function ordered = order_events(matEventi)

% matEventi is the result of evento_max_temp_010_matriceEventi

ordered = [];

for ii = 1:size(matEventi,1)
    for kk = 1:length(matEventi{ii,3})
        if matEventi{ii,3}(kk) ~= 0
            ordered = [ordered; matEventi{ii,2}(kk),matEventi{ii,3}(kk)];
        end
    end
end

end