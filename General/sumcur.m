function res = sumcur(data)
%res = sumcur(data)

res = [];
X = unique(data(:,1))';
for sig = X
    pts_sig = find(data(:,1) == sig);
    curdat = data(pts_sig,2:end);
    if length(pts_sig) == 1
        res = [res; curdat, zeros(1,length(curdat))];
    else
        res = [res; nansum(curdat)]; 
    end
end
res = [X' res];
