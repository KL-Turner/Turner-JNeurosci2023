function [ROIs] = PlaceGCaMP_ROIs_JNeurosci2022(animalID,fileID,ROIs,lensMag)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Analyze the cross-correlation between gamma-band power and each pixel to properly place a circular 1 mm ROI
%________________________________________________________________________________________________________________________

strDay = ConvertDate_JNeurosci2022(fileID);
fileDate = fileID(1:6);
% determine which ROIs to draw based on imaging type
hem = {'LH','RH','frontalLH','frontalRH'};
% extract the pixel values from the window ROIs
% character list of all ProcData files
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
% character list of all WindowCam files
windowDataFileStruct = dir('*_WindowCam.bin');
windowDataFiles = {windowDataFileStruct.name}';
windowDataFileIDs = char(windowDataFiles);
bb = 1;
for aa = 1:size(procDataFileIDs)
    procDataFileID = procDataFileIDs(aa,:);
    [~,procfileDate,~] = GetFileInfo_JNeurosci2022(procDataFileID);
    windowDataFileID = windowDataFileIDs(aa,:);
    if strcmp(procfileDate,fileDate) == true
        procDataFileList(bb,:) = procDataFileID;
        windowDataFileList(bb,:) = windowDataFileID;
        bb = bb + 1;
    end
end
for qq = 1:size(procDataFileList,1)
    disp(['Verifying first frame color from file (' num2str(qq) '/' num2str(size(procDataFileList,1)) ')']); disp(' ')
    load(procDataFileList(qq,:));
    imageHeight = ProcData.notes.CBVCamPixelHeight;
    imageWidth = ProcData.notes.CBVCamPixelWidth;
    pixelsPerFrame = imageWidth*imageHeight;
    % open the file, get file size, back to the begining
    fid = fopen(windowDataFileList(qq,:));
    fseek(fid,0,'eof');
    fseek(fid,0,'bof');
    % identify the number of frames to read. Each frame has a previously defined width and height (as inputs), along with a grayscale "depth" of 2"
    nFramesToRead = 10;
    % pre-allocate memory
    frames = cell(1,nFramesToRead);
    for n = 1:nFramesToRead
        z = fread(fid,pixelsPerFrame,'*int16','b');
        img = reshape(z(1:pixelsPerFrame),imageWidth,imageHeight);
        frames{n} = rot90(img',2);
    end
    gcampCheck = figure;
    frames = frames(1:end);
    for xx = 1:10
        subplot(2,5,xx)
        imagesc(frames{1,xx})
        axis image
        colormap gray
    end
    contCheck = false;
    while contCheck == false
        drawnow
        if isfield(ProcData.notes,'blueFrames') == true
            gcampFrames = ProcData.notes.blueFrames;
        else
            gcampFrames = input('Which index are blue LED frames (1,2,3): '); disp(' ')
        end
        if gcampFrames == 1
            if qq == 1
                roiFrame = frames{3};
            end
            ProcData.notes.blueFrames = 1;
            ProcData.notes.redFrames = 2;
            ProcData.notes.greenFrames = 3;
            save(procDataFileIDs(qq,:),'ProcData')
            contCheck = true;
        elseif gcampFrames == 2
            if qq == 1
                roiFrame = frames{1};
            end
            ProcData.notes.blueFrames = 2;
            ProcData.notes.redFrames = 3;
            ProcData.notes.greenFrames = 1;
            save(procDataFileIDs(qq,:),'ProcData')
            contCheck = true;
        elseif gcampFrames == 3
            if qq == 1
                roiFrame = frames{2};
            end
            ProcData.notes.blueFrames = 3;
            ProcData.notes.redFrames = 1;
            ProcData.notes.greenFrames = 2;
            save(procDataFileIDs(qq,:),'ProcData')
            contCheck = true;
        end
    end
    close(gcampCheck)
    fclose('all');
end
% determine the proper size of the ROI based on camera/lens magnification
if strcmpi(lensMag,'0.75X') == true
    circRadius = 7.5; % pixels to be 1 mm in diameter
elseif strcmpi(lensMag,'1.0X') == true
    circRadius = 10;
elseif strcmpi(lensMag,'1.5X') == true
    circRadius = 15;
elseif strcmpi(lensMag,'2.0X') == true
    circRadius = 20;
elseif strcmpi(lensMag,'2.5X') == true
    circRadius = 25;
elseif strcmpi(lensMag,'3.0X') == true
    circRadius = 30;
end
if imageWidth == 128
    % determine the proper size of the ROI based on camera/lens magnification
    circRadius = circRadius/2; % pixels to be 1 mm in diameter
end
% place circle along the most correlation region of each hemisphere
for f = 1:length(hem)
    % generate image
    isok = false;
    while isok == false
        windowFig = figure;
        imagesc(roiFrame)
        title([animalID ' ' hem{1,f} ' ROI'])
        xlabel('Image size (pixels)')
        ylabel('Image size (pixels)')
        colormap gray
        colorbar
        axis image
        disp(['Move the ROI over the desired region for ' hem{1,f}]); disp(' ')
        drawnow
        circ = drawcircle('Center',[0,0],'Radius',circRadius,'Color','r');
        checkCircle = input('Is the ROI okay? (y/n): ','s'); disp(' ')
        circPosition = round(circ.Center);
        if strcmpi(checkCircle,'y') == true
            isok = true;
            ROIs.([hem{1,f} '_' strDay]).circPosition = circPosition;
            ROIs.([hem{1,f} '_' strDay]).circRadius = circRadius;
        end
        delete(windowFig);
    end
end
% check final image
fig = figure;
imagesc(roiFrame)
hold on;
drawcircle('Center',ROIs.(['LH_' strDay]).circPosition,'Radius',ROIs.(['LH_' strDay]).circRadius,'Color','r');
drawcircle('Center',ROIs.(['RH_' strDay]).circPosition,'Radius',ROIs.(['RH_' strDay]).circRadius,'Color','r');
drawcircle('Center',ROIs.(['frontalLH_' strDay]).circPosition,'Radius',ROIs.(['LH_' strDay]).circRadius,'Color','r');
drawcircle('Center',ROIs.(['frontalRH_' strDay]).circPosition,'Radius',ROIs.(['RH_' strDay]).circRadius,'Color','r');
title([animalID ' final ROI placement'])
xlabel('Image size (pixels)')
ylabel('Image size (pixels)')
colormap gray
colorbar
axis image
caxis([0,2^ProcData.notes.CBVCamBitDepth])
savefig(fig,[animalID '_' strDay '_ROIs.fig'])

end
