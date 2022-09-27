%________________________________________________________________________________________________________________________
% Written by Kyle W. Gheres & Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Track changes in pupil area and detect periods of blinking
%________________________________________________________________________________________________________________________

clear; clc;
multiWaitbar('CloseAll');
% select file to process
pupilCamFileID = uigetfile('*_PupilCam.bin','Select a file for pupil tracking','MultiSelect','off');
underScoreIdx = strfind(pupilCamFileID,'_');
procDataFileID = [pupilCamFileID(1:underScoreIdx(end)) 'ProcData.mat'];
load(procDataFileID,'-mat')
fid = fopen(pupilCamFileID); % reads the binary file in to the work space
fseek(fid,0,'eof'); % find the end of the video frame
imageHeight = ProcData.notes.pupilCamPixelHeight; %#ok<*NODEF>
imageWidth = ProcData.notes.pupilCamPixelWidth;
pixelsPerFrame = imageWidth*imageHeight;
skippedPixels = pixelsPerFrame;
roiImage = zeros(imageHeight,imageWidth,1);
fseek(fid,1*skippedPixels,'bof'); % read .bin File to roiImage
z = fread(fid,pixelsPerFrame,'*uint8','b');
img = reshape(z(1:pixelsPerFrame),imageWidth,imageHeight);
roiImage(:,:,1) = flip(imrotate(img,-90),2);
roiImage = uint8(roiImage); % convert double floating point data to unsignned 8bit integers
data.workingImg = imcomplement(roiImage); % grab frame from image stack
disp('Draw ROI around eye'); disp(' ')
eyeFigure = figure;
title('Draw ROI around eye')
[eyeROI,data.x12,data.y12] = roipoly(data.workingImg);
close(eyeFigure)
% model the distribution of pixel intensities as a gaussian to estimate/isolate the population of pupil pixels
threshSet = 2; % StD beyond mean intensity to binarize image for pupil tracking
medFiltParams = [5,5]; % [x,y] dimensions for 2d median filter of images
pupilHistEdges = 1:1:256; % camera data is unsigned 8bit integers. Ignore 0 values
filtImg = medfilt2(data.workingImg,medFiltParams); % median filter image
threshImg = double(filtImg).*eyeROI; % only look at pixel values in ROI
[phat,~] = mle(reshape(threshImg(threshImg ~= 0),1,numel(threshImg(threshImg ~= 0))),'distribution','Normal');
intensityThresh = phat(1) + (threshSet*phat(2)); % set threshold as 4.5 sigma above population mean estimated from MLE
testFig = figure;
data.pupilHist = histogram(threshImg((threshImg ~= 0)),'BinEdges',pupilHistEdges,'Normalization','Probability');
data.theFit = pdf('normal',data.pupilHist.BinEdges,phat(1),phat(2)); % generate distribution from mle fit of data
data.normFit = data.theFit./sum(data.theFit); % normalize fit so sum of gaussian ==1
data.pupilHistEdges = pupilHistEdges;
data.threshImg = threshImg;
hold on;
plot(data.pupilHist.BinEdges,data.normFit,'r','LineWidth',2);
xline(intensityThresh,'--m','LineWidth',1);
title('Histogram of image pixel intensities')
xlabel('Pixel intensities');
ylabel('Bin Counts');
legend({'Normalized Bin Counts','MLE fit of data','Starting 2 StD ROI threshold'},'Location','northwest');
xlim([0,256]);
axis square
drawnow
% figure for verifying pupil threshold
testImg = threshImg;
testImg(threshImg >= intensityThresh) = 1;
testImg(threshImg < intensityThresh) = 0;
testThresh = labeloverlay(roiImage(:,:,1),testImg);
threshFig = figure;
imagesc(testThresh);
colormap gray
axis off
axis square
drawnow
% check threshold
threshOK = false;
while threshOK == false
    disp(['Intensity threshold: ' num2str(intensityThresh)]); disp (' ')
    threshCheck = input('Is pupil threshold value ok? (y/n): ','s'); disp(' ')
    if strcmp(threshCheck,'y') == true
        threshOK = true;
    else
        intensityThresh = input('Manually set pupil intensity threshold: '); disp(' ')
        testImg(threshImg >= intensityThresh) = 1;
        testImg(threshImg < intensityThresh) = 0;
        testThresh = labeloverlay(roiImage(:,:,1),testImg);
        imagesc(testThresh);
        colormap gray
        axis image
        axis off
        title('Pixels above threshold');
        drawnow
    end
end
data.intensityThresh = intensityThresh;
close(testFig)
close(threshFig)
% run pupil/blink tracking on all data files
theAngles = 1:1:180; % projection angles measured during radon transform of pupil
radonThresh = 0.05; % arbitrary threshold used to clean up radon transform above values == 1 below == 0
pupilThresh = 0.25; % arbitrary threshold used to clean up inverse radon transform above values == 1 below == 0
blinkThresh = 0.35; % arbitrary threshold used to binarize data for blink detection above values == 1 below == 0
medFiltParams = [5,5]; % [x,y] dimensions for 2d median filter of images
fid = fopen(pupilCamFileID); % reads the binary file in to the work space
fseek(fid,0,'eof'); % find the end of the video frame
fileSize = ftell(fid); % calculate file size
fseek(fid,0,'bof'); % find the begining of video frames
imageHeight = ProcData.notes.pupilCamPixelHeight; % how many pixels tall is the frame
imageWidth = ProcData.notes.pupilCamPixelWidth; % how many pixels wide is the frame
samplingRate = ProcData.notes.pupilCamSamplingRate; % pupil acquisition rate (Hz)
pixelsPerFrame = imageWidth*imageHeight;
skippedPixels = pixelsPerFrame;
nFramesToRead = floor(fileSize/(pixelsPerFrame));
imageStack = zeros(200,200,nFramesToRead); % empty variable for entire pupil tracking video
disp(['Reading ' num2str(nFramesToRead) ' camera frames ...']); disp(' ')
% read .bin file to imageStack
for dd = 1:nFramesToRead
    fseek(fid,(dd - 1)*skippedPixels,'bof');
    z = fread(fid,pixelsPerFrame,'*uint8','b'); % read in next movie frame
    img = reshape(z(1:pixelsPerFrame),imageWidth,imageHeight); % reshape to correct image dimension
    imageStack(:,:,dd) = flip(imrotate(img,-90),2);
