function [Results_PupilSleepModel,Results_PhysioSleepModel,Results_CombinedSleepModel] = AnalyzeSleepModelAccuracy_JNeurosci2023(animalID,rootFolder,delim,Results_PupilSleepModel,Results_PhysioSleepModel,Results_CombinedSleepModel)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: train/validate machine learning classifier using bootstrapped random forest
%________________________________________________________________________________________________________________________

dataLocation = [rootFolder delim 'Data' delim animalID delim 'Bilateral Imaging'];
cd(dataLocation)
% load resting baseline file
baselineDataFileStruct = dir('*_RestingBaselines.mat');
baselineDataFiles = {baselineDataFileStruct.name}';
baselineDataFileID = char(baselineDataFiles);
load(baselineDataFileID)
% go to animal's data location
dataLocation = [rootFolder delim 'Data' delim animalID delim 'Training Data'];
cd(dataLocation)
% character list of all ProcData files
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
% prepare pupil training data by updating parameters
AddPupilSleepParameters_JNeurosci2023(procDataFileIDs,RestingBaselines)
CreatePupilModelDataSet_JNeurosci2023(procDataFileIDs)
UpdatePupilTrainingDataSet_JNeurosci2023(procDataFileIDs)
% prepare physio training data by updating parameters
AddSleepParameters_JNeurosci2023(procDataFileIDs,RestingBaselines,'manualSelection')
CreateModelDataSet_JNeurosci2023(procDataFileIDs)
UpdateTrainingDataSets_JNeurosci2023(procDataFileIDs)
% training data file IDs
pupilTrainingDataFileStruct = dir('*_PupilTrainingData.mat');
pupilTrainingDataFiles = {pupilTrainingDataFileStruct.name}';
pupilTrainingDataFileIDs = char(pupilTrainingDataFiles);
% only use training files that match those of the pupil
for aa = 1:size(pupilTrainingDataFileIDs)
    trainingDataFileIDs(aa,:) = strrep(pupilTrainingDataFileIDs(aa,:),'Pupil','');
end
% load each updated training set and concatenate the data into table
pupilJoinedTable = []; physioJoinedTable = []; combinedJoinedTable = [];
for bb = 1:size(pupilTrainingDataFileIDs,1)
    % pupil table
    pupilTrainingTableFileID = pupilTrainingDataFileIDs(bb,:);
    load(pupilTrainingTableFileID)
    pupilJoinedTable = vertcat(pupilJoinedTable,pupilTrainingTable);
    % physio table
    trainingTableFileID = trainingDataFileIDs(bb,:);
    load(trainingTableFileID)
    physioJoinedTable = vertcat(physioJoinedTable,trainingTable);
    % combined table
    combinedJoinedTable = vertcat(combinedJoinedTable,horzcat(trainingTable(:,1:end - 1),pupilTrainingTable));
end
shuffleSeedA = randperm(size(pupilJoinedTable,1));
P = 0.70 ;
iterations = 100;
numTrees = 128;
paroptions = statset('UseParallel',true);
%% pupil model - separate the manual scores into 3 groups based on arousal classification
pupilJoinedAwakeTable = []; pupilJoinedNREMTable = []; pupilJoinedREMTable = [];
pupilRandomTable = pupilJoinedTable(shuffleSeedA,:);
for aa = 1:size(pupilRandomTable,1)
    if strcmp(pupilRandomTable.behavState{aa,1},'Not Sleep') == true
        pupilJoinedAwakeTable = vertcat(pupilJoinedAwakeTable,pupilRandomTable(aa,:));
    elseif strcmp(pupilRandomTable.behavState{aa,1},'NREM Sleep') == true
        pupilJoinedNREMTable = vertcat(pupilJoinedNREMTable,pupilRandomTable(aa,:));
    elseif strcmp(pupilRandomTable.behavState{aa,1},'REM Sleep') == true
        pupilJoinedREMTable = vertcat(pupilJoinedREMTable,pupilRandomTable(aa,:));
    end
