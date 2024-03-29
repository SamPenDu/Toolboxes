function P1 = RMAOV1(Xin, F1name, lbc)
% P1 = RMAOV1(Xin, F1name, lbc)
%
% RMAOV1 Repeated Measures Single-Factor Analysis of Variance Test.
%
%   One-way repeated measures ANOVA is used to analyze the relationship 
%   between the independent variable and dependent variable when:(1) 
%   the dependent variable is quantitative in nature and is measured on
%   a level that at least approximates interval characteristics, (2) the
%   independent variable is within-subjects in nature, and (3) the
%   independent variable has three or more levels. It is an extension of
%   the correlated-groups t test, where the main advantage is controlling
%   the disturbance variables or individual differences that could influence
%   the dependent variable. 
%   In contrast to the independent groups ANOVA (between-subjects), the 
%   repeated measures procedure is generally more powerful (ie. leads to 
%   a greater likelihood of rejecting a false null hypothesis). Statistically,
%   this is the case because unwanted variability (error) due to individual 
%   differences among participants can be quantified and removed from the 
%   denominator of the F-ratio. This procedure requires fewer participants,
%   but it can give rise to research confounds such as order or practice effects
%   and participant bias.
%   As with the independent groups ANOVA, the total variability of a set of scores
%   is subdivided into sources that provide estimates of population variability. 
%   However with the repeated measures ANOVA, the process of subdividing the 
%   variability is a two step process outlined below.
%
%   Total variability broken down into two components:
%     -Between subjects. Variability in scores due to individual differences 
%      among participants. 
%     -Within subjects. 
%   The within subjects variability is subdivided into the following components: 
%     -Treatment. Variance among the treatment means (same as MS between in the 
%      independent groups ANOVA). 
%     -Residual. Leftover or unwanted error variability (can be thought of an 
%      inconsistencies in the effects of the treatments across the participants). 
%
%   The F-ratio is calculated by dividing the treatment variance (Mean Square 
%   treatment) by the residual variance (Mean Square residual). The numerator 
%   variance is the same as the MS between groups in the independent groups ANOVA
%   while the denominator variance (residual) is the leftover or unwanted variability
%   (error) but without variability due to individual differences among participants
%   which has been separated from it.
%
%   At first glance, type of experiment resambles a randomized complete block design.
%   However, the block design considering groups or sets of subjects (blocks), whereas 
%   the within-subjects design each of the n subjects are exposed to different experimental
%   conditions or trials.
%
%   Syntax: function [RMAOV1] = RMAOV1(X,alpha) 
%      
%     Inputs:
%          X - data matrix (Size of matrix must be n-by-3;dependent variable=column 1,
%              independent variable=column 2;subject=column 3). 
%      alpha - significance level (default = 0.05).
%    Outputs:
%            - Complete Analysis of Variance Table.
%            - Strength of the relationship.
%
%    Example: From the example given by Dr. Matthias Winkel* (http://www.stats.ox.ac.uk/~winkel/phs.html) 
%             on the relaxation therapy against migrane. Nine subjects participated in a relaxation therapy
%             with several weeks baseline frequency/duration recording (w1 and w2) and several weeks
%             therapy (w3 to w5). Its is of interest to test if there exist differences on the relaxation
%             therapy and within subjects with a significance level = 0.05.
%
%                                                           Weeks
%                             ------------------------------------------------------
%                              Subject        1       2       3       4       5
%                             ------------------------------------------------------
%                                  1         21      22       8       6       6
%                                  2         20      19      10       4       4           
%                                  3         17      15       5       4       5
%                                  4         25      30      13      12      17
%                                  5         30      27      13       8       6
%                                  6         19      27       8       7       4
%                                  7         26      16       5       2       5        
%                                  8         17      18       8       1       5       
%                                  9         26      24      14       8       9
%                             ------------------------------------------------------
%                                       
%     *Note: Due to a typing error, on the data table given by Dr. Winkel the value of subject 6 on week 4 must be 7, not 6.
%
%     Data matrix must be:
%     X=[21 1 1;20 1 2;17 1 3;25 1 4;30 1 5;19 1 6;26 1 7;17 1 8;26 1 9;
%     22 2 1;19 2 2;15 2 3;30 2 4;27 2 5;27 2 6;16 2 7;18 2 8;24 2 9;
%     8 3 1;10 3 2;5 3 3;13 3 4;13 3 5;8 3 6;5 3 7;8 3 8;14 3 9;
%     6 4 1;4 4 2;4 4 3;12 4 4;8 4 5;7 4 6;2 4 7;1 4 8;8 4 9;
%     6 5 1;4 5 2;5 5 3;17 5 4;6 5 5;4 5 6;5 5 7;5 5 8;9 5 9];
%
%     Calling on Matlab the function: 
%             RMAOV1(X)
%
%       Answer is:
%
%    The number of IV levels are: 5
%
%    The number of subjects are: 9
%
%    Analysis of Variance Table.
%    --------------------------------------------------------------
%    SOV            SS          df         MS         F        P
%    --------------------------------------------------------------
%    Subjects    486.711         8      60.839[     8.450   0.0000]
%    IV         2449.200         4     612.300     85.042   0.0000
%    Error       230.400        32       7.200
%    Total      3166.311        44
%    --------------------------------------------------------------
%    If the P result is smaller than 0.05
%    the Ho tested results statistically significant. Otherwise, it is not significative.
%    [Generally speaking, no Mean Square is computed for the variable "subjects" since it is assumed
%    that subjects differ from one another thus making a significance test of "subjects" superfluous.
%    However, for all the interested people we are given it anyway].
%
%    The percentage of the variability in the DV associated with the IV is 91.40
%    (After the effects of individual differences have been removed).
%  
%    Created by A. Trujillo-Ortiz, R. Hernandez-Walls and R.A. Trujillo-Perez
%               Facultad de Ciencias Marinas
%               Universidad Autonoma de Baja California
%               Apdo. Postal 453
%               Ensenada, Baja California
%               Mexico.
%               atrujo@uabc.mx
%
%    Copyright.July 21, 2004.
%
%    To cite this file, this would be an appropriate format:
%    Trujillo-Ortiz, A., R. Hernandez-Walls and R.A. Trujillo-Perez. (2004). RMAOV1:One-way repeated
%      measures ANOVA. A MATLAB file. [WWW document]. URL http://www.mathworks.com/matlabcentral/
%      fileexchange/loadFile.do?objectId=5576
%
%    References:
%    Huck, S. W. (2000), Reading Statistics and Research. 3rd. ed. 
%             New-York:Allyn&Bacon/Longman Pub. Chapter 16.
%    Winkel, M. http://www.stats.ox.ac.uk/~winkel/phs.html
%    Zar, J. H. (1999), Biostatistical Analysis. 4th. ed.   
%           New-Jersey:Upper Saddle River. p. 255-259.
%
% !!! Modified by Sam Schwarzkopf, June 2009 & May 2019 (adding Bayes Factors)

for k = 1:size(Xin,2)
    X((k-1)*size(Xin,1)+1:(k-1)*size(Xin,1)+size(Xin,1),:) = [Xin(:,k) k*ones(size(Xin,1),1) [1:size(Xin,1)]'];
end

alpha = 0.05; %(default)

if nargin < 3, 
    lbc = false;
end;

k = max(X(:,2));
s = max(X(:,3));
% fprintf('The number of IV levels are:%2i\n\n', k);
% fprintf('The number of subjects are:%2i\n\n', s);

%Analysis of Variance Procedure.
m=[];n=[];nn=[];A=[];
indice = X(:,2);
for i = 1:k
   Xe = find(indice==i);
   eval(['X' num2str(i) '=X(Xe,1);']);
   eval(['m' num2str(i) '=mean(X' num2str(i) ');'])
   eval(['n' num2str(i) '=length(X' num2str(i) ') ;'])
   eval(['nn' num2str(i) '=(length(X' num2str(i) ').^2);'])
   eval(['xm = m' num2str(i) ';'])
   eval(['xn = n' num2str(i) ';'])
   eval(['xnn = nn' num2str(i) ';'])
   eval(['x =(sum(X' num2str(i) ').^2)/(n' num2str(i) ');']);
   m=[m;xm];n=[n;xn];nn=[nn,xnn];A=[A,x];
end;

S=[];
indice=X(:,3);
for j=1:s
   Xe=find(indice==j);
   eval(['S' num2str(j) '=X(Xe,1);']);
   eval(['x =((sum(S' num2str(j) ').^2)/length(S' num2str(j) '));']);
   S=[S,x]; 
end

C = (sum(X(:,1)))^2/length(X(:,1)); %correction term
SST = sum(X(:,1).^2)-C; %total sum of squares
dfT = length(X(:,1))-1; %total degrees of freedom

SSA = sum(A)-C; %IV sum of squares
v1 = k-1; %IV degrees of freedom
SSS = sum(S)-C; %within-subjects sum of squares
v2 = s-1; %within-subjects degrees of freedom
SSE = SST-SSA-SSS; %error sum of squares
v3 = v1*v2; %error degrees of freedom
MSA = SSA/v1; %IV mean squares
MSS = SSS/v2; %within-subjects mean squares
MSE = SSE/v3; %error mean squares
F1 = MSA/MSE; %IV F-statistic
F2 = MSS/MSE; %within-subjects F-statistic

if nargin < 2
    F1name = 'Cols';
end
% new_line;

%% Sphericity assumed
%Probability associated to the F-statistics.
P1 = 1 - fcdf(F1,v1,v3);    
P2 = 1 - fcdf(F2,v2,v3);   
Bf = ftestbf(F1,v1,v3,s);

if P1 < alpha sigma1 = '  *'; else sigma1 = ''; end

if nargout < 1
    disp('Sphericity assumed');
    disp('--------------------------------------------------------------------');
    disp([' ' F1name ': F(' n2s(v1) ',' n2s(v3) ')=' n2s(round_decs(F1,2)) ', p=' n2s(round_decs(P1,5)) sigma1 ' ' evidence(Bf)]);
    new_line;
end

%% Lower-bound corrected
if (lbc)
    % Determine lower-bound epsilon
    eps1 = 1 / (k-1);

    %Probability associated to the F-statistics.
    P1 = 1 - fcdf(F1, v1*eps1, v3*eps1);    
    P2 = 1 - fcdf(F2, v2, v3);
    Bf = ftestbf(F1, v1*eps1, v3*eps1, s);

    if P1 < alpha sigma1 = '  *'; else sigma1 = ''; end

    if nargout < 1
        disp('Lower-bound corrected');
        disp('--------------------------------------------------------------------');
        disp([' ' F1name ': F(' n2s(v1*eps1) ',' n2s(v3*eps1) ')=' n2s(F1) ', p=' n2s(P1) ', e=' n2s(eps1) sigma1 ' ' evidence(Bf)]);
        new_line;
    end
end
