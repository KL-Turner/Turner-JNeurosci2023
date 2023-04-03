function [Results_StateTime] = AnalyzeAnimalStateTime_JNeurosci2023(animalID,rootFolder,delim,Results_StateTime)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Determine the duration of imaging and duration spent in each arousal state for all animals
%________________________________________________________________________________________________________________________

% cd to animal directory
dataLocation = [rootFolder delim 'Data' delim animalID delim 'Bilateral Imaging'];
cd(dataLocation)
% find and load sleep scoring results
scoringResultsFileStruct = dir('*Forest_ScoringResults.mat');
scoringResultsFile = {scoringResultsFileStruct.name}';
scoringResultsFileID = char(scoringResultsFile);
load(scoringResultsFileID,'-mat')
% character list of ProcData file IDs
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
% go through each file and determine duration of imaging
bb = 1;
catLabels = {};
totalFiles = size(procDataFileIDs,1);
timePerFile = 15; % minutes
timePerBin = 5; % seconds
for aa = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(aa,:);
    [~,~,fileID] = GetFileInfo_JNeurosci2023(procDataFileID);
    load(procDataFileID,'-mat')
    if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
        for cc = 1:length(ScoringResults.fileIDs)
            scoringFileID = ScoringResults.fileIDs{cc,1};
            if strcmp(fileID,scoringFileID) == true
                labels = ScoringResults.labels{cc,1};
            end
        end
        catLabels = cat(1,catLabels,labels);
        goodFiles = bb;
        bb = bb + 1;
    end
end
% go through and determine time per arousal state
for aa = 1:length(catLabels)
    label = catLabels{aa,1};
    if strcmp(label,'Not Sleep') == true
        awakeLogical(aa,1) = 1;
        nremLogical(aa,1) = 0;
        remLogical(aa,1) = 0;
    elseif strcmp(label,'NREM Sleep') == true
        awakeLogical(aa,1) = 0;
        nremLogical(aa,1) = 1;
        remLogical(aa,1) = 0;
    elseif strcmp(label,'REM Sleep') == true
        awakeLogical(aa,1) = 0;
        nremLogical(aa,1) = 0;
        remLogical(aa,1) = 1;
    end
end
% save results
Results_StateTime.(animalID).totalHours = (totalFiles*timePerFile)/60; % minutes to hours
Results_StateTime.(animalID).goodHours = (goodFiles*timePerFile)/60; % minutes to hours
Results_StateTime.(animalID).usablePerc = (Results_StateTime.(animalID).goodHours/Results_StateTime.(animalID).totalHours)*100;
Results_StateTime.(animalID).awakeHours = ((sum(awakeLogical)*timePerBin)/60)/60; % sec to minutes to hours
Results_StateTime.(animalID).awakePerc = (sum(awakeLogical)/length(awakeLogical))*100;
Results_StateTime.(animalID).nremHours = ((sum(nremLogical)*timePerBin)/60)/60; % sec to minutes to hours
Results_StateTime.(animalID).nremPerc = (sum(nremLogical)/length(nremLogical))*100;
Results_StateTime.(animalID).remHours = ((sum(remLogical)*timePerBin)/60)/60; % sec to minutes to hours
Results_StateTime.(animalID).remPerc = (sum(remLogical)/length(remLogical))*100;
% save data
cd([rootFolder delim 'Analysis Structures\'])
save('Results_StateTime.mat','Results_StateTime')
cd([rootFolder delim])

end
