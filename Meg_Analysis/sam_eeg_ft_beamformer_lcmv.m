function [stats,talpositions,allepochdata]=sam_eeg_ft_beamformer_lcmv(S)
% Compute power-based beamformer image
% FORMAT [stats,talpositions,allepochdata]=sam_eeg_ft_beamformer_lcmv(S)
%
% returns a stats structure containing univariate t test on power
% and a list of the image files produced
%__________________________________________________________________________
% Copyright (C) 2009 Wellcome Trust Centre for Neuroimaging

% Gareth Barnes
% $Id: spm_eeg_ft_beamformer_lcmv.m 3833 2010-04-22 14:49:48Z vladimir $

% 26/04/2010 DSS - Added allepochdata as output for beamforming script!!

[Finter,Fgraph] = spm('FnUIsetup','univariate LCMV beamformer for power', 0);
%%

%% ============ Load SPM EEG file and verify consistency
if nargin == 0
    S = [];
end


if ~isfield(S,'gridpos'),
    S.gridpos=[];
    end;

 if ~isfield(S,'maskgrid'),
    S.maskgrid=[];
    end;

 
if ~isfield(S,'design'),
   error('Design matrix required');
end; % if

if ~isfield(S,'return_weights')
    ctf_weights=[];
    S.return_weights=0;
end

if ~isfield(S,'Niter')
    S.Niter=[];
end; % if 

if isempty(S.Niter),
    S.Niter=1;
end; % if

% if ~isfield(S,'weightspect'), 
%     S.weightspect=[];
% end; 
% 
if ~isfield(S,'weightttest'), 
    S.weightttest=[];
end; 

if ~isfield(S,'testbands'),
    S.testbands=[];
end;

if ~isfield(S,'gridpos'),
    if ~isfield(S,'gridstep');
    S.gridstep = spm_input('Grid step (mm):', '+1', 'r', '5');
    end; 
end; % if


if ~isfield(S,'detrend'),
    S.detrend=[];
    end;
    
 if isempty(S.detrend),
     disp('detrending data by default');
     S.detrend=1;
 end; % 
 
 if ~isfield(S,'hanning'),
     S.hanning=[];
 end; 
    
 if isempty(S.hanning),
     disp('windowing data by default');
     S.hanning=1;
 end; % 

if ~isfield(S,'logflag'),
    S.logflag=[];
end; % if

if isempty(S.logflag),
    S.logflag=0;
end; % if
%  

if ~isfield(S,'regpc'),
    S.regpc=[];
end; % if

if isempty(S.regpc),
    S.regpc=0;
end; % if


try
    D = S.D;
catch
    D = spm_select(1, 'mat', 'Select MEEG mat file');
    S.D = D;
end

if ischar(D)
    try
        D = spm_eeg_load(D);
    catch
        error(sprintf('Trouble reading file %s', D));
    end
end

[ok, D] = check(D, 'sensfid');

if ~ok
    if check(D, 'basic')
        errordlg(['The requested file is not ready for source reconstruction.'...
            'Use prep to specify sensors and fiducials.']);
    else
        errordlg('The meeg file is corrupt or incomplete');
    end
    return
end

modality = spm_eeg_modality_ui(D, 1, 1);

 channel_labels = D.chanlabels(strmatch(modality, D.chantype))';

if isfield(S, 'refchan') && ~isempty(S.refchan)
    refchan = S.refchan;
else
    refchan = [];
end

%% ============ Find or prepare head model

if ~isfield(D, 'val')
    D.val = 1;
end

   if ~isfield(S,'filenamestr'),
       S.filenamestr=[];
   end;%


for m = 1:numel(D.inv{D.val}.forward)
    if strncmp(modality, D.inv{D.val}.forward(m).modality, 3)
        vol  = D.inv{D.val}.forward(m).vol;
        if isa(vol, 'char')
            vol = ft_read_vol(vol);
        end
        datareg  = D.inv{D.val}.datareg(m);
    end
end


% 
%  try
%      vol = D.inv{D.val}.forward.vol;
%      datareg = D.inv{D.val}.datareg;
%  catch
%      D = spm_eeg_inv_mesh_ui(D, D.val, [], 1);
%      D = spm_eeg_inv_datareg_ui(D, D.val);
%      datareg = D.inv{D.val}.datareg;
%  end

% Return beamformer weights



X=S.design.X;
c=S.design.contrast; %% c is contrast eg [ 0 1 -1] compare columns 2,3 of X


    
try S.design.X(:,1)-S.design.Xtrials-S.design.Xstartlatencies;
    catch
    error('Design windows missepcified');
end;

