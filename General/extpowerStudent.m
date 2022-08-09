function x = extpowerStudent(t,df,c,alpha)
%EXTPOWERSTUDENT Exact power estimation of a performed Student's t test about mean(s).
% Estimates the exact statistical power of a performed Student's t test about mean(s).
% Here, according to Winer (1970) we use the exact power by the noncentral cumulative
% distribution function. It recalls you the statistical result of the test you should
% have arrived.
%
%   Syntax: function x = extpowerStudent(t,df,c,a) 
%      
%     Inputs:
%          t - Student's t statistic (this is considered the estimated 
%              noncentrality parameter) 
%         df - degrees of freedom
%          c - specified testing direction [1 = one-tailed(default);2 = two-tailed]
%      alpha - significance level (default = 0.05)
%
%     Outputs:
%          - Specified direction test
%          (Statistical result of the test you should have arrived)
%          - Power
%
%    Example: From the example 7.9 of Zar (1999, p.108), the exact estimation
%             of power of a one-sample t test for a two-tailed hypothesis 
%             (c = 2) with a  significance level = 0.05 (t = 2.7662, 
%             df = 11, c = 2).
%                                       
%    Calling on Matlab the function: 
%             extpowerStudent(2.7662,11,2)
%
%    Answer is:
%
%    It is a two-tailed hypothesis test.
%    (The null hypothesis was statistically significative.)
%    Power is: 0.71209
%
%    ans = 0.7121
%
%  Created by A. Trujillo-Ortiz, R. Hernandez-Walls and K. Barba-Rojo
%             Facultad de Ciencias Marinas
%             Universidad Autonoma de Baja California
%             Apdo. Postal 453
%             Ensenada, Baja California
%             Mexico.
%             atrujo@uabc.mx
%
%  March 2, 2009.
%  Copyrigth 2009
%
%  To cite this file, this would be an appropriate format:
%  Trujillo-Ortiz, A., R. Hernandez-Walls and K. Barba-Rojo. (2009). extpowerStudent:Exact power
%    estimation of a performed Student's t test about mean(s). A MATLAB file. [WWW document]
%    URL http://www.mathworks.com/matlabcentral/fileexchange/23184
%
%  References:
%  Winer, B. J. (1970), Statistical Principles in Experimental Design.
%           2nd ed. McGraw-Hill:NewYork.
%  Zar, J. H. (1999), Biostatistical Analysis. 4th. ed.   
%           New-Jersey:Upper Saddle River. p. 107-108,135-136,164.
%

if nargin < 4, 
    alpha = 0.05; %default
end 

if ~isscalar(alpha)
   error('POWERSTUDENT requires a scalar ALPHA value.');
end

if ~isnumeric(alpha) || isnan(alpha) || (alpha <= 0) || (alpha >= 1)
   error('POWERSTUDENT requires 0 < ALPHA < 1.');
end

if nargin < 3,
    c = 1; %default one-tailed 
end

if nargin < 2, 
    error('Requires at least two input arguments.'); 
end 

t = abs(t);
ncp = t; %estimated noncentrality parameter

if c == 1;
   disp('It is a one-tailed hypothesis test.');
   a = alpha;
   P = 1-tcdf(t,df);
   if P >= a;
      disp('(The null hypothesis was not statistically significative.)');
      disp('Recall that with such a result, what is important is to report the beta type II error.')
   else
      disp('(The null hypothesis was statistically significative.)');
      disp('Recall that with such a result, what is important is to report the power.')
   end  
   tp = nctcdf(tinv(1-a,df),df,ncp);
   x = 1 - tp;
   fprintf('Power is: %2.5f\n\n', x)
else c == 2;
   disp('It is a two-tailed hypothesis test.');
   a = alpha/2;
   P = 1-tcdf(t,df);
   if P >= a;
      disp('(The null hypothesis was not statistically significative.)');
      disp('Recall that with such a result, what is important is to report the beta type II error.')
   else      
      disp('(The null hypothesis was statistically significative.)');
      disp('Recall that with such a result, what is important is to report the power.')
   end      
   tp1 = nctcdf(-tinv(1-a,df),df,ncp);  %Power estimation.
   tp2 = nctcdf(tinv(1-a,df),df,ncp);
   x = 1 - tp2 + tp1;
   fprintf('Power is: %2.5f\n\n', x)
end

return,