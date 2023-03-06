function [] = AnalyzePupilMajorMinorAxisCorrelation_Handler_JNeurosci2022(rootFolder,delim,runFromStart)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Handler function for AnalyzePupilMajorMinorAxisCorrelation_JNeurosci2022.mat
%________________________________________________________________________________________________________________________

% create or load results structure
if runFromStart == true
    Results_AxisCorrelation = [];
elseif runFromStart == false
    cd([rootFolder delim 'Analysis Structures\'])
    % load existing results structure, if it exists
    if exist('Results_AxisCorrelation.mat','file') == 2
        load('Results_AxisCorrelation.mat','-mat')
    else
        Results_AxisCorrelation = [];
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
multiWaitbar('Analyzing pupil major-minor axis correlation',0,'Color','P'); pause(0.25);
for bb = 1:length(animalIDs)
    if isfield(Results_AxisCorrelation,(animalIDs{1,bb})) == false
        [Results_AxisCorrelation] = AnalyzePupilMajorMinorAxisCorrelation_JNeurosci2022(animalIDs{1,bb},rootFolder,delim,Results_AxisCorrelation);
    end
    multiWaitbar('Analyzing pupil major-minor axis correlation','Value',aa/waitBarLength);
    aa = aa + 1;
end

end
