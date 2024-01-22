function [simili, numero] = cerca_punti_simili001(massimi, minimi, righe, colonne)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%cerca_punti_simili001(massimi, minimi, righe, colonne)
%
%dato l'array (poi diventerà struttura appeno ho implementato la ricerca di
% più eventi dello stesso tipo) di thermo_results
% raggruppa gli eventi che avvengono nello stesso punto (primi vicini)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%prendo solo i rappresentanti
max_peaks_supp = massimi;
min_peaks_supp = minimi;
numero = 1;

%parto dai massimi e poi faccio i minimi che restano
i = 1;
while i <= length(max_peaks_supp(:,1))
    if max_peaks_supp(i, 3) ~= 0
        name = append('#', num2str(i));
        numero = i;

        array_store = zeros(0, 4);
        array_store(end+1,:) = max_peaks_supp(i,:);

        for j = 1 : length(max_peaks_supp(:,1))
            if max_peaks_supp(j, 3) ~= 0 %verifico se è nei primi vicini
                stato = raggruppo_2eventi(max_peaks_supp(i,1), max_peaks_supp(i,2), max_peaks_supp(j,1), max_peaks_supp(j,2), righe, colonne);

                if stato == 1
                    array_store(end+1,:) = max_peaks_supp(j,:);
                    max_peaks_supp(j,:) = [];
                    j = j - 1;
                end  
            end  
        end

        for j = 1 : length(min_peaks_supp(:,1))
            if min_peaks_supp(j, 3) ~= 0 %verifico se è nei primi vicini
                stato = raggruppo_2eventi_diversi(max_peaks_supp(i,1), max_peaks_supp(i,2), min_peaks_supp(j,1), min_peaks_supp(j,2), righe, colonne);

                if stato == 1
                    array_store(end+1,:) = min_peaks_supp(j,:);
                    min_peaks_supp(j,:) = [];
                    j = j - 1;
                end  
            end  
        end
        simili.(name) = {array_store};  
        i = i + 1;
    else
        max_peaks_supp(i,:) = [];
    end
end

%faccio i minimi che restano
i = 1;
while i <= length(min_peaks_supp(:,1))
    if min_peaks_supp(i, 3) ~= 0
        name = append('#', num2str(numero));
        numero = numero + 1;

        array_store = zeros(0, 4);
        array_store(end+1,:) = min_peaks_supp(i,:);

        for j = 1 : length(min_peaks_supp(:,1))
            if min_peaks_supp(j, 3) ~= 0 %verifico se è nei primi vicini
                stato = raggruppo_2eventi_diversi(min_peaks_supp(i,1), min_peaks_supp(i,2), min_peaks_supp(j,1), min_peaks_supp(j,2), righe, colonne);

                if stato == 1
                    array_store(end+1,:) = min_peaks_supp(j,:);
                    min_peaks_supp(j,:) = [];
                    j = j - 1;
                end  
            end  
        end
        simili.(name) = {array_store};
        i = i + 1;
    else
        min_peaks_supp(i,:) = [];
    end
end

end

