function [simili] = cerca_punti_simili_2centresByUsr(Eventi, coord1, coord2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%cerca_punti_simili001(massimi, minimi) e associa evento resistivo
%
% raggruppa gli eventi che avvengono nello stesso punto (primi vicini)
%
%  'Eventi' = struct containing 1 struct per frame: each of this contains 
%           info about events: time, maximum coord, minimum coord, areas, 
%           event count.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%prendo solo i rappresentanti
%parto dai massimi e poi faccio i minimi che restano
Eventi_supp = Eventi;
gruppo = 1;
for i = 1 : length(fieldnames(Eventi_supp))   %ciclo su tutti i frames
    Eventi_supp = 
end

save("Simili.mat", "simili")
end