end
% convert double floating point data to unsignned 8bit integers
imageStack = uint8(imageStack); % change to 8-bit to conserve memory
% grab frame from image stack
workingImg = imcomplement(imageStack(:,:,2)); % invert image pixel intensities so pupil becomes "bright" and sclera "dark"
data.firstFrame = imageStack(:,:,2);
%% track pupil frame-by-frame
% pre-allocate empty structures
pupilArea(1:size(imageStack,3)) = NaN; % area of pupil
pupilMajor(1:size(imageStack,3)) = NaN; % length of major axis of pupil
pupilMinor(1:size(imageStack,3)) = NaN; % length of minor axis of pupil
pupilCentroid(1:size(imageStack,3),2) = NaN; % center of pupil
pupilBoundary(1:size(imageStack,1),1:size(imageStack,2),1:size(imageStack,3)) = NaN;
procStart = tic;
disp(['Running pupil tracker for: ' pupilCamFileID]); disp(' ')
imageFrames = gpuArray(imageStack);
roiInt(1:size(imageFrames,3)) = NaN;
roiInt = gpuArray(roiInt);
correctedFlag = false;
lastFrameOK = 1;
waitBarLength = size(imageStack,3);
multiWaitbar('Tracking Pupil ...',0,'Color','R'); pause(0.25);
for frameNum = 1:size(imageStack,3)
    filtImg = medfilt2(imcomplement(imageFrames(:,:,frameNum)),medFiltParams); % invert and median filter raw movie frame
    % only look at pixel values in ROI
    threshImg = uint8(double(filtImg).*eyeROI); % apply mask to remove pixel data outside of eye
    roiIntTemp = sum(threshImg,1);
    roiInt(frameNum) = sum(roiIntTemp,2); % sum pixel intensities inside eye used for blink detection
    isoPupil = threshImg;
    isoPupil(isoPupil < intensityThresh) = 0; % set pixel values below threshold to 0
    isoPupil(isoPupil >= intensityThresh) = 1; % set pixel values above threshold to 1
    radPupil = radon(isoPupil); % transform image to radon space
    minPupil = min(radPupil,[],1);
    minMat = repmat(minPupil,size(radPupil,1),1);
    maxMat = repmat(max((radPupil - minMat),[],1),size(radPupil,1),1);
    % normalize each projection angle to its min and max values. Each value should now be between [0 1]
    normPupil = (radPupil - minMat)./maxMat; % normalize radon transform to account for inter-trial luminance changes
    threshPupil = normPupil;
    % binarize radon projection
    threshPupil(normPupil >= radonThresh) = 1; % threshold in normalized radon space
    threshPupil(normPupil < radonThresh) = 0;
    % transform back to image space
    radonPupil = gather(iradon(double(threshPupil),theAngles,'linear','Hamming',size(workingImg,2))); % transform back to image space.
    % find area corresponding to pupil on binary image
    [~,pupilBoundaries,objNum,~] = bwboundaries(radonPupil >pupilThresh*max(radonPupil(:)),8,'noholes'); % identify objects within image
    inspectFlag = false; % flag to indicate if first frame has multiple ROI defined
    if objNum == 1
        fillPupil = pupilBoundaries;
        % fill any subthreshold pixels inside the pupil boundary
        fillPupil = imfill(fillPupil,8,'holes'); % fill any holes within identified objects
        % get properties of detected objects in image
        areaFilled = regionprops(fillPupil,'FilledArea','Image','FilledImage','Centroid','MajorAxisLength','MinorAxisLength'); %identify binarized image object properties. This should be the Pupil!
    else
        if frameNum == 1
            fillPupil = pupilBoundaries;
            % fill any subthreshold pixels inside the pupil boundary
            fillPupil = imfill(fillPupil,8,'holes'); % fill any holes within identified objects
            areaFilled = regionprops(fillPupil,'FilledArea','Image','FilledImage','Centroid','MajorAxisLength','MinorAxisLength');%identify binarized image object properties. This should be the Pupil!
            for num = 1:size(areaFilled,1)
                theArea(num) = areaFilled(num).FilledArea; %#ok<*SAGROW>
            end
            if isempty(areaFilled) == false
                maxArea = max(theArea); % find the ROI with the largest area
                areaLogical = theArea == maxArea;
                areaFilled = areaFilled(areaLogical); % keep ROI with largest area, assumed to be pupil
                areaFilled = areaFilled(1); % if two ROI have same area take first one, this will need to be corrected
                inspectFlag = true; % use this to flag files that have multiple ROI for first frame
            else
                areaFilled = [];
                areaFilled.Centroid = NaN;
                areaFilled.MajorAxisLength = NaN;
                areaFilled.MinorAxisLength = NaN;
                areaFilled.FilledArea = NaN;
                inspectFlag = true; % use this to flag files that have multiple ROI for first frame
            end
        else
            areaFilled = regionprops(pupilBoundaries,'FilledArea','Image','FilledImage','Centroid','MajorAxisLength','MinorAxisLength'); %identify binarized image object properties.
        end
    end
    if frameNum > 1
        if abs((roiInt(frameNum) - roiInt(frameNum - 1))/roiInt(frameNum)) >= blinkThresh % Exclude fitting frame during blinks
            areaFilled = [];
            fillPupil(:) = 0;
        end
    end
    if ~isempty(areaFilled) % is an pupil identified
        if size(areaFilled,1) > 1 % is the pupil fragmented in to multiple ROI
            clear theArea areaLogical
            for num = 1:size(areaFilled,1)
                theArea(num) = areaFilled(num).FilledArea; %#ok<*SAGROW>
            end
            maxArea = max(theArea); % find the ROI with the largest area
            areaLogical = theArea == maxArea;
            areaFilled = areaFilled(areaLogical);
            areaFilled = areaFilled(1);
            % check for aberrant pupil diameter changes
            if frameNum > 1
                fracChange = (maxArea - pupilArea(frameNum-1))/pupilArea(frameNum-1); % frame-wise fractional change
                volFlag = fracChange <- 0.1; % does the change exceed a 10% reduction in pupil size
                if ~isnan(pupilArea(frameNum - 1)) % does the current frame follow a blink
                    if volFlag == true
                        if correctedFlag == false
                            lastFrameOK = frameNum - 1; % find last good pupil frame for size and location comparison
                            correctedFlag = true;
                        end
                        % correct aberrant diameters by altering radon threshold
                        pupilSweep = intensityThresh - (1:100); % adjust threshold of binary image instead of radon image KWG
                        for sweepNum = 1:size(pupilSweep,2)
                            if volFlag == true
                                isoSweep = threshImg; % get video frame
                                isoSweep(isoSweep < pupilSweep(sweepNum)) = 0; % set all pixel intensities below new thresh to zero
                                isoSweep(isoSweep >= pupilSweep(sweepNum)) = 1; % set all pixel intensities above new thresh to one
                                inPupil = [];
                                [~,correctBoundaries,~] = bwboundaries(gather(isoSweep),8,'noholes'); % Identify above threshold regions
                                fillCorrection = correctBoundaries;
                                fillCorrection =imfill(fillCorrection,8,'holes'); % fill holes in regions
                                areaCorrect = regionprops(fillCorrection,'FilledArea','Image','FilledImage','Centroid','MajorAxisLength','MinorAxisLength','PixelList'); %find region properties
                                for areaNum = 1:size(areaCorrect,1)
                                    areaCentroid = round(areaCorrect(areaNum).Centroid,0);
                                    inPupil(areaNum) = pupilBoundary(areaCentroid(2),areaCentroid(1),lastFrameOK); % determine if centroid of region was in previous pupil volume
                                end
                                theInds = find(inPupil == 1);
                                keepRegions = areaCorrect(theInds); % keep only regions within previous pupil measurements
                                keepMask = zeros(size(fillCorrection,1),size(fillCorrection,2));
                                for keepNum = 1:size(keepRegions,1)
                                    for pixNum = 1:size(keepRegions(keepNum).PixelList)
                                        keepMask(keepRegions(keepNum).PixelList(pixNum,2),keepRegions(keepNum).PixelList(pixNum,1)) = 1; % remap kept regions in to image frame
                                    end
                                end
                                fuseMask = bwconvhull(keepMask); % use convex hull operation to enclose regions previously within pupil
                                fusedCorrect = regionprops(fuseMask,'FilledArea','Image','FilledImage','Centroid','MajorAxisLength','MinorAxisLength','PixelList'); % measure new corrected pupil volume properties
                                if length(fusedCorrect) > 1
                                    fusedCorrect = fusedCorrect(1);
                                end
                                if ~isempty(fusedCorrect)
                                    fracChange = (fusedCorrect.FilledArea - pupilArea(lastFrameOK))/pupilArea(lastFrameOK); %compare pupil size to last known pupil size
                                    volFlag = fracChange < -0.1;
                                else
                                    fracChange = 100; % if no data present force frac change outside threshold to keep frame
                                end
                            end
                        end
                        % this can be used to insert NaN if the change is > 10%
                        if  abs(fracChange) < 0.1 % changed to only fill data withing a +/- 10% change in area
                            fillPupil = fuseMask;
                            areaFilled = fusedCorrect;
                        end
                        if ~exist('correctedFrames','var')
                            frameInd = 1;
                            correctedFrames(frameInd) = frameNum;
                        else
                            frameInd = frameInd + 1;
                            correctedFrames(frameInd) = frameNum;
                        end
                    else
                        correctedFlag = false;
                        lastFrameOK = frameNum;
                    end
                end
            end
        else
            if frameNum > 1
                % check for aberrant pupil diameter changes
                fracChange = (areaFilled.FilledArea - pupilArea(frameNum - 1))/pupilArea(frameNum - 1);
                volFlag = fracChange < -0.1;
                if ~isnan(pupilArea(frameNum - 1))
                    if volFlag == true
                        if correctedFlag == false
                            lastFrameOK = frameNum - 1;
                            correctedFlag = true;
                        end
                        % correct aberrant diameters with previous pupil locations
                        pupilSweep = intensityThresh - (1:100); % adjust threshold of binary image instead of radon image KWG
                        for sweepNum = 1:size(pupilSweep,2)
                            if volFlag == true
                                isoSweep = threshImg; % get video frame
                                isoSweep(isoSweep < pupilSweep(sweepNum)) = 0; % set all pixel intensities below thresh to zero
                                isoSweep(isoSweep >= pupilSweep(sweepNum)) = 1; % set all pixel intensities above thresh to one
                                radSweep = radon(isoSweep); % take radon transform of binarized image
                                minPupil = min(radSweep,[],1);
                                minMat = repmat(minPupil,size(radSweep,1),1);
                                maxMat = repmat(max((radSweep - minMat),[],1),size(radSweep,1),1);
                                % normalize each projection angle to its min and max values. Each value should now be between [0 1]
                                normSweep = (radSweep - minMat)./maxMat;
                                threshSweep = normSweep;
                                % binarize radon projection
                                threshSweep(normSweep >= radonThresh) = 1;
                                threshSweep(normSweep < radonThresh) = 0;
                                % transform back to image space
                                radonSweep = gather(iradon(double(threshSweep),theAngles,'linear','Hamming',size(workingImg,2)));
                                sweepArea = [];
                                % get image objects
                                [~,sweepBoundaries] = bwboundaries(radonSweep > pupilSweep(sweepNum)*max(radonSweep(:)),8,'noholes');
                                fillSweep = sweepBoundaries;
                                fillSweep = imfill(fillSweep,8,'holes');
                                % get object properties
                                areaSweep = regionprops(fillSweep,'FilledArea','Image','FilledImage','Centroid','MajorAxisLength','MinorAxisLength');
                                for num = 1:size(areaSweep,1)
                                    sweepArea(num) = areaSweep(num).FilledArea; %#ok<*AGROW>
                                end
                                maxSweep = max(sweepArea);
                                sweepLogical = sweepArea == maxSweep;
                                fracChange = (maxSweep - pupilArea(lastFrameOK))/pupilArea(lastFrameOK);
                                volFlag = fracChange < -0.1;
                            end
                        end
                        % this can be used to insert NaN if the change is > 10%
                        if abs(fracChange) < 0.1
                            fillPupil = fillCorrection;
                            areaFilled = areaCorrect(sweepLogical);
                        end
                        if ~exist('correctedFrames','var')
                            frameInd = 1;
                            correctedFrames(frameInd)=frameNum;
                        else
                            frameInd = frameInd + 1;
                            correctedFrames(frameInd) = frameNum;
                        end
                    else
                        correctedFlag = false;
                        lastFrameOK = frameNum;
                    end
                end
            end
        end
        pupilArea(frameNum) = areaFilled.FilledArea;
        pupilMajor(frameNum) = areaFilled.MajorAxisLength;
        pupilMinor(frameNum) = areaFilled.MinorAxisLength;
        pupilCentroid(frameNum,:) = areaFilled.Centroid;
        pupilBoundary(:,:,frameNum) = fillPupil;
        holdMat = labeloverlay(imageStack(:,:,frameNum),fillPupil,'Transparency',0.8,'Colormap','spring'); % this is the measured pupil overlayed on the movie frame
        if size(holdMat,3) == 1
            overlay(:,:,:,frameNum) = repmat(holdMat,1,1,3);
        else
            overlay(:,:,:,frameNum) = holdMat; % this is the measured pupil overlayed on the movie
        end
    else
        pupilArea(frameNum) = NaN;
        pupilMajor(frameNum) = NaN;
        pupilMinor(frameNum) = NaN;
        pupilCentroid(frameNum,:) = NaN;
        pupilBoundary(:,:,frameNum) = fillPupil;
        holdMat = labeloverlay(imageStack(:,:,frameNum),fillPupil); % this is the measured pupil overlayed on the movie frame
        if size(holdMat,3) == 1
            overlay(:,:,:,frameNum) = repmat(holdMat,1,1,3);
        else
            overlay(:,:,:,frameNum) = holdMat; % this is the measured pupil overlayed on the movie
        end
    end
    multiWaitbar('Tracking Pupil ...','Value',frameNum/waitBarLength);
