function [Results_PupilREM] = AnalyzeEyesOpenEyesClosedREM_JNeurosci2022(animalID,rootFolder,delim,Results_PupilREM)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Analyze the eyes-open vs. eyes-closed relationship during REM sleep
%________________________________________________________________________________________________________________________

% go to animal's data location
dataLocation = [rootFolder delim 'Data' delim animalID delim 'Bilateral Imaging'];
cd(dataLocation)
% find and load SleepData.mat strut
sleepDataFileStruct = dir('*_SleepData.mat');
sleepDataFile = {sleepDataFileStruct.name}';
sleepDataFileID = char(sleepDataFile);
load(sleepDataFileID,'-mat')
% ROI file
ROIFileDir = dir('*_PupilData.mat');
ROIFileName = {ROIFileDir.name}';
ROIFileID = char(ROIFileName);
load(ROIFileID);
% REM event information
fileIDs = SleepData.Forest.REM.FileIDs;
binTimes = SleepData.Forest.REM.BinTimes;
if isfield(SleepData.Forest.REM,'eyeState') == false
    for aa = 1:length(fileIDs)
        fileID = fileIDs{aa,1};
        binTime = binTimes{aa,1};
        startSec = binTime(1);
        stopSec = binTime(end);
        middleSec = (binTime(1) + binTime(end))/2;
        procDataFileID = [animalID '_' fileID '_ProcData.mat'];
        load(procDataFileID)
        % load files and extract video information
        [animalID,fileDate,fileID] = GetFileInfo_JNeurosci2022(procDataFileID);
        pupilCamFileID = [fileID '_PupilCam.bin'];
        idx = 0;
        for qq = 1:size(PupilData.firstFileOfDay,2)
            if strfind(PupilData.firstFileOfDay{1,qq},fileDate) >= 5
                idx = qq;
            end
        end
        fid = fopen(pupilCamFileID); % reads the binary file in to the work space
        fseek(fid,0,'eof'); % find the end of the video frame
        fseek(fid,0,'bof'); % find the begining of video frames
        imageHeight = ProcData.notes.pupilCamPixelHeight;
        imageWidth = ProcData.notes.pupilCamPixelWidth;
        pixelsPerFrame = imageWidth*imageHeight;
        skippedPixels = pixelsPerFrame;
        imageStack = zeros(200,200,3);
        % first frame of REM event
        fseek(fid,(startSec*30 - 1)*skippedPixels,'bof');
        z = fread(fid,pixelsPerFrame,'*uint8','b');
        img = reshape(z(1:pixelsPerFrame),imageWidth,imageHeight);
        if isfield(PupilData,'resizePosition') == true
            imageStack(:,:,1) = imcrop(flip(imrotate(img,-90),2),PupilData.resizePosition{1,idx});
        else
            imageStack(:,:,1) = flip(imrotate(img,-90),2);
        end
        % middle frame of REM event
        fseek(fid,(middleSec*30 - 1)*skippedPixels,'bof');
        z = fread(fid,pixelsPerFrame,'*uint8','b');
        img = reshape(z(1:pixelsPerFrame),imageWidth,imageHeight);
        if isfield(PupilData,'resizePosition') == true
            imageStack(:,:,2) = imcrop(flip(imrotate(img,-90),2),PupilData.resizePosition{1,idx});
        else
            imageStack(:,:,2) = flip(imrotate(img,-90),2);
        end
        % end frame of REM event
        try
            fseek(fid,(stopSec*30 - 1)*skippedPixels,'bof');
            z = fread(fid,pixelsPerFrame,'*uint8','b');
            img = reshape(z(1:pixelsPerFrame),imageWidth,imageHeight);
        catch
            fseek(fid,(length(ProcData.data.Pupil.roiIntensity) - 1)*skippedPixels,'bof');
            z = fread(fid,pixelsPerFrame,'*uint8','b');
            img = reshape(z(1:pixelsPerFrame),imageWidth,imageHeight);
        end
        if isfield(PupilData,'resizePosition') == true
            imageStack(:,:,3) = imcrop(flip(imrotate(img,-90),2),PupilData.resizePosition{1,idx});
        else
            imageStack(:,:,3) = flip(imrotate(img,-90),2);
        end
        % figure showing 3 frames
        imageCheck = figure;
        sgtitle([animalID strrep(fileID,'_',' ')])
        for ff = 1:size(imageStack,3)
            subplot(1,3,ff)
            imagesc(imageStack(:,:,ff))
            colormap gray
            axis image
            axis off
        end
        drawnow()
        % request user input for this file
        check = false;
        while check == false
            decision = input('Is eye data open, closed, or obscured with mucus for this REM event? (o/c/m): ','s'); disp(' ')
            if strcmp(decision,'o') == true || strcmp(decision,'c') == true || strcmp(decision,'m') == true
                SleepData.Forest.REM.eyeState{aa,1} = decision;
                close(imageCheck)
                check = true;
            end
        end
    end
    % save data
    save(sleepDataFileID,'SleepData')
    cd(rootFolder)
