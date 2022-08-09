function Res = Behavioural_Results(subj, twin)
%
% Res = Behavioural_Results(subj, [twin])
%
% Returns hit rates and false alarms from a scanning run.
%

if nargin < 2
    twin = 0.4;
end

resfiles = dir([subj '_*.mat']);
Res = struct;
Res.hr = [];
Res.fa = [];

for rf = 1:length(resfiles)
    load([resfiles(rf).name]);
    E = Behaviour.EventTime;
    E = E(1:end-1);

    R = Behaviour.ResponseTime;
    dR = [2*twin; diff(R)];
    dR = floor(dR/twin);
    if ~isempty(R)
        R = R(dR > 1);
    end
    
    Det = zeros(length(E),1); 
    for i = 1:length(E)
        rt = R - E(i);
        ct = find(rt < 0.5);
        if ~isempty(ct)
            R(ct(1)) = [];
            Det(i) = 1;
        end
    end

    Res.hr = [Res.hr sum(Det)/length(Det)];
    Res.fa = [Res.fa (length(Det)-sum(Det))/((Results(end).TrialOffset-Results(1).TrialOnset)/Parameters.Event_Duration)];
end