end
proceEnd = toc(procStart);
procMin = proceEnd/60;
minText = num2str(procMin);
procSec = round(str2double(minText(2:end))*60,0);
secText = num2str(procSec);
disp(['File processing time: ' minText(1) ' min ' secText ' seconds']); disp(' ')
% save data
data.pupilArea = pupilArea;
data.pupilMajor = pupilMajor;
data.pupilMinor = pupilMinor;
data.pupilCentroid = pupilCentroid;
data.eyeROI = eyeROI;
data.roiIntensity = gather(roiInt);
data.inspectFile = inspectFlag; % did the first frame include more than one ROI?
blinks = find((abs(diff(data.roiIntensity))./data.roiIntensity(2:end)) >= blinkThresh) + 1;
data.blinkFrames = overlay(:,:,:,blinks);
data.blinkInds = blinks;
%% patch NaNs due to blinking
blinkNaNs = isnan(pupilArea);
[linkedBlinkIndex] = LinkBinaryEvents(gt(blinkNaNs,0),[samplingRate,0]); % link greater than 1 second
% identify edges for interpolation
xx = 1;
edgeFoundA = false;
startEdgeA = [];
endEdgeA = [];
for aa = 1:length(linkedBlinkIndex)
    if edgeFoundA == false
        if linkedBlinkIndex(1,aa) == 1 && (aa < length(linkedBlinkIndex)) == true
            startEdgeA(xx,1) = aa;
            edgeFoundA = true;
        end
    elseif edgeFoundA == true
        if linkedBlinkIndex(1,aa) == 0
            endEdgeA(xx,1) = aa;
            edgeFoundA = false;
            xx = xx + 1;
        elseif (length(linkedBlinkIndex) == aa) == true && (linkedBlinkIndex(1,aa) == 1) == true
            endEdgeA(xx,1) = aa;
        end
    end
