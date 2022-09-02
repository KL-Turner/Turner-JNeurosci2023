function [Results_PupilSleepModel,Results_PhysioSleepModel,Results_CombinedSleepModel] = AnalyzeSleepModelAccuracy_Turner2022(animalID,rootFolder,delim,Results_PupilSleepModel,Results_PhysioSleepModel,Results_CombinedlSleepModel)
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
% % prepare pupil training data by updating parameters
% AddPupilSleepParameters_Turner2022(procDataFileIDs,RestingBaselines)
% CreatePupilModelDataSet_Turner2022(procDataFileIDs)
% UpdatePupilTrainingDataSet_Turner2022(procDataFileIDs)
% % prepare physio training data by updating parameters
% AddSleepParameters_Turner2022(procDataFileIDs,RestingBaselines,'manualSelection')
% CreateModelDataSet_Turner2022(procDataFileIDs)
% UpdateTrainingDataSets_Turner2022(procDataFileIDs)
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
    pupilTrainingTableFileID = pupilTrainingDataFileIDs(bb,:);
    load(pupilTrainingTableFileID)
    pupilJoinedTable = vertcat(pupilJoinedTable,pupilTrainingTable);
    trainingTableFileID = trainingDataFileIDs(bb,:);
    load(trainingTableFileID)
    physioJoinedTable = vertcat(physioJoinedTable,trainingTable);
    combinedJoinedTable = vertcat(combinedJoinedTable,horzcat(trainingTable(:,1:end - 1),pupilTrainingTable));
end
shuffleSeed = randperm(size(pupilJoinedTable,1));
iterations = 1;
numTrees = 128;
%% pupil model - separate the manual scores into 3 groups based on arousal classification
pupilJoinedAwakeTable = []; pupilJoinedNREMTable = []; pupilJoinedREMTable = [];
pupilRandomTable = pupilJoinedTable(shuffleSeed,:);
for aa = 1:size(pupilRandomTable,1)
    if strcmp(pupilRandomTable.behavState{aa,1},'Not Sleep') == true
        pupilJoinedAwakeTable = vertcat(pupilJoinedAwakeTable,pupilRandomTable(aa,:));
    elseif strcmp(pupilRandomTable.behavState{aa,1},'NREM Sleep') == true
        pupilJoinedNREMTable = vertcat(pupilJoinedNREMTable,pupilRandomTable(aa,:));
    elseif strcmp(pupilRandomTable.behavState{aa,1},'REM Sleep') == true
        pupilJoinedREMTable = vertcat(pupilJoinedREMTable,pupilRandomTable(aa,:));
    end
end
pupilJoinedTableOdd = vertcat(pupilJoinedAwakeTable(1:2:end,:),pupilJoinedNREMTable(1:2:end,:),pupilJoinedREMTable(1:2:end,:));
pupilTrainingTable = pupilJoinedTableOdd(randperm(size(pupilJoinedTableOdd,1)),:);
pupilJoinedTableEven = vertcat(pupilJoinedAwakeTable(2:2:end,:),pupilJoinedNREMTable(2:2:end,:),pupilJoinedREMTable(2:2:end,:));
pupilTestingTable = pupilJoinedTableEven(randperm(size(pupilJoinedTableEven,1)),:);
% train on odd data
pupilXtraining = pupilTrainingTable(:,1:end - 1);
pupilYtraining = pupilTrainingTable(:,end);
% test on even data
pupilXtesting = pupilTestingTable(:,1:end - 1);
pupilYtesting = pupilTestingTable(:,end);
% random forest
bestAccuracy = 0;
for aa = 1:iterations
    RF_MDL = TreeBagger(numTrees,pupilXtraining,pupilYtraining,'Method','Classification','Surrogate','all','OOBPrediction','on','ClassNames',{'Not Sleep','NREM Sleep','REM Sleep'});
    % use the model to generate a set of predictions
    [pupilTestingPredictions,~] = predict(RF_MDL,pupilXtesting);
    % confusion chart
    RF_confMat = figure;
    CM = confusionchart(pupilYtesting.behavState,pupilTestingPredictions);
    CM.ColumnSummary = 'column-normalized';
    CM.RowSummary = 'row-normalized';
    CM.Title = [animalID ' Testing Data'];
    confVals = CM.NormalizedValues;
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
physioRandomTable = physioJoinedTable(shuffleSeed,:);
for aa = 1:size(physioRandomTable,1)
    if strcmp(physioRandomTable.behavState{aa,1},'Not Sleep') == true
        physioJoinedAwakeTable = vertcat(physioJoinedAwakeTable,physioRandomTable(aa,:));
    elseif strcmp(physioRandomTable.behavState{aa,1},'NREM Sleep') == true
        physioJoinedNREMTable = vertcat(physioJoinedNREMTable,physioRandomTable(aa,:));
    elseif strcmp(physioRandomTable.behavState{aa,1},'REM Sleep') == true
        physioJoinedREMTable = vertcat(physioJoinedREMTable,physioRandomTable(aa,:));
    end
