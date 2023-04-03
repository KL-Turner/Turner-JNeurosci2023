function [] = CheckPupilBlinks_JNeurosci2023(procDataFileID)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Manually verify blinking indeces
%________________________________________________________________________________________________________________________

ROIFileDir = dir('*_PupilData.mat');
ROIFileName = {ROIFileDir.name}';
ROIFileID = char(ROIFileName);
load(ROIFileID);
load(procDataFileID)
if strcmp(ProcData.data.Pupil.frameCheck,'y') == true
    if isfield(ProcData.data.Pupil,'blinkCheckComplete') == false || strcmp(ProcData.data.Pupil.blinkCheckComplete,'n') == true
        % load files and extract video information
        [~,fileDate,fileID] = GetFileInfo_JNeurosci2023(procDataFileID);
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
        nFramesToRead = ProcData.data.Pupil.blinkInds;
        imageStackA = zeros(200,200,length(nFramesToRead));
        imageStackB = zeros(200,200,length(nFramesToRead));
        imageStackC = zeros(200,200,length(nFramesToRead));
        imageStackD = zeros(200,200,length(nFramesToRead));
        imageStackE = zeros(200,200,length(nFramesToRead));
        % first 5 frames of video
        for dd = 1:length(nFramesToRead)
            try
                % frame - 2
                fseek(fid,(nFramesToRead(dd) - 3)*skippedPixels,'bof');
                z = fread(fid,pixelsPerFrame,'*uint8','b');
                img = reshape(z(1:pixelsPerFrame),imageWidth,imageHeight);
                if isfield(PupilData,'resizePosition') == true
                    imageStackA(:,:,dd) = imcrop(flip(imrotate(img,-90),2),PupilData.resizePosition{1,idx});
                else
                    imageStackA(:,:,dd) = flip(imrotate(img,-90),2);
                end
                % frame - 1
                fseek(fid,(nFramesToRead(dd) - 2)*skippedPixels,'bof');
                z = fread(fid,pixelsPerFrame,'*uint8','b');
                img = reshape(z(1:pixelsPerFrame),imageWidth,imageHeight);
                if isfield(PupilData,'resizePosition') == true
                    imageStackB(:,:,dd) = imcrop(flip(imrotate(img,-90),2),PupilData.resizePosition{1,idx});
                else
                    imageStackB(:,:,dd) = flip(imrotate(img,-90),2);
                end
                % frame
                fseek(fid,(nFramesToRead(dd) - 1)*skippedPixels,'bof');
                z = fread(fid,pixelsPerFrame,'*uint8','b');
                img = reshape(z(1:pixelsPerFrame),imageWidth,imageHeight);
                if isfield(PupilData,'resizePosition') == true
                    imageStackC(:,:,dd) = imcrop(flip(imrotate(img,-90),2),PupilData.resizePosition{1,idx});
                else
                    imageStackC(:,:,dd) = flip(imrotate(img,-90),2);
                end
                % frame + 1
                fseek(fid,(nFramesToRead(dd))*skippedPixels,'bof');
                z = fread(fid,pixelsPerFrame,'*uint8','b');
                img = reshape(z(1:pixelsPerFrame),imageWidth,imageHeight);
                if isfield(PupilData,'resizePosition') == true
                    imageStackD(:,:,dd) = imcrop(flip(imrotate(img,-90),2),PupilData.resizePosition{1,idx});
                else
                    imageStackD(:,:,dd) = flip(imrotate(img,-90),2);
                end
                % frame + 2
                fseek(fid,(nFramesToRead(dd) + 1)*skippedPixels,'bof');
                z = fread(fid,pixelsPerFrame,'*uint8','b');
                img = reshape(z(1:pixelsPerFrame),imageWidth,imageHeight);
                if isfield(PupilData,'resizePosition') == true
                    imageStackE(:,:,dd) = imcrop(flip(imrotate(img,-90),2),PupilData.resizePosition{1,idx});
                else
                    imageStackE(:,:,dd) = flip(imrotate(img,-90),2);
                end
            catch
                imageStackA(:,:,dd) = NaN(200,200);
                imageStackB(:,:,dd) = NaN(200,200);
                % frame
                fseek(fid,(nFramesToRead(dd) - 2)*skippedPixels,'bof');
                z = fread(fid,pixelsPerFrame,'*uint8','b');
                img = reshape(z(1:pixelsPerFrame),imageWidth,imageHeight);
                if isfield(PupilData,'resizePosition') == true
                    imageStackC(:,:,dd) = imcrop(flip(imrotate(img,-90),2),PupilData.resizePosition{1,idx});
                else
                    imageStackC(:,:,dd) = flip(imrotate(img,-90),2);
                end
                imageStackD(:,:,dd) = NaN(200,200);
                imageStackE(:,:,dd) = NaN(200,200);
            end
        end
        % request user input for this file
        keepBlink = 'n';
        for ee = 1:length(nFramesToRead)
            if ee > 1
                timeDif = nFramesToRead(ee) - nFramesToRead(ee - 1);
                if timeDif > 6 || strcmpi(keepBlink,'n') == true
                    check = false;
                    while check == false
                        % figure showing 10 frames
                        imageCheck = figure;
                        subplot(1,5,1)
                        imagesc(imageStackA(:,:,ee))
                        colormap gray
                        axis image
                        axis off
                        subplot(1,5,2)
                        imagesc(imageStackB(:,:,ee))
                        colormap gray
                        axis image
                        axis off
                        subplot(1,5,3)
                        imagesc(imageStackC(:,:,ee))
                        colormap gray
                        axis image
                        axis off
                        subplot(1,5,4)
                        imagesc(imageStackD(:,:,ee))
                        colormap gray
                        axis image
                        axis off
                        subplot(1,5,5)
                        imagesc(imageStackE(:,:,ee))
                        colormap gray
                        axis image
                        axis off
                        imageCheck.WindowState = 'maximized';
                        keepBlink = input(['(' num2str(ee) '/' num2str(size(imageStackA,3)) ') Is this a Blink [t = ' num2str(nFramesToRead(ee)) ']? (y/n): '],'s'); disp(' ')
                        close(imageCheck)
                        if strcmp(keepBlink,'y') == true || strcmp(keepBlink,'n') == true
                            ProcData.data.Pupil.blinkCheck{1,ee} = keepBlink;
                            check = true;
                        end
                    end
                else
                    ProcData.data.Pupil.blinkCheck{1,ee} = ProcData.data.Pupil.blinkCheck{1,ee - 1};
                end
            elseif ee == 1
                check = false;
                while check == false
                    % figure showing 10 frames
                    imageCheck = figure;
                    subplot(1,5,1)
                    imagesc(imageStackA(:,:,ee))
                    colormap gray
                    axis image
                    axis off
                    subplot(1,5,2)
                    imagesc(imageStackB(:,:,ee))
                    colormap gray
                    axis image
                    axis off
                    subplot(1,5,3)
                    imagesc(imageStackC(:,:,ee))
                    colormap gray
                    axis image
                    axis off
                    subplot(1,5,4)
                    imagesc(imageStackD(:,:,ee))
                    colormap gray
                    axis image
                    axis off
                    subplot(1,5,5)
                    imagesc(imageStackE(:,:,ee))
                    colormap gray
                    axis image
                    axis off
                    imageCheck.WindowState = 'maximized';
                    keepBlink = input(['(' num2str(ee) '/' num2str(size(imageStackA,3)) ') Is this a Blink [t = ' num2str(nFramesToRead(ee)) ']? (y/n): '],'s'); disp(' ')
                    close(imageCheck)
                    if strcmp(keepBlink,'y') == true || strcmp(keepBlink,'n') == true
                        ProcData.data.Pupil.blinkCheck{1,ee} = keepBlink;
                        check = true;
                    end
                end
            end
        end
        ProcData.data.Pupil.blinkCheckComplete = 'y';
        save(procDataFileID,'ProcData')
    end
elseif strcmp(ProcData.data.Pupil.frameCheck,'n') == true
    for bb = 1:length(ProcData.data.Pupil.blinkInds)
        ProcData.data.Pupil.blinkCheck{1,bb} = 'n';
    end
    ProcData.data.Pupil.blinkCheckComplete = 'y';
    save(procDataFileID,'ProcData')
end

end
