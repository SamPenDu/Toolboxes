function [Sum Avg] = Stats_of_Label(Stats, Label)
%[Sum Avg] = Stats_of_Label(Stats, Label)
%
% Returns the Sum and Average of the statistics in Stats (must be .asc),
% for the label file Label (must be .label).

S = Read_FreeSurfer([Stats '.asc']);
L = Read_FreeSurfer([Label '.label']);
if isnan(L)
    Sum = NaN;
    Avg = NaN;
    return
end

X = []; 
for v = 1:length(L(:,1)) 
    vx = S(:,1)==L(v,1); 
    X = [X; S(vx,5)]; 
end

Sum = round(sum(X));
Avg = mean(X);
