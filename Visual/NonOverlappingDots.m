function XY = NonOverlappingDots(N, xys, Radius)
% 
% XY = NonOverlappingDots(N, xys, Radius)
%
% Generates N non-overlapping Cartesian coordinates XY (N x 2 matrix) surrounding
% point xys(1:2) drawn from a Gaussian distribution with standard deviation xys(3).
% Radius defines the radius of each dot and thus determines the minimum
% distance between neighbouring dots.
%

% Generate initial set of dots
XY = repmat(xys(1:2),N,1) + randn(N,2).*repmat(xys(3),N,2);

% Regenerate dots until none too close to their neighbours
CheckDists = true;
while CheckDists
    Ds = EuclideanDistMat(XY); % Distances between all dots
    Ds = rem_redmat(Ds); % Remove redundant part of matrix
    b = [];
    % Check which points are too close
    for i = 2:N
        if sum(Ds(1:i-1,i) < Radius) > 0
            b = [b i];
        end
    end
    nb = length(b); % How many new points are needed?
    if nb == 0
        CheckDists = false; % We are done!
    else
        XY(b,:) = repmat(xys(1:2),nb,1) + randn(nb,2).*repmat(xys(3),nb,2); % Regenerate dots
    end
end

