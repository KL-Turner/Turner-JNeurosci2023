function [] = AnalyzeStimulusBlinks_Handler_JNeurosci2023(rootFolder,delim,runFromStart)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Handler function for AnalyzeStimulusBlinks_JNeurosci2023.mat
%________________________________________________________________________________________________________________________

% create or load results structure
if runFromStart == true
    Results_StimulusBlinks = [];
elseif runFromStart == false
    cd([rootFolder delim 'Analysis Structures\'])
    % load existing results structure, if it exists
    if exist('Results_StimulusBlinks.mat','file') == 2
        load('Results_StimulusBlinks.mat','-mat')
    else
        Results_StimulusBlinks = [];
    end
    cd([rootFolder delim])
end
% determine waitbar length
waitBarLength = 0;
folderList = dir('Data');
folderList = folderList(~startsWith({folderList.name},'.'));
animalIDs = {folderList.name};
waitBarLength = waitBarLength + length(animalIDs);
% run analysis for each animal in the group
aa = 1;
multiWaitbar('Analyzing post-stumulus blinking behavior',0,'Color','P'); pause(0.25);
for bb = 1:length(animalIDs)
    if isfield(Results_StimulusBlinks,(animalIDs{1,bb})) == false
        [Results_StimulusBlinks] = AnalyzeStimulusBlinks_JNeurosci2023(animalIDs{1,bb},rootFolder,delim,Results_StimulusBlinks);
    end
    multiWaitbar('Analyzing post-stumulus blinking behavior','Value',aa/waitBarLength);
    aa = aa + 1;
end

end
