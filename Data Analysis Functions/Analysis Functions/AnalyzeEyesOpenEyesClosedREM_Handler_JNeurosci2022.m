function [] = AnalyzeEyesOpenEyesClosedREM_Handler_JNeurosci2022(rootFolder,delim,runFromStart)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Handler function for AnalyzeEyesOpenEyesClosedREM_Handler_JNeurosci2022.mat
%________________________________________________________________________________________________________________________

% create or load results structure
if runFromStart == true
    Results_PupilREM = [];
elseif runFromStart == false
    % load existing results structure, if it exists
    if exist('Results_PupilREM.mat','file') == 2
        load('Results_PupilREM.mat','-mat')
    else
        Results_PupilREM = [];
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
multiWaitbar('Analyzing eyes-open vs. eyes-closed REM events',0,'Color','P'); pause(0.25);
for bb = 1:length(animalIDs)
    if isfield(Results_PupilREM,(animalIDs{1,bb})) == false
        [Results_PupilREM] = AnalyzeEyesOpenEyesClosedREM_JNeurosci2022(animalIDs{1,bb},rootFolder,delim,Results_PupilREM);
    end
    multiWaitbar('Analyzing eyes-open vs. eyes-closed REM events','Value',aa/waitBarLength);
    aa = aa + 1;
end

end
