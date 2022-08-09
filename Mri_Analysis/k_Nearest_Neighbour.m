function Prediction = k_Nearest_Neighbour(Samples, Training, Group, Param, k)
%Prediction = k_Nearest_Neighbour(Sample, Training, Group, Param, k)
% 
% Non-linear k-nearest-neighbour classification.
%
%   'Samples' contains the test data set (observations by features)
%
%   'Training' contains the training set (observations by features)
%
%   'Group' contains class labels for each observation in the training set 
%
%   'Param' reranks the voxels based on the main effect between
%     conditions and then only uses up to N voxels       
%
%   'k' defines the number of neighbours to test (best to choose an odd number)
%
% Samples and Training must have the same number of features (columns).
%
% Returns a vector with predicted class labels for Samples in Prediction.

if nargin < 6
    Rnkd = 1;
end

% Number of conditions
Conds = unique(Group);
N_conds = length(Conds);

%% Preprocessing
% Remove voxels beyond number given in Param
if Param <= size(Training,2)
    Training = Training(:,1:Param);
    Samples = Samples(:,1:Param);
end

%% Classification of test set
Prediction = NaN(size(Samples,1),1);
% Loop through sample patterns
for i = 1 : size(Samples,1)
    if size(Samples,2) > 1
        D = corr(Samples(i,:)', Training')';
    else
        D = 1 - abs((repmat(Samples(i),size(Training,1),1) - Training) ./ (repmat(Samples(i),size(Training,1),1) + Training));
    end
    [D Dx] = sort(D, 'descend');
    knb = Dx(1:k);
    % Voting method
    n = hist(Group(knb),Conds);
    y = Conds(n==max(n));
    
    % Store class label
    Prediction(i) = y;
end
