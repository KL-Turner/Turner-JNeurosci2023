function [] = AnalyzePupilExample_Handler_JNeurosci2023(rootFolder,delim,runFromStart)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Handler function for AnalyzePupilExample_JNeurosci2023.mat
%________________________________________________________________________________________________________________________

% create or load results structure
if runFromStart == true
    Results_Example = [];
elseif runFromStart == false
    cd([rootFolder delim 'Analysis Structures\'])
    % load existing results structure, if it exists
    if exist('Results_Example.mat','file') == 2
        load('Results_Example.mat','-mat')
    else
        Results_Example = [];
    end
    cd([rootFolder delim])
end
% run analysis for each animal in the group
if isempty(Results_Example) == true
    AnalyzePupilExample_JNeurosci2023(rootFolder,delim,Results_Example);
end

end
