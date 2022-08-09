function ps = Normality(x)
%
% ps = Normality(x)
%
% Tests a data set for normality using several tests.
%

[h_ks p_ks] = kstest(zscore(x));    % Kolmogorov-Smirnov tests against standard normal
[h_lt p_lt] = lillietest(x);    % Lilliefors test
[h_jb p_jb] = jbtest(x);   % Jarque-Bera test

if h_ks, h_ks = '*'; else h_ks = ' '; end
if h_lt, h_lt = '*'; else h_lt = ' '; end
if h_jb, h_jb = '*'; else h_jb = ' '; end

new_line;
disp(['Kolmogorov-Smirnov:         p = ' n2s(p_ks) ' ' h_ks]);
disp(['Lilliefors:                 p = ' n2s(p_lt) ' ' h_lt]);
disp(['Jarque-Bera:                p = ' n2s(p_jb) ' ' h_jb]);

ps = [p_ks p_lt p_jb]';