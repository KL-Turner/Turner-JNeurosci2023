function [] = GetFuncDependencies(functionName)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Outputs all dependencies of a given function, including subfunction dependencies. It also verifies this by
%          looping through each subfunction and further checking that it doesn't have any dependencies.
%________________________________________________________________________________________________________________________

% control for input
if nargin == 0
    functionName = input('Input function name: ','s');
end
% detect OS and set delimeter to correct value. This typically isn't necessary in newer versions of Matlab.
if isunix
    delimiter = '/';
elseif ispc
    delimiter = '\';
else
    disp('Platform not currently supported');
    return
end
% attempt to use Matlab's codetool feature to detect function dependencies.
try
    [fList,~] = matlab.codetools.requiredFilesAndProducts(functionName);
catch
    % catch the instance where the filename does not exist or was spelled incorrectly.
    disp(['Matlab function ' functionName ' does not appear to exist or to be included in the current filepath(s)']);
    return
end
% find the unique functions listed and pull the names out.
uniqueFuncPaths = unique(fList);
allDepFuncNames = cell(size(uniqueFuncPaths,2),1);
allDepFuncPaths = cell(size(uniqueFuncPaths,2),1);
for x = 1:size(uniqueFuncPaths,2)
    allDepFuncPaths{x,1} = uniqueFuncPaths{1,x};
    funcDelimiters = strfind(allDepFuncPaths{x,1},delimiter);
    allDepFuncNames{x,1} = char(strip(allDepFuncPaths{x,1}(funcDelimiters(end):end),delimiter));
end
% table
T = table(allDepFuncNames,allDepFuncPaths,'VariableNames',{'FileNames','FilePaths'});
figure('Name','Function dependencies table','NumberTitle','off')
u = uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,'RowName',T.Properties.RowNames,'Units','Normalized','Position',[0,0,1,1]);
set(u,'ColumnWidth',{300})
pause(1)

end
