%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: determine mm per pixel for eye camera
%________________________________________________________________________________________________________________________

A = imread('1mm_PupilCam_scale.png');
figure;
imagesc(A)
colormap gray
axis image
axis off
line = drawline;
linePosition = line.Position;
lineLength = linePosition(2,1) - linePosition(1,1);
mmPerPixel = 1/lineLength;
% mmPerPixel = 0.018;

