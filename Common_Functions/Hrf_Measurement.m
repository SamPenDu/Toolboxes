function Hrf_Measurement(Parameters, Emulate)
%Hrf_Measurement(Parameters, Emulate)
%
% Runs an experiment to measure the HRF in a slow event-related design.
%

% Go to folder of calling wrapper function
GoToCurrFunc; 

% Default is without scanner!
if nargin < 2
    Emulate = 1;
end
% Shuffling undefined?
if ~isfield(Parameters, 'Shuffle_Stims')
    Parameters.Shuffle_Stims = false;
end
% Stimulus duration undefined?
if ~isfield(Parameters, 'Volumes_per_Stim')
    Parameters.Volumes_per_Stim = 1;
end

% Create the mandatory folders if not already present 
if ~exist([cd filesep 'Results'], 'dir')
    mkdir('Results');
end

% Check if eyetracker defined
if ~isfield(Parameters, 'Eye_tracker')
    Parameters.Eye_tracker = false;
end

disp(['Duration: ' n2s(length(Parameters.Conditions)*Parameters.Volumes_per_Trial + Parameters.Dummies) ' volumes']);

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
CurrVolume = 0;
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
for e = Parameters.TR : Parameters.Event_Duration : (length(Parameters.Conditions) * Parameters.Volumes_per_Trial * Parameters.TR)
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

%% Load background movie
Screen('FillRect', Win, Parameters.Background, Rect);
DrawFormattedText(Win, 'Please stand by while images are loading...', 'center', 'center', Parameters.Foreground); 
Screen('Flip', Win);
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
% Shuffle textures if desired
if Parameters.Shuffle_Stims
    Stimulus_Order = randperm(size(Parameters.Stimulus, length(size(Parameters.Stimulus))));
    BgdTextures = BgdTextures(Stimulus_Order);
end

%% Setup trigger
if Emulate == 0
    SetupTrigger;
end

%% Loop through blocks
for Block = 0 : Parameters.Blocks_per_Expmt-1
    if Parameters.Shuffle_Conditions
        %% Reshuffle the conditions for this block
        Reshuffling = randperm(length(Parameters.Conditions));
    else
        %% Conditions in pre-defined order
        Reshuffling = 1 : length(Parameters.Conditions);
    end
    
    %% Standby screen
    Screen('FillRect', Win, Parameters.Background, Rect);
    DrawFormattedText(Win, [Parameters.Welcome '\n \n' Parameters.Instruction '\n \n' TrigStr ...
        '\n \n \n (Duration: ' n2s(length(Parameters.Conditions)*Parameters.Volumes_per_Trial + Parameters.Dummies) ' volumes)'], ...
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
    Start_of_Block(Block+1) = GetSecs;
    if isnan(Start_of_Expmt)
        Start_of_Expmt = Start_of_Block(Block+1);
    end

    %% Run stimulus sequence 
    Screen('TextFont', Win, 'Arial');
    Screen('TextSize', Win, 14);
    for Trial = 1 : length(Parameters.Conditions)    
        %% Stimulus sequence
        CurrCondit = Parameters.Conditions(Reshuffling(Trial));
    	% Current volume 
    	CurrVolume = ceil((GetSecs - Start_of_Block(Block+1)) / Parameters.TR);
        
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
        f = ceil(rand*length(BgdTextures));    % Frame counter
        vf = 0;   % Video frame counter
        while GetSecs < TrialOutput.TrialOnset + Parameters.TR*Parameters.Volumes_per_Trial - Slack
            % Rotate background movie?
            BgdAngle = cos(GetSecs - TrialOutput.TrialOnset) * Parameters.Sine_Rotation;

            % Clear screen
            Screen('FillRect', Win, Parameters.Background);    
            % Is this a stimulus volume?
            if GetSecs < TrialOutput.TrialOnset + Parameters.TR*Parameters.Volumes_per_Stim - Slack
                % Draw movie frame
                Screen('DrawTexture', Win, BgdTextures(f), StimRect, CenterRect([0 0 Rect(4) Rect(4)], Rect), BgdAngle+CurrCondit-90);
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
                f = f + 1;
                if f > size(Parameters.Stimulus, length(size(Parameters.Stimulus)))
                    f = 1;
                end
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
end

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

