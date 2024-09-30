% Clean up MatLab
close all
clear all
SetupRand;

% In case Psychtoolbox exists
try 
    Screen('Preference', 'SkipSyncTests', 1);
    pause(.1);
catch
end
clear ans
clc
