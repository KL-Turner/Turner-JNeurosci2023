function [] = AnalyzeLaggedPupilSleepModelAccuracy_Handler_JNeurosci2022(rootFolder,delim,runFromStart)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Handler function for AnalyzeLaggedPupilSleepModelAccuracy_JNeurosci2022.mat
%________________________________________________________________________________________________________________________

% create or load results structure
if runFromStart == true
    Results_LaggedPupilSleepModel = [];
elseif runFromStart == false
    % load existing results structure, if it exists
    if exist('Results_LaggedPupilSleepModel.mat','file') == 2
        load('Results_LaggedPupilSleepModel.mat','-mat')
    else
        Results_LaggedPupilSleepModel = [];
    end
end
% determine waitbar length
waitBarLength = 0;
folderList = dir('Data');
folderList = folderList(~startsWith({folderList.name},'.'));
animalIDs = {folderList.name};
waitBarLength = waitBarLength + length(animalIDs);
% run analysis for each animal in the group
aa = 1;
multiWaitbar('Training lagged pupil sleep models and validating accuracy',0,'Color','P'); pause(0.25);
for bb = 1:length(animalIDs)
    if isfield(Results_LaggedPupilSleepModel,(animalIDs{1,bb})) == false
        [Results_LaggedPupilSleepModel] = AnalyzeLaggedPupilSleepModelAccuracy_JNeurosci2022(animalIDs{1,bb},rootFolder,delim,Results_LaggedPupilSleepModel);
    end
    multiWaitbar('Training lagged pupil sleep models and validating accuracy','Value',aa/waitBarLength);
    aa = aa + 1;
end

end
