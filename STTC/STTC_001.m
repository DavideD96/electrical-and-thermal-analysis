function ci = STTC_001(time_serieA,time_serieB,deltat)

%Compute pairwise correlation index, according to Cutts and Eglen, in
%"Detecting Pairwise Correlations in Spike Trains: An Objective Comparison 
%of Methods and Application to the Study of Retinal Waves"

%   ci = STTC_001(time_serieA,time_serieB,deltat)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  T_A  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nsamplA = size(time_serieA);
eventiA = time_serieA(time_serieA(:,2) ~= 0,:);
neventiA = size(eventiA,1);

Tempi_occupatiA = zeros(neventiA,2);

for i = 1:neventiA
    Tempi_occupatiA(i,1) = eventiA(i,1)-deltat;
    Tempi_occupatiA(i,2) = eventiA(i,1)+deltat;
end


intervalli_realiA = [Tempi_occupatiA(1,1),Tempi_occupatiA(1,2)];
intervallone_indexA = 1;

for i = 2:neventiA
    if Tempi_occupatiA(i,1) < Tempi_occupatiA(i-1,2) %se l'inizio della seconda finestra è prima della fine della prima...
        intervalli_realiA(intervallone_indexA,2) = Tempi_occupatiA(i,2); %la nuova fine dell'intervallone è...
    else %si apre un nuovo intervallone
        intervalli_realiA = [intervalli_realiA; Tempi_occupatiA(i,:)];
        intervallone_indexA = intervallone_indexA + 1;
    end
end

%cut the edges in order to avoid t < 0 or t > T
if intervalli_realiA(1,1) < 0
    intervalli_realiA(1,1) = 0;
end
if intervalli_realiA(end,2) > time_serieA(end,1)
    intervalli_realiA(end,2) = time_serieA(end,1);
end

%compute T_A
T_A = sum(intervalli_realiA(:,2)-intervalli_realiA(:,1),"all")/(time_serieA(end,1)-time_serieA(1,1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  T_B  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nsamplB = size(time_serieB);
eventiB = time_serieB(time_serieB(:,2) ~= 0,:);
neventiB = size(eventiB,1);

Tempi_occupatiB = zeros(neventiB,2);

for i = 1:neventiB
    Tempi_occupatiB(i,1) = eventiB(i,1)-deltat;
    Tempi_occupatiB(i,2) = eventiB(i,1)+deltat;
end


intervalli_realiB = [Tempi_occupatiB(1,1),Tempi_occupatiB(1,2)];
intervallone_indexB = 1;

for i = 2:neventiB
    if Tempi_occupatiB(i,1) < Tempi_occupatiB(i-1,2) %se l'inizio della seconda finestra è prima della fine della prima...
        intervalli_realiB(intervallone_indexB,2) = Tempi_occupatiB(i,2); %la nuova fine dell'intervallone è...
    else %si apre un nuovo intervallone
        intervalli_realiB = [intervalli_realiB; Tempi_occupatiB(i,:)];
        intervallone_indexB = intervallone_indexB + 1;
    end
end

%cut the edges in order to avoid t < 0 or t > T
if intervalli_realiB(1,1) < 0
    intervalli_realiB(1,1) = 0;
end
if intervalli_realiB(end,2) > time_serieB(end,1)
    intervalli_realiB(end,2) = time_serieB(end,1);
end

%compute T_B
T_B = sum(intervalli_realiB(:,2)-intervalli_realiB(:,1),"all")/(time_serieB(end,1)-time_serieB(1,1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% eventi B che ricadono negli intervalli A %%%%%%%%%%%%%%%%
hitBoverA = 0;

for i = 1:neventiB
    for j = 1:intervallone_indexA
        if eventiB(i,1) > intervalli_realiA(j,1) && eventiB(i,1) < intervalli_realiA(j,2)
            hitBoverA = hitBoverA + 1;
        end
    end
end

P_B = hitBoverA/neventiB;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% eventi A che ricadono negli intervalli B %%%%%%%%%%%%%%%%
hitAoverB = 0;

for i = 1:neventiA
    for j = 1:intervallone_indexB
        if eventiA(i,1) > intervalli_realiB(j,1) && eventiA(i,1) < intervalli_realiB(j,2)
            hitAoverB = hitAoverB + 1;
        end
    end
end

P_A = hitAoverB/neventiA;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% compute STTC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ci = 0.5*((P_A-T_B)/(1-P_A*T_B)+(P_B-T_A)/(1-P_B*T_A));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end