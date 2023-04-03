function [] = UpdateTrainingDataSets_JNeurosci2023(procDataFileIDs)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Update training data file with most recent predictors
%________________________________________________________________________________________________________________________

for a = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(a,:);
    modelDataSetID = [procDataFileID(1:end - 12) 'ModelData.mat'];
    trainingDataSetID = [procDataFileID(1:end - 12) 'TrainingData.mat'];
    load(modelDataSetID)
    load(trainingDataSetID)
    % update training data decisions with most recent predictor table
    paramsTable.behavState = trainingTable.behavState;
    trainingTable = paramsTable;
    save(trainingDataSetID,'trainingTable')
end
