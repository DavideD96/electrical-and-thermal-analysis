classdef esplora_video1 < matlab.apps.AppBase

    properties (Access = public)

        UIFigure matlab.ui.Figure
        UIAxesFrame1 matlab.ui.control.UIAxes
        UIAxesFrame2 matlab.ui.control.UIAxes
        UIAxesDiff matlab.ui.control.UIAxes

        LoadButton matlab.ui.control.Button
        SelectPixelButton matlab.ui.control.Button
        SaveFigButton matlab.ui.control.Button
        ScanPeaksButton matlab.ui.control.Button

        FrameSlider matlab.ui.control.Slider
        FrameSliderLabel matlab.ui.control.Label

        OffsetField matlab.ui.control.NumericEditField
        OffsetLabel matlab.ui.control.Label

        StepField matlab.ui.control.NumericEditField
        StepLabel matlab.ui.control.Label

        ThresholdField matlab.ui.control.NumericEditField
        ThresholdLabel matlab.ui.control.Label

        Data3D double
        NumFrames double

    end


    methods (Access = private)

        % =====================================================
        % LOAD
        % =====================================================
        function loadMatrix(app)

            [file,path] = uigetfile('*.mat');

            if isequal(file,0)
                return;
            end

            S = load(fullfile(path,file));

            if ~isfield(S,'mtotalT')
                uialert(app.UIFigure,'mTotalT mancante','Errore');
                return;
            end

            app.Data3D = double(S.mtotalT);

            if ndims(app.Data3D) ~= 3
                uialert(app.UIFigure,'La matrice deve essere 3D','Errore');
                return;
            end

            app.NumFrames = size(app.Data3D,3);

            app.FrameSlider.Limits = [1 app.NumFrames];
            app.FrameSlider.Value = 1;

            updatePlot(app);

        end


        % =====================================================
        % UPDATE PLOT
        % =====================================================
        function updatePlot(app)

            if isempty(app.Data3D)
                return;
            end

            idx = round(app.FrameSlider.Value);

            offset = round(app.OffsetField.Value);

            idx2 = min(max(idx + offset,1),app.NumFrames);

            f1 = app.Data3D(:,:,idx);

            f2 = app.Data3D(:,:,idx2);

            d = f2 - f1;


            % FRAME 1
            imagesc(app.UIAxesFrame1,f1);

            axis(app.UIAxesFrame1,'image');

            colormap(app.UIAxesFrame1,'gray');

            title(app.UIAxesFrame1,...
                sprintf('Frame %d',idx));


            % FRAME 2
            imagesc(app.UIAxesFrame2,f2);

            axis(app.UIAxesFrame2,'image');

            colormap(app.UIAxesFrame2,'gray');

            title(app.UIAxesFrame2,...
                sprintf('Frame %d',idx2));


            % DIFFERENZA
            imagesc(app.UIAxesDiff,d);

            axis(app.UIAxesDiff,'image');

            colormap(app.UIAxesDiff,'jet');

            colorbar(app.UIAxesDiff);

            title(app.UIAxesDiff,...
                sprintf('Diff %d - %d',idx2,idx));

        end


        % =====================================================
        % SCROLL MOUSE
        % =====================================================
        function mouseScroll(app,event)

            if isempty(app.Data3D)
                return;
            end

            step = max(1,round(app.StepField.Value));

            idx = round(app.FrameSlider.Value);

            if event.VerticalScrollCount > 0
                idx = idx + step;
            else
                idx = idx - step;
            end

            idx = min(max(idx,1),app.NumFrames);

            app.FrameSlider.Value = idx;

            updatePlot(app);

        end


        % =====================================================
        % SELECT PIXEL
        % =====================================================
        function selectPixel(app)

            if isempty(app.Data3D)
                return;
            end

            idx = round(app.FrameSlider.Value);

            offset = round(app.OffsetField.Value);

            idx2 = min(max(idx + offset,1),app.NumFrames);

            diffImg = app.Data3D(:,:,idx2) - ...
                      app.Data3D(:,:,idx);


            % figura esterna
            f = figure('Name','Selezione Pixel');

            ax = axes(f);

            imagesc(ax,diffImg);

            axis(ax,'image');

            colormap(ax,'jet');

            title(ax,'Clicca un pixel');


            % selezione pixel
            [x,y] = ginput(1);

            x = round(x);

            y = round(y);

            close(f);


            % controlli limiti
            [ny,nx,~] = size(app.Data3D);

            if x < 1 || x > nx || y < 1 || y > ny
                return;
            end


            % traccia temporale
            trace = squeeze(app.Data3D(y,x,:));

            filename = sprintf(...
                'trace_x%03d_y%03d.mat',x,y);

            save(filename,'trace','x','y');

            disp("Salvato: " + filename);


            % plot traccia
            figure;

            plot(trace);

            grid on;

            title(sprintf('Pixel (%d,%d)',x,y));

            xlabel('Frame');

            ylabel('Intensity');

        end


        % =====================================================
        % SAVE CURRENT DIFFERENTIAL IMAGE AS .FIG
        % =====================================================
        function saveCurrentDiffFig(app)

            if isempty(app.Data3D)
                return;
            end

            idx = round(app.FrameSlider.Value);

            offset = round(app.OffsetField.Value);

            idx2 = min(max(idx + offset,1),app.NumFrames);

            diffImg = app.Data3D(:,:,idx2) - ...
                      app.Data3D(:,:,idx);


            % figura invisibile
            f = figure('Visible','off');

            imagesc(diffImg);

            axis image;

            load("ThermoColorMap2.mat")

            colormap(cm);

            colorbar;

            title(sprintf('Diff %d - %d',idx2,idx));


            % nome file
            filename = sprintf('%d-%d.fig',idx2,idx);


            % salva
            savefig(f,filename);

            close(f);

            disp("Salvato: " + filename);

        end


        % =====================================================
        % SCAN PEAKS
        %
        % Scansiona le immagini differenziali:
        %   diff = Frame(i + Offset) - Frame(i)
        %
        % I frame di partenza vengono visitati con Step.
        %
        % Per ogni differenziale vengono salvati:
        %   - massimo positivo
        %   - minimo negativo
        %
        % I valori con abs(valore) > Threshold vengono
        % evidenziati nel grafico con un asterisco.
        % =====================================================
        function scanPeaks(app)

            if isempty(app.Data3D)
                uialert(app.UIFigure,...
                    'Caricare prima un file MAT.',...
                    'Nessun dato');

                return;
            end


            % Lettura parametri utente
            offset = round(app.OffsetField.Value);

            step = max(1,round(app.StepField.Value));

            threshold = app.ThresholdField.Value;


            if ~isfinite(offset) || offset == 0
                uialert(app.UIFigure,...
                    'Offset deve essere un numero intero diverso da zero.',...
                    'Parametro non valido');

                return;
            end


            if ~isfinite(step) || step < 1
                uialert(app.UIFigure,...
                    'Step deve essere un intero maggiore o uguale a 1.',...
                    'Parametro non valido');

                return;
            end


            if ~isfinite(threshold) || threshold < 0
                uialert(app.UIFigure,...
                    'Threshold deve essere un numero maggiore o uguale a zero.',...
                    'Parametro non valido');

                return;
            end


            % Costruzione degli indici dei frame iniziali.
            %
            % Per offset positivo:
            %   i + offset <= NumFrames
            %
            % Per offset negativo:
            %   i + offset >= 1
            if offset > 0

                startFrames = 1:step:(app.NumFrames - offset);

            else

                startFrames = (1 - offset):step:app.NumFrames;

            end


            if isempty(startFrames)

                uialert(app.UIFigure,...
                    'Offset troppo grande: nessuna immagine differenziale disponibile.',...
                    'Nessun dato da scansionare');

                return;

            end


            n = numel(startFrames);

            frameNumbers = zeros(1,n);

            maxPeaks = zeros(1,n);

            minPeaks = zeros(1,n);


            % Scansione delle immagini differenziali
            for k = 1:n

                idx = startFrames(k);

                idx2 = idx + offset;


                f1 = app.Data3D(:,:,idx);

                f2 = app.Data3D(:,:,idx2);


                diffImg = f2 - f1;


                % Massimo positivo e minimo negativo
                maxPeaks(k) = max(diffImg(:));

                minPeaks(k) = min(diffImg(:));


                frameNumbers(k) = idx;

            end


            % =================================================
            % GRAFICO 2D
            % =================================================
            f = figure(...
                'Name','Picchi di temperatura nel tempo',...
                'NumberTitle','off');

            ax = axes(f);

            hold(ax,'on');

            grid(ax,'on');


            % Curve dei massimi e minimi
            plot(ax,...
                frameNumbers,...
                maxPeaks,...
                '-o',...
                'DisplayName','Massimo positivo');

            plot(ax,...
                frameNumbers,...
                minPeaks,...
                '-o',...
                'DisplayName','Minimo negativo');


            % Linee di soglia
            yline(ax,...
                threshold,...
                '--',...
                'DisplayName','+Threshold');

            yline(ax,...
                -threshold,...
                '--',...
                'DisplayName','-Threshold');


            % =================================================
            % ASTERISCHI SUI PICCHI SOPRA SOGLIA
            %
            % Positivi:
            %   maxPeak > threshold
            %
            % Negativi:
            %   minPeak < -threshold
            % =================================================
            positiveAbove = maxPeaks > threshold;

            negativeAbove = minPeaks < -threshold;


            % Asterischi sui massimi positivi
            if any(positiveAbove)

                text(...
                    ax,...
                    frameNumbers(positiveAbove),...
                    maxPeaks(positiveAbove),...
                    repmat({'*'},1,sum(positiveAbove)),...
                    'HorizontalAlignment','center',...
                    'VerticalAlignment','bottom',...
                    'FontSize',14,...
                    'FontWeight','bold');

            end


            % Asterischi sui minimi negativi
            if any(negativeAbove)

                text(...
                    ax,...
                    frameNumbers(negativeAbove),...
                    minPeaks(negativeAbove),...
                    repmat({'*'},1,sum(negativeAbove)),...
                    'HorizontalAlignment','center',...
                    'VerticalAlignment','top',...
                    'FontSize',14,...
                    'FontWeight','bold');

            end


            xlabel(ax,'Frame');

            ylabel(ax,'Differenza di temperatura');

            title(ax,...
                sprintf(...
                'Picchi di temperatura nel tempo - Offset = %d, Step = %d, Threshold = %.4g',...
                offset,...
                step,...
                threshold));


            legend(ax,'Location','best');

            hold(ax,'off');


            % Messaggio finale
            nPositive = sum(positiveAbove);

            nNegative = sum(negativeAbove);

            uialert(...
                app.UIFigure,...
                sprintf(...
                ['Scansione completata.\n\n' ...
                 'Immagini differenziali analizzate: %d\n' ...
                 'Picchi positivi sopra soglia: %d\n' ...
                 'Picchi negativi sopra soglia: %d'],...
                 n,...
                 nPositive,...
                 nNegative),...
                'Scan Peaks');

        end

    end


    % =========================================================
    % CALLBACKS
    % =========================================================
    methods (Access = private)


        function LoadButtonPushed(app,event)

            loadMatrix(app);

        end


        function FrameSliderValueChanged(app,event)

            updatePlot(app);

        end


        function OffsetFieldValueChanged(app,event)

            updatePlot(app);

        end


        function SelectPixelButtonPushed(app,event)

            selectPixel(app);

        end


        function SaveFigButtonPushed(app,event)

            saveCurrentDiffFig(app);

        end


        function ScanPeaksButtonPushed(app,event)

            scanPeaks(app);

        end

    end


    % =========================================================
    % COSTRUTTORE
    % =========================================================
    methods (Access = public)


        function app = esplora_video1


            % =================================================
            % UIFIGURE
            % =================================================
            app.UIFigure = uifigure(...
                'Position',[100 100 1400 700]);

            app.UIFigure.WindowScrollWheelFcn = ...
                @(src,event) mouseScroll(app,event);


            % =================================================
            % AXES
            % =================================================
            app.UIAxesFrame1 = uiaxes(...
                app.UIFigure,...
                'Position',[30 200 400 400]);


            app.UIAxesFrame2 = uiaxes(...
                app.UIFigure,...
                'Position',[480 200 400 400]);


            app.UIAxesDiff = uiaxes(...
                app.UIFigure,...
                'Position',[930 200 400 400]);


            % =================================================
            % LOAD BUTTON
            % =================================================
            app.LoadButton = uibutton(...
                app.UIFigure,'push');

            app.LoadButton.Text = 'Load';

            app.LoadButton.Position = [30 100 120 40];

            app.LoadButton.ButtonPushedFcn = ...
                @(~,~)LoadButtonPushed(app);


            % =================================================
            % SELECT PIXEL BUTTON
            % =================================================
            app.SelectPixelButton = uibutton(...
                app.UIFigure,'push');

            app.SelectPixelButton.Text = ...
                'Select Pixel';

            app.SelectPixelButton.Position = ...
                [170 100 140 40];

            app.SelectPixelButton.ButtonPushedFcn = ...
                @(~,~)SelectPixelButtonPushed(app);


            % =================================================
            % SAVE FIG BUTTON
            % =================================================
            app.SaveFigButton = uibutton(...
                app.UIFigure,'push');

            app.SaveFigButton.Text = 'Save FIG';

            app.SaveFigButton.Position = ...
                [330 100 140 40];

            app.SaveFigButton.ButtonPushedFcn = ...
                @(~,~)SaveFigButtonPushed(app);


            % =================================================
            % SCAN PEAKS BUTTON
            % =================================================
            app.ScanPeaksButton = uibutton(...
                app.UIFigure,'push');

            app.ScanPeaksButton.Text = ...
                'Scan Peaks';

            app.ScanPeaksButton.Position = ...
                [480 100 140 40];

            app.ScanPeaksButton.ButtonPushedFcn = ...
                @(~,~)ScanPeaksButtonPushed(app);


            % =================================================
            % FRAME SLIDER
            % =================================================
            app.FrameSlider = uislider(app.UIFigure);

            app.FrameSlider.Position = ...
                [550 120 400 3];

            app.FrameSlider.ValueChangedFcn = ...
                @(~,~)FrameSliderValueChanged(app);


            app.FrameSliderLabel = uilabel(app.UIFigure);

            app.FrameSliderLabel.Text = 'Frame';

            app.FrameSliderLabel.Position = ...
                [480 110 50 20];


            % =================================================
            % OFFSET
            % =================================================
            app.OffsetField = uieditfield(...
                app.UIFigure,'numeric');

            app.OffsetField.Value = 10;

            app.OffsetField.Position = ...
                [1020 100 80 30];

            app.OffsetField.ValueChangedFcn = ...
                @(~,~)OffsetFieldValueChanged(app);


            app.OffsetLabel = uilabel(app.UIFigure);

            app.OffsetLabel.Text = 'Offset';

            app.OffsetLabel.Position = ...
                [970 110 50 20];


            % =================================================
            % STEP
            % =================================================
            app.StepField = uieditfield(...
                app.UIFigure,'numeric');

            app.StepField.Value = 1;

            app.StepField.Position = ...
                [1200 100 80 30];


            app.StepLabel = uilabel(app.UIFigure);

            app.StepLabel.Text = 'Step';

            app.StepLabel.Position = ...
                [1160 110 40 20];


            % =================================================
            % THRESHOLD
            % =================================================
            app.ThresholdField = uieditfield(...
                app.UIFigure,'numeric');

            app.ThresholdField.Value = 0;

            app.ThresholdField.Position = ...
                [1020 50 80 30];


            app.ThresholdLabel = uilabel(app.UIFigure);

            app.ThresholdLabel.Text = 'Threshold';

            app.ThresholdLabel.Position = ...
                [950 60 70 20];

        end

    end

end
