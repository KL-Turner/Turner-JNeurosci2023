function [ROIs] = CalculateROICorrelationMatrix_Turner2022(animalID,strDay,fileID,ROIs,imagingType,lensMag)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Analyze the cross-correlation between gamma-band power and each pixel to properly place a circular 1 mm ROI
%________________________________________________________________________________________________________________________

% pull file information and camera frames
fileID2 = strrep(fileID,'_',' ');
rawDataFileID = [animalID '_' fileID(1:end - 13) 'RawData.mat'];
procDataFileID = [animalID '_' fileID(1:end - 13) 'ProcData.mat'];
load(rawDataFileID)
load(procDataFileID)
[frames] = ReadDalsaBinary_Turner2022(animalID,fileID);
% open figure for ROI drawing
windowFig = figure;
imagesc(frames{1})
title([animalID ' ' fileID2])
xlabel('Image size (pixels)')
ylabel('Image size (pixels)')
colormap gray
colorbar
axis image
caxis([0,2^RawData.notes.CBVCamBitDepth])
set(gca,'Ticklength',[0,0])
% determine which ROIs to draw based on imaging type
if strcmp(imagingType,'bilateral') == true
    hem = {'LH','RH'};
elseif strcmp(imagingType,'single') == true
    hem = {'Barrels'};
end
% draw ROI for the mask over the entire windows
for a = 1:length(hem)
    isok = false;
    while isok == false
        disp(['Draw an ROI over the entire ' hem{1,a} ' window']); disp(' ')
        [~,rect] = imcrop;
        hold on;
        ROIoutline = rectangle('Position',rect,'EdgeColor','r');
        checkMask = input('Is the ROI okay? (y/n): ','s'); disp(' ')
        if strcmp(checkMask,'y') == true
            isok = true;
            ROIs.([hem{1,a} '_' strDay]).rect = rect;
        end
        delete(ROIoutline);
    end
