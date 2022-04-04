%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpose: Generate supplemental videos for Turner_Kederasetti_Gheres_Proctor_Costanzo_Drew_eLife2020
%________________________________________________________________________________________________________________________

zap;
dataStructure = 'Results_Example.mat';
load(dataStructure)
% movie file comparing processed with original data
if exist('VideoS1.mp4','file') == 2
    delete('VideoS1.mp4')
end
outputVideo = VideoWriter('VideoS1.mp4','MPEG-4');
fps = 30;   % default fps from video acquisition
speedUp = 2;   % speed up by factor of
outputVideo.FrameRate = fps*speedUp;
open(outputVideo);
%%
for aa = 1:size(Results_Example.overlay,4)
    fig = figure;
    imagesc(Results_Example.overlay(:,:,:,aa));
    title('Pupil tracking overlay')
    colormap gray
    axis image
    axis off
    F = getframe(gcf);
    I = frame2im(F);
    close(fig)
    frameSec = round(rem(aa/fps,60),3);
    frameMin = floor(aa/fps/60);
    secText = num2str(frameSec,'%05.2f');
    minText = num2str(frameMin,'%02.f');
    textStr = [minText ' min ' secText ' sec'];
    position = [650 705];
    boxColor = {'green'};
    RGB = insertText(I,position,textStr,'FontSize',24,'BoxOpacity',0,'TextColor','black');
    fig = figure;
    imshow(RGB)
    currentFrame = getframe(gcf);
    writeVideo(outputVideo,currentFrame);
    close(fig)
end
close(outputVideo)