end
% fill from start:ending edges of rapid pupil fluctuations that weren't NaN
testPupilAreaA = data.pupilArea;
patchLength = [];
for aa = 1:length(startEdgeA)
    try
        testPupilAreaA(startEdgeA(aa,1) - 2:endEdgeA(aa,1) + 2) = NaN;
        patchLength(aa,1) = (endEdgeA(aa,1) + 2) - (startEdgeA(aa,1) - 2);
    catch
        testPupilAreaA(startEdgeA(aa,1):endEdgeA(aa,1)) = NaN;
        patchLength(aa,1) = endEdgeA(aa,1) - startEdgeA(aa,1);
    end
end
% patch NaN values with moving median filter
try
    data.patchedPupilAreaA = fillmissing(testPupilAreaA,'movmedian',max(patchLength)*2);
catch
    data.patchedPupilAreaA = testPupilAreaA;
end
%% patch sudden spikes
diffArea = abs(diff(data.patchedPupilAreaA));
% threshold for interpolation
threshold = 250;
diffIndex = diffArea > threshold;
[linkedDiffIndex] = LinkBinaryEvents(gt(diffIndex,0),[samplingRate*2,0]);
% identify edges for interpolation
edgeFoundB = false;
xx = 1;
startEdgeB = [];
endEdgeB = [];
for aa = 1:length(linkedDiffIndex)
    if edgeFoundB == false
        if (linkedDiffIndex(1,aa) == 1) == true && (aa < length(linkedDiffIndex)) == true
            startEdgeB(xx,1) = aa;
            edgeFoundB = true;
        end
    elseif edgeFoundB == true
        if linkedDiffIndex(1,aa) == 0
            endEdgeB(xx,1) = aa;
            edgeFoundB = false;
            xx = xx + 1;
        elseif (length(linkedDiffIndex) == aa) == true && (linkedDiffIndex(1,aa) == 1) == true && edgeFoundB == true
            endEdgeB(xx,1) = aa;
        end
    end
end
% fill from start:ending edges of rapid pupil fluctuations that weren't NaN
testPupilAreaB = data.patchedPupilAreaA;
for aa = 1:length(startEdgeB)
    try
        testPupilAreaB(startEdgeB(aa,1) - 2:endEdgeB(aa,1) + 2) = NaN;
        patchLength = (endEdgeB(aa,1) + 2) - (startEdgeB(aa,1) - 2);
    catch
        testPupilAreaB(startEdgeB(aa,1):endEdgeB(aa,1)) = NaN;
        patchLength = endEdgeB(aa,1) - startEdgeB(aa,1);
    end
    testPupilAreaB = fillmissing(testPupilAreaB,'movmedian',patchLength*2);
end
data.patchedPupilArea = testPupilAreaB;
%% original vs. updated algorithm
trackingFig = figure;
sgtitle(strrep(pupilCamFileID,'_',' '))
[z,p,k] = butter(4,1/(samplingRate/2),'low');
[sos,g] = zp2sos(z,p,k);
p0 = plot((1:length(data.pupilArea))/samplingRate,data.pupilArea,'k','LineWidth',1);
hold on
try
    p1 = plot((1:length(data.pupilArea))/samplingRate,filtfilt(sos,g,data.patchedPupilArea),'m','LineWidth',1);
catch
    p1 = plot((1:length(data.pupilArea))/samplingRate,data.patchedPupilArea,'m','LineWidth',1);
end
s1 = scatter(data.blinkInds/samplingRate,ones(length(data.blinkInds),1)*max(data.patchedPupilArea),'MarkerEdgeColor','b');
title('Filt pupil area');
xlabel('Time (sec)');
ylabel('Area (pixels)');
set(gca,'box','off')
axis tight
legend([p0,p1,s1],'Original','Processed','Blinks')
multiWaitbar('CloseAll');

%% binary linking function
function [linkedWF] = LinkBinaryEvents(binWF,dCrit)
%________________________________________________________________________________________________________________________
% Edited by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%
% Purpose: Link binary events that occur within a certain amount of time.
%________________________________________________________________________________________________________________________

% identify edges, control for trial start/stop
dBinWF = diff(gt(binWF,0));
upInd = find(dBinWF == 1);
downInd = find(dBinWF == -1);
if binWF(end) > 0
    downInd = [downInd,length(binWF)];
end
if binWF(1) > 0
    upInd = [1,upInd];
end
% link periods of bin_wf == 0 together if less than dCrit(1). calculate time between events
brkTimes = upInd(2:length(upInd)) - downInd(1:(length(downInd) - 1));
% identify times less than user-defined period
sub_dCritDowns = find(lt(brkTimes,dCrit(1)));
% link any identified breaks together
if isempty(sub_dCritDowns) == 0
    for d = 1:length(sub_dCritDowns)
        start = downInd(sub_dCritDowns(d));
        stop = upInd(sub_dCritDowns(d) + 1);
        binWF(start:stop) = 1;
    end
end
% link periods of bin_wf == 1 together if less than dCrit(2)
hitimes = downInd - upInd;
blips = find(lt(hitimes,dCrit(2)) == 1);
if isempty(blips) == 0
    for b = 1:length(blips)
        start = upInd(blips(b));
        stop = downInd(blips(b));
        binWF(start:stop) = 0;
    end
end
linkedWF = binWF;

end

