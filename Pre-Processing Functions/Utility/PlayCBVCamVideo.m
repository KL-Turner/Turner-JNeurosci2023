%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: 
%________________________________________________________________________________________________________________________
%
%   Inputs: 
%
%   Outputs:        
%
%   Last Revised:    
%________________________________________________________________________________________________________________________

clear
clc

% User inputs for file information
windowCamFileID = uigetfile('*_WindowCam.bin','MultiSelect','off');
animalID = input('Input the animal ID: ', 's'); disp(' ')
rawDataFileID = [animalID '_' windowCamFileID(1:end - 14) '_RawData.mat'];

disp(['Loading relevant file information from ' rawDataFileID '...']); disp(' ')
try
    load(rawDataFileID)
catch
    disp([rawDataFileID ' does not appear to be in the current file path']); disp(' ')
    return
end

trialDuration = RawData.notes.trialDuration_sec;
disp([windowCamFileID ' is ' num2str(trialDuration) ' seconds long.']); disp(' ')
startTime = input('Input the desired start time (sec): '); disp(' ')
endTime = input('Input the desired end time (sec): '); disp(' ')

if startTime >= trialDuration || startTime < 0
    disp(['A start time of  ' num2str(startTime) ' is not a valid input']); disp(' ')
    return
elseif endTime > trialDuration || endTime <= startTime || endTime <= 0
    disp(['An end time of  ' num2str(startTime) ' is not a valid input']); disp(' ')
    return
end

imageHeight = RawData.notes.CBVCamPixelHeight;                                                                                                            
imageWidth = RawData.notes.CBVCamPixelWidth;
Fs = RawData.notes.CBVCamSamplingRate;

frameStart = floor(startTime)*Fs;
frameEnd = floor(endTime)*Fs;         
frameInds = frameStart:frameEnd;

 % Obtain subset of desired frames - normalize by an artificial baseline
frames = GetCBVFrameSubset_IOS_eLife2020(windowCamFileID,imageHeight,imageWidth,frameInds);
baselineFrame = mean(frames,3);

%% Create a figure to show the baseline frame in color and grey-scale
figure;
imagesc(frames(:,:,1));
colormap('gray');
title('Grey-scale first frame');
xlabel('width (pixels)');
ylabel('height (pixels)');
axis image;
caxis([0 2^12])

%% Create implay movie for the desired timeframe
normFrames = zeros(size(frames));
for a = 1:size(frames,3)
    disp(['Creating image stack: (' num2str(a) '/' num2str(size(frames,3)) ')']); disp(' ')
    normFrames(:,:,a) = frames(:,:,a)./baselineFrame;   % Normalize by baseline
end

handle = implay(normFrames,Fs);
handle.Visual.ColorMap.UserRange = 1; 
handle.Visual.ColorMap.UserRangeMin = .95; 
handle.Visual.ColorMap.UserRangeMax = 1.05;

Prompt = msgbox('Warning: May need to edit implay colormap range for best results');
