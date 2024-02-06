function [eventi_pos_noTypes, eventi_neg_noTypes, eventiRS] = cerca_evento_termo_005_noTypes_daTermo(matriceEventi,switch_resistenza, delta_t)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-12-06 Last modification: 2024-01-10
%Authors: Cristina Zuccali
%cerca_evento_termo_005_noTypes(rappr_max, rappr_min,switch_resistenza, delta_t)
%differenza con la versione 004: non fa il controllo del tipo di evento
%   'matrice eventi' has [time, state(1/0), delta_T_principale]
%   'switch_resistenza' = matrix of switch events
%   'delta_t' = time tollerance for resistive switching and thermal
%                   measures
%
%   'eventi_pos' = [delta_Res, delta_T, gruppo_termo] (delta_Temp > 0)
%   'eventi_neg' = [delta_Res, delta_T, gruppo_termo] (delta_Temp < 0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    eventiRS = zeros(0,2); %R, delta_T
    n_delta_frame = ceil(3*delta_t*20);

    %momentaea per confornto
    eventi_pos_noTypes = zeros(0,3); %R, delta_T
    eventi_neg_noTypes = zeros(0,3);

for i = 1 : length(matriceEventi(:,2))

        %cerca eventi delta_T positivi
        if matriceEventi(i,2) == 1
            
            for j = 0 : n_delta_frame
                n_frame_post = i + j;
                n_frame_ante = i - j;

                %ricerca tra i massimi
                if n_frame_post < length(switch_resistenza(:,1)) & switch_resistenza(n_frame_post, 2) ~= 0 
                    eventiRS(end+1, 1) = switch_resistenza(n_frame_post,1);
                    eventiRS(end, 2) = matriceEventi(i, 3);
                    eventiRS(end, 3) = matriceEventi(i, 4);
                    
                    if switch_resistenza(n_frame_post, 1) < 0
                        eventi_pos_noTypes(end+1, 1) = switch_resistenza(n_frame_post,1);
                        eventi_pos_noTypes(end, 2) =  eventiRS(end, 2);
                        eventi_pos_noTypes(end, 3) = eventiRS(end, 3);
    
                    elseif switch_resistenza(n_frame_post, 1) > 0
                        eventi_neg_noTypes(end+1, 1) = switch_resistenza(n_frame_post,1);
                        eventi_neg_noTypes(end, 2) = eventiRS(end, 2);
                        eventi_neg_noTypes(end, 3) = eventiRS(end, 3);
                    end

                    switch_resistenza(n_frame_post, :) = 0;
                    break

                elseif n_frame_ante > 0 & switch_resistenza(n_frame_ante, 2) ~= 0
                    eventiRS(end+1, 1) = switch_resistenza(n_frame_ante,1);
                    eventiRS(end, 2) = matriceEventi(i, 3);
                    eventiRS(end, 3) = matriceEventi(i, 4);
                    
                    if switch_resistenza(n_frame_ante, 1) < 0
                        eventi_pos_noTypes(end+1, 1) = switch_resistenza(n_frame_ante,1);
                        eventi_pos_noTypes(end, 2) = eventiRS(end, 2);
                        eventi_pos_noTypes(end, 3) = eventiRS(end, 3);
        
                    elseif switch_resistenza(n_frame_ante, 1) > 0
                        eventi_neg_noTypes(end+1, 1) = switch_resistenza(n_frame_ante,1);
                        eventi_neg_noTypes(end, 2) = eventiRS(end, 2);
                        eventi_neg_noTypes(end, 3) = eventiRS(end, 3);
                    end
                    
                    switch_resistenza(n_frame_ante, :) = 0;
                    break
                end
            end
        end  
end

    save("Eventi_res_termo.mat", "eventiRS")
    save("Eventi_res_termo_pos_noTypes.mat", "eventi_pos_noTypes")
    save("Eventi_res_termo_neg_noTypes.mat", "eventi_neg_noTypes")
end

