function Extract_Hrf(fname, tr, ntrials)
%
% Extract_Hrf(fname, tr, ntrials)
%
% Extracts the HRF for a participant. 
%
%   fname:      4D-Nifty file name (without extension) of HRF measurement
%   tr:         TR of the scan (default = 3.2)
%   ntrials:    Number of trials in the scan (default = 10)
%
% Saves a matlab file 'hrf_[fname].mat' containing the fitted points in Hrf, 
% the function parameters fP, and the raw data points in Raw_hrf.
%

if nargin < 1
    [fname pname] = uigetfile('*.nii');
    fname = [pname fname];
    tr = 3.06;
    ntrials = 10;
elseif nargin < 2
    fname = [fname '.nii'];
    tr = 3.06;
    ntrials = 10;
elseif nargin < 3
    fname = [fname '.nii'];
    ntrials = 10;
end

% Presumed peak volume of HRF
peak_vol = ceil(6/tr) + 1;

% Load & normalize data
hdr = spm_vol(fname);
img = spm_read_vols(hdr);
img = shiftdim(img, 3);

% Volumes per trial
nvols = size(img,1);
vols_per_trial = nvols / ntrials;
xvols = repmat((1:vols_per_trial)', ntrials, 1);

% Z-score 
zimg = zscore(img);

% Mean HRF image
hrfavg = zeros([vols_per_trial hdr(1).dim]);
hrferr = zeros([vols_per_trial hdr(1).dim]);
for t = 1:vols_per_trial
    hrfavg(t,:,:,:) = mean(zimg(xvols == t,:,:,:));
    hrferr(t,:,:,:) = std(zimg(xvols == t,:,:,:)) / sqrt(ntrials);
end

% T-statistic
timg = squeeze(hrfavg(peak_vol,:,:,:) ./ hrferr(peak_vol,:,:,:));
thdr = hdr(1);
thdr.fname = [fname(1:end-4) '_T.nii'];
spm_write_vol(thdr, timg);

% Average HRF of visually responsive voxels
thr = t_value(0.0000000001, ntrials-1);
sigvox = timg < thr;
Raw_hrf = zeros(1,vols_per_trial);
for v = 1:vols_per_trial
    curimg = squeeze(hrfavg(v,:,:,:));
    curimg = curimg(sigvox);
    Raw_hrf(v) = mean(curimg);
end

% Plot raw HRF data
plot((0:vols_per_trial-1)*tr, Raw_hrf, 'ko', 'linestyle', 'none', 'linewidth', 2, 'markerfacecolor', 'k');
hold on; 
% Fit a function 
fP = fminsearch(@(P)hrf_errfun(tr, P, Raw_hrf), [6 16 6 1], optimset('TolX',1e-2,'TolFun',1e-2));
fhrf = spm_hrf(.01, [fP(1:2) 1 1 fP(3) 0 32]) * fP(4); 
fhrf = max(Raw_hrf) / max(fhrf) * fhrf;
t = 0:.01:32;
fhrf = fhrf(1:length(t));
plot(t, fhrf, 'color', [.5 .5 .5], 'linewidth', 2);
yl = ylim;
line([0 tr], [1 1]*yl(1), 'color', 'r', 'linewidth', 3);
set(gca, 'fontsize', 15);
legend('Response', 'Fit', 'Stimulus');
xlabel('Time (s)');
ylabel('Response (z)');
xlim([-.1 vols_per_trial*tr+.1]);
Hrf = spm_hrf(tr, [fP(1:2) 1 1 fP(3) 0 32]) * fP(4);
Can = spm_hrf(tr);
Hrf = max(Can) / max(Hrf) * Hrf;

% Save the HRF data
[p f e] = fileparts(fname);
save(['hrf_' f], 'Hrf', 'fP', 'Raw_hrf');

% Error function to fit HRF
function err = hrf_errfun(TR,P,Y)
X = spm_hrf(TR, [P(1:2) 1 1 P(3) 0 32])' * P(4); 
if length(X) > length(Y)
    X = X(1:length(Y));
elseif length(X) < length(Y)
    Y = Y(1:length(X));
end
err = sum((Y-X).^2);
