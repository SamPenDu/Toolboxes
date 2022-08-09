function anova2w(x, y, d)
% Calculate two-way analysis of variance for matrix x 
% with y groups in the row factors (columns = col factor).

clc; 
if d 
    ds = 'on'; 
else
    ds = 'off';
end

%x1 = x groups; y2 = number rows per y group
[y2 x1] = size(x);
y2 = y2 / y;    %number of row elements per group

disp('Calculate two-way analysis of variance for matrix res.');
disp(' ');
xarr = arr2vec(x);  %arrange as a single vector

%construct group array
g1 = [];
g2 = [];
for i = 1:x1
    g1 = [g1 ones(1, y2*y)*i];
    for ii = 1:y
        for iii = 1:y2
            g2 = [g2; char(32+ii)];
        end
    end
end

g = {g1 g2};
[p, table, stats] = anovan(xarr, g, 'model', 'full', 'display', ds);
disp(table);

s = {['Col:  F(' num2str(cell2mat(table(2,3))) ',' num2str(cell2mat(table(5,3))) ')=' num2str(cell2mat(table(2,6)), 3) ', p=' num2str(p(1), 3)]; ...
     ['Row:  F(' num2str(cell2mat(table(3,3))) ',' num2str(cell2mat(table(5,3))) ')=' num2str(cell2mat(table(3,6)), 3) ', p=' num2str(p(2), 3)]; ...
     ['Int:  F(' num2str(cell2mat(table(4,3))) ',' num2str(cell2mat(table(5,3))) ')=' num2str(cell2mat(table(4,6)), 3) ', p=' num2str(p(3), 3)]};

if d
    pause; 
    close all;
else
    curfig = figure;
    set(gcf, 'Name', '2-way AnoVa Stats');    
    set(gcf, 'Units', 'normalized');
    axis off;
    title({' '; ' '; ' '; ' '; ' '; cell2mat(s(1)); ' '; cell2mat(s(2)); ' '; cell2mat(s(3))});    
    k = waitforbuttonpress;
    close(curfig);
end

if k
    [fn pn] = uiputfile('*.txt');
    fid = fopen([pn fn],'w');
    fprintf(fid,'%s   ~   ', cell2mat(s(1)));
    fprintf(fid,'%s   ~   ', cell2mat(s(2)));
    fprintf(fid,'%s', cell2mat(s(3)));
    status = fclose(fid);
end
disp(cell2mat(s(1)));   
disp(cell2mat(s(2)));   
disp(cell2mat(s(3))); 
disp(' ');


