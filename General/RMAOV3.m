function P = RMAOV3(X, nS, F1name, F2name, F3name, lbc)
% P = RMAOV3(X, nS, F1name, F2name, F3name, lbc)
%
% RMAOV33 Three-way Analysis of Variance With Repeated Measures on Three Factors Test.
%
%   This is a three-factor analysis of variance design in which all factors are within-
%   subjects variables. In repeated measures designs, the same participants are used
%   in all conditions. This is like an extreme matching. This allows for reduction of 
%   error variance due to subject factors. Fewer participants can be used in an repeated
%   measures design. Repeated measures designs make it easier to see an effect of the
%   independent variable on the dependent variable (if there is such an effect).
%   Due that there is no way to obtain an independent estimate of error component, for
%   we have only one score per cell, and therefore no within-cell variance. However,
%   each of the interactions with subjects can be shown to serve as a denominator for 
%   an F ratio. So, each effect to be tested has its own error term. Thus every effect
%   is tested by the interaction of that effect with the Subject effect.
%   The SS components are divided up for this design in a way that is best illustrated
%   in a SS tree, as shown:
%                                         
%                                 /    
%                                | SSS  
%                                |           /        / 
%                                |          |        | SSA 
%                                |          |   A   < 
%                                |          |        | [SSEA]
%                                |          |         \         
%                                |          |    
%                                |          |         / 
%                                |          |        | SSB 
%                                |          |   B   < 
%                                |          |        | [SSEB]
%                                |          |         \         
%                                |          |    
%                                |          |         / 
%                                |          |        | SSC 
%                                |          |   C   < 
%                                |          |        | [SSEC]
%                                |          |         \         
%                                |          |    
%                        SSTO   <           |         /
%                                |          |        | SSAxB
%                                | SSW-S   <   AB   <  
%                                |          |        | [SSEAB]
%                                |          |         \
%                                |          | 
%                                |          |         / 
%                                |          |        | SSAxC
%                                |          |  AC   < 
%                                |          |        | [SSEAC]
%                                |          |         \
%                                |          |
%                                |          |         / 
%                                |          |        | SSBxC 
%                                |          |  BC   <
%                                |          |        | [SSEBC]
%                                |          |
%                                |          |         / 
%                                |          |        | SSAxBxC 
%                                |          | ABC   <
%                                |          |        | [SSEABC]
%                                 \          \        \         
%                    
%   Syntax: function [RMAOV33] = RMAOV33(X,alpha) 
%      
%     Inputs:
%          X - data matrix (Size of matrix must be n-by-5;dependent variable=column 1;
%              independent variable 1 (within subjects)=column 2;independent variable 2
%              (within subjects)=column 3; independent variable 3 (within subjects)
%              =column 4; subject=column 5). 
%      alpha - significance level (default = 0.05).
%    Outputs:
%            - Complete Analysis of Variance Table.
%
%    Example: From the example of Howell (2002, p. 510-512). There he examine driver behavior as a 
%             function of two times of day, three types of course, and three models of cars. There
%             were three drivers, each of whom drove each model on each course at each time of day.
%             The dependent variable is the number of steering errors as shown on the below table.
%             Use a significance level = 0.05.
%
%                                  T1                                           T2                     
%             -----------------------------------------------------------------------------------------
%                   C1             C2             C3             C1             C2             C3      
%             -----------------------------------------------------------------------------------------
%    Subject   M1   M2   M3   M1   M2   M3   M1   M2   M3   M1   M2   M3   M1   M2   M3   M1   M2   M3 
%    --------------------------------------------------------------------------------------------------
%       1      10    8    6    9    7    5    7    6    3    5    4    3    4    3    3    2    2    1  
%       2       9    8    5   10    6    4    4    5    2    4    3    3    4    2    2    2    3    2         
%       3       8    7    4    7    4    3    3    4    2    4    1    2    3    3    2    1    0    1 
%    --------------------------------------------------------------------------------------------------
%                                       
%     Data matrix must be:
%     X=[10 1 1 1 1;9 1 1 1 2;8 1 1 1 3;8 1 1 2 1;8 1 1 2 2;7 1 1 2 3;6 1 1 3 1;5 1 1 3 2;4 1 1 3 3;9 1 2 1 1;
%     10 1 2 1 2;7 1 2 1 3;7 1 2 2 1;6 1 2 2 2;4 1 2 2 3;5 1 2 3 1;4 1 2 3 2;3 1 2 3 3;7 1 3 1 1;4 1 3 1 2;
%     3 1 3 1 3;6 1 3 2 1;5 1 3 2 2;4 1 3 2 3;3 1 3 3 1;2 1 3 3 2;2 1 3 3 3;5 2 1 1 1;4 2 1 1 2;4 2 1 1 3;
%     4 2 1 2 1;3 2 1 2 2;1 2 1 2 3;3 2 1 3 1;3 2 1 3 2;2 2 1 3 3;4 2 2 1 1;4 2 2 1 2;3 2 2 1 3;3 2 2 2 1;
%     2 2 2 2 2;3 2 2 2 3;3 2 2 3 1;2 2 2 3 2;2 2 2 3 3;2 2 3 1 1;2 2 3 1 2;1 2 3 1 3;2 2 3 2 1;3 2 3 2 2;
%     0 2 3 2 3;1 2 3 3 1;2 2 3 3 2;1 2 3 3 3];
%
%     Calling on Matlab the function: 
%             RMAOV33(X)
%
%     Answer is:
%
%    The number of IV1 levels are: 2
%    The number of IV2 levels are: 3
%    The number of IV3 levels are: 3
%    The number of subjects are:    3
%
%    Three-Way Analysis of Variance With Repeated Measures on Three Factors (Within-Subjects) Table.
%    ---------------------------------------------------------------------------------------------------
%    SOV                             SS          df           MS             F        P      Conclusion
%    ---------------------------------------------------------------------------------------------------
%    Between-Subjects              24.111         2
%
%    Within-Subjects              316.167        51
%    IV1                          140.167         1        140.167       120.143   0.0082        S
%    Error(IV1)                     2.333         2          1.167
%
%    IV2                           56.778         2         28.389      1022.000   0.0000        S
%    Error(IV2)                     0.111         4          0.028
%
%    IV3                           51.444         2         25.722        92.600   0.0004        S
%    Error(IV3)                     1.111         4          0.278
%
%    IV1xIV2                        5.444         2          2.722         2.085   0.2397       NS
%    Error(IV1xIV2)                 5.222         4          1.306
%
%    IV1xIV3                       16.778         2          8.389        37.750   0.0025        S
%    Error(IV1xIV3)                 0.889         4          0.222
%
%    IV2xIV3                        8.778         4          2.194         3.762   0.0524       NS
%    Error(IV2-IV3)                 4.667         8          0.583
%
%    IV1xIV2xIV3                    2.778         4          0.694         1.923   0.2000       NS
%    Error(IV1-IV2-IV3)             2.889         8          0.361
%    ---------------------------------------------------------------------------------------------------
%    Total                        323.500        53
%    ---------------------------------------------------------------------------------------------------
%    With a given significance level of: 0.05
%    The results are significant (S) or not significant (NS).
%  
%    Created by A. Trujillo-Ortiz, R. Hernandez-Walls and F.A. Trujillo-Perez
%               Facultad de Ciencias Marinas
%               Universidad Autonoma de Baja California
%               Apdo. Postal 453
%               Ensenada, Baja California
%               Mexico.
%               atrujo@uabc.mx
%
%    Copyright.January 10, 2006.
%
%    ---Special thanks are given to Georgina M. Blanc from the Vision Center Laboratory of the 
%       Salk Institute for Biological Studies, La Jolla, CA, for encouraging us to create
%       this m-file-- 
%
%    To cite this file, this would be an appropriate format:
%    Trujillo-Ortiz, A., R. Hernandez-Walls and F.A. Trujillo-Perez. (2006). RMAOV33: Three-way 
%      Analysis of Variance With Repeated Measures on Three Factors Test. A MATLAB file. [WWW document].
%      URL http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=9638
%
%    References:
%    Howell, D. C. (2002), Statistical Methods for Psychology. 5th ed. 
%             Pacific Grove, CA:Duxbury Wadsworth Group.
%
% !!! Modified by Sam Schwarzkopf, June 2009

