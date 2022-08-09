function bf_cmfgam_multap(FreqBand, GridSize, SpmFileName)
%% repeated measures

if nargin == 0
    FreqBand = [30 80];
    GridSize = 10;
    SpmFileName = uigetfile('*.mat');
elseif nargin == 1
    GridSize = 10;
    SpmFileName = uigetfile('*.mat');
elseif nargin == 2
    SpmFileName = uigetfile('*.mat');
end
Preview = false;

%% Set up analysis
D = spm_eeg_load(SpmFileName);
 
[condtypes,Ncond,condind]=unique(D.conditions); condtypes; Ncond;
lcl=strmatch('lcl',D.conditions);   % Left close large
lcs=strmatch('lcs',D.conditions);   % Left close small
lfl=strmatch('lfl',D.conditions);   % Left far large 
lfs=strmatch('lfs',D.conditions);   % Left far small 
rcl=strmatch('rcl',D.conditions);   % Right close large 
rcs=strmatch('rcs',D.conditions);   % Right close small 
rfl=strmatch('rfl',D.conditions);   % Right far large 
rfs=strmatch('rfs',D.conditions);   % Right far small 

%% Results output
Results = struct;
Results.GridSize = GridSize;
Results.FreqBand = FreqBand;
Results.Peaks = [];
Results.PeakHz = [];
Results.Frequency = [];
Results.Stimulus = [];
Results.Baseline = [];

%% Left & right hemifield
for h = 1:12
    switch h
        case 1
            % Left close all
            condstr = 'LC';
            triallist_cl1 = lcl;
            triallist_cl2 = lcs;
        case 2
            % Left far all
            condstr = 'LF';
            triallist_cl1 = lfl;
            triallist_cl2 = lfs;
        case 3
            % Right close all
            condstr = 'RC';
            triallist_cl1 = rcl;
            triallist_cl2 = rcs;
        case 4
            % Right far all
            condstr = 'RF';
            triallist_cl1 = rfl;
            triallist_cl2 = rfs;
        case 5
            % Left close large
            condstr = 'LCL';
            triallist_cl1 = lcl;
            triallist_cl2 = [];
        case 6
            % Left close small
            condstr = 'LCS';
            triallist_cl1 = lcs; 
            triallist_cl2 = [];
        case 7
            % Left far large
            condstr = 'LFL';
            triallist_cl1 = lfl;
            triallist_cl2 = [];            
        case 8
            % Left far small
            condstr = 'LFS';
            triallist_cl1 = lfs;
            triallist_cl2 = [];
        case 9
            % Right close large
            condstr = 'RCL';
            triallist_cl1 = rcl;
            triallist_cl2 = [];
        case 10
            % Right close small
            condstr = 'RCS';
            triallist_cl1 = rcs;
            triallist_cl2 = [];
        case 11
            % Right far large
            condstr = 'RFL';
            triallist_cl1 = rfl;
            triallist_cl2 = [];
        case 12
            % Right far small
            condstr = 'RFS';
            triallist_cl1 = rfs;
            triallist_cl2 = [];
    end
    
    length_both=length(triallist_cl1)+length(triallist_cl2);
    fulltriallist = [triallist_cl1;triallist_cl2;triallist_cl1;triallist_cl2];
    trialtype = [];  

    fullX = zeros(length(fulltriallist),length_both+2); 
    fullX(1:length_both,1) = 1;
    fullX(length_both+1:length_both*2,2) = 1;
    for j=1:length_both
        fullX(j,j+2)=1;
        fullX(j+length_both,j+2)=1;
    end;
    
    S.design.Xwindowduration = 1.0; % in seconds (width of comparison window for all conditions)
    prestim_lat = -S.design.Xwindowduration;
    poststim_lat = 0.5;

    Xstartlatency = zeros(size(fullX,1),1);
    Xstartlatency(1:length_both) = prestim_lat;
    Xstartlatency(length_both+1:end) = poststim_lat;

    
    S.design.Xtrials = fulltriallist; % correspond to the trials (in this case a row is a trial)
    S.design.Xstartlatencies = Xstartlatency; %% correspond to latencies within trials

    S.design.X = fullX;
    S.design.contrast = [-1 1 zeros(1,length_both)];

    S.freqbands{1} = FreqBand;
    S.gridstep = GridSize;
    S.preview = Preview;
    S.return_weights = 1;
    S.return_data=1;

    % S.Niter = 100;
    S.D = D;
    [stats,talpositions] = spm_eeg_ft_beamformer_lcmv(S);

    %% Look at induced
    [maxval,maxind] = max(stats.tstat); maxval;
    disp([condstr ' peak at: ' num2str(talpositions(maxind,:))]);
    % Is this the right peak%     figure;
