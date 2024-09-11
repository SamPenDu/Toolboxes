function Fs = dirc(dirstr)
%
% Fs = dirc(dirstr)
%
% Wrapper for dir but returning a cell array of the file names.
%

Fs = dir(dirstr);
Fs = {Fs.name}';