function [] = Fig1_JNeurosci2022(rootFolder,saveFigs,delim)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose:
%________________________________________________________________________________________________________________________
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpose:
%________________________________________________________________________________________________________________________

%% load data
dataStructure = 'Results_Example.mat';
load(dataStructure)
%% tracking algorithm images
% subplot for eye ROI
Fig1A = figure('Name','Figure Panel 1 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
subplot(2,2,1)
imagesc(Results_Example.workingImg)
hold on;
x1 = plot(Results_Example.x12,Results_Example.y12,'color','r','LineWidth',1');
title('ROI to measure changes in pupil area')
legend(x1,'eye ROI')
colormap gray
axis image
axis off
% subplot for ROI histrogram and threshold
subplot(2,2,2)
Results_Example.pupilHist = histogram(Results_Example.threshImg((Results_Example.threshImg ~= 0)),'BinEdges',Results_Example.pupilHistEdges,'Normalization','Probability');
hold on;
plot(Results_Example.pupilHist.BinEdges,Results_Example.normFit,'r','LineWidth',2);
xline(Results_Example.intensityThresh,'--m','LineWidth',1);
title('Histogram of image pixel intensity')
xlabel('Pixel intensity');
ylabel('Bin Count');
legend({'Normalized bin counts','MLE fit of data','Pupil intensity threshold'},'Location','northwest');
xlim([0,256]);
axis square
set(gca,'box','off')
% subplot for radon transform
subplot(2,2,3)
imagesc(Results_Example.saveRadonImg)
title('Radon transform back to image space')
colormap gray
caxis([-0.01,0.05])
axis image
axis off
% subplot for measured pupil area
subplot(2,2,4)
imagesc(Results_Example.overlay(:,:,:,1));
title('Calculated pupil area')
colormap gray
axis image
axis off
% save figure
if saveFigs == true
    dirpath = [rootFolder delim 'Summary Figures and Structures' delim 'Figure Panels' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig1A,[dirpath 'Fig1A_JNeurosci2022']);
    set(Fig1A,'PaperPositionMode','auto');
    print('-vector','-dpdf','-fillpage',[dirpath 'Fig1A_JNeurosci2022'])
end
%% example pupil/eye images
Fig1B = figure('Name','Figure Panel 1 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
sgtitle('Representative eye/blink images')
subplot(1,7,1)
imagesc(Results_Example.images(:,:,1));
title(['t = ' num2str(round(1200/Results_Example.dsFs)) ' sec'])
colormap gray
axis image
axis off
subplot(1,7,2)
imagesc(Results_Example.images(:,:,2));
title(['t = ' num2str(round(4200/Results_Example.dsFs)) ' sec'])
colormap gray
axis image
axis off
subplot(1,7,3)
imagesc(Results_Example.images(:,:,3));
title(['t = ' num2str(round(7866/Results_Example.dsFs)) ' sec'])
colormap gray
axis image
axis off
subplot(1,7,4)
imagesc(Results_Example.images(:,:,4));
title(['t = ' num2str(round(13200/Results_Example.dsFs)) ' sec'])
colormap gray
axis image
axis off
subplot(1,7,5)
imagesc(Results_Example.images(:,:,5));
title(['t = ' num2str(round(18510/Results_Example.dsFs)) ' sec'])
colormap gray
axis image
axis off
subplot(1,7,6)
imagesc(Results_Example.images(:,:,6));
title(['t = ' num2str(round(23458/Results_Example.dsFs)) ' sec'])
colormap gray
axis image
axis off
subplot(1,7,7)
imagesc(Results_Example.images(:,:,7));
title(['t = ' num2str(round(26332/Results_Example.dsFs)) ' sec'])
colormap gray
axis image
axis off
% save figure
if saveFigs == true
    dirpath = [rootFolder delim 'Summary Figures and Structures' delim 'Figure Panels' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig1B,[dirpath 'Fig1B_JNeurosci2022']);
    set(Fig1B,'PaperPositionMode','auto');
    print('-vector','-dpdf','-fillpage',[dirpath 'Fig1B_JNeurosci2022'])
end
%% example trial
Fig1C =  figure('Name','Figure Panel 1 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
sgtitle('Example trial')
% pupil
ax12 = subplot(6,1,[1,2]);
p1 = plot((1:length(Results_Example.filtPupilDiameter))/Results_Example.dsFs,Results_Example.filtPupilDiameter,'color',colors('black'));
blinkInds = find(Results_Example.blinkTimes > 1); 
Results_Example.blinkTimes(blinkInds) = max(Results_Example.filtPupilDiameter);
hold on;
s1 = scatter((1:length(Results_Example.blinkTimes))/Results_Example.dsFs,Results_Example.blinkTimes,'r');
x1 = xline(1200/Results_Example.dsFs,'g');
xline(4200/Results_Example.dsFs,'g')
xline(7866/Results_Example.dsFs,'g')
xline(13200/Results_Example.dsFs,'g')
xline(18510/Results_Example.dsFs,'g')
xline(23458/Results_Example.dsFs,'g')
xline(26332/Results_Example.dsFs,'g')
xlabel('Time (sec)')
ylabel('Diameter (mm)')
set(gca,'Xticklabel',[])
set(gca,'box','off')
xticks([0,60,120,180,240,300,360,420,480,540,600,660,720,780,840,900])
legend([p1,s1,x1],'Pupil Area','Blinks','Rep Imgs','Location','Northwest')
ax12.TickLength = [0.01,0.01];
% EMG and force sensor
ax3 = subplot(6,1,3);
p3 = plot((1:length(Results_Example.filtWhiskerAngle))/Results_Example.dsFs,-Results_Example.filtWhiskerAngle,'color',colors('black'),'LineWidth',0.5);
ylabel('Angle (deg)')
ylim([-10,50])
yyaxis right
p2 = plot((1:length(Results_Example.filtEMG))/Results_Example.dsFs,Results_Example.filtEMG,'color',colors('blue-violet'),'LineWidth',0.5);
ylabel('EMG pwr (a.u.)','rotation',-90,'VerticalAlignment','bottom')
ylim([-4,2.5])
legend([p2,p3],'Whisker Angle','EMG','Location','Northwest')
set(gca,'Xticklabel',[])
set(gca,'box','off')
xticks([0,60,120,180,240,300,360,420,480,540,600,660,720,780,840,900])
ax3.TickLength = [0.01,0.01];
ax3.YAxis(1).Color = colors('black');
ax3.YAxis(2).Color = colors('blue-violet');
% HbT
ax45 =subplot(6,1,[4,5]);
p4 = plot((1:length(Results_Example.filtRH_HbT))/Results_Example.dsFs,Results_Example.filtRH_HbT,'color',colors('black'),'LineWidth',1);
hold on
p5 = plot((1:length(Results_Example.filtLH_HbT))/Results_Example.dsFs,Results_Example.filtLH_HbT,'color',colors('blue-green'),'LineWidth',1);
ylabel('\Delta[HbT] (\muM)')
legend([p4,p5,],'LH HbT','RH HbT','Location','Northwest')
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
xticks([0,60,120,180,240,300,360,420,480,540,600,660,720,780,840,900])
ylim([-35,135])
ax45.TickLength = [0.01,0.01];
% hippocampal electrode spectrogram
ax6 = subplot(6,1,6);
Semilog_ImageSC(Results_Example.T,Results_Example.F,Results_Example.hippocampusNormS,'y')
axis xy
c6 = colorbar;
ylabel(c6,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
caxis([-100,100])
xlabel('Time (min)')
ylabel({'Hipp LFP','Freq (Hz)'})
set(gca,'box','off')
xticks([0,60,120,180,240,300,360,420,480,540,600,660,720,780,840,900])
xticklabels({'0','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15'})
ax6.TickLength = [0.01,0.01];
% axes properties
ax3Pos = get(ax3,'position');
ax6Pos = get(ax6,'position');
ax6Pos(3:4) = ax3Pos(3:4);
set(ax6,'position',ax6Pos);
% save figure
if saveFigs == true
    dirpath = [rootFolder delim 'Summary Figures and Structures' delim 'Figure Panels' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig1C,[dirpath 'Fig1C_JNeurosci2022']);
    % remove surface subplots because they take forever to render
    cla(ax6);
    set(ax6,'YLim',[1,99]);
    set(Fig1C,'PaperPositionMode','auto');
    print('-vector','-dpdf','-fillpage',[dirpath 'Fig1C_JNeurosci2022'])
    close(Fig1C)
    % subplot figure
    subplotImgs = figure('Name','Figure Panel 1 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
    % example 1 LH cortical LFP
    Semilog_ImageSC(Results_Example.T,Results_Example.F,Results_Example.hippocampusNormS,'y')
    caxis([-100,100])
    set(gca,'box','off')
    axis xy
    axis tight
    axis off
    xlim([0,900])
    print('-vector','-dtiffn',[dirpath 'Fig1_SpecImages_JNeurosci2022'])
    close(subplotImgs)
    % remake original figure
    figure('Name','Figure Panel 1 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
    sgtitle('Example trial')
    % pupil
    ax12 = subplot(6,1,[1,2]);
    p1 = plot((1:length(Results_Example.filtPupilDiameter))/Results_Example.dsFs,Results_Example.filtPupilDiameter,'color',colors('black'));
    hold on;
    s1 = scatter((1:length(Results_Example.blinkTimes))/Results_Example.dsFs,Results_Example.blinkTimes,'r');
    x1 = xline(1200/Results_Example.dsFs,'g');
    xline(4200/Results_Example.dsFs,'g')
    xline(7866/Results_Example.dsFs,'g')
    xline(13200/Results_Example.dsFs,'g')
    xline(18510/Results_Example.dsFs,'g')
    xline(23458/Results_Example.dsFs,'g')
    xline(26332/Results_Example.dsFs,'g')
    xlabel('Time (sec)')
    ylabel('Diameter (mm)')
    set(gca,'Xticklabel',[])
    set(gca,'box','off')
    xticks([0,60,120,180,240,300,360,420,480,540,600,660,720,780,840,900])
    legend([p1,s1,x1],'Pupil Area','Blinks','Rep Imgs','Location','Northwest')
    ax12.TickLength = [0.01,0.01];
    % EMG and force sensor
    ax3 = subplot(6,1,3);
    p3 = plot((1:length(Results_Example.filtWhiskerAngle))/Results_Example.dsFs,-Results_Example.filtWhiskerAngle,'color',colors('black'),'LineWidth',0.5);
    ylabel('Angle (deg)')
    ylim([-10,50])
    yyaxis right
    p2 = plot((1:length(Results_Example.filtEMG))/Results_Example.dsFs,Results_Example.filtEMG,'color',colors('blue-violet'),'LineWidth',0.5);
    ylabel('EMG pwr (a.u.)','rotation',-90,'VerticalAlignment','bottom')
    ylim([-4,2.5])
    legend([p2,p3],'Whisker Angle','EMG','Location','Northwest')
    set(gca,'Xticklabel',[])
    set(gca,'box','off')
    xticks([0,60,120,180,240,300,360,420,480,540,600,660,720,780,840,900])
    ax3.TickLength = [0.01,0.01];
    ax3.YAxis(1).Color = colors('black');
    ax3.YAxis(2).Color = colors('blue-violet');
    % HbT
    ax45 =subplot(6,1,[4,5]);
    p4 = plot((1:length(Results_Example.filtRH_HbT))/Results_Example.dsFs,Results_Example.filtRH_HbT,'color',colors('black'),'LineWidth',1);
    hold on
    p5 = plot((1:length(Results_Example.filtLH_HbT))/Results_Example.dsFs,Results_Example.filtLH_HbT,'color',colors('blue-green'),'LineWidth',1);
    ylabel('\Delta[HbT] (\muM)')
    legend([p4,p5,],'LH HbT','RH HbT','Location','Northwest')
    set(gca,'TickLength',[0,0])
    set(gca,'Xticklabel',[])
    set(gca,'box','off')
    xticks([0,60,120,180,240,300,360,420,480,540,600,660,720,780,840,900])
    ylim([-35,135])
    ax45.TickLength = [0.01,0.01];
    % hippocampal electrode spectrogram
    ax6 = subplot(6,1,6);
    Semilog_ImageSC(Results_Example.T,Results_Example.F,Results_Example.hippocampusNormS,'y')
    axis xy
    c6 = colorbar;
    ylabel(c6,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
    caxis([-100,100])
    xlabel('Time (min)')
    ylabel({'Hipp LFP','Freq (Hz)'})
    set(gca,'box','off')
    xticks([0,60,120,180,240,300,360,420,480,540,600,660,720,780,840,900])
    xticklabels({'0','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15'})
    ax6.TickLength = [0.01,0.01];
    % axes properties
    ax3Pos = get(ax3,'position');
    ax6Pos = get(ax6,'position');
    ax6Pos(3:4) = ax3Pos(3:4);
    set(ax6,'position',ax6Pos);
end

end