X = Rearr_rmaov3(X, nS);
alpha = 0.05; %(default)

if nargin < 6 
    lbc = false;
end;

a = max(X(:,2));
b = max(X(:,3));
c = max(X(:,4));
s = max(X(:,5));

% disp('   ');
% fprintf('The number of IV1 levels are:%2i\n', a);
% fprintf('The number of IV2 levels are:%2i\n', b);
% fprintf('The number of IV3 levels are:%2i\n', c);
% fprintf('The number of subjects are:   %2i\n\n', s);

CT = (sum(X(:,1)))^2/length(X(:,1));  %correction term
SSTO = sum(X(:,1).^2)-CT;  %total sum of squares
v16 = length(X(:,1))-1;  %total degrees of freedom
   
%procedure related to the subjects.
S = [];
indice = X(:,5);
for l = 1:s
    Xe = find(indice==l);
    eval(['S' num2str(l) '=X(Xe,1);']);
    eval(['x =((sum(S' num2str(l) ').^2)/length(S' num2str(l) '));']);
    S = [S,x];
end;

SSS = sum(S)-CT;
v15 = s-1;

%--Procedure Related to the Within-Subjects--
%procedure related to the IV1 (independent variable 1 [within-subjects]).
A = [];
indice = X(:,2);
for i = 1:a
    Xe = find(indice==i);
    eval(['A' num2str(i) '=X(Xe,1);']);
    eval(['x =((sum(A' num2str(i) ').^2)/length(A' num2str(i) '));']);
    A = [A,x];
