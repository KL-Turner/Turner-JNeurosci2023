function [] = CreatePupilModelDataSet_JNeurosci2022(procDataFileIDs)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Arrange data into a table of most-relevant parameters for model training/classification
%________________________________________________________________________________________________________________________

for a = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(a,:);
    pupilModelDataSetID = [procDataFileID(1:end - 12) 'PupilModelData.mat'];
    load(procDataFileID)
    if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
        % create table to send into model
        variableNames = {'zDiameter','mmDiameter'};
        % pre-allocation
        avgZDiameterColumn = zeros(180,1);
        avgmmDiameterColumn = zeros(180,1);
        % extract relevant parameters from each epoch
        for b = 1:length(avgZDiameterColumn)
            % average pupil area (z-unit or mm)
            avgZDiameterColumn(b,1) = mean(ProcData.sleep.parameters.Pupil.zDiameter{b,1},'omitnan');
            avgmmDiameterColumn(b,1) = mean(ProcData.sleep.parameters.Pupil.mmDiameter{b,1},'omitnan');
        end
        % create table
        pupilParamsTable = table(avgZDiameterColumn,avgmmDiameterColumn,'VariableNames',variableNames);
        save(pupilModelDataSetID,'pupilParamsTable')
    end
end

end
