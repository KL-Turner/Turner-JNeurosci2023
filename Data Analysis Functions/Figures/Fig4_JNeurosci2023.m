function [] = Fig4_JNeurosci2023(rootFolder,saveFigs,delim)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Generate figures and supporting information for Figure Panel 4
%________________________________________________________________________________________________________________________

dataLocation = [rootFolder delim 'Analysis Structures'];
cd(dataLocation)
%% blinks associated with wisker stimulation
resultsStruct = 'Results_StimulusBlinks.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_StimulusBlinks);
% pre-allocate data structure
data.stimPerc = [];
data.binProb = [];
data.indBinProb = [];
data.duration = [];
% concatenate data from each animal
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    data.stimPerc = cat(1,data.stimPerc,Results_StimulusBlinks.(animalID).stimPercentage);
    data.duration = cat(1,data.duration,Results_StimulusBlinks.(animalID).stimPercentageDuration);
    data.binProb = cat(1,data.binProb,smooth(Results_StimulusBlinks.(animalID).binProbability)');
    data.indBinProb = cat(1,data.indBinProb,Results_StimulusBlinks.(animalID).indBinProbability);
end
% mean and standard deviation
data.meanStimPerc = mean(data.stimPerc,1);
data.stdStimPerc = std(data.stimPerc,0,1);
data.meanDuration = mean(data.duration,1);
data.meanBinProb = mean(data.binProb,1);
data.stdBinProb = std(data.binProb,0,1)./sqrt(size(data.binProb,1));
data.meanIndBinProb = mean(data.indBinProb,1);
data.stdIndBinProb = std(data.indBinProb,0,1);
%% blink triggered averages
resultsStruct = 'Results_BlinkResponses.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_BlinkResponses);
timeVector = (0:20*30)/30 - 10;
data.Awake.zDiameter = []; data.Awake.whisk = []; data.Awake.HbT = []; data.Awake.cort = []; data.Awake.hip = []; data.Awake.EMG = [];
data.Asleep.zDiameter = []; data.Asleep.whisk = []; data.Asleep.HbT = []; data.Asleep.cort = []; data.Asleep.hip = []; data.Asleep.EMG = [];
data.Awake.zDiameter_lowWhisk = []; data.Awake.whisk_lowWhisk = []; data.Awake.HbT_lowWhisk = []; data.Awake.cort_lowWhisk = []; data.Awake.hip_lowWhisk = []; data.Awake.EMG_lowWhisk = [];
data.Asleep.zDiameter_lowWhisk = []; data.Asleep.whisk_lowWhisk = []; data.Asleep.HbT_lowWhisk = []; data.Asleep.cort_lowWhisk = []; data.Asleep.hip_lowWhisk = []; data.Asleep.EMG_lowWhisk = [];
data.Awake.zDiameter_highWhisk = []; data.Awake.whisk_highWhisk = []; data.Awake.HbT_highWhisk = []; data.Awake.cort_highWhisk = []; data.Awake.hip_highWhisk = []; data.Awake.EMG_highWhisk = [];
data.Asleep.zDiameter_highWhisk = []; data.Asleep.whisk_highWhisk = []; data.Asleep.HbT_highWhisk = []; data.Asleep.cort_highWhisk = []; data.Asleep.hip_highWhisk = []; data.Asleep.EMG_highWhisk = [];
blinkStates = {'Awake','Asleep'};
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    for bb = 1:length(blinkStates)
        blinkState = blinkStates{1,bb};
        % all blinks
        if isempty(Results_BlinkResponses.(animalID).(blinkState).zDiameter) == false
            data.(blinkState).zDiameter  = cat(1,data.(blinkState).zDiameter,Results_BlinkResponses.(animalID).(blinkState).zDiameter);
            data.(blinkState).whisk  = cat(1,data.(blinkState).whisk,Results_BlinkResponses.(animalID).(blinkState).whisk);
            data.(blinkState).HbT  = cat(1,data.(blinkState).HbT,Results_BlinkResponses.(animalID).(blinkState).LH_HbT,Results_BlinkResponses.(animalID).(blinkState).RH_HbT);
            data.(blinkState).cort = cat(3,data.(blinkState).cort,Results_BlinkResponses.(animalID).(blinkState).LH_cort,Results_BlinkResponses.(animalID).(blinkState).RH_cort);
            data.(blinkState).hip = cat(3,data.(blinkState).hip,Results_BlinkResponses.(animalID).(blinkState).hip);
            data.(blinkState).EMG = cat(1,data.(blinkState).EMG,Results_BlinkResponses.(animalID).(blinkState).EMG);
            T = Results_BlinkResponses.(animalID).(blinkState).T;
            F = Results_BlinkResponses.(animalID).(blinkState).F;
        end
        % asleep blinks
        if isempty(Results_BlinkResponses.(animalID).(blinkState).zDiameter_lowWhisk) == false
            data.(blinkState).zDiameter_lowWhisk  = cat(1,data.(blinkState).zDiameter_lowWhisk,Results_BlinkResponses.(animalID).(blinkState).zDiameter_lowWhisk);
            data.(blinkState).whisk_lowWhisk  = cat(1,data.(blinkState).whisk_lowWhisk,Results_BlinkResponses.(animalID).(blinkState).whisk_lowWhisk);
            data.(blinkState).HbT_lowWhisk  = cat(1,data.(blinkState).HbT_lowWhisk,Results_BlinkResponses.(animalID).(blinkState).LH_HbT_lowWhisk,Results_BlinkResponses.(animalID).(blinkState).RH_HbT_lowWhisk);
            data.(blinkState).cort_lowWhisk = cat(3,data.(blinkState).cort_lowWhisk,Results_BlinkResponses.(animalID).(blinkState).LH_cort_lowWhisk,Results_BlinkResponses.(animalID).(blinkState).RH_cort_lowWhisk);
            data.(blinkState).hip_lowWhisk = cat(3,data.(blinkState).hip_lowWhisk,Results_BlinkResponses.(animalID).(blinkState).hip_lowWhisk);
            data.(blinkState).EMG_lowWhisk = cat(1,data.(blinkState).EMG_lowWhisk,Results_BlinkResponses.(animalID).(blinkState).EMG_lowWhisk);
        end
        % awake blinks
        if isempty(Results_BlinkResponses.(animalID).(blinkState).zDiameter_highWhisk) == false
            data.(blinkState).zDiameter_highWhisk  = cat(1,data.(blinkState).zDiameter_highWhisk,Results_BlinkResponses.(animalID).(blinkState).zDiameter_highWhisk);
            data.(blinkState).whisk_highWhisk  = cat(1,data.(blinkState).whisk_highWhisk,Results_BlinkResponses.(animalID).(blinkState).whisk_highWhisk);
            data.(blinkState).HbT_highWhisk  = cat(1,data.(blinkState).HbT_highWhisk,Results_BlinkResponses.(animalID).(blinkState).LH_HbT_highWhisk,Results_BlinkResponses.(animalID).(blinkState).RH_HbT_highWhisk);
            data.(blinkState).cort_highWhisk = cat(3,data.(blinkState).cort_highWhisk,Results_BlinkResponses.(animalID).(blinkState).LH_cort_highWhisk,Results_BlinkResponses.(animalID).(blinkState).RH_cort_highWhisk);
            data.(blinkState).hip_highWhisk = cat(3,data.(blinkState).hip_highWhisk,Results_BlinkResponses.(animalID).(blinkState).hip_highWhisk);
            data.(blinkState).EMG_highWhisk = cat(1,data.(blinkState).EMG_highWhisk,Results_BlinkResponses.(animalID).(blinkState).EMG_highWhisk);
        end
    end
end
% mean and standard error
for bb = 1:length(blinkStates)
    blinkState = blinkStates{1,bb};
    % all blinks
    data.(blinkState).meanDiameter = mean(data.(blinkState).zDiameter,1);
    data.(blinkState).stdDiameter = std(data.(blinkState).zDiameter,0,1)./sqrt(size(data.(blinkState).zDiameter,1));
    data.(blinkState).meanEMG = mean(data.(blinkState).EMG,1);
    data.(blinkState).stdEMG = std(data.(blinkState).EMG,0,1)./sqrt(size(data.(blinkState).EMG,1));
    data.(blinkState).meanWhisk = mean(data.(blinkState).whisk,1);
    data.(blinkState).stdWhisk = std(data.(blinkState).whisk,0,1)./sqrt(size(data.(blinkState).whisk,1));
    data.(blinkState).meanHbT = mean(data.(blinkState).HbT,1);
    data.(blinkState).stdHbT = std(data.(blinkState).HbT,0,1)./sqrt(size(data.(blinkState).HbT,1));
    data.(blinkState).meanCort = mean(data.(blinkState).cort,3).*100;
    data.(blinkState).meanHip = mean(data.(blinkState).hip,3).*100;
    % asleep blinks
    data.(blinkState).meanDiameter_lowWhisk = mean(data.(blinkState).zDiameter_lowWhisk,1);
    data.(blinkState).stdDiameter_lowWhisk = std(data.(blinkState).zDiameter_lowWhisk,0,1)./sqrt(size(data.(blinkState).zDiameter_lowWhisk,1));
    data.(blinkState).meanEMG_lowWhisk = mean(data.(blinkState).EMG_lowWhisk,1);
    data.(blinkState).stdEMG_lowWhisk = std(data.(blinkState).EMG_lowWhisk,0,1)./sqrt(size(data.(blinkState).EMG_lowWhisk,1));
    data.(blinkState).meanWhisk_lowWhisk = mean(data.(blinkState).whisk_lowWhisk,1);
    data.(blinkState).stdWhisk_lowWhisk = std(data.(blinkState).whisk_lowWhisk,0,1)./sqrt(size(data.(blinkState).whisk_lowWhisk,1));
    data.(blinkState).meanHbT_lowWhisk = mean(data.(blinkState).HbT_lowWhisk,1);
    data.(blinkState).stdHbT_lowWhisk = std(data.(blinkState).HbT_lowWhisk,0,1)./sqrt(size(data.(blinkState).HbT_lowWhisk,1));
    data.(blinkState).meanCort_lowWhisk = mean(data.(blinkState).cort_lowWhisk,3).*100;
    data.(blinkState).meanHip_lowWhisk = mean(data.(blinkState).hip_lowWhisk,3).*100;
    % awake blinks
    data.(blinkState).meanDiameter_highWhisk = mean(data.(blinkState).zDiameter_highWhisk,1);
    data.(blinkState).stdDiameter_highWhisk = std(data.(blinkState).zDiameter_highWhisk,0,1)./sqrt(size(data.(blinkState).zDiameter_highWhisk,1));
    data.(blinkState).meanEMG_highWhisk = mean(data.(blinkState).EMG_highWhisk,1);
    data.(blinkState).stdEMG_highWhisk = std(data.(blinkState).EMG_highWhisk,0,1)./sqrt(size(data.(blinkState).EMG_highWhisk,1));
    data.(blinkState).meanWhisk_highWhisk = mean(data.(blinkState).whisk_highWhisk,1);
    data.(blinkState).stdWhisk_highWhisk = std(data.(blinkState).whisk_highWhisk,0,1)./sqrt(size(data.(blinkState).whisk_highWhisk,1));
    data.(blinkState).meanHbT_highWhisk = mean(data.(blinkState).HbT_highWhisk,1);
    data.(blinkState).stdHbT_highWhisk = std(data.(blinkState).HbT_highWhisk,0,1)./sqrt(size(data.(blinkState).HbT_highWhisk,1));
    data.(blinkState).meanCort_highWhisk = mean(data.(blinkState).cort_highWhisk,3).*100;
    data.(blinkState).meanHip_highWhisk = mean(data.(blinkState).hip_highWhisk,3).*100;
end
%% arousal transitions associated with blinking
resultsStruct = 'Results_BlinkTransition.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_BlinkTransition);
% pre-allocate
catAwakeMat = [];
catNremMat = [];
catRemMat = [];
% concatenate transition from each animal
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    catAwakeMat = cat(1,catAwakeMat,Results_BlinkTransition.(animalID).awakeProbabilityMatrix);
    catNremMat = cat(1,catNremMat,Results_BlinkTransition.(animalID).nremProbabilityMatrix);
    catRemMat = cat(1,catRemMat,Results_BlinkTransition.(animalID).remProbabilityMatrix);
end
% average probability
awakeProbability = smooth(mean(catAwakeMat,1));
nremProbability = smooth(mean(catNremMat,1));
remProbability = smooth(mean(catRemMat,1));
%% interblink interval and blink duration
resultsStruct = 'Results_InterBlinkInterval.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_InterBlinkInterval);
data.interblink = []; data.blinkDuration = []; data.allInterBlink = []; data.allBlinkDuration = [];
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    data.interblink = cat(1,data.interblink,mean(Results_InterBlinkInterval.(animalID).interBlinkInterval));
    data.allInterBlink = cat(1,data.allInterBlink,Results_InterBlinkInterval.(animalID).interBlinkInterval);
    data.blinkDuration = cat(1,data.blinkDuration,mean(Results_InterBlinkInterval.(animalID).allDurations));
    data.allBlinkDuration = cat(1,data.allBlinkDuration,Results_InterBlinkInterval.(animalID).allDurations);
end
data.meanInterblink = mean(data.interblink,1);
data.stdInterblink = std(data.interblink,0,1);
%% figures
Fig4A = figure('Name','Figure Panel 4 - Turner et al. 2023','Units','Normalized','OuterPosition',[0,0,1,1]);
%% histogram of interblink interval
ax1 = subplot(2,3,1);
[~,edges] = histcounts(log10(data.allInterBlink));
histogram(data.allInterBlink,10.^edges,'Normalization','probability','EdgeColor',colors('vegas gold'),'FaceColor','k')
set(gca,'xscale','log')
xlabel('Interblink interval (IBI) (s)')
ylabel('Probability')
title('Interblink interval histogram')
axis square
set(gca,'box','off')
ax1.TickLength = [0.03,0.03];
%% mean interblink interval
ax5 = subplot(2,3,2);
scatter(ones(1,length(data.interblink))*1,data.interblink,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('vegas gold'),'jitter','on','jitterAmount',0);
hold on
e1 = errorbar(1,data.meanInterblink,data.stdInterblink,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
ylabel('Mean IBI (s)')
title('Interblink interval')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,2])
set(gca,'box','off')
ax5.TickLength = [0.03,0.03];
%% blinking post-stimulus
ax2 = subplot(2,3,3);
stimTimeVec = 0.5:0.5:5;
plot(stimTimeVec,data.meanBinProb,'color',colors('magenta'),'LineWidth',2)
hold on;
plot(stimTimeVec,data.meanBinProb + data.stdBinProb,'color',colors('magenta')','LineWidth',0.5)
plot(stimTimeVec,data.meanBinProb - data.stdBinProb,'color',colors('magenta')','LineWidth',0.5)
title('blink location post-stimulus')
xlabel('Post-stim time (s)')
ylabel('Probability')
set(gca,'box','off')
xlim([0.5,5]);
ylim([0,0.45])
axis square
ax2.TickLength = [0.03,0.03];
%% percentage blinks post-puff
ax6 = subplot(2,3,4);
scatter(ones(1,length(data.stimPerc))*1,data.stimPerc,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('magenta'),'jitter','on','jitterAmount',0);
hold on
e1 = errorbar(1,data.meanStimPerc,data.stdStimPerc,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
ylabel('Percentage (%)')
title('Probabilty of blinking after a whisker puff')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,2])
set(gca,'box','off')
ax6.TickLength = [0.03,0.03];
%% blink transitions
ax3 = subplot(2,3,5);
p1 = plot(awakeProbability,'color',colors('black'),'LineWidth',2);
hold on
p2 = plot(nremProbability,'color',colors('cyan'),'LineWidth',2);
p3 = plot(remProbability,'color',colors('candy apple red'),'LineWidth',2);
x1 = xline(7,'color',colors('magenta'),'LineWidth',2);
title('Peri-blink state probability')
xlabel('Peri-blink time (s)')
ylabel('Probability')
legend([p1,p2,p3,x1],'Awake','NREM','REM','Blink','Location','NorthWest')
xticks([1,3,5,7,9,11,13])
xticklabels({'-30','-20','-10','0','10','20','30'})
xlim([1,13])
ylim([0,1])
axis square
set(gca,'box','off')
ax3.TickLength = [0.03,0.03];
%% whisking before/after a blink
ax4 = subplot(2,3,6);
p1 = plot(timeVector,data.Awake.meanWhisk,'color',colors('black'),'LineWidth',2);
hold on
plot(timeVector,data.Awake.meanWhisk + data.Awake.stdWhisk,'color',colors('black'),'LineWidth',0.5)
plot(timeVector,data.Awake.meanWhisk - data.Awake.stdWhisk,'color',colors('black'),'LineWidth',0.5)
p2 = plot(timeVector,data.Asleep.meanWhisk,'color',colors('royal purple'),'LineWidth',2);
plot(timeVector,data.Asleep.meanWhisk + data.Asleep.stdWhisk,'color',colors('royal purple'),'LineWidth',0.5)
plot(timeVector,data.Asleep.meanWhisk - data.Asleep.stdWhisk,'color',colors('royal purple'),'LineWidth',0.5)
x1 = xline(0,'color',colors('magenta'),'LineWidth',2);
xlabel('Peri-blink Time (s)')
ylabel('Probability')
title('Peri-blink whisk probability')
legend([p1,p2,x1],'Awake','Asleep','Blink','Location','NorthEast')
set(gca,'box','off')
axis square
ax4.TickLength = [0.03,0.03];
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'MATLAB Figures' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig4A,[dirpath 'Fig4A_JNeurosci2023']);
    set(Fig4A,'PaperPositionMode','auto');
    print('-vector','-dpdf','-bestfit',[dirpath 'Fig4A_JNeurosci2023'])
