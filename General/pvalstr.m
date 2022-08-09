function rps = pvalstr(p, withspaces)
%
% rps = pvalstr(p, [withspaces=false])
%
% Returns a string to report p-values in text. The precision is up to four
% decimal points. Below that the nearest order of magnitude is reported.
% The optional input withspaces toggles whether there are spaces between
% the p, equals symbol, and the actual number (defaults to false).
%

if nargin < 2
    withspaces = false;
end

% Is p<0.0001?
if p < 0.0001
    if withspaces 
        rps = 'p < ';
    else
        rps = 'p<';
    end
    e = num2str(ceil(log10(p)));
    rps = [rps '10^' e];
else
    if withspaces 
        rps = 'p = ';
    else
        rps = 'p=';
    end
    rps = [rps sprintf('%1.4f', p)];
end