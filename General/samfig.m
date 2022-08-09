function samfig(t)
% opens a black window that spans the screen
% at the size specified by samfig.xls if it exists

global windim;
if isempty(windim)
    windim = [300 300 800 600];
end
figure; axis off;
set(gcf, 'Units', 'pixels'); 
set(gcf, 'MenuBar', 'none');
set(gcf, 'Color', [0 0 0]);
set(gcf, 'NumberTitle', 'off');
set(gcf, 'Position', windim);

try   
    set(gcf, 'Name', t);
catch end

