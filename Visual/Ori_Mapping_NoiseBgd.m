function Ori_Mapping(Parameters, Emulate)
%Ori_Mapping(Parameters, Emulate)
%
% Runs an experiment to map orientation tuning.
%

% Default is without scanner!
if nargin < 2
    Emulate = 1;
end

%% Set up design
Parameters.Conditions = [ones(1,Parameters.Cycles_per_Expmt) 0];  % Condition of each cycle
RotatAngle = 180 / Parameters.Volumes_per_Cycle;  % Angle step per volume in degrees
CurrOris = ceil(rand(1,4)*Parameters.Volumes_per_Cycle) * RotatAngle;  % Which orientation each quadrant starts on
RotatDirec = isodd(Parameters.Session)*2 - 1; % Direction of rotation
ApFrm = NaN(length(Parameters.Conditions),4); % Save here the orientation conditions

% Create the mandatory folders if not already present 
if ~exist([cd filesep 'Results'], 'dir')
    mkdir('Results');
end

% Check if eyetracker defined
if ~isfield(Parameters, 'Eye_tracker')
    Parameters.Eye_tracker = false;
end

disp(['Duration: ' n2s(length(Parameters.Conditions)*Parameters.Volumes_per_Cycle + Parameters.Dummies) ' volumes']);

%% Initialize randomness & keycodes
SetupRand;
SetupKeyCodes;

%% Configure scanner 
if Emulate 
    % Emulate scanner
    TrigStr = 'Press key to start...';    % Trigger string
else
    % Real scanner
    TrigStr = 'Stand by for scan...';    % Trigger string
end

