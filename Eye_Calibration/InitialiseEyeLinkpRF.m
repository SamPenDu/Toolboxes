%InitialiseEyeLink
% Goal of the function :
% Initializes eyeLink-connection, creates edf-file
% and writes experimental parameters to edf-file
% ----------------------------------------------------------------------
% Input(s) :
% wPtr : window pointer.
% elparam : struct containing many constant configuration.
% ----------------------------------------------------------------------
% Output(s):
% el : eye-link structure.
% elparam : struct containing edfFileName
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 15 / 11 / 2011
% Project : CrowdedSac
% Version : 2.0
% ----------------------------------------------------------------------

%% Define EDF file name :
elparam.edffilename = strcat(Parameters.Subj_ID ,'.edf');


%% Modify different defaults settings :
el=EyelinkInitDefaults(Win);

el.backgroundcolour = 127;
el.msgfontcolour    = 0; %from LandoltAcuityInitialise code
el.imgtitlecolour   = 0;
el.targetbeep       = 1;
el.calibrationtargetcolour= 255;
el.displayCalResults = 1;
el.eyeimgsize=50;

% el.backgroundcolour = elparam.colBG;		
% el.foregroundcolour = wPtr.white;       
el.calibrationtargetsize=2;%elparam.calTargetRadVal;         % radius (pix) of calibration target (used in my modified version of EyelinkDrawCalTarget)
el.calibrationtargetwidth=0.5;%elparam.calTargetWidthVal;      % radius (pix) of inside bull's eye of calibration target (used in my modified version of EyelinkDrawCalTarget)
el.txtCol = 15;
el.bgCol  = 0; 
el.targetbeep = 1;              % put 0 if no sound desired

EyelinkUpdateDefaults(el);


% Initialization of the connection with the Eyelink Gazetracker. 
dummymode = 0;

if ~EyelinkInit(dummymode)
    fprintf('Eyelink Init aborted.\n');
    Eyelink('Shutdown');
    Screen('CloseAll');
    return;
end

%% open file to record data to
res = Eyelink('Openfile', elparam.edffilename);
if res~=0
    fprintf('Cannot create EDF file ''%s'' ', elparam.edffilename);
    Eyelink('Shutdown');
    Screen('CloseAll');
    return;
end

% Describe general information on the experiment :
Eyelink('command', 'add_file_preamble_text ''LandoltAcuityVFExperiment''');

% make sure we're still connected.
if Eyelink('IsConnected')~=1 
    fprintf('Not connected. exiting');
    Eyelink('Shutdown');
    Screen('CloseAll');
    return;
end

%% Set up tracker personal configuration :

angle = 0:pi/2:3*(pi/2); %0,90,180,270 deg

centX = round(Rect(3)/2);
centY = round(Rect(4)/2);

% compute calibration target locations
[cx1,cy1] = pol2cart(angle,0.5);
[cx2,cy2] = pol2cart(angle,0.5);

cx = round(Parameters.FixationPos(1) + Parameters.FixationPos(1)*[0 cx1 cx2]);
cy = round(Parameters.FixationPos(2) + Parameters.FixationPos(2)*[0 cy1 cy2]);

% start at center, select randomly, end at center
crp = randperm(4)+1;
c(1:2:12) = [cx(1) cx(crp) cx(1)];
c(2:2:12) = [cy(1) cy(crp) cy(1)];

% compute validation target locations (ca libration targets smaller radius)
[vx1,vy1] = pol2cart(angle,0.5);
[vx2,vy2] = pol2cart(angle,0.5);

vx = round(Parameters.FixationPos(1) + Parameters.FixationPos(1)*[0 vx1 vx2]);
vy = round(Parameters.FixationPos(2) + Parameters.FixationPos(2)*[0 vy1 vy2]);

% start at center, select randomly, end at center
vrp = randperm(4)+1;
v(1:2:12) = [vx(1) vx(vrp) vx(1)];
v(2:2:12) = [vy(1) vy(vrp) vy(1)];


Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, Rect(3)-1, Rect(4)-1);
Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, Rect(3)-1, Rect(4)-1);

Eyelink('command', 'screen_distance %ld %ld',Parameters.ViewDist*10,Parameters.ViewDist*10); %specify distance as mm_to_top and mm_to_bottom of monitor

Eyelink('command', 'recording_parse_type = GAZE'); %set to gaze rather than HREF or pupil coordinates

Eyelink('command', 'calibration_type = HV5');
Eyelink('command', 'generate_default_targets = NO');

Eyelink('command', 'randomize_calibration_order 0');
Eyelink('command', 'randomize_validation_order 0');
Eyelink('command', 'cal_repeat_first_target 0');
Eyelink('command', 'val_repeat_first_target 0');

Eyelink('command', 'calibration_samples=6');
Eyelink('command', 'calibration_sequence=0, 1, 2, 3, 4, 5'); %, 6, 7, 8, 9, 10, 11, 12, 13');
Eyelink('command', sprintf('calibration_targets = %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i',c)); %i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i',c));

Eyelink('command', 'validation_samples=6');
Eyelink('command', 'validation_sequence=0, 1, 2, 3, 4, 5');
Eyelink('command', sprintf('validation_targets = %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i',v));


%% Set parser
%Sets up columns of eyelink file
Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
Eyelink('command', 'file_sample_data = LEFT,RIGHT,GAZE,AREA');
Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,AREA');

Eyelink('command', 'heuristic_filter = 1 1');

%% Set pupil Tracking model in camera setup screen  (no = centroid. yes = ellipse)
Eyelink('command', 'use_ellipse_fitter =  NO');

%% set sample rate in camera setup screen
Eyelink('command', 'sample_rate = %d',1000);

%% Experiment descriptions into the edf-file :
Eyelink('message', 'START OF DESCRIPTIONS');
%Eyelink('message', '%s', fName);
Eyelink('message', '**SamPenDu Lab experiments**');
Eyelink('message', 'END OF DESCRIPTIONS');

% Test mode of eyelink connection :
status = Eyelink('IsConnected');
switch status
%     case -1
%         fprintf(1, '\tEyelink in dummymode.\n\n');
    case  0
        fprintf(1, '\tEyelink not connected.\n\n');
    case  1
        fprintf(1, '\tEyelink connected.\n\n');
end

% make sure we're still connected.
if Eyelink('IsConnected')~=1 
    fprintf('Not connected. exiting');
    Eyelink('Shutdown');
    Screen('CloseAll');
    return;
end

