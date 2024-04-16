function coord = setArea_FromRefPoint(reference_point,coord_from_point,area_size)

%
% example:
% area_size = [5,5]
% coord_from_point = [4,3]
% ref_point = [3,4]
%
% . . . . . . . . . .     |
% . o o o o o . . . . 1   v y
% . o o o o o . . . . 2 
% . o o o # o . . . . 3
% . o o o o o . . . .
% . o o o o o . . . .
% . . . . . . . . . .
% . . . . . . . . . .
%   1 2 3 4 
%
% --> x  
% 
% result = [2,2; 6,2; 6,7] ([top left, top right, bottom right])
%

topLeft = [reference_point(1)-area_size(1)+coord_from_point(1),reference_point(2)-area_size(2)+coord_from_point(2)];
topRight = [topLeft(1)+area_size(1)-1,topLeft(1)];
bottomRight = [topRight(1),topRight(2)+area_size(2)];

coord = [topLeft;topRight;bottomRight];

end