%% Initialize PTB
[Win Rect] = Screen('OpenWindow', Parameters.Screen, Parameters.Background, Parameters.Resolution, 32); 
Screen('TextFont', Win, Parameters.FontName);
Screen('TextSize', Win, Parameters.FontSize);
Screen('BlendFunction', Win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
HideCursor;
RefreshDur = Screen('GetFlipInterval',Win);
Slack = RefreshDur / 2;

%% If desired, initialize eyetracker 
if Parameters.Eye_tracker
    if Eyelink('Initialize') ~= 0	
        error('Problem initialising the eyetracker!'); 
    end
    Eye_params = EyelinkInitDefaults(Win);
    Eyelink('Openfile', 'Test.edf');  % Open a file on the eyetracker
    Eyelink('StartRecording');  % Start recording to the file
    Eye_error = Eyelink('CheckRecording');
    if Eyelink('NewFloatSampleAvailable') > 0
        Eye_used = Eyelink('EyeAvailable'); % Get eye that's tracked
        if Eye_used == Eye_params.BINOCULAR; 
            % If both eyes are tracked use left
            Eye_used = Eye_params.LEFT_EYE;         
        end
    end
end

%% Various variables
Results = [];
Start_of_Expmt = NaN;

%% Spiderweb coordinates
[Ix Iy] = pol2cart([0:30:330]/180*pi, Parameters.Fixation_Width(1));
[Ox Oy] = pol2cart([0:30:330]/180*pi, Rect(3)/2);
Rc = Rect(3) - Parameters.Fixation_Width(2);
Sc = round(Rc / 10);
Wc = Parameters.Fixation_Width(2) : Sc : Rect(3);
Wa = round(Parameters.Spider_Web * 255);

%% Behavioural data
Behaviour = struct;
Behaviour.EventTime = [];
Behaviour.Response = [];
Behaviour.ResponseTime = [];

%% Event timings 
Events = [];
for e = Parameters.TR : Parameters.Event_Duration : (length(Parameters.Conditions) * Parameters.Volumes_per_Cycle * Parameters.TR)
    if rand < Parameters.Prob_of_Event
        Events = [Events; e];
    end
end
% Add a dummy event at the end of the Universe
Events = [Events; Inf];
Behaviour.EventTime = Events;

%% Configure events
if ~isfield(Parameters, 'Event_Colour')
    Parameters.Event_Colour = [127 0 255; 0 0 255];
end
if isfield(Parameters, 'Event_Chars')
    Parameters.Event_Chars = upper(Parameters.Event_Chars);
    Event_String = [];
    if Parameters.Event_Chars(1) == '?'
        % If the event string is fixed
        while length(Event_String) < length(Events)
            Event_String = [Event_String upper(whyout)];
        end
        Event_String = Event_String(1:length(Events));
    else
        % If the event string is random
        for e = 1:length(Events)
            Event_String = [Event_String Parameters.Event_Chars(ceil(rand*length(Parameters.Event_Chars)))];
        end
    end
end

%% Create orientation stimuli
StimRect = [0 0 repmat(round(Rect(4)/3), 1, 2)];
Screen('FillRect', Win, Parameters.Background, Rect);
DrawFormattedText(Win, 'Generating images...', 'center', 'center', Parameters.Foreground); 
Screen('Flip', Win);
OriTextures = []; % Oriented gratings
RndTextures = []; % Non-oriented textures
for f = 1:100
    StimImg = ones(StimRect(4), StimRect(4)) / 2;
    StimImg = Gabor(StimImg, round(Parameters.Gabor_Params(1)*StimRect(4)), 0, round(Parameters.Gabor_Params(2)*StimRect(4)), ...
        RandOri, StimRect(4)/2, StimRect(4)/2);
    OriTextures(f) = Screen('MakeTexture', Win, StimImg*255);
%     StimImg = ones(StimRect(4), StimRect(4)) / 2;
%     for g = 0:RotatAngle:180-RotatAngle
%         StimImg = Gabor(StimImg, round(Parameters.Gabor_Params(1)*StimRect(4)), g, round(Parameters.Gabor_Params(2)*StimRect(4)), ...
%             RandOri, StimRect(4)/2, StimRect(4)/2, 1.5/Parameters.Volumes_per_Cycle);
%     end
%     RndTextures(f) = Screen('MakeTexture', Win, StimImg*255);
end

%% Setup trigger
if Emulate == 0
    SetupTrigger;
end

%% Standby screen
Screen('FillRect', Win, Parameters.Background, Rect);
DrawFormattedText(Win, [Parameters.Welcome '\n \n' Parameters.Instruction '\n \n' TrigStr ...
    '\n \n \n (Duration: ' n2s(length(Parameters.Conditions)*Parameters.Volumes_per_Cycle + Parameters.Dummies) ' volumes)'], ...
    'center', 'center', Parameters.Foreground); 
Screen('Flip', Win);
if Emulate
    WaitSecs(0.1);
    KbWait;
    [bkp bkt bk] = KbCheck;           
else
    TriggerExperiment;
    bk = zeros(1,256);
end

% Abort if Escape was pressed
if bk(KeyCodes.Escape) 
    % Abort screen
    Screen('FillRect', Win, Parameters.Background, Rect);
    DrawFormattedText(Win, 'Experiment was aborted!', 'center', 'center', Parameters.Foreground); 
    Screen('Flip', Win);
    WaitSecs(0.5);
    ShowCursor;
    Screen('CloseAll');
    new_line;
    disp('Experiment aborted by user!'); 
    new_line;
    % Experiment duration
    End_of_Expmt = GetSecs;
    new_line;
    ExpmtDur = End_of_Expmt - Start_of_Expmt;
    ExpmtDurMin = floor(ExpmtDur/60);
    ExpmtDurSec = mod(ExpmtDur, 60);
    disp(['Experiment lasted ' n2s(ExpmtDurMin) ' minutes, ' n2s(ExpmtDurSec) ' seconds']);
    new_line;
    if Emulate == 0
        CleanUpTrigger;
    end
    % Shutdown eye tracker if used
    if Parameters.Eye_tracker
        Eyelink('StopRecording');
        Eyelink('CloseFile');
        Eyelink('ShutDown');
    end
    return;
end
Screen('FillRect', Win, Parameters.Background, Rect);
Screen('Flip', Win);

%% Dummy volumes
Screen('FillRect', Win, Parameters.Background);    
% Overlay spiderweb
if Wa > 0
    for s = 1:length(Ix)
        Screen('DrawLines', Win, [[Ix(s);Iy(s)] [Ox(s);Oy(s)]], 1, [0 0 0 Wa], Rect(3:4)/2);
    end
    for s = Wc
        Screen('FrameOval', Win, [0 0 0 Wa], CenterRect([0 0 s s], Rect));
    end
end
if isfield(Parameters, 'Fixation_Width')
    Screen('FillOval', Win, Parameters.Event_Colour(2,:), CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect));    