end
%% awake blink triggered averages
Fig4B = figure('Name','Figure Panel 4 - Turner et al. 2023','Units','Normalized','OuterPosition',[0,0,1,1]);
sgtitle('Awake high vs. low whisk blink triggered averages')
%% awake diameter
ax1 = subplot(2,3,1);
p1 = plot(timeVector,data.Awake.meanDiameter_highWhisk,'color',colors('black'),'LineWidth',2);
hold on
plot(timeVector,data.Awake.meanDiameter_highWhisk + data.Awake.stdDiameter_highWhisk,'color',colors('black'),'LineWidth',0.5)
plot(timeVector,data.Awake.meanDiameter_highWhisk - data.Awake.stdDiameter_highWhisk,'color',colors('black'),'LineWidth',0.5)
p2 = plot(timeVector,data.Awake.meanDiameter_lowWhisk,'color',colors('ash grey'),'LineWidth',2);
plot(timeVector,data.Awake.meanDiameter_lowWhisk + data.Awake.stdDiameter_lowWhisk,'color',colors('ash grey'),'LineWidth',0.5)
plot(timeVector,data.Awake.meanDiameter_lowWhisk - data.Awake.stdDiameter_lowWhisk,'color',colors('ash grey'),'LineWidth',0.5)
xline(0,'color',colors('magenta'),'LineWidth',2);
ylabel('Diameter (z-units)')
xlabel('Peri-blink time (s)')
legend([p1,p2],'whisking blink','low whisk blink')
set(gca,'box','off')
xlim([-10,10])
axis square
ax1.TickLength = [0.03,0.03];
%% awake Hbt
ax2 = subplot(2,3,2);
plot(timeVector,data.Awake.meanHbT_highWhisk,'color',colors('black'),'LineWidth',2);
hold on
plot(timeVector,data.Awake.meanHbT_highWhisk + data.Awake.stdHbT_highWhisk,'color',colors('black'),'LineWidth',0.5)
plot(timeVector,data.Awake.meanHbT_highWhisk - data.Awake.stdHbT_highWhisk,'color',colors('black'),'LineWidth',0.5)
plot(timeVector,data.Awake.meanHbT_lowWhisk,'color',colors('battleship grey'),'LineWidth',2);
plot(timeVector,data.Awake.meanHbT_lowWhisk + data.Awake.stdHbT_lowWhisk,'color',colors('battleship grey'),'LineWidth',0.5)
plot(timeVector,data.Awake.meanHbT_lowWhisk - data.Awake.stdHbT_lowWhisk,'color',colors('battleship grey'),'LineWidth',0.5)
xline(0,'color',colors('magenta'),'LineWidth',2);
ylabel('\DeltaHbT (\muM)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
axis square
ax2.TickLength = [0.03,0.03];
%% awake EMG
ax3 = subplot(2,3,3);
plot(timeVector,data.Awake.meanEMG_highWhisk,'color',colors('black'),'LineWidth',2);
hold on
plot(timeVector,data.Awake.meanEMG_highWhisk + data.Awake.stdEMG_highWhisk,'color',colors('black'),'LineWidth',0.5)
plot(timeVector,data.Awake.meanEMG_highWhisk - data.Awake.stdEMG_highWhisk,'color',colors('black'),'LineWidth',0.5)
plot(timeVector,data.Awake.meanEMG_lowWhisk,'color',colors('ash grey'),'LineWidth',2);
plot(timeVector,data.Awake.meanEMG_lowWhisk + data.Awake.stdEMG_lowWhisk,'color',colors('ash grey'),'LineWidth',0.5)
plot(timeVector,data.Awake.meanEMG_lowWhisk - data.Awake.stdEMG_lowWhisk,'color',colors('ash grey'),'LineWidth',0.5)
xline(0,'color',colors('magenta'),'LineWidth',2);
ylabel('EMG Power (a.u.)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
axis square
ax3.TickLength = [0.03,0.03];
%% awake cortical low whisk
ax5 = subplot(2,4,5);
imagesc(T,F,data.Awake.meanCort_lowWhisk)
hold on
xline(0,'color',colors('magenta'),'LineWidth',2);
title('LW Cort LFP')
ylabel('Freq (Hz)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
caxis([-20,20])
axis square
axis xy
ax5.TickLength = [0.03,0.03];
%% awake cortical high whisk
ax6 = subplot(2,4,6);
imagesc(T,F,data.Awake.meanCort_highWhisk)
hold on
xline(0,'color',colors('magenta'),'LineWidth',2);
title('HW Cort LFP')
ylabel('Freq (Hz)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
caxis([-20,20])
axis square
axis xy
ax6.TickLength = [0.03,0.03];
%% awake hip low whisk
ax7 = subplot(2,4,7);
imagesc(T,F,data.Awake.meanHip_lowWhisk)
hold on
xline(0,'color',colors('magenta'),'LineWidth',2);
title('LW Hip LFP')
ylabel('Freq (Hz)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
caxis([-20,20])
axis square
axis xy
ax7.TickLength = [0.03,0.03];
%% awake hip high whisk
ax8 = subplot(2,4,8);
imagesc(T,F,data.Awake.meanHip_highWhisk)
hold on
xline(0,'color',colors('magenta'),'LineWidth',2);
title('HW Hip LFP')
ylabel('Freq (Hz)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
caxis([-20,20])
c4 = colorbar;
ylabel(c4,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
axis square
axis xy
ax8.TickLength = [0.03,0.03];
% axes properties
ax5Pos = get(ax5,'position');
ax8Pos = get(ax8,'position');
ax8Pos(3:4) = ax5Pos(3:4);
set(ax8,'position',ax8Pos);
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'MATLAB Figures' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig4B,[dirpath 'Fig4B_JNeurosci2023']);
    set(Fig4B,'PaperPositionMode','auto');
    print('-vector','-dpdf','-bestfit',[dirpath 'Fig4B_JNeurosci2023'])
end
%% asleep blink triggered averages
Fig4C = figure('Name','Figure Panel 4 - Turner et al. 2023','Units','Normalized','OuterPosition',[0,0,1,1]);
sgtitle('Asleep high vs. low whisk blink triggered averages')
%% Asleep diameter
ax1 = subplot(2,3,1);
p1 = plot(timeVector,data.Asleep.meanDiameter_highWhisk,'color',colors('electric purple'),'LineWidth',2);
hold on
plot(timeVector,data.Asleep.meanDiameter_highWhisk + data.Asleep.stdDiameter_highWhisk,'color',colors('electric purple'),'LineWidth',0.5)
plot(timeVector,data.Asleep.meanDiameter_highWhisk - data.Asleep.stdDiameter_highWhisk,'color',colors('electric purple'),'LineWidth',0.5)
p2 = plot(timeVector,data.Asleep.meanDiameter_lowWhisk,'color',colors('royal purple'),'LineWidth',2);
plot(timeVector,data.Asleep.meanDiameter_lowWhisk + data.Asleep.stdDiameter_lowWhisk,'color',colors('royal purple'),'LineWidth',0.5)
plot(timeVector,data.Asleep.meanDiameter_lowWhisk - data.Asleep.stdDiameter_lowWhisk,'color',colors('royal purple'),'LineWidth',0.5)
xline(0,'color',colors('magenta'),'LineWidth',2);
ylabel('Diameter (z-units)')
xlabel('Peri-blink time (s)')
legend([p1,p2],'whisking blink','low whisk blink')
set(gca,'box','off')
xlim([-10,10])
axis square
ax1.TickLength = [0.03,0.03];
%% Asleep Hbt
ax2 = subplot(2,3,2);
plot(timeVector,data.Asleep.meanHbT_highWhisk,'color',colors('electric purple'),'LineWidth',2);
hold on
plot(timeVector,data.Asleep.meanHbT_highWhisk + data.Asleep.stdHbT_highWhisk,'color',colors('electric purple'),'LineWidth',0.5)
plot(timeVector,data.Asleep.meanHbT_highWhisk - data.Asleep.stdHbT_highWhisk,'color',colors('electric purple'),'LineWidth',0.5)
plot(timeVector,data.Asleep.meanHbT_lowWhisk,'color',colors('royal purple'),'LineWidth',2);
plot(timeVector,data.Asleep.meanHbT_lowWhisk + data.Asleep.stdHbT_lowWhisk,'color',colors('royal purple'),'LineWidth',0.5)
plot(timeVector,data.Asleep.meanHbT_lowWhisk - data.Asleep.stdHbT_lowWhisk,'color',colors('royal purple'),'LineWidth',0.5)
xline(0,'color',colors('magenta'),'LineWidth',2);
ylabel('\DeltaHbT (\muM)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
axis square
ax2.TickLength = [0.03,0.03];
%% Asleep EMG
ax3 = subplot(2,3,3);
plot(timeVector,data.Asleep.meanEMG_highWhisk,'color',colors('electric purple'),'LineWidth',2);
hold on
plot(timeVector,data.Asleep.meanEMG_highWhisk + data.Asleep.stdEMG_highWhisk,'color',colors('electric purple'),'LineWidth',0.5)
plot(timeVector,data.Asleep.meanEMG_highWhisk - data.Asleep.stdEMG_highWhisk,'color',colors('electric purple'),'LineWidth',0.5)
plot(timeVector,data.Asleep.meanEMG_lowWhisk,'color',colors('royal purple'),'LineWidth',2);
plot(timeVector,data.Asleep.meanEMG_lowWhisk + data.Asleep.stdEMG_lowWhisk,'color',colors('royal purple'),'LineWidth',0.5)
plot(timeVector,data.Asleep.meanEMG_lowWhisk - data.Asleep.stdEMG_lowWhisk,'color',colors('royal purple'),'LineWidth',0.5)
xline(0,'color',colors('magenta'),'LineWidth',2);
ylabel('EMG Power (a.u.)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
axis square
ax3.TickLength = [0.03,0.03];
%% Asleep cortical low whisk
ax5 = subplot(2,4,5);
imagesc(T,F,data.Asleep.meanCort_lowWhisk)
hold on
xline(0,'color',colors('magenta'),'LineWidth',2);
title('LW Cort LFP')
ylabel('Freq (Hz)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
caxis([-100,100])
axis square
axis xy
ax5.TickLength = [0.03,0.03];
%% Asleep cortical high whisk
ax6 = subplot(2,4,6);
imagesc(T,F,data.Asleep.meanCort_highWhisk)
hold on
xline(0,'color',colors('magenta'),'LineWidth',2);
title('HW Cort LFP')
ylabel('Freq (Hz)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
caxis([-100,100])
axis square
axis xy
ax6.TickLength = [0.03,0.03];
%% Asleep hip low whisk
ax7 = subplot(2,4,7);
imagesc(T,F,data.Asleep.meanHip_lowWhisk)
hold on
xline(0,'color',colors('magenta'),'LineWidth',2);
title('LW Hip LFP')
ylabel('Freq (Hz)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
caxis([-100,100])
axis square
axis xy
ax7.TickLength = [0.03,0.03];
%% Asleep hip high whisk
ax8 = subplot(2,4,8);
imagesc(T,F,data.Asleep.meanHip_highWhisk)
hold on
xline(0,'color',colors('magenta'),'LineWidth',2);
title('HW Hip LFP')
ylabel('Freq (Hz)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
caxis([-100,100])
c4 = colorbar;
ylabel(c4,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
axis square
axis xy
ax8.TickLength = [0.03,0.03];
% axes properties
ax5Pos = get(ax5,'position');
ax8Pos = get(ax8,'position');
ax8Pos(3:4) = ax5Pos(3:4);
set(ax8,'position',ax8Pos);
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'MATLAB Figures' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig4C,[dirpath 'Fig4C_JNeurosci2023']);
    set(Fig4C,'PaperPositionMode','auto');
    print('-vector','-dpdf','-bestfit',[dirpath 'Fig4C_JNeurosci2023'])
    % text diary
    diaryFile = [dirpath 'Fig4_Text.txt'];
    if exist(diaryFile,'file') == 2
        delete(diaryFile)
    end
    diary(diaryFile)
    diary on
    % mean inter-blink interval (IBI)
    disp('======================================================================================================================')
    disp('Mean inter-blink interval')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Inter-blink interval: ' num2str(data.meanInterblink) ' ± ' num2str(data.stdInterblink) ' seconds (n = ' num2str(length(data.interblink)) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    % mean blink post whisker stimulus probability
    disp('======================================================================================================================')
    disp('Mean inter-blink interval')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Post-stimulus blink probability: ' num2str(data.meanStimPerc) ' ± ' num2str(data.stdStimPerc) ' seconds (n = ' num2str(length(data.stimPerc)) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    diary off
end
cd(rootFolder)
end
