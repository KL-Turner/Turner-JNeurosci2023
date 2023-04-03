function [ROIs] = CreateBilateralROIs_JNeurosci2023(img,ROIname,animalID,ROIs)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%
% Purpose: Draw free-hand ROIs, typically over the cement for drift correction
%________________________________________________________________________________________________________________________

% create figure of the image frame
roiFig = figure;
imagesc(img)
colormap(gray)
axis image
xlabel('Caudal')
% draw ROI over the cement
disp(['Please select your region of interest for ' animalID ' ' ROIname '.']); disp(' ')
[~,xi,yi] = roipoly;
ROIs.(ROIname).xi = xi;
ROIs.(ROIname).yi = yi;
close(roiFig)

end
