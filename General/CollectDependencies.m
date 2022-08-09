function CollectDependencies(FuncName, Exclusions, DepFolder)
%
% CollectDependencies(FuncName, Exclusions, DepFolder)
%
% Copies all the required dependencies for function FuncName into DepFolder.
% Exclusions is a cell array containing strings in pathnames you want to
% exclude from this process, e.g. {'Psychtoolbox' 'spm12'}

mkdir(DepFolder); % Make the dependencies folder if needed
clc

disp(['Collecting dependencies for ' FuncName]);
disp(' ');
Dependencies = RequiredDependencies(FuncName);
disp(Dependencies);
disp(' ');

if ischar(Exclusions)
    Exclusions = {Exclusions};
end
disp('Excluding folders containing:')
disp(Exclusions);
disp(' ');

disp('Copying files...');

% Loop thru dependencies
for i = 1:length(Dependencies)
    CollectThis = true;
    % Loop thru exclusions
    for j = 1:length(Exclusions)
        if strfind(Dependencies{i}, Exclusions{j}) 
            CollectThis = false;
        end
    end
    % Copy if needed
    if CollectThis
        dos(['copy ' Dependencies{i} ' ' DepFolder '\']);
        disp(Dependencies{i});
    end
end
disp(' ');