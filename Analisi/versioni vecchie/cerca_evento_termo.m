function evento = cerca_evento_termo(frame_states,tempo, delta_t, delta_R)
    n_frame_start = ceil(tempo*30);
    n_delta_frame = ceil(delta_t*30);
    
    evento = zeros(1,2);

    for i = 1 : n_delta_frame

        test = frame_states(n_frame_start+i, 3)*delta_R;
        
        if n_frame_start + i < length(frame_states(:,1))
            if frame_states(n_frame_start+i, 8) ~= 0 & test<0
                evento(1, 1) = delta_R;
    
                if delta_R < 0
                    evento(1,2) = frame_states(n_frame_start+i, 4);
                
                elseif delta_R > 0
                    evento(1,2) = frame_states(n_frame_start+i, 5);
                end
    
                break
            end
        end
            
        if n_frame_start-i > 0
            if frame_states(n_frame_start-i, 8) ~= 0 & test<0
                evento(1, 1) = delta_R;

                if delta_R < 0
                    evento(1,2) = frame_states(n_frame_start+i, 4);
                
                elseif delta_R > 0
                    evento(1,2) = frame_states(n_frame_start+i, 5);
                end
    
                break
            end
        end
    end
    
end

