% thermal tomography instructions
%
% %%%%%%%%%%%%%%%%% locate CAF and grooves %%%%%%%%%%%%%%%%%%
% 0) Data.mat containing electric data must be in each folder.
%
% 1) setInitialRefPoint in reference folder.
%
% 2) setAndCheck_refPoint in every folder.
%    store_mtotalT in every folder.
%    findRiseFall in every folder.
%       (it runs also mean_ColdAndHot automatically)
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now you have all the information to perform tomography.
%
% 3) thermalTomography



% engram instructions
%
% %%%%%%%%%%%%%%%%% locate CAF and grooves %%%%%%%%%%%%%%%%%%
%
% 1) setInitialRefPoint in reference folder.
% 2) init_folders(filename)
% 3) engram(filiename,'startfold','endfold')