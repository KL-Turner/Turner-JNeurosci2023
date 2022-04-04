function [Results_PupilSleepModel] = AnalzyePupilSleepModelAccuracy_Pupil(animalID,rootFolder,delim,Results_PupilSleepModel)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose:
%________________________________________________________________________________________________________________________

%% function parameters
dataLocation = [rootFolder delim 'Data' delim animalID delim 'Training Data'];
cd(dataLocation)
% character list of all ProcData files
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
% prepare training data by updating parameters
AddPupilSleepParameters_IOS(procDataFileIDs)
CreatePupilModelDataSet_IOS(procDataFileIDs)
UpdatePupilTrainingDataSet_IOS(procDataFileIDs)
% training data file IDs
pupilTrainingDataFileStruct = dir('*_PupilTrainingData.mat');
pupilTrainingDataFiles = {pupilTrainingDataFileStruct.name}';
pupilTrainingDataFileIDs = char(pupilTrainingDataFiles);
% Load each updated training set and concatenate the data into table
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
        joinedTableOdd = vertcat(joinedTableOdd,pupilTrainingTable); %#ok<*AGROW>
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
zXodd = Xodd(:,1); zXeven = Xeven(:,1);
mXodd = Xodd(:,2); 
zSVM_MDL = fitcsvm(zXodd,Yodd); %,'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',struct('AcquisitionFunctionName','expected-improvement-plus'));
mmSVM_MDL = fitcsvm(mXodd,Yodd); %,'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',struct('AcquisitionFunctionName','expected-improvement-plus'));
% determine k-fold loss of the model
disp('Cross-validating (k-fold) the support vector machine classifier...'); disp(' ')
CV_SVM_MDL = crossval(zSVM_MDL,'kfold',10);
loss = kfoldLoss(CV_SVM_MDL);
disp(['10-fold loss classification error: ' num2str(loss)]); disp(' ')
% use the model to generate a set of scores for the even set of data
[XoddLabels,~] = predict(zSVM_MDL,zXodd);
[XevenLabels,~] = predict(zSVM_MDL,Xeven.zDiameter);
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
% ROC curve
svmLogical = strcmp(Yodd.behavState,'Awake');
mdlSVM = fitcsvm(Xodd.zDiameter,svmLogical); %,'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',struct('AcquisitionFunctionName','expected-improvement-plus'));
mdlSVM = fitPosterior(mdlSVM);
[~,scoreSVM] = resubPredict(mdlSVM);
[Xsvm,Ysvm,Tsvm,AUCsvm,OPTROCPTsvm] = perfcurve(svmLogical,scoreSVM(:,mdlSVM.ClassNames),'true');
% save results
Results_PupilSleepModel.(animalID).SVM.rocX = Xsvm;
Results_PupilSleepModel.(animalID).SVM.rocY = Ysvm;
Results_PupilSleepModel.(animalID).SVM.rocT = Tsvm;
Results_PupilSleepModel.(animalID).SVM.rocAUC = AUCsvm;
Results_PupilSleepModel.(animalID).SVM.rocOPTROCPT = OPTROCPTsvm;
%% check boundary equation
exampleBoundary = -zSVM_MDL.Bias/zSVM_MDL.Beta;
figure;
sgtitle([animalID ' Single predictor, binary class SVM'])
subplot(1,2,1)
gscatter(Xodd.zDiameter,randn(length(Xodd.zDiameter),1),Yodd.behavState); 
hold on;
xline(exampleBoundary)
set(gca,'YTickLabel',[]);
set(gca,'box','off')
xlabel('Diameter (z-units)')
axis square
exampleBoundary = -mmSVM_MDL.Bias/mmSVM_MDL.Beta;
subplot(1,2,2);
gscatter(Xodd.mmDiameter,randn(length(Xodd.mmDiameter),1),Yodd.behavState); 
hold on;
xline(exampleBoundary)
set(gca,'YTickLabel',[]);
set(gca,'box','off')
xlabel('Diameter (mm)')
axis square
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
% Results_PupilSleepModel.(animalID).EC.mdl = EC_MDL;
% Results_PupilSleepModel.(animalID).EC.loss = loss;
% Results_PupilSleepModel.(animalID).EC.Xodd = Xodd;
% Results_PupilSleepModel.(animalID).EC.Yodd = Yodd;
% Results_PupilSleepModel.(animalID).EC.Xeven = Xeven;
% Results_PupilSleepModel.(animalID).EC.Yeven = Yeven;
% Results_PupilSleepModel.(animalID).EC.trainYlabels = Yodd.behavState;
% Results_PupilSleepModel.(animalID).EC.trainXlabels = XoddLabels;
% Results_PupilSleepModel.(animalID).EC.testYlabels = Yeven.behavState;
% Results_PupilSleepModel.(animalID).EC.testXlabels = XevenLabels;
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
% Results_PupilSleepModel.(animalID).RF.mdl = RF_MDL;
% Results_PupilSleepModel.(animalID).RF.RF_OOBerror = RF_OOBerror;
% Results_PupilSleepModel.(animalID).RF.Xodd = Xodd;
% Results_PupilSleepModel.(animalID).RF.Yodd = Yodd;
% Results_PupilSleepModel.(animalID).RF.Xeven = Xeven;
% Results_PupilSleepModel.(animalID).RF.Yeven = Yeven;
% Results_PupilSleepModel.(animalID).RF.trainYlabels = Yodd.behavState;
% Results_PupilSleepModel.(animalID).RF.trainXlabels = XoddLabels;
% Results_PupilSleepModel.(animalID).RF.testYlabels = Yeven.behavState;
% Results_PupilSleepModel.(animalID).RF.testXlabels = XevenLabels;
%% save data
cd([rootFolder delim])
save('Results_PupilSleepModel.mat','Results_PupilSleepModel')

end
