function [ROIs] = CheckROIDates_JNeurosci2022(animalID,ROIs,ROInames,imagingType,lensMag)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Create/Update ROIs.mat structure to verify all ROIs are drawn
%________________________________________________________________________________________________________________________

% character list of all WindowCam files
windowCamFilesDir = dir('*_WindowCam.bin');
windowCamDataFiles = {windowCamFilesDir.name}';
windowCamDataFileIDs = char(windowCamDataFiles);
% establish the number of unique days based on file IDs
[~,fileDates,~] = GetFileInfo_JNeurosci2022(windowCamDataFileIDs);
[uniqueDays,~,DayID] = GetUniqueDays_JNeurosci2022(fileDates);
firstsFileOfDay = cell(1,length(uniqueDays));
for a = 1:length(uniqueDays)
    FileInd = DayID == a;
    dayFilenames = windowCamDataFileIDs(FileInd,:);
    firstsFileOfDay(a) = {dayFilenames(1,:)};
end
% load existing ROI structure if it exists
ROIFileDir = dir('*_ROIs.mat');
ROIFileName = {ROIFileDir.name}';
ROIFileID = char(ROIFileName);
if exist(ROIFileID,'file')
    load(ROIFileID);
else
    ROIs = [];
end
% create the desired window ROI for each day if it doesn't yet exist
for b = 1:length(firstsFileOfDay)
    fileID = firstsFileOfDay{1,b};
    strDay = ConvertDate_JNeurosci2022(fileID);
    for c = 1:length(ROInames)
        ROIname = [ROInames{1,c} '_' strDay];
        if ~isfield(ROIs,(ROIname))
            if any(strcmp(ROInames{1,c},{'LH','RH','frontalLH','frontalRH','Barrels'})) == true
                if strcmpi(imagingType,'GCaMP') == true
                    [ROIs] = PlaceGCaMP_ROIs_JNeurosci2022(animalID,fileID,ROIs,lensMag);
                else
                    [ROIs] = CalculateROICorrelationMatrix_JNeurosci2022(animalID,strDay,fileID,ROIs,imagingType,lensMag);
                end
            else
                [frames] = ReadDalsaBinary_JNeurosci2022(animalID,fileID);
                [ROIs] = CreateFreeHandROIs_JNeurosci2022(frames{3},ROIname,animalID,ROIs);
            end
            save([animalID '_ROIs.mat'],'ROIs');
        end
    end
end

end
