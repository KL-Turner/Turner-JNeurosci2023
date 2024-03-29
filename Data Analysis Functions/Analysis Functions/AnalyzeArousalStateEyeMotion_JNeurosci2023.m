function [Results_EyeMotion] = AnalyzeArousalStateEyeMotion_JNeurosci2023(animalID,rootFolder,delim,Results_EyeMotion)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Analyze the eye motion during each arousal state
%________________________________________________________________________________________________________________________

% load model
modelDirectory = [rootFolder delim 'Data' delim animalID delim 'Figures' delim 'Sleep Models'];
cd(modelDirectory)
modelName = [animalID '_IOS_RF_SleepScoringModel.mat'];
load(modelName)
% go to animal's data location
dataLocation = [rootFolder delim 'Data' delim animalID delim 'Bilateral Imaging'];
cd(dataLocation)
% go to data and load the model files
modelDataFileStruct = dir('*_ModelData.mat');
modelDataFile = {modelDataFileStruct.name}';
modelDataFileIDs = char(modelDataFile);
% proc data file list
procDataFileStruct = dir('*_ProcData.mat');
procDataFile = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFile);
% load resting baseline file
baselineDataFileStruct = dir('*_RestingBaselines.mat');
baselineDataFiles = {baselineDataFileStruct.name}';
baselineDataFileID = char(baselineDataFiles);
load(baselineDataFileID)
AddPupilSleepParameters_JNeurosci2023(procDataFileIDs,RestingBaselines)
% go through each file and sleep score the data
bb = 1;
for aa = 1:size(modelDataFileIDs,1)
    modelDataFileID = modelDataFileIDs(aa,:);
    procDataFileID = procDataFileIDs(aa,:);
    load(procDataFileID)
    load(modelDataFileID)
    if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
        try
            puffs = ProcData.data.stimulations.LPadSol;
        catch
            puffs = ProcData.data.solenoids.LPadSol;
        end
        if isempty(puffs) == true
            if bb == 1
                dataLength = size(paramsTable,1);
                joinedTable = paramsTable;
                joinedEyeMotion = ProcData.sleep.parameters.Pupil.eyeMotion;
                joinedFileList = cell(size(paramsTable,1),1);
                joinedFileList(:) = {modelDataFileID};
                bb = bb + 1;
            else
                load(modelDataFileID)
                fileIDCells = cell(size(paramsTable,1),1);
                fileIDCells(:) = {modelDataFileID};
                joinedTable = vertcat(joinedTable,paramsTable); % #ok<*AGROW>
                joinedEyeMotion = vertcat(joinedEyeMotion,ProcData.sleep.parameters.Pupil.eyeMotion);
                joinedFileList = vertcat(joinedFileList,fileIDCells);
                bb = bb + 1;
            end
        end
    end
end
scoringTable = joinedTable;
[labels,~] = predict(RF_MDL,scoringTable);
% apply a logical patch on the REM events
REMindex = strcmp(labels,'REM Sleep');
numFiles = length(labels)/dataLength;
reshapedREMindex = reshape(REMindex,dataLength,numFiles);
patchedREMindex = [];
% patch missing REM indeces due to theta band falling off
for b = 1:size(reshapedREMindex,2)
    remArray = reshapedREMindex(:,b);
    patchedREMarray = LinkBinaryEvents_JNeurosci2023(remArray',[5,0]);
    patchedREMindex = vertcat(patchedREMindex,patchedREMarray'); %#ok<*AGROW>
end
% change labels for each event
for c = 1:length(labels)
    if patchedREMindex(c,1) == 1
        labels{c,1} = 'REM Sleep';
    end
end
% convert strings to numbers for easier comparisons
data.awake = []; data.nrem = []; data.rem = [];
for d = 1:length(labels)
    if strcmp(labels{d,1},'Not Sleep') == true
        data.awake = vertcat(data.awake,sum(joinedEyeMotion{d,1},'omitnan'));
    elseif strcmp(labels{d,1},'NREM Sleep') == true
        data.nrem = vertcat(data.nrem,sum(joinedEyeMotion{d,1},'omitnan'));
    elseif strcmp(labels{d,1},'REM Sleep') == true
        data.rem = vertcat(data.rem,sum(joinedEyeMotion{d,1},'omitnan'));
    end
end
% save results
Results_EyeMotion.(animalID).Awake = data.awake;
Results_EyeMotion.(animalID).NREM = data.nrem;
Results_EyeMotion.(animalID).REM = data.rem;
% save data
cd([rootFolder delim 'Analysis Structures\'])
save('Results_EyeMotion.mat','Results_EyeMotion')
cd([rootFolder delim])

end
