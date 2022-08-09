function [s,ss] = myttest(x, ps)
%
% Performs t-test on the data in x
%
% If x is a 2-column matrix it compares columns otherwise compares it to ps, 
% unless ps is 1 in which case paired t-test between columns. If ps is a
% vector it performs a two-sample t-test between x and ps (in this case,
% the two sample sizes need not be the same).
%

if size(x,2) == 2  
    if ps == 1
        [~,p,~,stats] = ttest(x(:,1), x(:,2));
        t = 'Paired-sample';
        b = t1smpbf(stats.tstat, size(x,1));
    else
        [~,p,~,stats] = ttest2(x(:,1), x(:,2));
        t = 'Two sample';
        b = t2smpbf(stats.tstat, size(x,1), size(x,1));
    end
    m = ['M1=' num2str(round_decs(nanmean(x(:,1)),2)) ', M2=' num2str(round_decs(nanmean(x(:,2)),2))];
else
    if size(ps,1) > 1
        [~,p,~,stats] = ttest2(x, ps);
        t = 'Two sample';
        b = t2smpbf(stats.tstat, size(x,1), size(ps,1));
        m = ['M1=' num2str(round_decs(nanmean(x),2)) ', M2=' num2str(round_decs(nanmean(ps),2))];        
    else
        [~,p,~,stats] = ttest(x, ps);
        t = ['Single sample vs ' num2str(ps)];
        b = t1smpbf(stats.tstat, length(x));
        m = ['M=' num2str(round_decs(nanmean(x),2))];
    end
end


if p < 0.001
    sg = '***';
    s = [t ':   ' m ', t(' num2str(stats.df) ')=' num2str(round(stats.tstat,2)) ', p=' num2str(round(p,5)) ' ' sg ' ' evidence(b)];
elseif p < 0.01
    sg = '** ';
    s = [t ':   ' m ', t(' num2str(stats.df) ')=' num2str(round(stats.tstat,2)) ', p=' num2str(round(p,5)) ' ' sg ' ' evidence(b)];
elseif p < 0.05
    sg = ' * ';
    s = [t ':   ' m ', t(' num2str(stats.df) ')=' num2str(round(stats.tstat,2)) ', p=' num2str(round(p,5)) ' ' sg ' ' evidence(b)];
else
    sg = ' n.s. ';
    s = [t ':   ' m ', t(' num2str(stats.df) ')=' num2str(round(stats.tstat,2)) ', p=' num2str(round(p,5)) ' ' sg ' ' evidence(b)];
end

ss = ['t(' num2str(stats.df) ')=' num2str(round(stats.tstat,1)) ', p=' num2str(round(p,3)) ', BF_{10}=' num2str(round(b,2))];
