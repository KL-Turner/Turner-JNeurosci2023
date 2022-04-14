function [frames] = ReadDalsaBinary_JNeurosci2022(animalID,fileID)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%
% Purpose: Extract the frames from the desired WindowCam file.
%________________________________________________________________________________________________________________________

rawDataFileID = [animalID '_' fileID(1:end - 13) 'RawData.mat'];
load(rawDataFileID)
imageHeight = RawData.notes.CBVCamPixelHeight;
imageWidth = RawData.notes.CBVCamPixelWidth;
pixelsPerFrame = imageWidth*imageHeight;
% open the file, get file size, back to the begining
fid = fopen(fileID);
fseek(fid,0,'eof');
fileSize = ftell(fid);
fseek(fid,0,'bof');
% identify the number of frames to read. Each frame has a previously defined width and height (as inputs), along with a grayscale "depth" of 2"
nFramesToRead = floor(fileSize/(2*pixelsPerFrame));
% preallocate memory
frames = cell(1,nFramesToRead);
for n = 1:nFramesToRead
    z = fread(fid,pixelsPerFrame,'int16','b');
    img = reshape(z(1:pixelsPerFrame),imageWidth,imageHeight);
    frames{n} = rot90(img',2);
end
fclose('all');

end