%% wait bar function
function [cancel] = multiWaitbar(label,varargin)
%________________________________________________________________________________________________________________________
% Utilized in analysis by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% multiWaitbar: add, remove or update an entry on the multi waitbar
%
%   multiWaitbar(LABEL,VALUE) adds a waitbar for the specified label, or
%   if it already exists updates the value. LABEL must be a string and
%   VALUE a number between zero and one or the string 'Close' to remove the
%   entry Setting value equal to 0 or 'Reset' will cause the progress bar
%   to reset and the time estimate to be re-initialized.
%
%   multiWaitbar(LABEL,COMMAND,VALUE,...)  or
%   multiWaitbar(LABEL,VALUE,COMMAND,VALUE,...)
%   passes one or more command/value pairs for changing the named waitbar
%   entry. Possible commands include:
%   'Value'       Set the value of the named waitbar entry. The
%                 corresponding value must be a number between 0 and 1.
%   'Increment'   Increment the value of the named waitbar entry. The
%                 corresponding value must be a number between 0 and 1.
%   'Color'       Change the color of the named waitbar entry. The
%                 value must be an RGB triple, e.g. [0.1 0.2 0.3], or a
%                 single-character color name, e.g. 'r', 'b', 'm'.
%   'Relabel'     Change the label of the named waitbar entry. The
%                 value must be the new name.
%   'Reset'       Set the named waitbar entry back to zero and reset its
%                 timer. No value need be specified.
%   'CanCancel'   [on|off] should a "cancel" button be shown for this bar
%                 (default 'off').
%   'CancelFcn'   Function to call in the event that the user cancels.
%   'ResetCancel' Reset the "cancelled" flag for an entry (ie. if you
%                 decide not to cancel).
%   'Close'       Remove the named waitbar entry.
%   'Busy'        Puts this waitbar in "busy mode" where a small bar
%                 bounces back and forth. Return to normal progress display
%                 using the 'Reset' command.
%
%   cancel = multiWaitbar(LABEL,VALUE) also returns whether the user has
%   clicked the "cancel" button for this entry (true or false). Two
%   mechanisms are provided for cancelling an entry if the 'CanCancel'
%   setting is 'on'. The first is just to check the return argument and if
%   it is true abort the task. The second is to set a 'CancelFcn' that is
%   called when the user clicks the cancel button, much as is done for
%   MATLAB's built-in WAITBAR. In either case, you can use the
%   'ResetCancel' command if you don't want to cancel after all.
%
%   multiWaitbar('CLOSEALL') closes the waitbar window.
%
%   Example:
%   multiWaitbar( 'CloseAll' );
%   multiWaitbar( 'Task 1', 0 );
%   multiWaitbar( 'Task 2', 0.5, 'Color', 'b' );
%   multiWaitbar( 'Task 3', 'Busy');
%   multiWaitbar( 'Task 1', 'Value', 0.1 );
%   multiWaitbar( 'Task 2', 'Increment', 0.2 );
%   multiWaitbar( 'Task 3', 'Reset' ); % Disables "busy" mode
%   multiWaitbar( 'Task 3', 'Value', 0.3 );
%   multiWaitbar( 'Task 2', 'Close' );
%   multiWaitbar( 'Task 3', 'Close' );
%   multiWaitbar( 'Task 1', 'Close' );
%
%   Example:
%   multiWaitbar( 'Task 1', 0, 'CancelFcn', @(a,b) disp( ['Cancel ',a] ) );
%   for ii=1:100
%      abort = multiWaitbar( 'Task 1', ii/100 );
%      if abort
%         % Here we would normally ask the user if they're sure
%         break
%      else
%         pause( 1 )
%      end
%   end
%   multiWaitbar( 'Task 1', 'Close' )
%
%   Example:
%   multiWaitbar( 'CloseAll' );
%   multiWaitbar( 'Red...',    7/7, 'Color', [0.8 0.0 0.1] );
%   multiWaitbar( 'Orange...', 6/7, 'Color', [1.0 0.4 0.0] );
%   multiWaitbar( 'Yellow...', 5/7, 'Color', [0.9 0.8 0.2] );
%   multiWaitbar( 'Green...',  4/7, 'Color', [0.2 0.9 0.3] );
%   multiWaitbar( 'Blue...',   3/7, 'Color', [0.1 0.5 0.8] );
%   multiWaitbar( 'Indigo...', 2/7, 'Color', [0.4 0.1 0.5] );
%   multiWaitbar( 'Violet...', 1/7, 'Color', [0.8 0.4 0.9] );
%
%    Thanks to Jesse Hopkins for suggesting the "busy" mode.

%   Author: Ben Tordoff
%   Copyright 2007-2014 The MathWorks, Inc.

persistent FIGH;
cancel = false;

% Check basic inputs
error( nargchk( 1, inf, nargin ) ); %#ok<NCHKN> - kept for backwards compatibility
if ~ischar( label )
    error( 'multiWaitbar:BadArg', 'LABEL must be the name of the progress entry (i.e. a string)' );
end

% Try to get hold of the figure
if isempty( FIGH ) || ~ishandle( FIGH )
    FIGH = findall( 0, 'Type', 'figure', 'Tag', 'multiWaitbar:Figure' );
    if isempty(FIGH)
        FIGH = iCreateFig();
    else
        FIGH = handle( FIGH(1) );
    end
end

% Check for close all and stop early
if any( strcmpi( label, {'CLOSEALL','CLOSE ALL'} ) )
    iDeleteFigure(FIGH);
    return;
end

% Make sure we're on-screen
if ~strcmpi( FIGH.Visible, 'on' )
    FIGH.Visible = 'on';
end

% Get the list of entries and see if this one already exists
entries = getappdata( FIGH, 'ProgressEntries' );
if isempty(entries)
    idx = [];
else
    idx = find( strcmp( label, {entries.Label} ), 1, 'first' );
end
bgcol = getappdata( FIGH, 'DefaultProgressBarBackgroundColor' );

% If it doesn't exist, create it
needs_redraw = false;
entry_added = isempty(idx);
if entry_added
    % Create a new entry
    defbarcolor = getappdata( FIGH, 'DefaultProgressBarColor' );
    entries = iAddEntry( FIGH, entries, label, 0, defbarcolor, bgcol );
    idx = numel( entries );
end

% Check if the user requested a cancel
if nargout
    cancel = entries(idx).Cancel;
end

% Parse the inputs. We shortcut the most common case as an efficiency
force_update = false;
if nargin==2 && isnumeric( varargin{1} )
    entries(idx).LastValue = entries(idx).Value;
    entries(idx).Value = max( 0, min( 1, varargin{1} ) );
    entries(idx).Busy = false;
    needs_update = true;
else
    [params,values] = iParseInputs( varargin{:} );

    needs_update = false;
    for ii=1:numel( params )
        switch upper( params{ii} )
            case 'BUSY'
                entries(idx).Busy = true;
                needs_update = true;

            case 'VALUE'
                entries(idx).LastValue = entries(idx).Value;
                entries(idx).Value = max( 0, min( 1, values{ii} ) );
                entries(idx).Busy = false;
                needs_update = true;

            case {'INC','INCREMENT'}
                entries(idx).LastValue = entries(idx).Value;
                entries(idx).Value = max( 0, min( 1, entries(idx).Value + values{ii} ) );
                entries(idx).Busy = false;
                needs_update = true;

            case {'COLOR','COLOUR'}
                entries(idx).CData = iMakeColors( values{ii}, 16 );
                needs_update = true;
                force_update = true;

            case {'RELABEL', 'UPDATELABEL'}
                % Make sure we have a string as the value and that it
                % doesn't already appear
                if ~ischar( values{ii} )
                    error( 'multiWaitbar:BadString', 'Value for ''Relabel'' must be a string.' );
                end
                if ismember( values{ii}, {entries.Label} )
                    error( 'multiWaitbar:NameAlreadyExists', 'Cannot relabel an entry to a label that already exists.' );
                end
                entries(idx).Label = values{ii};
                needs_update = true;
                force_update = true;

            case {'CANCANCEL'}
                if ~ischar( values{ii} ) || ~any( strcmpi( values{ii}, {'on','off'} ) )
                    error( 'multiWaitbar:BadString', 'Parameter ''CanCancel'' must be a ''on'' or ''off''.' );
                end
                entries(idx).CanCancel = strcmpi( values{ii}, 'on' );
                entries(idx).Cancel = false;
                needs_redraw = true;

            case {'RESETCANCEL'}
                entries(idx).Cancel = false;
                needs_redraw = true;

            case {'CANCELFCN'}
                if ~isa( values{ii}, 'function_handle' )
                    error( 'multiWaitbar:BadFunction', 'Parameter ''CancelFcn'' must be a valid function handle.' );
                end
                entries(idx).CancelFcn = values{ii};
                if ~entries(idx).CanCancel
                    entries(idx).CanCancel = true;
                end
                needs_redraw = true;

            case {'CLOSE','DONE'}
                if ~isempty(idx)
                    % Remove the selected entry
                    entries = iDeleteEntry( entries, idx );
                end
                if isempty( entries )
                    iDeleteFigure( FIGH );
                    % With the window closed, there's nothing else to do
                    return;
                else
                    needs_redraw = true;
                end
                % We can't continue after clearing the entry, so jump out
                break;

            otherwise
                error( 'multiWaitbar:BadArg', 'Unrecognized command: ''%s''', params{ii} );

        end
    end
