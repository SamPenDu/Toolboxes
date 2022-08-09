function [p2, ststr] = corrdiff_indvars(na,nb,ra,rb)
%Fisher r-to-z transformation
%Finds the significance of the difference between two correlation coefficients
%From http://vassarstats.net/rdiff.html

%% Calculation
raplus = ra + 1;
raminus = 1 - ra;
rbplus = rb + 1;
rbminus = 1 - rb;

za = (log(raplus) - log(raminus)) / 2;
zb = (log(rbplus) - log(rbminus)) / 2;

se = sqrt((1 / (na - 3)) + (1 / (nb - 3)));
z = (za - zb) / se;

z2 = abs(z);

p2 = (((((.000005383 * z2 + .0000488906) * z2 + .0000380036) * z2 + .0032776263) * z2 + .0211410061) * z2 + .049867347) * z2 + 1;

p2 = p2^-16;
p1 = p2 / 2;

ststr = ['z = ' num2str(z) ', p = ' num2str(p1)];

%% Display
if nargout == 0
    new_line;
    disp(ststr);
    new_line;
end
