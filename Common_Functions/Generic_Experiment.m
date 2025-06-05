function ExpmtDur = Generic_Experiment(Parameters, Emulate)
%ExpmtDur = Generic_Experiment(Parameters, Emulate)
%
% Runs a generic psychophysics experiment. Originally this was conceived 
% for the method of constant stimuli, but it may also adapted for the
% use of staircase procedures. It should also be usable in the scanner.
%
% Emulate determines how the program is triggered:
%   (0 = scanner, 1 = keyboard, -1 = mouse)
%

% Go to folder of calling wrapper function
GoToCurrFunc; 

% Default is without scanner!
if nargin < 2
    Emulate = 1;
end

% Create the mandatory folders if not already present 
if ~exist([cd filesep 'Results'], 'dir')
    mkdir('Results');
end

% Check if screen defined
if ~isfield(Parameters, 'Screen')
    Parameters.Screen = 0;
end

% Check if eyetracker defined
if ~isfield(Parameters, 'Eye_tracker')
    Parameters.Eye_tracker = false;
end

% Check if stereo
if ~isfield(Parameters, 'Stereo')
    Parameters.Stereo = 0;
end

%% Initialize randomness & keycodes
SetupRand;
SetupKeyCodes;

%% Configure scanner 
if Emulate == 1
    % Emulate scanner
    TrigStr = 'Press any key to start (Esc to abort)...';    % Trigger string
elseif Emulate == -1
    % Emulate scanner
    TrigStr = 'Click mouse to start (middle button to abort)...';    % Trigger string
else
    % Real scanner
    TrigStr = 'Stand by for scan...';    % Trigger string
end

%% Initialize PTB
if ~isfield(Parameters, 'Gamma')
    Parameters.Gamma = 1; % If gamma undefined, don't use
end
if length(Screen('Screens')) == 1  && Parameters.Screen > 0
    Parameters.Screen = 0; % If only one screen