end

% Now work out what to update/redraw
if needs_redraw
    setappdata( FIGH, 'ProgressEntries', entries );
    iRedraw( FIGH );
    % NB: Redraw includes updating all bars, so never need to do both
elseif needs_update
    [entries(idx),needs_redraw] = iUpdateEntry( entries(idx), force_update );
    setappdata( FIGH, 'ProgressEntries', entries );
    % NB: if anything was updated onscreen, "needs_redraw" is now true.
end
if entry_added || needs_redraw
    % If the shape or size has changed, do a full redraw, including events
    drawnow();
end

% If we have any "busy" entries, start the timer, otherwise stop it.
myTimer = getappdata( FIGH, 'BusyTimer' );
if any([entries.Busy])
    if strcmpi(myTimer.Running,'off')
        start(myTimer);
    end
else
    if strcmpi(myTimer.Running,'on')
        stop(myTimer);
    end
end

end % multiWaitbar


%-------------------------------------------------------------------------%
function [params, values] = iParseInputs( varargin )
% Parse the input arguments, extracting a list of commands and values
idx = 1;
params = {};
values = {};
if nargin==0
    return;
end
if isnumeric( varargin{1} )
    params{idx} = 'Value';
    values{idx} = varargin{1};
    idx = idx + 1;
end

while idx <= nargin
    param = varargin{idx};
    if ~ischar( param )
        error( 'multiWaitbar:BadSyntax', 'Additional properties must be supplied as property-value pairs' );
    end
    params{end+1,1} = param; %#ok<AGROW>
    values{end+1,1} = []; %#ok<AGROW>
    switch upper( param )
        case {'DONE','CLOSE','RESETCANCEL'}
            % No value needed, and stop
            break;
        case {'BUSY'}
            % No value needed but parsing should continue
            idx = idx + 1;
        case {'RESET','ZERO','SHOW'}
            % All equivalent to saying ('Value', 0)
            params{end} = 'Value';
            values{end} = 0;
            idx = idx + 1;
        otherwise
            if idx==nargin
                error( 'multiWaitbar:BadSyntax', 'Additional properties must be supplied as property-value pairs' );
            end
            values{end,1} = varargin{idx+1};
            idx = idx + 2;
    end
end
if isempty( params )
    error( 'multiWaitbar:BadSyntax', 'Must specify a value or a command' );
end
end % iParseInputs

%-------------------------------------------------------------------------%
function fobj = iCreateFig()
% Create the progress bar group window
bgcol = get(0,'DefaultUIControlBackgroundColor');
f = figure( ...
    'Name', 'Progress', ...
    'Tag', 'multiWaitbar:Figure', ...
    'Color', bgcol, ...
    'MenuBar', 'none', ...
    'ToolBar', 'none', ...
    'WindowStyle', 'normal', ... % We don't want to be docked!
    'HandleVisibility', 'off', ...
    'IntegerHandle', 'off', ...
    'Visible', 'off', ...
    'NumberTitle', 'off' );
% Resize and centre on the first screen
screenSize = get(0,'ScreenSize');
figSz = [600 100];
figPos = ceil((screenSize(1,3:4)-figSz)/2);
figPos(2) = ceil(screenSize(4)*.85);
fobj = handle( f );
fobj.Position = [figPos, figSz];
setappdata( fobj, 'ProgressEntries', [] );
% Make sure we have the image
defbarcolor = [0.8 0.0 0.1];
barbgcol = uint8( 255*0.75*bgcol );
setappdata( fobj, 'DefaultProgressBarBackgroundColor', barbgcol );
setappdata( fobj, 'DefaultProgressBarColor', defbarcolor );
setappdata( fobj, 'DefaultProgressBarSize', [350 16] );
% Create the timer to use for "Busy" mode, being sure to delete any
% existing ones
delete( timerfind('Tag', 'MultiWaitbarTimer') );
myTimer = timer( ...
    'TimerFcn', @(src,evt) iTimerFcn(f), ...
    'Period', 0.02, ...
    'ExecutionMode', 'FixedRate', ...
    'Tag', 'MultiWaitbarTimer' );
setappdata( fobj, 'BusyTimer', myTimer );

% Setup the resize function after we've finished setting up the figure to
% avoid excessive redraws
fobj.ResizeFcn = @iRedraw;
fobj.CloseRequestFcn = @iCloseFigure;
end % iCreateFig

%-------------------------------------------------------------------------%
function cdata = iMakeColors( baseColor, height )
% Creates a shiny bar from a single base color
lightColor = [1 1 1];
badColorErrorID = 'multiWaitbar:BadColor';
badColorErrorMsg = 'Colors must be a three element vector [R G B] or a single character (''r'', ''g'' etc.)';

if ischar(baseColor)
    switch upper(baseColor)
        case 'K'
            baseColor = [0.1 0.1 0.1];
        case 'R'
            baseColor = [0.8 0 0];
        case 'G'
            baseColor = [0 0.6 0];
        case 'B'
            baseColor = [0 0 0.8];
        case 'C'
            baseColor = [0.2 0.8 0.9];
        case 'M'
            baseColor = [0.6 0 0.6];
        case 'Y'
            baseColor = [0.720000 0.530000 0.040000];
        case 'W'
            baseColor = [0.9 0.9 0.9];
        case 'O'
            baseColor = [0.910000 0.410000 0.170000];
        case 'P'
            baseColor = [0.470000 0.320000 0.660000];
        case 'A'
            baseColor = [0.940000 0.870000 0.800000];
        otherwise
            error( badColorErrorID, badColorErrorMsg );
    end
else
    if numel(baseColor) ~= 3
        error( badColorErrorID, badColorErrorMsg );
    end
    if isa( baseColor, 'uint8' )
        baseColor = double( baseColor ) / 255;
    elseif isa( baseColor, 'double' )
        if any(baseColor>1) || any(baseColor<0)
            error( 'multiWaitbar:BadColorValue', 'Color values must be in the range 0 to 1 inclusive.' );
        end
    else
        error( badColorErrorID, badColorErrorMsg );
    end
end

% By this point we should have a double precision 3-element vector.
cols = repmat( baseColor, [height, 1] );

