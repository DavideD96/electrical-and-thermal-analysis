function [simili, numero] = cerca_punti_simili001_multiEvento_001(Eventi_ripuliti, righe, colonne, frame_start, fr_diff)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2024-01-22 Last modification: 2024-01-22
%Authors: Cristina Zuccali
%cerca_punti_simili001_multiEvento_001(massimi, minimi)
%cerca i punti simili (che avvengono nella stessa regione di spazio) nella
%versione multi-evento
%   'Eventi_ripuliti' = 'frames_states_struct' = is a struct --> [time [s],
%                       {massimi}, {minimi}, area_max, area_min, state] only of max temp events
%
%dato l'array (poi diventerà struttura appeno ho implementato la ricerca di
% più eventi dello stesso tipo) di thermo_results
% raggruppa gli eventi che avvengono nello stesso punto (primi vicini)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%prendo solo i rappresentanti
Eventi_supp = Eventi_ripuliti;
numero = 1;

%parto dai massimi e poi faccio i minimi che restano
i = 1;
contatore = 1;
evento = 0;
while i <= length(fieldsnames(Eventi_supp))
    fname = append("frame", num2str(frame_start+ fr_diff + i - 1));

    if Eventi_supp.(fname).num_evento ~= 0
        simili.(name).(contatore) = Eventi_supp.(fname);

        if Eventi.(fname).massimi(1,1) ~= 0 & Eventi.(fname).minimi(1,1) ~= 0
            eventi_tutti = [Eventi.(fname).massimi; Eventi.(fname).minimi];
        elseif Eventi.(fname).massimi(1,1) ~= 0
            eventi_tutti = Eventi.(fname).massimi;
        elseif Eventi.(fname).minimi(1,1) ~= 0
            eventi_tutti = Eventi.(fname).minimi;
        else
            eventi_tutti = [];
        end

        numero = i;
        name = append("gruppo", num2str(evento));
        
        for j = 2 : length(fieldsname(Eventi_supp))
            fname_succ = append("frame", num2str(frame_start + j - 1));

            if Eventi_supp.(fname_succ).num_evento ~= 0 %verifico se è nei primi vicini

                if Eventi.(fname_succ).massimi(1,1) ~= 0 & Eventi.(fname_succ).minimi(1,1) ~= 0
                    eventi_tutti_succ = [Eventi.(fname_succ).massimi; Eventi.(fname_succ).minimi];
                elseif Eventi.(fname_succ).massimi(1,1) ~= 0
                    eventi_tutti_succ = Eventi.(fname_succ).massimi;
                elseif Eventi.(fname_succ).minimi(1,1) ~= 0
                    eventi_tutti_succ = Eventi.(fname_succ).minimi;
                else
                    eventi_tutti_succ = [];
                end

                stato = raggruppo_2eventi_002(eventi_tutti, eventi_tutti_succ, righe, colonne);

                if stato == 1
                    contatore = contatore + 1;

                    simili.(name).(contatore) = Eventi_supp.(fname_succ);

                    %pulisci
                    Eventi_supp.(fname_succ).massimi  = 0;
                    Eventi_supp.(fname_succ).minimi  = 0;
                    Eventi_supp.(fname_succ).area_max  = 0;
                    Eventi_supp.(fname_succ).area_min  = 0;
                    Eventi_supp.(fname_succ).num_evento  = 0;

                    j = j - 1;
                end  
            end  
        end 
        i = i + 1;
    end
    evento = evento + 1;
end

