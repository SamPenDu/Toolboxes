function Plot_Decoding_Accuracy(Method, Bars, Comps, Rois, Indiv)

if nargin < 5
    Indiv = true;
end

[p Ts Aci] = Simul_2ndLvl(.5, 2, 10, 8, 5000);

for c = 1:length(Comps)
    figure('Name', Comps{c}); 
%     maximize; 

    load([Method '_' Comps{c}]);
    if isfield(Results, 'Chance')
        Chance = repmat(Results.Chance, 1, 2);
    else
        Chance = [.5 .5];
    end
    
    A = []; E = []; S = []; As = []; Rs = [];
    for r = 1:length(Rois)
        Res = getfield(Results, Rois{r});
        if isinf(Bars)
            Bars = max(Res(:,1));
        end
        X = avecur(Res);
        X(isnan(X)) = 0;
        A = [A mean(Res(Res(:,1)==Bars,2))]; 
        E = [E sem(Res(Res(:,1)==Bars,2))]; 
        As = [As Res(Res(:,1)==Bars,2)];
        Rs = [Rs ones(length(Res(Res(:,1)==Bars,2)),1)*r];
        cs = ttest(Res(Res(:,1)==Bars,2), Chance(1), 0.025, 'right');
        if cs == 0
            cs = -1;
        end
        S = [S cs]; 
        if Bars == 0
            subplot(ceil(sqrt(length(Rois))), ceil(sqrt(length(Rois))), r);
            hold on; 
            line([0 max(X(:,1))], Chance, 'color', 'r', 'linewidth', 2);
            line([0 max(X(:,1))], [Aci(1) Aci(1)], 'color', 'r', 'linewidth', 2, 'linestyle', '--');
            line([0 max(X(:,1))], [Aci(2) Aci(2)], 'color', 'r', 'linewidth', 2, 'linestyle', '--');
            errorplot(X(:,1)',X(:,2)',X(:,3)',[0 0 0]); 
            ylim([0 1]);
            set(gca, 'fontname', 'calibri', 'fontsize', 15);
            ylabel('Decoding accuracy');
            title([Rois{r} ': ' Comps{c}]);
        end
    end
    
    if Bars > 0
        if (Indiv)
            bar(As'); hold on;
            colormap jet; 
            scatter(1:length(Rois), S*0.95, 120, 'k', '*');
            ylim([0 1]); 
        else
            barploterr(A, E, .02); hold on;
            scatter(1:length(Rois), S.*(A+E*2), 120, 'k', '*');
            colormap([.5 .5 .5]);
            ylim([.3 .8]); 
        end
        line([0 length(Rois)+1], Chance, 'color', 'r', 'linewidth', 2);
        line([0 max(X(:,1))], [Aci(1) Aci(1)], 'color', 'r', 'linewidth', 2, 'linestyle', '--');
        line([0 max(X(:,1))], [Aci(2) Aci(2)], 'color', 'r', 'linewidth', 2, 'linestyle', '--');
        xlim([0 length(Rois)+1]);
        set(gca, 'fontname', 'calibri', 'fontsize', 15);
        set(gca, 'xtick', 1:length(Rois), 'xticklabel', Rois);
        set(gca, 'ytick', 0:.1:1);
        ylabel('Decoding accuracy');
        title(Comps{c});
    else
        maximize;
    end    
end
