function [chnc all_accus] = chance_classif(ndraws,xvals,sims)

if nargin < 3
    sims = 10000;
end

all_accus = [];

for i = 1:sims
    accu = [];
    for c = 1:xvals
        curr = CoinFlip(ndraws,0.5);
%         curr = rand(ndraws,1) < 0.5;
        accu = [accu; sum(curr)/length(curr)*100];
    end
    all_accus = [all_accus; mean(accu)];
end

chnc = [mean(all_accus), std(all_accus)];

if nargout == 0
    figure('Name', ['Chance distribution: ' num2str(ndraws) ' samples, ' num2str(xvals) ' cross-validations']);
    hold on;
    hist(all_accus, 5:5:95);
    xlim([0 100]);
    yl = ylim;
    line([chnc(1) chnc(1)], ylim, 'LineWidth', 2, 'Color', 'r');
    fill([chnc(1)-chnc(2) chnc(1)+chnc(2) chnc(1)+chnc(2) chnc(1)-chnc(2)], [0 0 yl(2) yl(2)], 'r', 'EdgeColor', 'none', 'FaceAlpha', 0.5);
    title([num2str(chnc(1)) ' +/- ' num2str(chnc(2))]);
    xlabel('Accuracy (%)');
    ylabel('Frequency');
end