end
% pull out eyes open vs. eyes closed REM sleep data
LH_HbT_open = []; LH_HbT_closed = [];
RH_HbT_open = []; RH_HbT_closed = [];
LH_gamma_open = []; LH_gamma_closed = [];
RH_gamma_open = []; RH_gamma_closed = [];
hip_theta_open = []; hip_theta_closed = [];
cc = 1; dd = 1;
for bb = 1:length(SleepData.Forest.REM.eyeState)
    if strcmp(SleepData.Forest.REM.eyeState{bb,1},'o') == true
        LH_HbT_open(cc,1) = mean(SleepData.Forest.REM.data.CBV_HbT.LH{bb,1}); 
        RH_HbT_open(cc,1) = mean(SleepData.Forest.REM.data.CBV_HbT.RH{bb,1}); 
        LH_gamma_open(cc,1) = mean(SleepData.Forest.REM.data.cortical_LH.gammaBandPower{bb,1}); 
        RH_gamma_open(cc,1) = mean(SleepData.Forest.REM.data.cortical_RH.gammaBandPower{bb,1}); 
        hip_theta_open(cc,1) = mean(SleepData.Forest.REM.data.hippocampus.thetaBandPower{bb,1}); 
        cc = cc + 1;
    elseif strcmp(SleepData.Forest.REM.eyeState{bb,1},'c') == true
        LH_HbT_closed(dd,1) = mean(SleepData.Forest.REM.data.CBV_HbT.LH{bb,1}); 
        RH_HbT_closed(dd,1) = mean(SleepData.Forest.REM.data.CBV_HbT.RH{bb,1}); 
        LH_gamma_closed(dd,1) = mean(SleepData.Forest.REM.data.cortical_LH.gammaBandPower{bb,1}); 
        RH_gamma_closed(dd,1) = mean(SleepData.Forest.REM.data.cortical_RH.gammaBandPower{bb,1}); 
        hip_theta_closed(dd,1) = mean(SleepData.Forest.REM.data.hippocampus.thetaBandPower{bb,1}); 
        dd = dd + 1;
    end
end
% save results
Results_PupilREM.(animalID).LH_HbT_open = mean(LH_HbT_open);
Results_PupilREM.(animalID).RH_HbT_open = mean(RH_HbT_open);
Results_PupilREM.(animalID).LH_gamma_open = mean(LH_gamma_open);
Results_PupilREM.(animalID).RH_gamma_open = mean(RH_gamma_open);
Results_PupilREM.(animalID).hip_theta_open = mean(hip_theta_open);
Results_PupilREM.(animalID).LH_HbT_closed = mean(LH_HbT_closed);
Results_PupilREM.(animalID).RH_HbT_closed = mean(RH_HbT_closed);
Results_PupilREM.(animalID).LH_gamma_closed = mean(LH_gamma_closed);
Results_PupilREM.(animalID).RH_gamma_closed = mean(RH_gamma_closed);
Results_PupilREM.(animalID).hip_theta_closed = mean(hip_theta_closed);
% save data
cd([rootFolder delim 'Analysis Structures\'])
save('Results_PupilREM.mat','Results_PupilREM')
cd([rootFolder delim])

end
