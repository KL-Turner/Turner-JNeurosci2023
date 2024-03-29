function [Results_Example] = AnalyzePupilExample_JNeurosci2023(rootFolder,delim,Results_Example)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Process example file for representative animal - pupil tracking, figure, movie, etc.
%________________________________________________________________________________________________________________________

filePath = [rootFolder delim 'Data' delim 'T141' delim 'Bilateral Imaging'];
cd(filePath)
exampleBaselineFileID = 'T141_RestingBaselines.mat';
load(exampleBaselineFileID,'-mat')
cd([rootFolder delim])
% go to manual scores for this file
filePath = [rootFolder delim 'Data' delim 'T141' delim 'Example Day'];
cd(filePath)
% character list of ProcData file IDs
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
% prepare pupil training data by updating parameters
AddPupilSleepParameters_JNeurosci2023(procDataFileIDs,RestingBaselines)
CreatePupilModelDataSet_JNeurosci2023(procDataFileIDs)
UpdatePupilTrainingDataSet_JNeurosci2023(procDataFileIDs)
% prepare physio training data by updating parameters
AddSleepParameters_JNeurosci2023(procDataFileIDs,RestingBaselines,'manualSelection')
CreateModelDataSet_JNeurosci2023(procDataFileIDs)
UpdateTrainingDataSets_JNeurosci2023(procDataFileIDs)
% character list of training file IDs
pupilTrainingFileStruct = dir('*_PupilTrainingData.mat');
pupilTrainingFiles = {pupilTrainingFileStruct.name}';
pupilTrainingFileIDs = char(pupilTrainingFiles);
% character list of ProcData file IDs
physioTrainingFileStruct = dir('*_TrainingData.mat');
physioTrainingFiles = {physioTrainingFileStruct.name}';
physioTrainingFileIDs = char(physioTrainingFiles);
for aa = 1:size(procDataFileIDs)
    pupilTrainingFileID = pupilTrainingFileIDs(aa,:);
    load(pupilTrainingFileID,'-mat')
    Results_Example.allPupilTables{aa,1} = pupilTrainingTable;
    physioTrainingFileID = physioTrainingFileIDs(aa,:);
    load(physioTrainingFileID,'-mat')
    Results_Example.allPhysioTables{aa,1} = trainingTable;
    Results_Example.allCombinedTables{aa,1} = horzcat(trainingTable(:,1:end - 1),pupilTrainingTable);
end
% start with file 2 to focus on the differences between each file
trialDuration = 15; % min
binTime = 5; % sec
for gg = 2:size(procDataFileIDs,1)
    leadFileID = procDataFileIDs(gg - 1,:);
    lagFileID = procDataFileIDs(gg,:);
    [~,~,leadFileInfo] = GetFileInfo_JNeurosci2023(leadFileID);
    [~,~,lagFileInfo] = GetFileInfo_JNeurosci2023(lagFileID);
    leadFileStr = ConvertDateTime_JNeurosci2023(leadFileInfo);
    lagFileStr = ConvertDateTime_JNeurosci2023(lagFileInfo);
    leadFileTime = datevec(leadFileStr);
    lagFileTime = datevec(lagFileStr);
    timeDifference = etime(lagFileTime,leadFileTime) - (trialDuration*60); % seconds
    Results_Example.timePadBins{gg - 1,1} = cell(floor(timeDifference/binTime),1);
    Results_Example.timePadBins{gg - 1,1}(:) = {'Time Pad'};
