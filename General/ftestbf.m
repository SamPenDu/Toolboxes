function BF10 = ftestbf(F, df1, df2, n)
%
% Returns the Bayes Factor BF10 for an F-test using the procedure outlined 
% in Faulkenberry, 2018, Biometrical Letters. It requires the F-ratio, the
% degrees of freedom and the sample size n.
%

BF01 = sqrt(n.^df1 * (1 + F*df1/df2).^-n); % Support for null-hypothesis

BF10 = 1 ./ BF01; % Reciprocal of BF01
