function [Strs Stats] = rm_anova2(Yy,nS,fn,ggc)
%
% !!! This function has become obsolete!
%
%[Stats Strs] = rm_anova2(Yy,nS,fn,ggc)
%
% Two-factor, within-subject repeated measures ANOVA.
% For designs with two within-subject factors.
%
% Parameters:
%    Yy         dependent variable (numeric) in a column vector
%    nS         number of subjects, if negative rows contain row-factor levels
%    fn         cell array with names of factors
%    ggc        optional, Greenhouse-Geisser is off if this is 1
%
% Returns:
%    Stats is a numeric array output with all stats  
%    Strs is the cell array output with texts
%
% Notes:
%    Program does not do any input validation, so it is up to you to make
%    sure that you have passed in the parameters in the correct form:
%
%       Y, S, F1, and F2 must be numeric vectors all of the same length.
%
%       There must be at least one value in Y for each possible combination
%       of S, F1, and F2 (i.e. there must be at least one measurement per
%       subject per condition).
%
%       If there is more than one measurement per subject X condition, then
%       the program will take the mean of those measurements.
%
% Aaron Schurger (2005.02.04)
%   Derived from Keppel & Wickens (2004) "Design and Analysis" ch. 18
%

if nargin < 3
    fn = {'Cols' 'Rows'};
end  

if nS < 0
    [Y,S,F1,F2] = anova_data(Yy,nS,1);
    nS = -nS;
else
    [Y,S,F1,F2] = anova_data(Yy,nS);
end
stats = cell(4,5);

F1_lvls = unique(F1);
F2_lvls = unique(F2);
Subjs = unique(S);

a = length(F1_lvls); % # of levels in factor 1
b = length(F2_lvls); % # of levels in factor 2
n = length(Subjs); % # of subjects

% hack to determine AxB epsilon (only for 2xn design)
if a == 2
    AxB = zeros(n,b);
    for i=1:b
        AxB(:,i) = Yy(1+n*(i-1):n*i,1)-Yy(1+n*(i-1):n*i,2);
    end
elseif b == 2
    AxB = Yy(1:n,:)-Yy(n+1:end,:);
end

INDS = cell(a,b,n); % this will hold arrays of indices
CELLS = cell(a,b,n); % this will hold the data for each subject X condition
MEANS = zeros(a,b,n); % this will hold the means for each subj X condition

% Calculate means for each subject X condition.
% Keep data in CELLS, because in future we may want to allow options for
% how to compute the means (e.g. leaving out outliers > 3stdev, etc...).
for i=1:a % F1
    for j=1:b % F2
        for k=1:n % Subjs
            INDS{i,j,k} = find(F1==F1_lvls(i) & F2==F2_lvls(j) & S==Subjs(k));
            CELLS{i,j,k} = Y(INDS{i,j,k});
            MEANS(i,j,k) = mean(CELLS{i,j,k});
        end
    end
end

% make tables (see table 18.1, p. 402)
AB = reshape(nansum(MEANS,3),a,b); % across subjects
AS = reshape(nansum(MEANS,2),a,n); % across factor 2
BS = reshape(nansum(MEANS,1),b,n); % across factor 1

A = nansum(AB,2); % sum across columns, so result is ax1 column vector
B = nansum(AB,1); % sum across rows, so result is 1xb row vector
S = nansum(AS,1); % sum across rows, so result is 1xs row vector
T = nansum(nansum(A)); % could sum either A or B or S, choice is arbitrary

% epsilon for Greenhouse-Geisser correction
if nargin > 3 & ggc == 1
    epsA = 1;
    epsB = 1;
    epsAB = 1;
else
    epsA = epsGG(AS');
    epsB = epsGG(BS');
    epsAB = epsGG(AB');
end

% degrees of freedom
dfA = (a-1)*epsA;
dfB = (b-1)*epsB;
dfAB = ((a-1)*(b-1))*epsAB; 
dfS = (n-1);
dfAS = ((a-1)*(n-1))*epsA;
dfBS = ((b-1)*(n-1))*epsB;
dfABS = ((a-1)*(b-1)*(n-1))*epsAB;

% bracket terms (expected value)
expA = nansum(A.^2)./(b*n);
expB = nansum(B.^2)./(a*n);
expAB = nansum(nansum(AB.^2))./n;
expS = nansum(S.^2)./(a*b);
expAS = nansum(nansum(AS.^2))./b;
expBS = nansum(nansum(BS.^2))./a;
expY = nansum(Y.^2);
expT = T^2 / (a*b*n);

% sums of squares
ssA = expA - expT;
ssB = expB - expT;
ssAB = expAB - expA - expB + expT;
ssS = expS - expT;
ssAS = expAS - expA - expS + expT;
ssBS = expBS - expB - expS + expT;
ssABS = expY - expAB - expAS - expBS + expA + expB + expS - expT;
ssTot = expY - expT;

% mean squares
msA = ssA / dfA;
msB = ssB / dfB;
msAB = ssAB / dfAB;
msS = ssS / dfS;
msAS = ssAS / dfAS;
msBS = ssBS / dfBS;
msABS = ssABS / dfABS;

% f statistic
fA = msA / msAS;
fB = msB / msBS;
fAB = msAB / msABS;

% p values
pA = 1-fcdf(fA,dfA,dfAS);
pB = 1-fcdf(fB,dfB,dfBS);
pAB = 1-fcdf(fAB,dfAB,dfABS);

% return values
if pA < 0.001 
    hA = 3;
    sfA = '***';
elseif pA < 0.01
    hA = 2; 
    sfA = ' **';
elseif pA < 0.05
    hA = 1; 
    sfA = ' * ';
else
    hA = 0; 
    sfA = ' - ';
end

if pB < 0.001
    hB = 3; 
    sfB = '***';
elseif pB < 0.01
    hB = 2; 
    sfB = ' **';
elseif pB < 0.05
    hB = 1; 
    sfB = ' * ';
else
    hB = 0; 
    sfB = ' - ';
end

if pAB < 0.001
    hAB = 3; 
    sfAB = '***';
elseif pAB < 0.01
    hAB = 2; 
    sfAB = ' **';
elseif pAB < 0.05
    hAB = 1; 
    sfAB = ' * ';
else
    hAB = 0; 
    sfAB = ' - ';
end

Strs = { [sfA ' ' fn{1} ': F(' num2str(dfA) ',' num2str(dfAS) ')=' num2str(fA) ', p=' num2str(pA)]; ...
         [sfB ' ' fn{2} ': F(' num2str(dfB) ',' num2str(dfBS) ')=' num2str(fB) ', p=' num2str(pB)]; ...
         [sfAB ' Int''n: F(' num2str(dfAB) ',' num2str(dfABS) ')=' num2str(fAB) ', p=' num2str(pAB)] };
     
Stats = [dfA dfAS fA pA; dfB dfBS fB pB; dfAB dfABS fAB pAB];     
