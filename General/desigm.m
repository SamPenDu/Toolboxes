function x = desigm(f, y)
% returns x for which sigmoidal function f generates y

x = rt((y-f.s) * f.c_50^f.n / (f.r_max - (y-f.s)), f.n);
