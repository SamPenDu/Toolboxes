Parameters.Subj_ID = 'Test';
Parameters.Screen = 0;
Parameters.Resolution = [0 0 1920 1080];
Parameters.ViewDist = 67;
Parameters.Foreground=[0 0 0];  % Foreground colour
Parameters.Background=[127 127 127];    % Background colour
Parameters.FontSize = 15;   % Size of font
Parameters.FontName = 'Calibri';  % Font to use

Parameters.EyeTested = eye; %1=LE, 2=RE
if Parameters.EyeTested ==1
    Parameters.EyeTestedLab = 'left';
else
    Parameters.EyeTestedLab = 'right';
end
Parameters.FixationPos = Parameters.Resolution(3:4) / 2;
Parameters.FixationGreyDiam = 25;%50 25pixels means we miss the central +/-0.25deg    % [10 50]; Width of fixation spot/surrounding gap in pixels
Parameters.FixationWidth = 5;%10
Parameters.FixationLength = 25;%50 %25 pixels is about 0.5deg

[Win Rect] = Screen('OpenWindow', 0, Parameters.Background, Parameters.Resolution, 32);
Screen('TextFont', Win, Parameters.FontName);
Screen('TextSize', Win, Parameters.FontSize);
Screen('BlendFunction', Win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
HideCursor;

EyeLinkParamspRF;
InitialiseEyeLinkpRF; 

Eyelink('command','clear_screen %d',127);
Eyelink('command','draw_text %d %d %d %s', (Parameters.Resolution(3)/2),(Parameters.Resolution(4)/2),el.txtCol,'1st Calibration instruction');
calibresult = EyelinkDoTrackerSetup(el); %what runs the calibration, eyelink command
if calibresult==el.TERMINATE_KEY %checks whether you've pressed el.TERMINATE_KEY (key you pres to exit calibration)
    return
end

Screen('CloseAll');
ShowCursor;