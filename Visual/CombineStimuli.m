function OutStim = CombineStimuli(Stims)
%OutStim = CombineStimuli(Stims)
% Combines together all the stimulus structures in the array Stims,
% and returns a new stimulus structure with all the elements.
% If there are differences between the sigma and lambda parameters,
% it simply chooses those from the first stimulus in the array.
%

%initialize output stimulus structure
OutStim = struct;
OutStim.N = 0;
OutStim.X = [];
OutStim.Y = [];
OutStim.Theta = [];
OutStim.Collinear = [];
OutStim.IsContour = [];
OutStim.Contrast = [];
OutStim.Phase = [];

%select rendering parameters from first stimulus
OutStim.Sigma = [];
OutStim.Lambda = [];

%combine stimuli in the array
for i = 1 : length(Stims)
    OutStim.N = OutStim.N + Stims(i).N;
    OutStim.X = [OutStim.X; Stims(i).X];
    OutStim.Y = [OutStim.Y; Stims(i).Y];
    OutStim.Theta = [OutStim.Theta; Stims(i).Theta];
    OutStim.Collinear = [OutStim.Collinear; Stims(i).Collinear];
    OutStim.IsContour = [OutStim.IsContour; Stims(i).IsContour];
    OutStim.Contrast = [OutStim.Contrast; Stims(i).Contrast];
    OutStim.Phase = [OutStim.Phase; Stims(i).Phase];
    if length(Stims(i).Sigma) == 1
        Stims(i).Sigma = ones(Stims(i).N,1) * Stims(i).Sigma;
    end
    if length(Stims(i).Lambda) == 1
        Stims(i).Lambda = ones(Stims(i).N,1) * Stims(i).Lambda;
    end
    OutStim.Sigma = [OutStim.Sigma; Stims(i).Sigma];
    OutStim.Lambda = [OutStim.Lambda; Stims(i).Lambda];
end

