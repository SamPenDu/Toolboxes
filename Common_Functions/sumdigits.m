function y = sumdigits(n)
%Returns the sum of the digits of n.

if ~isempty(n)
    s = num2str(n);
    ss = [];
    for i=1:length(s)
        ss = [ss s(i) ' '];
    end
    ns = str2num(ss);
    y = sum(ns);
else
    y = [];
end
