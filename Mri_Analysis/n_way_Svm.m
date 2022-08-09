function Prediction = n_way_Svm(X_test, X_train, y_train, y_test, Kernel)
%
% Prediction = n_way_Svm(X_test, X_train, y_train, y_test, [Kernel])
%
% n-way SVM classifier (using Matlab's internal SVM)
%

if nargin < 5
    Kernel = 'linear';
end

Classes = unique(y_train);
Nclasses = length(Classes);

% Which comparisons do we need to make?
Nbins = Nclasses * (Nclasses-1) / 2;
Comparisons = [];
for i = 1:4
    for j = i:4
        if Classes(i) ~= Classes(j)
            Comparisons = [Comparisons; Classes(i) Classes(j)];
        end
    end
end

% Run N*(N-1)/2 binary classifications
All_predictions = [];
for k = 1:Nbins
    Xtr = X_train(ismember(y_train, Comparisons(k,:)),:);
    ytr = y_train(ismember(y_train, Comparisons(k,:)));
    Xte = X_test;
    
    Svm = svmtrain(Xtr, ytr, 'Kernel_Function', Kernel);
    ypr = svmclassify(Svm, Xte);
    
    All_predictions = [All_predictions ypr];
end

% Voting procedure
Prediction = [];
for m = 1:size(All_predictions,1)
    Votes = [];
    for n = 1:Nclasses
        Votes = [Votes sum(All_predictions(m,:) == n)];
    end
    [W Wi] = max(Votes);
    Prediction = [Prediction; Classes(Wi)];
end

