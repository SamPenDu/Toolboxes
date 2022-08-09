function Bars_Mapping_log(Parameters, Emulate, SaveAps)
%Bars_Mapping_log(Parameters, Emulate, [SaveAps = 0])
%
% Runs the drifting bar protocol for mapping population receptive fields.
% Step size of bars is adjusted logarithmically relative to eccentricity.
% If SaveAps is 1 it saves the aperture for each volume.
% If it is 2 it saves a frame of the actual stimulus movie. 
% If it is 0 (default) it doesn't save anything.
% 
%

if nargin < 3
    SaveAps = 0;
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
KeyTime = -Inf;   % First key press was before the Big Bang

%% Event timings 
Events = [];
for e = Parameters.TR : Parameters.Event_Duration : (length(Parameters.Conditions) * Parameters.Volumes_per_Trial * Parameters.TR)
    if rand < Parameters.Prob_of_Event
        Events = [Events; e];
    end
end
% Add a dummy event at the end of the Universe
Events = [Events; Inf];

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
Frames_per_Sec = 1 / RefreshDur;
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

%% Initialize various variables
Results = [];

% Spiderweb coordinates
[Ix Iy] = pol2cart([0:30:330]/180*pi, Parameters.Fixation_Width(1));
[Ox Oy] = pol2cart([0:30:330]/180*pi, Rect(3)/2);
Rc = Rect(3) - Parameters.Fixation_Width(2);
Sc = round(Rc / 10);
Wc = Parameters.Fixation_Width(2) : Sc : Rect(3);
Wa = round(Parameters.Spider_Web * 255);

% Load background movie
StimRect = [0 0 repmat(size(Parameters.Stimulus,1), 1, 2)];
BgdTextures = [];
if length(size(Parameters.Stimulus)) < 4
    for f = 1:size(Parameters.Stimulus, 3)
        BgdTextures(f) = Screen('MakeTexture', Win, Parameters.Stimulus(:,:,f));
    end
else
    for f = 1:size(Parameters.Stimulus, 4)
        BgdTextures(f) = Screen('MakeTexture', Win, Parameters.Stimulus(:,:,:,f));
    end
end

%% Background variables
CurrFrame = 0;
CurrStim = 1;
LogRadius = log(StimRect(3)/2);
LogPos = LogRadius/(Parameters.Volumes_per_Trial/2) : LogRadius/(Parameters.Volumes_per_Trial/2) : LogRadius;
BarPos = [-exp(fliplr(LogPos)) exp(LogPos)] + Rect(3)/2;

%% Initialize circular Aperture
CircAperture = Screen('MakeTexture', Win, 127 * ones(Rect([4 3])));
if SaveAps
    if SaveAps == 1
        ApFrm = zeros(100, 100, Parameters.Volumes_per_Trial * length(Parameters.Conditions));
    elseif SaveAps == 2
        ApFrm = zeros(300, 300);
        sf = 0;
    end
    SavWin = Screen('MakeTexture', Win, 127 * ones(Rect([4 3])));
end

% If scanning use Cogent
if Emulate == 0
    config_serial;
    start_cogent;
    Port = 1;
end

%% Standby screen
Screen('FillRect', Win, Parameters.Background, Rect);
DrawFormattedText(Win, [Parameters.Welcome '\n \n' Parameters.Instruction '\n \n' TrigStr], 'center', 'center', Parameters.Foreground); 
Screen('Flip', Win);
if Emulate
    WaitSecs(0.1);
    KbWait;
    [bkp bkt bk] = KbCheck;           
else
    %%% CHANGE THIS TO WHATEVER CODE YOU USE TO TRIGGER YOUR SCRIPT!!! %%%
    CurrSlice = waitslice(Port, 1);  
    bk = zeros(1,256);
end
Start_of_Expmt = GetSecs;

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
    %%% REMOVE THIS IF YOU DON'T USE COGENT!!! %%%
    if Emulate == 0
        % Turn off Cogent
        stop_cogent;
    end
    % Shutdown eye tracker if used
    if Parameters.Eye_tracker
        Eyelink('StopRecording');
        Eyelink('CloseFile');
        Eyelink('ShutDown');
    end
    return
end

%% Dummy volumes
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

%% Behaviour structure
Behaviour.EventTime = Events;
k = 0;  % Toggle this when key was pressed recently