end;
SSA = sum(A)-CT;  %sum of squares for the IV1
v1 = a-1;  %degrees of freedom for the IV1
MSA = SSA/v1;  %mean square for the IV1

%procedure related to the IV1-error.
EIV1 = [];
for i = 1:a
    for l = 1:s
        Xe = find((X(:,2)==i) & (X(:,5)==l));
        eval(['IV1S' num2str(i) num2str(l) '=X(Xe,1);']);
        eval(['x =((sum(IV1S' num2str(i) num2str(l) ').^2)/length(IV1S' num2str(i) num2str(l) '));']);
        EIV1 = [EIV1,x];
    end;
end;
SSEA = sum(EIV1)-sum(A)-sum(S)+CT;  %sum of squares of the IV1-error
v2 = v1*v15;  %degrees of freedom of the IV1-error
MSEA = SSEA/v2;  %mean square for the IV1-error

%F-statistics calculation.
F1 = MSA/MSEA;

%Probability associated to the F-statistics.
P1 = 1 - fcdf(F1,v1,v2);    

%procedure related to the IV2 (independent variable 2 [within-subjects]).
B = [];
indice = X(:,3);
for j = 1:b
    Xe = find(indice==j);
    eval(['B' num2str(j) '=X(Xe,1);']);
    eval(['x =((sum(B' num2str(j) ').^2)/length(B' num2str(j) '));']);
    B =[B,x];
end;
SSB = sum(B)-CT;  %sum of squares for the IV2
v3 = b-1;  %degrees of freedom for the IV2
MSB = SSB/v3;  %mean square for the IV2

%procedure related to the IV2-error.
EIV2 = [];
for j = 1:b
    for l = 1:s
        Xe = find((X(:,3)==j) & (X(:,5)==l));
        eval(['IV2S' num2str(j) num2str(l) '=X(Xe,1);']);
        eval(['x =((sum(IV2S' num2str(j) num2str(l) ').^2)/length(IV2S' num2str(j) num2str(l) '));']);
        EIV2 = [EIV2,x];
    end;
