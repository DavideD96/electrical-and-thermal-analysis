classdef esplora_video < matlab.apps.AppBase

    properties (Access = public)

        UIFigure matlab.ui.Figure

        UIAxesFrame1 matlab.ui.control.UIAxes
        UIAxesFrame2 matlab.ui.control.UIAxes
        UIAxesDiff matlab.ui.control.UIAxes

        LoadButton matlab.ui.control.Button
        SelectPixelButton matlab.ui.control.Button

        FrameSlider matlab.ui.control.Slider
        FrameSliderLabel matlab.ui.control.Label

        OffsetField matlab.ui.control.NumericEditField
        OffsetLabel matlab.ui.control.Label

        StepField matlab.ui.control.NumericEditField
        StepLabel matlab.ui.control.Label

        Data3D double
        NumFrames double

    end

    methods (Access = private)

        % =====================================================
        % LOAD
        % =====================================================
        function loadMatrix(app)

            [file,path] = uigetfile('*.mat');
            if isequal(file,0), return; end

            S = load(fullfile(path,file));

            if ~isfield(S,'mtotalT')
                uialert(app.UIFigure,'mTotalT mancante','Errore');
                return;
            end

            app.Data3D = double(S.mtotalT);

            if ndims(app.Data3D) ~= 3
                uialert(app.UIFigure,'Deve essere 3D','Errore');
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
            d  = f2 - f1;

            imagesc(app.UIAxesFrame1,f1);
            axis(app.UIAxesFrame1,'image');
            colormap(app.UIAxesFrame1,'gray');
            title(app.UIAxesFrame1,sprintf('Frame %d',idx));

            imagesc(app.UIAxesFrame2,f2);
            axis(app.UIAxesFrame2,'image');
            colormap(app.UIAxesFrame2,'gray');
            title(app.UIAxesFrame2,sprintf('Frame %d',idx2));

            imagesc(app.UIAxesDiff,d);
            axis(app.UIAxesDiff,'image');
            colormap(app.UIAxesDiff,'jet');
            colorbar(app.UIAxesDiff);

            title(app.UIAxesDiff,sprintf('Diff %d - %d',idx2,idx));

        end

        % =====================================================
        % SCROLL
        % =====================================================
        function mouseScroll(app,event)

            if isempty(app.Data3D), return; end

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
        % SELEZIONE PIXEL CON FIGURA ESTERNA + GINPUT
        % =====================================================
        function selectPixel(app)

            if isempty(app.Data3D)
                return;
            end

            idx = round(app.FrameSlider.Value);
            offset = round(app.OffsetField.Value);
            idx2 = min(max(idx + offset,1),app.NumFrames);

            diffImg = app.Data3D(:,:,idx2) - app.Data3D(:,:,idx);

            % --- NUOVA FIGURA ESTERNA ---
            f = figure('Name','Selezione Pixel');
            ax = axes(f);

            imagesc(ax,diffImg);
            axis(ax,'image');
            colormap(ax,'jet');
            title(ax,'Clicca un pixel');

            % --- GINPUT FUNZIONA QUI ---
            [x,y] = ginput(1);

            x = round(x);
            y = round(y);

            close(f);

            % controllo limiti
            [ny,nx,~] = size(app.Data3D);

            if x < 1 || x > nx || y < 1 || y > ny
                return;
            end

            % traccia temporale
            trace = squeeze(app.Data3D(y,x,:));

            filename = sprintf('trace_x%03d_y%03d.mat',x,y);

            save(filename,'trace','x','y');

            disp("Salvato: " + filename);

            % plot
            figure;
            plot(trace);
            grid on;
            title(sprintf('Pixel (%d,%d)',x,y));
            xlabel('Frame');
            ylabel('Intensity');

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

    end

    % =========================================================
    % COSTRUTTORE
    % =========================================================
    methods (Access = public)

        function app = esplora_video

            app.UIFigure = uifigure('Position',[100 100 1400 700]);

            app.UIFigure.WindowScrollWheelFcn = ...
                @(src,event) mouseScroll(app,event);

            % AXES
            app.UIAxesFrame1 = uiaxes(app.UIFigure,'Position',[30 200 400 400]);
            app.UIAxesFrame2 = uiaxes(app.UIFigure,'Position',[480 200 400 400]);
            app.UIAxesDiff   = uiaxes(app.UIFigure,'Position',[930 200 400 400]);

            % BUTTONS
            app.LoadButton = uibutton(app.UIFigure,'push');
            app.LoadButton.Text = 'Load';
            app.LoadButton.Position = [30 100 120 40];
            app.LoadButton.ButtonPushedFcn = @(~,~)LoadButtonPushed(app);

            app.SelectPixelButton = uibutton(app.UIFigure,'push');
            app.SelectPixelButton.Text = 'Select Pixel';
            app.SelectPixelButton.Position = [170 100 140 40];
            app.SelectPixelButton.ButtonPushedFcn = @(~,~)SelectPixelButtonPushed(app);

            % SLIDER
            app.FrameSlider = uislider(app.UIFigure);
            app.FrameSlider.Position = [350 120 400 3];
            app.FrameSlider.ValueChangedFcn = @(~,~)FrameSliderValueChanged(app);

            app.FrameSliderLabel = uilabel(app.UIFigure);
            app.FrameSliderLabel.Text = 'Frame';
            app.FrameSliderLabel.Position = [300 110 50 20];

            % OFFSET
            app.OffsetField = uieditfield(app.UIFigure,'numeric');
            app.OffsetField.Value = 10;
            app.OffsetField.Position = [800 100 80 30];
            app.OffsetField.ValueChangedFcn = @(~,~)OffsetFieldValueChanged(app);

            app.OffsetLabel = uilabel(app.UIFigure);
            app.OffsetLabel.Text = 'Offset';
            app.OffsetLabel.Position = [740 110 50 20];

            % STEP
            app.StepField = uieditfield(app.UIFigure,'numeric');
            app.StepField.Value = 1;
            app.StepField.Position = [950 100 80 30];

            app.StepLabel = uilabel(app.UIFigure);
            app.StepLabel.Text = 'Step';
            app.StepLabel.Position = [910 110 40 20];

        end

    end
end