X0  = X - X*c*pinv(c); 
Xdesign   = full(X*c);
X0  = spm_svd(X0); %% X0 is null space i.e. everything that is happening in other columns of X


outfilenames='';


freqbands=[];
if ~isfield(S, 'freqbands')
    error('need to supply frequency bands')
end


if isempty(S.testbands),
    S.testbands=S.freqbands; %% bands to do the test on
end; % if
    
    
Nbands=numel(S.freqbands);



%% READ IN JUST THE DATA WE need
%% ASSUME THAT INPUT IS AS FOLLOWS
%% a list of trial types and latency ranges for 2 conditions/periods (active and
%% rest for now)
%% each condition has an associated time window which must of equal sizes
%% SO will have
%% a list of trial indices and latencies, a list of trial types of the same
%% length

try
    data = D.ftraw; %% convert to field trip format- direct memory map 
catch
    disp('failed to read data directly.. going slowly');
   data = D.ftraw(0); %% convert to field trip format - file pointers
end; 
%% Check latencies are same here

%% now read in the first trial of data just to get sizes of variables right
cfg=[];
cfg.keeptrials='no';
cfg.trials=1; 


Ntrials=size(S.design.X,1);
cfg.latency=[S.design.Xstartlatencies(1) S.design.Xstartlatencies(1)+S.design.Xwindowduration];

subdata=ft_timelockanalysis(cfg,data); 
Nsamples=length(subdata.time);
Nchans=length(channel_labels);


if S.hanning,
    fftwindow=hamming(Nsamples);
else
    disp('not windowing');
    fftwindow=ones(Nsamples,1);
end; 

allfftwindow=repmat(fftwindow,1,Nchans);
NumUniquePts = ceil((Nsamples+1)/2); %% data is real so fft is symmetric

fftnewdata=zeros(Ntrials,NumUniquePts,Nchans);
allepochdata=zeros(Ntrials,Nchans,Nsamples); %% for loading in data quickly

fHz = (0:NumUniquePts-1)*D.fsample/Nsamples;


if ~isfield(S,'Nfeatures'),
    Nfeatures=floor(Ntrials/3);
else
    Nfeatures=S.Nfeatures;
end;


%% now read in all trialtype and hold them as windowed fourier transforms
[uniquewindows]=unique(S.design.Xstartlatencies);
Nwindows=length(uniquewindows);
    
for i=1:Nwindows,     %% puts trials into epoch data according to order of design.X structures
    winstart=uniquewindows(i); %% window start
    cfg=[];
    cfg.keeptrials='yes';
    cfg.channel=channel_labels;
    cfg.feedback='off';
    useind=find(winstart==S.design.Xstartlatencies); %% indices into design.X structures
    cfg.trials=S.design.Xtrials(useind); %% trials starting at these times
    cfg.latency=[winstart winstart+S.design.Xwindowduration];
    subdata=ft_timelockanalysis(cfg,data); % subset of original data
    allepochdata(useind,:,:)=squeeze(subdata.trial); %% get an epoch of data with channels in columns
end; % for i


for i=1:Ntrials, %% read in all individual trial types
    epochdata=squeeze(allepochdata(i,:,:))'; %% get an epoch of data with channels in columns
    if S.detrend==1
        dtepochdata=detrend(epochdata); %% detrend epoch data, this includes removind dc level. NB. This will have an effect on specific evoked response components !
        else 
        dtepochdata=epochdata; %% no dc removal, no detrend : this will have effect on accuracy of fourier estimate at non dc bins
        end; % detrend 
    wdtepochfft=dtepochdata.*allfftwindow; %% windowed
    
    epochfft=fft(wdtepochfft);
    fftnewdata(i,:,:)=epochfft(1:NumUniquePts,:); % .*filtervect';    
end; 
if size(fftnewdata,3)~=Nchans,
    size(fftnewdata)
    error('Data dimension mismatch');
end;



%% now have an fft for each channel in each condition

    
% %%
cfg                       = [];
if strcmp('EEG', modality)
    cfg.elec = D.inv{D.val}.datareg.sensors;
    cfg.reducerank=3;
else
    cfg.grad = D.sensors('MEG');
    cfg.reducerank=2;
    disp('Reducing possible source orientations to a tangential plane for MEG');
end


cfg.channel = channel_labels;
cfg.vol                   = vol;


 
if  isempty(S.gridpos),
    cfg.resolution            = S.gridstep;
else
    disp('USING pre-specified gridpoints');
    cfg.grid.pos=S.gridpos; %% predefined grid
    cfg.grid.inside=[1:size(S.gridpos,1)]; %% assume all in head
    cfg.grid.outside=[];
    end;

    