breaks = max( 1, round( height * [1 25 50 75 88 100] / 100 ) );
cols(breaks(1),:) = 0.6*baseColor;
cols(breaks(2),:) = lightColor - 0.4*(lightColor-baseColor);
cols(breaks(3),:) = baseColor;
cols(breaks(4),:) = min( baseColor*1.2, 1.0 );
cols(breaks(5),:) = min( baseColor*1.4, 0.95 ) + 0.05;
cols(breaks(6),:) = min( baseColor*1.6, 0.9 ) + 0.1;

y = 1:height;
cols(:,1) = max( 0, min( 1, interp1( breaks, cols(breaks,1), y, 'pchip' ) ) );
cols(:,2) = max( 0, min( 1, interp1( breaks, cols(breaks,2), y, 'pchip' ) ) );
cols(:,3) = max( 0, min( 1, interp1( breaks, cols(breaks,3), y, 'pchip' ) ) );
cdata = uint8( 255 * cat( 3, cols(:,1), cols(:,2), cols(:,3) ) );
end % iMakeColors


%-------------------------------------------------------------------------%
function cdata = iMakeBackground( baseColor, height )
% Creates a shaded background
if isa( baseColor, 'uint8' )
    baseColor = double( baseColor ) / 255;
end

ratio = 1 - exp( -0.5-2*(1:height)/height )';
cdata = uint8( 255 * cat( 3, baseColor(1)*ratio, baseColor(2)*ratio, baseColor(3)*ratio ) );
end % iMakeBackground

%-------------------------------------------------------------------------%
function entries = iAddEntry( parent, entries, label, value, color, bgcolor )
% Add a new entry to the progress bar

% Create bar coloring
psize = getappdata( parent, 'DefaultProgressBarSize' );
cdata = iMakeColors( color, 16 );
% Create background image
barcdata = iMakeBackground( bgcolor, psize(2) );

% Work out the size in advance
labeltext = uicontrol( 'Style', 'Text', ...
    'String', label, ...
    'Parent', parent, ...
    'HorizontalAlignment', 'Left' );
etatext = uicontrol( 'Style', 'Text', ...
    'String', '', ...
    'Parent', parent, ...
    'HorizontalAlignment', 'Right' );
progresswidget = uicontrol( 'Style', 'Checkbox', ...
    'String', '', ...
    'Parent', parent, ...
    'Position', [5 5 psize], ...
    'CData', barcdata );
cancelwidget = uicontrol( 'Style', 'PushButton', ...
    'String', '', ...
    'FontWeight', 'Bold', ...
    'Parent', parent, ...
    'Position', [5 5 16 16], ...
    'CData', iMakeCross( 8 ), ...
    'Callback', @(src,evt) iCancelEntry( src, label ), ...
    'Visible', 'off' );
mypanel = uipanel( 'Parent', parent, 'Units', 'Pixels' );

newentry = struct( ...
    'Label', label, ...
    'Value', value, ...
    'LastValue', inf, ...
    'Created', tic(), ...
    'LabelText', labeltext, ...
    'ETAText', etatext, ...
    'ETAString', '', ...
    'Progress', progresswidget, ...
    'ProgressSize', psize, ...
    'Panel', mypanel, ...
    'BarCData', barcdata, ...
    'CData', cdata, ...
    'BackgroundCData', barcdata, ...
    'CanCancel', false, ...
    'CancelFcn', [], ...
    'CancelButton', cancelwidget, ...
    'Cancel', false, ...
    'Busy', false );
if isempty( entries )
    entries = newentry;
else
    entries = [entries;newentry];
end
% Store in figure before the redraw
setappdata( parent, 'ProgressEntries', entries );
if strcmpi( get( parent, 'Visible' ), 'on' )
    iRedraw( parent, [] );
else
    set( parent, 'Visible', 'on' );
end
end % iAddEntry

%-------------------------------------------------------------------------%
function entries = iDeleteEntry( entries, idx )
delete( entries(idx).LabelText );
delete( entries(idx).ETAText );
delete( entries(idx).CancelButton );
delete( entries(idx).Progress );
delete( entries(idx).Panel );
entries(idx,:) = [];
end % iDeleteEntry

%-------------------------------------------------------------------------%
function entries = iCancelEntry( src, name )
figh = ancestor( src, 'figure' );
entries = getappdata( figh, 'ProgressEntries' );
if isempty(entries)
    % The entries have been lost - nothing can be done.
    return
end
idx = find( strcmp( name, {entries.Label} ), 1, 'first' );

% Set the cancel flag so that the user is told on next update
entries(idx).Cancel = true;
setappdata( figh, 'ProgressEntries', entries );

% If a user function is supplied, call it
if ~isempty( entries(idx).CancelFcn )
    feval( entries(idx).CancelFcn, name, 'Cancelled' );
end

end % iCancelEntry


%-------------------------------------------------------------------------%
function [entry,updated] = iUpdateEntry( entry, force )
% Update one progress bar

% Deal with busy entries separately
if entry.Busy
    entry = iUpdateBusyEntry(entry);
    updated = true;
    return;
end

% Some constants
marker_weight = 0.8;

% Check if the label needs updating
updated = force;
val = entry.Value;
lastval = entry.LastValue;

% Now update the bar
psize = entry.ProgressSize;
filled = max( 1, round( val*psize(1) ) );
lastfilled = max( 1, round( lastval*psize(1) ) );

% We do some careful checking so that we only redraw what we have to. This
% makes a small speed difference, but every little helps!
if force || (filled<lastfilled)
    % Create the bar background
    startIdx = 1;
    bgim = entry.BackgroundCData(:,ones( 1, psize(1)-filled ),:);
    barim = iMakeBarImage(entry.CData, startIdx, filled);
    progresscdata = [barim,bgim];

    % Add light/shadow around the markers
    markers = round( (0.1:0.1:val)*psize(1) );
    markers(markers<startIdx | markers>(filled-2)) = [];
    highlight = [marker_weight*entry.CData, 255 - marker_weight*(255-entry.CData)];
    for ii=1:numel( markers )
        progresscdata(:,markers(ii)+[-1,0],:) = highlight;
    end

    % Set the image into the checkbox
    entry.BarCData = progresscdata;
    set( entry.Progress, 'cdata', progresscdata );
    updated = true;

elseif filled > lastfilled
    % Just need to update the existing data
    progresscdata = entry.BarCData;
    startIdx = max(1,lastfilled-1);
    % Repmat is the obvious way to fill the bar, but BSXFUN is often
    % faster. Indexing is obscure but faster still.
    progresscdata(:,startIdx:filled,:) = iMakeBarImage(entry.CData, startIdx, filled);

    % Add light/shadow around the markers
    markers = round( (0.1:0.1:val)*psize(1) );
    markers(markers<startIdx | markers>(filled-2)) = [];
    highlight = [marker_weight*entry.CData, 255 - marker_weight*(255-entry.CData)];
    for ii=1:numel( markers )
        progresscdata(:,markers(ii)+[-1,0],:) = highlight;
    end

    entry.BarCData = progresscdata;
    set( entry.Progress, 'CData', progresscdata );
    updated = true;
end

% As an optimization, don't update any text if the bar didn't move and the
% percentage hasn't changed
decval = round( val*100 );
lastdecval = round( lastval*100 );

