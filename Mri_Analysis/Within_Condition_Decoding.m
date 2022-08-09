function [Accs All_Accs] = Within_Condition_Decoding(Roi, Conds_orig, nVox, Meth, Avgs, Rnkg, Nrml, Dtrd) 
%
%[Accs All_Accs] = Within_Condition_Decoding(Roi, Conds_orig, nVox, Meth, Avgs, Rnkg, Nrml, Dtrd)
%
%   If 'Meth' is prefixed by 'Univ_' this runs a univariate classifier control.
%   If it is prefixed by 'Perm_' this shuffles the training labels before classification.
%

if nargin < 5
    Avgs = true;
    Rnkg = true;
    Nrml = 'Run';
    Dtrd = 'No';
elseif nargin < 6
    Rnkg = true;
    Nrml = 'Run';
    Dtrd = 'No';
elseif nargin < 7
    Nrml = 'Run';
    Dtrd = 'No';
elseif nargin < 8
    Dtrd = 'No';
end

CtrlMeth = Meth;

fn = ['Patterns_' Roi '.mat'];
load(fn);
disp(' ');

Accs = [];

%% Loop over subjects
nSs = length(Patterns);  % Number of subjects
for s = 1:nSs
    All_Accs{s} = [];
    
    disp(['Subject #' num2str(s)]);
    % Current subject's data
    Curr = Patterns(s);
    % Run numbers    
    Runs = unique(Curr.Run)';
    
    % Combine conditions?
    if size(Conds_orig,1) > 1
        for cr = 1:size(Conds_orig,1)
            Curr.Cond(ismember(Curr.Cond, Conds_orig(cr,:))) = cr; 
        end
        Conds = 1:size(Conds_orig,1);
    else
        Conds = Conds_orig;
    end        

    % Only analyse if enough voxels
    if nVox <= size(Curr.Data,2)
        %% Preprocessing data
        disp('   Preprocessing data...');
        
        if strcmpi(Dtrd, 'Run')
            % Detrending each run
            disp('      Detrending each run');
            for r = Runs
                Curr.Data(Curr.Run==r,:) = detrend(Curr.Data(Curr.Run==r,:));
            end
        elseif strcmpi(Dtrd, 'All')
            % Detrending whole matrix
            disp('      Detrending whole matrix');
            Curr.Data = detrend(Curr.Data);
        end

        if strcmpi(Nrml, 'Run');
            % Z-score each run
            disp('      Normalizing each run');
            for r = Runs
                Curr.Data(Curr.Run==r,:) = detrend(Curr.Data(Curr.Run==r,:));
                Curr.Data(Curr.Run==r,:) = zscore(Curr.Data(Curr.Run==r,:));
            end
        elseif strcmpi(Nrml, 'T');
            % T-convert each condition in each run
            disp('      T-statistic for each run');
            D = []; C = [];
            R = []; B = [];
            b = 0;
            for r = Runs
                for c = Conds
                    b = b + 1;
                    [th tp tc ts] = ttest2(Curr.Data(Curr.Run==r & Curr.Cond==c,:), Curr.Data(Curr.Run==r & Curr.Cond==0,:));
                    D = [D; ts.tstat];
                    C = [C; c];
                    B = [B; b];
                end
                R = [R; r * ones(length(Conds),1)];
            end
            % Remove NaNs
            D = rem_nan(D')';
            % Change data structure
            Curr.Data = D;
            Curr.Cond = C;
            Curr.Block = B;
            Curr.Run = R;
        elseif strcmpi(Nrml, 'All')
            % Z-score whole matrix
            disp('      Normalizing whole matrix');
            Curr.Data = zscore(Curr.Data);
        end

        if (Avgs)
            % Average each block
            disp('      Averaging each block');
            Blocks = unique(Curr.Block)';
            X_new = []; % Data matrix
            C_new = []; % Condition labels
            B_new = []; % Block numbers
            R_new = []; % Run numbers
            for b = Blocks
                cX = Curr.Data(Curr.Block==b,:);
                X_new = [X_new; mean(cX,1)];
                cC = Curr.Cond(Curr.Block==b);
                C_new = [C_new; mean(cC,1)];
                cB = Curr.Block(Curr.Block==b);
                B_new = [B_new; mean(cB,1)];
                cR = Curr.Run(Curr.Block==b);
                R_new = [R_new; mean(cR,1)];
            end
            Curr.Data = X_new;
            Curr.Cond = C_new;
            Curr.Block = B_new;
            Curr.Run = R_new;
        end

        % Remove non-brain voxels
        Curr.Voxels(:, Curr.Data(1,:) == 0) = [];
        Curr.Data(:, Curr.Data(1,:) == 0) = [];
        Curr.Voxels(:, isnan(Curr.Data(1,:))) = [];
        Curr.Data(:, isnan(Curr.Data(1,:))) = [];

        % Rank by stimulus evoked response 
        if find(Curr.Cond == 0)
            [vh vp vc vs] = ttest2(Curr.Data(Curr.Cond > 0,:), Curr.Data(Curr.Cond == 0,:));
        else
            [vh vp vc vs] = ttest(Curr.Data, 0);
        end
        [st sx] = sort(vs.tstat, 'descend');
        Curr.Data = Curr.Data(:,sx);
        Curr.Voxels = Curr.Voxels(:,sx);
        Curr.Ts = st;
        
        %% Classification analysis
        disp('   Classification...');

        Predictions = [];
        % Leave-one-run-out procedure
        for r = Runs
            % Divide data sets
            X_train = Curr.Data(Curr.Run~=r & ismember(Curr.Cond, Conds),:);
            y_train = Curr.Cond(Curr.Run~=r & ismember(Curr.Cond, Conds));
            X_test = Curr.Data(Curr.Run==r & ismember(Curr.Cond, Conds),:);
            y_test = Curr.Cond(Curr.Run==r & ismember(Curr.Cond, Conds));

            if (Rnkg)
                % Sort training data into conditions
                F = [];
                for v = 1:size(X_train,2)
                    N_conds = length(unique(y_train));
                    C = NaN(sum(y_train == Conds(1)), N_conds);
                    for cn = 1:N_conds
                        C(:,cn) = X_train(y_train == Conds(cn), v);
                    end
                    % Calculate F-values
                    [h p f] = ftest(C);
                    F = [F f];
                end
                F(isnan(F)) = 0; % Remove NaNs

                % Sort by F-values
                [sFs rnk] = sort(F, 'descend');
                X_train = X_train(:,rnk);
                X_test = X_test(:,rnk);
            end
                        
            % Any control analysis?
            if strcmpi(CtrlMeth(1:3), 'Uni')
                % Univariate classification control?
                Meth = CtrlMeth(6:end);
                % Average across voxels
                X_train = mean(X_train(:,1:nVox),2);
                X_test = mean(X_test(:,1:nVox),2);
            elseif strcmpi(Meth(1:3), 'Per')
                % Permutation control?
                Meth = CtrlMeth(6:end);
                % Shuffle training labels
                y_train = Shuffle(y_train);
            end
            
            if strcmpi(Meth, 'Corr')
                % Correlational classifier
                y_pred = Correlation_Classifier_PCA(X_test, X_train, y_train, nVox);
            elseif strcmpi(Meth, 'PCA')
                % Correlational classifier + PCA
                if Rnkg
                    % Only most discriminative eigenvector!
                    y_pred = Correlation_Classifier_PCA(X_test, X_train, y_train, 'PCA!', 1);    
                else
                    % All non-zero eigenvectors
                    y_pred = Correlation_Classifier_PCA(X_test, X_train, y_train, 'PCA');    
                end
            elseif strfind(upper(Meth), 'KNN')
                % k-nearest neighbour
                kf = str2num(Meth(4:end)); 
                y_pred = k_Nearest_Neighbour(X_test, X_train, y_train, nVox, kf);    
            elseif strcmpi(Meth, 'LDA')
                % Linear discriminant analysis 
                X_train = X_train(:,1:nVox);
                X_test = X_test(:,1:nVox);
                % Dimensionality reduction with PCA
                X_test = X_test - repmat(nanmean(X_train), size(X_test,1), 1);  % Centre test set on mean from training set
                [Pcs X_train eigs] = princomp(X_train); % Transform training set & get principal components
                X_test = X_test * Pcs; % Transform test set into principal component space
                eigs =  eigs/sum(eigs)*100; % Convert eigenvalues into percent of variance
                y_pred = classify(X_test(:,eigs > 5), X_train(:,eigs > 5), y_train);
            elseif strfind(upper(Meth), 'SVM')
                % Support vector machine
                X_train = X_train(:,1:nVox);
                X_test = X_test(:,1:nVox);
                % What SVM kernel?
                if strcmpi(Meth, 'QuaSVM')
                    kf = 'quadratic'; % Quadratic kernel
                elseif strcmpi(Meth, 'RadSVM')
                    kf = 'rbf'; % Gaussian radial basis function kernel (with default scaling factor 1)
                elseif strcmpi(Meth, 'PolSVM')
                    kf = 'polynomial'; % Polynomial kernel (with default order 3)
                elseif strcmpi(Meth, 'MlpSVM')
                    kf = 'mlp'; % Multilayer perceptron kernel (with default scale [1 -1])
                else
                    kf = 'linear'; % Linear kernel
                end
                model = svmtrain(X_train, y_train, 'kernel_function', kf);   % -t = Linear kernel
                y_pred = svmclassify(model, X_test);
            end
            disp(['    ' n2s(sum(y_pred==y_test)) '/' n2s(length(y_test)) ' = ' n2s(100*mean(y_pred==y_test)) '% correct']);
            
            Predictions = [Predictions; mean(y_pred == y_test)];
        end
        
        % Add data to output
        Accs = [Accs; mean(Predictions)];
        All_Accs{s} = [All_Accs{s}; ones(length(Predictions),1)*nVox Predictions];
    else
        % Add filler data to output
        Accs = [Accs; NaN];
        All_Accs{s} = [All_Accs{s}; ones(length(Runs),1)*nVox NaN(length(Runs),1)];
    end
end

