function init_folders(filename, start,stop)

    ref_name = '001_';

    for ii = start:stop

        zer = '';
        for kk = 1:3-numel(num2str(ii))
            zer = [zer,'0'];
        end

        filename_now = [filename,zer,num2str(ii),'_']; 
        setAndCheck_refPoint_folder(num2str(ii),filename_now,10,'1',[filename,ref_name])
        close all
    end
    
end