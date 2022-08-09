function oricon = LocalGeometry(stim, resol, maxDist)
%oricon = LocalGeometry(stim, resol, [maxDist])
%
% Returns the orientation contrast in the local neighbourhood of all 
% contour elements in stimulus stim. Positions are in polar coordinates 
% with all angles collapsed over all the possible radii (within the range 
% of maxDist). The output matrix has rows for each bin of polar angles, 
% and a column for each contour element.
%
% Parameters:
%   stim :      Stimulus structure
%   resol :     Bins of polar angles
%   maxDist :   Maximal range to include 
%                  (optional, default = 0.25)
%

%only contour elements are used
els = find(stim.IsContour == 1);

%maximal distance for links
if nargin < 3
    maxDist = 0.25; 
end

xy = [stim.X stim.Y];
tri = delaunay(xy(:,1), xy(:,2));

if nargin < 2
    resol = 36;
end
angres = 360/resol;

%orientation map matrix
oricon = NaN * ones(resol, length(els));

%for each stimulus element
for i = 1 : length(els)
    nnb = NaturalNeighbours(xy, tri, els(i));

    %for each natural neighbour
    for n = 1 : length(nnb)
        %contour axis orientation
        cdeg = NormDeg(stim.Collinear(els(i)), 180);
        
        %current neighbour's orientation
        ndeg = NormDeg(stim.Theta(xy(:,1) == nnb(n,1) & xy(:,2) == nnb(n,2)), 180);

        %current neighbour's distance to current element
        dist = norm([nnb(n,:) - xy(els(i),:)]);

        %only use neighbours within a certain range
        if dist <= maxDist && dist > 0
            %neighbour's polar position with respect to contour path
            n_real = [nnb(n,:) - xy(els(i),:)]; %real coordinates
            [t r] = cart2pol(n_real(:,1), n_real(:,2));
            t = t / pi*180;
            t = t - cdeg;
            t = NormDeg(t);
            if t == 0
                t = 360;
            end
            
            %polar angle bin
            ab = ceil((t-angres/2) / angres);
            if ab == 0
                ab = resol;
            end

            %difference of orientations 
            ori_offset = NormDeg(ndeg - cdeg); %orientation contrast

            %update the map 
            oricon(ab, i) = ori_offset;
        end
    end
end



