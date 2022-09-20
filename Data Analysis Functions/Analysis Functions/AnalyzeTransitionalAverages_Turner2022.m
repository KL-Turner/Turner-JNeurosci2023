function [Results_Transitions] = AnalyzeTransitionalAverages_Turner2022(animalID,rootFolder,delim,Results_Transitions)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Analyze the pupil transitions between sleep stages
%________________________________________________________________________________________________________________________

% load model
modelDirectory = [rootFolder delim 'Data' delim animalID delim 'Figures' delim 'Sleep Models'];
cd(modelDirectory)
modelName = [animalID '_IOS_RF_SleepScoringModel.mat'];
load(modelName)
% go to animal's data location
dataLocation = [rootFolder delim 'Data' delim animalID delim 'Bilateral Imaging'];
cd(dataLocation)
% function parameters
transitions = {'AWAKEtoNREM','NREMtoAWAKE','NREMtoREM','REMtoAWAKE'};
% go to data and load the model files
modelDataFileStruct = dir('*_ModelData.mat');
modelDataFile = {modelDataFileStruct.name}';
modelDataFileIDs = char(modelDataFile);
baselineFileStruct = dir('*_RestingBaselines.mat');
baselineFile = {baselineFileStruct.name}';
baselineFileID = char(baselineFile);
load(baselineFileID)
samplingRate = 30;
fileDates = fieldnames(RestingBaselines.manualSelection.CBV.adjLH);
% go through each file and sleep score the data
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
[labels,~] = predict(RF_MDL,scoringTable);
% apply a logical patch on the REM events
REMindex = strcmp(labels,'REM Sleep');
numFiles = length(labels)/dataLength;
reshapedREMindex = reshape(REMindex,dataLength,numFiles);
patchedREMindex = [];
% patch missing REM indeces due to theta band falling off
for b = 1:size(reshapedREMindex,2)
    remArray = reshapedREMindex(:,b);
    patchedREMarray = LinkBinaryEvents_Turner2022(remArray',[5,0]);
    patchedREMindex = vertcat(patchedREMindex,patchedREMarray'); %#ok<*AGROW>
end
% change labels for each event
for c = 1:length(labels)
    if patchedREMindex(c,1) == 1
        labels{c,1} = 'REM Sleep';
    end
end
% convert strings to numbers for easier comparisons
labelNumbers = zeros(length(labels),1);
for d = 1:length(labels)
    if strcmp(labels{d,1},'Not Sleep') == true
        labelNumbers(d,1) = 1;
    elseif strcmp(labels{d,1},'NREM Sleep') == true
        labelNumbers(d,1) = 2;
    elseif strcmp(labels{d,1},'REM Sleep') == true
        labelNumbers(d,1) = 3;
    end
end
% reshape
fileIDs = unique(joinedFileList);
fileLabels = reshape(labelNumbers,dataLength,size(modelDataFileIDs,1))';
stringArray = zeros(1,12);
for d = 1:length(transitions)
    transition = transitions{1,d};
    if strcmp(transition,'AWAKEtoNREM') == true
        for e = 1:12
            if e <= 6
                stringArray(1,e) = 1;
            else
                stringArray(1,e) = 2;
            end
        end
    elseif strcmp(transition,'NREMtoAWAKE') == true
        for e = 1:12
            if e <= 6
                stringArray(1,e) = 2;
            else
                stringArray(1,e) = 1;
            end
        end
    elseif strcmp(transition,'NREMtoREM') == true
        for e = 1:12
            if e <= 6
                stringArray(1,e) = 2;
            else
                stringArray(1,e) = 3;
            end
        end
    elseif strcmp(transition,'REMtoAWAKE') == true
        for e = 1:12
            if e <= 6
                stringArray(1,e) = 3;
            else
                stringArray(1,e) = 1;
            end
        end
    end
    % go through and pull out all indeces of matching strings
    idx = 1;
    for f = 1:length(fileIDs)
        fileID = fileIDs{f,1};
        labelArray = fileLabels(f,:);
        indeces = strfind(labelArray,stringArray);
        if isempty(indeces) == false
            for g1 = 1:length(indeces)
                data.(transition).files{idx,1} = fileID;
                data.(transition).startInd(idx,1) = indeces(1,g1);
                idx = idx + 1;
            end
        end
    end
end
% extract data
for h = 1:length(transitions)
    transition = transitions{1,h};
    iqx = 1;
    for i = 1:length(data.(transition).files)
        file = data.(transition).files{i,1};
        startBin = data.(transition).startInd(i,1);
        if startBin > 1 && startBin < (180 - 12)
            [animalID,fileDate,fileID] = GetFileInfo_Turner2022(file);
            strDay = ConvertDate_Turner2022(fileDate);
            procDataFileID = [animalID '_' fileID '_ProcData.mat'];
            load(procDataFileID)
            if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
                startTime = (startBin - 1)*5; % sec
                endTime = startTime + (12*5); % sec
                % pupil data
                [z2,p2,k2] = butter(4,1/(samplingRate/2),'low');
                [sos2,g2] = zp2sos(z2,p2,k2);
                mmDiameter = ProcData.data.Pupil.mmDiameter;
                zDiameter = ProcData.data.Pupil.zDiameter;
                filtmmDiameter = filtfilt(sos2,g2,mmDiameter(startTime*samplingRate + 1:endTime*samplingRate));
                filtzDiameter = filtfilt(sos2,g2,zDiameter(startTime*samplingRate + 1:endTime*samplingRate));
                data.(transition).fileDate{iqx,1} = strDay;
                data.(transition).mmDiameter(iqx,:) = filtmmDiameter;
                data.(transition).zDiameter(iqx,:) = filtzDiameter;
                [z,p,k] = butter(4,10/(samplingRate/2),'low');
                [sos,g] = zp2sos(z,p,k);
                try
                    centroidX = filtfilt(sos,g,ProcData.data.Pupil.patchCentroidX - RestingBaselines.manualSelection.Pupil.patchCentroidX.(strDay).mean);
                    centroidY = filtfilt(sos,g,ProcData.data.Pupil.patchCentroidY - RestingBaselines.manualSelection.Pupil.patchCentroidY.(strDay).mean);
                catch
                    centroidX = ProcData.data.Pupil.patchCentroidX - RestingBaselines.manualSelection.Pupil.patchCentroidX.(strDay).mean;
                    centroidY = ProcData.data.Pupil.patchCentroidY - RestingBaselines.manualSelection.Pupil.patchCentroidY.(strDay).mean;
                end
                data.(transition).centroidX(iqx,:) = centroidX(startTime*samplingRate + 1:endTime*samplingRate);
                data.(transition).centroidY(iqx,:) = centroidY(startTime*samplingRate + 1:endTime*samplingRate);
                iqx = iqx + 1;
            end
        end
    end
end
% take averages of each behavior
for d = 1:length(transitions)
    transition = transitions{1,d};
    % save results
    Results_Transitions.(animalID).(transition).indFileDate = data.(transition).fileDate;
    Results_Transitions.(animalID).(transition).fileDates = fileDates;
    Results_Transitions.(animalID).(transition).mmDiameter = data.(transition).mmDiameter;
    Results_Transitions.(animalID).(transition).zDiameter = data.(transition).zDiameter;
    Results_Transitions.(animalID).(transition).centroidX = data.(transition).centroidX;
    Results_Transitions.(animalID).(transition).centroidY = data.(transition).centroidY;
end
% save data
cd([rootFolder delim])
save('Results_Transitions.mat','Results_Transitions')

end
