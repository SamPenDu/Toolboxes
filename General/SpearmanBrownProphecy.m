function pr = SpearmanBrownProphecy(r,n)
% 
% pr = SpearmanBrownProphecy(r,n)
%
% Returns the predicted reliability pr for observed reliability r and the number of tests n.
%
  
pr = (n*r) / (1 + (n-1)*r);