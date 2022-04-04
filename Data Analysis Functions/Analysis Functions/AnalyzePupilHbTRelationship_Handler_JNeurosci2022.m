function [] = AnalyzePupilHbTRelationship_Pupil_Handler(rootFolder,delim,runFromStart)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: 
%________________________________________________________________________________________________________________________

% create or load results structure
if runFromStart == true
    Results_PupilHbTRelationship = [];
elseif runFromStart == false
    % load existing results structure, if it exists
    if exist('Results_PupilHbTRelationship.mat','file') == 2
        load('Results_PupilHbTRelationship.mat','-mat')
    else
        Results_PupilHbTRelationship = [];
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
multiWaitbar('Analyzing pupil-hbt relationship during each behavior',0,'Color','P'); pause(0.25);
for bb = 1:length(animalIDs)
    if isfield(Results_PupilHbTRelationship,(animalIDs{1,bb})) == false
        [Results_PupilHbTRelationship] = AnalyzePupilHbTRelationship_Pupil(animalIDs{1,bb},rootFolder,delim,Results_PupilHbTRelationship);
    end
    multiWaitbar('Analyzing pupil-hbt relationship during each behavior','Value',aa/waitBarLength);
    aa = aa + 1;
end

end
