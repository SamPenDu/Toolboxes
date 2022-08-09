function ps = Heteroscedasticity(x,y)
%
% ps = Heteroscedasticity(x,y)
%
% Tests a two-sample data set for heteroscedasticity using several tests.
%

p_w = TestHet(x,y,'-W');
p_bpk = TestHet(x,y,'-BPK');
p_sr = SpearmanTestHet(x,y);

% new_line;
% disp(['White''s test:               p = ' n2s(p_w)]);
% disp(['Breuch-Pagan-Koenker test:   p = ' n2s(p_bpk)]);
% disp(['Spearman''s Rho:             p = ' n2s(p_sr)]);

ps = [p_w p_bpk p_sr]';
