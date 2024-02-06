function [eventi_pos_noTypes, eventi_neg_noTypes, eventiRS] = cerca_evento_termo_005_noTypes(matriceEventi,switch_resistenza, delta_t)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-12-06 Last modification: 2024-01-10
%Authors: Cristina Zuccali
%cerca_evento_termo_005_noTypes(rappr_max, rappr_min,switch_resistenza, delta_t)
%differenza con la versione 004: non fa il controllo del tipo di evento
%   'matrice eventi' has [time, state(1/0), delta_T principale]
%   'switch_resistenza' = matrix of switch events
%   'delta_t' = time tollerance for resistive switching and thermal
%                   measures
%
%   'eventi_pos' = [delta_Res, delta_T, gruppo_termo] (delta_Temp > 0)
%   'eventi_neg' = [delta_Res, delta_T, gruppo_termo] (delta_Temp < 0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    eventiRS = zeros(0,2); %R, delta_T
    n_delta_frame = ceil(2*delta_t*30);
    n_switch = 1;

    %momentaea per confornto
    eventi_pos_noTypes = zeros(0,3); %R, delta_T
    eventi_neg_noTypes = zeros(0,3);

    for i = 1 : length(switch_resistenza(:,1))

        %cerca eventi delta_T positivi
        if switch_resistenza(i,2) == n_switch
            
            for j = 0 : n_delta_frame
                n_frame_post = i + j;
                n_frame_ante = i - j;

                %ricerca tra i massimi
                if n_frame_post < length(matriceEventi(:,1)) & matriceEventi(n_frame_post, 2) == 1  
                    eventiRS(end+1, 1) = switch_resistenza(i,1);
                    eventiRS(end, 2) = matriceEventi(n_frame_post, 3);
                    eventiRS(end, 3) = matriceEventi(n_frame_post, 4);
                    
                    if switch_resistenza(i, 1) < 0
                        eventi_pos_noTypes(end+1, 1) = switch_resistenza(i,1);
                        eventi_pos_noTypes(end, 2) =  eventiRS(end, 2);
                        eventi_pos_noTypes(end, 3) = eventiRS(end, 3);
    
                    elseif switch_resistenza(i, 1) > 0
                        eventi_neg_noTypes(end+1, 1) = switch_resistenza(i,1);
                        eventi_neg_noTypes(end, 2) = eventiRS(end, 2);
                        eventi_neg_noTypes(end, 3) = eventiRS(end, 3);
                    end

                    matriceEventi(n_frame_post, :) = 0;
                    break

                elseif n_frame_ante > 0 & matriceEventi(n_frame_ante, 2) == 1
                    eventiRS(end+1, 1) = switch_resistenza(i,1);
                    eventiRS(end, 2) = matriceEventi(n_frame_ante, 3);
                    eventiRS(end, 3) = matriceEventi(n_frame_ante, 4);
                    
                    if switch_resistenza(i, 1) < 0
                        eventi_pos_noTypes(end+1, 1) = switch_resistenza(i,1);
                        eventi_pos_noTypes(end, 2) = eventiRS(end, 2);
                        eventi_pos_noTypes(end, 3) = eventiRS(end, 3);
        
                    elseif switch_resistenza(i, 1) > 0
                        eventi_neg_noTypes(end+1, 1) = switch_resistenza(i,1);
                        eventi_neg_noTypes(end, 2) = eventiRS(end, 2);
                        eventi_neg_noTypes(end, 3) = eventiRS(end, 3);
                    end
                    
                    matriceEventi(n_frame_ante, :) = 0;
                    break
                end
            end

            n_switch = n_switch + 1;
        end  
    end

    save("Eventi_res_termo.mat", "eventiRS")
    save("Eventi_res_termo_pos_noTypes.mat", "eventi_pos_noTypes")
    save("Eventi_res_termo_neg_noTypes.mat", "eventi_neg_noTypes")
end