end
close(windowFig)
% extract the pixel values from the window ROIs
% character list of all ProcData files
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
% character list of all WindowCam files
windowDataFileStruct = dir('*_WindowCam.bin');
windowDataFiles = {windowDataFileStruct.name}';
windowDataFileIDs = char(windowDataFiles);
for qq = 1:size(procDataFileIDs,1)
    disp(['Analyzing cross correlation matrix (' num2str(qq) '/' num2str(size(procDataFileIDs,1)) ')']); disp(' ')
    load(procDataFileIDs(qq,:));
    imageHeight = ProcData.notes.CBVCamPixelHeight;
    imageWidth = ProcData.notes.CBVCamPixelWidth;
    pixelsPerFrame = imageWidth*imageHeight;
    % open the file, get file size, back to the begining
    fid = fopen(windowDataFileIDs(qq,:));
    fseek(fid,0,'eof');
    fileSize = ftell(fid);
    fseek(fid,0,'bof');
    % identify the number of frames to read. Each frame has a previously defined width and height (as inputs), along with a grayscale "depth" of 2"
    nFramesToRead = floor(fileSize/(2*pixelsPerFrame));
    % preallocate memory
    frames = cell(1,nFramesToRead);
    for n = 1:nFramesToRead
        z = fread(fid,pixelsPerFrame,'*int16','b');
        img = reshape(z(1:pixelsPerFrame),imageWidth,imageHeight);
        frames{n} = rot90(img',2);
    end
    fclose('all');
    for b = 1:length(hem)
        imageMask = nan(size(frames{1}));
        rectMask = ROIs.([hem{1,b} '_' strDay]).rect;
        rectMask = round(rectMask);
        imageMask(rectMask(2):(rectMask(2) + rectMask(4)),rectMask(1):(rectMask(1) + rectMask(3))) = 1;
        for c = 1:length(frames) - 1
            frame = frames{1,c};
            frameHold = double(frame).*imageMask;
            imageStack.(hem{1,b})(:,c) = frameHold(~isnan(frameHold));
        end
    end
    % extract and process gamma band power
    [B,A] = butter(3,2/(ProcData.notes.dsFs/2),'low');
    LH_gammaBandPower = detrend(filtfilt(B,A,ProcData.data.cortical_LH.gammaBandPower - ProcData.data.cortical_LH.gammaBandPower(1)) + ProcData.data.cortical_LH.gammaBandPower(1),'constant');
    RH_gammaBandPower = detrend(filtfilt(B,A,ProcData.data.cortical_RH.gammaBandPower - ProcData.data.cortical_RH.gammaBandPower(1)) + ProcData.data.cortical_RH.gammaBandPower(1),'constant');
    Hip_gammaBandPower = detrend(filtfilt(B,A,ProcData.data.hippocampus.gammaBandPower - ProcData.data.hippocampus.gammaBandPower(1)) + ProcData.data.hippocampus.gammaBandPower(1),'constant');
    % cross correlation
    lagTime = 5;   % seconds
    maxLag = lagTime*RawData.notes.CBVCamSamplingRate;
    for d = 1:length(hem)
        hemisphere = hem{1,d};
        if strcmp(hemisphere,'LH') == true
            gammaBandArray = LH_gammaBandPower;
        elseif strcmp(hemisphere,'RH') == true
            gammaBandArray = RH_gammaBandPower;
        elseif strcmp(hemisphere,'Barrels') == true
            singleHem = ProcData.notes.hemisphere;
            if strcmp(singleHem,'LH') == true
                gammaBandArray = LH_gammaBandPower;
            elseif strcmp(singleHem,'RH') == true
                gammaBandArray = RH_gammaBandPower;
            elseif strcmp(singleHem,'Both') == true
                gammaBandArray = Hip_gammaBandPower;
            end
        end
        % extract pixel values from each numel index in matrix image
        for e = 1:size(imageStack.(hemisphere),1)
            pixelArray = imageStack.(hemisphere)(e,:);
            pixelArray = detrend(filtfilt(B,A,pixelArray - pixelArray(1)) + pixelArray(1),'constant');
            [xcorrVals,lags] = xcorr(pixelArray,gammaBandArray,maxLag,'coeff');
            zeroPoint = find(lags == 0);
            validVals = xcorrVals(zeroPoint:zeroPoint + 45);
            maxCorr = min(validVals);
            if isnan(maxCorr) == true
                corrMatrix.(hemisphere)(1,e,qq) = 0;
            else
                corrMatrix.(hemisphere)(1,e,qq) = maxCorr;
            end
        end
    end
end
% determine the proper size of the ROI based on camera/lens magnification
if strcmp(lensMag,'0.75X') == true
    circRadius = 7.5;   % pixels to be 1 mm in diameter
elseif strcmp(lensMag,'1.0X') == true
    circRadius = 10;
elseif strcmp(lensMag,'1.5X') == true
    circRadius = 15;
elseif strcmp(lensMag,'2.0X') == true
    circRadius = 20;
elseif strcmp(lensMag,'2.5X') == true
    circRadius = 25;
elseif strcmp(lensMag,'3.0X') == true
    circRadius = 30;
end
% place circle along the most correlation region of each hemisphere
for f = 1:length(hem)
    rectMask = ROIs.([hem{1,f} '_' strDay]).rect;
    rectMask = round(rectMask);
    imgWidth = rectMask(3) + 1;
    imgHeight = rectMask(4) + 1;
    corrImg = reshape(mean(corrMatrix.(hem{1,f}),3),imgHeight,imgWidth);
    % generate image
    isok = false;
    while isok == false
        windowFig = figure;
        imagesc(corrImg.*-1)
        title([animalID ' ' hem{1,f} ' peak pixel correlations'])
        xlabel('Image size (pixels)')
        ylabel('Image size (pixels)')
        colormap parula
        colorbar
        axis image
        disp(['Move the ROI over the most correlated region for the ' hem{1,f}]); disp(' ')
        circ = drawcircle('Center',[0,0],'Radius',circRadius,'Color','r');
        checkCircle = input('Is the ROI okay? (y/n): ','s'); disp(' ')
        circPosition = round(circ.Center);
        if strcmp(checkCircle,'y') == true
            isok = true;
            rectBottomLeftCorner = [rectMask(1),rectMask(2) + rectMask(4)];
            rectTopLeftCorner = [rectMask(1),rectMask(2)];
            circPositionEdit = [rectBottomLeftCorner(1) + circPosition(1),rectTopLeftCorner(2) + circPosition(2)];
            ROIs.([hem{1,f} '_' strDay]).circPosition = circPositionEdit;
            ROIs.([hem{1,f} '_' strDay]).circRadius = circRadius;
        end
        delete(windowFig);
    end
end
% check final image
fig = figure;
imagesc(frames{1})
hold on;
if strcmp(imagingType,'bilateral') == true
    drawcircle('Center',ROIs.(['LH_' strDay]).circPosition,'Radius',ROIs.(['LH_' strDay]).circRadius,'Color','r');
    drawcircle('Center',ROIs.(['RH_' strDay]).circPosition,'Radius',ROIs.(['RH_' strDay]).circRadius,'Color','r');
elseif strcmp(imagingType,'single')
    drawcircle('Center',ROIs.(['Barrels_' strDay]).circPosition,'Radius',ROIs.(['Barrels_' strDay]).circRadius,'Color','r');
end
title([animalID ' final ROI placement'])
xlabel('Image size (pixels)')
ylabel('Image size (pixels)')
colormap gray
colorbar
axis image
caxis([0 2^RawData.notes.CBVCamBitDepth])
savefig(fig,[animalID '_' strDay '_ROIs.fig'])

end
