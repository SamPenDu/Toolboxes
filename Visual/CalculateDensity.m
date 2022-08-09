function dens = CalculateDensity(stim, cw)
%dens = CalculateDensity(stim, [cw])
%
% Calculates the density histogram for contour and background elements.
% To avoid artifacts at the edge of the stimulus this only takes into
% account elements which are within a 1/4 stimulus width from the centre.
%
% Parameters:
%   stim :    Stimulus structure
%   cw :      Cell width (optional, default = 0.125)
%
% Returns a m x 3 matrix. The first column contains the distances, 
% the second column the median densities for contour elements, 
% and the third column the standard error of the mean.
% The next two columns show the same data for the background.
%
% These results are also plotted in an error bar graph.
%

%default cell width
if nargin < 2
    cw = 0.05;
end

%contour and background elements
conel = find(stim.IsContour == 1);
bgdel = find(stim.IsContour == 0);

%element coordinates
xy = [stim.X stim.Y];

dens = [];
condens = [];
bgddens = [];

%range and increments of distance
X = cw : 0.005 : 1;

for e = 1 : length(xy)
    %only do this for elements within 0.5 of origin
    if norm(xy(e,1), xy(e,2)) <= 0.5
        %current element matrix of densities
        currcon = [];
        currbgd = [];

        %vectors from current element to other ones
        xydv(:,1) = xy(:,1) - xy(e,1); 
        xydv(:,2) = xy(:,2) - xy(e,2);

        %distances of other elements to current one
        xyd = [];
        for d = 1 : length(xydv)
            xyd = [xyd; norm(xydv(d,:))];
        end

        %expanding circle to check for elements       
        for ecc = X
            %frequency of elements occuring
            freq = length(find(xyd < ecc & xyd > ecc-cw));

            %what kind of element is it?
            if stim.IsContour(e) == 0   %background element
                currbgd = [currbgd, freq / ((pi*(ecc/cw)^2)-(pi*((ecc-cw)/cw)^2))]; 
            else    %contour element
                currcon = [currcon, freq / ((pi*(ecc/cw)^2)-(pi*((ecc-cw)/cw)^2))]; 
            end
        end

        %add to storage matrix
        condens = [condens; currcon];
        bgddens = [bgddens; currbgd];
    end
end

X = X';
conmean = mean(condens)';
bgdmean = mean(bgddens)';

consem = sqrt(var(condens)/size(condens,1))';
bgdsem = sqrt(var(bgddens)/size(bgddens,1))';

dens = [X conmean consem bgdmean bgdsem];

hold on
errorplot(dens(:,1)', [dens(:,2)'; dens(:,4)'], [dens(:,3)'; dens(:,5)'], [0 0 1; 1 0 0]);
xlabel('Distance (stim-space)');
ylabel('Density (elements/area)');
title({'Blue = Contour, Red = Background'; 'The more the two curves overlap, the less obvious are the density cues.'});
set(gcf, 'Name', 'Gabor field density plots');
xlim([0 1.1]);



