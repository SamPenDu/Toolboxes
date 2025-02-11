function Resp = Likert(Win, Prompt, Colour, NumOpts)
%
% Resp = Likert(Win, Prompt, Colour, [NumOpts=7])
%
% Presents a screen with a Likert scale with NumOpts options (default=7) using Psychtoolbox window Win.
% Colour defines the colour of the font & the slider. Background colour is defined by the window.
%
% Prompt is a string which can contain new line operators ('\n'). This is presented in the middle 
% of the screen using standard text formatting in your window.
%
% Move the slider with Left & Right arrow & confirm with Space.
%
% If NumOpts is 1, there is no slider & you can only move on with Space.
%
% Returns the response number in Resp.
%

if nargin < 4
    NumOpts = 7;
end
if NumOpts < 1
    error('NumOpts must be >= 1!');
end

% Likert locations
Rect = Screen('Rect', Win);
X1 = round(Rect(3)*.3); % Left side of line
X2 = round(Rect(3)*.7); % Right side of line
S = round((X2-X1)/(NumOpts-1)); % Step size

% Initialise response
Resp = 0;
Curr = round(NumOpts/2);

% Add instructions
if NumOpts > 1
    Prompt = [Prompt '\n\n\n(Left & Right to move & Space to confirm)'];
else
    Prompt = [Prompt '\n\n\n(Press Enter to continue)'];
end

% Wait until response
while Resp == 0
    % Write prompt
    [~,Y] = DrawFormattedText(Win, Prompt, 'center', Rect(4)*.2, Colour); 
    Y = Y + 100; % Position for slider

    % Draw slider
    if NumOpts > 1
        Screen('DrawLine', Win, Colour, X1, Y, X2, Y, 2);
        for s = 1:NumOpts
            X = X1 + (s-1)*S; % Position of tick
            Screen('DrawText', Win, num2str(s), X-10, Y-50, Colour);
            if s == Curr
                Screen('FillOval', Win, Colour, [X-10 Y-10 X+10 Y+10]); % Draw current selection
            else
                Screen('DrawLine', Win, Colour, X, Y-10, X, Y+10, 2); % Draw tick
            end
        end
    end

    % Show screen
    Screen('Flip', Win);

    % Keyboard response
    WaitSecs(.1);
    KbWait;
    [~,~,k] = KbCheck;
    if sum(ismember(find(k), KbName('leftarrow'))) 
        Curr = Curr - 1; % Move left
    elseif sum(ismember(find(k), KbName('rightarrow'))) 
        Curr = Curr + 1; % Move right
    elseif NumOpts > 1 && sum(ismember(find(k), KbName('space'))) 
        Resp = Curr; % Confirmed!
    elseif NumOpts == 1 && sum(ismember(find(k), KbName('return'))) 
        Resp = Inf; % Continuing...
    elseif sum(ismember(find(k), KbName('escape'))) 
        Resp = NaN;
        return
    end
    
    % Ensure bounds
    if Curr > NumOpts
        Curr = NumOpts;
    elseif Curr < 1
        Curr = 1;
    end
end