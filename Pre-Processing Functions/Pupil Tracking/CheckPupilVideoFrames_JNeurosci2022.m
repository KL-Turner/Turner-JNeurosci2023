function [] = CheckPupilVideoFrames_JNeurosci2022(procDataFileID)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Manually check the video quality of eye camera data
%________________________________________________________________________________________________________________________

ROIFileDir = dir('*_PupilData.mat');
ROIFileName = {ROIFileDir.name}';
ROIFileID = char(ROIFileName);
load(ROIFileID);
load(procDataFileID)
if isfield(ProcData.data.Pupil,'frameCheck') == false
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
    fileSize = ftell(fid); % calculate file size
    fseek(fid,0,'bof'); % find the begining of video frames
    imageHeight = ProcData.notes.pupilCamPixelHeight;
    imageWidth = ProcData.notes.pupilCamPixelWidth;
    pixelsPerFrame = imageWidth*imageHeight;
    skippedPixels = pixelsPerFrame;
    nFrames = floor(fileSize/(pixelsPerFrame));
    nFramesToRead_A = 1:5;
    nFramesToRead_B = (nFrames - 4):nFrames;
    imageStack = zeros(200,200,(length(nFramesToRead_A) + length(nFramesToRead_B)));
    % first 5 frames of video
    cc = 1;
    for dd = 1:length(nFramesToRead_A)
        fseek(fid,(nFramesToRead_A(dd) - 1)*skippedPixels,'bof');
        z = fread(fid,pixelsPerFrame,'*uint8','b');
        img = reshape(z(1:pixelsPerFrame),imageWidth,imageHeight);
        if isfield(PupilData,'resizePosition') == true
            imageStack(:,:,cc) = imcrop(flip(imrotate(img,-90),2),PupilData.resizePosition{1,idx});
        else
            imageStack(:,:,cc) = flip(imrotate(img,-90),2);
        end
        cc = cc + 1;
    end
    % last 5 frames of video
    for ee = 1:length(nFramesToRead_B)
        fseek(fid,(nFramesToRead_B(ee) - 1)*skippedPixels,'bof');
        z = fread(fid,pixelsPerFrame,'*uint8','b');
        img = reshape(z(1:pixelsPerFrame),imageWidth,imageHeight);
        if isfield(PupilData,'resizePosition') == true
            imageStack(:,:,cc) = imcrop(flip(imrotate(img,-90),2),PupilData.resizePosition{1,idx});
        else
            imageStack(:,:,cc) = flip(imrotate(img,-90),2);
        end
        cc = cc + 1;
    end
    % figure showing 10 frames
    imageCheck = figure;
    sgtitle([animalID strrep(fileID,'_',' ')])
    for ff = 1:size(imageStack,3)
        subplot(2,5,ff)
        imagesc(imageStack(:,:,ff))
        colormap gray
        axis image
        axis off
    end
    % request user input for this file
    check = false;
    while check == false
        keepFigure = input('Is eye data good for this session? (y/n): ','s'); disp(' ')
        if strcmp(keepFigure,'y') == true || strcmp(keepFigure,'n') == true
            ProcData.data.Pupil.frameCheck = keepFigure;
            save(procDataFileID,'ProcData')
            % save the figure to directory.
            [pathstr,~,~] = fileparts(cd);
            dirpath = [pathstr '/Figures/Pupil Frame Check/'];
            if ~exist(dirpath,'dir')
                mkdir(dirpath);
            end
            savefig(imageCheck,[dirpath animalID '_' fileID '_FrameCheck']);
            close(imageCheck)
            check = true;
        end
    end
end

end