end;
SSEB = sum(EIV2)-sum(B)-sum(S)+CT;  %sum of squares of the IV2-error
v4 = v3*v15;  %degrees of freedom of the IV2-error
MSEB = SSEB/v4;  %mean square for the IV2-error

%F-statistics calculation.
F2 = MSB/MSEB;

%Probability associated to the F-statistics.
P2 = 1 - fcdf(F2,v3,v4);    

%procedure related to the IV3 (independent variable 3 [within-subject]).
C = [];
indice = X(:,4);
for k = 1:c
    Xe = find(indice==k);
    eval(['C' num2str(k) '=X(Xe,1);']);
    eval(['x =((sum(C' num2str(k) ').^2)/length(C' num2str(k) '));']);
    C =[C,x];
end;
SSC = sum(C)-CT;  %sum of squares for the IV3
v5 = c-1;  %degrees of freedom for the IV3
MSC = SSC/v5;  %mean square for the IV3

%procedure related to the IV3-error.
EIV3 = [];
for k = 1:c
    for l = 1:s
        Xe = find((X(:,4)==k) & (X(:,5)==l));
        eval(['IV3S' num2str(k) num2str(l) '=X(Xe,1);']);
        eval(['x =((sum(IV3S' num2str(k) num2str(l) ').^2)/length(IV3S' num2str(k) num2str(l) '));']);
        EIV3 = [EIV3,x];
    end;
end;
SSEC = sum(EIV3)-sum(C)-sum(S)+CT;  %sum of squares of the IV3-error
v6 = v5*v15;  %degrees of freedom of the IV3-error
MSEC = SSEC/v6;  %mean square for the IV3-error

%F-statistics calculation.
F3 = MSC/MSEC;

%Probability associated to the F-statistics.
P3 = 1 - fcdf(F3,v5,v6);    

%procedure related to the IV1 and IV2 (within- and within- subject).
AB = [];
for i = 1:a
    for j = 1:b
        Xe = find((X(:,2)==i) & (X(:,3)==j));
        eval(['AB' num2str(i) num2str(j) '=X(Xe,1);']);
        eval(['x =((sum(AB' num2str(i) num2str(j) ').^2)/length(AB' num2str(i) num2str(j) '));']);
        AB = [AB,x];
    end;
end;
SSAB = sum(AB)-sum(A)-sum(B)+CT;  %sum of squares of the IV1xIV2
v7 = v1*v3;  %degrees of freedom of the IV1xIV2
MSAB = SSAB/v7;  %mean square for the IV1xIV2

%procedure related to the IV1-IV2-error.
EIV12 = [];
for i = 1:a
    for j = 1:b
        for l = 1:s
            Xe = find((X(:,2)==i) & (X(:,3)==j) & (X(:,5)==l));
            eval(['IV12S' num2str(i) num2str(j) num2str(l) '=X(Xe,1);']);
            eval(['x =((sum(IV12S' num2str(i) num2str(j) num2str(l) ').^2)/length(IV12S' num2str(i) num2str(j) num2str(l) '));']);
            EIV12 = [EIV12,x];
        end;
    end;
end;
SSEAB = sum(EIV12)-sum(AB)-sum(EIV2)+sum(B)-sum(EIV1)+sum(A)+sum(S)-CT;
v8= v2*v3;  %degrees of freedom of the IV1-IV2-error
MSEAB = SSEAB/v8;  %mean square for the IV1-IV2-error

%F-statistics calculation
F4 = MSAB/MSEAB;

%Probability associated to the F-statistics.
P4 = 1 - fcdf(F4,v7,v8);

