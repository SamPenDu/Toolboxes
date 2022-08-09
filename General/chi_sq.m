function [h,p,cq] = chi_sq(x)
% performs chi square test on the curves 
% from the data in the two rows of x

ind = [];

for i = 1:length(x)
    ind(i) = (x(1,i) - x(2,i))^2 / x(2,i);
end

curfig = figure;
plot(x');
set(gcf, 'Name', 'Chi-Square Goodness of Fit Analysis');
cq = sum(ind);
p = chi2pdf(cq, length(x)-1);
title(['Chi-Square = ' num2str(cq) ' ~ p = ' num2str(p)]);
k = waitforbuttonpress;
close(curfig);

if k 
    [fn pn] = uiputfile('*.txt');
    fid = fopen([pn fn],'w');
    fprintf(fid, '%s', ['Chi-Square = ' num2str(cq) ' ~ p = ' num2str(p)]);
    status = fclose(fid);
end

if p <= 0.05
    h = 1;
else
    h = 0;
end