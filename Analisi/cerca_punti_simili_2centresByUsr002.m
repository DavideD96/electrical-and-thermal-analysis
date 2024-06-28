function group1 = cerca_punti_simili_2centresByUsr002(coord1)

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

cd termoFiles_mat\
% times_ = load('timesDT.mat');
% times = times_.times;
Eventi = load('MatriceEventi.mat');
Eventi = Eventi.matriceEventi;
cd ..

% if frame_start > fr_diff
%     bias = frame_start;
% else
%     bias = fr_diff+1;
% end

%primo gruppo
group1 = zeros(size(Eventi,1),2);
group1(:,1) = Eventi(:,1);

for i = 1 : size(Eventi,1)  %ciclo su tutti i frames
    %fname = ['frame', num2str(i)];
    waitbar(i/size(Eventi,1));
    group1(i,2) = match_evento_area_002(Eventi(i,:),coord1,1); %1=NN
end
disp('io')
name = append('group_x',num2str(coord1(1)),'_y',num2str(coord1(2)));

save(name,"group1") %
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

