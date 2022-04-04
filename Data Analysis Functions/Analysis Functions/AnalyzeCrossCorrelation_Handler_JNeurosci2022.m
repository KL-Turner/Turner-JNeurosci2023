function [] = AnalyzeCrossCorrelation_Pupil_Handler(rootFolder,delim,runFromStart)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Handle core function 'AnalyzeCrossCorrelation' inputs and outputs for each animal
%________________________________________________________________________________________________________________________

% create or load results structure
if runFromStart == true
    Results_CrossCorrelation = [];
elseif runFromStart == false
    % load existing results structure, if it exists
    if exist('Results_CrossCorrelation.mat','file') == 2
        load('Results_CrossCorrelation.mat','-mat')
    else
        Results_CrossCorrelation = [];
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
multiWaitbar('Analyzing cross correlation during each behavior',0,'Color','P'); pause(0.25);
for bb = 1:length(animalIDs)
    if isfield(Results_CrossCorrelation,(animalIDs{1,bb})) == false
        [Results_CrossCorrelation] = AnalyzeCrossCorrelation_Pupil(animalIDs{1,bb},rootFolder,delim,Results_CrossCorrelation);
    end
    multiWaitbar('Analyzing cross correlation during each behavior','Value',aa/waitBarLength);
    aa = aa + 1;
end

end
