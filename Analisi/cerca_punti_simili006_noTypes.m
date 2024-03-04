function [simili] = cerca_punti_simili006_noTypes(Eventi, righe, colonne, frame_start, fr_diff, Eventi_RS_pos, Eventi_RS_neg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%cerca_punti_simili001(massimi, minimi) e associa evento resistivo
%
% raggruppa gli eventi che avvengono nello stesso punto (primi vicini)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%prendo solo i rappresentanti
%parto dai massimi e poi faccio i minimi che restano
Eventi_supp = Eventi;
gruppo = 1;
for i = 1 : length(fieldnames(Eventi_supp))   
    fname = append("frame", num2str(frame_start + i + fr_diff - 1));
    eventi_tutti = 0;
    if Eventi_supp.(fname).num_evento ~= 0
        if Eventi_supp.(fname).massimi(1,1) ~= 0 & Eventi_supp.(fname).minimi(1,1) ~= 0
            eventi_tutti = [Eventi_supp.(fname).massimi; Eventi_supp.(fname).minimi];
        elseif Eventi_supp.(fname).massimi(1,1) ~= 0
            eventi_tutti = Eventi_supp.(fname).massimi;
        elseif Eventi_supp.(fname).minimi(1,1) ~= 0
            eventi_tutti = Eventi_supp.(fname).minimi;
        else
            eventi_tutti = [];
        end

        evento = 1;

        for j = i : length(fieldnames(Eventi_supp))
            fname_succ = append("frame", num2str(frame_start+ j + fr_diff - 1));
                
             if Eventi_supp.(fname_succ).num_evento ~= 0
                eventi_tutti_succ = 0;
                if Eventi_supp.(fname_succ).massimi(1,1) ~= 0 & Eventi_supp.(fname_succ).minimi(1,1) ~= 0
                    eventi_tutti_succ = [Eventi_supp.(fname_succ).massimi; Eventi_supp.(fname_succ).minimi];
                elseif Eventi_supp.(fname_succ).massimi(1,1) ~= 0
                    eventi_tutti_succ = Eventi_supp.(fname_succ).massimi;
                elseif Eventi_supp.(fname_succ).minimi(1,1) ~= 0
                    eventi_tutti_succ = Eventi_supp.(fname_succ).minimi;
                else
                    eventi_tutti_succ = [];
                end

                stato = raggruppo_2eventi_diversi_005(eventi_tutti, eventi_tutti_succ, righe, colonne);
    
                if stato == 1
                    name_gruppo = append("gruppo", num2str(gruppo));
                    name_evento = append("evento", num2str(evento));
    
                    simili.(name_gruppo).(name_evento) = Eventi_supp.(fname_succ);
                    simili.(name_gruppo).(name_evento).n_punti = length(eventi_tutti_succ(:,1));

                    %controlla resistenza
                    stato_res = 0;
                    
                    % for k = 1 : length(Eventi_RS_pos(:,1))
                    %     if Eventi_RS_pos(k,3) == Eventi_supp.(fname_succ).num_evento
                    %         stato_res = Eventi_RS_pos(k,1);
                    %         break
                    %     end
                    % end
                    % 
                    % 
                    % for k = 1 : length(Eventi_RS_neg(:,1))
                    %     if Eventi_RS_neg(k,3) == Eventi_supp.(fname_succ).num_evento
                    %         stato_res = Eventi_RS_neg(k,1);
                    %         break
                    %     end
                    % end

                    
                    simili.(name_gruppo).(name_evento).RS = stato_res;                  
                                      
                    Eventi_supp.(fname_succ).massimi  = 0;
                    Eventi_supp.(fname_succ).minimi  = 0;
                    Eventi_supp.(fname_succ).num_evento  = 0;
                    Eventi_supp.(fname_succ).area_max  = 0;
                    Eventi_supp.(fname_succ).area_min  = 0;
                    evento = evento + 1;
                end
    
            end  
        end
        gruppo = gruppo + 1;
    end

end

save("Simili.mat", "simili")
end