end
Screen('Flip', Win);
WaitSecs(Parameters.Dummies * Parameters.TR);
Start_of_Expmt = GetSecs;

%% Run stimulus sequence 
Screen('TextFont', Win, 'Arial');
Screen('TextSize', Win, 14);
CurrVolume = 1; PrevVolume = 1;
for Trial = 1 : length(Parameters.Conditions)    
    %% Stimulus sequence
    CurrCondit = Parameters.Conditions(Trial);
    % Begin trial
    TrialOutput = struct;
    TrialOutput.TrialOnset = GetSecs;
    TrialOutput.TrialOffset = NaN;
    if Parameters.Eye_tracker
        TrialOutput.Eye = [];
    end

    %% Present short stimulus followed by long blank epoch
    KeyTime = -Inf;   % First key press was before the Big Bang
    k = 0;    % Toggle this when key was pressed recently
    f = ceil(rand(1,4)*length(OriTextures));    % Frame counter
    vf = 0;   % Video frame counter
    while GetSecs < TrialOutput.TrialOnset + Parameters.TR*Parameters.Volumes_per_Cycle - Slack
        % Current volume 
        CurrVolume = ceil((GetSecs - Start_of_Expmt) / Parameters.TR);
        if PrevVolume ~= CurrVolume
            PrevVolume = CurrVolume;
            CurrOris = NormDeg(CurrOris + RotatDirec*RotatAngle, 180);
        else
            if CurrCondit
                % Store orientation of this volume
                ApFrm(CurrVolume,:) = CurrOris;
            else
                % Non-oriented volume
                ApFrm(CurrVolume,:) = NaN(1,4);
            end
        end
        
        % Clear screen
        Screen('FillRect', Win, Parameters.Background);    
        % Draw movie frames
        if CurrCondit
            % Orientation condition
            Screen('DrawTexture', Win, OriTextures(f(1)), StimRect, CenterRect(StimRect, Rect) + [+1 -1 +1 -1]*StimRect(4)*.75, CurrOris(1));
            Screen('DrawTexture', Win, OriTextures(f(2)), StimRect, CenterRect(StimRect, Rect) + [-1 +1 -1 +1]*StimRect(4)*.75, CurrOris(2));
            Screen('DrawTexture', Win, OriTextures(f(3)), StimRect, CenterRect(StimRect, Rect) + [-1 -1 -1 -1]*StimRect(4)*.75, CurrOris(3));
            Screen('DrawTexture', Win, OriTextures(f(4)), StimRect, CenterRect(StimRect, Rect) + [+1 +1 +1 +1]*StimRect(4)*.75, CurrOris(4));
