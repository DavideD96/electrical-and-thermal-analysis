function [tempi_simili] = matrice_simili_tempo003(Simili, n_gruppi)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%24/01/2024
%cerca_punti_simili001(massimi, minimi) e associa evento resistivo
%[tempi_simili] = matrice_simili_tempo(Simili, gruppo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%prendi matrice dei tempi
cd termoFiles_mat
    times = load("timesDT.mat");
    times = cell2mat(struct2cell(times));
cd ..
times = times';

%prendo i 3 gruppi con lunghezza maggiore
n_eventi = zeros(length(fieldnames(Simili)), 2);

for i = 1 : length(fieldnames(Simili))
    name_gruppo = append("gruppo", num2str(i));
    
    n_eventi(i,2) = length(fieldnames(Simili.(name_gruppo)));
    n_eventi(i,1) = i;
end

n_eventi = sortrows(n_eventi, 2, "descend");
gruppi = n_eventi(1:n_gruppi, 1);


%crea matrice
tempi_simili = zeros(length(times(:,1)), n_gruppi + 1);
tempi_simili(:,1) = times(:,1);


%aggiungo 1 per gli eventi
for k = 1 : n_gruppi
    name_gruppo = append("gruppo", num2str(gruppi(k,1)));

    for i = 1 : length(fieldnames(Simili.(name_gruppo)))
        name_evento = append("evento", num2str(i));
    
        for j = 1 : length(tempi_simili(:,1))
            if tempi_simili(j,1) == Simili.(name_gruppo).(name_evento).tempo 
                tempi_simili(j,k+1) = 1;
                break
            end
        end
    end
end
end

