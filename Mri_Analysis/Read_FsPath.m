function [len pts] = Read_FsPath(fname)
%[len pts] = Read_FsPath(fname)
%
% Reads in a FreeSurfer path file.
% The matrix is organized into four colums:
%   1-3:    x,y,z      coordinates of vertices in world space
%   4:      vertex     vertex index number
%
% The output arguments contain a scalar len with the length,
% and a matrix with all the points on the path.
%

fid = fopen(fname);
[p n e] = fileparts(fname);
c = textscan(fid,repmat('%n',1,4),'headerlines',4);
fclose(fid);

pts = cell2mat(c);

% Calculate path length
len = 0;
for i = 2:size(pts,1)
    % Euclidian distance between points
    curlen = sqrt(sum((pts(i-1,1:3)-pts(i,1:3)).^2));
    len = len + curlen;
end
