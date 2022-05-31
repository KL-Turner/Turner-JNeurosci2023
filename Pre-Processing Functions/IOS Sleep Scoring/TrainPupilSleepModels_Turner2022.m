function [animalID] = TrainPupilSleepModels_Turner2022()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Train several machine learning techniques on manually scored sleep data, and evaluate each model's accuracy
%________________________________________________________________________________________________________________________

%% load in all the data to create a table of values
startingDirectory = cd;
trainingDirectory = [startingDirectory '\Training Data\'];
cd(trainingDirectory)
% character list of all training files
trainingDataFileStruct = dir('*_PupilTrainingData.mat');
trainingDataFiles = {trainingDataFileStruct.name}';
trainingDataFileIDs = char(trainingDataFiles);
% Load each updated training set and concatenate the data into table
for bb = 1:size(trainingDataFileIDs,1)
    trainingTableFileID = trainingDataFileIDs(bb,:);
    if bb == 1
        load(trainingTableFileID)
        dataLength = size(pupilTrainingTable,1);
        joinedTableOdd = pupilTrainingTable;
    elseif bb == 2
        load(trainingTableFileID)
        joinedTableEven = pupilTrainingTable;
    elseif rem(bb,2) == 1
        load(trainingTableFileID)
        joinedTableOdd = vertcat(joinedTableOdd,pupilTrainingTable); %#ok<*AGROW>
    elseif rem(bb,2) == 0
        load(trainingTableFileID)
        joinedTableEven = vertcat(joinedTableEven,pupilTrainingTable);
    end
end
% train on odd data
Xodd = joinedTableOdd(:,1:end - 1);
Yodd = joinedTableOdd(:,end);
% test on even data
Xeven = joinedTableEven(:,1:end - 1);
Yeven = joinedTableEven(:,end);
% pull animal ID
[animalID,~,~] = GetFileInfo_Turner2022(trainingTableFileID);
% directory path for saving data
dirpath = [startingDirectory '\Figures\Sleep Models\'];
if ~exist(dirpath,'dir')
    mkdir(dirpath);
end
%% Train Support Vector Machine (SVM) classifier
t = templateSVM('Standardize',true,'KernelFunction','gaussian');
disp('Training Support Vector Machine...'); disp(' ')
Pupil_SVM_MDL = fitcecoc(Xodd,Yodd,'Learners',t,'FitPosterior',true,'ClassNames',{'Not Sleep','NREM Sleep','REM Sleep'},'Verbose',2);
% save model in desired location
save([dirpath animalID '_IOS_SVM_PupilSleepScoringModel.mat'],'Pupil_SVM_MDL')
% determine k-fold loss of the model
disp('Cross-validating (3-fold) the support vector machine classifier...'); disp(' ')
Pupil_CV_SVM_MDL = crossval(Pupil_SVM_MDL,'kfold',3);
loss = kfoldLoss(Pupil_CV_SVM_MDL);
disp(['k-fold loss classification error: ' num2str(loss*100) '%']); disp(' ')
% use the model to generate a set of scores for the even set of data
[XoddLabels,~] = predict(Pupil_SVM_MDL,Xodd);
[XevenLabels,~] = predict(Pupil_SVM_MDL,Xeven);
% apply a logical patch on the REM events
oddREMindex = strcmp(XoddLabels,'REM Sleep');
evenREMindex = strcmp(XevenLabels,'REM Sleep');
oddNumFiles = length(XoddLabels)/dataLength;
evenNumFiles = length(XevenLabels)/dataLength;
oddReshapedREMindex = reshape(oddREMindex,dataLength,oddNumFiles);
evenReshapedREMindex = reshape(evenREMindex,dataLength,evenNumFiles);
oddPatchedREMindex = [];
evenPatchedREMindex = [];
% training data - patch missing REM indeces due to theta band falling off
for ii = 1:size(oddReshapedREMindex,2)
    oddREMArray = oddReshapedREMindex(:,ii);
    oddPatchedREMarray = LinkBinaryEvents_Turner2022(oddREMArray',[5,0]);
    oddPatchedREMindex = vertcat(oddPatchedREMindex,oddPatchedREMarray');
end
% testing data - patch missing REM indeces due to theta band falling off
for ii = 1:size(evenReshapedREMindex,2)
    evenREMArray = evenReshapedREMindex(:,ii);
    evenPatchedREMarray = LinkBinaryEvents_Turner2022(evenREMArray',[5,0]);
    evenPatchedREMindex = vertcat(evenPatchedREMindex,evenPatchedREMarray');
end
% training data - change labels for each event
for jj = 1:length(XoddLabels)
    if oddPatchedREMindex(jj,1) == 1
        XoddLabels{jj,1} = 'REM Sleep';
    end
end
% testing data - change labels for each event
for jj = 1:length(XevenLabels)
    if evenPatchedREMindex(jj,1) == 1
        XevenLabels{jj,1} = 'REM Sleep';
    end
end
% save labels for later confusion matrix
PupilConfusionData.SVM.trainYlabels = Yodd.behavState;
PupilConfusionData.SVM.trainXlabels = XoddLabels;
PupilConfusionData.SVM.testYlabels = Yeven.behavState;
PupilConfusionData.SVM.testXlabels = XevenLabels;
% confusion matrix
Pupil_SVM_confMat = figure;
sgtitle('Support Vector Machine Classifier Confusion Matrix')
% training data confusion chart
subplot(1,2,1)
oddCM = confusionchart(Yodd.behavState,XoddLabels);
oddCM.ColumnSummary = 'column-normalized';
oddCM.RowSummary = 'row-normalized';
oddCM.Title = 'Training Data';
oddConfVals = oddCM.NormalizedValues;
oddTotalScores = sum(oddConfVals(:));
try
    oddSVM_accuracy = (sum(oddConfVals([1,5,9])/oddTotalScores))*100;
    disp(['Support Vector Machine model prediction accuracy (training): ' num2str(oddSVM_accuracy) '%']); disp(' ')
catch
    PupilConfusionData.SVM.noREM = 1;
end
% testing data confusion chart
subplot(1,2,2)
evenCM = confusionchart(Yeven.behavState,XevenLabels);
evenCM.ColumnSummary = 'column-normalized';
evenCM.RowSummary = 'row-normalized';
evenCM.Title = 'Testing Data';
evenConfVals = evenCM.NormalizedValues;
evenTotalScores = sum(evenConfVals(:));
try
    evenSVM_accuracy = (sum(evenConfVals([1,5,9])/evenTotalScores))*100;
    disp(['Support Vector Machine model prediction accuracy (testing): ' num2str(evenSVM_accuracy) '%']); disp(' ')
catch
    PupilConfusionData.SVM.noREM = 1;
end
% save model and figure
savefig(Pupil_SVM_confMat,[dirpath animalID '_IOS_SVM_PupilConfusionMatrix']);
close(Pupil_SVM_confMat)
%% Ensemble classification - AdaBoostM2, Subspace, Bag, LPBoost,RUSBoost, TotalBoost
disp('Training Ensemble Classifier...'); disp(' ')
t = templateTree('Reproducible',true);
Pupil_EC_MDL = fitcensemble(Xodd,Yodd,'OptimizeHyperparameters','auto','Learners',t,'HyperparameterOptimizationOptions',...
    struct('AcquisitionFunctionName','expected-improvement-plus'),'ClassNames',{'Not Sleep','NREM Sleep','REM Sleep'});
% save model in desired location
save([dirpath animalID '_IOS_EC_PupilSleepScoringModel.mat'],'Pupil_EC_MDL')
% determine k-fold loss of the model
disp('Cross-validating (3-fold) the ensemble classifier...'); disp(' ')
Pupil_CV_EC_MDL = crossval(Pupil_EC_MDL,'kfold',3);
loss = kfoldLoss(Pupil_CV_EC_MDL);
disp(['k-fold loss classification error: ' num2str(loss*100) '%']); disp(' ')
% use the model to generate a set of scores for the even set of data
[XoddLabels,~] = predict(Pupil_EC_MDL,Xodd);
[XevenLabels,~] = predict(Pupil_EC_MDL,Xeven);
% apply a logical patch on the REM events
oddREMindex = strcmp(XoddLabels,'REM Sleep');
evenREMindex = strcmp(XevenLabels,'REM Sleep');
oddNumFiles = length(XoddLabels)/dataLength;
evenNumFiles = length(XevenLabels)/dataLength;
oddReshapedREMindex = reshape(oddREMindex,dataLength,oddNumFiles);
evenReshapedREMindex = reshape(evenREMindex,dataLength,evenNumFiles);
oddPatchedREMindex = [];
evenPatchedREMindex = [];
% training data - patch missing REM indeces due to theta band falling off
for ii = 1:size(oddReshapedREMindex,2)
    oddREMArray = oddReshapedREMindex(:,ii);
    oddPatchedREMarray = LinkBinaryEvents_Turner2022(oddREMArray',[5,0]);
    oddPatchedREMindex = vertcat(oddPatchedREMindex,oddPatchedREMarray');
end
% testing data - patch missing REM indeces due to theta band falling off
for ii = 1:size(evenReshapedREMindex,2)
    evenREMArray = evenReshapedREMindex(:,ii);
    evenPatchedREMarray = LinkBinaryEvents_Turner2022(evenREMArray',[5,0]);
    evenPatchedREMindex = vertcat(evenPatchedREMindex,evenPatchedREMarray');
end
% training data - change labels for each event
for jj = 1:length(XoddLabels)
    if oddPatchedREMindex(jj,1) == 1
        XoddLabels{jj,1} = 'REM Sleep';
    end
end
% testing data - change labels for each event
for jj = 1:length(XevenLabels)
    if evenPatchedREMindex(jj,1) == 1
        XevenLabels{jj,1} = 'REM Sleep';
    end
end
% save labels for later confusion matrix
PupilConfusionData.EC.trainYlabels= Yodd.behavState;
PupilConfusionData.EC.trainXlabels = XoddLabels;
PupilConfusionData.EC.testYlabels = Yeven.behavState;
PupilConfusionData.EC.testXlabels = XevenLabels;
% confusion matrix
Pupil_EC_confMat = figure;
sgtitle('Support Vector Machine Classifier Confusion Matrix')
% training data confusion chart
subplot(1,2,1)
oddCM = confusionchart(Yodd.behavState,XoddLabels);
oddCM.ColumnSummary = 'column-normalized';
oddCM.RowSummary = 'row-normalized';
oddCM.Title = 'Training Data';
oddConfVals = oddCM.NormalizedValues;
oddTotalScores = sum(oddConfVals(:));
try
    oddEC_accuracy = (sum(oddConfVals([1,5,9])/oddTotalScores))*100;
    disp(['Ensemble model prediction accuracy (training): ' num2str(oddEC_accuracy) '%']); disp(' ')
catch
    PupilConfusionData.EC.noREM = 1;
end
% testing data confusion chart
subplot(1,2,2)
evenCM = confusionchart(Yeven.behavState,XevenLabels);
evenCM.ColumnSummary = 'column-normalized';
evenCM.RowSummary = 'row-normalized';
evenCM.Title = 'Testing Data';
evenConfVals = evenCM.NormalizedValues;
evenTotalScores = sum(evenConfVals(:));
try
    evenEC_accuracy = (sum(evenConfVals([1,5,9])/evenTotalScores))*100;
    disp(['Ensemble model prediction accuracy (testing): ' num2str(evenEC_accuracy) '%']); disp(' ')
catch
    PupilConfusionData.EC.noREM = 1;
end
% save model and figure
savefig(Pupil_EC_confMat,[dirpath animalID '_IOS_EC_PupilConfusionMatrix']);
close(Pupil_EC_confMat)
%% Decision Tree classification
disp('Training Decision Tree Classifier...'); disp(' ')
Pupil_DT_MDL = fitctree(Xodd,Yodd,'ClassNames',{'Not Sleep','NREM Sleep','REM Sleep'});
% save model in desired location
save([dirpath animalID '_IOS_DT_PupilSleepScoringModel.mat'],'Pupil_DT_MDL')
% use the model to generate a set of scores for the even set of data
[XoddLabels,~] = predict(Pupil_DT_MDL,Xodd);
[XevenLabels,~] = predict(Pupil_DT_MDL,Xeven);
% apply a logical patch on the REM events
oddREMindex = strcmp(XoddLabels,'REM Sleep');
evenREMindex = strcmp(XevenLabels,'REM Sleep');
oddNumFiles = length(XoddLabels)/dataLength;
evenNumFiles = length(XevenLabels)/dataLength;
oddReshapedREMindex = reshape(oddREMindex,dataLength,oddNumFiles);
evenReshapedREMindex = reshape(evenREMindex,dataLength,evenNumFiles);
oddPatchedREMindex = [];
evenPatchedREMindex = [];
% training data - patch missing REM indeces due to theta band falling off
for ii = 1:size(oddReshapedREMindex,2)
    oddREMArray = oddReshapedREMindex(:,ii);
    oddPatchedREMarray = LinkBinaryEvents_Turner2022(oddREMArray',[5,0]);
    oddPatchedREMindex = vertcat(oddPatchedREMindex,oddPatchedREMarray');
end
% testing data - patch missing REM indeces due to theta band falling off
for ii = 1:size(evenReshapedREMindex,2)
    evenREMArray = evenReshapedREMindex(:,ii);
    evenPatchedREMarray = LinkBinaryEvents_Turner2022(evenREMArray',[5,0]);
    evenPatchedREMindex = vertcat(evenPatchedREMindex,evenPatchedREMarray');
end
% training data - change labels for each event
for jj = 1:length(XoddLabels)
    if oddPatchedREMindex(jj,1) == 1
        XoddLabels{jj,1} = 'REM Sleep';
    end
end
% testing data - change labels for each event
for jj = 1:length(XevenLabels)
    if evenPatchedREMindex(jj,1) == 1
        XevenLabels{jj,1} = 'REM Sleep';
    end
end
% save labels for later confusion matrix
PupilConfusionData.DT.trainYlabels = Yodd.behavState;
PupilConfusionData.DT.trainXlabels = XoddLabels;
PupilConfusionData.DT.testYlabels = Yeven.behavState;
PupilConfusionData.DT.testXlabels = XevenLabels;
% confusion matrix
Pupil_DT_confMat = figure;
sgtitle('Decision Tree Classifier Confusion Matrix')
% training data confusion chart
subplot(1,2,1)
oddCM = confusionchart(Yodd.behavState,XoddLabels);
oddCM.ColumnSummary = 'column-normalized';
oddCM.RowSummary = 'row-normalized';
oddCM.Title = 'Training Data';
oddConfVals = oddCM.NormalizedValues;
oddTotalScores = sum(oddConfVals(:));
try
    oddDT_accuracy = (sum(oddConfVals([1,5,9])/oddTotalScores))*100;
    disp(['Support Vector Machine model prediction accuracy (training): ' num2str(oddDT_accuracy) '%']); disp(' ')
catch
    PupilConfusionData.DT.noREM = 1;
end
% testing data confusion chart
subplot(1,2,2)
evenCM = confusionchart(Yeven.behavState,XevenLabels);
evenCM.ColumnSummary = 'column-normalized';
evenCM.RowSummary = 'row-normalized';
evenCM.Title = 'Testing Data';
evenConfVals = evenCM.NormalizedValues;
evenTotalScores = sum(evenConfVals(:));
try
    evenDT_accuracy = (sum(evenConfVals([1,5,9])/evenTotalScores))*100;
    disp(['Decision Tree model prediction accuracy (testing): ' num2str(evenDT_accuracy) '%']); disp(' ')
catch
    PupilConfusionData.DT.noREM = 1;
end
% save model and figure
savefig(Pupil_DT_confMat,[dirpath animalID '_IOS_DT_PupilConfusionMatrix']);
close(Pupil_DT_confMat)
%% Random forest
disp('Training Random Forest Classifier...'); disp(' ')
numTrees = 128;
Pupil_RF_MDL = TreeBagger(numTrees,Xodd,Yodd,'Method','Classification','Surrogate','all','OOBPrediction','on','ClassNames',{'Not Sleep','NREM Sleep','REM Sleep'});
% save model in desired location
save([dirpath animalID '_IOS_RF_PupilSleepScoringModel.mat'],'Pupil_RF_MDL')
% determine the misclassification probability (for classification trees) for out-of-bag observations in the training data
RF_OOBerror = oobError(Pupil_RF_MDL,'Mode','Ensemble');
disp(['Random Forest out-of-bag error: ' num2str(RF_OOBerror*100) '%']); disp(' ')
% use the model to generate a set of scores for the even set of data
[XoddLabels,~] = predict(Pupil_RF_MDL,Xodd);
[XevenLabels,~] = predict(Pupil_RF_MDL,Xeven);
% apply a logical patch on the REM events
oddREMindex = strcmp(XoddLabels,'REM Sleep');
evenREMindex = strcmp(XevenLabels,'REM Sleep');
oddNumFiles = length(XoddLabels)/dataLength;
evenNumFiles = length(XevenLabels)/dataLength;
oddReshapedREMindex = reshape(oddREMindex,dataLength,oddNumFiles);
evenReshapedREMindex = reshape(evenREMindex,dataLength,evenNumFiles);
oddPatchedREMindex = [];
evenPatchedREMindex = [];
% training data - patch missing REM indeces due to theta band falling off
for ii = 1:size(oddReshapedREMindex,2)
    oddREMArray = oddReshapedREMindex(:,ii);
    oddPatchedREMarray = LinkBinaryEvents_Turner2022(oddREMArray',[5,0]);
    oddPatchedREMindex = vertcat(oddPatchedREMindex,oddPatchedREMarray');
end
% testing data - patch missing REM indeces due to theta band falling off
for ii = 1:size(evenReshapedREMindex,2)
    evenREMArray = evenReshapedREMindex(:,ii);
    evenPatchedREMarray = LinkBinaryEvents_Turner2022(evenREMArray',[5,0]);
    evenPatchedREMindex = vertcat(evenPatchedREMindex,evenPatchedREMarray');
end
% training data - change labels for each event
for jj = 1:length(XoddLabels)
    if oddPatchedREMindex(jj,1) == 1
        XoddLabels{jj,1} = 'REM Sleep';
    end
end
% testing data - change labels for each event
for jj = 1:length(XevenLabels)
    if evenPatchedREMindex(jj,1) == 1
        XevenLabels{jj,1} = 'REM Sleep';
    end
end
% save labels for later confusion matrix
PupilConfusionData.RF.trainYlabels = Yodd.behavState;
PupilConfusionData.RF.trainXlabels = XoddLabels;
PupilConfusionData.RF.testYlabels = Yeven.behavState;
PupilConfusionData.RF.testXlabels = XevenLabels;
% confusion matrix
Pupil_RF_confMat = figure;
sgtitle('Random Forest Classifier Confusion Matrix')
% training data confusion chart
subplot(1,2,1)
oddCM = confusionchart(Yodd.behavState,XoddLabels);
oddCM.ColumnSummary = 'column-normalized';
oddCM.RowSummary = 'row-normalized';
oddCM.Title = 'Training Data';
oddConfVals = oddCM.NormalizedValues;
oddTotalScores = sum(oddConfVals(:));
try
    oddRF_accuracy = (sum(oddConfVals([1,5,9])/oddTotalScores))*100;
    disp(['Random Forest model prediction accuracy (training): ' num2str(oddRF_accuracy) '%']); disp(' ')
catch
    PupilConfusionData.RF.noREM = 1;
end
% testing data confusion chart
subplot(1,2,2)
evenCM = confusionchart(Yeven.behavState,XevenLabels);
evenCM.ColumnSummary = 'column-normalized';
evenCM.RowSummary = 'row-normalized';
evenCM.Title = 'Testing Data';
evenConfVals = evenCM.NormalizedValues;
evenTotalScores = sum(evenConfVals(:));
try
    evenRF_accuracy = (sum(evenConfVals([1,5,9])/evenTotalScores))*100;
    disp(['Random Forest model prediction accuracy (testing): ' num2str(evenRF_accuracy) '%']); disp(' ')
catch
    PupilConfusionData.RF.noREM = 1;
end
% save model and figure
savefig(Pupil_RF_confMat,[dirpath animalID '_IOS_RF_PupilConfusionMatrix']);
close(Pupil_RF_confMat)
%% k-nearest neighbor classifier
disp('Training k-nearest neighbor Classifier...'); disp(' ')
t = templateKNN('NumNeighbors',5,'Standardize',1);
Pupil_KNN_MDL = fitcecoc(Xodd,Yodd,'Learners',t);
% save model in desired location
save([dirpath animalID '_IOS_KNN_PupilSleepScoringModel.mat'],'Pupil_KNN_MDL')
% use the model to generate a set of scores for the even set of data
[XoddLabels,~] = predict(Pupil_KNN_MDL,Xodd);
[XevenLabels,~] = predict(Pupil_KNN_MDL,Xeven);
% apply a logical patch on the REM events
oddREMindex = strcmp(XoddLabels,'REM Sleep');
evenREMindex = strcmp(XevenLabels,'REM Sleep');
oddNumFiles = length(XoddLabels)/dataLength;
evenNumFiles = length(XevenLabels)/dataLength;
oddReshapedREMindex = reshape(oddREMindex,dataLength,oddNumFiles);
evenReshapedREMindex = reshape(evenREMindex,dataLength,evenNumFiles);
oddPatchedREMindex = [];
evenPatchedREMindex = [];
% training data - patch missing REM indeces due to theta band falling off
for ii = 1:size(oddReshapedREMindex,2)
    oddREMArray = oddReshapedREMindex(:,ii);
    oddPatchedREMarray = LinkBinaryEvents_Turner2022(oddREMArray',[5,0]);
    oddPatchedREMindex = vertcat(oddPatchedREMindex,oddPatchedREMarray');
end
% testing data - patch missing REM indeces due to theta band falling off
for ii = 1:size(evenReshapedREMindex,2)
    evenREMArray = evenReshapedREMindex(:,ii);
    evenPatchedREMarray = LinkBinaryEvents_Turner2022(evenREMArray',[5,0]);
    evenPatchedREMindex = vertcat(evenPatchedREMindex,evenPatchedREMarray');
end
% training data - change labels for each event
for jj = 1:length(XoddLabels)
    if oddPatchedREMindex(jj,1) == 1
        XoddLabels{jj,1} = 'REM Sleep';
    end
end
% testing data - change labels for each event
for jj = 1:length(XevenLabels)
    if evenPatchedREMindex(jj,1) == 1
        XevenLabels{jj,1} = 'REM Sleep';
    end
end
% save labels for later confusion matrix
PupilConfusionData.KNN.trainYlabels = Yodd.behavState;
PupilConfusionData.KNN.trainXlabels = XoddLabels;
PupilConfusionData.KNN.testYlabels = Yeven.behavState;
PupilConfusionData.KNN.testXlabels = XevenLabels;
% confusion matrix
Pupil_KNN_confMat = figure;
sgtitle('Support Vector Machine Classifier Confusion Matrix')
% training data confusion chart
subplot(1,2,1)
oddCM = confusionchart(Yodd.behavState,XoddLabels);
oddCM.ColumnSummary = 'column-normalized';
oddCM.RowSummary = 'row-normalized';
oddCM.Title = 'Training Data';
oddConfVals = oddCM.NormalizedValues;
oddTotalScores = sum(oddConfVals(:));
try
    oddKNN_accuracy = (sum(oddConfVals([1,5,9])/oddTotalScores))*100;
    disp(['k-Nearest Neighbor model prediction accuracy (training): ' num2str(oddKNN_accuracy) '%']); disp(' ')
catch
    PupilConfusionData.KNN.noREM = 1;
end
% testing data confusion chart
subplot(1,2,2)
evenCM = confusionchart(Yeven.behavState,XevenLabels);
evenCM.ColumnSummary = 'column-normalized';
evenCM.RowSummary = 'row-normalized';
evenCM.Title = 'Testing Data';
evenConfVals = evenCM.NormalizedValues;
evenTotalScores = sum(evenConfVals(:));
try
    evenKNN_accuracy = (sum(evenConfVals([1,5,9])/evenTotalScores))*100;
    disp(['k-Nearest Neightbor model prediction accuracy (testing): ' num2str(evenKNN_accuracy) '%']); disp(' ')
catch
    PupilConfusionData.KNN.noREM = 1;
end
% save model and figure
savefig(Pupil_KNN_confMat,[dirpath animalID '_IOS_KNN_PupilConfusionMatrix']);
close(Pupil_KNN_confMat)
%% Naive Bayes classifier
disp('Training naive Bayes Classifier...'); disp(' ')
Pupil_NB_MDL = fitcnb(Xodd,Yodd,'ClassNames',{'Not Sleep','NREM Sleep','REM Sleep'});
% save model in desired location
save([dirpath animalID '_IOS_NB_PupilSleepScoringModel.mat'],'Pupil_NB_MDL')
% use the model to generate a set of scores for the even set of data
[XoddLabels,~] = predict(Pupil_NB_MDL,Xodd);
[XevenLabels,~] = predict(Pupil_NB_MDL,Xeven);
% apply a logical patch on the REM events
oddREMindex = strcmp(XoddLabels,'REM Sleep');
evenREMindex = strcmp(XevenLabels,'REM Sleep');
oddNumFiles = length(XoddLabels)/dataLength;
evenNumFiles = length(XevenLabels)/dataLength;
oddReshapedREMindex = reshape(oddREMindex,dataLength,oddNumFiles);
evenReshapedREMindex = reshape(evenREMindex,dataLength,evenNumFiles);
oddPatchedREMindex = [];
evenPatchedREMindex = [];
% training data - patch missing REM indeces due to theta band falling off
for ii = 1:size(oddReshapedREMindex,2)
    oddREMArray = oddReshapedREMindex(:,ii);
    oddPatchedREMarray = LinkBinaryEvents_Turner2022(oddREMArray',[5,0]);
    oddPatchedREMindex = vertcat(oddPatchedREMindex,oddPatchedREMarray');
end
% testing data - patch missing REM indeces due to theta band falling off
for ii = 1:size(evenReshapedREMindex,2)
    evenREMArray = evenReshapedREMindex(:,ii);
    evenPatchedREMarray = LinkBinaryEvents_Turner2022(evenREMArray',[5,0]);
    evenPatchedREMindex = vertcat(evenPatchedREMindex,evenPatchedREMarray');
end
% training data - change labels for each event
for jj = 1:length(XoddLabels)
    if oddPatchedREMindex(jj,1) == 1
        XoddLabels{jj,1} = 'REM Sleep';
    end
end
% testing data - change labels for each event
for jj = 1:length(XevenLabels)
    if evenPatchedREMindex(jj,1) == 1
        XevenLabels{jj,1} = 'REM Sleep';
    end
end
% save labels for later confusion matrix
PupilConfusionData.NB.trainYlabels = Yodd.behavState;
PupilConfusionData.NB.trainXlabels = XoddLabels;
PupilConfusionData.NB.testYlabels = Yeven.behavState;
PupilConfusionData.NB.testXlabels = XevenLabels;
% confusion matrix
Pupil_NB_confMat = figure;
sgtitle('Naive Bayes Classifier Confusion Matrix')
% training data confusion chart
subplot(1,2,1)
oddCM = confusionchart(Yodd.behavState,XoddLabels);
oddCM.ColumnSummary = 'column-normalized';
oddCM.RowSummary = 'row-normalized';
oddCM.Title = 'Training Data';
oddConfVals = oddCM.NormalizedValues;
oddTotalScores = sum(oddConfVals(:));
try
    oddNB_accuracy = (sum(oddConfVals([1,5,9])/oddTotalScores))*100;
    disp(['Naive Bayes model prediction accuracy (training): ' num2str(oddNB_accuracy) '%']); disp(' ')
catch
    PupilConfusionData.NB.noREM = 1;
end
% testing data confusion chart
subplot(1,2,2)
evenCM = confusionchart(Yeven.behavState,XevenLabels);
evenCM.ColumnSummary = 'column-normalized';
evenCM.RowSummary = 'row-normalized';
evenCM.Title = 'Testing Data';
evenConfVals = evenCM.NormalizedValues;
evenTotalScores = sum(evenConfVals(:));
try
    evenNB_accuracy = (sum(evenConfVals([1,5,9])/evenTotalScores))*100;
    disp(['Naive Bayes model prediction accuracy (testing): ' num2str(evenNB_accuracy) '%']); disp(' ')
catch
    PupilConfusionData.NB.noREM = 1;
end
% save model and figure
savefig(Pupil_NB_confMat,[dirpath animalID '_IOS_NB_PupilConfusionMatrix']);
close(Pupil_NB_confMat)
cd(startingDirectory)
% save confusion matrix results
save([dirpath animalID '_PupilConfusionData.mat'],'PupilConfusionData')

end
