function AvgPhaseMaps
%
% Select the phase maps you want to average. 
% You can select more than one file in each dialog,
% but be sure you separate them by their direction!
%

% Get files
[c cf] = uigetfile('*_imag.nii', 'Clockwise/Expanding', 'MultiSelect', 'on');
[a af] = uigetfile('*_imag.nii', 'Anticlockwise/Contracting', 'MultiSelect', 'on');
% Turn into cells
if ischar(c) c = {c}; end
if ischar(a) a = {a}; end
% Image dimensions 
hdr = spm_vol([cf filesep c{1}]);
dims = hdr.dim;

%% Load all images
c_real = NaN([dims length(c)]);
c_imag = NaN([dims length(c)]);
a_real = NaN([dims length(a)]);
a_imag = NaN([dims length(a)]);
% Load clockwise/expanding runs
for i = 1:length(c)
    s = c{i};
    % Load imaginaries
    hdr = spm_vol([cf filesep s]);
    img = spm_read_vols(hdr);
    c_imag(:,:,:,i) = img;
    % Load reals
    hdr = spm_vol([cf filesep s(1:end-9) '_real.nii']);
    img = spm_read_vols(hdr);
    c_real(:,:,:,i) = img;
end
% Load anticlockwise/contracting runs
for i = 1:length(a)
    s = a{i};
    % Load imaginaries
    hdr = spm_vol([af filesep s]);
    img = spm_read_vols(hdr);
    a_imag(:,:,:,i) = img;
    % Load reals
    hdr = spm_vol([af filesep s(1:end-9) '_real.nii']);
    img = spm_read_vols(hdr);
    a_real(:,:,:,i) = img;
end

%% Multiply anticlockwise/contracting imaginaries by -1
a_imag = -a_imag;

%% Pool images & average
all_real = NaN([dims size(c_real,4)+size(a_real,4)]);
all_imag = NaN([dims size(c_imag,4)+size(a_imag,4)]);
all_real(:,:,:,1:size(c_real,4)) = c_real;
all_real(:,:,:,size(c_real,4)+1:end) = a_real;
all_imag(:,:,:,1:size(c_imag,4)) = c_imag;
all_imag(:,:,:,size(c_imag,4)+1:end) = a_imag;
avg_real = mean(all_real,4);
avg_imag = mean(all_imag,4);

% Transform to phases
avg_pha = atan2(avg_imag,avg_real)/pi*180;  % Phase in degrees
avg_pha = mod(avg_pha,360); % Phases between 0 and 360
avg_pha = avg_pha - 180;  % Phases between -180 and +180

avgname = input('Name of average map (without extension): ','s');
hdr.fname = [avgname '_real.nii'];
spm_write_vol(hdr, avg_real);
hdr.fname = [avgname '_imag.nii'];
spm_write_vol(hdr, avg_imag);
hdr.fname = [avgname '_phase.nii'];
spm_write_vol(hdr, avg_pha);