end
% shuffle training table
pupilTrainingTable = vertcat(pupilJoinedAwakeTable(1:round(P*size(pupilJoinedAwakeTable,1)),:), ...
    pupilJoinedNREMTable(1:round(P*size(pupilJoinedNREMTable,1)),:),...
    pupilJoinedREMTable(1:round(P*size(pupilJoinedREMTable,1)),:));
shuffleSeedB = randperm(size(pupilTrainingTable,1));
pupilTrainingTable = pupilTrainingTable(shuffleSeedB,:);
% shuffle testing table
pupilTestingTable = vertcat(pupilJoinedAwakeTable(round(P*size(pupilJoinedAwakeTable,1) + 1:end),:), ...
    pupilJoinedNREMTable(round(P*size(pupilJoinedNREMTable,1) + 1:end),:),...
    pupilJoinedREMTable(round(P*size(pupilJoinedREMTable,1) + 1:end),:));
shuffleSeedC = randperm(size(pupilTestingTable,1));
pupilTestingTable = pupilTestingTable(shuffleSeedC,:);
% train on odd data
pupilXtraining = pupilTrainingTable(:,1:end - 1);
pupilYtraining = pupilTrainingTable(:,end);
% test on even data
pupilXtesting = pupilTestingTable(:,1:end - 1);
pupilYtesting = pupilTestingTable(:,end);
% random forest
bestAccuracy = 0;
for aa = 1:iterations
    RF_MDL = TreeBagger(numTrees,pupilXtraining,pupilYtraining,'Method','Classification','Surrogate','all','OOBPrediction','on','ClassNames',{'Not Sleep','NREM Sleep','REM Sleep'},'Options',paroptions);
    % use the model to generate a set of predictions
    [pupilTestingPredictions,~] = predict(RF_MDL,pupilXtesting);
    % confusion chart
    RF_confMat = figure;
    CM = confusionchart(pupilYtesting.behavState,pupilTestingPredictions);
    CM.ColumnSummary = 'column-normalized';
    CM.RowSummary = 'row-normalized';
    CM.Title = [animalID ' Testing Data'];
    confVals = CM.NormalizedValues;
    % totalScoresA = sum(confVals([7,8,9]));
    % modelAccuracyA = (sum(confVals(9)/totalScoresA))*100;
    % totalScoresB = sum(confVals([3,6,9]));
    % modelAccuracyB = (sum(confVals(9)/totalScoresB))*100;
    % modelAccuracy = (modelAccuracyA + modelAccuracyB)/2;
    totalScores = sum(confVals(:));
    modelAccuracy = (sum(confVals([1,5,9])/totalScores))*100;
    CM.Title = {'Pupil RF',['total accuracy: ' num2str(modelAccuracy) ' (%)']};
    close(RF_confMat)
    if modelAccuracy > bestAccuracy
        bestAccuracy = modelAccuracy;
        bestMDL = RF_MDL;
    end
end
% determine the misclassification probability (for classification trees) for out-of-bag observations in the training data
outOfBagError = oobError(bestMDL,'Mode','Ensemble');
% use the model to generate a set of predictions
[pupilTestingPredictions,~] = predict(bestMDL,pupilXtesting);
% save labels for later confusion matrix
Results_PupilSleepModel.(animalID).pupil.mdl = bestMDL;
Results_PupilSleepModel.(animalID).pupil.outOfBagError = outOfBagError;
Results_PupilSleepModel.(animalID).pupil.trueTestingLabels = pupilYtesting.behavState;
Results_PupilSleepModel.(animalID).pupil.predictedTestingLabels = pupilTestingPredictions;
%% physio model - separate the manual scores into 3 groups based on arousal classification
physioJoinedAwakeTable = []; physioJoinedNREMTable = []; physioJoinedREMTable = [];
physioRandomTable = physioJoinedTable(shuffleSeedA,:);
for aa = 1:size(physioRandomTable,1)
    if strcmp(physioRandomTable.behavState{aa,1},'Not Sleep') == true
        physioJoinedAwakeTable = vertcat(physioJoinedAwakeTable,physioRandomTable(aa,:));
    elseif strcmp(physioRandomTable.behavState{aa,1},'NREM Sleep') == true
        physioJoinedNREMTable = vertcat(physioJoinedNREMTable,physioRandomTable(aa,:));
    elseif strcmp(physioRandomTable.behavState{aa,1},'REM Sleep') == true
        physioJoinedREMTable = vertcat(physioJoinedREMTable,physioRandomTable(aa,:));
    end
