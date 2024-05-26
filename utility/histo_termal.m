cd termoFiles_mat

events = load("Eventi_Termo_principali.mat");
events = events.results;
matT = load('mtotalT.mat');
matT = matT.mtotalT;
matDT = load('mtotalDT.mat');
matDT = matDT.mtotalDT;

[Rows, Columns] = size(matT(:,:,1));
[data_x, data_y] = meshgrid( 1:Columns, 1:Rows);
%dati = [data_x, data_y, mdiff];

hind_ev = 1;
hind = 1;
hind_start = 0;
hind_end = 0;

cind_ev = 1;
cind = 1;
cind_start = 0;
cind_end = 0;

hots = 0;
colds = 0;

hind_start = find(events(:,4)>0);
hind_start = hind_start(1);
cind_start = find(events(:,5)<0);
cind_start = cind_start(1);
%hind_start
hind_ev = events(hind_start,8);
cind_ev = events(cind_start,8);

 hind_start =0;
  chind_start=0; 

n_ev = max(events(:,8));
term_ev = zeros(n_ev,1);

    [Rows, Columns] = size (matT(:,:,1));
[data_x, data_y] = meshgrid( 1:Columns, 1:Rows);
delay = 29;
deltat = 3;

for ii = 1:n_ev
    dove = find(events(:,8)==ii);
    %disp(dove(1:4))
    inizio = dove(1);
    fine = dove(end);
    ind = round((inizio+fine)/2);
    %ii
    if events(inizio,4) > 0 && events(inizio,5) < 0
        if events(fine,4) > 0
            y = ceil(events(ind,2)/Rows); %%floor up
            x = events(ind,2) - Rows*(y-1);
            %events(:,2)
            %disp(events(ind,2))
            matT(x,y,fine)

            term_ev(ii) = matT(x,y,fine+delay+deltat)-matT(x,y,inizio+delay);
        else 
            y = ceil(events(ind,3)/Rows); %%floor up
            x = events(ind,3) - Rows*(y-1);
            %events(:,2)
            %disp(events(ind,2))
            term_ev(ii) = matT(x,y,fine+delay+deltat)-matT(x,y,inizio+delay);
        end

    elseif events(inizio,4) > 0

        %disp(events(ii,2))
        y = ceil(events(ind,2)/Rows); %%floor up
        x = events(ind,2) - Rows*(y-1);
        %events(:,2)
        %disp(events(ind,2))
        %disp(matDT(y,x,fine))
        term_ev(ii) = matT(x,y,fine+delay+deltat)-matT(x,y,inizio+delay);
    else
        y = ceil(events(ind,3)/Rows); %%floor up
        x = events(ind,3) - Rows*(y-1);
        term_ev(ii) = matT(x,y,fine+delay+deltat)-matT(x,y,inizio+delay);
    end
end
histogram(term_ev,25)
cd ..

% for ii = min(cind_start,hind_start)+1:length(events)
% 
%     if events(ii,8) > 0 && events(ii,4) > 0 %hot
%         %hind_ev
%         if events(ii,8) == hind_ev 
%             %disp(events(ii,4))
%             hind_end = ii;
%             hots(1,end) = hots(1,end)+events(ii,4);
%         else
%             %disp(events(ii,4))
%             hind_start = ii;
%             hind_end = ii; %singoli            
%             %hots(1,end)= hots(1,end)+events(ii,4);
%             hots = [hots;events(ii,4)];
%             hind_ev = events(ii,8);
%         end
% 
%     end
% 
%     if events(ii,8) > 0 && events(ii,5) < 0 %cold
%         if cind_start == 0
%             cind_start = ii;
%             %colds = [colds;events(ii,5)];
%         end
% 
%         if events(ii,8) == hind_ev 
%             cind_end = ii;
%             colds(1,end) = colds(1,end)+events(ii,5);
%         else
%             cind_start = ii;
%             cind_end = ii; %singoli
%             colds(1,end) = colds(1,end)+events(ii,5);
%             colds = [colds;events(ii,5)];
%             hind_ev = events(ii,8);
%         end
%     end
% end 

%hots



