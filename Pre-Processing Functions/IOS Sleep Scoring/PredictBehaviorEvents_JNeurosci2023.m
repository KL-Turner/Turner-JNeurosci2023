function [ScoringResults] = PredictBehaviorEvents_JNeurosci2023(animalID,startingDirectory,baselineDirectory,modelDataFileIDs,modelName)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Use trained model to predict arousal states on all files
%________________________________________________________________________________________________________________________

disp(['Predicting behavior events using ' modelName ' model']); disp(' ')
% load appropriate model
modelDirectory = [startingDirectory '\Figures\Sleep Models\'];
cd(modelDirectory)
notManual = 'y';
if strcmp(modelName,'SVM') == true
    modelName = [animalID '_IOS_SVM_SleepScoringModel.mat'];
    load(modelName)
    modelType = 'SVM';
    MDL = SVM_MDL;
elseif strcmp(modelName,'Ensemble') == true
    modelName = [animalID '_IOS_EC_SleepScoringModel.mat'];
    load(modelName)
    modelType = 'Ensemble';
    MDL = EC_MDL;
elseif strcmp(modelName,'Forest') == true
    modelName = [animalID '_IOS_RF_SleepScoringModel.mat'];
    load(modelName)
    modelType = 'Forest';
    MDL = RF_MDL;
elseif strcmp(modelName,'Manual') == true
    notManual = 'n';
    modelType = 'Manual';
end
cd(baselineDirectory)
% go through each manual file and sleep score it using the chosen model
if strcmp(notManual,'y') == true
    for a = 1:size(modelDataFileIDs,1)
        modelDataFileID = modelDataFileIDs(a,:);
        if a == 1
            load(modelDataFileID)
            dataLength = size(paramsTable,1);
            joinedTable = paramsTable;
            joinedFileList = cell(size(paramsTable,1),1);
            joinedFileList(:) = {modelDataFileID};
        else
            load(modelDataFileID)
            fileIDCells = cell(size(paramsTable,1),1);
            fileIDCells(:) = {modelDataFileID};
            joinedTable = vertcat(joinedTable,paramsTable); %#ok<*AGROW>
            joinedFileList = vertcat(joinedFileList,fileIDCells);
        end
    end
    scoringTable = joinedTable;
    [labels,~] = predict(MDL,scoringTable);
    % apply a logical patch on the REM events
    REMindex = strcmp(labels,'REM Sleep');
    numFiles = length(labels)/dataLength;
    reshapedREMindex = reshape(REMindex,dataLength,numFiles);
    patchedREMindex = [];
    % patch missing REM indeces due to theta band falling off
    for c = 1:size(reshapedREMindex,2)
        remArray = reshapedREMindex(:,c);
        patchedREMarray = LinkBinaryEvents_JNeurosci2023(remArray',[5,0]);
        patchedREMindex = vertcat(patchedREMindex,patchedREMarray'); %#ok<*AGROW>
    end
    % change labels for each event
    for d = 1:length(labels)
        if patchedREMindex(d,1) == 1
            labels{d,1} = 'REM Sleep';
        end
    end
    % export results
    reshapedLabels = reshape(labels,dataLength,numFiles);
    for e = 1:size(modelDataFileIDs,1)
        modelDataFileID = modelDataFileIDs(e,:);
        [~,~,fileID] = GetFileInfo_JNeurosci2023(modelDataFileID);
        fileIDs{e,1} = fileID;
        labelArrays{e,1} = reshapedLabels(:,e);
    end
    ScoringResults.fileIDs = fileIDs;
    ScoringResults.labels = labelArrays;
    ScoringResults.allfileIDs = joinedFileList;
    ScoringResults.alllabels = labels;
else
    ScoringResults = [];
end
save([animalID '_' modelType '_ScoringResults'],'ScoringResults')
cd(startingDirectory)

end