end
physioTrainingTable = vertcat(physioJoinedAwakeTable(1:round(P*size(physioJoinedAwakeTable,1)),:), ...
    physioJoinedNREMTable(1:round(P*size(physioJoinedNREMTable,1)),:),...
    physioJoinedREMTable(1:round(P*size(physioJoinedREMTable,1)),:));
physioTrainingTable = physioTrainingTable(shuffleSeedB,:);
physioTestingTable = vertcat(physioJoinedAwakeTable(round(P*size(physioJoinedAwakeTable,1) + 1:end),:), ...
    physioJoinedNREMTable(round(P*size(physioJoinedNREMTable,1) + 1:end),:),...
    physioJoinedREMTable(round(P*size(physioJoinedREMTable,1) + 1:end),:));
physioTestingTable = physioTestingTable(shuffleSeedC,:);
% train on odd data
physioXtraining = physioTrainingTable(:,1:end - 1);
physioYtraining = physioTrainingTable(:,end);
% test on even data
physioXtesting = physioTestingTable(:,1:end - 1);
physioYtesting = physioTestingTable(:,end);
% random forest
bestAccuracy = 0;
for aa = 1:iterations
    RF_MDL = TreeBagger(numTrees,physioXtraining,physioYtraining,'Method','Classification','Surrogate','all','OOBPrediction','on','ClassNames',{'Not Sleep','NREM Sleep','REM Sleep'},'Options',paroptions);
    % use the model to generate a set of predictions
    [physioTestingPredictions,~] = predict(RF_MDL,physioXtesting);
    % confusion chart
    RF_confMat = figure;
    CM = confusionchart(physioYtesting.behavState,physioTestingPredictions);
    CM.ColumnSummary = 'column-normalized';
    CM.RowSummary = 'row-normalized';
    CM.Title = [animalID ' Testing Data'];
    confVals = CM.NormalizedValues;
    % totalScoresA = sum(confVals([7,8,9]));
    % modelAccuracyA = (sum(confVals(9)/totalScoresA))*100;
    % totalScoresB = sum(confVals([3,6,9]));
    % modelAccuracyB = (sum(confVals(9)/totalScoresB))*100;
    % modelAccuracy = (modelAccuracyA + modelAccuracyB)/2;
    totalScores = sum(confVals(:));
    modelAccuracy = (sum(confVals([1,5,9])/totalScores))*100;
    CM.Title = {'Physio RF',['total accuracy: ' num2str(modelAccuracy) ' (%)']};
    close(RF_confMat)
    if modelAccuracy > bestAccuracy
        bestAccuracy = modelAccuracy;
        bestMDL = RF_MDL;
    end
end
% determine the misclassification probability (for classification trees) for out-of-bag observations in the training data
outOfBagError = oobError(bestMDL,'Mode','Ensemble');
% use the model to generate a set of predictions
[physioTestingPredictions,~] = predict(bestMDL,physioXtesting);
% save labels for later confusion matrix
Results_PhysioSleepModel.(animalID).physio.mdl = bestMDL;
Results_PhysioSleepModel.(animalID).physio.outOfBagError = outOfBagError;
Results_PhysioSleepModel.(animalID).physio.trueTestingLabels = physioYtesting.behavState;
Results_PhysioSleepModel.(animalID).physio.predictedTestingLabels = physioTestingPredictions;
%% combined model - separate the manual scores into 3 groups based on arousal classification
combinedJoinedAwakeTable = []; combinedJoinedNREMTable = []; combinedJoinedREMTable = [];
combinedRandomTable = combinedJoinedTable(shuffleSeedA,:);
for aa = 1:size(combinedRandomTable,1)
    if strcmp(combinedRandomTable.behavState{aa,1},'Not Sleep') == true
        combinedJoinedAwakeTable = vertcat(combinedJoinedAwakeTable,combinedRandomTable(aa,:));
    elseif strcmp(combinedRandomTable.behavState{aa,1},'NREM Sleep') == true
        combinedJoinedNREMTable = vertcat(combinedJoinedNREMTable,combinedRandomTable(aa,:));
    elseif strcmp(combinedRandomTable.behavState{aa,1},'REM Sleep') == true
        combinedJoinedREMTable = vertcat(combinedJoinedREMTable,combinedRandomTable(aa,:));
    end
