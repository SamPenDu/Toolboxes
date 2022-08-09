function bf_samgam(FreqBand, GridSize, SpmFileName, Preview)

if nargin == 0
    FreqBand = [30 80];
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
 
[condtypes,Ncond,condind]=unique(D.conditions);
left0ind=strmatch('left0',D.conditions);
left180ind=strmatch('left180',D.conditions);
right0ind=strmatch('right0',D.conditions);
right180ind=strmatch('right180',D.conditions);

%% Results output
Results = struct;
Results.GridSize = GridSize;
Results.FreqBand = FreqBand;
Results.Peaks = [];
Results.PeakHz = [];
Results.Frequency = [];
Results.Stimulus = [];
Results.Baseline = [];
Results.PercSign = [];
Results.Ts = [];

%% Left & right hemifield
for h = 1:2
    switch h
        case 1
            % Left-side stimulation
            hemistr = 'LVF';
            triallist = [left0ind; left180ind];
        case 2
            % Right-side stimulation
            hemistr = 'RVF';
            triallist = [right0ind; right180ind];
    end

    fulltriallist = [triallist;triallist];
    trialtype = [];  

    fullX = zeros(length(fulltriallist),2); 
    fullX(1:length(triallist),1) = 1;
    fullX(length(triallist)+1:end,2) = 1;

%     prestim_lat = -1.200;
%     poststim_lat = 0.300;
    prestim_lat = -1.000;
    poststim_lat = 0.500;

    Xstartlatency = zeros(size(fullX,1),1);
    Xstartlatency(1:length(triallist)) = prestim_lat;
    Xstartlatency(length(triallist)+1:end) = poststim_lat;

    S.design.Xwindowduration = 1.0; % in seconds (width of comparison window for all conditions)
%     S.design.Xwindowduration = 1.2; % in seconds (width of comparison window for all conditions)
    S.design.Xtrials = fulltriallist; % correspond to the trials (in this case a row is a trial)
    S.design.Xstartlatencies = Xstartlatency; %% correspond to latencies within trials

    S.design.X = fullX;
    S.design.contrast = [-1  1]';

    S.freqbands{1} = FreqBand;
    S.gridstep = GridSize;
    S.preview = Preview;
    S.return_weights = 1;

    % S.Niter = 100;
    S.D = D;
    [stats,talpositions,allepochdata] = sam_eeg_ft_beamformer_lcmv(S);

    %% Look at induced
    [maxval,maxind] = max(stats.tstat);
    disp([hemistr ' peak at: ' num2str(talpositions(maxind,:))]);
    % Is this the right peak?
    peakvox = input('Peak voxel coordinates (enter to accept suggestion): ');
    if ~isempty(peakvox)
        maxind = elemind(stats.tstat, peakvox);
    end
    
    Results.Peaks = [Results.Peaks; talpositions(maxind,:)];

    maxweights = stats.ctf_weights(maxind,:);
    Ntrials = size(allepochdata,1);

    for f = 1:Ntrials,
        vedata = maxweights*squeeze(allepochdata(f,:,:));
        vetrialdata(f,:) = vedata; % Put this into pretty wavelet trans?
        vedata = detrend(vedata);
        vedata = vedata .* hanning(length(vedata))';
        fftvedata = fft(vedata);

        allpowvedata(f,:) = fftvedata .* conj(fftvedata);
    end; % for f

    Nep = Ntrials/2;
    power_base = mean(allpowvedata(S.design.X(:,1)==1,:));
    sem_power_base = std(allpowvedata(S.design.X(:,1)==1,:)) ./ sqrt(Nep);
    power_stim = mean(allpowvedata(S.design.X(:,2)==1,:));
    sem_power_stim = std(allpowvedata(S.design.X(:,2)==1,:)) ./ sqrt(Nep);
    power_change = mean((allpowvedata(S.design.X(:,2)==1,:)-allpowvedata(S.design.X(:,1)==1,:))./allpowvedata(S.design.X(:,1)==1,:))*100;
    sem_power_change = std((allpowvedata(S.design.X(:,2)==1,:)-allpowvedata(S.design.X(:,1)==1,:))./allpowvedata(S.design.X(:,1)==1,:))./sqrt(Nep)*100;
    [h_psc p_psc ci_psc stats_psc] = ttest(allpowvedata(S.design.X(:,2)==1,:),allpowvedata(S.design.X(:,1)==1,:));
    t_power_change = stats_psc.tstat;
    
    figure('name',SpmFileName); widerthantall;
    subplot(1,2,1);
    samlegend({'Stimulus' 'Baseline'}, [0 0 1; 1 0 0]);
    errorplot(stats.fHz,power_stim(1:length(stats.fHz)),sem_power_stim(1:length(stats.fHz)),[0 0 1]);
    errorplot(stats.fHz,power_base(1:length(stats.fHz)),sem_power_base(1:length(stats.fHz)),[1 0 0]);
%     errorplot(stats.fHz,power_change(1:length(stats.fHz)),sem_power_change(1:length(stats.fHz)),[0 0 0]);
    set(gca,'fontsize',15,'fontname','calibri');
    title([hemistr ' ~ ' num2str(talpositions(maxind,:))]);
    xlabel('Oscillation frequency (Hz)'); 
    ylabel('% signal change');
    xlim(FreqBand);
    subplot(1,2,2); hold on;
    plot(stats.fHz,t_power_change(1:length(stats.fHz)),'k');
    gaussfit = fit(stats.fHz', t_power_change(1:length(stats.fHz))', 'gauss1');
    plot(gaussfit, 'r');
    line([gaussfit.b1 gaussfit.b1], ylim, 'color', 'r', 'linestyle', ':');
    set(gca,'fontsize',15,'fontname','calibri');
    title([hemistr ' ~ ' num2str(talpositions(maxind,:))]);
    xlabel('Oscillation frequency (Hz)'); 
    ylabel('T-statistic');
    xlim(FreqBand);
    BandHz = find(stats.fHz >= FreqBand(1) & stats.fHz <= FreqBand(2));
    Results.Frequency = stats.fHz(BandHz)'; 
    Results.Stimulus = [Results.Stimulus, power_stim(BandHz)'];   
    Results.Baseline = [Results.Baseline, power_base(BandHz)']; 
    Results.PercSign = [Results.PercSign, power_change(BandHz)'];
    Results.Ts = [Results.Ts, t_power_change(BandHz)'];
    Results.PeakHz = [Results.PeakHz; gaussfit.b1];
    saveas(gcf,['Psc_' hemistr '_' num2str(FreqBand(1)) '-' num2str(FreqBand(2)) '_' num2str(GridSize) '.fig']);
    close(gcf);
    
    % Note these VEs are raw, unfiltered data! So really should only look
    % at TF ranges within the band of the covariance window
end

save(['Bf_psc' num2str(FreqBand(1)) '-' num2str(FreqBand(2)) '_' num2str(GridSize) '.mat']', 'Results');


    
 
  

 