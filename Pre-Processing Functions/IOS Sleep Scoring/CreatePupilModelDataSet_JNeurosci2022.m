function [] = CreatePupilModelDataSet_JNeurosci2022(procDataFileIDs)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: Arrange data into a table of most-relevant parameters for model training/classification
%________________________________________________________________________________________________________________________

for a = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(a,:);
    pupilModelDataSetID = [procDataFileID(1:end - 12) 'PupilModelData.mat'];
    load(procDataFileID)
    if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
        %% Create table to send into model
        variableNames = {'zDiameter','mmDiameter'};
        % pre-allocation
        avgZDiameter_column = zeros(180,1);
        avgmmDiameter_column = zeros(180,1);
        % extract relevant parameters from each epoch
        for b = 1:length(avgZDiameter_column)
            % number of binarized whisking events
            % average pupil area
            avgZDiameter_column(b,1) = mean(ProcData.sleep.parameters.Pupil.zDiameter{b,1},'omitnan');
            avgmmDiameter_column(b,1) = mean(ProcData.sleep.parameters.Pupil.mmDiameter{b,1},'omitnan');
        end
        % create table
        pupilParamsTable = table(avgZDiameter_column,avgmmDiameter_column,'VariableNames',variableNames);
        save(pupilModelDataSetID,'pupilParamsTable')
    end
end

end