end
combinedTrainingTable = vertcat(combinedJoinedAwakeTable(1:round(P*size(combinedJoinedAwakeTable,1)),:), ...
    combinedJoinedNREMTable(1:round(P*size(combinedJoinedNREMTable,1)),:),...
    combinedJoinedREMTable(1:round(P*size(combinedJoinedREMTable,1)),:));
combinedTrainingTable = combinedTrainingTable(shuffleSeedB,:);
combinedTestingTable = vertcat(combinedJoinedAwakeTable(round(P*size(combinedJoinedAwakeTable,1) + 1:end),:), ...
    combinedJoinedNREMTable(round(P*size(combinedJoinedNREMTable,1) + 1:end),:),...
    combinedJoinedREMTable(round(P*size(combinedJoinedREMTable,1) + 1:end),:));
combinedTestingTable = combinedTestingTable(shuffleSeedC,:);
% train on odd data
combinedXtraining = combinedTrainingTable(:,1:end - 1);
combinedYtraining = combinedTrainingTable(:,end);
% test on even data
combinedXtesting = combinedTestingTable(:,1:end - 1);
combinedYtesting = combinedTestingTable(:,end);
% random forest
bestAccuracy = 0;
for aa = 1:iterations
    RF_MDL = TreeBagger(numTrees,combinedXtraining,combinedYtraining,'Method','Classification','Surrogate','all','OOBPrediction','on','ClassNames',{'Not Sleep','NREM Sleep','REM Sleep'},'Options',paroptions);
    % use the model to generate a set of predictions
    [combinedTestingPredictions,~] = predict(RF_MDL,combinedXtesting);
    % confusion chart
    RF_confMat = figure;
    CM = confusionchart(combinedYtesting.behavState,combinedTestingPredictions);
    CM.ColumnSummary = 'column-normalized';
    CM.RowSummary = 'row-normalized';
    CM.Title = [animalID ' Testing Data'];
    confVals = CM.NormalizedValues;
    % totalScoresA = sum(confVals([7,8,9]));
    % modelAccuracyA = (sum(confVals(9)/totalScoresA))*100;
    % totalScoresB = sum(confVals([3,6,9]));
    % modelAccuracyB = (sum(confVals(9)/totalScoresB))*100;
    % modelAccuracy = (modelAccuracyA + modelAccuracyB)/2;
    totalScores = sum(confVals(:));
    modelAccuracy = (sum(confVals([1,5,9])/totalScores))*100;
    CM.Title = {'Combined RF',['total accuracy: ' num2str(modelAccuracy) ' (%)']};
    close(RF_confMat)
    if modelAccuracy > bestAccuracy
        bestAccuracy = modelAccuracy;
        bestMDL = RF_MDL;
    end
end
% determine the misclassification probability (for classification trees) for out-of-bag observations in the training data
outOfBagError = oobError(bestMDL,'Mode','Ensemble');
% use the model to generate a set of predictions
[combinedTestingPredictions,~] = predict(bestMDL,combinedXtesting);
% save labels for later confusion matrix
Results_CombinedSleepModel.(animalID).combined.mdl = bestMDL;
Results_CombinedSleepModel.(animalID).combined.outOfBagError = outOfBagError;
Results_CombinedSleepModel.(animalID).combined.trueTestingLabels = combinedYtesting.behavState;
Results_CombinedSleepModel.(animalID).combined.predictedTestingLabels = combinedTestingPredictions;
%% save data
cd([rootFolder delim 'Analysis Structures\'])
save('Results_PupilSleepModel.mat','Results_PupilSleepModel')
save('Results_PhysioSleepModel.mat','Results_PhysioSleepModel')
save('Results_CombinedSleepModel.mat','Results_CombinedSleepModel')
cd([rootFolder delim])

end
