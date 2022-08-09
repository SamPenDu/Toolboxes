function tchnc(x)
% Returns a t-test of the percentages in x vs chance.

[h p c s] = ttest(x,50,0.05,'right'); 
new_line; 
disp(['(t(' n2s(s.df) ')=' n2s(s.tstat) ', p=' n2s(p) ')']); 
new_line;