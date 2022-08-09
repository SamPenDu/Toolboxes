function bf_samgam_rpt_grb_dss(FreqBand, GridSize, SpmFileName, Preview)
%% repeated measures

restoredefaultpath;
addpath(genpath('D:\Documents\MATLAB\Spm8'));
addpath('C:\Users\sschwarz\Documents\My Dropbox\SamScripts\Meg_Analysis');
addpath('C:\Users\sschwarz\Documents\My Dropbox\SamScripts\General');

if nargin == 0
    FreqBand = [30 100];
    GridSize = 10;
    SpmFileName = uigetfile('*.mat');
    Preview = true;
elseif nargin == 1
    GridSize = 10;
    SpmFileName = uigetfile('*.mat');
    Preview = true;
elseif nargin == 2
    SpmFileName = uigetfile('*.mat');
    Preview = true;
elseif nargin == 3
    Preview = true;
end

%% Set up analysis
D = spm_eeg_load(SpmFileName);
 
[condtypes,Ncond,condind]=unique(D.conditions); condtypes; Ncond;
left0ind=strmatch('left0',D.conditions); %% left 0
left180ind=strmatch('left180',D.conditions); %% left 180
right0ind=strmatch('right0',D.conditions); % right 0
right180ind=strmatch('right180',D.conditions); %% right 180

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
for h = 1:2
    switch h
        case 1
            % Left-side stimulation
            hemistr = 'LVF';
            triallist_cl1 = [left0ind];
            triallist_cl2 = [left180ind];
            
        case 2
            % Right-side stimulation
            hemistr = 'RVF';
            triallist_cl1 = [right0ind];
            triallist_cl2 = [right180ind];
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
    disp([hemistr ' peak at: ' num2str(talpositions(maxind,:))]);
%     % Is this the right peak?
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
    title([hemistr ' stimulation']);
    set(gca,'xtick',1:300:1801,'xticklabel',[0:300:1800]/D.fsample-1.5);
    set(gca,'ytick',0:10:100,'yticklabel',100:-10:0);
    xlabel('Time (s)');
    ylabel('Frequency (Hz)'); 
    saveas(gcf,['tf_' hemistr '_' num2str(FreqBand(1)) '-' num2str(FreqBand(2)) '_' num2str(GridSize) '_rpt.fig']);
    
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
         figure;
      %plot(freq,pwrall,freq,pwrstim,freq,pwrbase);
      %legend('all','stim','base');
       
      figure;
      plot(freq,pwrstim,freq,pwrbase);
      legend('stim','base');
    %% now fit thse models to the trials
%     figure; hold on;
%     colorstr='bcrg';
%       for f = 1:Ntrials,
%         f
%         
%         vedata = maxweights*squeeze(stats.allepochdata(f,:,:));
%         vetrialdata(f,:) = vedata; % Put this into pretty wavelet trans?
%         vedata = detrend(vedata);
%         if S.design.Xstartlatencies(f)>=0,
%                 pmodel=bestpstim;
%             else
%                 pmodel=bestpbase;
%             end;
%         
%         vedata = vedata .* hanning(length(vedata))';
%         fvedata = filtfilt(B, A, vedata);
%         
%          artrial(f)=spm_ar (fvedata,pmodel,0); %
%         p=spm_ar_freq(artrial(f),freq,D.fsample);
%         colind=find(S.design.X(f,:)==1);
%        plot(freq,p,colorstr(colind));
%     end; % for f

      
         