if ~updated && (decval == lastdecval)
    return
end

% Now work out the remaining time
minTime = 0; % secs
if val <= 0
    % Zero value, so clear the eta
    entry.Created = tic();
    elapsedtime = 0;
    etaString = '';
else
    elapsedtime = round(toc( entry.Created )); % in seconds

    % Only show the remaining time if we've had time to estimate
    if elapsedtime < minTime
        % Not enough time has passed since starting, so leave blank
        etaString = '';
    else
        % Calculate a rough ETA
        eta = elapsedtime * (1-val) / val;
        etaString = iGetTimeString( eta );
    end
end

if ~isequal( etaString, entry.ETAString )
    set( entry.ETAText, 'String', etaString );
    entry.ETAString = etaString;
    updated = true;
end

% Update the label too
if force || elapsedtime > minTime
    if force || (decval ~= lastdecval)
        labelstr = [entry.Label, sprintf( ' (%d%%)', decval )];
        set( entry.LabelText, 'String', labelstr );
        updated = true;
    end
end

end % iUpdateEntry

function eta = iGetTimeString( remainingtime )
if remainingtime > 172800 % 2 days
    eta = sprintf( '%d days', round(remainingtime/86400) );
else
    if remainingtime > 7200 % 2 hours
        eta = sprintf( '%d hours', round(remainingtime/3600) );
    else
        if remainingtime > 120 % 2 mins
            eta = sprintf( '%d mins', round(remainingtime/60) );
        else
            % Seconds
            remainingtime = round( remainingtime );
            if remainingtime > 1
                eta = sprintf( '%d secs', remainingtime );
            elseif remainingtime == 1
                eta = '1 sec';
            else
                eta = ''; % Nearly done (<1sec)
            end
        end
    end
end
% eta = '';
end % iGetTimeString


%-------------------------------------------------------------------------%
function entry = iUpdateBusyEntry( entry )
% Update a "busy" progress bar
% Make sure the widget is still OK
if ~ishandle(entry.Progress)
    return
end
% Work out the new position. Since the bar is 0.1 long and needs to bounce,
% the position varies from 0 up to 0.9 then back down again. We achieve
% this with judicious use of "mod" with 1.8.
entry.Value = mod(entry.Value+0.01,1.8);
val = entry.Value;
if val>0.9
    % Moving backwards
    val = 1.8-val;
end
psize = entry.ProgressSize;
startIdx = max( 1, round( val*psize(1) ) );
endIdx = max( 1, round( (val+0.1)*psize(1) ) );
barLength = endIdx - startIdx + 1;

% Create the image
bgim = entry.BackgroundCData(:,ones( 1, psize(1) ),:);
barim = iMakeBarImage(entry.CData, 1, barLength);
bgim(:,startIdx:endIdx,:) = barim;

% Put it into the widget
entry.BarCData = bgim;
set( entry.Progress, 'CData', bgim );
end % iUpdateBusyEntry


%-------------------------------------------------------------------------%
function barim = iMakeBarImage(strip, startIdx, endIdx)
shadow1_weight = 0.4;
shadow2_weight = 0.7;
barLength = endIdx - startIdx + 1;
% Repmat is the obvious way to fill the bar, but BSXFUN is often
% faster. Indexing is obscure but faster still.
barim = strip(:,ones(1, barLength),:);
% Add highlight to the start of the bar
if startIdx <= 2 && barLength>=2
    barim(:,1,:) = 255 - shadow1_weight*(255-strip);
    barim(:,2,:) = 255 - shadow2_weight*(255-strip);
end
% Add shadow to the end of the bar
if endIdx>=4 && barLength>=2
    barim(:,end,:) = shadow1_weight*strip;
    barim(:,end-1,:) = shadow2_weight*strip;
end
end % iMakeBarImage

%-------------------------------------------------------------------------%
function iCloseFigure( fig, evt ) %#ok<INUSD>
% Closing the figure just makes it invisible
set( fig, 'Visible', 'off' );
end % iCloseFigure

%-------------------------------------------------------------------------%
function iDeleteFigure( fig )
% Actually destroy the figure
busyTimer = getappdata( fig, 'BusyTimer' );
stop( busyTimer );
delete( busyTimer );
delete( fig );
end % iDeleteFigure

%-------------------------------------------------------------------------%
function iRedraw( fig, evt ) %#ok<INUSD>
entries = getappdata( fig, 'ProgressEntries' );
fobj = handle( fig );
p = fobj.Position;
% p = get( fig, 'Position' );
border = 5;
textheight = 16;
barheight = 16;
panelheight = 10;
N = max( 1, numel( entries ) );

% Check the height is correct
heightperentry = textheight+barheight+panelheight;
requiredheight = 2*border + N*heightperentry - panelheight;
if ~isequal( p(4), requiredheight )
    p(2) = p(2) + p(4) - requiredheight;
    p(4) = requiredheight;
    % In theory setting the position should re-trigger this callback, but
    % in practice it doesn't, probably because we aren't calling "drawnow".
    set( fig, 'Position', p )
end
ypos = p(4) - border;
width = p(3) - 2*border;
setappdata( fig, 'DefaultProgressBarSize', [width barheight] );

for ii=1:numel( entries )
    set( entries(ii).LabelText, 'Position', [border ypos-textheight width*0.75 textheight] );
    set( entries(ii).ETAText, 'Position', [border+width*0.75 ypos-textheight width*0.25 textheight] );
    ypos = ypos - textheight;
    if entries(ii).CanCancel
        set( entries(ii).Progress, 'Position', [border ypos-barheight width-barheight+1 barheight] );
        entries(ii).ProgressSize = [width-barheight barheight];
        set( entries(ii).CancelButton, 'Visible', 'on', 'Position', [p(3)-border-barheight ypos-barheight barheight barheight] );
    else
        set( entries(ii).Progress, 'Position', [border ypos-barheight width+1 barheight] );
        entries(ii).ProgressSize = [width barheight];
        set( entries(ii).CancelButton, 'Visible', 'off' );
    end
    ypos = ypos - barheight;
    set( entries(ii).Panel, 'Position', [-500 ypos-500-panelheight/2 p(3)+1000 500] );
    ypos = ypos - panelheight;
    entries(ii) = iUpdateEntry( entries(ii), true );
end
setappdata( fig, 'ProgressEntries', entries );
end % iRedraw

function cdata = iMakeCross( sz )
% Create a cross-shape icon of size sz*sz*3

cdata = diag(ones(sz,1),0) + diag(ones(sz-1,1),1) + diag(ones(sz-1,1),-1);
cdata = cdata + flip(cdata,2);

% Convert zeros to nans (transparent) and non-zeros to zero (black)
cdata(cdata == 0) = nan;
cdata(~isnan(cdata)) = 0;

% Convert to RGB
cdata = cat( 3, cdata, cdata, cdata );
end % iMakeCross


function iTimerFcn(fig)
% Timer callback for updating stuff every so often
entries = getappdata( fig, 'ProgressEntries' );
for ii=1:numel(entries)
    if entries(ii).Busy
        entries(ii) = iUpdateBusyEntry(entries(ii));
    end
end
setappdata( fig, 'ProgressEntries', entries );
end % iTimerFcn
