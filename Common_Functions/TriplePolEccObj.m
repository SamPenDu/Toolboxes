function TriplePolEccObj(Parameters, Emulate, SaveAps)
%TriplePolEccObj(Parameters, Emulate, SaveAps)
%
% Runs a triple polar & eccentricity mapping combined with objects localiser.
% If SaveAps is true it saves the aperture mask for each volume (for pRF).
%

% Go to folder of calling wrapper function
GoToCurrFunc; 

% Default is without scanner!
if nargin < 2
    Emulate = 1;
end
% Aperture saving undefined?
if nargin < 3
    SaveAps = 0;
end
% Alpha undefined?
if ~isfield(Parameters, 'Alpha')
    Alpha = 0;
else
    Alpha = Parameters.Alpha * 255;
end

%% Fixed sequence to ensure things work
Wedges = repmat(1:Parameters.Volumes_per_Cycle(1), 1, Parameters.Cycles_per_Expmt(1))';
Rings = repmat(1:Parameters.Volumes_per_Cycle(2), 1, Parameters.Cycles_per_Expmt(2))';
NumSeqVols = length(Wedges);
% Add the blanks
Blanks = ones(Parameters.Volumes_per_Cycle(3),1);
Visible = repmat([ones(length(Wedges)/2,1); zeros(Parameters.Volumes_per_Cycle(3),1)], 4, 1);
Wedges = [Wedges(1:NumSeqVols/2); Blanks; Wedges(NumSeqVols/2+1:end); Blanks; Wedges(end:-1:NumSeqVols/2+1); Blanks; Wedges(NumSeqVols/2:-1:1); Blanks];
Rings = [Rings(1:NumSeqVols/2); Blanks; Rings(end:-1:NumSeqVols/2+1); Blanks; Rings(NumSeqVols/2+1:end); Blanks; Rings(NumSeqVols/2:-1:1); Blanks];
LogDir = [ones(NumSeqVols/2,1); 0*Blanks; -ones(NumSeqVols/2,1); 0*Blanks; ones(NumSeqVols/2,1); 0*Blanks; -ones(NumSeqVols/2,1); 0*Blanks]; 
% Object vector
Vols_per_ObjBlk = NumSeqVols / 12;
Objects = [];
for i = 1:4
    CurObjOrder = repmat(1:2,1,3);
    if isodd(i)
        CurObjOrder = fliplr(CurObjOrder);
    end
    for j = 1:length(CurObjOrder)
        Objects = [Objects; CurObjOrder(j)*ones(Vols_per_ObjBlk,1)];
    end
    Objects = [Objects; zeros(Parameters.Volumes_per_Cycle(3),1)];
end

% Default is without scanner!
if nargin < 2
    Emulate = 1;
end

% Create the mandatory folders if not already present 
if ~exist([cd filesep 'Results'], 'dir')
    mkdir('Results');
end

%% Initialize randomness & keycodes
SetupRand;
SetupKeyCodes;

%% Behavioural data
Behaviour = struct;
Behaviour.EventTime = [];
Behaviour.Response = [];
Behaviour.ResponseTime = [];

%% Event timings 
Events = []; 
for e = Parameters.TR : Parameters.Event_Duration : length(Visible) * Parameters.TR
    if rand < Parameters.Prob_of_Event
        Events = [Events; e];
    end
end
% Add a dummy event at the end of the Universe
Events = [Events; Inf];

%% Configure events
if ~isfield(Parameters, 'Event_Colour')
    Parameters.Event_Colour = [0 0 255; 0 0 0];
end
% Randomizing event colours?
if isnan(Parameters.Event_Colour)
    Parameters.Event_Colour = [NaN NaN NaN; 0 0 0];
    Colours = [];
    for e = 1:length(Events)
        Colours = [Colours; (rand(1,3) > 0.5) * 255];
    end
end
% Event string present?
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

%% Configure scanner 
if Emulate 
    % Emulate scanner
    TrigStr = 'Press key to start...';    % Trigger string
else
    % Real scanner
    TrigStr = 'Stand by for scan...';    % Trigger string
end

