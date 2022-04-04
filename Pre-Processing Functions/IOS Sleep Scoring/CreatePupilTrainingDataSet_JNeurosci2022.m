function [] = CreatePupilTrainingDataSet_JNeurosci2022(procDataFileIDs)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Go through each file and train a data set for the model or for model validation
%________________________________________________________________________________________________________________________

for a = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(a,:);
    pupilModelDataFileID = [procDataFileID(1:end - 12) 'PupilModelData.mat'];
    pupilTrainingDataFileID = [procDataFileID(1:end - 12) 'PupilTrainingData.mat'];
    trainingDataFileID = [procDataFileID(1:end - 12) 'TrainingData.mat'];
    load(procDataFileID)
    if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
        load(pupilModelDataFileID)
        load(trainingDataFileID)
        pupilParamsTable.behavState = trainingTable.behavState;
        pupilTrainingTable = pupilParamsTable;
        save(pupilTrainingDataFileID,'pupilTrainingTable')
    end
end

end