%% Run stimulus sequence 
for Trial = 1 : length(Parameters.Conditions)
    % Begin trial
    TrialOutput = struct;
    TrialOutput.TrialOnset = GetSecs;
    TrialOutput.TrialOffset = NaN;
    if Parameters.Eye_tracker
        TrialOutput.Eye = [];
    end

    %% Stimulation sequence
    CurrCondit = Parameters.Conditions(Trial);
    new_line; disp([Trial CurrCondit]);
    CurrVolume = 1; PrevVolume = 0;
    while CurrVolume <= Parameters.Volumes_per_Trial        
        % Determine current frame 
        CurrFrame = CurrFrame + 1;
        if CurrFrame > Parameters.Refreshs_per_Stim 
            CurrFrame = 1;
            CurrStim = CurrStim + 1;
        end
        if CurrStim > size(Parameters.Stimulus, length(size(Parameters.Stimulus)))
            CurrStim = 1;
        end

        % Create Aperture
        Screen('FillRect', CircAperture, [0 0 0 0]);    
        if isnan(CurrCondit) 
            Screen('FillRect', CircAperture, Parameters.Background);    
        else    
            if CurrVolume < Parameters.Volumes_per_Trial/2
                Bar_HalfWidth = -(BarPos(CurrVolume)-BarPos(CurrVolume+1)) * 0.75;
            else
                Bar_HalfWidth = (BarPos(CurrVolume)-BarPos(CurrVolume-1)) * 0.75;
            end
            SmoothRect(CircAperture, Parameters.Background, [0 0 BarPos(CurrVolume)-Bar_HalfWidth Rect(4)], Parameters.Fringe);    
            SmoothRect(CircAperture, Parameters.Background, [BarPos(CurrVolume)+Bar_HalfWidth 0 Rect(3) Rect(4)], Parameters.Fringe);    
        end

        % Rotate background movie?
        BgdAngle = cos((GetSecs-TrialOutput.TrialOnset)/Parameters.TR * 2*pi) * Parameters.Sine_Rotation;

        % Draw movie frame
        Screen('DrawTexture', Win, BgdTextures(CurrStim), StimRect, CenterRect(StimRect, Rect), BgdAngle+CurrCondit-90);
        % Draw aperture (and save if desired)
        Screen('DrawTexture', Win, CircAperture, Rect, Rect, CurrCondit-90);
        CurrEvents = (GetSecs - Start_of_Expmt) - Events;
        % Draw hole around fixation
        SmoothOval(Win, Parameters.Background, CenterRect([0 0 Parameters.Fixation_Width(2) Parameters.Fixation_Width(2)], Rect), Parameters.Fringe);    

        % If saving movie
        if SaveAps == 1 && PrevVolume ~= CurrVolume
            PrevVolume = CurrVolume;
            CurApImg = Screen('GetImage', Win, CenterRect(StimRect, Rect), 'backBuffer'); 
            CurApImg = rgb2gray(CurApImg);
            CurApImg = imresize(CurApImg, [100 100]);
            CurApImg = double(abs(double(CurApImg)-127)>1);
            ApFrm(:,:,Parameters.Volumes_per_Trial*(Trial-1)+CurrVolume) = CurApImg;
        elseif SaveAps == 2
            CurApImg = Screen('GetImage', Win, CenterRect(StimRect, Rect), 'backBuffer'); 
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
                DrawFormattedText(Win, Event_String(CurrEvents > 0 & CurrEvents < Parameters.Event_Duration), 'center', Rect(4)/2-Parameters.FontSize, Parameters.Event_Colour(1,:));
            else
                Screen('FillOval', Win, Parameters.Event_Colour(1,:), CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect));
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
        % Flip screen
        Screen('Flip', Win);

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
            %%% REMOVE THIS IF YOU DON'T USE COGENT!!! %%%
            if Emulate == 0
                % Turn off Cogent
                stop_cogent;
            end
            % Shutdown eye tracker if used
            if Parameters.Eye_tracker
                Eyelink('StopRecording');
                Eyelink('CloseFile');
                Eyelink('ShutDown');
            end
            return
        end
    
        % Determine current volume
        CurrVolume = floor((GetSecs-TrialOutput.TrialOnset-Slack) / Parameters.TR) + 1;

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
end

% Clock after experiment
End_of_Expmt = GetSecs;

%% Save results of current block
Parameters = rmfield(Parameters, 'Stimulus');  
Screen('FillRect', Win, Parameters.Background, Rect);
DrawFormattedText(Win, 'Saving data...', 'center', 'center', Parameters.Foreground); 
Screen('Flip', Win);
save(['Results' filesep Parameters.Session_name]);

%% Shut down Cogent
%%% REMOVE THIS IF YOU DON'T USE COGENT!!! %%%
if Emulate == 0
    % Turn off Cogent
    stop_cogent;
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
    disp(['The target sum was: ' sumdigits(Sequence)]);
else
    disp(['There were ' n2s(length(Behaviour.ResponseTime)) ' button presses.']);
end
new_line;

%% Save movie
if SaveAps == 2
    ApFrm = uint8(ApFrm);
    save('Stimulus_movie', 'ApFrm');
end
