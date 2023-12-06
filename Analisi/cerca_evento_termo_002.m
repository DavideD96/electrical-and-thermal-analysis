function [eventi_pos, eventi_neg] = cerca_evento_termo_002(frame_states,switch_resistenza, delta_t, times)
    n_delta_frame = ceil(2*delta_t*30);
    
    eventi_pos = zeros(0,2); %R, delta_T
    eventi_neg = zeros(0,2);

    for i = 1: length(switch_resistenza(:,1))
        
        %cerca eventi delta_T positivi
        if switch_resistenza(i, 1) < 0
            tempo_evento = ceil(times(i,1));
            frame_evento = 2*tempo_evento*30;
            
            %cerco evento delta_T nell'intervallo
            for j = 0 : n_delta_frame
                if (frame_evento + j) < length(frame_states(:, 1)) % controllo
                    if frame_states(frame_evento + j, 4) * switch_resistenza(i,1) < 0
                        eventi_pos(end+1, 1) = switch_resistenza(i,1);
                        eventi_pos(end, 2) = frame_states(frame_evento+j, 4);
                        frame_states(frame_evento + j, :) = 0; 
                    end
                end
                
                if (frame_evento - j) > 0 %controllo
                    if frame_states(frame_evento - j, 4) * switch_resistenza(i,1) < 0
                        eventi_pos(end+1, 1) = switch_resistenza(i,1);
                        eventi_pos(end, 2) = frame_states(frame_evento-j, 4);
                        frame_states(frame_evento - j, :) = 0; 
                    end
                end
            end


        %cerca eventi delta_T negativi
        elseif switch_resistenza(i,1) > 0
            tempo_evento = ceil(times(i,1));
            frame_evento = 2*tempo_evento*30;
            
            %cerco evento delta_T nell'intervallo
            for j = 0 : n_delta_frame
                if (frame_evento + j) < length(frame_states(:, 1)) % controllo
                    if frame_states(frame_evento + j, 5) * switch_resistenza(i,1) < 0
                        eventi_neg(end+1, 1) = switch_resistenza(i,1);
                        eventi_neg(end, 2) = frame_states(frame_evento+j, 5);
                        frame_states(frame_evento + j, :) = 0; 
                    end
                end
                
                if (frame_evento - j) > 0 %controllo
                    if frame_states(frame_evento - j, 5) * switch_resistenza(i,1) < 0
                        eventi_neg(end+1, 1) = switch_resistenza(i,1);
                        eventi_neg(end, 2) = frame_states(frame_evento-j, 5);
                        frame_states(frame_evento - j, :) = 0; 
                    end
                end
            end
        end
    end
end

