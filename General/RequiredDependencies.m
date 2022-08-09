function fList = RequiredDependencies(FuncName)
% Returns a cell array containing a list of the dependencies of FuncName

[fList, pList] = matlab.codetools.requiredFilesAndProducts(FuncName);
fList = fList';
