function [Results_Example] = AnalyzePupilExample_Pupil(rootFolder,delim,Results_Example)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose:
%________________________________________________________________________________________________________________________

filePath = [rootFolder delim 'Data' delim 'T141' delim 'Bilateral Imaging'];
cd(filePath)
exampleProcDataFileID = 'T141_201105_12_05_20_ProcData.mat';
load(exampleProcDataFileID,'-mat')
exampleSpecDataFileID = 'T141_201105_12_05_20_SpecDataA.mat';
load(exampleSpecDataFileID,'-mat')
trainingDataFileID = 'T141_201105_12_05_20_TrainingData.mat';
load(trainingDataFileID,'-mat')
modelDataFileID = 'T141_201105_12_05_20_ModelData.mat';
load(modelDataFileID,'-mat')
exampleBaselineFileID = 'T141_RestingBaselines.mat';
load(exampleBaselineFileID,'-mat')
examplePupilData = 'T141_PupilData.mat';
load(examplePupilData)
[~,fileDate,fileID] = GetFileInfo_IOS(exampleProcDataFileID);
pupilCamFileID = [fileID '_PupilCam.bin'];
strDay = ConvertDate_IOS(fileDate);
Results_Example.dsFs = ProcData.notes.dsFs;
% setup butterworth filter coefficients for a 1 Hz and 10 Hz lowpass based on the sampling rate
[z1,p1,k1] = butter(4,10/(ProcData.notes.dsFs/2),'low');
[sos1,g1] = zp2sos(z1,p1,k1);
[z2,p2,k2] = butter(4,1/(ProcData.notes.dsFs/2),'low');
[sos2,g2] = zp2sos(z2,p2,k2);
% pupil area
Results_Example.filtPupilDiameter= filtfilt(sos2,g2,ProcData.data.Pupil.mmDiameter);
Results_Example.filtPupilZDiameter= filtfilt(sos2,g2,ProcData.data.Pupil.zDiameter);
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
% pupil tracking
[data] = FuncRunPupilTracker(exampleProcDataFileID);
% create pupil model data set for the example file
avgPupilArea_column = zeros(180,1);
% extract relevant parameters from each epoch
for b = 1:length(avgPupilArea_column)
    % number of binarized whisking events
    % average pupil area
    avgPupilArea_column(b,1) = round(mean(ProcData.sleep.parameters.Pupil.zDiameter{b,1},'omitnan'),2);
end
variableNames = {'zDiameter'};
pupilParamsTable = table(avgPupilArea_column,'VariableNames',variableNames);
% save results
Results_Example.physioTable = paramsTable;
Results_Example.pupilTable = pupilParamsTable;
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
cd([rootFolder delim])
save('Results_Example.mat','Results_Example','-v7.3')
end
