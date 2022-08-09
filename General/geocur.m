function [res uerr lerr] = geocur(data)
%res = geocur(data)

cols = size(data,2)-1;

% calculate geometric mean
data(:,2:end) = log(data(:,2:end));
ave = avecur(data);
res = ave(:,1:cols+1);
res(:,2:end) = exp(res(:,2:end));

% calculate the error
uerr = ave(:,2:cols+1)+ave(:,2+cols:end);
lerr = ave(:,2:cols+1)-ave(:,2+cols:end);
uerr(:,2:end) = exp(uerr(:,2:end));
lerr(:,2:end) = exp(lerr(:,2:end));