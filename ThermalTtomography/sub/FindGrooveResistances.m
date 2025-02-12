function [R1,R2,R3] = FindGrooveResistances(Rab,Rbc,Rca)

% author: Davide Decastri
%
% topology:
%
%  ° electrodes
%  / grooves
%
%             c
%     Rca --> ° <-- Rbc
%     |    \     /   |
%     |  R3 \   / R2 |
%     |      \ /     |
%     v       |      v
%   a °       |R1    ° b
%             |
%            Rab
%
% finds grooves resistances, knowing resistances between all the electrodes
% couples.

numerator = Rab^2+Rbc^2+Rca^2-2*Rbc*Rca-2*Rca*Rab-2*Rbc*Rab;
% denominator = (Rab*(Rbc-Rca))^2-2*Rab*Rbc*Rca*(Rbc+Rca)+(Rbc*Rca)^2;
% R1 = -(2*Rab*Rbc*Rca*(Rab*(Rbc+Rca))-Rbc*Rca)/denominator
% R2 = -(2*Rab*Rbc*Rca*(Rab*(Rbc-Rca))+Rbc*Rca)/denominator
% R3 = -(2*Rab*Rbc*Rca*(Rab*(Rca-Rbc))-Rbc*Rca)/denominator

R1 = 0.5*numerator/(Rab-Rbc-Rca);
R2 = 0.5*numerator/(Rbc-Rca-Rab);
R3 = 0.5*numerator/(Rca-Rab-Rbc);

% check
% Rab = R1*(R2+R3)/(R1+R2+R3)
% Rbc = R2*(R1+R3)/(R1+R2+R3)
% Rac = R3*(R2+R1)/(R1+R2+R3)

Rab = 1/(1/R1+1/(R2+R3));
Rbc = 1/(1/R2+1/(R1+R3));
Rac = 1/(1/R3+1/(R2+R1));

end