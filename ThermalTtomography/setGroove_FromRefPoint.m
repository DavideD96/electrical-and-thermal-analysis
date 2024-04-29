function coord = setGroove_FromRefPoint(reference_point,coord_from_point,groove_size)

%
% example:
% groove_size = [2,5]
% coord_from_point = [4,3]
% ref_point = [5,4]
%
% . . . . . . . . . .     |
% . o o . . . . . . . 1   v y
% . o o . . . . . . . 2 
% . o o . # . . . . . 3
% . o o . . . . . . .
% . o o . . . . . . .
% . . . . . . . . . .
% . . . . . . . . . .
%   1 2   
%
% --> x  
% 
% result = [2,2; 3,2; 2,7] ([top left; top right; bottom right])
%

% area_size = [5,7]
% coord_from_point = [3,2]
% reference_point = [8,9]

topLeft = [reference_point(1)-coord_from_point(1)+1,reference_point(2)-coord_from_point(2)+1];
topRight = [topLeft(1)+groove_size(1)-1,topLeft(2)];
bottomRight = [topRight(1),topRight(2)+groove_size(2)-1];

coord = [topLeft;topRight;bottomRight];

end