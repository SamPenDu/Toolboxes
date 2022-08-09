function ExpmtDur = PercMap_Experiment(Parameters, Emulate)
%ExpmtDur = PercMap_Experiment(Parameters, Emulate)
%
% Runs a generic perceptual mapping psychophysics experiment. 
%
% Emulate determines how the program is triggered:
%   (0 = scanner, 1 = keyboard, -1 = mouse)
%

% Default is without scanner!
if nargin < 2
    Emulate = 1;
end

% Go to folder of calling wrapper function
GoToCurrFunc; 

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
    TrigStr = 'Click left mouse button to start...\n(Middle or right button to abort)';    % Trigger string
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
[Win, Rect] = PsychImaging('OpenWindow', Parameters.Screen, Parameters.Background, Parameters.Resolution, 32, 2, Parameters.Stereo); 
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
CurrNoise = Parameters.Noise; % Noise to be added to signals
Start_of_Expmt = NaN;
% If fields for control experiments undefined
if ~isfield(Parameters, 'Bias')
    Parameters.Bias = zeros(Parameters.Number_of_Elements,1);
end
if ~isfield(Parameters, 'Widths')
    Parameters.Widths = zeros(Parameters.Number_of_Elements,1);
end
% If conditions undefined
if ~isfield(Parameters, 'Conditions')
    Parameters.Conditions = 1;
    Trials_per_Block = Parameters.Number_of_Elements * 5; % Trials in each block
else
    Trials_per_Block = Parameters.Number_of_Elements * length(Parameters.Conditions); % Trials in each block
end
% Chance performance
Chance_Level = 1 / Parameters.Number_of_Elements; 

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
if exist(['.' filesep 'Initialization.m']) == 2
    Initialization;
end

%% Setup trigger
if Emulate == 0
    SetupTrigger;
end

%% Loop through blocks
for Block = 0 : Parameters.Blocks_per_Expmt-1
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
    
    %% Abort if Escape was pressed
    if ismember(KeyCodes.Escape, find(bk)) | find(bk) == 2 | find(bk) == 3
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
    Screen('Flip', Win);

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
    WaitSecs(Parameters.Dummies * Parameters.TR);
    Start_of_Block(Block+1) = GetSecs;
    if isnan(Start_of_Expmt)
        Start_of_Expmt = Start_of_Block(Block+1);
    end

    %% Run stimulus sequence 
    % Reshuffle conditions if more than one
    Reshuffled_Conditions = Shuffle(repmat(Parameters.Conditions, 1, Trials_per_Block / length(Parameters.Conditions)));
    % Loop through trials
    for Trial = 1 : Trials_per_Block   
        %% Begin trial
        % Trial data
        TrialOutput = struct;
        TrialOutput.TrialOnset = GetSecs;
        TrialOutput.TrialOffset = NaN;
        if Parameters.Eye_tracker
            TrialOutput.Eye = [];
        end
        
        % Current volume
    	CurrVolume = ceil((GetSecs - Start_of_Block(Block+1)) / Parameters.TR);
        
        %% Signal in each element
        Elements = randn(Parameters.Number_of_Elements,1) * CurrNoise;
        TrialOutput.Noise = CurrNoise;
                
        %% What is correct element?
        if Parameters.Number_of_Elements == 2
            % With only 2 elements both should be randomised
            CorrElement = find(abs(Elements) == min(abs(Elements)));
        else
            % With more than 2 elements there is always a correct target
            CorrElement = ceil(rand*Parameters.Number_of_Elements);
            % Set correct element to zero
            Elements(CorrElement) = 0;
        end
        TrialOutput.Target = CorrElement;
        
        %% Call stimulation sequence
        CurrCondit = Reshuffled_Conditions(Trial);
        TrialOutput.Condition = CurrCondit;
        eval(Parameters.Stimulus_Sequence);  % Custom script for each experiment!
              
        %% Abort if Escape was pressed
        if ismember(KeyCodes.Escape, find(TrialOutput.Key)) | find(TrialOutput.Key) == 2 | find(TrialOutput.Key) == 3
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
        
        %% Record correctness of response
        TrialOutput.Correct = sum(Response == CorrElement); % Sum because could be more than one correct element
        
        %% Reaction to response
        if exist(['.' filesep 'Feedback.m']) == 2
            Feedback;
        end
                
        %% Signal per element
        TrialOutput.Elements = Elements;

        %% End of trial
        TrialOutput.TrialOffset = GetSecs;
        % Record trial results   
        Results = [Results; TrialOutput];
        
        %% Are we staircasing?
        if isfield(Parameters, 'Staircase')
            % After every 10th trial check performance
            if mod(Trial,10) == 0
                % Recent behavioural performance
                curcor = [Results.Correct]';
                curacc = sum(curcor(end-9:end));
                % Adjust the noise
                if curacc < Parameters.Staircase(3)
                    % Too low so make noise larger (easier)
                    CurrNoise = CurrNoise + Parameters.Staircase(1);
                elseif curacc > Parameters.Staircase(4)
                    % Too high so make noise smaller (harder)
                    CurrNoise = CurrNoise - Parameters.Staircase(1);
                end
                % Ensure noise stays within bounds
                if CurrNoise < Parameters.Staircase(1)
                    CurrNoise = Parameters.Staircase(1); % No zero noise
                elseif CurrNoise > Parameters.Staircase(2)
                    CurrNoise = Parameters.Staircase(2); % No noise beyond maximum
                end
            end
        end
    end
    
    %% Clock after experiment
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

