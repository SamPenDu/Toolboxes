function [Staircase, IsReversal] = UpdateStaircase(Condit, InStairs, StepSize, Jitter)
%[Staircase, IsReversal] = UpdateStaircase(Condit, InStairs, StepSize, [Jitter=[0 3]])
% 
% Updates the staircase for stimulus condition Condit. If the criterion for a 
% step are fulfilled, the Signal is changed accordingly. For a downwards staircase 
% (e.g. contrast-detection) the StepSize is negative. If the current step is a 
% reversal, the flag IsReversal is set.
%
% The optional input argument Jitter is a 1x2 vector & defines staircase jittering. 
% You can use this to prevent a 50% staircase from saturating at chance.
% 
%   Jitter(1) defines the probability that a given trial is jittered. 
%   Jitter(2) defines the number of ste sizes by which the current level is moved back 
%             to an easier level = -StepSize * Jitter(2) Jitter(2) defaults to 3 step sizes.
% 

if nargin < 4
    Jitter = [0 3];
end
if length(Jitter) == 1
    Jitter(2) = 3;
end

Staircase = InStairs;

IsReversal = 0;

if rand < Jitter(1)
    %% Jittered trial
    Staircase.Signal(Condit) = Staircase.Signal(Condit) - StepSize*Jitter(2)*sign(Staircase.Initial(Condit));
    if Staircase.Signal(Condit) < Staircase.Range(1)
        Staircase.Signal(Condit) = Staircase.Range(1);
    end    
    if Staircase.Signal(Condit) > Staircase.Range(2)
        Staircase.Signal(Condit) = Staircase.Range(2);
    end    
else
    %% Standard trial
    if Staircase.Correct(Condit) >= Staircase.UpDown(1)
        % Step up i.e. harder
        Staircase.Correct(Condit) = 0;
        Staircase.Incorrect(Condit) = 0;
        % Is this a reversal?
        if Staircase.Previous(Condit) ~= 1 
            IsReversal = 1;
            Staircase.Reversals(Condit) = Staircase.Reversals(Condit) + 1;
        end
        Staircase.Previous(Condit) = 1;
        Staircase.Signal(Condit) = Staircase.Signal(Condit) + StepSize;
        if Staircase.Signal(Condit) < Staircase.Range(1)
            Staircase.Signal(Condit) = Staircase.Range(1);
        end    
        if Staircase.Signal(Condit) > Staircase.Range(2)
            Staircase.Signal(Condit) = Staircase.Range(2);
        end    
    elseif Staircase.Incorrect(Condit) >= Staircase.UpDown(2)
        % Step down i.e. easier
        Staircase.Correct(Condit) = 0;
        Staircase.Incorrect(Condit) = 0;
        % Is this a reversal?
        if Staircase.Previous(Condit) ~= -1 
            IsReversal = 1;
            Staircase.Reversals(Condit) = Staircase.Reversals(Condit) + 1;
        end
        Staircase.Previous(Condit) = -1;
        Staircase.Signal(Condit) = Staircase.Signal(Condit) - StepSize;
        if Staircase.Signal(Condit) < Staircase.Range(1)
            Staircase.Signal(Condit) = Staircase.Range(1);
        end    
        if Staircase.Signal(Condit) > Staircase.Range(2)
            Staircase.Signal(Condit) = Staircase.Range(2);
        end    
    end
end

