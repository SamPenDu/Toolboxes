%EyeLinkParamspRF
%April 2017

%% EyeLink Set up
elparam.expName      = 'Eye Calibration';     % experiment name.
elparam.eyeMvt       = 1;                     % control eye movement,                             0 = NO   , 1 = YES
% elparam.TEST         = sp.UseDummyMode;     % Dummy mode or not,                                0 = NO   , 1 = YES
elparam.viewEL       = 0;                     % View eye position                                 0 = NO   , 1 = YES
elparam.expStart     = 1;                     % Start of a recording exp                          0 = NO   , 1 = YES

elparam.calibFlag    = 0;                     % Luminance gamma linearisation calibration         0 = NO   , 1 = YES
elparam.calibType    = 2;                     % There is 2 types of gamma calibration             1 = Gray linearized;    2 = RGB linearized
elparam.mkVideo      = 0;                     % Make a video of one trial                         0 = NO   , 1 = YES
elparam.expTraining  = 0;                     % Training of the current experiment                0 = NO   , 1 = YES
elparam.feedbackTask = 0;                     % Training of the current experiment                0 = NO   , 1 = YES

% elparam.CalTarRadDeg = 0.25; %from Martin's code
elparam.CalTarRadPix = 13; % ~0.25 deg from above
% elparam.CalTarWidthDeg = 0.1;
elparam.CalTarWidthPix = 5; % approx 0.1 deg

elparam.timeCalibMin = 10; %every 10 mins it will initialise re-calibration
elparam.timeCalib = elparam.timeCalibMin*60; %converts to secs (system requirement)
elparam.timeFixSec = 5; %maximum time allowed for non-fixation during trial
% 
% elparam.FixRadDeg = 2;
elparam.FixRadPix = 100; % approx 2deg

elparam.MaxInvTrials = 5;


