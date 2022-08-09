function [contel, spacing, elemspacs] = CollinearContour(full_xy, nelems, disjitter, latjitter)
%[contel, spacing, elemspacs] = CollinearContour(full_xy, nelems, [disjitter, latjitter])
%
% Parses the string of points on path to return roughly 
% equally spaced elements with orientational jitter.
%
% Parameters:
%   full_xy :       String of coordinates on contour path
%   nelems :        Number of elements for contour. If negative, this is the spacing
%   disjitter :     Inter-element distance jitter as proportion of spacing (optional)
%   latjitter :     Lateral jitter off the contour path (optional)
%
% Returns struct of the contour elements with fields:
%   contel.Theta =   Orientations 
%   contel.X =       X-coordinates
%   contel.Y =       Y-coordinates
%
% The second output argument contains the minimum inter-element spacing.
% The third output is a vector with the distance from each element to the next.

sparse_xy = [];

%check if lateral jitter is defined
if nargin == 2
    disjitter = 0;
    latjitter = 0;
elseif nargin == 3
    latjitter = 0;
end

%length of string
strpts = length(full_xy);
if strpts == 1
    sparse_xy = [RandOri full_xy];
else
    strlen = norm([full_xy(2,:)-full_xy(1,:)]);
    for i = 3 : strpts
        d = norm([full_xy(i,:)-full_xy(i-1,:)]);
        strlen = [strlen; strlen(end)+d];
    end

    if nelems < 0
        nelems = strlen(end) / -nelems;
    end
    
    %inter-element spacing
    spacing = strlen(end) / nelems;
    
    %determine position of elements on length of path
    elems_len = [spacing : spacing : strlen(end)]';
    disjits = RandSign(length(elems_len),1) * disjitter;
    elems_len = elems_len + disjits;

    for n = 1 : nelems
        curstrdis = abs(strlen - elems_len(n));
        ci = find(curstrdis == min(curstrdis));

        % determine element orientation
        curelem = AlignToPath(full_xy, ci(1)); 

        % add lateral jitter
        [latx laty] = pol2cart((curelem(1)+90)/180*pi, randn*latjitter);
        curelem(2:3) = curelem(2:3) + [latx laty];
        sparse_xy = [sparse_xy; curelem];
    end
end

contel = struct;
contel.N = size(sparse_xy,1);
contel.X = sparse_xy(:,2);
contel.Y = sparse_xy(:,3);
contel.Theta = sparse_xy(:,1);
contel.Collinear = sparse_xy(:,1);
contel.IsContour = ones(size(sparse_xy,1),1);
contel.Contrast = ones(contel.N,1);
contel.Phase = zeros(contel.N,1);
contel.Sigma = 10;
contel.Lambda = 5;

elemspacs = [];
for n = 1 : contel.N - 1
    elemspacs = [elemspacs; norm([contel.X(n) contel.Y(n)] - [contel.X(n+1) contel.Y(n+1)])];
end
spacing = mean(elemspacs);

