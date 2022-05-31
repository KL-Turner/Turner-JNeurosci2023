function [SpecData] = NormalizeSpectrograms_Turner2022(neuralDataTypes,RestingBaselines)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Normalizes each spectrogram by the resting baseline for that day.
%________________________________________________________________________________________________________________________

% file list A
specDirectory = dir('*_SpecDataA.mat');
specDataFiles = {specDirectory.name}';
specDataFileIDs = char(specDataFiles);
for aa = 1:size(specDataFileIDs,1)
    disp(['Normalizing spectrogram file (A) ' num2str(aa) ' of ' num2str(size(specDataFileIDs,1)) '...']); disp(' ')
    load(specDataFileIDs(aa,:),'-mat');
    [~,fileDate,~] = GetFileInfo_Turner2022(specDataFileIDs(aa,:));
    strDay = ConvertDate_Turner2022(fileDate);
    for bb = 1:length(neuralDataTypes)
        neuralDataType = neuralDataTypes{1,bb};
        baseLine = RestingBaselines.Spectrograms.(neuralDataType).fiveSecA.(strDay);
        S = SpecData.(neuralDataType).S;
        holdMatrix = baseLine.*ones(size(S));
        SpecData.(neuralDataType).normS = (S - holdMatrix)./holdMatrix;
    end
    save(specDataFileIDs(aa,:),'SpecData')
end
% file list B
specDirectory = dir('*_SpecDataB.mat');
specDataFiles = {specDirectory.name}';
specDataFileIDs = char(specDataFiles);
for cc = 1:size(specDataFileIDs,1)
    disp(['Normalizing spectrogram file (B) ' num2str(cc) ' of ' num2str(size(specDataFileIDs,1)) '...']); disp(' ')
    load(specDataFileIDs(cc,:),'-mat');
    [~,fileDate,~] = GetFileInfo_Turner2022(specDataFileIDs(cc,:));
    strDay = ConvertDate_Turner2022(fileDate);
    for dd = 1:length(neuralDataTypes)
        neuralDataType = neuralDataTypes{1,dd};
        baseLine = RestingBaselines.Spectrograms.(neuralDataType).oneSecB.(strDay);
        S = SpecData.(neuralDataType).S;
        holdMatrix = baseLine.*ones(size(S));
        SpecData.(neuralDataType).normS = (S - holdMatrix)./holdMatrix;
    end
    save(specDataFileIDs(cc,:),'SpecData')
end
% file list C
specDirectory = dir('*_SpecDataC.mat');
specDataFiles = {specDirectory.name}';
specDataFileIDs = char(specDataFiles);
for ee = 1:size(specDataFileIDs,1)
    disp(['Normalizing spectrogram file (C) ' num2str(ee) ' of ' num2str(size(specDataFileIDs,1)) '...']); disp(' ')
    load(specDataFileIDs(ee,:),'-mat');
    [~,fileDate,~] = GetFileInfo_Turner2022(specDataFileIDs(ee,:));
    strDay = ConvertDate_Turner2022(fileDate);
    for ff = 1:length(neuralDataTypes)
        neuralDataType = neuralDataTypes{1,ff};
        baseLine = RestingBaselines.Spectrograms.(neuralDataType).oneSecC.(strDay);
        S = SpecData.(neuralDataType).S;
        holdMatrix = baseLine.*ones(size(S));
        SpecData.(neuralDataType).normS = (S - holdMatrix)./holdMatrix;
    end
    save(specDataFileIDs(ee,:),'SpecData')
end

end
