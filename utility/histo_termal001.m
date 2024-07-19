
%            v_________
%           /
%          /
%       v /
%________/
%      |__|
%        1
%        |__|
%          1



%          _______________
%         |
% ________|
%      |__|
%        1
%       |__|
%         1
%        |__|
%          1

cd termoFiles_mat
events = load("DD_Eventi_Termo.mat");
events = events.DD_Eventi;


matT = load('mtotalT.mat');
matT = matT.mtotalT;
cd ..

n_ev = find(~cellfun(@isempty,events(:,3)),1,"last");
n_ev = max(events{n_ev,3}); %trovo il numero totale di eventi
term_ev = zeros(n_ev,1);

[Rows, Columns] = size(matT(:,:,1));
[data_x, data_y] = meshgrid( 1:Columns, 1:Rows);

cd parameters
ThermalParameters_ = load('ThermalParameters.mat');
ThermalParameters = ThermalParameters_.ThermalParameters;
cd ..

delay = ThermalParameters.delay;
deltat = ThermalParameters.fr_diff;
dove = [];

for ii = 1:n_ev

    % find frame and index of TE n° ii
    for kk = 1:size(events,1)
        %events{kk,3}==ii
        %any(find(events{kk,3}==ii) ~= 0)
        if isempty(events{kk,3}) == 0 && any(find(events{kk,3}==ii) ~= 0)
            ind_ev = find(events{kk,3}==ii); %indice per come l'evento ii è stato indicizzato all'interno del frame
            dove = [dove,kk]; 
        end
        %dove
    end

    inizio = dove(1);
    fine = dove(end);
    mid = round((inizio+fine)/2);
    %events{mid,2}(ind_ev,1)

    y = ceil(events{mid,2}(ind_ev,1)/Rows); %coordinate and amplitudes are stored in events{mid,2}(:,:)
    x = events{mid,2}(ind_ev,1) - Rows*(y-1);
    %matT
    % if ii == 19
    %     dove
    %     y
    %     x
    %     matT(x,y,fine+delay)
    %     matT(x,y,inizio+delay-2)
    %     term_ev(ii,1) = matT(x,y,fine+delay)-matT(x,y,inizio+delay-2)
    % end
    term_ev(ii,1) = matT(x,y,fine+delay)-matT(x,y,inizio+delay-2); %-2: vado al frame prima della detection
    matT(x,y,fine+delay)-matT(x,y,inizio+delay-1)
    fine+delay
    inizio+delay-1
    dove = [];

end
histogram(term_ev,25)