%         else
%             % Baseline condition
%             Screen('DrawTexture', Win, RndTextures(f(1)), StimRect, CenterRect(StimRect, Rect) + [+1 -1 +1 -1]*StimRect(4)*.75, 0);
%             Screen('DrawTexture', Win, RndTextures(f(2)), StimRect, CenterRect(StimRect, Rect) + [-1 +1 -1 +1]*StimRect(4)*.75, 0);
%             Screen('DrawTexture', Win, RndTextures(f(3)), StimRect, CenterRect(StimRect, Rect) + [-1 -1 -1 -1]*StimRect(4)*.75, 0);
%             Screen('DrawTexture', Win, RndTextures(f(4)), StimRect, CenterRect(StimRect, Rect) + [+1 +1 +1 +1]*StimRect(4)*.75, 0);
        end

        % Draw fixation cross 
        CurrEvents = (GetSecs - Start_of_Expmt) - Events;
        SmoothOval(Win, Parameters.Background, CenterRect([0 0 Parameters.Fixation_Width(2) Parameters.Fixation_Width(2)], Rect), Parameters.Fringe);    
        if sum(CurrEvents > 0 & CurrEvents < Parameters.Event_Duration)
            % This is an event
            if isfield(Parameters, 'Event_Chars')
                % If string is used
                Screen('FillOval', Win, Parameters.Event_Colour(2,:), CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect));
                DrawFormattedText(Win, Event_String(CurrEvents > 0 & CurrEvents < Parameters.Event_Duration), 'center', Rect(4)/2-12, Parameters.Event_Colour(1,:));
            else
                Screen('FillOval', Win, Parameters.Event_Colour(1,:), CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect));
            end
        else
            % This is not an event
            Screen('FillOval', Win, Parameters.Event_Colour(2,:), CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect));    
        end
        % Check whether the refractory period of key press has passed
        if k ~= 0 && GetSecs-KeyTime >= Parameters.Event_Duration
            k = 0;
        end

        % Overlay spiderweb
        if Wa > 0
            for s = 1:length(Ix)
                Screen('DrawLines', Win, [[Ix(s);Iy(s)] [Ox(s);Oy(s)]], 1, [0 0 0 Wa], Rect(3:4)/2);
            end
            for s = Wc
                Screen('FrameOval', Win, [0 0 0 Wa], CenterRect([0 0 s s], Rect));
            end
        end
        % Flip screen
        Screen('Flip', Win);

        % Advance frame
        vf = vf + 1;
        if vf > Parameters.Refreshs_per_Stim
            vf = 0;
            f = ceil(rand(1,4)*length(OriTextures));    % Renew frame counter
        end

        % Record eye data
        if Parameters.Eye_tracker
            if Eyelink( 'NewFloatSampleAvailable') > 0
                Eye = Eyelink( 'NewestFloatSample');
                ex = Eye.gx(Eye_used+1); 
                ey = Eye.gy(Eye_used+1);
                ep = Eye.pa(Eye_used+1);
                % Store if data is valid 
                if ex ~= Eye_params.MISSING_DATA && ey ~= Eye_params.MISSING_DATA && ep > 0
                    TrialOutput.Eye = [TrialOutput.Eye; GetSecs-TrialOutput.TrialOnset ex ey ep];
                end
            end
        end    

        % Behavioural response
        if k == 0
            [Keypr KeyTime Key] = KbCheck;
            if Keypr 
                k = 1;
                Behaviour.Response = [Behaviour.Response; find(Key)];
                Behaviour.ResponseTime = [Behaviour.ResponseTime; KeyTime - Start_of_Expmt];
            end
        end
        TrialOutput.Key = Key;
        % Abort if Escape was pressed
        if find(TrialOutput.Key) == KeyCodes.Escape
            % Abort screen
            Screen('TextFont', Win, Parameters.FontName);
            Screen('TextSize', Win, Parameters.FontSize);
            Screen('FillRect', Win, Parameters.Background, Rect);
            DrawFormattedText(Win, 'Experiment was aborted mid-block!', 'center', 'center', Parameters.Foreground); 
            WaitSecs(0.5);
            ShowCursor;
            Screen('CloseAll');
            new_line; 
            disp('Experiment aborted by user mid-block!'); 
            new_line;
            % Experiment duration
            End_of_Expmt = GetSecs;
            new_line;
            ExpmtDur = End_of_Expmt - Start_of_Expmt;
            ExpmtDurMin = floor(ExpmtDur/60);
            ExpmtDurSec = mod(ExpmtDur, 60);
            disp(['Experiment lasted ' n2s(ExpmtDurMin) ' minutes, ' n2s(ExpmtDurSec) ' seconds']);
            new_line;
            if Emulate == 0
                CleanUpTrigger;
            end
            % Shutdown eye tracker if used
            if Parameters.Eye_tracker
                Eyelink('StopRecording');
                Eyelink('CloseFile');
                Eyelink('ShutDown');
            end
            return;
        end
    end

    % Reaction to response
    if exist('.\Feedback.m') == 2
        Feedback;
    end
    TrialOutput.TrialOffset = GetSecs;

    % Record trial results   
    Results = [Results; TrialOutput];
end

% Clock after experiment
End_of_Expmt = GetSecs;

%% Save results of current block
Screen('TextFont', Win, Parameters.FontName);
Screen('TextSize', Win, Parameters.FontSize);
Screen('FillRect', Win, Parameters.Background, Rect);
DrawFormattedText(Win, 'Saving data...', 'center', 'center', Parameters.Foreground); 
Screen('Flip', Win);
save(['Results' filesep Parameters.Session_name]);

