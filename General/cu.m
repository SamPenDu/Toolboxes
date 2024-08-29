% Clean up MatLab
close all;
clear all;
clear global all;
SetupRand;
clc;

% In case Psychtoolbox exists
try 
    Screen('Preference', 'SkipSyncTests', 1);
catch
end