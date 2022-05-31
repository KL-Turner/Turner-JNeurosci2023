function [angle] = WhiskerTrackerParallel_Turner2022(fileName)
%________________________________________________________________________________________________________________________
% Edited by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%
% Purpose: Analyze the changes in whisker position via the radon transform.
%________________________________________________________________________________________________________________________

% variable Setup
theta = -40:80; % angles used for radon
% import whisker movie
importStart = tic;
baslerFrames = ReadBinFileU8MatrixGradient_Turner2022([fileName '_WhiskerCam.bin'],350,30);
importTime = toc(importStart);
disp(['WhiskerTrackerParallel: Binary file import time was ' num2str(importTime) ' seconds.']); disp(' ')
% transfer the images to the GPU
gpuTrans1 = tic;
gpuFrame = gpuArray(baslerFrames);
gpuTransfer = toc(gpuTrans1);
disp(['WhiskerTrackerParallel: GPU transfer time was ' num2str(gpuTransfer) ' seconds.']); disp(' ')
% pre-allocate array of whisker angles, use NaN as a place holder
angle = NaN*ones(1,length(baslerFrames));
radonTime1 = tic;
for f = 1:(length(baslerFrames) - 1)
    % radon on individual frame
    [R,~] = radon(gpuFrame(:,:,f),theta);
    % get transformed image from GPU and calculate the variance
    colVar = var(gather(R));
    % sort the columns according to variance
    ordVar = sort(colVar);
    % choose the top 0.1*number columns which show the highest variance
    thresh = round(numel(ordVar)*0.9);
    sieve = gt(colVar,ordVar(thresh));
    % associate the columns with the corresponding whisker angle
    angles = nonzeros(theta.*sieve);
    % calculate the average of the whisker angles
    angle(f) = mean(angles);
end
radonTime = toc(radonTime1);
disp(['WhiskerTrackerParallel: Whisker Tracking time was ' num2str(radonTime) ' seconds.']); disp(' ')
inds = isnan(angle);
angle(inds) = [];

end
