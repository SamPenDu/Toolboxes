function [ff gof] = fitsigm(x, y)
% fits an ascending sigmoidal function to the data in y plotted against x

ftype = fittype('r_max*c^n/(c^n+c_50^n)+s', 'independent', 'c');
opts = fitoptions('Method','NonLinearLeastSquares', 'Lower', [0 0 -Inf -Inf], 'StartPoint', [50 1 100 50]);
[ff gof] = fit(x, y, ftype, opts);
