function group1 = cerca_punti_simili_2centresByUsr(Eventi, bias,fr_diff, coord1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%cerca_punti_simili001(massimi, minimi) e associa evento resistivo
%
% raggruppa gli eventi che avvengono nello stesso punto (primi vicini)
%
%   'coord1' = coordinates of the first cluster
%   'Eventi' = struct containing 1 struct per frame: each of this contains 
%           info about events: time, maximum coord, minimum coord, areas, 
%           event count.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%prendo solo i rappresentanti
%parto dai massimi e poi faccio i minimi che restano
Eventi_supp = Eventi;

cd termoFiles_mat\
times_ = load('timesDT.mat');
times = times_.times;
cd ..

% if frame_start > fr_diff
%     bias = frame_start;
% else
%     bias = fr_diff+1;
% end

%primo gruppo
group1 = zeros(length(fieldnames(Eventi_supp)),2);
group1(:,1) = times(bias+1:end)';

for i = bias+fr_diff : length(fieldnames(Eventi_supp))+bias-1  %ciclo su tutti i frames
    fname = ['frame', num2str(i)];
    group1(i-bias-fr_diff+1,2) = match_evento_area_001(Eventi_supp.(fname),coord1,1);
end
disp('io')
%secondo gruppo
% group2 = zeros(length(fieldnames(Eventi_supp)),2);
% group2(:,1) = times(1:end-(bias))';
% 
% % for i = bias+fr_diff : length(fieldnames(Eventi_supp))+bias-1   %ciclo su tutti i frames
% %     fname = ['frame', num2str(i)];
% %     group2(i-bias+1,2) = match_evento_area_001(Eventi_supp.(fname),coord2,2);
% % end
% 
% %save("Simili.mat", "simili")
end

