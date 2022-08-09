function [a b x] = sim_depcorr(rax_obs, rbx_obs, n)
%
% Simulates a data set with three variables a, b, and x where the
% correlation between a and x is rax_obs and between b and x is rbx_obs.
% The sample size is given by n.
%

% Correlation between a and x
rax = 1; 
while rax > rax_obs+.003 || rax < rax_obs-.003 
    xy = mvnrnd([0 0],[1 rax_obs; rax_obs 1], n); 
    rax = corr(xy(:,1), xy(:,2)); 
end
a = xy(:,1);
x = xy(:,2);

% Correlation between b and x
rbx = 1; 
while rbx > rbx_obs+.003 || rbx < rbx_obs-.003 
    xy = [randn(n,1) x]; 
    rbx = corr(xy(:,1), xy(:,2)); 
end
b = xy(:,1);