%% Clean up trigger
if Emulate == 0
    CleanUpTrigger;
end

%% Shutdown eye tracker if used
if Parameters.Eye_tracker
    Eyelink('StopRecording');
    Eyelink('CloseFile');
    Eyelink('ShutDown');
end

%% Farewell screen
Screen('FillRect', Win, Parameters.Background, Rect);
DrawFormattedText(Win, 'Thank you!', 'center', 'center', Parameters.Foreground); 
Screen('Flip', Win);
WaitSecs(Parameters.TR * Parameters.Overrun);
ShowCursor;
Screen('CloseAll');

%% Experiment duration
new_line;
ExpmtDur = End_of_Expmt - Start_of_Expmt;
ExpmtDurMin = floor(ExpmtDur/60);
ExpmtDurSec = mod(ExpmtDur, 60);
disp(['Experiment lasted ' n2s(ExpmtDurMin) ' minutes, ' n2s(ExpmtDurSec) ' seconds']);
disp(['There were ' n2s(length(Behaviour.EventTime)-1) ' dimming events.']);
if isfield(Parameters, 'Event_Chars')
    disp(['The event string was: ' Event_String]);
    Sequence = Event_String(ismember(Event_String, '123456789'));
    disp(['The target sequence was: ' Sequence]);
    disp(['The target sum was: ' n2s(sumdigits(Sequence))]);
else
    disp(['There were ' n2s(length(Behaviour.ResponseTime)) ' button presses.']);
end
new_line;

function outputimg = Gabor(inputimg, sigma, theta, lambda, phase, xpos, ypos, contr)
%outputimg = Gabor(inputimg, sigma, theta, lambda, phase, xpos, ypos, [contr])
% Draws a Gabor with specified parameters into the input image.
% Parameters:
%   inputimg :  Input image to draw in (should have grey background)
%   sigma :     Standard deviation of Gaussian envelope
%   theta :     Orientation of the carrier (0 deg = 3 o'clock, positive is counter-clockwise)
%   lambda :    Wavelength of the carrier
%   phase :     Phase of the carrier (cosine grating so 0 deg = light peak in middle)
%   xpos :      X pixel coordinate of the Gabor centre in the image 
%   ypos :      Y pixel coordinate of the Gabor centre in the image
%   contr :     Optional, defines the contrast of the Gabor between 0-1
% The function returns the new image containing the new Gabor element.
% Angles and phases are passed in degrees and converted into radians internally.
%

% If contrast undefined it is 100%
if nargin < 8
    contr = 1;
end

% Create output image
outputimg = inputimg;
dims = size(outputimg);

% Mathematical convention
theta = -(theta-90);

% Convert to radians
theta = pi * theta / 180; 
phase = pi * phase / 180;

% Coordinates of all pixels of the Gabor relative to its centre
[X Y] = meshgrid(-3*sigma : 3*sigma, -3*sigma : 3*sigma);

% Luminance modulation at each pixel:
% Gabor function = oriented sinusoidal carrier grating within a Gaussian envelope.
%  L = modulation of the background intensity i.e. full modulation is from 0 to 0.5
%           Gaussian                            Sinusoid    Carrier theta               Wavelength & Phase                                        
L = exp(-((X.^2)./(2*sigma.^2))-((Y.^2)./(2*sigma.^2))) .* (cos(2*pi .* (cos(theta).*X + sin(theta).*Y) ./ lambda + phase)) * contr/2;

% Determine pixel coordinates in the image
X = X + xpos;
Y = Y + ypos;

% Remove pixels outside the image
xrng = X(1,:) > 0 & X(1,:) <= dims(2);
yrng = Y(:,1) > 0 & Y(:,1) <= dims(1);
% X and Y are reversed because image is a MatLab Row x Col matrix!
X = X(yrng,xrng);
Y = Y(yrng,xrng);
L = L(yrng,xrng);

% Add the modulation of the pixels to the background intensity.
% X and Y are reversed because image is a MatLab Row x Col matrix!
outputimg(Y(:,1), X(1,:)) = outputimg(Y(:,1), X(1,:)) + L;