%% Initialize PTB
if ~isfield(Parameters, 'Gamma')
    Parameters.Gamma = 1; % If gamma undefined, don't use
end
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
[Win, Rect] = PsychImaging('OpenWindow', Parameters.Screen, Parameters.Background, Parameters.Resolution, 32); 
PsychColorCorrection('SetEncodingGamma', Win, Parameters.Gamma); % Apply desired gamma correction
disp(['Applying gamma correction = ' n2s(Parameters.Gamma)]);
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

%% Initialization
% Spiderweb coordinates
[Ix Iy] = pol2cart([0:30:330]/180*pi, Parameters.Fixation_Width(1));
[Ox Oy] = pol2cart([0:30:330]/180*pi, Rect(3)/2);
Rc = Rect(3) - Parameters.Fixation_Width(2);
Sc = round(Rc / 10);
Wc = Parameters.Fixation_Width(2) : Sc : Rect(3);
Wa = round(Parameters.Spider_Web * 255);

% Load background movie
Screen('FillRect', Win, Parameters.Background, Rect);
DrawFormattedText(Win, 'Please stand by while images are loading...', 'center', 'center', Parameters.Foreground); 
Screen('Flip', Win);
disp('Please stand by while images are loading...');
StimRect = [0 0 repmat(size(Parameters.Stimulus{1},1), 1, 2)];
BgdTextures = {[] []};
% Loop thru stimulus types
for i = 1:2
    if length(size(Parameters.Stimulus{i})) < 4
        for f = 1:size(Parameters.Stimulus{i}, 3)
            BgdTextures{i}(f) = Screen('MakeTexture', Win, Parameters.Stimulus{i}(:,:,f));
        end
    else
        for f = 1:size(Parameters.Stimulus{i}, 4)
            BgdTextures{i}(f) = Screen('MakeTexture', Win, Parameters.Stimulus{i}(:,:,:,f));
        end
    end
    % Shuffle textures 
    Stimulus_Order = randperm(size(Parameters.Stimulus{i}, length(size(Parameters.Stimulus{i}))));
    BgdTextures{i} = BgdTextures{i}(Stimulus_Order);
end

% Background variables
CurrFrame = 0;
CurrStim = 1;

% Advancement per volume (originally incorrectly used screen width rather than height)
Angle_per_Vol = 360 / Parameters.Volumes_per_Cycle(1);  % Angle steps per volume
if strcmpi(Parameters.Ring_Scaling(1:3), 'log') 
    Pixels_per_Vol = Rect(4) * exp(-4+4/Parameters.Volumes_per_Cycle(2):4/Parameters.Volumes_per_Cycle(2):0)';   % Logarithmic increase in ring widths
elseif strcmpi(Parameters.Ring_Scaling(1:3), 'lin') 
    Pixels_per_Vol = Rect(4) / Parameters.Volumes_per_Cycle(2);  % Steps in ring width per volume
end

% Initialize circular Aperture
CircAperture = Screen('MakeTexture', Win, 127 * ones(Rect([4 3])));
if SaveAps
    if SaveAps == 1
        ApFrm = zeros(100, 100, length(Wedges));
    elseif SaveAps == 2
        ApFrm = zeros(300, 300);
        sf = 0;
    end    
    SavWin = Screen('MakeTexture', Win, 127 * ones(Rect([4 3])));
end

%% Setup trigger
if Emulate == 0
    SetupTrigger;
end

%% Standby screen
Screen('FillRect', Win, Parameters.Background, Rect);
DrawFormattedText(Win, [Parameters.Welcome '\n \n' Parameters.Instruction '\n \n' TrigStr ...
    '\n \n \n (Duration: ' n2s(length(Visible) + Parameters.Dummies) ' volumes)'], ...
    'center', 'center', Parameters.Foreground); 
Screen('Flip', Win);
disp('***************************************************************************************');
disp(strrep([Parameters.Welcome '\n' Parameters.Instruction '\n' TrigStr ...
    '\n (Duration: ' n2s(length(Visible) + Parameters.Dummies) ' volumes)'], '\n', newline));
new_line;
if Emulate
    WaitSecs(0.1);
    KbWait;
    [bkp Start_of_Expmt bk] = KbCheck;           
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

