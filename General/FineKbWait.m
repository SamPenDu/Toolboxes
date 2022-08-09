function [kp t k] = FineKbWait(UntilWhen)
%
% [kp t k] = FineKbWait([UntilWhen])
%
% Waits for keypress. Similar functionality as KbCheck but is checking with 
% a finer temporal resolution for reaction time measurements. The optional
% defines the time until when the function waits. This uses GetSecs.
%

if nargin == 0
    UntilWhen = Inf;
end

kp = 0;
t = 0;
k = zeros(1,256);

while GetSecs < UntilWhen
    [kp t k] = KbCheck;
    if kp
        return;
    end
end