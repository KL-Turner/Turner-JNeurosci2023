function [] = AnalyzePupilAreaSleepProbability_Handler_JNeurosci2023(rootFolder,delim,runFromStart)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Handler function for AnalyzePupilAreaSleepProbability_JNeurosci2023.mat
%________________________________________________________________________________________________________________________

% create or load results structure
if runFromStart == true
    Results_SleepProbability = [];
elseif runFromStart == false
    cd([rootFolder delim 'Analysis Structures\'])
    % load existing results structure, if it exists
    if exist('Results_SleepProbability.mat','file') == 2
        load('Results_SleepProbability.mat','-mat')
    else
        Results_SleepProbability = [];
    end
    cd([rootFolder delim])
end
folderList = dir('Data');
folderList = folderList(~startsWith({folderList.name},'.'));
animalIDs = {folderList.name};
% run analysis for each animal in the group
if isempty(Results_SleepProbability) == true
    AnalyzePupilAreaSleepProbability_JNeurosci2023(animalIDs,rootFolder,delim);
end

end
