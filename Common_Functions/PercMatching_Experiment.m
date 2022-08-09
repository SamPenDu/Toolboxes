function ExpmtDur = PercMatching_Experiment(Parameters)
%ExpmtDur = PercMatching_Experiment(Parameters)
%
% Runs a generic perceptual mapping psychophysics experiment. 
%%

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

%% Initialize randomness & keycodes
SetupRand;
SetupKeyCodes;

%% Mouse to start 
TrigStr = 'Click mouse to start (Right button to abort)...';    % Trigger string

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

%% Various variables
Results = [];
Start_of_Expmt = NaN;
Trials_per_Expmt = length(Parameters.Conditions) * Parameters.Number_of_Elements * Parameters.Number_of_Repeats; % Trials in experiment
% If conditions undefined
if ~isfield(Parameters, 'Conditions')
    Parameters.Conditions = 1;
end
Chance_Level = 1 / Parameters.Number_of_Elements; % Chance performance

%% Custom initialization
Screen('FillRect', Win, Parameters.Background, Rect);
DrawFormattedText(Win, 'Initialization - please stand by...', 'center', 'center', Parameters.Foreground); 
Screen('Flip', Win);
Initialization;

%% Standby screen
Screen('FillRect', Win, Parameters.Background, Rect);
DrawFormattedText(Win, [Parameters.Welcome '\n \n' Parameters.Instruction '\n \n' TrigStr], 'center', 'center', Parameters.Foreground); 
Screen('Flip', Win);
WaitSecs(0.1);
bk = waitformouse;

%% Abort if middle mouse was pressed
if find(bk) == 2
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
    return
end
Screen('FillRect', Win, Parameters.Background, Rect);
Screen('Flip', Win);

%% Run stimulus sequence 
Start_of_Expmt = GetSecs;
% Reshuffle conditions if more than one
Reshuffled_Conditions = Shuffle(repmat(Parameters.Conditions, 1, Parameters.Number_of_Elements * Parameters.Number_of_Repeats));
% Loop through trials
for Trial = 1 : Trials_per_Expmt   
    %% Begin trial
    % Trial data
    TrialOutput = struct;
    TrialOutput.TrialOnset = GetSecs;
    TrialOutput.TrialOffset = NaN;

    %% Signal in each element
    Elements = [randn * Parameters.Noise(1) + randn(Parameters.Number_of_Elements-1,1) * Parameters.Noise(2); 0]; % Randomised stimuli & the target
    % Sort to be either ascending or descending
    if rand > 0.5
        Elements = sort(Elements, 'ascend');
    else
        Elements = sort(Elements, 'descend');
    end
    % Set new starting position
    sx = round(rand * Parameters.Number_of_Elements);
    Elements = [Elements(sx+1:end); Elements(1:sx)];
    
    %% What is correct element?
    CorrElement = find(Elements == 0);
    TrialOutput.Target = CorrElement;

    %% Call stimulation sequence
    CurrCondit = Reshuffled_Conditions(Trial);
    TrialOutput.Condition = CurrCondit;
    Stimulus_Sequence; % Custom script for each experiment!

    %% Abort if Escape was pressed
    if TrialOutput.Key == 2
        % Abort screen
        Screen('FillRect', Win, Parameters.Background, Rect);
        DrawFormattedText(Win, 'Experiment was aborted mid-block!', 'center', 'center', Parameters.Foreground); 
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
        return
    end

    %% Record correctness of response
    TrialOutput.Correct = sum(Response == CorrElement); % Sum because could be more than one correct element

    %% Signal per element
    TrialOutput.Elements = Elements;

    %% End of trial
    TrialOutput.TrialOffset = GetSecs;
    % Record trial results   
    Results = [Results; TrialOutput];
end

%% Clock after experiment
End_of_Expmt = GetSecs;

%% Save results of current block
Screen('FillRect', Win, Parameters.Background, Rect);
DrawFormattedText(Win, 'Saving data...', 'center', 'center', Parameters.Foreground); 
Screen('Flip', Win);
save(['Results' filesep Parameters.Session_name]);

%% Farewell screen
Screen('FillRect', Win, Parameters.Background, Rect);
DrawFormattedText(Win, 'Thank you!', 'center', 'center', Parameters.Foreground); 
Screen('Flip', Win);
ShowCursor;
Screen('CloseAll');

%% Experiment duration
new_line;
ExpmtDur = End_of_Expmt - Start_of_Expmt;
ExpmtDurMin = floor(ExpmtDur/60);
ExpmtDurSec = mod(ExpmtDur, 60);
disp(['Experiment lasted ' n2s(ExpmtDurMin) ' minutes, ' n2s(ExpmtDurSec) ' seconds']);
new_line;

