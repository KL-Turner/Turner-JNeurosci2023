function [] = AnalyzeSleepModelCoherence_Pupil_Handler(~,~,runFromStart)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Handle core function 'AnalyzeCrossCorrelation' inputs and outputs for each animal
%________________________________________________________________________________________________________________________

% create or load results structure
if runFromStart == true
    Results_PupilModelCoherence = [];
elseif runFromStart == false
    % load existing results structure, if it exists
    if exist('Results_PupilModelCoherence.mat','file') == 2
        load('Results_PupilModelCoherence.mat','-mat')
    else
        Results_PupilModelCoherence = [];
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
multiWaitbar('Analyzing coherence bewteen pupil model true and predicted scores',0,'Color','P'); pause(0.25);
for bb = 1:length(animalIDs)
    if isfield(Results_PupilModelCoherence,(animalIDs{1,bb})) == false
        [Results_PupilModelCoherence] = AnalyzePupilModelCoherence_Pupil(animalIDs{1,bb},Results_PupilModelCoherence);
    end
    multiWaitbar('Analyzing coherence bewteen pupil model true and predicted scores','Value',aa/waitBarLength);
    aa = aa + 1;
end

end
