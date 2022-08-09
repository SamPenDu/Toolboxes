function Dual_Retino_Fourier4D(ExpName)
%Dual_Retino_Fourier4D([ExpName])
%
% Runs retinotopic mapping using Fourier analysis. This program requires a 
% 4D-Nifty image as input. It also needs SPM to be installed in the path.
% The parameter ExpName is optional. Without it the file is selected by dialog.
%
% Before starting one has to choose between polar and eccentricity mapping.
% The parameters may need to be adjusted in this function for your experiment:
%
%   ExpName is the name of the image containing the functional time series.
%
%   Frequency is the number of stimulus cycles in the run.
%
%   OutputName is the name of the files to be saved. If this is undefined 
%   then the name prefix is identical to ExpName.
%
%   DroppedVols is the number of dummy volumes to be dropped from the end. 
%   If this is undefined this is set to 0.
%
%   IgnoredFreq is a vector containing the frequencies that should be
%   ignored when calculating the coherence values.
%
% The script will save three NII images, two containing the imaginary and 
% real components of the Fourier transformed data, and one with and F-ratio.
%
% The data is thresholded by only including voxels above the mean intensity. 
% This is a very crude method but it excludes non-brain voxels.
%

if nargin == 0
    [fn,pn] = uigetfile('*.nii');
    cd(pn);
    ExpName = fn(1:end-4);
end
button = questdlg('What do you want to analyse?', 'Dual_Retino_Fourier4D', 'Polar', 'Eccentricity', 'Polar');
switch button
    case 'Polar'
        Frequency = 3;
        OutputName = ['Pol_' ExpName];
        DroppedVols = 15;
        IgnoredFreq = [0 1 5];
    case 'Eccentricity'
        Frequency = 5;
        OutputName = ['Ecc_' ExpName];
        DroppedVols = 15;
        IgnoredFreq = [0 1 3];
    otherwise
        error('Dual_Retino_Fourier4D was cancelled.');
end

%% Load time series
disp('Reading nifty headers');
hdr = spm_vol([ExpName '.nii']);  % Read the headers
nvols = length(hdr)-DroppedVols;    % Number of volumes in image
dim = hdr(1).dim;  % Dimensions of images
disp('Loading time series');
img = spm_read_vols(hdr);
msk = img(:,:,:,1);
nhdr = hdr(1);
nhdr.pinfo = [1 0 0]';

% Time series matrix
ts = NaN([nvols dim(1:3)]);  
% Transform so that time is in rows
img = img(:,:,:,1:nvols);
ts = shiftdim(img,3);

% Normalize time series
vm = repmat(mean(ts,1), [nvols 1 1 1]); % Voxel-wise mean
ts = (ts - vm) ./ vm * 100; % Voxel-wise percent signal change

%% Fourier transform
disp('Analysing volume'); 
ft = fft(ts);   % Fourier transform
pw = abs(ft);   % Power at each frequency
cf = squeeze(ft(Frequency+1,:,:,:));    % Cycle frequency only

% Mean power over all frequencies
mpw = NaN(dim); 
mfs = 1:size(pw,1);
mfs = mfs(~ismember(mfs, IgnoredFreq+1));
for z = 1:dim(3)
    mpw(:,:,z) = nanmean(pw(mfs,:,:,z)); 
end

% Data at cycle frequency
cI = -imag(cf);  % Imaginary component (negative because we want cosine as 0)
cR = real(cf);  % Real component
cA = abs(cf);   % Amplitude
cF = cA ./ mpw * 100; % F-statistic 
cP = atan2(cI,cR)/pi*180;  % Phase in degrees
cP = mod(cP,360); % Phases between 0 and 360
cP = cP - 180;  % Phases between -180 and +180

% Mask the brain
threshold = mean(msk(:)); % intensity threshold
nbvox = find(msk < threshold);  % non-brain voxels
% Remove non-brain voxels
cI(nbvox) = NaN;   
cR(nbvox) = NaN;   
cF(nbvox) = NaN;
cA(nbvox) = NaN;   
cP(nbvox) = NaN;   

%% Save to disk as Nifty
disp(' ');
nhdr.fname = [OutputName '_real.nii'];   
spm_write_vol(nhdr,cR);
disp(['Saved Real image: ' nhdr.fname]);

nhdr.fname = [OutputName '_imag.nii'];  
spm_write_vol(nhdr,cI);
disp(['Saved Imaginary image: ' nhdr.fname]);

nhdr.fname = [OutputName '_F.nii'];
spm_write_vol(nhdr,cF);
disp(['Saved F image: ' nhdr.fname]);

nhdr.fname = [OutputName '_ampl.nii'];  
spm_write_vol(nhdr,cA);
disp(['Saved Amplitude image: ' nhdr.fname]);
 
nhdr.fname = [OutputName '_phase.nii']; 
spm_write_vol(nhdr,cP);
disp(['Saved Phase image: ' nhdr.fname]);


