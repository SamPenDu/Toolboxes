function widerthantall(h,w)

% Resize the window to be twice as wide as tall.
%
% widerthantall(h,w)
%
%   h is the figure handle
%   w=1-3 sets different aspect ratios

if nargin == 0
    h = gcf;
    w = false;
elseif nargin == 1
    w = false;
end

pos = get(h, 'Position');
if w
    if w==1
        set(h, 'Position', [pos(1)-pos(3) pos(2) pos(3)*3 pos(4)*1.06]-100);
    elseif w==2
        %as 1 but not as tall
        set(h, 'Position', [pos(1)-pos(3) pos(2) pos(3)*3.5 pos(4)*.7]-100);
    elseif w==3
        %as wide as the screen & half as high
        set(h, 'Units', 'normalized', 'Position', [0 .5 1 .45]);
    end
else
    set(h, 'Position', [pos(1)-pos(3)*0.4 pos(2) pos(3)*1.6 pos(4)]);
end


