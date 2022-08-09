function KbEyeCal(grey)
%---------------------------------------------------------------
%KbEyeCal - eye calibration using keyboard input
%---------------------------------------------------------------
% 19/05/2009 - Sam Schwarzkopf
%
% If this script is called with any input arguments,
% it will display the grid on a grey background.
% Otherwise it will be white on black.
%
% First the grid appears as it was. Press Enter to continue.
% An instruction to fixate the highlighted number appears.
% Again, press Enter to continue.
%
% The grid will then appear again with the 1 highlighted.
% Use the arrow keys to move the highlight to other numbers.
% When you are done, quit the program by pressing Esc.
%---------------------------------------------------------------
% Please contact Sam (s.schwarzkopf@fil.ion.ucl.ac.uk) if you 
% have any questions or suggestions about this script.
%---------------------------------------------------------------

% Load images
load('KbEyeCal');

if nargin > 0
    % Grey background
    bgd = [.5 .5 .5];
    fgd = [0 0 0];
    col = 'BLACK';
    img = Grey_grid;
else
    % Black & white
    bgd = [0 0 0];
    fgd = [1 1 1];
    col = 'WHITE';
    img = Black_White_grid;
end

% Initialize Cogent
config_display(1, 3, bgd, fgd, 'Arial', 25, 1)
config_keyboard
start_cogent
kmap = getkeymap;

% Grid with numbers
clearpict(1)
preparepict(img(:,:,10), 1);
drawpict(1);
waitkeydown(Inf);

% Instruction
clearpict(1)
preparestring(['Now please fixate on whichever number is ' col], 1);
drawpict(1);
waitkeydown(Inf);

% Loop through numbers
N = 1;
nn = 1;
K = 0;
while K(end) ~= kmap.Escape
    if nn <= 9 && nn >= 1 
        N = nn;
        preparepict(img(:,:,N), 1);
        drawpict(1);
    end

    K = waitkeydown(Inf);
    switch K(end)
        case kmap.Left
            nn = N-1;
        case kmap.Right
            nn = N+1;
        case kmap.Up
            nn = N-3;
        case kmap.Down
            nn = N+3;
    end
end

% Finish off
stop_cogent

