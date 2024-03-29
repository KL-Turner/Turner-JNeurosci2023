function [Results_Example2] = AnalyzePupilExample2_JNeurosci2023(rootFolder,delim,Results_Example2)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Process example file for representative animal - pupil tracking, figure, movie, etc.
%________________________________________________________________________________________________________________________

filePath = [rootFolder delim 'Data' delim 'T123' delim 'Bilateral Imaging'];
cd(filePath)
exampleProcDataFileID = 'T123_200304_14_32_00_ProcData.mat';
load(exampleProcDataFileID,'-mat')
exampleSpecDataFileID = 'T123_200304_14_32_00_SpecDataA.mat';
load(exampleSpecDataFileID,'-mat')
trainingDataFileID = 'T123_200304_14_32_00_TrainingData.mat';
load(trainingDataFileID,'-mat')
modelDataFileID = 'T123_200304_14_32_00_ModelData.mat';
load(modelDataFileID,'-mat')
exampleBaselineFileID = 'T123_RestingBaselines.mat';
load(exampleBaselineFileID,'-mat')
examplePupilData = 'T123_PupilData.mat';
load(examplePupilData)
[~,fileDate,fileID] = GetFileInfo_JNeurosci2023(exampleProcDataFileID);
pupilCamFileID = [fileID '_PupilCam.bin'];
strDay = ConvertDate_JNeurosci2023(fileDate);
Results_Example2.dsFs = ProcData.notes.dsFs;
% setup butterworth filter coefficients for a 1 Hz and 10 Hz lowpass based on the sampling rate
[z1,p1,k1] = butter(4,10/(ProcData.notes.dsFs/2),'low');
[sos1,g1] = zp2sos(z1,p1,k1);
[z2,p2,k2] = butter(4,1/(ProcData.notes.dsFs/2),'low');
[sos2,g2] = zp2sos(z2,p2,k2);
% pupil area
Results_Example2.filtPupilDiameter= filtfilt(sos2,g2,ProcData.data.Pupil.mmDiameter);
Results_Example2.filtPupilZDiameter= filtfilt(sos2,g2,ProcData.data.Pupil.zDiameter);
% blink times
Results_Example2.blinkTimes = ProcData.data.Pupil.blinkTimes;
% whisker angle
Results_Example2.filtWhiskerAngle = filtfilt(sos1,g1,ProcData.data.whiskerAngle);
% EMG
normEMG = ProcData.data.EMG.emg - RestingBaselines.manualSelection.EMG.emg.(strDay).mean;
Results_Example2.filtEMG = filtfilt(sos1,g1,normEMG);
% HbT
Results_Example2.filtLH_HbT = filtfilt(sos2,g2,ProcData.data.CBV_HbT.adjLH);
Results_Example2.filtRH_HbT = filtfilt(sos2,g2,ProcData.data.CBV_HbT.adjRH);
% hippocampal spectrogram
Results_Example2.hippocampusNormS = SpecData.hippocampus.normS.*100;
Results_Example2.T = SpecData.hippocampus.T;
Results_Example2.F = SpecData.hippocampus.F;
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
Results_Example2.images = cat(3,imageStack(:,:,1200),imageStack(:,:,4200),imageStack(:,:,7866),...
    imageStack(:,:,13200),imageStack(:,:,18510),imageStack(:,:,23458),imageStack(:,:,26332));
% pupil tracking
[data] = FuncRunPupilTracker_JNeurosci2023(exampleProcDataFileID);
% create pupil model data set for the example file
avgPupilDiameter_column = zeros(180,1);
% extract relevant parameters from each epoch
for b = 1:length(avgPupilDiameter_column)
    % average pupil area
    avgPupilDiameter_column(b,1) = round(mean(ProcData.sleep.parameters.Pupil.zDiameter{b,1},'omitnan'),2);
end
variableNames = {'zDiameter'};
pupilParamsTable = table(avgPupilDiameter_column,'VariableNames',variableNames);
% save results
Results_Example2.physioTable = paramsTable;
Results_Example2.pupilTable = pupilParamsTable;
Results_Example2.trueLabels = trainingTable.behavState;
Results_Example2.workingImg = data.workingImg;
Results_Example2.x12 = data.x12;
Results_Example2.y12 = data.y12;
Results_Example2.threshImg = data.threshImg;
Results_Example2.pupilHistEdges = data.pupilHistEdges;
Results_Example2.normFit = data.normFit;
Results_Example2.intensityThresh = data.intensityThresh;
Results_Example2.saveRadonImg = data.saveRadonImg;
Results_Example2.overlay = data.overlay;
cd([rootFolder delim])
% go to manual scores for this file
filePath = [rootFolder delim 'Data' delim 'T141' delim 'Example Day'];
cd(filePath)
% character list of ProcData file IDs
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
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
    Results_Example2.allPupilTables{aa,1} = pupilTrainingTable;
    physioTrainingFileID = physioTrainingFileIDs(aa,:);
    load(physioTrainingFileID,'-mat')
    Results_Example2.allPhysioTables{aa,1} = trainingTable;
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
    Results_Example2.timePadBins{gg - 1,1} = cell(floor(timeDifference/binTime),1);
    Results_Example2.timePadBins{gg - 1,1}(:) = {'Time Pad'};
end
% save results
cd([rootFolder delim])
save('Results_Example2.mat','Results_Example2','-v7.3')

end
