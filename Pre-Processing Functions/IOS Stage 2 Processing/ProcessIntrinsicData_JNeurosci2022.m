function [] = ProcessIntrinsicData_JNeurosci2022(animalID,imagingType,lensMag,rawDataFileIDs,procDataFileIDs)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%________________________________________________________________________________________________________________________
%
%   Purpose: Base function to run the functions necessary for IOS data extraction from drawn ROIs over the images
%________________________________________________________________________________________________________________________

if strcmp(imagingType,'bilateral') == true
    ROInames = {'LH','RH','Cement'};
elseif strcmp(imagingType,'single') == true
    ROInames = {'Barrels','Cement'};
elseif strcmp(imagingType,'gcamp') == true
    ROInames = {'LH','RH','Cement'};
end
% create/load pre-existing ROI file with the coordinates
ROIFileDir = dir('*_ROIs.mat');
if isempty(ROIFileDir) == true
    ROIs = [];
else
    ROIFileName = {ROIFileDir.name}';
    ROIFileID = char(ROIFileName);
    load(ROIFileID);
end
% check whether or not each ROI already exists
[ROIs] = CheckROIDates_JNeurosci2022(animalID,ROIs,ROInames,imagingType,lensMag);
% Extract CBV data from each ROI for each RawData file in the directory that hasn't been processed yet.
if strcmp(imagingType,'true') == false
    ExtractGCaMPData_JNeurosci2022(ROIs,ROInames,rawDataFileIDs,procDataFileIDs)
else
    ExtractCBVData_JNeurosci2022(ROIs,ROInames,rawDataFileIDs)
end
% Go through each ProcData file and add the pixel data to each
for a = 1:size(procDataFileIDs,1)
    disp(['Adding IOS CBV data to ProcData file (' num2str(a) '/' num2str(size(procDataFileIDs,1)) ')']); disp(' ')
    procDataFileID = procDataFileIDs(a,:);
    load(procDataFileID)
    rawDataFileID = rawDataFileIDs(a,:);
    load(rawDataFileID)
    [~,fileDate,~] = GetFileInfo_JNeurosci2022(rawDataFileID);
    strDay = ConvertDate_JNeurosci2022(fileDate);
    for b = 1:length(ROInames)
        if strcmp(imagingType,'gcamp') == true
            ProcData.data.CBV.(ROInames{1,b}) = RawData.data.CBV.([ROInames{1,b} '_' strDay]);
            ProcData.data.GCaMP7s.(ROInames{1,b}) = RawData.data.GCaMP7s.([ROInames{1,b} '_' strDay]);
            ProcData.data.Deoxy.(ROInames{1,b}) = RawData.data.Deoxy.([ROInames{1,b} '_' strDay]);
            ProcData.notes.CBVCamSamplingRate = RawData.notes.CBVCamSamplingRate/3;
        else
            ProcData.data.CBV.(ROInames{1,b}) = RawData.data.CBV.([ROInames{1,b} '_' strDay])(1:end - 1);
        end
        CheckForNaNs_JNeurosci2022(ProcData,imagingType);
        save(procDataFileID,'ProcData')
    end
end

end

