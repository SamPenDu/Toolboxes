function D = MeanDistance(MinDist)
%D = MeanDistance(MinDist)
%
% Runs 1,000 simulations of GridBackground to work out 
% the mean distance of an element to its nearest neighbour
% given a certain minimum distance. This can be used to 
% determine a suitable contour spacing.
%
% Parameters:
%   MinDist :   Minimum distance relative to cell width 
%
% Returns mean (+/- StD) distance (in cell widths) 
% of the central element to its nearest neighbour.
%
% For MinDist = 0.75:  0.817 +/- 0.0719
%

Dists = [];

%only nine cells
Cells = 2/3;

for i = 1 : 1000
    clc; disp(['Iteration #' num2str(i)]);
    Elems = [0 0; Inf Inf; Inf Inf];

    %first create a background array
    for gx = -1+Cells/2 : Cells : 1
        for gy = -1+Cells/2 : Cells : 1
            %jittered positions within each cell
            x = gx + rand*(Cells/1) - Cells/2;
            y = gy + rand*(Cells/1) - Cells/2;

            %work out immediate neighbourhood
            n = Neighbourhood([x y], Elems);

            %if not too close to any element
            if norm(n(1,:) - [x y]) >= Cells * MinDist
                %add element to array
                Elems = [Elems; x y];
            end
        end
    end

    %now fill up the empty spaces
    for x = -1+Cells/4 : Cells/2 : 1
        for y = -1+Cells/4 : Cells/2 : 1
            %work out immediate neighbourhood
            n = Neighbourhood([x y], Elems);

            %if not too close to any element
            if norm(n(1,:) - [x y]) >= Cells * MinDist
                %add element to array
                Elems = [Elems; x y];
            end
        end
    end

    %remove dummy elements
    Elems = Elems(4:end,:);

    %find nearest neighbour to centre 
    [n d] = Neighbourhood([0 0], Elems); 
    Dists = [Dists; d(1)];
end

Dists = Dists / Cells;

D = [mean(Dists) std(Dists)];