function [Results_PhysioSleepModel] = AnalzyePhysiologicalSleepModelAccuracy_Pupil(animalID,rootFolder,delim,Results_PhysioSleepModel)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose:
%________________________________________________________________________________________________________________________

%% function parameters
dataLocation = [rootFolder delim 'Data' delim animalID delim 'Bilateral Imaging'];
cd(dataLocation)
% Resting Baselines structure
baselineFileStruct = dir('*_RestingBaselines.mat');
baselineDataFiles = {baselineFileStruct.name}';
baselineDataFileID = char(baselineDataFiles);
load(baselineDataFileID)
% training data location
cd([rootFolder delim])
dataLocation = [rootFolder delim 'Data' delim animalID delim 'Training Data'];
cd(dataLocation)
% ProcData file IDs
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
% prepare training data by updating parameters
AddSleepParameters_IOS(procDataFileIDs,RestingBaselines,'manualSelection')
CreateModelDataSet_IOS(procDataFileIDs)
UpdateTrainingDataSets_IOS(procDataFileIDs)
% training data file IDs
pupilTrainingDataFileStruct = dir('*_PupilTrainingData.mat');
pupilTrainingDataFiles = {pupilTrainingDataFileStruct.name}';
pupilTrainingDataFileIDs = char(pupilTrainingDataFiles);
% only use training files that match those of the pupil
for aa = 1:size(pupilTrainingDataFileIDs)
    trainingDataFileIDs(aa,:) = strrep(pupilTrainingDataFileIDs(aa,:),'Pupil','');
end
% Load each updated training set and concatenate the data into table
cc = 1;
for bb = 1:size(trainingDataFileIDs,1)
    trainingTableFileID = trainingDataFileIDs(bb,:);
    if cc == 1
        load(trainingTableFileID)
        joinedTableOdd = trainingTable;
        cc = cc + 1;
    elseif cc == 2
        load(trainingTableFileID)
        joinedTableEven = trainingTable;
        cc = cc + 1;
    elseif rem(cc,2) == 1
        load(trainingTableFileID)
        joinedTableOdd = vertcat(joinedTableOdd,trainingTable);
        cc = cc + 1;
    elseif rem(cc,2) == 0
        load(trainingTableFileID)
        joinedTableEven = vertcat(joinedTableEven,trainingTable);
        cc = cc + 1;
    end
end
% train on odd data
Xodd = joinedTableOdd(:,1:end - 1);
Yodd = joinedTableOdd(:,end);
% test on even data
Xeven = joinedTableEven(:,1:end - 1);
Yeven = joinedTableEven(:,end);
for aa = 1:length(Yodd.behavState)
    if strcmp(Yodd.behavState{aa,1},'Not Sleep') == true
        Yodd.behavState{aa,1} = 'Awake';
    elseif strcmp(Yodd.behavState{aa,1},'NREM Sleep') || strcmp(Yodd.behavState{aa,1},'REM Sleep') == true
        Yodd.behavState{aa,1} = 'Asleep';
    end
end
for aa = 1:length(Yeven.behavState)
    if strcmp(Yeven.behavState{aa,1},'Not Sleep') == true
        Yeven.behavState{aa,1} = 'Awake';
    elseif strcmp(Yeven.behavState{aa,1},'NREM Sleep') || strcmp(Yeven.behavState{aa,1},'REM Sleep') == true
        Yeven.behavState{aa,1} = 'Asleep';
    end
