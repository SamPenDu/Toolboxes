function [P Ts Aci] = Simul_2ndLvl(A, ndraws, nxvals, nsubjs, nperms)

if nargin < 5
    nperms = 2000;  % Number of permutations
end

% Mean accuracy
mA = mean(A);
eA = sem(A);

% Observed t-value
[th tp tci tst] = ttest(A,0.5);
T = tst.tstat;

% Simulations
Ts = []; Ab = [];
for h = 1:nperms
    As= []; 
    for i = 1:nsubjs    
        for j = 1:nxvals
            As = [As; mean(CoinFlip(ndraws,0.5))];
        end
    end
    Ab = [Ab; mean(As)];
    [th tp tci tst] = ttest(As,0.5);
    t = tst.tstat;
    Ts = [Ts; t];
end

% Final data
P = mean(abs(Ts) >= abs(T));
Aci = prctile(Ab, [2.5 97.5]);

if nargout == 0
    % Plot histogram
    [n x] = ksdensity(Ts);
    plot(x,n,'k');
    hold on
    line([T T], ylim, 'color', 'r');
    set(gca,'fontsize',12);
    title([n2s(mA) ' +/- ' n2s(eA) ', p=' n2s(P) ', (' n2s(Aci(1)) '-' n2s(Aci(2)) ')']);
    xlabel('T-statistic');
    ylabel('Frequency');
end