cfg.feedback='off';
cfg.inwardshift           = 0; % mm

if ~isfield(S,'grid'),
    disp('preparing leadfield');
    grid                      = ft_prepare_leadfield(cfg);
else
    disp('Using precomputed leadfield');
    grid=S.grid;
end; % if 


maskedgrid_inside_ind=[1:length(grid.inside)];
if ~isempty(S.maskgrid),
    if length(S.maskgrid)~=length(grid.inside),
        error('mask and grid points must be of same size');
        end;
    maskedgrid_inside_ind=find(S.maskgrid==1); %% indices into grid.inside 
    end; 




%% Now have all lead fields and all data
%% Now do actual beamforming
%% decide on the covariance matrix we need
%% construct covariance matrix within frequency range of interest

disp('now running through freq bands and constructing t stat images');
for fband=1:Nbands,
    freqrange=S.freqbands{fband};
    freq_ind=intersect(find(fHz>=freqrange(1)),find(fHz<freqrange(2)));
    if length(freq_ind)<=1,
        disp(sprintf('Cannot use band %3.2f-%3.2f',freqrange(1),freqrange(2)));
        error('Need more than one frequency bin in the covariance band');
        end
    freqrangetest=S.testbands{fband};
    Ntestbands=length(freqrangetest)/2;
    if floor(Ntestbands)~=Ntestbands,
        error('Need pairs of values in testband');
        end;
    freq_indtest=[];
    freq_teststr='';
    for k=1:Ntestbands
        newtestind=intersect(find(fHz>=freqrangetest(k*2-1)),find(fHz<freqrangetest(k*2)));
        freq_indtest=[freq_indtest newtestind];    
        freq_teststr=sprintf('%s %3.2f-%3.2fHz,',freq_teststr,fHz(min(newtestind)),fHz(max(newtestind)));
        end; % for k
    if length(setdiff(freq_indtest,freq_ind))>0,
            error('Bands in test band are not within covariance band')
         end;
    covtrial=zeros(Nchans,Nchans);
   
    
    if ~isempty(S.weightttest),
        [fweightedt,weightspectindt]=intersect(fHz,S.weightttest(fband).fHz);
        if abs(max(fHz(freq_ind)-S.weightttest(fband).fHz))>0,
            error('weight ttest vector wrong length');
            end; % 
        tfiltervect=S.weightttest(fband).vect; %% weighted by previous mv analysis
        else
        tfiltervect=ones(length(freq_indtest),1);
        end;  % weightspect
        


for i=1:Ntrials, %% read in all individual trial types 
     ffttrial=squeeze(fftnewdata(i,freq_ind,:)); % .*Allfiltervect;
     covtrial=covtrial+real(cov(ffttrial));
end; % for i
  covtrial=covtrial/Ntrials;
  allsvd = svd(covtrial);
  cumpower=cumsum(allsvd)./sum(allsvd);
  nmodes99=min(find(cumpower>0.99));
  disp(sprintf('99 percent of the power in this data is in the first %d principal components of the cov matrix',nmodes99));
  disp(sprintf('largest/smallest eigenvalue=%3.2f',allsvd(1)/allsvd(end)));
  disp(sprintf('\nFrequency resolution %3.2fHz',mean(diff(fHz))));
  noise = allsvd(end); %% use smallest eigenvalue
  redNfeatures=Nfeatures;
  
    
  disp(sprintf('covariance band from %3.2f to %3.2fHz (%d bins), test band %s (%d bins)',fHz(freq_ind(1)),fHz(freq_ind(end)),length(freq_ind),freq_teststr,length(freq_indtest)))
  
    
  
  
  lambda = (S.regpc/100) * sum(allsvd)/size(covtrial,1); %% scale lambda relative mean eigenvalue
  disp(sprintf('regularisation =%3.2f percent',S.regpc));
  cinv=inv(covtrial+eye(size(covtrial,1))*lambda); %% get inverse 
  
      



 tstat=zeros(length(grid.inside),S.Niter);
 normdiff=zeros(length(grid.inside),S.Niter);
maxt=zeros(2,S.Niter);
power_trial=zeros(Ntrials,length(freq_indtest));
evoked_trial=zeros(Ntrials,length(freq_indtest));

