function [] = AnalyzeBlinkCoherogram_Handler_JNeurosci2022(rootFolder,delim,runFromStart)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Handler function for AnalyzeBlinkCoherogram_JNeurosci2022.mat
%________________________________________________________________________________________________________________________

% create or load results structure
if runFromStart == true
    Results_BlinkCoherogram = [];
elseif runFromStart == false
    cd([rootFolder delim 'Analysis Structures\'])
    % load existing results structure, if it exists
    if exist('Results_BlinkCoherogram.mat','file') == 2
        load('Results_BlinkCoherogram.mat','-mat')
    else
        Results_BlinkCoherogram = [];
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
multiWaitbar('Analyzing blinking coherogram',0,'Color','P'); pause(0.25);
for bb = 1:length(animalIDs)
    if isfield(Results_BlinkCoherogram,(animalIDs{1,bb})) == false
        [Results_BlinkCoherogram] = AnalyzeBlinkCoherogram_JNeurosci2022(animalIDs{1,bb},rootFolder,delim,Results_BlinkCoherogram);
    end
    multiWaitbar('Analyzing blinking coherogram','Value',aa/waitBarLength);
    aa = aa + 1;
end

end
