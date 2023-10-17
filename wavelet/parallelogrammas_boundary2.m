function boundary = parallelogrammas_boundary2(dimy, varargin)

num = length(varargin);

% set coordinates
t = [0,0];     %                     *  Top           Left  * * * * Top
b = [0,0];     %                  *   *                     *     *
l = [0,0];     %         Left  *       *                    *     *
r = [0,0];     %                *       *  Right    Bottom  * * * * Right
               %                 *   *
               %          Bottom  *

for k = 1:2:num
    if varargin{k}=='t'
        top = varargin{k+1};
    elseif varargin{k}=='b'
        bottom = varargin{k+1};
    elseif varargin{k}=='l'
        left = varargin{k+1};
    elseif varargin{k}=='r'
        right = varargin{k+1};
    end
end

%{
x_top_left=round(1);        
y_top_left=round(3);        
                                
x_top_right=round(10);       
y_top_right=round(1);       

x_bottom_right=round(12);
y_bottom_right=round(8);

x_bottom_left=round(3);
y_bottom_left=round(10);

%}                             
x_top=round(top(1));        
y_top=round(top(2));        
                                
x_right=round(right(1));       
y_right=round(right(2));      

x_left=round(left(1));
y_left=round(left(2));

x_bottom=round(bottom(1));
y_bottom=round(bottom(2));

delta_x_top_right = x_right - x_top;
delta_y_top_right = y_right - y_top;

delta_x_top_left = x_top - x_left;
delta_y_top_left = y_top - y_left;

%inclinazione_top_left = delta_x_top_left/delta_y_top_left; %floor((abs(delta_x_top)+1)/(abs(delta_y_top)+1))+1
%inclinazione_top_right = delta_x_top_right/delta_y_top_right; %floor((abs(delta_y_right)+1)/(abs(delta_x_right)+1))+1
if abs(delta_y_top_left) < abs(delta_x_top_left)
    inclinazione_top_left = sign(delta_x_top_left*delta_y_top_left)*floor((abs(delta_x_top_left)+1)/(abs(delta_y_top_left)+1));
else
    inclinazione_top_left = sign(delta_x_top_left*delta_y_top_left)/floor((abs(delta_y_top_left)+1)/(abs(delta_x_top_left)+1));
end

if abs(delta_y_top_right) < abs(delta_x_top_right)
    inclinazione_top_right = sign(delta_x_top_right*delta_y_top_right)*floor((abs(delta_x_top_right)+1)/(abs(delta_y_top_right)+1)); %inclinazione_top_right = sign(delta_x_top_right*delta_y_top_right)*floor(abs(delta_x_top_right/delta_y_top_right));
else
    inclinazione_top_right = sign(delta_x_top_right*delta_y_top_right)/floor((abs(delta_y_top_right)+1)/(abs(delta_x_top_right)+1));
end

remainder_top_left = sign(inclinazione_top_left)*floor(rem(abs(delta_x_top_left)+1,abs(inclinazione_top_left))); %rem(delta_x_top_left,inclinazione_top_left); %delta_y_top);
remainder_top_right = sign(inclinazione_top_right)*floor(rem(abs(delta_x_top_right)+1,abs(inclinazione_top_right)));


fin = y_bottom - y_top + 1;

if y_left == y_top

    lato = zeros(fin,1);
    for i=1:fin
        lato(i,1) = x_left + floor((i-1)*inclinazione_top_right);
    end

    left_boundary = lato;
    right_boundary = lato + (x_top - x_left);
else

    lato_top_sx = zeros(fin,1);    %  /\
    lato_top_dx = zeros(fin,1);    % /  \
    lato_bottom_sx = zeros(fin,1); % \  /
    lato_bottom_dx = zeros(fin,1); %  \/

    right_boundary = zeros(fin,1);
    left_boundary = zeros(fin,1);

    for i=1:fin

        lato_top_sx(i,1) = x_top + floor(i*inclinazione_top_left); 

        lato_top_dx(i,1) = x_top + floor((i-1)*inclinazione_top_right);

        lato_bottom_sx(fin-i+1) = x_bottom - floor((i-1)*inclinazione_top_right);
        lato_bottom_dx(fin-i+1) = x_bottom - floor(i*inclinazione_top_left); 

    %{
    if remainder_top == 0
        lato_top_sx(i,1) = x_top_right - floor((i+1)*floor(inclinazione_top)); %ok
    else
        lato_top_sx(i,1) = x_top_right - floor((i-1)*floor(inclinazione_top)) - remainder_top;
    end

    lato_top_dx(i,1) = x_top_right + floor((i-1)*1/inclinazione_right);      %ok

    lato_bottom_sx(fin+1-i) = x_bottom_left - floor((i-1)*1/inclinazione_right);
    lato_bottom_dx(fin+1-i) = x_bottom_left + floor((i-1)*inclinazione_top) + remainder_top; %ok
    %}
    end

    for i=1:fin
        if lato_top_sx(i) < lato_bottom_sx(i)
            left_boundary(i) = lato_bottom_sx(i);
        else
            left_boundary(i) = lato_top_sx(i);
        end

        if lato_top_dx(i) < lato_bottom_dx(i)
            right_boundary(i) = lato_top_dx(i);
        else
            right_boundary(i) = lato_bottom_dx(i);
        end
    end
end

%lato_top_sx
%lato_top_dx
%lato_bottom_dx
%lato_bottom_sx


top_empty = ones(y_top-1,1);
bottom_empty = ones(dimy-y_bottom,1);

top_empty = [top_empty, -top_empty];
bottom_empty = [bottom_empty, -bottom_empty];

boundary = [top_empty; [left_boundary,right_boundary]; bottom_empty];

end