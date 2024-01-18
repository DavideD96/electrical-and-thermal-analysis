function rename(in)

%rename CSV files!
%example:
% ciao_12.CSV                 ciao_14.CSV
% ciao_13.CSV   -rename(3)->  ciao_15.CSV
% ciao_14.CSV                 ciao_16.CSV


% Get all PDF files in the current folder
files = dir('*.CSV');

% Loop through each

for id = 1:length(files)

    % Get the file name (minus the extension)
    [~, f] = fileparts(files(id).name);

    check = f(end);
    number = f(end);

    while check ~= '_'
        f = f(1:end-1);
        check = f(end);
        number = append(f(end),number); 
    end

    number = number(2:end);
    number = str2num(number);
    decimal = floor(log10(number))+1;
    format = append('%',num2str(decimal),'d.CSV');
    new_number = in+number-1;

    movefile(files(id).name, append('_',f,sprintf(format, new_number)));
end

files = dir('*.CSV');

for id = 1:length(files)
    movefile(files(id).name, files(id).name(2:end));
end

end