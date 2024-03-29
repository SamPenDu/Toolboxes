function Staircase = StaircaseTrial(Condit, InStairs, IsCorrect)
%Staircase = StaircaseTrial(Condit, InStairs, IsCorrect)
%
% Updates the trial counters of Staircase for condition Condit.
%

if ~isnan(IsCorrect)
    Staircase = InStairs;
    if IsCorrect
        Staircase.Correct(Condit) = Staircase.Correct(Condit) + 1;
    else
        Staircase.Incorrect(Condit) = Staircase.Incorrect(Condit) + 1;
    end
else
    StairCase = InStairs;
end