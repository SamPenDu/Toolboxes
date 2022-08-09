function p1D = BayesTheorem(p1, p2, pD1, pD2)
%
% p1D = BayesTheorem(p1, p2, pD1, pD2)
%
% Returns the posterior probability of hypothesis 1 with the inputs:
%   p1, p2:     The prior probabilities of hypotheses 1 and 2 
%   pD1, pD2:   The likelihood i.e. the probability of the data given hypothesis 1 and 2
%

% Marginal likelihood i.e. probability of the data
pD = pD1 * p1 + pD2 * p2;

% Posterior of hypothesis 1
p1D = pD1 * p1 / pD; 