function [imageStack] = GetCBVFrameSubset_JNeurosci2023(filename,imageHeight,imageWidth,frameInds)
%________________________________________________________________________________________________________________________
% Edited by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%
% Purpse: Reads in camera images from a binary file with defined width and height and at defined positions in time.
%________________________________________________________________________________________________________________________

pixelsPerFrame = imageWidth*imageHeight; % number to give to fread along with 16-bit pixel depth flag
skippedPixels = pixelsPerFrame*2; % multiply by two because there are 16 bits (2 bytes) per pixel
numFrames = length(frameInds);
% open the file, get file size, back to the begining
fid = fopen(filename);
% handle Error
if fid == -1
    error(wraptext(['Error. ReadDalsaBinary_Matrix: fopen.m cannot open ' filename]))
end
% pre-allocate memory
imageStack = NaN*ones(imageHeight,imageWidth,numFrames);
% loop over each frame
for n = 1:numFrames
    fseek(fid,frameInds(n)*skippedPixels,'bof');
    z = fread(fid,pixelsPerFrame,'*int16','b');
    % convert linear array into a 256x256x1 frame
    img = reshape(z,imageHeight,imageWidth);
    % orient the frame so that rostral is up
    imageStack(:,:,n) = rot90(img',2);
end
fclose('all');

end

