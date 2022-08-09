function [signif corP] = HolmBonf(Ps, alpha)
% [signif corP] = HolmBonf(Ps, [alpha = 0.05])
%
% Returns a vector tagging each p-value in Ps that is significant when
%  using the Holm-Bonferroni method for multiple comparison correction.
%  The optional input alpha defines the alpha level to use.
%  The second output corP contains the corrected p-value.
%

if nargin < 2
    alpha = 0.05;
end

n = length(Ps); % Number of hypotheses
sPs = sort(Ps); % Sorted p-values

% Loop thru hypotheses
keep_rejecting = true; 
corP = 0;
x = 1; 
while keep_rejecting
    p = alpha / (n+1-x);
    if sPs(x) < p
        corP = p;
    else
        keep_rejecting = false;
    end
    x = x + 1;
end

% Significant p-values
signif = Ps < corP;