end
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
[Win, Rect] = PsychImaging('OpenWindow', Parameters.Screen, Parameters.Background, Parameters.Resolution, 32, 2, Parameters.Stereo); 
PsychColorCorrection('SetEncodingGamma', Win, Parameters.Gamma); % Apply desired gamma correction
disp(['Applying gamma correction = ' n2s(Parameters.Gamma)]);
Screen('TextFont', Win, Parameters.FontName);
Screen('TextSize', Win, Parameters.FontSize);
Screen('BlendFunction', Win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
HideCursor;
RefreshDur = Screen('GetFlipInterval',Win);
Slack = RefreshDur / 2;
Screen_Centre = Rect(3:4) / 2;

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
        if Eye_used == Eye_params.BINOCULAR 
            % If both eyes are tracked use left
            Eye_used = Eye_params.LEFT_EYE;         
        end
    end
end

%% Various variables
Results = [];
CurrVolume = 0;
Start_of_Expmt = NaN;

%% Custom initialization
Screen('SelectStereoDrawBuffer', Win, 0);
Screen('FillRect', Win, Parameters.Background, Rect);
DrawFormattedText(Win, 'Initialization - please stand by...', 'center', 'center', Parameters.Foreground); 
if Parameters.Stereo > 0
    Screen('SelectStereoDrawBuffer', Win, 1);
    Screen('FillRect', Win, Parameters.Background, Rect);
    DrawFormattedText(Win, 'Initialization - please stand by...', 'center', 'center', Parameters.Foreground); 
end
Screen('Flip', Win);
disp('Initialization - please stand by...');
if exist(['.' filesep 'Initialization.m']) == 2
    Initialization;
end

%% Setup trigger
if Emulate == 0
    SetupTrigger;
end

%% Transpose conditions if column vector
if size(Parameters.Conditions,2) == 1
    Parameters.Conditions = Parameters.Conditions';
end

%% Loop through blocks
for Block = 0 : Parameters.Blocks_per_Expmt-1
    if Parameters.Shuffle_Conditions
        %% Reshuffle the conditions for this block
        Reshuffling = randperm(size(Parameters.Conditions,2));
    else
        %% Conditions in pre-defined order
        Reshuffling = 1 : size(Parameters.Conditions,2);
    end
        
    %% Standby screen
    if isfield(Parameters, 'Volumes_per_Expmt')
        Vol_per_Exp = ['\n \n \n(Duration: ' n2s(Parameters.Volumes_per_Expmt) ' volumes)'];
    else
        Vol_per_Exp = '';
    end
    if Parameters.Blocks_per_Expmt > 1
        Blk_per_Exp = ['Block ' num2str(Block+1) ' of ' num2str(Parameters.Blocks_per_Expmt) '\n \n'];
    else
        Blk_per_Exp = '';
    end
    Screen('SelectStereoDrawBuffer', Win, 0);
    Screen('FillRect', Win, Parameters.Background, Rect);
    DrawFormattedText(Win, [Parameters.Welcome '\n \n' Parameters.Instruction '\n \n' ... 
        Blk_per_Exp TrigStr Vol_per_Exp], 'center', 'center', Parameters.Foreground); 
    if Parameters.Stereo > 0
        Screen('SelectStereoDrawBuffer', Win, 1);
        Screen('FillRect', Win, Parameters.Background, Rect);
        DrawFormattedText(Win, [Parameters.Welcome '\n \n' Parameters.Instruction '\n \n' ... 
            Blk_per_Exp TrigStr Vol_per_Exp], 'center', 'center', Parameters.Foreground); 
    end
    Screen('Flip', Win);
    disp('***************************************************************************************');
    disp(strrep([Parameters.Welcome '\n' Parameters.Instruction '\n' Blk_per_Exp TrigStr Vol_per_Exp], '\n', newline));
    new_line;
    if Emulate == 1
        WaitSecs(0.1);
        KbWait;
        [bkp bkt bk] = KbCheck;           
    elseif Emulate == -1
        WaitSecs(0.1);
        bk = waitformouse;
    else
        TriggerExperiment;
        bk = zeros(1,256);
    end
    
    % Abort if Escape was pressed
    if ismember(KeyCodes.Escape, find(bk)) | find(bk) == 2
        % Abort screen
        Screen('SelectStereoDrawBuffer', Win, 0);
        Screen('FillRect', Win, Parameters.Background, Rect);
        DrawFormattedText(Win, 'Experiment was aborted!', 'center', 'center', Parameters.Foreground); 
        if Parameters.Stereo > 0
            Screen('SelectStereoDrawBuffer', Win, 1);
            Screen('FillRect', Win, Parameters.Background, Rect);
            DrawFormattedText(Win, 'Experiment was aborted!', 'center', 'center', Parameters.Foreground); 
        end
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
    DummyStart = Screen('Flip', Win);

    %% Dummy volumes
    if isfield(Parameters, 'Fixation_Width')
        Screen('SelectStereoDrawBuffer', Win, 0);
        Screen('FillRect', Win, Parameters.Background);    
        Screen('FillOval', Win, Parameters.Foreground, CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect));    
        if Parameters.Stereo > 0
            Screen('SelectStereoDrawBuffer', Win, 1);
            Screen('FillRect', Win, Parameters.Background);    
            Screen('FillOval', Win, Parameters.Foreground, CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect));    
        end
        Screen('Flip', Win);
    end
    % Wait for dummies
    EyeCalibration = [];
    while GetSecs - DummyStart < Parameters.Dummies * Parameters.TR - Slack
        % Check eye position
        if Parameters.Eye_tracker
            if Eyelink( 'NewFloatSampleAvailable') > 0
                Eye = Eyelink( 'NewestFloatSample');
                ex = Eye.gx(Eye_used+1); 
                ey = Eye.gy(Eye_used+1);
                ep = Eye.pa(Eye_used+1);
                EyeCalibration = [EyeCalibration; ex ey];
            end            
        end
        
        % Show fixation dot
        Screen('FillOval', Win, [0 0 255], CenterRect([0 0 6 6], Rect));    
        Screen('Flip', Win);        
    end
    EyeCalibration = median(EyeCalibration); % Calibrated eye position of screen centre
    Start_of_Block(Block+1) = GetSecs;
    if isnan(Start_of_Expmt)
        Start_of_Expmt = Start_of_Block(Block+1);
    end

    %% Run stimulus sequence 
    for Trial = 1 : size(Parameters.Conditions,2)    
    	% Current volume 
    	CurrVolume = ceil((GetSecs - Start_of_Block(Block+1)) / Parameters.TR);
        
        % Begin trial
        TrialOutput = struct;
        TrialOutput.TrialOnset = GetSecs;
        TrialOutput.TrialOffset = NaN;
        if Parameters.Eye_tracker
            TrialOutput.Eye = [];
        end

        % Call stimulation sequence
        CurrCondit = Parameters.Conditions(:,Reshuffling(Trial));
        eval(Parameters.Stimulus_Sequence);  % Custom script for each experiment!
              
        % Abort if Escape was pressed
        if ismember(KeyCodes.Escape, find(TrialOutput.Key)) || mean(TrialOutput.Key) == 1
            % Abort screen
            Screen('SelectStereoDrawBuffer', Win, 0);
            Screen('FillRect', Win, Parameters.Background, Rect);
            DrawFormattedText(Win, 'Experiment was aborted mid-block!', 'center', 'center', Parameters.Foreground); 
            if Parameters.Stereo > 0
                Screen('SelectStereoDrawBuffer', Win, 1);
                Screen('FillRect', Win, Parameters.Background, Rect);
                DrawFormattedText(Win, 'Experiment was aborted mid-block!', 'center', 'center', Parameters.Foreground); 
            end
            Screen('Flip', Win);
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
        
        % Reaction to response
        if exist(['.' filesep 'Feedback.m']) == 2
            Feedback;
        end
        TrialOutput.TrialOffset = GetSecs;
        
        % Record trial results   
        Results = [Results; TrialOutput];
    end
    
    % Clock after experiment
    End_of_Expmt = GetSecs;

    %% Save results of current block
    Screen('SelectStereoDrawBuffer', Win, 0);
    Screen('FillRect', Win, Parameters.Background, Rect);
    DrawFormattedText(Win, 'Saving data...', 'center', 'center', Parameters.Foreground); 
    if Parameters.Stereo > 0
        Screen('SelectStereoDrawBuffer', Win, 1);
        Screen('FillRect', Win, Parameters.Background, Rect);
        DrawFormattedText(Win, 'Saving data...', 'center', 'center', Parameters.Foreground); 
    end
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
Screen('SelectStereoDrawBuffer', Win, 0);
Screen('FillRect', Win, Parameters.Background, Rect);
DrawFormattedText(Win, 'Thank you!', 'center', 'center', Parameters.Foreground); 
if Parameters.Stereo > 0
    Screen('SelectStereoDrawBuffer', Win, 1);
    Screen('FillRect', Win, Parameters.Background, Rect);
    DrawFormattedText(Win, 'Thank you!', 'center', 'center', Parameters.Foreground); 
end
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
new_line;

