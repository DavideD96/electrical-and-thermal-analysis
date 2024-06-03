% given mtotalT:
%
% 1) run store_mtotalDT(frdiff, mtotalT) (usually frdiff = 3)
% 2) run analisi_Nframes011_multiEvento_007_NOpV(fr_start) 
%    this function returns a structure "Eventi_Termo", and a matrix
%    "framestates" (both with the same information), frame_start will not
%    be used anymore in the following steps.
% 3) run evento_max_temp_009_matriceEventi(0) (0 = use first detection
%    frame, 1 = use highest DeltaT) and obtain matriceEventi
% 4) run 
%    cerca_punti_simili2centresByUsr002(matriceEventi,[x,y]) x = col, y = row.
%
% stat analysis:
% 5a) run SSTCmultiple_windows
% 5b) run ISIpuntiSimili