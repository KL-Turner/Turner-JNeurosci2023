function [Results_PupilSleepModelTEST] = AnalyzePupilSleepModelAccuracyTEST2_Turner2022(animalIDs,rootFolder,delim,Results_PupilSleepModelTEST)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: train/validate machine learning classifier using solely the pupil diameter
%________________________________________________________________________________________________________________________

cc = 1;
for aa = 1:length(animalIDs)
    animalID = animalIDs{1,aa};
    % go to animal's data location
    dataLocation = [rootFolder delim 'Data' delim animalID delim 'Training Data'];
    cd(dataLocation)
    % character list of all ProcData files
    procDataFileStruct = dir('*_ProcData.mat');
    procDataFiles = {procDataFileStruct.name}';
    procDataFileIDs = char(procDataFiles);
    % prepare training data by updating parameters
%     AddPupilSleepParameters_Turner2022(procDataFileIDs)
%     CreatePupilModelDataSet_Turner2022(procDataFileIDs)
%     UpdatePupilTrainingDataSet_Turner2022(procDataFileIDs)
    % training data file IDs
    pupilTrainingDataFileStruct = dir('*_PupilTrainingData.mat');
    pupilTrainingDataFiles = {pupilTrainingDataFileStruct.name}';
    pupilTrainingDataFileIDs = char(pupilTrainingDataFiles);
    % load each updated training set and concatenate the data into table
    for bb = 1:size(pupilTrainingDataFileIDs,1)
        trainingTableFileID = pupilTrainingDataFileIDs(bb,:);
        if cc == 1
            load(trainingTableFileID)
            dataLength = size(pupilTrainingTable,1);
            joinedTableOdd = pupilTrainingTable;
            cc = cc + 1;
        elseif cc == 2
            load(trainingTableFileID)
            joinedTableEven = pupilTrainingTable;
            cc = cc + 1;
        elseif rem(cc,2) == 1
            load(trainingTableFileID)
            joinedTableOdd = vertcat(joinedTableOdd,pupilTrainingTable);
            cc = cc + 1;
        elseif rem(cc,2) == 0
            load(trainingTableFileID)
            joinedTableEven = vertcat(joinedTableEven,pupilTrainingTable);
            cc = cc + 1;
        end
    end
end
% train on odd data
Xodd = joinedTableOdd(:,1:end - 1);
Yodd = joinedTableOdd(:,end);
% test on even data
Xeven = joinedTableEven(:,1:end - 1);
Yeven = joinedTableEven(:,end);
%% random forest
disp('Training Random Forest Classifier...'); disp(' ')
numTrees = 128;
RF_MDL = TreeBagger(numTrees,Xodd,Yodd,'Method','Classification','Surrogate','all','OOBPrediction','on','ClassNames',{'Not Sleep','NREM Sleep','REM Sleep'});
% determine the misclassification probability (for classification trees) for out-of-bag observations in the training data
RF_OOBerror = oobError(RF_MDL,'Mode','Ensemble');
disp(['Random Forest out-of-bag error: ' num2str(RF_OOBerror*100) '%']); disp(' ')
% use the model to generate a set of scores for the even set of data
[XoddLabels,~] = predict(RF_MDL,Xodd);
[XevenLabels,~] = predict(RF_MDL,Xeven);
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
% Results_PupilSleepModelTEST.(animalID).RF.mdl = RF_MDL;
% Results_PupilSleepModelTEST.(animalID).RF.RF_OOBerror = RF_OOBerror;
% Results_PupilSleepModelTEST.(animalID).RF.Xodd = Xodd;
% Results_PupilSleepModelTEST.(animalID).RF.Yodd = Yodd;
% Results_PupilSleepModelTEST.(animalID).RF.Xeven = Xeven;
% Results_PupilSleepModelTEST.(animalID).RF.Yeven = Yeven;
% Results_PupilSleepModelTEST.(animalID).RF.trainYlabels = Yodd.behavState;
% Results_PupilSleepModelTEST.(animalID).RF.trainXlabels = XoddLabels;
% Results_PupilSleepModelTEST.(animalID).RF.testYlabels = Yeven.behavState;
% Results_PupilSleepModelTEST.(animalID).RF.testXlabels = XevenLabels;
% confusion chart
RF_confMat = figure;
evenCM = confusionchart(Yeven.behavState,XevenLabels);
evenCM.ColumnSummary = 'column-normalized';
evenCM.RowSummary = 'row-normalized';
evenCM.Title = [animalID ' Testing Data'];
evenConfVals = evenCM.NormalizedValues;
evenTotalScores = sum(evenConfVals(:));
evenRF_accuracy = (sum(evenConfVals([1,5,9])/evenTotalScores))*100;
disp(['Random Forest model prediction accuracy (testing): ' num2str(evenRF_accuracy) '%']); disp(' ')
%% save data
cd([rootFolder delim])
save('Results_PupilSleepModelTEST.mat','Results_PupilSleepModelTEST')
% save figure
savefig(RF_confMat,[animalID '_ConfusionMatrix']);
close(RF_confMat)

end
