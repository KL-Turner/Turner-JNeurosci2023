function [Results_LaggedPupilSleepModel] = AnalyzeLaggedPupilSleepModelAccuracy_Turner2022(animalID,rootFolder,delim,Results_LaggedPupilSleepModel)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: train/validate machine learning classifier using solely the pupil diameter - lagged comparison
%________________________________________________________________________________________________________________________

% go to animal's data location
dataLocation = [rootFolder delim 'Data' delim animalID delim 'Training Data'];
cd(dataLocation)
% character list of all ProcData files
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
% prepare training data by updating parameters
AddPupilSleepParameters_Turner2022(procDataFileIDs)
CreatePupilModelDataSet_Turner2022(procDataFileIDs)
UpdatePupilTrainingDataSet_Turner2022(procDataFileIDs)
% training data file IDs
pupilTrainingDataFileStruct = dir('*_PupilTrainingData.mat');
pupilTrainingDataFiles = {pupilTrainingDataFileStruct.name}';
pupilTrainingDataFileIDs = char(pupilTrainingDataFiles);
% compare different lag times
lags = {'negFifteen','negTen','negFive','zero','five','ten','fifteen'};
for qq = 1:length(lags)
    lag = lags{1,qq};
    joinedTableOdd = [];
    joinedTableEven = [];
    switch lag
        case 'fifteen'
            % load each updated training set and concatenate the data into a table
            cc = 1;
            for bb = 1:size(pupilTrainingDataFileIDs,1)
                trainingTableFileID = pupilTrainingDataFileIDs(bb,:);
                load(trainingTableFileID)
                zDiameter = pupilTrainingTable.zDiameter(1:end - 3);
                mmDiameter = pupilTrainingTable.mmDiameter(1:end - 3);
                behavState = pupilTrainingTable.behavState(4:end);
                % create table to send into model
                variableNames = {'zDiameter','mmDiameter','behavState'};
                lagPupilTrainingTable = table(zDiameter,mmDiameter,behavState,'VariableNames',variableNames);
                if cc == 1
                    joinedTableOdd = lagPupilTrainingTable;
                    cc = cc + 1;
                elseif cc == 2
                    joinedTableEven = lagPupilTrainingTable;
                    cc = cc + 1;
                elseif rem(cc,2) == 1
                    joinedTableOdd = vertcat(joinedTableOdd,lagPupilTrainingTable);
                    cc = cc + 1;
                elseif rem(cc,2) == 0
                    joinedTableEven = vertcat(joinedTableEven,lagPupilTrainingTable);
                    cc = cc + 1;
                end
            end
        case 'ten'
            % load each updated training set and concatenate the data into table
            cc = 1;
            for bb = 1:size(pupilTrainingDataFileIDs,1)
                trainingTableFileID = pupilTrainingDataFileIDs(bb,:);
                load(trainingTableFileID)
                zDiameter = pupilTrainingTable.zDiameter(1:end - 2);
                mmDiameter = pupilTrainingTable.mmDiameter(1:end - 2);
                behavState = pupilTrainingTable.behavState(3:end);
                % create table to send into model
                variableNames = {'zDiameter','mmDiameter','behavState'};
                lagPupilTrainingTable = table(zDiameter,mmDiameter,behavState,'VariableNames',variableNames);
                if cc == 1
                    joinedTableOdd = lagPupilTrainingTable;
                    cc = cc + 1;
                elseif cc == 2
                    joinedTableEven = lagPupilTrainingTable;
                    cc = cc + 1;
                elseif rem(cc,2) == 1
                    joinedTableOdd = vertcat(joinedTableOdd,lagPupilTrainingTable);
                    cc = cc + 1;
                elseif rem(cc,2) == 0
                    joinedTableEven = vertcat(joinedTableEven,lagPupilTrainingTable);
                    cc = cc + 1;
                end
            end
        case 'five'
            % load each updated training set and concatenate the data into table
            cc = 1;
            for bb = 1:size(pupilTrainingDataFileIDs,1)
                trainingTableFileID = pupilTrainingDataFileIDs(bb,:);
                load(trainingTableFileID)
                zDiameter = pupilTrainingTable.zDiameter(1:end - 1);
                mmDiameter = pupilTrainingTable.mmDiameter(1:end - 1);
                behavState = pupilTrainingTable.behavState(2:end);
                % create table to send into model
                variableNames = {'zDiameter','mmDiameter','behavState'};
                lagPupilTrainingTable = table(zDiameter,mmDiameter,behavState,'VariableNames',variableNames);
                if cc == 1
                    joinedTableOdd = lagPupilTrainingTable;
                    cc = cc + 1;
                elseif cc == 2
                    joinedTableEven = lagPupilTrainingTable;
                    cc = cc + 1;
                elseif rem(cc,2) == 1
                    joinedTableOdd = vertcat(joinedTableOdd,lagPupilTrainingTable);
                    cc = cc + 1;
                elseif rem(cc,2) == 0
                    joinedTableEven = vertcat(joinedTableEven,lagPupilTrainingTable);
                    cc = cc + 1;
                end
            end
        case 'zero'
            % load each updated training set and concatenate the data into table
            cc = 1;
            for bb = 1:size(pupilTrainingDataFileIDs,1)
                trainingTableFileID = pupilTrainingDataFileIDs(bb,:);
                load(trainingTableFileID)
                zDiameter = pupilTrainingTable.zDiameter(1:end);
                mmDiameter = pupilTrainingTable.mmDiameter(1:end);
                behavState = pupilTrainingTable.behavState(1:end);
                % create table to send into model
                variableNames = {'zDiameter','mmDiameter','behavState'};
                lagPupilTrainingTable = table(zDiameter,mmDiameter,behavState,'VariableNames',variableNames);
                if cc == 1
                    joinedTableOdd = lagPupilTrainingTable;
                    cc = cc + 1;
                elseif cc == 2
                    joinedTableEven = lagPupilTrainingTable;
                    cc = cc + 1;
                elseif rem(cc,2) == 1
                    joinedTableOdd = vertcat(joinedTableOdd,lagPupilTrainingTable);
                    cc = cc + 1;
                elseif rem(cc,2) == 0
                    joinedTableEven = vertcat(joinedTableEven,lagPupilTrainingTable);
                    cc = cc + 1;
                end
            end
        case 'negFive'
            % load each updated training set and concatenate the data into table
            cc = 1;
            for bb = 1:size(pupilTrainingDataFileIDs,1)
                trainingTableFileID = pupilTrainingDataFileIDs(bb,:);
                load(trainingTableFileID)
                zDiameter = pupilTrainingTable.zDiameter(2:end);
                mmDiameter = pupilTrainingTable.mmDiameter(2:end);
                behavState = pupilTrainingTable.behavState(1:end - 1);
                % create table to send into model
                variableNames = {'zDiameter','mmDiameter','behavState'};
                lagPupilTrainingTable = table(zDiameter,mmDiameter,behavState,'VariableNames',variableNames);
                if cc == 1
                    joinedTableOdd = lagPupilTrainingTable;
                    cc = cc + 1;
                elseif cc == 2
                    joinedTableEven = lagPupilTrainingTable;
                    cc = cc + 1;
                elseif rem(cc,2) == 1
                    joinedTableOdd = vertcat(joinedTableOdd,lagPupilTrainingTable);
                    cc = cc + 1;
                elseif rem(cc,2) == 0
                    joinedTableEven = vertcat(joinedTableEven,lagPupilTrainingTable);
                    cc = cc + 1;
                end
            end
        case 'negTen'
            % load each updated training set and concatenate the data into table
            cc = 1;
            for bb = 1:size(pupilTrainingDataFileIDs,1)
                trainingTableFileID = pupilTrainingDataFileIDs(bb,:);
                load(trainingTableFileID)
                zDiameter = pupilTrainingTable.zDiameter(3:end);
                mmDiameter = pupilTrainingTable.mmDiameter(3:end);
                behavState = pupilTrainingTable.behavState(1:end - 2);
                % create table to send into model
                variableNames = {'zDiameter','mmDiameter','behavState'};
                lagPupilTrainingTable = table(zDiameter,mmDiameter,behavState,'VariableNames',variableNames);
                if cc == 1
                    joinedTableOdd = lagPupilTrainingTable;
                    cc = cc + 1;
                elseif cc == 2
                    joinedTableEven = lagPupilTrainingTable;
                    cc = cc + 1;
                elseif rem(cc,2) == 1
                    joinedTableOdd = vertcat(joinedTableOdd,lagPupilTrainingTable);
                    cc = cc + 1;
                elseif rem(cc,2) == 0
                    joinedTableEven = vertcat(joinedTableEven,lagPupilTrainingTable);
                    cc = cc + 1;
                end
            end
        case 'negFifteen'
            % load each updated training set and concatenate the data into table
            cc = 1;
            for bb = 1:size(pupilTrainingDataFileIDs,1)
                trainingTableFileID = pupilTrainingDataFileIDs(bb,:);
                load(trainingTableFileID)
                zDiameter = pupilTrainingTable.zDiameter(4:end);
                mmDiameter = pupilTrainingTable.mmDiameter(4:end);
                behavState = pupilTrainingTable.behavState(1:end - 3);
                % create table to send into model
                variableNames = {'zDiameter','mmDiameter','behavState'};
                lagPupilTrainingTable = table(zDiameter,mmDiameter,behavState,'VariableNames',variableNames);
                if cc == 1
                    joinedTableOdd = lagPupilTrainingTable;
                    cc = cc + 1;
                elseif cc == 2
                    joinedTableEven = lagPupilTrainingTable;
                    cc = cc + 1;
                elseif rem(cc,2) == 1
                    joinedTableOdd = vertcat(joinedTableOdd,lagPupilTrainingTable);
                    cc = cc + 1;
                elseif rem(cc,2) == 0
                    joinedTableEven = vertcat(joinedTableEven,lagPupilTrainingTable);
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
    % replace Yodd with Awake/Asleep labels
    for aa = 1:length(Yodd.behavState)
        if strcmp(Yodd.behavState{aa,1},'Not Sleep') == true
            Yodd.behavState{aa,1} = 'Awake';
        elseif strcmp(Yodd.behavState{aa,1},'NREM Sleep') || strcmp(Yodd.behavState{aa,1},'REM Sleep') == true
            Yodd.behavState{aa,1} = 'Asleep';
        end
    end
    % replace Yeven with Awake/Asleep labels
    for aa = 1:length(Yeven.behavState)
        if strcmp(Yeven.behavState{aa,1},'Not Sleep') == true
            Yeven.behavState{aa,1} = 'Awake';
        elseif strcmp(Yeven.behavState{aa,1},'NREM Sleep') || strcmp(Yeven.behavState{aa,1},'REM Sleep') == true
            Yeven.behavState{aa,1} = 'Asleep';
        end
    end
    % train support vector machine (SVM) classifier
    disp('Training Support Vector Machine...'); disp(' ')
    Xodd = Xodd(:,1);
    Xeven = Xeven(:,1);
    SVM_MDL = fitcsvm(Xodd,Yodd);
    % determine k-fold loss of the model
    disp('Cross-validating (k-fold) the support vector machine classifier...'); disp(' ')
    CV_SVM_MDL = crossval(SVM_MDL,'kfold',10);
    loss = kfoldLoss(CV_SVM_MDL);
    disp(['10-fold loss classification error: ' num2str(loss)]); disp(' ')
    % use the model to generate a set of scores for the even set of data
    [XoddLabels,~] = predict(SVM_MDL,Xodd);
    [XevenLabels,~] = predict(SVM_MDL,Xeven.zDiameter);
    % save labels for later confusion matrix
    Results_LaggedPupilSleepModel.(animalID).(lag).SVM.mdl = SVM_MDL;
    Results_LaggedPupilSleepModel.(animalID).(lag).SVM.zBoundary = -SVM_MDL.Bias/SVM_MDL.Beta;
    Results_LaggedPupilSleepModel.(animalID).(lag).SVM.loss = loss;
    Results_LaggedPupilSleepModel.(animalID).(lag).SVM.Xodd = Xodd;
    Results_LaggedPupilSleepModel.(animalID).(lag).SVM.Yodd = Yodd;
    Results_LaggedPupilSleepModel.(animalID).(lag).SVM.Xeven = Xeven;
    Results_LaggedPupilSleepModel.(animalID).(lag).SVM.Yeven = Yeven;
    Results_LaggedPupilSleepModel.(animalID).(lag).SVM.trainYlabels = Yodd.behavState;
    Results_LaggedPupilSleepModel.(animalID).(lag).SVM.trainXlabels = XoddLabels;
    Results_LaggedPupilSleepModel.(animalID).(lag).SVM.testYlabels = Yeven.behavState;
    Results_LaggedPupilSleepModel.(animalID).(lag).SVM.testXlabels = XevenLabels;
end
% save data
cd([rootFolder delim])
save('Results_LaggedPupilSleepModel.mat','Results_LaggedPupilSleepModel','-v7.3')
end