%     errorplot(stats.fHz,power_stim_cl1(1:length(stats.fHz)),sem_power_cl1(1:length(stats.fHz)),[0 0 1]);
%     errorplot(stats.fHz,power_stim_cl2(1:length(stats.fHz)),sem_power_cl2(1:length(stats.fHz)),[1 0 0]);
%     errorplot(stats.fHz,power_base(1:length(stats.fHz)),sem_power_base(1:length(stats.fHz)),[0 1 0]);

%     peakvox = input('Peak voxel coordinates (enter to accept suggestion): ');
%     if ~isempty(peakvox)
%         maxind = elemind(stats.tstat, peakvox);
%     end
    
    Results.Peaks = [Results.Peaks; talpositions(maxind,:)];

    maxweights = stats.ctf_weights(maxind,:);
    Ntrials = size(stats.allepochdata,1);

    % Time-frequency plot 
    trials = [triallist_cl1;triallist_cl2];
    xD = D(:,:,trials);
    ws = NaN(100,1801,length(trials)); 
    for t = 1:length(trials) 
        tD = detrend(maxweights*xD(:,:,t)); ws(:,:,t)=spm_wavspec(tD,1:100,600); 
    end
    mws = mean(ws,3);
    tfimg = mws./repmat(mean(mws(:,1:900),2),[1 1801]);
    tfimg = flipud(tfimg);
    figure; imagesc(tfimg);   
    colormap hot;
    set(gca,'fontsize',15,'fontname','calibri');
    title([condstr ' stimulation']);
    set(gca,'xtick',1:300:1801,'xticklabel',[0:300:1800]/D.fsample-1.5);
    set(gca,'ytick',0:10:100,'yticklabel',100:-10:0);
    xlabel('Time (s)');
    ylabel('Frequency (Hz)'); 
    saveas(gcf,['tf_' condstr '_' num2str(FreqBand(1)) '-' num2str(FreqBand(2)) '_' num2str(GridSize) '_mt.fig']);
    
    tfd = [tfimg(:,1201:1800)-tfimg(:,301:900)]';
%     figure; errorplot(0:99, mean(tfd), sem(tfd), [0 0 0]);
    [m tff]=max(mean(tfd));
    tff = tff-1;
%     hold on; line([tff tff], ylim, 'color', 'r');
%     saveas(gcf,['tfd_' condstr '_' num2str(FreqBand(1)) '-' num2str(FreqBand(2)) '_' num2str(GridSize) '_mt.fig']);
    
    Nbutter=2;
    [B,A] = butter(Nbutter,2*[FreqBand]./D.fsample);
    allvedata=[];
    allstimvedata=[];
    allbasevedata=[];
    for f = 1:Ntrials,
        disp(f);
        
        vedata = maxweights*squeeze(stats.allepochdata(f,:,:));
        vetrialdata(f,:) = vedata; % Put this into pretty wavelet trans?
        vedata = detrend(vedata);
        if S.design.Xstartlatencies(f)>=0,
               allstimvedata=[allstimvedata vedata];
            else
                allbasevedata=[allbasevedata vedata];
            end;
        allvedata=[allvedata vedata];
        vedata = vedata .* hanning(length(vedata))';
        
        fvedata = filtfilt(B, A, vedata);
        
        fftvedata = fft(fvedata);
        
        allpowvedata(f,:) = fftvedata .* conj(fftvedata);
        
        
        for p=1:6,
        %disp(sprintf('Now fitting model with p=%d coefficients',p));
            %ar=spm_rar (fvedata,p,2,0); %% 2 noise mixtures- robust fitting
            ar=spm_ar (fvedata,p,0); %%
            %mar=spm_mar (fvedata,p); %%
            logev(p,f)=ar.fm;
            %logevmar(p,f)=mar.fm;
        end
       fvetrialdata(f,:)=fvedata;
    end; % for f
            
    [max_log, max_p]=max(logev); max_log;
    maxmaxorder=max(max_p); %% get most complext model from all epochs
    disp(sprintf('Most complex for single epoch is AR-%d model ',maxmaxorder));

    allvedata = allvedata .* hanning(length(allvedata))';
    allstimvedata = allstimvedata .* hanning(length(allstimvedata))';
    allbasevedata = allbasevedata .* hanning(length(allbasevedata))';
    fallvedata = filtfilt(B, A, allvedata);
    fallstimvedata = filtfilt(B, A, allstimvedata);
    fallbasevedata = filtfilt(B, A, allbasevedata);
        for p=1:10,
        %disp(sprintf('Now fitting model with p=%d coefficients',p));
            %ar=spm_rar (fvedata,p,2,0); %% 2 noise mixtures- robust fitting
            fullar(p)=spm_ar (fallvedata,p,0); %%
            stimar(p)=spm_ar (fallstimvedata,p,0); %%
            basear(p)=spm_ar (fallbasevedata,p,0); %%
            %mar=spm_mar (fvedata,p); %%
            logevall(p)=fullar(p).fm;
            logevstim(p)=stimar(p).fm;
            logevbase(p)=basear(p).fm;
            %logevmar(p,f)=mar.fm;
        end
      
      [bestF,bestpall]=max(logevall); bestF; 
      [bestFstim,bestpstim]=max(logevstim); bestFstim; 
      [bestFbase,bestpbase]=max(logevbase); bestFbase;
      freq=[1:100];
       pwrall=spm_ar_freq(fullar(bestpall),freq,D.fsample);
         pwrstim=spm_ar_freq(stimar(7),freq,D.fsample);
         pwrbase=spm_ar_freq(basear(bestpbase),freq,D.fsample);
         disp(sprintf('For all data baseline is AR-%d model ',bestpbase));
         disp(sprintf('For all stim baseline is AR-%d model ',bestpstim));        
    
    Nep = Ntrials/2;
    
    power_base = mean(allpowvedata(S.design.Xstartlatencies<0,:));
    sem_power_base = std(allpowvedata(S.design.Xstartlatencies<0,:)) ./ sqrt(Nep);
   
    power_stim = mean(allpowvedata(S.design.Xstartlatencies>=0,:));
    sem_power_stim = std(allpowvedata(S.design.Xstartlatencies>=0,:)) ./ sqrt(Nep);
    
    power_stim_cl1 = mean(allpowvedata(find(S.design.X(:,3)),:));
    sem_power_cl1 = std(allpowvedata(find(S.design.X(:,3)),:)) ./ sqrt(Nep);
    power_stim_cl2 = mean(allpowvedata(find(S.design.X(:,4)),:));
    sem_power_cl2 = std(allpowvedata(find(S.design.X(:,4)),:)) ./ sqrt(Nep);
    