%procedure related to the IV1 and IV3 (between- and within- subject).
AC = [];
for i = 1:a
    for k = 1:c
        Xe = find((X(:,2)==i) & (X(:,4)==k));
        eval(['AC' num2str(i) num2str(k) '=X(Xe,1);']);
        eval(['x =((sum(AC' num2str(i) num2str(k) ').^2)/length(AC' num2str(i) num2str(k) '));']);
        AC = [AC,x];
    end;
end;
SSAC = sum(AC)-sum(A)-sum(C)+CT;  %sum of squares of the IV1xIV3
v9 = v1*v5;  %degrees of freedom of the IV1xIV3
MSAC = SSAC/v9;  %mean square for the IV1xIV3

%procedure related to the IV1-IV3-error.
EIV13 = [];
for i = 1:a
    for k = 1:c
        for l = 1:s
            Xe = find((X(:,2)==i) & (X(:,4)==k) & (X(:,5)==l));
            eval(['IV13S' num2str(i) num2str(k) num2str(l) '=X(Xe,1);']);
            eval(['x =((sum(IV13S' num2str(i) num2str(k) num2str(l) ').^2)/length(IV13S' num2str(i) num2str(k) num2str(l) '));']);
            EIV13 = [EIV13,x];
        end;
    end;
end;
SSEAC = sum(EIV13)-sum(AC)-sum(EIV3)+sum(C)-sum(EIV1)+sum(A)+sum(S)-CT;
v10 = v2*v5;  %degrees of freedom of the IV1-IV3-error
MSEAC = SSEAC/v10;  %mean square for the IV1-IV3-error

%F-statistics calculation
F5 = MSAC/MSEAC;

%Probability associated to the F-statistics.
P5 = 1 - fcdf(F5,v9,v10);

%procedure related to the IV2 and IV3 (within- and within- subject).
BC = [];
for j = 1:b
    for k = 1:c
        Xe = find((X(:,3)==j) & (X(:,4)==k));
        eval(['BC' num2str(j) num2str(k) '=X(Xe,1);']);
        eval(['x =((sum(BC' num2str(j) num2str(k) ').^2)/length(BC' num2str(j) num2str(k) '));']);
        BC = [BC,x];
    end;
end;
SSBC = sum(BC)-sum(B)-sum(C)+CT;  %sum of squares of the IV2xIV3
v11 = v3*v5;  %degrees of freedom of the IV2xIV3
MSBC = SSBC/v11;  %mean square for the IV2xIV3

%procedure related to the IV2-IV3-error.
EIV23 = [];
for j = 1:b
    for k = 1:c
        for l = 1:s
            Xe = find((X(:,3)==j) & (X(:,4)==k) & (X(:,5)==l));
            eval(['IV23S' num2str(j) num2str(k) num2str(l) '=X(Xe,1);']);
            eval(['x =((sum(IV23S' num2str(j) num2str(k) num2str(l) ').^2)/length(IV23S' num2str(j) num2str(k) num2str(l) '));']);
            EIV23 = [EIV23,x];
        end;
    end;
end;
SSEBC = sum(EIV23)-sum(BC)-sum(EIV3)+sum(C)-sum(EIV2)+sum(B)+sum(S)-CT;
v12 = v4*v5;  %degrees of freedom of the IV2-IV3-error
MSEBC = SSEBC/v12;  %mean square for the IV2-IV3-error

%F-statistics calculation
F6 = MSBC/MSEBC;

%Probability associated to the F-statistics.
P6 = 1 - fcdf(F6,v11,v12);

%procedure related to the IV1, IV2 and IV3 (within, within- and within- subject).
ABC = [];
for i = 1:a
    for j = 1:b
        for k = 1:c
            Xe = find((X(:,2)==i) & (X(:,3)==j) & (X(:,4)==k));
            eval(['AB' num2str(i) num2str(j) num2str(k) '=X(Xe,1);']);
            eval(['x =((sum(AB' num2str(i) num2str(j) num2str(k) ').^2)/length(AB' num2str(i) num2str(j) num2str(k) '));']);
            ABC = [ABC,x];
        end;
    end;
