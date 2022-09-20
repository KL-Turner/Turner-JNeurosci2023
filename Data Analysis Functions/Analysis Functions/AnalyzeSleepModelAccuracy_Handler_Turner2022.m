function [] = AnalyzeSleepModelAccuracy_Handler_Turner2022(rootFolder,delim,runFromStart)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Handler function for AnalyzeSleepModelAccuracy_Turner2022.mat
%________________________________________________________________________________________________________________________

% create or load results structure
if runFromStart == true
    Results_PupilSleepModel = [];
    Results_PhysioSleepModel = [];
    Results_CombinedSleepModel = [];
elseif runFromStart == false
    % load existing results structure, if it exists
    if exist('Results_PupilSleepModel.mat','file') == 2
        load('Results_PupilSleepModel.mat','-mat')
        load('Results_PhysioSleepModel.mat','-mat')
        load('Results_CombinedSleepModel.mat','-mat')
    else
        Results_PupilSleepModel = [];
        Results_PhysioSleepModel = [];
        Results_CombinedSleepModel = [];
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
multiWaitbar('Training & validating sleep models',0,'Color','P'); pause(0.25);
for bb = 1:length(animalIDs)
    %     if isfield(Results_PupilSleepModel,(animalIDs{1,bb})) == false
    if strcmp(animalIDs{1,bb},'T141') == true
        [Results_PupilSleepModel,Results_PhysioSleepModel,Results_CombinedSleepModel] = AnalyzeSleepModelAccuracy_Turner2022(animalIDs{1,bb},rootFolder,delim,Results_PupilSleepModel,Results_PhysioSleepModel,Results_CombinedSleepModel);
    end
    multiWaitbar('Training & validating sleep models','Value',aa/waitBarLength);
    aa = aa + 1;
end

end
