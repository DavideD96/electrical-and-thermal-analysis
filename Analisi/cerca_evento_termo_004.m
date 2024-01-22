function [eventi_pos, eventi_neg] = cerca_evento_termo_004(rappr_max, rappr_min,switch_resistenza, delta_t)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-12-06 Last modification: 2024-01-10
%Authors: Cristina Zuccali
%cerca_evento_termo_004(rappr_max, rappr_min,switch_resistenza, delta_t, times)
%   'rappr_max' = matrice con un rappresentante per evento (eventi con
%                   delta_Temp positiva) (position, value, # associated event group, i)
%   'rappr_min' = matrice con un rappresentante per evento (eventi con
%                   delta_Temp negativa) (position, value, # associated event group, i)
%   'switch_resistenza' = matrix of switch events
%   'delta_t' = time tollerance for resistive switching and thermal
%                   measures
%
%   'eventi_pos' = [delta_Res, delta_T, gruppo_termo] (delta_Temp > 0)
%   'eventi_neg' = [delta_Res, delta_T, gruppo_termo] (delta_Temp < 0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    eventi_pos = zeros(0,2); %R, delta_T
    eventi_neg = zeros(0,2);
    n_delta_frame = ceil(2*delta_t*30);
    n_switch = 1;

    for i = 1 : length(switch_resistenza(:,1))

        %cerca eventi delta_T positivi
        if switch_resistenza(i, 1) < 0 & switch_resistenza(i,2) == n_switch
            
            for j = 0 : n_delta_frame
                n_frame_post = i + j;
                n_frame_ante = i - j;

                if n_frame_post < length(rappr_max(:,1)) & rappr_max(n_frame_post, 2) ~= 0  
                    eventi_pos(end+1, 1) = switch_resistenza(i,1);
                    eventi_pos(end, 2) = rappr_max(n_frame_post, 2);
                    eventi_pos(end, 3) = rappr_max(n_frame_post, 3);
                    rappr_max(n_frame_post, :) = 0;
                    break

                elseif n_frame_ante > 0 & rappr_max(n_frame_ante, 2) ~= 0
                    eventi_pos(end+1, 1) = switch_resistenza(i,1);
                    eventi_pos(end, 2) = rappr_max(n_frame_ante, 2);
                    eventi_pos(end, 3) = rappr_max(n_frame_ante, 3);
                    rappr_max(n_frame_ante, :) = 0;
                    break
                end
            end

            n_switch = n_switch + 1;


        %cerca eventi delta_T negativi
        elseif switch_resistenza(i,1) > 0 & switch_resistenza(i,2) == n_switch
            for j = 0 : n_delta_frame
                n_frame_post = i + j;
                n_frame_ante = i - j;

                if n_frame_post < length(rappr_min(:,1)) & rappr_min(n_frame_post, 2) ~= 0 
                    eventi_neg(end+1, 1) = switch_resistenza(i,1);
                    eventi_neg(end, 2) = rappr_min(n_frame_post, 2);
                    eventi_neg(end, 3) = rappr_min(n_frame_post, 3);
                    rappr_min(n_frame_post, :) = 0;
                    break

                elseif n_frame_ante > 0 & rappr_min(n_frame_ante, 2) ~= 0 
                    eventi_neg(end+1, 1) = switch_resistenza(i,1);
                    eventi_neg(end, 2) = rappr_min(n_frame_ante, 2);
                    eventi_neg(end, 3) = rappr_min(n_frame_ante, 3);
                    rappr_min(n_frame_ante, :) = 0;
                    break
                end
            end

            n_switch = n_switch + 1;
        end
    end

    save("Eventi_res_termo_pos.mat", "eventi_pos")
    save("Eventi_res_termo_neg.mat", "eventi_neg")
end