% Dummy volumes
Screen('FillRect', CircAperture, Parameters.Background);    
% Overlay spiderweb
if Wa > 0
    for s = 1:length(Ix)
        Screen('DrawLines', Win, [[Ix(s);Iy(s)] [Ox(s);Oy(s)]], 1, [0 0 0 Wa], Rect(3:4)/2);
    end
    for s = Wc
        Screen('FrameOval', Win, [0 0 0 Wa], CenterRect([0 0 s s], Rect));
    end
end
% Draw fixation dot
Screen('FillOval', Win, Parameters.Event_Colour(2,:), CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect));
Screen('Flip', Win);
WaitSecs(Parameters.Dummies * Parameters.TR);
Start_of_Expmt = GetSecs;

% Behaviour structure
Behaviour.EventTime = Events;
k = 0;  % Toggle this when key was pressed recently

% Begin trial
TrialOutput = struct;
TrialOutput.TrialOnset = GetSecs;
TrialOutput.TrialOffset = NaN;
if Parameters.Eye_tracker
    TrialOutput.Eye = [];
end

%% Stimulus movie
Screen('TextFont', Win, 'Arial');
Screen('TextSize', Win, 14);
CurrVolume = 1; PrevVolume = 0;
while CurrVolume <= length(Wedges)
    % Determine current frame 
    CurrFrame = CurrFrame + 1;
    if CurrFrame > Parameters.Refreshs_per_Stim 
        CurrFrame = 1;
        CurrStim = CurrStim + 1;
    end

    % Create Aperture
    Screen('FillRect', CircAperture, [Parameters.Background Alpha]);
    CurrAngle = Wedges(CurrVolume) * Angle_per_Vol - Angle_per_Vol * 1.5 + 90;
    if strcmpi(Parameters.Ring_Scaling(1:3), 'log')
        if LogDir(CurrVolume) == 1
            CurrWidth = Pixels_per_Vol(mod(CurrVolume-1,Parameters.Volumes_per_Cycle(2))+1);
        elseif LogDir(CurrVolume) == -1
            CurrWidth = Pixels_per_Vol(end-mod(CurrVolume-1,Parameters.Volumes_per_Cycle(2)));
        end
    elseif strcmpi(Parameters.Ring_Scaling(1:3), 'lin') 
        CurrWidth = Rings(CurrVolume) * Pixels_per_Vol;
    end
    if Visible(CurrVolume) 
        if strcmpi(Parameters.Ring_Scaling(1:3), 'log') 
            Screen('FillOval', CircAperture, [0 0 0 0], CenterRect([0 0 repmat(CurrWidth * 4/3,1,2)], Rect));
            InnerWidth = CurrWidth * 3/4;
        elseif strcmpi(Parameters.Ring_Scaling(1:3), 'lin') 
            Screen('FillOval', CircAperture, [0 0 0 0], CenterRect([0 0 repmat(CurrWidth + Pixels_per_Vol * 0.5,1,2)], Rect));
            InnerWidth = CurrWidth - Pixels_per_Vol * 1.5;
        end
        if InnerWidth < 0
            InnerWidth = 0;
        end
        Screen('FillOval', CircAperture, [Parameters.Background Alpha], CenterRect([0 0 repmat(InnerWidth + 1,1,2)], Rect));
        Screen('FillArc', CircAperture, [0 0 0 0], CenterRect([0 0 repmat(Rect(4),1,2)], Rect), CurrAngle-Angle_per_Vol/2, Angle_per_Vol*2);
        % Rotate background movie?
        BgdAngle = cos((GetSecs-TrialOutput.TrialOnset)/Parameters.TR * 2*pi) * Parameters.Sine_Rotation;
        % Draw movie frame
        if CurrStim > size(Parameters.Stimulus{Objects(CurrVolume)}, length(size(Parameters.Stimulus{Objects(CurrVolume)})))
            CurrStim = 1;
        end
        Screen('DrawTexture', Win, BgdTextures{Objects(CurrVolume)}(CurrStim), StimRect, CenterRect([0 0 Rect(4) Rect(4)], Rect), BgdAngle);
    end
    
    
    % Draw aperture
    Screen('DrawTexture', Win, CircAperture, Rect, Rect);
    CurrEvents = (GetSecs - Start_of_Expmt) - Events;
    % Draw hole around fixation
    SmoothOval(Win, Parameters.Background, CenterRect([0 0 Parameters.Fixation_Width(2) Parameters.Fixation_Width(2)], Rect), Parameters.Fringe);    

    % If saving movie
    if SaveAps == 1 && PrevVolume ~= CurrVolume 
        % Save apertures
        PrevVolume = CurrVolume;
        CurApImg = Screen('GetImage', Win, CenterRect([0 0 Rect(4) Rect(4)], Rect), 'backBuffer'); 
        CurApImg = rgb2gray(CurApImg);
        CurApImg = double(abs(double(CurApImg)-127)>1);
        CurApImg = imresize(CurApImg, [100 100]);
        ApFrm(:,:,CurrVolume) = CurApImg;
    elseif SaveAps == 2
        % Saving downsampled movie
        CurApImg = Screen('GetImage', Win, CenterRect([0 0 Rect(4) Rect(4)], Rect), 'backBuffer'); 
        CurApImg = rgb2gray(CurApImg);
        sf = sf + 1;
        ApFrm(:,:,sf) = imresize(CurApImg, [300 300]);
    end

    % Draw fixation dot 
    if sum(CurrEvents > 0 & CurrEvents < Parameters.Event_Duration)
        % This is an event
        if isfield(Parameters, 'Event_Chars')
            % If string is used
            Screen('FillOval', Win, Parameters.Event_Colour(2,:), CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect));
            DrawFormattedText(Win, Event_String(CurrEvents > 0 & CurrEvents < Parameters.Event_Duration), 'center', Rect(4)/2-12, Parameters.Event_Colour(1,:));
        else
            if isnan(sum(Parameters.Event_Colour(1,:)))
                % Randomized event colour
                Screen('FillOval', Win, Colours(CurrEvents > 0 & CurrEvents < Parameters.Event_Duration, :), CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect));
            else
                % Fixed event colour
                Screen('FillOval', Win, Parameters.Event_Colour(1,:), CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect));
            end
        end
    else
        % This is not an event
        Screen('FillOval', Win, Parameters.Event_Colour(2,:), CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect));
    end    
    % Check whether the refractory period of key press has passed
    if k ~= 0 && GetSecs-KeyTime >= 2*Parameters.Event_Duration
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
    % Saving screen shot?
    if SaveAps == 3
        CurApImg = Screen('GetImage', Win, CenterRect([0 0 Rect(4) Rect(4)], Rect), 'backBuffer'); 
        imwrite(CurApImg, 'Screenshot.png');
        SaveAps = 0;
    end    
    % Flip screen
    Screen('Flip', Win);

    % Behavioural response
    if k == 0
        [Keypr KeyTime Key] = KbCheck;
        if Keypr 
            k = 1;
            Behaviour.Response = [Behaviour.Response; find(Key,1)];
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
        DrawFormattedText(Win, 'Experiment was aborted mid-experiment!', 'center', 'center', Parameters.Foreground); 
        WaitSecs(0.5);
        ShowCursor;
        Screen('CloseAll');
        new_line; 
        disp('Experiment aborted by user mid-experiment!'); 
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
        return
    elseif find(TrialOutput.Key) == KeyCodes.Space
        % Save screenshot of next frame
        SaveAps = 3;
    end

    % Determine current volume
    CurrVolume = floor((GetSecs - Start_of_Expmt) / Parameters.TR) + 1;

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
end

% Trial end time
TrialOutput.TrialOffset = GetSecs;

% Record trial results   
Results = [Results; TrialOutput];

% Clock after experiment
End_of_Expmt = GetSecs;

%% Save results
Screen('TextFont', Win, Parameters.FontName);
Screen('TextSize', Win, Parameters.FontSize);
Parameters = rmfield(Parameters, 'Stimulus');  % Remove stimulus from data
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

%% Save movie
if SaveAps == 2
    ApFrm = uint8(ApFrm);
    save('Stimulus_movie', 'ApFrm');
end
