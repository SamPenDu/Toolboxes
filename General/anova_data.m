function [y s fc fr] = anova_data(x, n, o)
% Returns the column vectors for rm_anova2. Input is data x and the number of subjects n.
% If 3rd argument defined, rows contain levels of row factor,
% if undefined row cells contain individual subjects.

n = abs(n);
nr = size(x,1) / n;
nc = size(x,2);

s = []; fc = []; fr = [];

if nargin < 3
    for c = 1:nc
        for r = 1:nr
            s = [s 1:n];
            fr = [fr ones(1,n)*r];
        end
        fc = [fc ones(1,n*nr)*c];
    end
else
    for c = 1:nc
        for sn = 1:n
            fr = [fr 1:nr];
            s = [s ones(1,nr)*sn];
        end
        fc = [fc ones(1,n*nr)*c];
    end
end

s = s'; fc = fc'; fr = fr'; 
y = x(1:end)';

