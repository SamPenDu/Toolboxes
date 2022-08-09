function [SnellenFt, SnellenM, MinAngRes] = LogMar2Snellen(LogMar)
%
% Snellen = LogMar2Snellen(LogMar, Units)
%
% Converts logMAR acuity into Snellen acuity.
%   SnellenFt is in Imperial units (feet), e.g. 20/20 vision
%   SnellenM is in metric units (meters), e.g. 6/6 vision
%   MinAngRes is the minimum angle of resolution in minutes of visual angle, e.g. 1 minute 
%

MinAngRes = 10^LogMar;
SnellenFt = ['20/' num2str(round(MinAngRes*20))];
SnellenM = ['6/' num2str(round(MinAngRes*6))];

