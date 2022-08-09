function Bars_Mapping_Dice(Parameters, Emulate)
%Bars_Mapping_Dice(Parameters, Emulate)
%
% Runs the drifting bar protocol for mapping population receptive fields.
% Uses a central gambling task to ensure fixation and arousal. (If you need
% to save the apertures, it must be done with the version without gambling.)
%

% Create the mandatory folders if not already present 
if ~exist([cd filesep 'Results'], 'dir')
    mkdir('Results');
end

%% Initialize randomness & keycodes
SetupRand;
SetupKeyCodes;

%% Behavioural data
Level = 18;
CurrDice = 0;
Winnings = 0;
KeyTime = -Inf;
Event = 0;

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

%% Initialize various variables
Results = [];

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
Drift_per_Vol = StimRect(3) / Parameters.Volumes_per_Trial;
BarPos = [0 : Drift_per_Vol : StimRect(3)-Drift_per_Vol] + (Rect(3)/2-StimRect(3)/2) + Drift_per_Vol/2;

%% Initialize circular Aperture
CircAperture = Screen('MakeTexture', Win, 127 * ones(Rect([4 3])));

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
    return;
end

%% Change font for task
Screen('TextFont', Win, 'Arial');
Screen('TextSize', Win, 8);

%% Dummy volumes
Screen('FillRect', CircAperture, [127 127 127]);    
Screen('FillOval', Win, [0 0 127], CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect));    
DrawFormattedText(Win, '###', 'center', Rect(4)/2-8, [255 255 255]); 
Screen('Flip', Win);
WaitSecs(Parameters.Dummies * Parameters.TR);
Start_of_Expmt = GetSecs;

%% Run stimulus sequence 
for Trial = 1 : length(Parameters.Conditions)
    % Begin trial
    TrialOutput = struct;
    TrialOutput.TrialOnset = GetSecs;
    TrialOutput.TrialOffset = NaN;

    %% Stimulation sequence
    CurrCondit = Parameters.Conditions(Trial);
    new_line; disp([Trial CurrCondit]);
    CurrVolume = 1; 
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
            Screen('FillRect', CircAperture, [127 127 127]);    
        else    
            SmoothRect(CircAperture, [127 127 127], [0 0 BarPos(CurrVolume)-Parameters.Bar_Width/2 Rect(4)], Parameters.Fringe);    
            SmoothRect(CircAperture, [127 127 127], [BarPos(CurrVolume)+Parameters.Bar_Width/2 0 Rect(3) Rect(4)], Parameters.Fringe);    
        end

        % Rotate background movie?
        BgdAngle = cos((GetSecs-TrialOutput.TrialOnset)/Parameters.TR * 2*pi) * Parameters.Sine_Rotation;

        % Draw movie frame
        Screen('DrawTexture', Win, BgdTextures(CurrStim), StimRect, CenterRect(StimRect, Rect), BgdAngle+CurrCondit-90);
        % Draw aperture (and save if desired)
        Screen('DrawTexture', Win, CircAperture, Rect, Rect, CurrCondit-90);
        % Draw fixation cross 
        SmoothOval(Win, Parameters.Background, CenterRect([0 0 Parameters.Fixation_Width(2) Parameters.Fixation_Width(2)], Rect), Parameters.Fringe);    
        if Event ~= 0 && GetSecs-KeyTime < 2*Parameters.Event_Duration
            % There is a message
            if Event == -1
                % Too much!
                Screen('FillOval', Win, [127 0 0], CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect));    
                DrawFormattedText(Win, '!!!', 'center', Rect(4)/2-8, [255 255 255]); 
            elseif Event == 2
                % Banked the money
                Screen('FillOval', Win, [0 127 0], CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect));    
                DrawFormattedText(Win, '£', 'center', Rect(4)/2-8, [0 0 0]); 
            elseif Event == 3
                % Perfect score!
                Screen('FillOval', Win, [255 127 0], CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect));    
                DrawFormattedText(Win, '£££', 'center', Rect(4)/2-8, [0 0 0]); 
            else
                % Rolled the die 
                Screen('FillOval', Win, [64 64 64], CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect));    
            end
        else
            % Display current level
            Screen('FillOval', Win, [64 64 64], CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect));    
            Screen('FillArc', Win, [0 0 127], CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect), 0, Level/18*360);
            Screen('FillArc', Win, [0 0 255], CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect), 0, CurrDice/18*360);
            DrawFormattedText(Win, n2s(Winnings), 'center', Rect(4)/2-8, [255 255 255]); 
            Event = 0;
        end
        % Flip screen
        Screen('Flip', Win);

        % Behavioural response
        if Event == 0
            [Keypr KeyTime Key] = KbCheck;
            if Keypr 
                Event = 1;  % Responded
            end
            if find(Key) == KeyCodes.Left
                D = ceil(rand*6);  % Rolling the die
                CurrDice = CurrDice + D;
                if CurrDice > Level
                    Event = -1;  % Too much!
                    CurrDice = 0;
                elseif CurrDice == Level
                    Event = 3;  % Perfect score!
                    Winnings = Winnings + CurrDice*2;
                    Level = Level + 1;
                    CurrDice = 0;
                    if Level > 18
                        Level = 18;
                    end
                end
            elseif find(Key) == KeyCodes.Right 
                if CurrDice > 0
                    Event = 2;  % Bank the money
                    Winnings = Winnings + CurrDice;
                    Level = CurrDice;  
                    CurrDice = 0;
                    if Level < 6
                        Level = 6;
                    end
                end
            end
        end

        TrialOutput.Key = Key;
        % Abort if Escape was pressed
        if find(Key) == KeyCodes.Escape
            % Change back font 
            Screen('TextFont', Win, Parameters.FontName);
            Screen('TextSize', Win, Parameters.FontSize);
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
            return;
        end
    
        % Determine current volume
        CurrVolume = floor((GetSecs - TrialOutput.TrialOnset - Slack) / Parameters.TR) + 1;
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

%%% REMOVE THIS IF YOU DON'T USE COGENT!!! %%%
if Emulate == 0
% Turn off Cogent
    stop_cogent;
end

%% Farewell screen
% Change back font 
Screen('TextFont', Win, Parameters.FontName);
Screen('TextSize', Win, Parameters.FontSize);
Screen('FillRect', Win, Parameters.Background, Rect);
DrawFormattedText(Win, ['In this run you won £' n2s(round_decs(Winnings/100, 2))], 'center', 'center', Parameters.Foreground); 
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