end
exampleProcDataFileID = 'T141_201105_12_05_20_ProcData.mat';
load(exampleProcDataFileID,'-mat')
exampleSpecDataFileID = 'T141_201105_12_05_20_SpecDataA.mat';
load(exampleSpecDataFileID,'-mat')
trainingDataFileID = 'T141_201105_12_05_20_TrainingData.mat';
load(trainingDataFileID,'-mat')
trainingDataFileID = 'T141_201105_12_05_20_PupilTrainingData.mat';
load(trainingDataFileID,'-mat')
modelDataFileID = 'T141_201105_12_05_20_ModelData.mat';
load(modelDataFileID,'-mat')
%
filePath = [rootFolder delim 'Data' delim 'T141' delim 'Bilateral Imaging'];
cd(filePath)
examplePupilData = 'T141_PupilData.mat';
load(examplePupilData)
[~,fileDate,fileID] = GetFileInfo_JNeurosci2023(exampleProcDataFileID);
pupilCamFileID = [fileID '_PupilCam.bin'];
strDay = ConvertDate_JNeurosci2023(fileDate);
Results_Example.dsFs = ProcData.notes.dsFs;
% setup butterworth filter coefficients for a 1 Hz and 10 Hz lowpass based on the sampling rate
[z1,p1,k1] = butter(4,10/(ProcData.notes.dsFs/2),'low');
[sos1,g1] = zp2sos(z1,p1,k1);
[z2,p2,k2] = butter(4,1/(ProcData.notes.dsFs/2),'low');
[sos2,g2] = zp2sos(z2,p2,k2);
% pupil area
Results_Example.filtPupilDiameter= filtfilt(sos2,g2,ProcData.data.Pupil.mmDiameter);
Results_Example.filtPupilZDiameter= filtfilt(sos2,g2,ProcData.data.Pupil.zDiameter);
% eye motion
Results_Example.filtEyeMotion = filtfilt(sos1,g1,ProcData.data.Pupil.distanceTraveled);
% eye position
Results_Example.filtCentroidX = filtfilt(sos2,g2,ProcData.data.Pupil.patchCentroidX - RestingBaselines.manualSelection.Pupil.patchCentroidX.(strDay).mean)*ProcData.data.Pupil.mmPerPixel;
Results_Example.filtCentroidY = filtfilt(sos2,g2,ProcData.data.Pupil.patchCentroidY - RestingBaselines.manualSelection.Pupil.patchCentroidY.(strDay).mean)*ProcData.data.Pupil.mmPerPixel;
% blink times
Results_Example.blinkTimes = ProcData.data.Pupil.blinkTimes;
% whisker angle
Results_Example.filtWhiskerAngle = filtfilt(sos1,g1,ProcData.data.whiskerAngle);
% EMG
normEMG = ProcData.data.EMG.emg - RestingBaselines.manualSelection.EMG.emg.(strDay).mean;
Results_Example.filtEMG = filtfilt(sos1,g1,normEMG);
% HbT
Results_Example.filtLH_HbT = filtfilt(sos2,g2,ProcData.data.CBV_HbT.adjLH);
Results_Example.filtRH_HbT = filtfilt(sos2,g2,ProcData.data.CBV_HbT.adjRH);
% hippocampal spectrogram
Results_Example.hippocampusNormS = SpecData.hippocampus.normS.*100;
Results_Example.T = SpecData.hippocampus.T;
Results_Example.F = SpecData.hippocampus.F;
% images
fid = fopen(pupilCamFileID); % reads the binary file in to the work space
fseek(fid,0,'eof'); % find the end of the video frame
fileSize = ftell(fid); % calculate file size
fseek(fid,0,'bof'); % find the begining of video frames
imageHeight = ProcData.notes.pupilCamPixelHeight; % how many pixels tall is the frame
imageWidth = ProcData.notes.pupilCamPixelWidth; % how many pixels wide is the frame
pixelsPerFrame = imageWidth*imageHeight;
skippedPixels = pixelsPerFrame;
nFramesToRead = floor(fileSize/(pixelsPerFrame));
imageStack = zeros(imageHeight,imageWidth,nFramesToRead);
for dd = 1:length(imageStack)
    fseek(fid,(dd - 1)*skippedPixels,'bof');
    z = fread(fid,pixelsPerFrame,'*uint8','b');
    img = reshape(z(1:pixelsPerFrame),imageWidth,imageHeight);
    imageStack(:,:,dd) = flip(imrotate(img,-90),2);
end
fclose('all');
% save images of interest
Results_Example.images = cat(3,imageStack(:,:,1200),imageStack(:,:,4200),imageStack(:,:,7866),...
    imageStack(:,:,13200),imageStack(:,:,18510),imageStack(:,:,23458),imageStack(:,:,26332));
% combined model table
combinedJoinedTable = horzcat(trainingTable(:,1:end - 1),pupilTrainingTable);
% pupil tracking
[data] = FuncRunPupilTracker_JNeurosci2023(exampleProcDataFileID);
% save results
Results_Example.pupilTable = pupilTrainingTable;
Results_Example.physioTable = paramsTable;
Results_Example.combinedTable = combinedJoinedTable;
Results_Example.trueLabels = trainingTable.behavState;
Results_Example.workingImg = data.workingImg;
Results_Example.x12 = data.x12;
Results_Example.y12 = data.y12;
Results_Example.threshImg = data.threshImg;
Results_Example.pupilHistEdges = data.pupilHistEdges;
Results_Example.normFit = data.normFit;
Results_Example.intensityThresh = data.intensityThresh;
Results_Example.saveRadonImg = data.saveRadonImg;
Results_Example.overlay = data.overlay;
% save results
cd([rootFolder delim 'Analysis Structures\'])
save('Results_Example.mat','Results_Example','-v7.3')
cd([rootFolder delim])

end
