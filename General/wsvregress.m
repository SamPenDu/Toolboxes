function model = wsvregress(IV, DV) 
% Runs a multiple regression analysis modeling both between- and within-
% subject variance explicitly (similar to wsvcorr). IVin and DVin are the 
% independent and dependent variable. These are matrices with each row 
% being one subject and each column being one within-subject observation.
%

%% Prepare regressors
BetweenFx = mean(IV,2); % Mean per participant
BetweenFx = repmat(BetweenFx, [1, size(IV,2)]); % Data averaged per subject across within-subject observations
WithinFx = repmat(mean(IV,1), [size(IV,1), 1]); % Data averaged across subjects but separated by within-subject observation

%% Combine design & dependent variable vectors
X = [BetweenFx(:), WithinFx(:)]; % Regressor design matrix
Y = DV(:); % Dependent variable

%% Statistical test
model = LinearModel.fit(X, Y, 'VarNames', {'Between-Subject' 'Within-Subject' 'Dependent Variable'});