%     p=spm_ar_freq(arall(f),freq,D.fsample);
%       
%     figure; hold on;
%     
%     for f=1:Ntrials, %% now fit this model to every epoch
%              colind=find(S.design.X(f,:)==1);
%            arall(f)=spm_ar (fvetrialdata(f,:),maxmaxorder,0);
%            freq=[1:100];
%             p=spm_ar_freq(arall(f),freq,D.fsample);
%             plot(freq,p,colorstr(colind));
%             xlabel('Frequency');
%             ylabel('Power');
%            allarfeatures(f,:)=[arall(f).a_mean' arall(f).mean_beta arall(f).a_cov(1,1) arall(f).a_cov(1,2) ];
%            allpower(f,:)=p;
%         end;
%       
%       
%      %% alternative decomp of spectra
%      stimind=find(S.design.Xstartlatencies>=0); 
%      [Uvd,Sng]=spm_svd(allpowvedata(stimind,:)'*allpowvedata(stimind,:));
%      useind=min(find(cumsum(diag(Sng))./sum(diag(Sng))>0.90));
%      dstimallpowvedata=allpowvedata(stimind,:)*Uvd(:,1:useind);
% 
%      Yred=dstimallpowvedata;
%      %Yred=allarfeatures(:,1:3);
%      Nclass=45;
%      xba=mean(Yred(1:Nclass,:)); %% 1* useind
% yba=mean(Yred(Nclass+1:Nclass*2,:));
% %% assume equal number of trials in both conditions- not necessary but easier
% C=cov(Yred);
% nx=Nclass;ny=Nclass;
% T2=(nx*ny/(nx+ny))*(xba-yba)*pinv(C)*(xba-yba)';
% p=useind; % n features
% Fval=T2*(nx+ny-p--1)/((nx+ny-2)*p);
% pval=1-spm_Fcdf(Fval,p,nx+ny-1-p)

     
%    model_orders=1:6;
%     Nvbit=10;
%     [bestvbmix,Fmodelev,allmods]=cluster3d_data_spm(allarfeatures(1:3,:),model_orders,Nvbit,[]);
%     
%     
%     sample=allarfeatures(1:10);
%     training=allarfeatures(11:end,:);
%     [val,group]=max(S.design.X');
%     CLASS = CLASSIFY(sample,training,group)
%     
%     ar=spm_ar (x,max_p,0);
    
    
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
%     
%     figure('name',SpmFileName); 
%     samlegend({'Stimulus' 'Baseline'}, [0 0 1; 1 0 0]);
%     errorplot(stats.fHz,power_stim(1:length(stats.fHz)),sem_power_stim(1:length(stats.fHz)),[0 0 1]);
%     errorplot(stats.fHz,power_base(1:length(stats.fHz)),sem_power_base(1:length(stats.fHz)),[1 0 0]);
    
    
%     hold on; plot(freq,pwrstim,'b',freq,pwrbase,'r');
%     set(gca,'fontsize',15,'fontname','calibri');
%     title({[hemistr '  stimulation']; num2str(talpositions(maxind,:))});
%     xlabel('Frequency (Hz)'); 
%     ylabel('Power');
%     xlim(FreqBand);
    BandHz = find(stats.fHz >= FreqBand(1) & stats.fHz <= FreqBand(2));
    Results.Frequency = stats.fHz(BandHz)'; 
    Results.Stimulus = [Results.Stimulus, power_stim(BandHz)'];   
    Results.Baseline = [Results.Baseline, power_base(BandHz)']; 
    Results.PeakHz = [Results.PeakHz; Results.Frequency(Results.Stimulus(:,h)==max(Results.Stimulus(:,h)))];
    
    
    
    figure;
    samlegend({'Stimulus' 'Baseline'}, [0 0 1; 1 0 0]);
    errorplot(stats.fHz,power_stim(1:length(stats.fHz)),sem_power_stim(1:length(stats.fHz)),[0 0 1]);
    errorplot(stats.fHz,power_base(1:length(stats.fHz)),sem_power_base(1:length(stats.fHz)),[1 0 0]);
    set(gca,'fontsize',15,'fontname','calibri');
    title({[hemistr ' stimulation']; num2str(talpositions(maxind,:))});
    xlabel('Frequency (Hz)'); 
    ylabel('Power');
    xlim(FreqBand);
    BandHz = find(stats.fHz >= FreqBand(1) & stats.fHz <= FreqBand(2));
    Results.Frequency = stats.fHz(BandHz)'; 
    Results.Stimulus = [Results.Stimulus, power_stim(BandHz)'];   
    Results.Baseline = [Results.Baseline, power_base(BandHz)']; 
    Results.PeakHz = [Results.PeakHz; Results.Frequency(Results.Stimulus(:,h)==max(Results.Stimulus(:,h)))];
    saveas(gcf,[hemistr '_' num2str(FreqBand(1)) '-' num2str(FreqBand(2)) '_' num2str(GridSize) '_rpt.fig']);
    
    % Note these VEs are raw, unfiltered data! So really should only look
    % at TF ranges within the band of the covariance window
    
    close all;
end

save(['Bf_rpt_' num2str(FreqBand(1)) '-' num2str(FreqBand(2)) '_' num2str(GridSize) '.mat']', 'Results');


    
 
  

 