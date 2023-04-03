function [] = CreatePupilModelDataSet_JNeurosci2023(procDataFileIDs)
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
        variableNames = {'meanMDiameter','varMDiameter','minMDiameter',...
            'meanZDiameter','varZDiameter','minZDiameter',...
            'sumEyeMotion','varEyeMotion',...
            'meanCentroidX','varCentroidX','maxCentroidX',...
            'meanCentroidY','varCentroidY','maxCentroidY'};%,...
        %'sumBinWhisk','sumWhiskAngle','varWhiskAngle'};
        % pre-allocation
        avgMDiameterColumn = zeros(180,1);
        varMDiameterColumn = zeros(180,1);
        minMDiameterColumn = zeros(180,1);
        avgZDiameterColumn = zeros(180,1);
        varZDiameterColumn = zeros(180,1);
        minZDiameterColumn = zeros(180,1);
        sumEyeMotionColumn = zeros(180,1);
        varEyeMotionColumn = zeros(180,1);
        avgCentroidXColumn = zeros(180,1);
        varCentroidXColumn = zeros(180,1);
        maxCentroidXColumn = zeros(180,1);
        avgCentroidYColumn = zeros(180,1);
        varCentroidYColumn = zeros(180,1);
        maxCentroidYColumn = zeros(180,1);
        sumBinWhiskColumn = zeros(180,1);
        sumWhiskAngleColumn = zeros(180,1);
        varWhiskAngleColumn = zeros(180,1);
        % extract relevant parameters from each epoch
        for b = 1:length(avgZDiameterColumn)
            % average pupil area (z-unit or mm)
            avgMDiameterColumn(b,1) = mean(ProcData.sleep.parameters.Pupil.mmDiameter{b,1},'omitnan');
            varMDiameterColumn(b,1) = var(ProcData.sleep.parameters.Pupil.mmDiameter{b,1},'omitnan');
            minMDiameterColumn(b,1) = min(ProcData.sleep.parameters.Pupil.mmDiameter{b,1},[],'omitnan');
            avgZDiameterColumn(b,1) = mean(ProcData.sleep.parameters.Pupil.zDiameter{b,1},'omitnan');
            varZDiameterColumn(b,1) = var(ProcData.sleep.parameters.Pupil.zDiameter{b,1},'omitnan');
            minZDiameterColumn(b,1) = min(ProcData.sleep.parameters.Pupil.zDiameter{b,1},[],'omitnan');
            sumEyeMotionColumn(b,1) = sum(ProcData.sleep.parameters.Pupil.eyeMotion{b,1},'omitnan');
            varEyeMotionColumn(b,1) = var(ProcData.sleep.parameters.Pupil.eyeMotion{b,1},'omitnan');
            avgCentroidXColumn(b,1) = mean(ProcData.sleep.parameters.Pupil.centroidX{b,1},'omitnan');
            varCentroidXColumn(b,1) = var(ProcData.sleep.parameters.Pupil.centroidX{b,1},'omitnan');
            maxCentroidXColumn(b,1) = max(ProcData.sleep.parameters.Pupil.centroidX{b,1},[],'omitnan');
            avgCentroidYColumn(b,1) = mean(ProcData.sleep.parameters.Pupil.centroidY{b,1},'omitnan');
            varCentroidYColumn(b,1) = var(ProcData.sleep.parameters.Pupil.centroidY{b,1},'omitnan');
            maxCentroidYColumn(b,1) = max(ProcData.sleep.parameters.Pupil.centroidY{b,1},[],'omitnan');
            sumBinWhiskColumn(b,1) = sum(ProcData.sleep.parameters.binWhiskerAngle{b,1},'omitnan');
            sumWhiskAngleColumn(b,1) = sum(ProcData.sleep.parameters.Pupil.whiskerMotion{b,1},'omitnan');
            varWhiskAngleColumn(b,1) = var(ProcData.sleep.parameters.Pupil.whiskerMotion{b,1},'omitnan');
        end
        % create table
        pupilParamsTable = table(avgMDiameterColumn,varMDiameterColumn,minMDiameterColumn,...
            avgZDiameterColumn,varZDiameterColumn,minZDiameterColumn,...
            sumEyeMotionColumn,varEyeMotionColumn,...
            avgCentroidXColumn,varCentroidXColumn,maxCentroidXColumn,...
            avgCentroidYColumn,varCentroidYColumn,maxCentroidYColumn,'VariableNames',variableNames);%,...
        % sumBinWhiskColumn,sumWhiskAngleColumn,varWhiskAngleColumn,'VariableNames',variableNames);
        save(pupilModelDataSetID,'pupilParamsTable')
    end
end

end