end
%% Train Support Vector Machine (SVM) classifier
disp('Training Support Vector Machine...'); disp(' ')
SVM_MDL = fitcsvm(Xodd,Yodd); %,'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',struct('AcquisitionFunctionName','expected-improvement-plus'));
% determine k-fold loss of the model
disp('Cross-validating (k-fold) the support vector machine classifier...'); disp(' ')
CV_SVM_MDL = crossval(SVM_MDL,'kfold',10);
loss = kfoldLoss(CV_SVM_MDL);
disp(['10-fold loss classification error: ' num2str(loss)]); disp(' ')
% use the model to generate a set of scores for the even set of data
[XoddLabels,~] = predict(SVM_MDL,Xodd);
[XevenLabels,~] = predict(SVM_MDL,Xeven);
% save labels for later confusion matrix
Results_PhysioSleepModel.(animalID).SVM.mdl = SVM_MDL;
Results_PhysioSleepModel.(animalID).SVM.loss = loss;
Results_PhysioSleepModel.(animalID).SVM.Xodd = Xodd;
Results_PhysioSleepModel.(animalID).SVM.Yodd = Yodd;
Results_PhysioSleepModel.(animalID).SVM.Xeven = Xeven;
Results_PhysioSleepModel.(animalID).SVM.Yeven = Yeven;
Results_PhysioSleepModel.(animalID).SVM.trainYlabels = Yodd.behavState;
Results_PhysioSleepModel.(animalID).SVM.trainXlabels = XoddLabels;
Results_PhysioSleepModel.(animalID).SVM.testYlabels = Yeven.behavState;
Results_PhysioSleepModel.(animalID).SVM.testXlabels = XevenLabels;
% ROC curve
svmLogical = strcmp(Yodd.behavState,'Awake');
mdlSVM = fitcsvm(Xodd,svmLogical); %,'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',struct('AcquisitionFunctionName','expected-improvement-plus'));
mdlSVM = fitPosterior(mdlSVM);
[~,scoreSVM] = resubPredict(mdlSVM);
[Xsvm,Ysvm,Tsvm,AUCsvm,OPTROCPTsvm] = perfcurve(svmLogical,scoreSVM(:,mdlSVM.ClassNames),'true');
% save results
Results_PhysioSleepModel.(animalID).SVM.rocX = Xsvm;
Results_PhysioSleepModel.(animalID).SVM.rocY = Ysvm;
Results_PhysioSleepModel.(animalID).SVM.rocT = Tsvm;
Results_PhysioSleepModel.(animalID).SVM.rocAUC = AUCsvm;
Results_PhysioSleepModel.(animalID).SVM.rocOPTROCPT = OPTROCPTsvm;
%% Ensemble classification - AdaBoostM2, Subspace, Bag, LPBoost,RUSBoost, TotalBoost
% disp('Training Ensemble Classifier...'); disp(' ')
% t = templateTree('Reproducible',true);
% EC_MDL = fitcensemble(Xodd,Yodd,'OptimizeHyperparameters','auto','Learners',t,'HyperparameterOptimizationOptions',...
%     struct('AcquisitionFunctionName','expected-improvement-plus'),'ClassNames',{'Awake','Asleep'});
% % determine k-fold loss of the model
% disp('Cross-validating (k-fold) the ensemble classifier...'); disp(' ')
% CV_EC_MDL = crossval(EC_MDL,'kfold',10);
% loss = kfoldLoss(CV_EC_MDL);
% disp(['10-fold loss classification error: ' num2str(loss)]); disp(' ')
% % use the model to generate a set of scores for the even set of data
% [XoddLabels,~] = predict(EC_MDL,Xodd);
% [XevenLabels,~] = predict(EC_MDL,Xeven);
% % save labels for later confusion matrix
% Results_PhysioSleepModel.(animalID).EC.mdl = EC_MDL;
% Results_PhysioSleepModel.(animalID).EC.loss = loss;
% Results_PhysioSleepModel.(animalID).EC.Xodd = Xodd;
% Results_PhysioSleepModel.(animalID).EC.Yodd = Yodd;
% Results_PhysioSleepModel.(animalID).EC.Xeven = Xeven;
% Results_PhysioSleepModel.(animalID).EC.Yeven = Yeven;
% Results_PhysioSleepModel.(animalID).EC.trainYlabels = Yodd.behavState;
% Results_PhysioSleepModel.(animalID).EC.trainXlabels = XoddLabels;
% Results_PhysioSleepModel.(animalID).EC.testYlabels = Yeven.behavState;
% Results_PhysioSleepModel.(animalID).EC.testXlabels = XevenLabels;
%% Random forest
% disp('Training Random Forest Classifier...'); disp(' ')
% numTrees = 128;
% RF_MDL = TreeBagger(numTrees,Xodd,Yodd,'Method','Classification','Surrogate','all','OOBPrediction','on','ClassNames',{'Awake','Asleep'});
% % determine the misclassification probability (for classification trees) for out-of-bag observations in the training data
% RF_OOBerror = oobError(RF_MDL,'Mode','Ensemble');
% disp(['Random Forest out-of-bag error: ' num2str(RF_OOBerror*100) '%']); disp(' ')
% % use the model to generate a set of scores for the even set of data
% [XoddLabels,~] = predict(RF_MDL,Xodd);
% [XevenLabels,~] = predict(RF_MDL,Xeven);
% % save labels for later confusion matrix
% Results_PhysioSleepModel.(animalID).RF.mdl = RF_MDL;
% Results_PhysioSleepModel.(animalID).RF.RF_OOBerror = RF_OOBerror;
% Results_PhysioSleepModel.(animalID).RF.Xodd = Xodd;
% Results_PhysioSleepModel.(animalID).RF.Yodd = Yodd;
% Results_PhysioSleepModel.(animalID).RF.Xeven = Xeven;
% Results_PhysioSleepModel.(animalID).RF.Yeven = Yeven;
% Results_PhysioSleepModel.(animalID).RF.trainYlabels = Yodd.behavState;
% Results_PhysioSleepModel.(animalID).RF.trainXlabels = XoddLabels;
% Results_PhysioSleepModel.(animalID).RF.testYlabels = Yeven.behavState;
% Results_PhysioSleepModel.(animalID).RF.testXlabels = XevenLabels;
%% save data
cd([rootFolder delim])
save('Results_PhysioSleepModel.mat','Results_PhysioSleepModel')
end
