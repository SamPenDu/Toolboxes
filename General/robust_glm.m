function [bf21 prob_no_outliers] = robust_glm(y,x)

N = size(x,1);
rglm1 = spm_rglm(y, [x,ones(N,1)], 1);
rglm2 = spm_rglm(y, [x,ones(N,1)], 2);
bf21 = rglm2.fm - rglm1.fm;
prob_no_outliers = 1/(1+exp(bf21));

tb = exp(abs(bf21));
if tb > 1 && tb <= 3
    e = 'weak';
elseif tb > 3 && tb <= 20
    e = 'positive';
elseif tb > 20 && tb <= 150
    e = 'strong';
elseif tb > 150 
    e = 'very strong';
end
if bf21 > 0
    h = 'outlier';
else
    h = 'simple';
end

new_line;
disp(['There is ' e ' evidence supporting the ' h ' model.']);
