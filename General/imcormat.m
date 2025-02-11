function imcormat(R, P, labels, pcor)
%
% imcormat(R, P, labels, pcor)
%
%   Displays the correlation matrix R as an image.
%
%   P defines the p value but this is optional (can also set to []).
%   If pcor is Inf, P contains Bayes Factors instead.
%
%   The cell matrix labels defines the labels of each column/row.
%
%   The final input pcor toggles how Bonferroni correction is used:
%
%         0: no correction (default) 
%        +1: full matrix
%        -1: half matrix only
%       Inf: Bayes Factor
%

% Global variable
global Rmat pcor

if nargin < 2
    P = [];
    labels = {};
    pcor = 0;
elseif nargin < 3
    labels = {};
    pcor = 0;
elseif nargin < 4
    pcor = 0;
end

% If no labels defined
if isempty(labels)
    labels = 1:size(R,1);
end

% Number of elements
n = size(R,1);

% Show image
Rmat = imresize(R/2+.5, 75, 'nearest');
if ~isempty(P)
    Rmat(:,:,2) = imresize(P, 75, 'nearest');
end
imshow(Rmat(:,:,1));
axis on
hold on

% Colour map
cm = [0 0 0; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 0 0 0; 0 0 0];
colormap(gca, colourscale(200));

% Bonferroni threshold
if pcor == 1
    nc = n^2; % Bonferroni threshold over full matrix
elseif pcor == -1
    cs = cumsum(1:n-1); % Half size of matrix
    nc = cs(end); % Number of comparisons
else
    nc = 1;
end

% Show asterisks
if ~isempty(P)
    for r = 1:n
        for c = 1:n
            % Bayesian or frequentist?
            if isinf(pcor)
                s = '';
                % Which Bayes Factor?
                if P(r,c) < 1/3
                    s = 'o'; % Moderately H0
                end
                if P(r,c) < 1/10
                    s = 's'; % Strongly H0
                end
                if P(r,c) < 1/100
                    s = 'd'; % Decisively H0
                end
                if P(r,c) > 3
                    s = '*'; % Moderately H1
                end
                if P(r,c) > 10
                    s = 'p'; % Strongly H1
                end
                if P(r,c) > 100
                    s = 'h'; % Decisively H1
                end
                
                % If above/below criterion
                if P(r,c) < 1/3 || P(r,c) > 3
                    cc = round((R(r,c)/2+.5)*8);
                    if cc == 0
                        cc = 1;
                    end
                    scatter(c*75-37.5, r*75-37.5, 150, cm(cc,:), s);
                end
            else
                % What significance threshold?
                if P(r,c) < 0.05/nc 
                    s = '+'; 
                end
                if P(r,c) < 0.01/nc 
                    s = '*'; 
                end
                if P(r,c) < 0.001/nc 
                    s = 'p'; 
                end
                if P(r,c) < 0.0001/nc 
                    s = 'h'; 
                end

                % If significant at any threshold
                if P(r,c) < 0.05/nc
                    cc = round((R(r,c)/2+.5)*8);
                    if cc == 0
                        cc = 1;
                    end
                    scatter(c*75-37.5, r*75-37.5, 150, cm(cc,:), s);
                end
            end
        end
    end
end

% Add labels
set(gca, 'xtick', 75*(.5:n), 'xticklabel', labels, 'ytick', 75*(.5:n), 'yticklabel', labels);

% Add color bar
hb = colorbar;
set(hb, 'ytick', 0:.25:1, 'yticklabel', -1:.5:1);

% Pixel selection hack
dcm_obj = datacursormode(gcf);
set(dcm_obj, 'UpdateFcn', @getpixelfun)

% Close request function
crfcn = @closereq;
set(gcf, 'CloseRequestFcn', crfcn);

%% Subfunctions
function txt = getpixelfun(empt, event_obj)
global Rmat pcor
pos = get(event_obj, 'Position');
if size(Rmat,3) > 1
    if isinf(pcor)
        % Bayesian test
        txt = {['R = ' num2str((Rmat(pos(2),pos(1),1)-.5)*2)]; ...
               ['BF_{10} = ' num2str(Rmat(pos(2),pos(1),2))]};
    else
        % Frequentist test
        txt = {['R = ' num2str((Rmat(pos(2),pos(1),1)-.5)*2)]; ...
               ['P = ' num2str(Rmat(pos(2),pos(1),2))]};
    end
else
    txt = ['R = ' num2str((Rmat(pos(2),pos(1))-.5)*2)]; 
end
return

function closereq(src, evnt)
% Clear global variables when figure is closed
clear global Rmat
delete(src);

function cmap = colourscale(res)

if nargin == 0
    res = 256;
end
cmap = berlin(res);

% Old red-white-blue colour scheme 
% steps = res/4;
% cmap = [linspace(0,0,steps)' linspace(1,0,steps)' linspace(1,1,steps)'; ...
%         linspace(0,1,steps)' linspace(0,1,steps)' linspace(1,1,steps)'; ...
%         linspace(1,1,steps)' linspace(1,0,steps)' linspace(1,0,steps)'; ...
%         linspace(1,1,steps)' linspace(0,1,steps)' linspace(0,0,steps)'];
