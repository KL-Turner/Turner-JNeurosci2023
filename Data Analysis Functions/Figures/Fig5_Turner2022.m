function [AnalysisResults] = Fig5_Turner2022(rootFolder,saveFigs,delim,AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: Generate figures and supporting information for Figure Panel 5
%________________________________________________________________________________________________________________________

dataLocation = [rootFolder delim 'Analysis Structures'];
cd(dataLocation)
%% Pupil-HbT relationship
resultsStruct = 'Results_PupilHbTRelationship.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_PupilHbTRelationship);
behavFields = {'Awake','NREM','REM'};
% take data from each animal corresponding to the CBV-gamma relationship
data.HbTRel.catHbT = [];  data.HbTRel.catPupil = [];
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    for bb = 1:length(behavFields)
        behavField = behavFields{1,bb};
        if isfield(data.HbTRel.catHbT,behavField) == false
            data.HbTRel.catHbT.(behavField) = [];
            data.HbTRel.catPupil.(behavField) = [];
        end
        data.HbTRel.catHbT.(behavField) = cat(1,data.HbTRel.catHbT.(behavField),Results_PupilHbTRelationship.(animalID).(behavField).HbT);
        data.HbTRel.catPupil.(behavField) = cat(1,data.HbTRel.catPupil.(behavField),Results_PupilHbTRelationship.(animalID).(behavField).Pupil);
    end
end
%% Pupil-Gamma relationship
resultsStruct = 'Results_PupilGammaRelationship.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_PupilGammaRelationship);
behavFields = {'Awake','NREM','REM'};
% take data from each animal corresponding to the CBV-gamma relationship
data.GammaRel.catGamma = [];  data.GammaRel.catPupil = [];
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    for bb = 1:length(behavFields)
        behavField = behavFields{1,bb};
        if isfield(data.GammaRel.catGamma,behavField) == false
            data.GammaRel.catGamma.(behavField) = [];
            data.GammaRel.catPupil.(behavField) = [];
        end
        data.GammaRel.catGamma.(behavField) = cat(1,data.GammaRel.catGamma.(behavField),Results_PupilGammaRelationship.(animalID).(behavField).Gamma*100);
        data.GammaRel.catPupil.(behavField) = cat(1,data.GammaRel.catPupil.(behavField),Results_PupilGammaRelationship.(animalID).(behavField).Pupil);
    end
end
%% Sleep probability based on pupil mm diameter
resultsStruct = 'Results_SleepProbability.mat';
load(resultsStruct);
diameterAllCatMeans = Results_SleepProbability.diameterCatMeans;
awakeProbPerc = Results_SleepProbability.awakeProbPerc./100;
nremProbPerc = Results_SleepProbability.nremProbPerc./100;
remProbPerc = Results_SleepProbability.remProbPerc./100;
%% Figure
HbTawakeHist = figure;
h1 = histogram2(data.HbTRel.catPupil.Awake,data.HbTRel.catHbT.Awake,'DisplayStyle','tile','ShowEmptyBins','on','XBinedges',-5:0.025:3,'YBinedges',-25:2.5:125,'Normalization','probability');
h1Vals = h1.Values;
% RGB image for Awake
HbTawakeRGB = figure;
s = pcolor(-4.975:0.025:3,-22.5:2.5:125,h1Vals');
s.FaceColor = 'interp';
set(s,'EdgeColor','none');
n = 50;
R = linspace(1,0,n);
G = linspace(1,0,n);
B = linspace(1,0,n);
colormap(flipud([R(:),G(:),B(:)]));
cax = caxis;
caxis([cax(1),cax(2)/1.5])
axis off
h1Frame = getframe(gcf);
h1Img = frame2im(h1Frame);
close(HbTawakeHist)
close(HbTawakeRGB)
% histogram for NREM
HbTnremHist = figure;
h2 = histogram2(data.HbTRel.catPupil.NREM,data.HbTRel.catHbT.NREM,'DisplayStyle','tile','ShowEmptyBins','on','XBinedges',-5:0.025:3,'YBinedges',-25:2.5:125,'Normalization','probability');
h2Vals = h2.Values;
% RGB image for NREM
HbTnremRGB = figure;
s = pcolor(-4.975:0.025:3,-22.5:2.5:125,h2Vals');
s.FaceColor = 'interp';
set(s,'EdgeColor','none');
n = 50;
R = linspace(0,0,n);
G = linspace(1,0,n);
B = linspace(1,0,n);
colormap(flipud([R(:),G(:),B(:)]));
cax = caxis;
caxis([cax(1),cax(2)/1.5])
axis off
h2Frame = getframe(gcf);
h2Img = frame2im(h2Frame);
close(HbTnremHist)
close(HbTnremRGB)
% histogram for REM
HbTremHist = figure;
h3 = histogram2(data.HbTRel.catPupil.REM,data.HbTRel.catHbT.REM,'DisplayStyle','tile','ShowEmptyBins','on','XBinedges',-5:0.025:3,'YBinedges',-25:2.5:125,'Normalization','probability');
h3Vals = h3.Values;
% RGB image for REM
HbTRemRGB = figure;
s = pcolor(-4.975:0.025:3,-22.5:2.5:125,h3Vals');
s.FaceColor = 'interp';
set(s,'EdgeColor','none');
n = 50;
R = linspace(1,0,n);
G = linspace(0,0,n);
B = linspace(0,0,n);
colormap(flipud([R(:),G(:),B(:)]));
cax = caxis;
caxis([cax(1),cax(2)/1.5])
axis off
h3Frame = getframe(gcf);
h3Img = frame2im(h3Frame);
close(HbTremHist)
close(HbTRemRGB)
GammaAwakeHist = figure;
h4 = histogram2(data.HbTRel.catPupil.Awake,data.GammaRel.catGamma.Awake,'DisplayStyle','tile','ShowEmptyBins','on','XBinedges',-5:0.025:3,'YBinedges',-25:2.5:100,'Normalization','probability');
h4Vals = h4.Values;
% RGB image for Awake
GammaAwakeRGB = figure;
s = pcolor(-4.975:0.025:3,-22.5:2.5:100,h4Vals');
s.FaceColor = 'interp';
set(s,'EdgeColor','none');
n = 50;
R = linspace(1,0,n);
G = linspace(1,0,n);
B = linspace(1,0,n);
colormap(flipud([R(:),G(:),B(:)]));
cax = caxis;
caxis([cax(1),cax(2)/1.5])
axis off
h4Frame = getframe(gcf);
h4Img = frame2im(h4Frame);
close(GammaAwakeHist)
close(GammaAwakeRGB)
% histogram for NREM
GammaNremHist = figure;
h5 = histogram2(data.GammaRel.catPupil.NREM,data.GammaRel.catGamma.NREM,'DisplayStyle','tile','ShowEmptyBins','on','XBinedges',-5:0.025:3,'YBinedges',-25:2.5:100,'Normalization','probability');
h5Vals = h5.Values;
% RGB image for NREM
GammaNremRGB = figure;
s = pcolor(-4.975:0.025:3,-22.5:2.5:100,h5Vals');
s.FaceColor = 'interp';
set(s,'EdgeColor','none');
n = 50;
R = linspace(0,0,n);
G = linspace(1,0,n);
B = linspace(1,0,n);
colormap(flipud([R(:),G(:),B(:)]));
cax = caxis;
caxis([cax(1),cax(2)/1.5])
axis off
h5Frame = getframe(gcf);
h5Img = frame2im(h5Frame);
close(GammaNremHist)
close(GammaNremRGB)
% histogram for REM
GammaRemHist = figure;
h6 = histogram2(data.GammaRel.catPupil.REM,data.GammaRel.catGamma.REM,'DisplayStyle','tile','ShowEmptyBins','on','XBinedges',-5:0.025:3,'YBinedges',-25:2.5:100,'Normalization','probability');
h6Vals = h6.Values;
% RGB image for REM
GammaRemRGB = figure;
s = pcolor(-4.975:0.025:3,-22.5:2.5:100,h6Vals');
s.FaceColor = 'interp';
set(s,'EdgeColor','none');
n = 50;
R = linspace(1,0,n);
G = linspace(0,0,n);
B = linspace(0,0,n);
colormap(flipud([R(:),G(:),B(:)]));
cax = caxis;
caxis([cax(1),cax(2)/1.5])
axis off
h6Frame = getframe(gcf);
h6Img = frame2im(h6Frame);
close(GammaRemHist)
close(GammaRemRGB)
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'MATLAB Figures' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    %% axis for composite images
    Fig5A = figure('Name','Figure Panel 5 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
    subplot(1,2,1)
    img = imagesc(-4.975:0.025:3,-22.5:2.5:100,h4Vals');
    xlabel('Diameter (z-units)')
    ylabel('\DeltaP/P (%)')
    title('Pupil-Gamma axis template')
    set(gca,'box','off')
    axis square
    axis xy
    delete(img)
    subplot(1,2,2)
    img = imagesc(-4.975:0.025:3,-22.5:2.5:125,h1Vals');
    xlabel('Diameter (z-units)')
    ylabel('\Delta[HbT] (\muM)')
    title('Pupil-HbT axis template')
    set(gca,'box','off')
    axis square
    axis xy
    delete(img)
    set(Fig5A,'PaperPositionMode','auto');
    savefig(Fig5A,[dirpath 'Fig5A_Turner2022']);
    print('-vector','-dpdf','-fillpage',[dirpath 'Fig5A_Turner2022'])
    close(Fig5A)
    imwrite(h1Img,[dirpath 'Fig5_HbTAwake_Turner2022.png'])
    imwrite(h2Img,[dirpath 'Fig5_HbTNREM_Turner2022.png'])
    imwrite(h3Img,[dirpath 'Fig5_HbTREM_Turner2022.png'])
    imwrite(h4Img,[dirpath 'Fig5_GammaAwake_Turner2022.png'])
    imwrite(h5Img,[dirpath 'Fig5_GammaNREM_Turner2022.png'])
    imwrite(h6Img,[dirpath 'Fig5_GammaREM_Turner2022.png'])
end
%% eye transitions between arousal states
resultsStruct = 'Results_Transitions.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_Transitions);
transitions = {'AWAKEtoNREM','NREMtoAWAKE','NREMtoREM','REMtoAWAKE'};
mmPerPixel = 0.018;
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    for bb = 1:length(transitions)
        transition = transitions{1,bb};
        data.(transition).mmDiameter(aa,:) = mean(Results_Transitions.(animalID).(transition).mmDiameter,'omitnan');
        data.(transition).zDiameter(aa,:) = mean(Results_Transitions.(animalID).(transition).zDiameter,'omitnan');
        data.(transition).distanceTraveled(aa,:) = mean(Results_Transitions.(animalID).(transition).distanceTraveled,'omitnan')*mmPerPixel;
        data.(transition).centroidX(aa,:) = mean(Results_Transitions.(animalID).(transition).centroidX,'omitnan')*mmPerPixel;
        data.(transition).centroidY(aa,:) = mean(Results_Transitions.(animalID).(transition).centroidY,'omitnan')*mmPerPixel;
    end
end
% take average for each behavioral transition
for cc = 1:length(transitions)
    transition = transitions{1,cc};
    data.(transition).meanZ = mean(data.(transition).zDiameter,1,'omitnan');
    data.(transition).stdZ = std(data.(transition).zDiameter,0,1,'omitnan');
    data.(transition).meanMM = mean(data.(transition).mmDiameter,1,'omitnan');
    data.(transition).stdMM = std(data.(transition).mmDiameter,0,1,'omitnan');
    data.(transition).meanDistanceTraveled = mean(data.(transition).distanceTraveled,1,'omitnan');
    data.(transition).stdDistanceTraveled = std(data.(transition).distanceTraveled,0,1,'omitnan');
    data.(transition).meanCentroidX = mean(data.(transition).centroidX,1,'omitnan');
    data.(transition).stdCentroidX = std(data.(transition).centroidX,0,1,'omitnan');
    data.(transition).meanCentroidY = mean(data.(transition).centroidY,1,'omitnan');
    data.(transition).stdCentroidY = std(data.(transition).centroidY,0,1,'omitnan');
end
T1 = -30 + (1/30):(1/30):30;
%% eye motion
resultsStruct = 'Results_EyeMotion.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_Transitions);
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    data.Awake(aa,:) = mean(Results_EyeMotion.(animalID).Awake);
    data.NREM(aa,:) = mean(Results_EyeMotion.(animalID).NREM);
    data.REM(aa,:) = mean(Results_EyeMotion.(animalID).REM);
end
% take average for each behavioral transition
secPerBin = 5;
meanAwake = mean(data.Awake/secPerBin);
stdAwake = std(data.Awake/secPerBin,0,1);
meanNREM = mean(data.NREM/secPerBin);
stdNREM = std(data.NREM/secPerBin,0,1);
meanREM = mean(data.REM/secPerBin);
stdREM = std(data.REM/secPerBin,0,1);
% stats
[AwakeNREMStats.h,AwakeNREMStats.p,AwakeNREMStats.ci,AwakeNREMStats.stats] = ttest(data.Awake,data.NREM);
[AwakeREMStats.h,AwakeREMStats.p,AwakeREMStats.ci,AwakeREMStats.stats] = ttest(data.Awake,data.REM);
[NREMREMStats.h,NREMREMStats.p,NREMREMStats.ci,NREMREMStats.stats] = ttest(data.NREM,data.REM);
% bonferroni correction
comparisons = 3;
alpha1 = 0.05/comparisons;
alpha2 = 0.01/comparisons;
alpha3 = 0.001/comparisons;
%% Figure
Fig5 = figure('Name','Figure Panel 5 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
ax1 = subplot(3,4,1);
edges = -8:0.1:6.5;
yyaxis right
h1 = histogram(diameterAllCatMeans,edges,'Normalization','probability','EdgeColor',colors('black'),'FaceColor',colors('black'));
ylabel('Probability','rotation',-90,'VerticalAlignment','bottom')
yyaxis left
p1 = plot(edges,sgolayfilt(medfilt1(awakeProbPerc,10,'truncate'),3,17),'-','color',colors('battleship grey'),'LineWidth',2);
hold on
p2 = plot(edges,sgolayfilt(medfilt1(nremProbPerc,10,'truncate'),3,17),'-','color',colors('cyan'),'LineWidth',2);
p3 = plot(edges,sgolayfilt(medfilt1(remProbPerc,10,'truncate'),3,17),'-','color',colors('candy apple red'),'LineWidth',2);
ylabel({'Arousal-state probability (%)'})
xlim([-8,6.5])
ylim([0,1])
legend([p1,p2,p3,h1],'Awake','NREM','REM','\DeltaArea','Location','NorthEast')
title('Diameter vs. arousal state')
xlabel('Diameter (z-units)')
axis square
set(gca,'box','off')
set(gca,'TickLength',[0.03,0.03]);
set(h1,'facealpha',0.2);
ax1.TickLength = [0.03,0.03];
ax1.YAxis(1).Color = colors('black');
ax1.YAxis(2).Color = colors('battleship grey');
%% Gamma
subplot(3,4,2)
gammaPupilImg = imread('GammaPupilStack.png'); % needs made by combining images in ImageJ (Z project min)
imshow(gammaPupilImg)
axis off
title('Pupil-Gamma')
xlabel('Diameter (z-units)')
ylabel('\DeltaP/P (%)')
%% HbT
subplot(3,4,3)
HbTPupilImg = imread('HbTPupilStack.png'); % needs made by combining images in ImageJ (Z project min)
imshow(HbTPupilImg)
axis off
title('Pupil-HbT')
xlabel('Diameter (z-units)')
ylabel('\Delta[HbT] (\muM)')
%% Eye motion
subplot(3,4,4)
s1 = scatter(ones(1,length(data.Awake))*1,data.Awake/secPerBin,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('black'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,meanAwake,stdAwake,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
s2 = scatter(ones(1,length(data.NREM))*2,data.NREM/secPerBin,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('cyan'),'jitter','on','jitterAmount',0.25);
hold on
e2 = errorbar(2,meanNREM,stdNREM,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
s3 = scatter(ones(1,length(data.REM))*3,data.REM/secPerBin,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('candy apple red'),'jitter','on','jitterAmount',0.25);
hold on
e3 = errorbar(3,meanREM,stdREM,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e3.Color = 'black';
e3.MarkerSize = 10;
e3.CapSize = 10;
title('Eye motion')
ylabel('Mean |velocity| (mm/sec)')
legend([s1,s2,s3],'Awake','NREM','REM')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,4])
set(gca,'box','off')
%% z-unit figure
ax1 = subplot(3,4,5);
plot(T1,data.AWAKEtoNREM.meanZ,'-','color',colors('black'),'LineWidth',2);
hold on
plot(T1,data.AWAKEtoNREM.meanZ + data.AWAKEtoNREM.stdZ,'-','color',colors('battleship grey'),'LineWidth',0.5);
plot(T1,data.AWAKEtoNREM.meanZ - data.AWAKEtoNREM.stdZ,'-','color',colors('battleship grey'),'LineWidth',0.5);
xlim([-30,30])
title('Awake to NREM')
xlabel('Peri-transition time (s)')
ylabel('Diameter (Z)')
set(gca,'box','off')
%
ax2 = subplot(3,4,6);
plot(T1,data.NREMtoAWAKE.meanZ,'-','color',colors('black'),'LineWidth',2);
hold on
plot(T1,data.NREMtoAWAKE.meanZ + data.NREMtoAWAKE.stdZ,'-','color',colors('battleship grey'),'LineWidth',0.5);
plot(T1,data.NREMtoAWAKE.meanZ - data.NREMtoAWAKE.stdZ,'-','color',colors('battleship grey'),'LineWidth',0.5);
xlim([-30,30])
title('NREM to Awake')
xlabel('Peri-transition time (s)')
ylabel('Diameter (z-units)')
set(gca,'box','off')
%
ax3 = subplot(3,4,7);
plot(T1,data.NREMtoREM.meanZ,'-','color',colors('black'),'LineWidth',2);
hold on
plot(T1,data.NREMtoREM.meanZ + data.NREMtoREM.stdZ,'-','color',colors('battleship grey'),'LineWidth',0.5);
plot(T1,data.NREMtoREM.meanZ - data.NREMtoREM.stdZ,'-','color',colors('battleship grey'),'LineWidth',0.5);
xlim([-30,30])
title('NREM to REM')
xlabel('Peri-transition time (s)')
ylabel('Diameter (z-units)')
set(gca,'box','off')
%
ax4 = subplot(3,4,8);
plot(T1,data.REMtoAWAKE.meanZ,'-','color',colors('black'),'LineWidth',2);
hold on
plot(T1,data.REMtoAWAKE.meanZ + data.REMtoAWAKE.stdZ,'-','color',colors('battleship grey'),'LineWidth',0.5);
plot(T1,data.REMtoAWAKE.meanZ - data.REMtoAWAKE.stdZ,'-','color',colors('battleship grey'),'LineWidth',0.5);
xlim([-30,30])
title('REM to Awake')
xlabel('Peri-transition time (s)')
ylabel('Diameter (z-units)')
set(gca,'box','off')
linkaxes([ax1,ax2,ax3,ax4],'xy')
%
ax1 = subplot(3,4,9);
plot(T1,data.AWAKEtoNREM.meanCentroidX,'-','color',colors('custom green'),'LineWidth',2);
hold on
plot(T1,data.AWAKEtoNREM.meanCentroidX + data.AWAKEtoNREM.stdCentroidX,'-','color',colors('custom green'),'LineWidth',0.5);
plot(T1,data.AWAKEtoNREM.meanCentroidX - data.AWAKEtoNREM.stdCentroidX,'-','color',colors('custom green'),'LineWidth',0.5);
plot(T1,data.AWAKEtoNREM.meanCentroidY,'-','color',colors('cocoa brown'),'LineWidth',2);
plot(T1,data.AWAKEtoNREM.meanCentroidY + data.AWAKEtoNREM.stdCentroidY,'-','color',colors('cocoa brown'),'LineWidth',0.5);
plot(T1,data.AWAKEtoNREM.meanCentroidY - data.AWAKEtoNREM.stdCentroidY,'-','color',colors('cocoa brown'),'LineWidth',0.5);
xlim([-30,30])
title('Awake to NREM')
xlabel('Peri-transition time (s)')
ylabel('Position (mm)')
set(gca,'box','off')
%
ax2 = subplot(3,4,10);
plot(T1,data.NREMtoAWAKE.meanCentroidX,'-','color',colors('custom green'),'LineWidth',2);
hold on
plot(T1,data.NREMtoAWAKE.meanCentroidX + data.NREMtoAWAKE.stdCentroidX,'-','color',colors('custom green'),'LineWidth',0.5);
plot(T1,data.NREMtoAWAKE.meanCentroidX - data.NREMtoAWAKE.stdCentroidX,'-','color',colors('custom green'),'LineWidth',0.5);
plot(T1,data.NREMtoAWAKE.meanCentroidY,'-','color',colors('cocoa brown'),'LineWidth',2);
plot(T1,data.NREMtoAWAKE.meanCentroidY + data.NREMtoAWAKE.stdCentroidY,'-','color',colors('cocoa brown'),'LineWidth',0.5);
plot(T1,data.NREMtoAWAKE.meanCentroidY - data.NREMtoAWAKE.stdCentroidY,'-','color',colors('cocoa brown'),'LineWidth',0.5);
xlim([-30,30])
title('NREM to Awake')
xlabel('Peri-transition time (s)')
ylabel('Position (mm)')
set(gca,'box','off')
%
ax3 = subplot(3,4,11);
plot(T1,data.NREMtoREM.meanCentroidX,'-','color',colors('custom green'),'LineWidth',2);
hold on
plot(T1,data.NREMtoREM.meanCentroidX + data.NREMtoREM.stdCentroidX,'-','color',colors('custom green'),'LineWidth',0.5);
plot(T1,data.NREMtoREM.meanCentroidX - data.NREMtoREM.stdCentroidX,'-','color',colors('custom green'),'LineWidth',0.5);
plot(T1,data.NREMtoREM.meanCentroidY,'-','color',colors('cocoa brown'),'LineWidth',2);
plot(T1,data.NREMtoREM.meanCentroidY + data.NREMtoREM.stdCentroidY,'-','color',colors('cocoa brown'),'LineWidth',0.5);
plot(T1,data.NREMtoREM.meanCentroidY - data.NREMtoREM.stdCentroidY,'-','color',colors('cocoa brown'),'LineWidth',0.5);
xlim([-30,30])
title('NREM to REM')
xlabel('Peri-transition time (s)')
ylabel('Position (mm)')
set(gca,'box','off')
%
ax4 = subplot(3,4,12);
plot(T1,data.REMtoAWAKE.meanCentroidX,'-','color',colors('custom green'),'LineWidth',2);
hold on
plot(T1,data.REMtoAWAKE.meanCentroidX + data.REMtoAWAKE.stdCentroidX,'-','color',colors('custom green'),'LineWidth',0.5);
plot(T1,data.REMtoAWAKE.meanCentroidX - data.REMtoAWAKE.stdCentroidX,'-','color',colors('custom green'),'LineWidth',0.5);
plot(T1,data.REMtoAWAKE.meanCentroidY,'-','color',colors('cocoa brown'),'LineWidth',2);
plot(T1,data.REMtoAWAKE.meanCentroidY + data.REMtoAWAKE.stdCentroidY,'-','color',colors('cocoa brown'),'LineWidth',0.5);
plot(T1,data.REMtoAWAKE.meanCentroidY - data.REMtoAWAKE.stdCentroidY,'-','color',colors('cocoa brown'),'LineWidth',0.5);
xlim([-30,30])
title('REM to Awake')
xlabel('Peri-transition time (s)')
ylabel('Position (mm)')
set(gca,'box','off')
linkaxes([ax1,ax2,ax3,ax4],'xy')
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'MATLAB Figures' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig5,[dirpath 'Fig5B_Turner2022']);
    set(Fig5,'PaperPositionMode','auto');
    print('-vector','-dpdf','-fillpage',[dirpath 'Fig5B_Turner2022'])
    % text diary
    diaryFile = [dirpath 'Fig5_Text.txt'];
    if exist(diaryFile,'file') == 2
        delete(diaryFile)
    end
    diary(diaryFile)
    diary on
    disp('======================================================================================================================')
    disp('Eye motion')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Awake eye motion: ' num2str(meanAwake) ' ± ' num2str(stdAwake) ' mm/sec (n = ' num2str(length(data.Awake)) ') mice']); disp(' ')
    disp(['NREM eye motion: ' num2str(meanNREM) ' ± ' num2str(stdNREM) ' mm/sec (n = ' num2str(length(data.NREM)) ') mice']); disp(' ')
    disp(['REM eye motion: ' num2str(meanREM) ' ± ' num2str(stdREM) ' mm/sec (n = ' num2str(length(data.REM)) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp('Stats')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Awake vs. NREM: p < ' num2str(AwakeNREMStats.p)]); disp(' ')
    disp(['Awake vs. REM: p < ' num2str(AwakeREMStats.p)]); disp(' ')
    disp(['NREM vs. REM: p < ' num2str(NREMREMStats.p)]); disp(' ')
    disp(['Bonferroni corrected significance levels (3 comparisons): *p < ' num2str(alpha1) ' **p < ' num2str(alpha2) ' ***p < ' num2str(alpha3)])
    disp('----------------------------------------------------------------------------------------------------------------------')
    diary off
end
cd(rootFolder)
end
