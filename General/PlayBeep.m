function PlayBeep(beep)
%PlayBeep(beep)
% Plays a beep defined by
%   beep = MakeBeep(600,0.15);

Snd('Open');
Snd('Play', beep);
Snd('Wait');
Snd('Quiet');
Snd('Close');