end
physioJoinedTableOdd = vertcat(physioJoinedAwakeTable(1:2:end,:),physioJoinedNREMTable(1:2:end,:),physioJoinedREMTable(1:2:end,:));
physioTrainingTable = physioJoinedTableOdd(randperm(size(physioJoinedTableOdd,1)),:);
physioJoinedTableEven = vertcat(physioJoinedAwakeTable(2:2:end,:),physioJoinedNREMTable(2:2:end,:),physioJoinedREMTable(2:2:end,:));
physioTestingTable = physioJoinedTableEven(randperm(size(physioJoinedTableEven,1)),:);
% train on odd data
physioXtraining = physioTrainingTable(:,1:end - 1);
physioYtraining = physioTrainingTable(:,end);
% test on even data
physioXtesting = physioTestingTable(:,1:end - 1);
physioYtesting = physioTestingTable(:,end);
% random forest
bestAccuracy = 0;
for aa = 1:iterations
    RF_MDL = TreeBagger(numTrees,physioXtraining,physioYtraining,'Method','Classification','Surrogate','all','OOBPrediction','on','ClassNames',{'Not Sleep','NREM Sleep','REM Sleep'});
    % use the model to generate a set of predictions
    [physioTestingPredictions,~] = predict(RF_MDL,physioXtesting);
    % confusion chart
    RF_confMat = figure;
    CM = confusionchart(physioYtesting.behavState,physioTestingPredictions);
    CM.ColumnSummary = 'column-normalized';
    CM.RowSummary = 'row-normalized';
    CM.Title = [animalID ' Testing Data'];
    confVals = CM.NormalizedValues;
    totalScores = sum(confVals(:));
    modelAccuracy = (sum(confVals([1,5,9])/totalScores))*100;
    CM.Title = {'physio RF',['total accuracy: ' num2str(modelAccuracy) ' (%)']};
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
combinedRandomTable = combinedJoinedTable(shuffleSeed,:);
for aa = 1:size(combinedRandomTable,1)
    if strcmp(combinedRandomTable.behavState{aa,1},'Not Sleep') == true
        combinedJoinedAwakeTable = vertcat(combinedJoinedAwakeTable,combinedRandomTable(aa,:));
    elseif strcmp(combinedRandomTable.behavState{aa,1},'NREM Sleep') == true
        combinedJoinedNREMTable = vertcat(combinedJoinedNREMTable,combinedRandomTable(aa,:));
    elseif strcmp(combinedRandomTable.behavState{aa,1},'REM Sleep') == true
        combinedJoinedREMTable = vertcat(combinedJoinedREMTable,combinedRandomTable(aa,:));
    end
end
combinedJoinedTableOdd = vertcat(combinedJoinedAwakeTable(1:2:end,:),combinedJoinedNREMTable(1:2:end,:),combinedJoinedREMTable(1:2:end,:));
combinedTrainingTable = combinedJoinedTableOdd(randperm(size(combinedJoinedTableOdd,1)),:);
combinedJoinedTableEven = vertcat(combinedJoinedAwakeTable(2:2:end,:),combinedJoinedNREMTable(2:2:end,:),combinedJoinedREMTable(2:2:end,:));
combinedTestingTable = combinedJoinedTableEven(randperm(size(combinedJoinedTableEven,1)),:);
% train on odd data
combinedXtraining = combinedTrainingTable(:,1:end - 1);
combinedYtraining = combinedTrainingTable(:,end);
% test on even data
combinedXtesting = combinedTestingTable(:,1:end - 1);
combinedYtesting = combinedTestingTable(:,end);
% random forest
bestAccuracy = 0;
for aa = 1:iterations
    RF_MDL = TreeBagger(numTrees,combinedXtraining,combinedYtraining,'Method','Classification','Surrogate','all','OOBPrediction','on','ClassNames',{'Not Sleep','NREM Sleep','REM Sleep'});
    % use the model to generate a set of predictions
    [combinedTestingPredictions,~] = predict(RF_MDL,combinedXtesting);
    % confusion chart
    RF_confMat = figure;
    CM = confusionchart(combinedYtesting.behavState,combinedTestingPredictions);
    CM.ColumnSummary = 'column-normalized';
    CM.RowSummary = 'row-normalized';
    CM.Title = [animalID ' Testing Data'];
    confVals = CM.NormalizedValues;
    totalScores = sum(confVals(:));
    modelAccuracy = (sum(confVals([1,5,9])/totalScores))*100;
    CM.Title = {'combined RF',['total accuracy: ' num2str(modelAccuracy) ' (%)']};
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
cd([rootFolder delim])
save('Results_PupilSleepModel.mat','Results_PupilSleepModel')
save('Results_PhysioSleepModel.mat','Results_PhysioSleepModel')
save('Results_CombinedSleepModel.mat','Results_CombinedSleepModel')

end
