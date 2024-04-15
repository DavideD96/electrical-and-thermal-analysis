function boundary = rectangle_boundary(dimy, varargin)

num = length(varargin);            

for k = 1:2:num
    if prod(varargin{k}=='tl') %top left
        topleft = varargin{k+1};
    elseif prod(varargin{k}=='br') %bottom right
        bottomright = varargin{k+1};
    end
end

topleft = round(topleft);
bottomright = round(bottomright);

y_top = topleft(1);
y_bottom = bottomright(1);

top_empty = ones(y_top-1,1);
bottom_empty = ones(dimy-y_bottom,1);

top_empty = [top_empty, -top_empty];
bottom_empty = [bottom_empty, -bottom_empty];

leftboundary = topleft(2)*ones(bottomright(1)-topleft(1)+1,1);
rightboudary = bottomright(2)*ones(bottomright(1)-topleft(1)+1,1);

boundary = [top_empty; [leftboundary,rightboudary]; bottom_empty];

end