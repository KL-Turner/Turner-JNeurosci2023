function [] = UpdatePupilTrainingDataSet_JNeurosci2023(procDataFileIDs)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Update training data file with most recent predictors
%________________________________________________________________________________________________________________________

for a = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(a,:);
    pupilModelDataFileID = [procDataFileID(1:end - 12) 'PupilModelData.mat'];
    pupilTrainingDataFileID = [procDataFileID(1:end - 12) 'PupilTrainingData.mat'];
    trainingDataFileID = [procDataFileID(1:end - 12) 'TrainingData.mat'];
    load(procDataFileID)
    % only files with accurate diameter tracking
    if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
        load(pupilModelDataFileID)
        load(trainingDataFileID)
        % update training data decisions with most recent predictor table
        pupilParamsTable.behavState = trainingTable.behavState;
        pupilTrainingTable = pupilParamsTable;
        save(pupilTrainingDataFileID,'pupilTrainingTable')
    end
end

end
