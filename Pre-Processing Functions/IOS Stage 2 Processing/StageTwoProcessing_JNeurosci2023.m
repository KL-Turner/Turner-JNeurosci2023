%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: 1) Create ProcData structure using threshholds for the observed data
%            2) Extract the average pixel reflectance changes within those ROIs and save to RawData/ProcData files
%            3) Use spectral analysis of the reflectance data to pull out the animal's heart rate
%            4) Remove pixel-drift trends from each file, if necessary
%________________________________________________________________________________________________________________________

% load the script's necessary variables and data structures.
% clear the workspace variables and command window.
zap;
% character list of all RawData files
rawDataFileStruct = dir('*_RawData.mat');
rawDataFiles = {rawDataFileStruct.name}';
rawDataFileIDs = char(rawDataFiles);
[animalID,~,~] = GetFileInfo_JNeurosci2023(rawDataFileIDs(1,:));
% identify whether this analysis is for bilateral or single hemisphere imaging1
curDir = cd;
dirBreaks = strfind(curDir,'\');
curFolder = curDir(dirBreaks(end) + 1:end);
imagingType = input('Input imaging type (bilateral, single, GCaMP): ','s'); disp(' ')
correctPixelDrift = false;
lensMag = '1.5X'; % typically 1.5X bilateral, 2.0X single hemisphere
% process the RawData structure -> Create Threshold data structure and ProcData structure.
ProcessRawDataFiles_JNeurosci2023(rawDataFileIDs)
% process IOS pixel data from each ROI.
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
ProcessIntrinsicData_JNeurosci2023(animalID,imagingType,lensMag,rawDataFileIDs,procDataFileIDs)
% add Heart Rate to the ProcData structures.
ExtractHeartRate_JNeurosci2023(procDataFileIDs,imagingType)
% check/Correct IOS pixel drift.
if correctPixelDrift == true
    if strcmp(imagingType,'bilateral') == true
        CorrectBilateralPixelDrift_JNeurosci2023(procDataFileIDs)
    elseif strcmp(imagingType,'single') == true
        CorrectPixelDrift_JNeurosci2023(procDataFileIDs)
    elseif strcmpi(imagingType,'GCaMP')  == true
        CorrectBilateralPixelDrift_CBV_JNeurosci2023(procDataFileIDs)
        CorrectBilateralPixelDrift_GCaMP_JNeurosci2023(procDataFileIDs)
        CorrectBilateralPixelDrift_Deoxy_JNeurosci2023(procDataFileIDs)
    end
end
