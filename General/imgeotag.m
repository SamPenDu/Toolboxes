function [Gps, DatTim] = imgeotag(ImgFile)
%
% [Gps, DatTim] = imgeotag(ImgFile)
% 
% Reads out the geotag from an image file and returns in Gps the decimal coordinates. 
% If the altitude is included, this is Gps(3); if not, this is set to NaN.
% 

% Load geotag data
warning off
I = imfinfo(ImgFile); % Read image info
warning on
DatTim = I.DateTime; % Data & time photo was taken
Lat = I.GPSInfo.GPSLatitude; % Latitude in DMS
Lon = I.GPSInfo.GPSLongitude; % Longitude in DMS

% Convert DMS to decimals
Lat = Lat(1) + Lat(2)*(1/60) + Lat(3)*(1/3600); % Latitude
Lon = Lon(1) + Lon(2)*(1/60) + Lon(3)*(1/3600);

% Assign correct sign
if I.GPSInfo.GPSLatitudeRef == 'S'
    Lat = -Lat; % Southern latitudes
end
if I.GPSInfo.GPSLongitudeRef == 'W'
    Lon = -Lon; % Western longitudes
end

% Add altitude data?
if isfield(I.GPSInfo, 'GPSAltitude')
    Alt = I.GPSInfo.GPSAltitude;
else 
    Alt = NaN;
end

% Return data
Gps = [Lat Lon Alt];