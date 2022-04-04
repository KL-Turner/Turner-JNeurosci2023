function [] = AnalyzePupilGammaRelationship_Pupil_Handler(rootFolder,delim,runFromStart)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: 
%________________________________________________________________________________________________________________________

% create or load results structure
if runFromStart == true
    Results_PupilGammaRelationship = [];
elseif runFromStart == false
    % load existing results structure, if it exists
    if exist('Results_PupilGammaRelationship.mat','file') == 2
        load('Results_PupilGammaRelationship.mat','-mat')
    else
        Results_PupilGammaRelationship = [];
    end
end
% determine waitbar length
waitBarLength = 0;
folderList = dir('Data');
folderList = folderList(~startsWith({folderList.name}, '.'));
animalIDs = {folderList.name};
waitBarLength = waitBarLength + length(animalIDs);
% run analysis for each animal in the group
aa = 1;
multiWaitbar('Analyzing pupil-gamma relationship during each behavior',0,'Color','P'); pause(0.25);
for bb = 1:length(animalIDs)
    if isfield(Results_PupilGammaRelationship,(animalIDs{1,bb})) == false
        [Results_PupilGammaRelationship] = AnalyzePupilGammaRelationship_Pupil(animalIDs{1,bb},rootFolder,delim,Results_PupilGammaRelationship);
    end
    multiWaitbar('Analyzing pupil-gamma relationship during each behavior','Value',aa/waitBarLength);
    aa = aa + 1;
end

end
