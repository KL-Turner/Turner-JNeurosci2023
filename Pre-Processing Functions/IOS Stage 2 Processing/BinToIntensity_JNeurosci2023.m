function [refl] = BinToIntensity_JNeurosci2023(ROImask,frames)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%
% Purpose: Apply image mask of an ROI to each frame of the stack and extract the mean of the valid pixels
%________________________________________________________________________________________________________________________

nFrames = length(frames);
refl = zeros(1,nFrames);
% apply image mask to each frame of the stack
for n = 1:nFrames
    mask = ROImask.*double(frames{n});
    refl(n) = mean(nonzeros(mask));
end

end
