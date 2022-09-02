function [Results_PupilSleepModelTEST] = AnalyzePupilSleepModelAccuracyTEST_Turner2022(animalID,rootFolder,delim,Results_PupilSleepModelTEST)
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
% go to animal's data location
dataLocation = [rootFolder delim 'Data' delim animalID delim 'Training Data'];
cd(dataLocation)
% character list of all ProcData files
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
load(baselineDataFileID)
% prepare pupil training data by updating parameters
AddPupilSleepParameters_Turner2022(procDataFileIDs,RestingBaselines)
CreatePupilModelDataSet_Turner2022(procDataFileIDs)
UpdatePupilTrainingDataSet_Turner2022(procDataFileIDs)
% prepare physio training data by updating parameters
AddSleepParameters_Turner2022(procDataFileIDs,RestingBaselines,'manualSelection')
CreateModelDataSet_Turner2022(procDataFileIDs)
UpdateTrainingDataSets_Turner2022(procDataFileIDs)
% training data file IDs
pupilTrainingDataFileStruct = dir('*_PupilTrainingData.mat');
pupilTrainingDataFiles = {pupilTrainingDataFileStruct.name}';
pupilTrainingDataFileIDs = char(pupilTrainingDataFiles);
% load each updated training set and concatenate the data into table
joinedTable = [];
for bb = 1:size(pupilTrainingDataFileIDs,1)
    trainingTableFileID = pupilTrainingDataFileIDs(bb,:);
    load(trainingTableFileID)
    joinedTable = vertcat(joinedTable,pupilTrainingTable);
end
% separate the manual scores into 3 groups based on arousal classification
joinedAwakeTable = []; joinedNREMTable = []; joinedREMTable = [];
shuffleSeed = randperm(size(joinedTable,1));
randomTable = joinedTable(randperm(size(joinedTable,1)),:);
for aa = 1:size(randomTable,1)
    if strcmp(randomTable.behavState{aa,1},'Not Sleep') == true
        joinedAwakeTable = vertcat(joinedAwakeTable,randomTable(aa,:));
    elseif strcmp(randomTable.behavState{aa,1},'NREM Sleep') == true
        joinedNREMTable = vertcat(joinedNREMTable,randomTable(aa,:));
    elseif strcmp(randomTable.behavState{aa,1},'REM Sleep') == true
        joinedREMTable = vertcat(joinedREMTable,randomTable(aa,:));
    end
end
joinedTableOdd = vertcat(joinedAwakeTable(1:2:end,:),joinedNREMTable(1:2:end,:),joinedREMTable(1:2:end,:));
trainingTable = joinedTableOdd(randperm(size(joinedTableOdd,1)),:);
joinedTableEven = vertcat(joinedAwakeTable(2:2:end,:),joinedNREMTable(2:2:end,:),joinedREMTable(2:2:end,:));
testingTable = joinedTableEven(randperm(size(joinedTableEven,1)),:);
% train on odd data
Xtraining = trainingTable(:,1:end - 1);
Ytraining = trainingTable(:,end);
% test on even data
Xtesting = testingTable(:,1:end - 1);
Ytesting = testingTable(:,end);
%% random forest
numTrees = 128;
RF_MDL = TreeBagger(numTrees,Xtraining,Ytraining,'Method','Classification','Surrogate','all','OOBPrediction','on','ClassNames',{'Not Sleep','NREM Sleep','REM Sleep'});
% determine the misclassification probability (for classification trees) for out-of-bag observations in the training data
outOfBagError = oobError(RF_MDL,'Mode','Ensemble');
% use the model to generate a set of predictions
[trainingPredictions,~] = predict(RF_MDL,Xtraining);
[testingPredictions,~] = predict(RF_MDL,Xtesting);
% save labels for later confusion matrix
Results_PupilSleepModelTEST.(animalID).RF.mdl = RF_MDL;
Results_PupilSleepModelTEST.(animalID).RF.outOfBagError = outOfBagError;
Results_PupilSleepModelTEST.(animalID).RF.Xtraining = Xtraining;
Results_PupilSleepModelTEST.(animalID).RF.Ytraining = Ytraining;
Results_PupilSleepModelTEST.(animalID).RF.Xtesting = Xtesting;
Results_PupilSleepModelTEST.(animalID).RF.Ytesting = Ytesting;
Results_PupilSleepModelTEST.(animalID).RF.trueTrainingLabels = Ytraining.behavState;
Results_PupilSleepModelTEST.(animalID).RF.predictedTrainingLabels = trainingPredictions;
Results_PupilSleepModelTEST.(animalID).RF.trueTestingLabels = Ytesting.behavState;
Results_PupilSleepModelTEST.(animalID).RF.predictedTestingLabels = testingPredictions;
% confusion chart
RF_confMat = figure;
CM = confusionchart(Ytesting.behavState,testingPredictions);
CM.ColumnSummary = 'column-normalized';
CM.RowSummary = 'row-normalized';
CM.Title = [animalID ' Testing Data'];
confVals = CM.NormalizedValues;
totalScores = sum(confVals(:));
modelAccuracy = (sum(confVals([1,5,9])/totalScores))*100;
CM.Title = {'Pupil RF',['total accuracy: ' num2str(modelAccuracy) ' (%)']};
%% save data
cd([rootFolder delim])
save('Results_PupilSleepModelTEST.mat','Results_PupilSleepModelTEST')
% save figure
savefig(RF_confMat,[animalID '_ConfusionMatrix']);
close(RF_confMat)

end
