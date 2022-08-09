function [s cs] = anova(res, d)
% Calculate one-way analysis of variance for matrix res.

if nargin>1 & d 
    ds = 'on'; 
    clc; disp(' ');
    disp(res);
else
    ds = 'off';
end

[p, table, stats] = anova1(res, [], ds);

if nargin>1 & d 
    disp('Calculate one-way analysis of variance for matrix res.');
    disp(' ');
    disp(table);
    disp(['p = ', num2str(p)]);
end

cs = [];
if p < 0.05
    c = multcompare(stats, 'display', ds);
    if nargin>1 & d
        disp(' ');
        disp('Tukey hsd test of individual groups.');
        disp(' ');
        disp(c);
    end
    [cr,cc] = size(c);
    for i = 1:cr
        if (c(i,3) < 0) & (c(i,5) > 0)
            cs = cs;
        else    
            cs = [cs; c(i,1) c(i,2)];
        end
    end
end

s = ['F(' num2str(cell2mat(table(2,3))) ',' num2str(cell2mat(table(3,3))) ')=' num2str(cell2mat(table(2,5)), 3) ', p=' num2str(p, 3)];

k = 0;
if nargin>1 & d 
    pause; 
    close all;
    rd = size(res);
    for i = 1:rd(2)
        m(i) = mean(res( find(~isnan(res(:,i))) ,i)); 
        e(i) = sem(res( find(~isnan(res(:,i))) ,i)); 
    end
    resfig = figure;
    errorbar(1:rd(2), m, e, -e);
    set(gcf, 'Name', 'Group means +/- Sem');
    set(gcf, 'Units', 'normalized');
    set(gcf, 'Position', [0.05, 0.25, 0.4, 0.5]);

    statfig = figure; 
    if ~isempty(cs)
        scatter(cs(:,1), cs(:,2));
    end
    set(gcf, 'Name', '1-way Anova Stats');
    set(gcf, 'Units', 'normalized');
    set(gcf, 'Position', [0.5, 0.25, 0.4, 0.5]);
    title(s);
    axis([0 rd(2)+1 0 rd(2)+1]);
    set(gca, 'xtick', 0:rd(2));
    set(gca, 'ytick', 0:rd(2));
    k = waitforbuttonpress;
    close(resfig);
    close(statfig);
end

if k 
    [fn pn] = uiputfile('*.txt');
    fid = fopen([pn fn],'w');
    fprintf(fid, '%s', s);
    status = fclose(fid);
end