TrueIter=1; %% no permutation for this iteration
for j=1:S.Niter, %% set up permutations in advance- so perms across grid points are identical
    randind(j,:)=randperm(Ntrials);
    if j==TrueIter,
        randind(j,:)=1:Ntrials; % don't permute first run
        end;
    end;
      
  
    for i=1:length(maskedgrid_inside_ind), %% 81
        lf=cell2mat(grid.leadfield(grid.inside(maskedgrid_inside_ind(i))));
        
        %% get optimal orientation- direct copy from Robert's beamformer_lcmv.m
        projpower_vect=pinv(lf'*cinv*lf);
        [u, s, v] = svd(real(projpower_vect));
        eta = u(:,1);
        lf  = lf * eta; %% now have got the lead field at this voxel, compute some contrast
        weights=lf'*cinv/(lf'*cinv*lf); %% CORRECT WEIGHTS CALC
        
        if S.return_weights
            stats(fband).ctf_weights(i,:)=weights;
        end
        
        for j=1:Ntrials, %% this has to be done at each location
            fdata=squeeze(fftnewdata(j,freq_indtest,:));
            
            fdatatrial=fdata*weights';
            evoked_trial(j,:)=fdatatrial;
            if S.logflag,
                power_trial(j,:)=log(fdatatrial.*conj(fdatatrial));
            else
                power_trial(j,:)=fdatatrial.*conj(fdatatrial); %%
            end; % i 

        end; % for j
        
        
        power_flag=1; %% only look at power for now
            if power_flag,
                Yfull=power_trial; %% univariate test later so just take the mean
            else
                Yfull=evoked_trial;
            end; % if power_flag
            %Yfull=power_trial;
        %Y     = Yfull - X0*(X0'*Yfull); %% eg remove DC level or drift terms from all of Y
        
              
       %% Now permute the rows of X if necessary
        for iter=1:S.Niter,
        
            
            X=Xdesign(randind(iter,:),:); %% randind(1,:)=1, i.e. unpermuted
            cond1_ind=find(X(:,1)>0);
            cond2_ind=find(X(:,1)<=0);
            nx=length(cond1_ind);
            ny=length(cond2_ind);
            dfe = nx + ny - 2;
            xba_epochs=Yfull(cond1_ind,:)*tfiltervect; %% for univariate tfiltervect is all ones (i.e. sum)
            yba_epochs=Yfull(cond2_ind,:)*tfiltervect; %%
            pdiff=mean(xba_epochs)-mean(yba_epochs);
            s2x=var(xba_epochs);
            s2y=var(yba_epochs);
            sPooled = sqrt(((nx-1) .* s2x + (ny-1) .* s2y) ./ dfe);
            se = sPooled .* sqrt(1./nx + 1./ny);
            tstat(maskedgrid_inside_ind(i),iter) = pdiff ./ se; %
            normdiff(maskedgrid_inside_ind(i),iter)=pdiff/(weights*weights');
        end; % for Niter
        
         
        
        
     
        if i/100==floor(i/100)
            disp(sprintf('done t stats for %3.2f percent of freq band %d of %d, log=%d',100*i/length(maskedgrid_inside_ind),fband,Nbands,S.logflag));
        end; % if
    
    
  
end; % for grid points


      
stats(fband).tstat=tstat;
stats(fband).fHz=fHz;

dispthresh_uv=max(stats(fband).tstat)/2;
if S.Niter>1,
    %% get corrected p values to t
        allglobalmax=squeeze(max(abs(stats(fband).tstat(:,1:end))));
        [sortglobalmax,sortglobalmaxind]=sort(allglobalmax','descend');
        
        stats(fband).corrpmax_tstat=find(TrueIter==sortglobalmaxind)/length(sortglobalmaxind);
        stats(fband).thresh05globalmax_tstat=sortglobalmax(round(length(sortglobalmaxind)*5/100),:);
        dispthresh_uv=stats(fband).thresh05globalmax_tstat; % display only significant effects
end; % if
  

    talpositions = spm_eeg_inv_transform_points(D.inv{D.val}.datareg.toMNI, grid.pos(grid.inside(maskedgrid_inside_ind),:));
    gridpositions=grid.pos(grid.inside(maskedgrid_inside_ind),:);


    
    sMRI = fullfile(spm('dir'), 'canonical', 'single_subj_T1.nii');
    
    
    csource=grid; %% only plot and write out unpermuted iteration
    csource.pow_tstat(csource.inside) = tstat(:,TrueIter);
    csource.pow_tstat(csource.outside)=0;
    csource.pos = spm_eeg_inv_transform_points(D.inv{D.val}.datareg.toMNI, csource.pos);
    
    csource.normdiff(csource.inside) =normdiff(:,TrueIter);
    csource.normdiff(csource.outside)=0;
    
    
     % CTF positions inside head
    ctf_inside = spm_eeg_inv_transform_points(D.inv{D.val}.datareg.toMNI, csource.pos(csource.inside,:));
    
    
    if isempty(S.gridpos), %% only write images if they use whole volume
         
    
    cfg1 = [];
    cfg1.sourceunits   = 'mm';
    cfg1.parameter = 'pow_tstat';
    cfg1.downsample = 1;
    sourceint_pow_tstat = ft_sourceinterpolate(cfg1, csource, sMRI);
    
     cfg1 = [];
     cfg1.sourceunits   = 'mm';
     cfg1.parameter = 'normdiff';
     cfg1.downsample = 1;
     sourceint_normdiff= ft_sourceinterpolate(cfg1, csource, sMRI);
%     
    
    
    
    if (isfield(S, 'preview') && S.preview)
        
        
        cfg1 = [];
        cfg1.funparameter = 'pow_tstat';
        cfg1.funcolorlim = [min(csource.pow_tstat) max(csource.pow_tstat)];  
        cfg1.interactive = 'yes';
        figure
        ft_sourceplot(cfg1,sourceint_pow_tstat);
        
 
%         cfg1 = [];
%         cfg1.funparameter = 'evoked_tstat2';
%         cfg1.funcolorlim = [min(csource.evoked_tstat2) max(csource.evoked_tstat2)];  
%         cfg1.interactive = 'yes';
%         figure
%         ft_sourceplot(cfg1,sourceint_evoked_tstat2);
        
    
    end; % if preview
    
    
    %% else %% write out the data sets
    disp('writing images');
    
    cfg = [];
    cfg.sourceunits   = 'mm';
    cfg.parameter = 'pow';
    cfg.downsample = 1;
    % write t stat
    dirname='tstatBf_images';
    if S.logflag,
        dirname=[dirname '_log'];
    end;

    res = mkdir(D.path, dirname);
    outvol = spm_vol(sMRI);
    outvol.dt(1) = spm_type('float32');
%     featurestr=[S.filenamestr 'Nf' num2str(redNfeatures)] ;
%     outvol.fname= fullfile(D.path, dirname, ['chi_pw_'  spm_str_manip(D.fname, 'r') '_' num2str(freqbands(fband,1)) '-' num2str(freqbands(fband,2)) 'Hz' featurestr '.nii']);
%     stats(fband).outfile_chi_pw=outvol.fname;
%     outvol = spm_create_vol(outvol);
%     spm_write_vol(outvol, sourceint_pow_maxchi.pow_maxchi);
%     
%     outvol.fname= fullfile(D.path, dirname, ['chi_ev_' spm_str_manip(D.fname, 'r') '_' num2str(freqbands(fband,1)) '-' num2str(freqbands(fband,2)) 'Hz' featurestr '.nii']);
%     stats(fband).outfile_chi_ev=outvol.fname;
%     outvol = spm_create_vol(outvol);
%     spm_write_vol(outvol, sourceint_evoked_maxchi.evoked_maxchi);

        outvol.fname= fullfile(D.path, dirname, ['tstat_pow_' spm_str_manip(D.fname, 'r') '_' num2str(S.freqbands{fband}(1)) '-' num2str(S.freqbands{fband}(2)) 'Hz' S.filenamestr '.nii']);
        stats(fband).outfile_pow_tstat=outvol.fname;
        outvol = spm_create_vol(outvol);
        spm_write_vol(outvol, sourceint_pow_tstat.pow_tstat);
         
         outvol.fname= fullfile(D.path, dirname, ['normdiff_pow_' spm_str_manip(D.fname, 'r') '_' num2str(S.freqbands{fband}(1)) '-' num2str(S.freqbands{fband}(2)) 'Hz' S.filenamestr '.nii']);
         stats(fband).outfile_normdiff=outvol.fname;
         outvol = spm_create_vol(outvol);
         spm_write_vol(outvol, sourceint_normdiff.normdiff);
% 
    
    end; % if ~S.gridpos
    
end; % for fband=1:Nbands

  %% Set t tstat thresholds based on F test for this many degrees of
  %% freedom. Not using Hotellings threshold for now..
%      Nfeatures=Nchans; 
%      Ht_toF=(Ntrials-Nfeatures)/((Nfeatures-1)*Ntrials); %% factor that relates hotellings T threshold to an F threshold
%      Fthresh_alyt=spm_invFcdf(1-0.05,Nfeatures,Ntrials-Nfeatures);
%      T2thresh=Fthresh_alyt.^2;
%      plotT=tstat;
%      plotind=find(tstat.^2>=T2thresh);
%      
%      Fgraph = spm_figure('GetWin','Graphics');
%      figure(Fgraph);clf
%     
%      spm_mip(plotT(plotind),talpositions(plotind,:),S.gridstep);
%       drawnow
%  
     
     
end % function