end;
SSABC = sum(ABC)+sum(A)+sum(B)+sum(C)-sum(AB)-sum(AC)-sum(BC)-CT;  %sum of squares of the IV1xIV2xIV3
v13 = v1*v3*v5;  %degrees of freedom of the IV1xIV2xIV3
MSABC = SSABC/v13;  %mean square for the IV1xIV2xIV3

%procedure related to the IV1-IV2-IV3-error.
EIV123 = [];
for i = 1:a
    for j = 1:b
        for k = 1:c
            for l = 1:s
                Xe = find((X(:,2)==i) &(X(:,3)==j) & (X(:,4)==k) & (X(:,5)==l));
                eval(['IV123S' num2str(i) num2str(j) num2str(k) num2str(l) '=X(Xe,1);']);
                eval(['x =((sum(IV123S' num2str(i) num2str(j) num2str(k) num2str(l) ').^2)/length(IV123S' num2str(i) num2str(j) num2str(k) num2str(l) '));']);
                EIV123 = [EIV123,x];
            end;
        end;
    end;
end;
SSEABC = sum(EIV123)-sum(ABC)-sum(EIV23)+sum(BC)-sum(EIV13)+sum(AC)+sum(EIV3)-sum(C)-sum(EIV12)+sum(AB)+sum(EIV2)-sum(B)+sum(EIV1)-sum(A)-sum(S)+CT;  %sum of squares of the IV1-IV2-IV3-error
v14 = v2*v3*v5;  %degrees of freedom of the IV1-IV2-IV3-error
MSEABC = SSEABC/v14;  %mean square for the IV1-IV2-IV3-error

%F-statistics calculation
F7 = MSABC/MSEABC;

%Probability associated to the F-statistics.
P7 = 1 - fcdf(F7,v13,v14);

SSWS = SSA+SSEA+SSB+SSEB+SSC+SSEC+SSAB+SSEAB+SSAC+SSAC+SSEAC+SSBC+SSEBC+SSABC+SSEABC;
vWS = v1+v2+v3+v4+v5+v6+v7+v8+v9+v10+v11+v12+v13+v14;


if nargin < 3
    F1name = 'Rows';
    F2name = 'Cols';
    F3name = 'Lvls';
end
new_line;

%% Sphericity assumed
if P1 < alpha sigma1 = '  *'; else sigma1 = ''; end
if P2 < alpha sigma2 = '  *'; else sigma2 = ''; end
if P3 < alpha sigma3 = '  *'; else sigma3 = ''; end
if P4 < alpha sigma4 = '  *'; else sigma4 = ''; end
if P5 < alpha sigma5 = '  *'; else sigma5 = ''; end
if P6 < alpha sigma6 = '  *'; else sigma6 = ''; end
if P7 < alpha sigma7 = '  *'; else sigma7 = ''; end

if nargout < 1
    disp('Sphericity assumed');
    disp('--------------------------------------------------------------------');
    disp([' ' F1name ': F(' n2s(v1) ',' n2s(v2) ')=' n2s(round_decs(F1,2)) ', p=' n2s(round_decs(P1,5)) sigma1]);
    disp([' ' F2name ': F(' n2s(v3) ',' n2s(v4) ')=' n2s(round_decs(F2,2)) ', p=' n2s(round_decs(P2,5)) sigma2]);
    disp([' ' F3name ': F(' n2s(v5) ',' n2s(v6) ')=' n2s(round_decs(F3,2)) ', p=' n2s(round_decs(P3,5)) sigma3]);
    disp([' ' F1name ' x ' F2name ': F(' n2s(v7) ',' n2s(v8) ')=' n2s(round_decs(F4,2)) ', p=' n2s(round_decs(P4,5)) sigma4]);
    disp([' ' F1name ' x ' F3name ': F(' n2s(v9) ',' n2s(v10) ')=' n2s(round_decs(F5,2)) ', p=' n2s(round_decs(P5,5)) sigma5]);
    disp([' ' F2name ' x ' F3name ': F(' n2s(v11) ',' n2s(v12) ')=' n2s(round_decs(F6,2)) ', p=' n2s(round_decs(P6,5)) sigma6]);
    disp([' ' F1name ' x ' F2name ' x ' F3name ': F(' n2s(v13) ',' n2s(v14) ')=' n2s(round_decs(F7,2)) ', p=' n2s(round_decs(P7,5)) sigma7]);
    new_line;
