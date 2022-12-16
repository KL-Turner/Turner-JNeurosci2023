function [AnalysisResults] = Fig6_JNeurosci2022(rootFolder,saveFigs,delim,AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: Generate figures and supporting information for Figure Panel 6
%________________________________________________________________________________________________________________________

dataLocation = [rootFolder delim 'Analysis Structures'];
cd(dataLocation)
%% Sleep probability based on pupil mm diameter
resultsStruct = 'Results_SleepProbability.mat';
load(resultsStruct);
diameterAllCatMeans = Results_SleepProbability.diameterCatMeans;
awakeProbPerc = Results_SleepProbability.awakeProbPerc./100;
nremProbPerc = Results_SleepProbability.nremProbPerc./100;
remProbPerc = Results_SleepProbability.remProbPerc./100;
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
Fig6 = figure('Name','Figure Panel 6 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
ax1 = subplot(3,4,1:2);
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
%% Eye motion
subplot(3,4,3:4)
s1 = scatter(ones(1,length(data.Awake))*1,data.Awake/secPerBin,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('black'),'jitter','on','jitterAmount',0);
hold on
e1 = errorbar(1,meanAwake,stdAwake,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
s2 = scatter(ones(1,length(data.NREM))*2,data.NREM/secPerBin,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('cyan'),'jitter','on','jitterAmount',0);
hold on
e2 = errorbar(2,meanNREM,stdNREM,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
s3 = scatter(ones(1,length(data.REM))*3,data.REM/secPerBin,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('candy apple red'),'jitter','on','jitterAmount',0);
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
    savefig(Fig6,[dirpath 'Fig6B_JNeurosci2022']);
    set(Fig6,'PaperPositionMode','auto');
    print('-vector','-dpdf','-fillpage',[dirpath 'Fig6B_JNeurosci2022'])
    % text diary
    diaryFile = [dirpath 'Fig6_Text.txt'];
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
