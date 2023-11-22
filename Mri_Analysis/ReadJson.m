function json = ReadJson(JsonFile)
%
% json = ReadJson(JsonFile)
% 
% Reads a JSON file (name provided without extension) & returns as struct.
%

f = fopen([JsonFile '.json']);
raw = fread(f,Inf);
str = char(raw');
json = jsondecode(str);
fclose(f);