%     figure;
%     errorplot(stats.fHz,power_stim_cl1(1:length(stats.fHz)),sem_power_cl1(1:length(stats.fHz)),[0 0 1]);
%     errorplot(stats.fHz,power_stim_cl2(1:length(stats.fHz)),sem_power_cl2(1:length(stats.fHz)),[1 0 0]);
%     errorplot(stats.fHz,power_base(1:length(stats.fHz)),sem_power_base(1:length(stats.fHz)),[0 1 0]);
    
    figure('name',SpmFileName); 
    hs = errorplot(stats.fHz,power_stim(1:length(stats.fHz)),sem_power_stim(1:length(stats.fHz)),[0 0 1]);
    hb = errorplot(stats.fHz,power_base(1:length(stats.fHz)),sem_power_base(1:length(stats.fHz)),[1 0 0]);
    legend([hs hb], {'Stimulus' 'Baseline'});    
    
%     hold on; plot(freq,pwrstim,'b',freq,pwrbase,'r');
    set(gca,'fontsize',15,'fontname','calibri');
    title({[condstr '  stimulation']; num2str(talpositions(maxind,:))});
    xlabel('Frequency (Hz)'); 
    ylabel('Power');
    xlim(FreqBand);
    
    BandHz = find(stats.fHz >= FreqBand(1) & stats.fHz <= FreqBand(2));
    Results.Frequency = stats.fHz(BandHz)'; 
    Results.Stimulus = [Results.Stimulus, power_stim(BandHz)'];   
    Results.Baseline = [Results.Baseline, power_base(BandHz)']; 
    Results.PeakHz = [Results.PeakHz; Results.Frequency(Results.Stimulus(:,h)==max(Results.Stimulus(:,h)))];
    Results.tf_PeakHz = [Results.PeakHz; tff];
    
    figure;
    hs = errorplot(stats.fHz,power_stim(1:length(stats.fHz)),sem_power_stim(1:length(stats.fHz)),[0 0 1]);
    hb = errorplot(stats.fHz,power_base(1:length(stats.fHz)),sem_power_base(1:length(stats.fHz)),[1 0 0]);
    set(gca,'fontsize',15,'fontname','calibri');
    title({[condstr ' stimulation']; num2str(talpositions(maxind,:))});
    xlabel('Frequency (Hz)'); 
    ylabel('Power');
    xlim(FreqBand);
    legend([hs hb], {'Stimulus' 'Baseline'});    
    saveas(gcf,[condstr '_' num2str(FreqBand(1)) '-' num2str(FreqBand(2)) '_' num2str(GridSize) '_mt.fig']);
%     save([condstr '_' num2str(FreqBand(1)) '-' num2str(FreqBand(2)) '_' num2str(GridSize) '_mt']);

    % Note these VEs are raw, unfiltered data! So really should only look
    % at TF ranges within the band of the covariance window
        
    close all;
end

save(['Bf_mt_' num2str(FreqBand(1)) '-' num2str(FreqBand(2)) '_' num2str(GridSize) '.mat']', 'Results');


    
 
  

 