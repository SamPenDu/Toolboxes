function bf10 = corrbf(r,n,s)
%
% bf10 = corrbf(r,n,s)
%
% Calculates JZS Bayes factor for correlation r and sample size n.
% This quantifies the evidence in favour of the alternative hypothesis.
% The optional input s determines if the test is two-sided (0 = default),
% or if it is testing positive (+1) or negative (-1) correlations only.

% Wagenmakers, Verhagen& Ly (2016) How to quantify the evidence for the absence of a correlation
%

if nargin < 3
    s = 0;
end

% Function to be integrated
F = @(rho,r,n) ((1-rho.^2).^((n-1)/2)) / ((1-rho.*r).^((2*n-3)/2));

% Calculate Bayes Factor
switch s
    case 0 
        bf10 = integral(@(rho) F(rho,r,n), -1, 1, 'ArrayValued', 1) / 2;
    case 1
        bf10 = integral(@(rho) F(rho,r,n),  0, 1, 'ArrayValued', 1);
    case -1
        bf10 = integral(@(rho) F(rho,r,n), -1, 0, 'ArrayValued', 1);
    otherwise
        error('Invalid tail specified for the test!');
end

%% Old code no longer used
% Updated after personal communication from EJW (old one didn't work with large N)
% F = @(g,r,n) exp(((n-2)./2).*log(1+g)+(-(n-1)./2).*log(1+(1-r.^2).*g)+(-3./2).*log(g)+-n./(2.*g));
% % Bayes factor calculation
% bf10 = sqrt((n/2)) / gamma(1/2) * integral(@(g) F(g,r,n),0,Inf);
