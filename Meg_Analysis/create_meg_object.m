function D = create_meg_object(data)
%
% Function for creating an SPM M/EEG dataset from beamformed data in a matrix. 
%

% Some details about the data
%--------------------------------------------------------------------------
Nsamples  = size(data,2);
Ntrials   = size(data,3);
TimeOnset = -0.1; % in sec
Fsample = 600;

chlabels = {'Bf'};

% define the output file name
%--------------------------------------------------------------------------
fname = 'Beamformed data';

% create the time axis (should be the same for all trials)
%--------------------------------------------------------------------------
timeaxis = [0:(Nsamples-1)]./Fsample + TimeOnset;

% Create the Fieldtrip raw struct
%--------------------------------------------------------------------------

ftdata = [];

for i = 1:Ntrials
   ftdata.trial{i} = squeeze(data(:, :, i));
   ftdata.time{i} = timeaxis;
end


ftdata.fsample = Fsample;
ftdata.label = chlabels;
ftdata.label = ftdata.label(:);

% Convert the ftdata struct to SPM M\EEG dataset
%--------------------------------------------------------------------------
D = spm_eeg_ft2spm(ftdata, fname);

% Examples of providing additional information in a script
% [] comes instead of an index vector and means that the command
% applies to all channels/all trials.
%--------------------------------------------------------------------------
D = type(D, 'single');                        % Sets the dataset type
D = chantype(D, [], 'LFP');                   % Sets the channel type 
D = conditions(D, 1:Ntrials, 'Condition 1');  % Sets the condition label

