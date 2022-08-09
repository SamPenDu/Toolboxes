function [h p F] = ftest(X)

% Numbers
n = size(X,1);  % Number of subjects/observations
g = size(X,2);  % Number of groups

% Means
m = mean(X);    % Group means
gm = mean(m);   % Grand mean

% Residuals
br = m - repmat(gm,1,g);    % Between-group residuals
wr = X - repmat(m,n,1);     % Within-group residuals

% Sums of squares
SSb = sum(n*(br.^2));    
SSw = sum(wr(:).^2);    

% Degrees of freedom
dfb = g-1;      
dfw = g*(n-1);   

% Mean squares
MSb = SSb / dfb;    
MSw = SSw / dfw;

F = MSb / MSw;
p = 1 - fcdf(F,dfb,dfw);
h = p < 0.05;