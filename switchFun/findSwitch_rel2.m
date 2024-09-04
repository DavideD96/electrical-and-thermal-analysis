function analyzed = findSwitch_rel2 (matr,col, matsigma,ns,normalize,RoG,threshHighRes)

%Date: 2019-02-18 Last Modification: 2019-03-19
%Author: M. Camponovo, D. Decastri
%
%   analyzed = findSwitch(matr,col,matSigma,ns,normalize)
%
%The program anlyzed the column 'col' of matrix 'matr' and collects switch
%events performing an anlysis on the variance of the data
%
%   matr: matrix with column data
%   col: an integer; index of column to be analyzed
%   matsigma: matrix with the value of the quantity and the correspondant
%             sigma on the coluns; the data have to be ordered form the 
%             greater to smaller one
%   ns: an integer; the number of sigma to consider the difference between
%       two adiaccent quantities a switch
%   normalize: if is true the program normalize the times (in the first 
%              column of matr with respect to the time of the first data.
%   RoG: store DeltaR or DeltaG in analyzed.
%   threshHighRes: threshold low conductance state (prevents detection when
%       sample is not conducting).


s = size(matr,1);
z = zeros(s,1);

if normalize == true %MODIFICATO
    matr(:,1) = matr(:,1) - matr(1,1);
end

analyzed = [matr z z];

figure;
plot(matr(:,1),matr(:,col));
hold on;

       delta = diff(matr(:,col));
       rel = (delta./matr(1:end-1,col));
       
event_happening = 0;
n_event = 0;

nocond_thrsd = 0; %A
if threshHighRes ~= 0
    nocond_thrsd = 1.5e-5; %A
end

    for i=1:s - 1 %ho aggiunto il "-1"
        [mv,sv] = sigmaSelector(matr(i,col),matsigma);
        checkCond = abs(matr(i,col)) > nocond_thrsd || abs(matr(i+1,col)) > nocond_thrsd;
        
        if abs(rel(i)) > ns*sv/abs(mv) && checkCond %o sei nel bel mezzo di un evento, o alla fine
            if event_happening == 0  %allora l'evento inizia
                event_happening = i;
                n_event = n_event + 1;
                analyzed(i,end-1) = n_event; %detected now
                plot(matr(i,1), matr(i,col), 'or');
            else %devo fare dei controlli ulteriori
                if rel(i)*rel(i-1) > 0 %sono nello stesso evento
                    analyzed(i,end-1) = 0; %detected yet
                else %il primo evento finisce e ne inizia un altro
                    if RoG == 0
                        analyzed(event_happening,end) = matr(i,end) - matr(event_happening,end); %modifica Davide: no col ma end (resistenza)
                    else
                        analyzed(event_happening,end) = 1./matr(i,end) - 1./matr(event_happening,end);
                    end
                    event_happening = i;
                    n_event = n_event + 1;
                    analyzed(i,end-1) = n_event; %detected now
                    plot(matr(i,1), matr(i,col), 'or');
                end
                
            end

            % if analyzed(i-1,end-1) ~= 0 %possono essere successe due cose: eventi distinti (spike), o no.
            %     if rel(i)*rel(i-1) > 0 %stesso evento
            %         analyzed(i,end-1) = -1; %sei nel bel mezzo di un evento
            %         analyzed(i,end-2) = 1;
            %     else %spike
            %         analyzed(i,end-1) = 1;
            %         analyzed(i-1,end) = matr(i+1,col) - matr(event_happening,col);
            %         %analyzed(i,end) = matr(i+1,col) - matr(i,col);
            %         event_happening = i; %non "chiudo" l'analisi del secondo evento
            %         plot(matr(i,1), matr(i,col), 'or'); 
            %         analyzed(i,end-2) = 2;
            %     end
            % else %sei all'inizio di un nuovo evento
            %     plot(matr(i,1), matr(i,col), 'or');               
            %     analyzed(i,end-1) = 1;
            %     event_happening = i;
            %     analyzed(i,end-2) = 3;
            % end
        else 


            if i > 1
                if event_happening ~= 0
                    if RoG == 0
                        analyzed(event_happening,end) = matr(i,end) - matr(event_happening,end);
                    else
                        analyzed(event_happening,end) = 1./matr(i,end) - 1./matr(event_happening,end);
                    end
                    plot(matr(i,1), matr(i,col), 'or');
                    event_happening = 0;
                end
                % if analyzed(i-1,end-1) ~= 0 %indipendenetemente dal prodotto
                %     if event_happening ~= 0 %altrimenti c'è stato uno spike e ho già registrato i dati prima
                %         analyzed(event_happening,end) = matr(i+1,col)-matr(event_happening,col);
                %         event_happening = 0;
                %         analyzed(i,end-2) = 4;
                %     end
                %     plot(matr(i,1), matr(i,col), 'or');   
                % end
            end
        end
    end

hold off;            
end