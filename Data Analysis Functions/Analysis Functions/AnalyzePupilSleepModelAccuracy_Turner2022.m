function [Results_PupilSleepModel] = AnalyzePupilSleepModelAccuracy_Turner2022(animalID,rootFolder,delim,Results_PupilSleepModel)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: train/validate machine learning classifier using solely the pupil diameter
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
% load each updated training set and concatenate the data into table
cc = 1;
for bb = 1:size(pupilTrainingDataFileIDs,1)
    trainingTableFileID = pupilTrainingDataFileIDs(bb,:);
    if cc == 1
        load(trainingTableFileID)
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
%% train support vector machine (SVM) classifier
disp('Training Support Vector Machine...'); disp(' ')
zXodd = Xodd(:,1); 
zXeven = Xeven(:,1);
mXodd = Xodd(:,2);
zSVM_MDL = fitcsvm(zXodd,Yodd);
mmSVM_MDL = fitcsvm(mXodd,Yodd);
% determine k-fold loss of the model
disp('Cross-validating (k-fold) the support vector machine classifier...'); disp(' ')
CV_SVM_MDL = crossval(zSVM_MDL,'kfold',10);
loss = kfoldLoss(CV_SVM_MDL);
disp(['10-fold loss classification error: ' num2str(loss)]); disp(' ')
% use the model to generate a set of scores for the even set of data
[XoddLabels,~] = predict(zSVM_MDL,zXodd);
[XevenLabels,~] = predict(zSVM_MDL,zXeven);
% save labels for later confusion matrix
Results_PupilSleepModel.(animalID).SVM.mdl = zSVM_MDL;
Results_PupilSleepModel.(animalID).SVM.zBoundary = -zSVM_MDL.Bias/zSVM_MDL.Beta;
Results_PupilSleepModel.(animalID).SVM.mmBoundary = -mmSVM_MDL.Bias/mmSVM_MDL.Beta;
Results_PupilSleepModel.(animalID).SVM.loss = loss;
Results_PupilSleepModel.(animalID).SVM.Xodd = zXodd;
Results_PupilSleepModel.(animalID).SVM.Yodd = Yodd;
Results_PupilSleepModel.(animalID).SVM.Xeven = zXeven;
Results_PupilSleepModel.(animalID).SVM.Yeven = Yeven;
Results_PupilSleepModel.(animalID).SVM.trainYlabels = Yodd.behavState;
Results_PupilSleepModel.(animalID).SVM.trainXlabels = XoddLabels;
Results_PupilSleepModel.(animalID).SVM.testYlabels = Yeven.behavState;
Results_PupilSleepModel.(animalID).SVM.testXlabels = XevenLabels;
% receiver operating characteristic curve
svmLogical = strcmp(Yodd.behavState,'Awake');
mdlSVM = fitcsvm(Xodd.zDiameter,svmLogical);
mdlSVM = fitPosterior(mdlSVM);
[~,scoreSVM] = resubPredict(mdlSVM);
[Xsvm,Ysvm,Tsvm,AUCsvm,OPTROCPTsvm] = perfcurve(svmLogical,scoreSVM(:,mdlSVM.ClassNames),'true');
% save results
Results_PupilSleepModel.(animalID).SVM.rocX = Xsvm;
Results_PupilSleepModel.(animalID).SVM.rocY = Ysvm;
Results_PupilSleepModel.(animalID).SVM.rocT = Tsvm;
Results_PupilSleepModel.(animalID).SVM.rocAUC = AUCsvm;
Results_PupilSleepModel.(animalID).SVM.rocOPTROCPT = OPTROCPTsvm;
%% ensemble classification - AdaBoostM2, Subspace, Bag, LPBoost,RUSBoost, TotalBoost
disp('Training Ensemble Classifier...'); disp(' ')
t = templateTree('Reproducible',true);
EC_MDL = fitcensemble(zXodd,Yodd,'OptimizeHyperparameters','auto','Learners',t,'HyperparameterOptimizationOptions',...
    struct('AcquisitionFunctionName','expected-improvement-plus'),'ClassNames',{'Awake','Asleep'});
% determine k-fold loss of the model
disp('Cross-validating (k-fold) the ensemble classifier...'); disp(' ')
CV_EC_MDL = crossval(EC_MDL,'kfold',10);
loss = kfoldLoss(CV_EC_MDL);
disp(['10-fold loss classification error: ' num2str(loss)]); disp(' ')
% use the model to generate a set of scores for the even set of data
[XoddLabels,~] = predict(EC_MDL,zXodd);
[XevenLabels,~] = predict(EC_MDL,zXeven);
% save labels for later confusion matrix
Results_PupilSleepModel.(animalID).EC.mdl = EC_MDL;
Results_PupilSleepModel.(animalID).EC.loss = loss;
Results_PupilSleepModel.(animalID).EC.Xodd = zXodd;
Results_PupilSleepModel.(animalID).EC.Yodd = Yodd;
Results_PupilSleepModel.(animalID).EC.Xeven = zXeven;
Results_PupilSleepModel.(animalID).EC.Yeven = Yeven;
Results_PupilSleepModel.(animalID).EC.trainYlabels = Yodd.behavState;
Results_PupilSleepModel.(animalID).EC.trainXlabels = XoddLabels;
Results_PupilSleepModel.(animalID).EC.testYlabels = Yeven.behavState;
Results_PupilSleepModel.(animalID).EC.testXlabels = XevenLabels;
%% random forest
disp('Training Random Forest Classifier...'); disp(' ')
numTrees = 128;
RF_MDL = TreeBagger(numTrees,zXodd,Yodd,'Method','Classification','Surrogate','all','OOBPrediction','on','ClassNames',{'Awake','Asleep'});
% determine the misclassification probability (for classification trees) for out-of-bag observations in the training data
RF_OOBerror = oobError(RF_MDL,'Mode','Ensemble');
disp(['Random Forest out-of-bag error: ' num2str(RF_OOBerror)]); disp(' ')
% use the model to generate a set of scores for the even set of data
[XoddLabels,~] = predict(RF_MDL,zXodd);
[XevenLabels,~] = predict(RF_MDL,zXeven);
% save labels for later confusion matrix
Results_PupilSleepModel.(animalID).RF.mdl = RF_MDL;
Results_PupilSleepModel.(animalID).RF.RF_OOBerror = RF_OOBerror;
Results_PupilSleepModel.(animalID).RF.Xodd = zXodd;
Results_PupilSleepModel.(animalID).RF.Yodd = Yodd;
Results_PupilSleepModel.(animalID).RF.Xeven = zXeven;
Results_PupilSleepModel.(animalID).RF.Yeven = Yeven;
Results_PupilSleepModel.(animalID).RF.trainYlabels = Yodd.behavState;
Results_PupilSleepModel.(animalID).RF.trainXlabels = XoddLabels;
Results_PupilSleepModel.(animalID).RF.testYlabels = Yeven.behavState;
Results_PupilSleepModel.(animalID).RF.testXlabels = XevenLabels;
%% save data
cd([rootFolder delim])
save('Results_PupilSleepModel.mat','Results_PupilSleepModel')

end