end

%% Lower-bound corrected
if (lbc)
    % Determine lower-bound epsilon
    eps1 = 1 / (a-1);
    eps2 = 1 / (b-1);
    eps3 = 1 / (c-1);
    eps4 = 1 / (max([a b])-1);
    eps5 = 1 / (max([a c])-1);
    eps6 = 1 / (max([b c])-1);
    eps7 = 1 / (max([a b c])-1);

    %Probability associated to the F-statistics.
    P1 = 1 - fcdf(F1, v1*eps1, v2*eps1);    
    P2 = 1 - fcdf(F2, v3*eps2, v4*eps2);    
    P3 = 1 - fcdf(F3, v5*eps3, v6*eps3);    
    P4 = 1 - fcdf(F4, v7*eps4, v8*eps4);    
    P5 = 1 - fcdf(F5, v9*eps5, v10*eps5);    
    P6 = 1 - fcdf(F6, v11*eps6, v12*eps6);    
    P7 = 1 - fcdf(F7, v13*eps7, v14*eps7);    

    if P1 < alpha sigma1 = '  *'; else sigma1 = ''; end
    if P2 < alpha sigma2 = '  *'; else sigma2 = ''; end
    if P3 < alpha sigma3 = '  *'; else sigma3 = ''; end
    if P4 < alpha sigma4 = '  *'; else sigma4 = ''; end
    if P5 < alpha sigma5 = '  *'; else sigma5 = ''; end
    if P6 < alpha sigma6 = '  *'; else sigma6 = ''; end
    if P7 < alpha sigma7 = '  *'; else sigma7 = ''; end

    if nargout < 1
        disp('Lower-bound corrected');
        disp('--------------------------------------------------------------------');
        disp([' ' F1name ': F(' n2s(v1*eps1) ',' n2s(v2*eps1) ')=' n2s(F1) ', p=' n2s(P1) ', e=' n2s(eps1) sigma1]);
        disp([' ' F2name ': F(' n2s(v3*eps2) ',' n2s(v4*eps2) ')=' n2s(F2) ', p=' n2s(P2) ', e=' n2s(eps2) sigma2]);
        disp([' ' F3name ': F(' n2s(v5*eps3) ',' n2s(v6*eps3) ')=' n2s(F3) ', p=' n2s(P3) ', e=' n2s(eps3) sigma3]);
        disp([' ' F1name ' x ' F2name ': F(' n2s(v7*eps4) ',' n2s(v8*eps4) ')=' n2s(F4) ', p=' n2s(P4) ', e=' n2s(eps4) sigma4]);
        disp([' ' F1name ' x ' F3name ': F(' n2s(v9*eps5) ',' n2s(v10*eps5) ')=' n2s(F5) ', p=' n2s(P5) ', e=' n2s(eps5) sigma5]);
        disp([' ' F2name ' x ' F3name ': F(' n2s(v11*eps6) ',' n2s(v12*eps6) ')=' n2s(F6) ', p=' n2s(P6) ', e=' n2s(eps6) sigma6]);
        disp([' ' F1name ' x ' F2name ' x ' F3name ': F(' n2s(v13*eps7) ',' n2s(v14*eps7) ')=' n2s(F7) ', p=' n2s(P7) ', e=' n2s(eps7) sigma7]);
        new_line;
    end
end

P = [P1 P2 P3 P4 P5 P6 P7];