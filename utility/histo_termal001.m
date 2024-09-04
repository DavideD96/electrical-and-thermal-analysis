
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

all_ev = [];
for ii = 1:size(events,1)
    if any(events{ii,3}) 
        all_ev = [all_ev,events{ii,3}];
    end
end

%n_ev = find(~cellfun(@isempty,events(:,3)),1,"last");
%n_ev = max(events{n_ev,3}); %trovo il numero totale di eventi

n_ev = max(all_ev);
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

    intensities_of_single_TE = [];
    % find frame and index of TE n° ii
    for kk = 1:size(events,1)
        %events{kk,3}==ii
        %any(find(events{kk,3}==ii) ~= 0)
        if isempty(events{kk,3}) == 0 && any(find(events{kk,3}==ii) ~= 0)
            ind_ev = find(events{kk,3}==ii); %indice per come l'evento ii è stato indicizzato all'interno del frame
            dove = [dove,kk]; 
            intensities_of_single_TE = [intensities_of_single_TE,events{kk,2}(ind_ev,2)]; % è vero sono smootate... ma va bene
        end
        %dove
    end

    inizio = dove(1); %indice di mDT in cui inizia evento. Essendo l'indice a sx devo fare inizio+delay-fr_diff-1 per usarlo su mT
    fine = dove(end); %Essendo l'indice a dx devo fare fine+delay-1 per usarlo su mT
    [maxim,coord] = max(intensities_of_single_TE);
    mid = inizio+coord-1;
    %mid = round((inizio+fine)/2)
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
    term_ev(ii,1) = matT(x,y,fine+delay-1)-matT(x,y,inizio+delay-1-deltat); %-2: vado al frame prima della detection
    matT(x,y,fine+delay)-matT(x,y,inizio+delay-1);
    term_ev;
    fine+delay;
    inizio+delay-1;
    dove = [];

end
term_ev
histogram(term_ev,40)
grid on
xlabel('\DeltaT associated to TE [K]')
ylabel('counts')

