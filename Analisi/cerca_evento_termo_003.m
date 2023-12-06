function [eventi_pos, eventi_neg] = cerca_evento_termo_003(rappr_max, rappr_min,switch_resistenza, delta_t, times)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: 2023-12-6 Last modification: 2023-12-6
%Authors: Cristina Zuccali
%cerca_evento_termo_003(rappr_max, rappr_min,switch_resistenza, delta_t, times)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    eventi_pos = zeros(0,2); %R, delta_T
    eventi_neg = zeros(0,2);

    for i = 1: length(switch_resistenza(:,1))
        
        %cerca eventi delta_T positivi
        if switch_resistenza(i, 1) < 0
            tempo_evento = times(i,1);
            j = 0;
            stato = 0;
            %cerco evento delta_T nell'intervallo
            for k = 1 : length(rappr_max(:,1))
                while times(i+j, 1) <= tempo_evento+delta_t
                    if times(i+j, 1) < times(end, 1) & rappr_max(k,4) == i+j % controllo
                        if rappr_max(k, 2) * switch_resistenza(i,1) < 0
                            eventi_pos(end+1, 1) = switch_resistenza(i,1);
                            eventi_pos(end, 2) = rappr_max(k, 2);
                            rappr_max(k, :) = 0; 
                            stato = 1;
                            break
                        end
                    end
                    
                    if times(i-j, 1) > 0 & rappr_max(k,4) == i-j %controllo
                        if rappr_max(k, 2) * switch_resistenza(i,1) < 0
                            eventi_pos(end+1, 1) = switch_resistenza(i,1);
                            eventi_pos(end, 2) = rappr_max(k, 2);
                            rappr_max(k, :) = 0; 
                            stato = 1;
                            break
                        end
                    end

                    j = j+1;
                end

                if stato == 1
                    break
                end
            end


        %cerca eventi delta_T negativi
        elseif switch_resistenza(i,1) > 0
            tempo_evento = times(i,1);
            tempo = tempo_evento;
            j = 0;
            stato = 0;
            %cerco evento delta_T nell'intervallo
            for k = 1 : length(rappr_min(:,1))
                while times(i+j, 1) <= tempo_evento+delta_t
                    if times(i+j, 1) < times(end, 1) & rappr_min(k,4) == i+j % controllo
                        if rappr_min(k, 2) * switch_resistenza(i,1) < 0
                            eventi_neg(end+1, 1) = switch_resistenza(i,1);
                            eventi_neg(end, 2) = rappr_min(k, 2);
                            rappr_min(k, :) = 0; 
                            stato = 1;
                            break
                        end
                    end
                    
                    if times(i-j, 1)  > 0 & rappr_min(k,2) == i-j %controllo
                        if rappr_min(k, 2) * switch_resistenza(i,1) < 0
                            eventi_neg(end+1, 1) = switch_resistenza(i,1);
                            eventi_neg(end, 2) = rappr_min(k, 2);
                            rappr_min(k, :) = 0;
                            stato = 1;
                            break
                        end
                    end
                    j = j+1;
                end

                if stato == 1
                    break
                end
            end
        end
    end
end

