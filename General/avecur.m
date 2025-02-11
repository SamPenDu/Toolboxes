function res = avecur(data, err)
%res = avecur(data, [err='SEM'])
%
% Returns a matrix res with the average value in data(:,2) for each unique
% value in data(:,1) and the associated error. The optional input err
% defines the error to be computed:
%   'SEM' = standard error of the mean
%   'StD' = standard deviation
%   '95CI' = bootstrapped 95% confidence interval (1000 iterations)

if nargin == 1
    err = 'SEM';
end

res = [];
X = unique(data(:,1))'; 
for sig = X
    pts_sig = find(data(:,1) == sig);
    curdat = data(pts_sig,2:end);
    if length(pts_sig) == 1
        if err == 2
            res = [res; curdat, zeros(2,length(curdat))];
        else
            res = [res; curdat, zeros(1,length(curdat))];
        end
    else
        rres = nanmean(curdat);
        for c = 1:size(curdat,2)
            if strcmpi(err, 'SEM')
                rres = [rres sqrt(nanvar(curdat(:,c))/length(find(~isnan(curdat(:,c)))))];
            elseif strcmpi(err, 'StD')
                rres = [rres nanstd(curdat(:,c))];
            elseif strcmpi(err, '95CI')
                bs = bootstrp(1000, @nanmean, (curdat(:,c)));
                rres = [rres prctile(bs, [2.5 97.5])];
            else
                error('Invalid error calculation!');
            end
        end
        res = [res; rres];
    end
end
res = [X' res];
