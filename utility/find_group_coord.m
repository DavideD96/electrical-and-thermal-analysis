function [x,y] = find_group_coord(name)

pat = digitsPattern;
dig = extract(name,pat);

x = str2num(dig{1});
y = str2num(dig{2});
end