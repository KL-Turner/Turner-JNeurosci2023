function [] = SleepScoreMainScript_JNeurosci2023()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Sleep score manual training files, training classification models, and create sleep data structure
%________________________________________________________________________________________________________________________

zap;
disp('Loading necessary file names...'); disp(' ')
baselineType = 'manualSelection';
startingDirectory = cd;
% create training data set for each animal
baselineDirectory = [startingDirectory '\Bilateral Imaging\'];
cd(baselineDirectory)
% load the baseline structure
baselinesFileStruct = dir('*_RestingBaselines.mat');
baselinesFile = {baselinesFileStruct.name}';
baselinesFileID = char(baselinesFile);
load(baselinesFileID)
cd(startingDirectory)
% cd to the animal's training set folde
trainingDirectory = [startingDirectory '\Training Data\'];
cd(trainingDirectory)
% character list of all ProcData files
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
% add sleep parameters (each behavior we care about during sleep)
AddSleepParameters_JNeurosci2023(procDataFileIDs,RestingBaselines,baselineType)
% create a table of values for sleep scoring model
CreateModelDataSet_JNeurosci2023(procDataFileIDs)
% create manual decisions for each 5 second bin
CreateTrainingDataSet_JNeurosci2023(procDataFileIDs,RestingBaselines,baselineType)
% combine the existing training set decisions with any sleep parameter changes
UpdateTrainingDataSets_JNeurosci2023(procDataFileIDs)
cd(startingDirectory)
% train Models - cycle through each data set and update any necessary parameters
[animalID] = TrainSleepModels_JNeurosci2023;
% sleep score an animal's data set and create a SleepData.mat structure for classification
modelNames = {'SVM','Ensemble','Forest','Manual'};
SleepData = [];
% cd to the animal's bilateral imaging folder
cd(baselineDirectory)
% load the baseline structure
baselinesFileStruct = dir('*_RestingBaselines.mat');
baselinesFile = {baselinesFileStruct.name}';
baselinesFileID = char(baselinesFile);
load(baselinesFileID)
% character list of all ProcData files
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
% add sleep parameters (each behavior we care about during sleep)
AddSleepParameters_JNeurosci2023(procDataFileIDs,RestingBaselines,baselineType)
% create a table of values for sleep scoring model
CreateModelDataSet_JNeurosci2023(procDataFileIDs)
% character list of all ModelData files
modelDataFileStruct = dir('*_ModelData.mat');
modelDataFiles = {modelDataFileStruct.name}';
modelDataFileIDs = char(modelDataFiles);
for c = 1:length(modelNames)
    modelName = modelNames{1,c};
    [ScoringResults] = PredictBehaviorEvents_JNeurosci2023(animalID,startingDirectory,baselineDirectory,modelDataFileIDs,modelName);
    ApplySleepLogical_JNeurosci2023(startingDirectory,trainingDirectory,baselineDirectory,modelName,ScoringResults)
    NREMsleepTime = 30; % seconds
    REMsleepTime = 60; % seconds
    [SleepData] = CreateSleepData_JNeurosci2023(startingDirectory,trainingDirectory,baselineDirectory,NREMsleepTime,REMsleepTime,modelName,SleepData);
end
cd(baselineDirectory)
save([animalID '_SleepData.mat'],'SleepData')
cd(startingDirectory)
disp('Sleep Scoring analysis complete'); disp(' ')
