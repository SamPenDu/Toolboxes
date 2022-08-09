function Prediction = Correlation_Classifier_PCA(Samples, Training, Group, Param, Npc)
%Prediction = Correlation_Classifier_PCA(Sample, Training, Group, Param, [Npc])
% 
% Nearest-neighbour classification using correlation coefficients.
%
%   'Samples' contains the test data set (observations by features)
%
%   'Training' contains the training set (observations by features)
%
%   'Group' contains class labels for each observation in the training set 
%
%   'Param' defines what preprocessing is done on the data sets:
%       char 'PCA' = transforms data set into principal component space 
%       char 'PCA!' = transforms data set into principal component space
%                      and then ranks the components by their f-statistic
%                      deriving the final accuracy from the Npc best components
%       double N = truncates the voxels beyond N       
%
%   'Npc' is optional and only relevant for when PCA is used.
%       It is a scalar indicating how many principal components to include.
%       If this is not defined (or zero), all non-zero eigenvectors are used.
%
% Samples and Training must have the same number of features (columns).
%
% Returns a vector with predicted class labels for Samples in Prediction.

if nargin < 5
    Npc = 0;
end

% Number of conditions
Conds = unique(Group);
N_conds = length(Conds);

%% Preprocessing
if ischar(Param) && strfind(Param, 'PCA')
    % Principal component analysis
    Samples = Samples - repmat(nanmean(Training), size(Samples,1), 1);  % Centre test set on mean from training set
    [PC_coefs Training PC_vars] = princomp(Training); % Transform training set & get principal components
    Samples = Samples * PC_coefs; % Transform test set into principal component space
    if strcmpi(Param, 'PCA!') 
        % Sort training data into conditions
        F = [];
        for v = 1:size(Training,2)
            C = NaN(sum(Group == Conds(1)), N_conds);
            for cn = 1:N_conds
                C(:,cn) = Training(Group == Conds(cn), v);
            end
            % Calculate F-values
            [h p f] = ftest(C);
            F = [F f];
        end
        F(isnan(F)) = 0; % Remove NaNs
         % Sort by t-values
        [Fs ix] = sort(F, 'descend');
        % Apply sorting to data sets
        Training = Training(:,ix);
        Samples = Samples(:,ix);
        if nargin < 5
            error('Number of principle components undefined!')
        end
        if Npc == 0
            % Final non-zero variance component
            Npc = find(PC_vars > 0, 1, 'last');
        end
    elseif nargin < 5 || Npc == 0
        % Only components that explain more than 5% of variance
        PC_vars = PC_vars/sum(PC_vars)*100; 
        Npc = find(PC_vars > 5, 1, 'last');
    end
    % Remove components of no interest
    Training = Training(:,1:Npc);
    Samples = Samples(:,1:Npc);
else
    % Remove voxels beyond number given in Param
    if Param <= size(Training,2)
        Training = Training(:,1:Param);
        Samples = Samples(:,1:Param);
    end
end

%% Calculate the template patterns
Templates = NaN(N_conds, size(Training,2));
for i = 1 : N_conds
    X = Training(Group == Conds(i), :);
    Templates(i,:) = nanmean(X,1);
end

%% Classification of test set
Prediction = NaN(size(Samples,1),1);
% Loop through sample patterns
for i = 1 : size(Samples,1)
    % Loop through templates
    Correl_Coefs = [];
    for j = 1 : N_conds        
        if size(Samples,2) > 1
            % Correlation of test sample & template
            R = corr(Samples(i,:)', Templates(j,:)');
        else
            % If only one feature
            R = 1 - abs((Samples(i,1)-Templates(j,1)) / (Samples(i,1)+Templates(j,1)));
        end
        Correl_Coefs = [Correl_Coefs; R];
    end
    
    % Determine minimal distance template
    y = find(Correl_Coefs == max(Correl_Coefs));
    
    % Store class label
    Prediction(i) = Conds(y(1));
end
