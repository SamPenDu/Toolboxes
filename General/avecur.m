function res = avecur(data)
%res = avecur(data)

res = [];
X = unique(data(:,1))'; 
for sig = X
    pts_sig = find(data(:,1) == sig);
    curdat = data(pts_sig,2:end);
    if length(pts_sig) == 1
        res = [res; curdat, zeros(1,length(curdat))];
    else
        rres = nanmean(curdat);
        for c = 1:size(curdat,2)
            rres = [rres sqrt(nanvar(curdat(:,c))/length(find(~isnan(curdat(:,c)))))];
        end
        res = [res; rres];
    end
end
res = [X' res];
