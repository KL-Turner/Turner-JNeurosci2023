function [] = Fig3_JNeurosci2022(rootFolder,saveFigs,delim)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Generate figures and supporting information for Figure Panel 3
%________________________________________________________________________________________________________________________

%% arousal state colors
colorAwake = [0,0,0];
colorNREM = [0,0.4,0];
colorREM = [1,0,1];
colorAsleep = [0.47,0.32,0.66];
%% blink periodogram 
resultsStruct = 'Results_BlinkPeriodogram';
load(resultsStruct);
animalIDs = fieldnames(Results_BlinkPeriodogram);
for aa = 1:length(animalIDs) - 1
    animalID = animalIDs{aa,1};
    data.f1(aa,:) = Results_BlinkPeriodogram.(animalID).f;
    data.S(aa,:) = Results_BlinkPeriodogram.(animalID).S;
end
data.meanf1 = mean(data.f1,1);
data.meanS = mean(data.S,1);
data.f2 = Results_BlinkPeriodogram.results.f;
data.pxx = Results_BlinkPeriodogram.results.pxx;
data.meanPxx = mean(data.pxx,2,'omitnan');
data.meanF2 = data.f2;
%% blinks associated with wisker stimulation
resultsStruct = 'Results_StimulusBlinks';
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
data.stdBinProb = std(data.binProb,0,1);
data.meanIndBinProb = mean(data.indBinProb,1);
data.stdIndBinProb = std(data.indBinProb,0,1);
%% blink triggered averages
resultsStruct = 'Results_BlinkResponses';
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
resultsStruct = 'Results_BlinkTransition';
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
resultsStruct = 'Results_InterBlinkInterval';
load(resultsStruct);
animalIDs = fieldnames(Results_InterBlinkInterval);
interblink = []; blinkDuration = []; allInterBlink = []; allBlinkDuration = [];
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    interblink = cat(1,interblink,mean(Results_InterBlinkInterval.(animalID).interBlinkInterval));
    allInterBlink = cat(1,allInterBlink,Results_InterBlinkInterval.(animalID).interBlinkInterval);
    blinkDuration = cat(1,blinkDuration,mean(Results_InterBlinkInterval.(animalID).allDurations));
    allBlinkDuration = cat(1,allBlinkDuration,Results_InterBlinkInterval.(animalID).allDurations);
end
meanInterblink = mean(interblink,1);
stdInterblink = std(interblink,0,1);
%% figures
Fig3A = figure('Name','Figure Panel 3 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
%% histogram of interblink interval
ax1 = subplot(2,4,1);
[~,edges] = histcounts(log10(allInterBlink));
histogram(allInterBlink,10.^edges,'Normalization','probability','EdgeColor',colors('vegas gold'),'FaceColor','k')
set(gca,'xscale','log')
xlabel('Interblink duration (s)')
ylabel('Probability')
title('Interblink interval')
axis square
set(gca,'box','off')
ax1.TickLength = [0.03,0.03];
%% blinking post-stimulus
ax2 = subplot(2,4,2);
stimTimeVec = 0.5:0.5:5;
plot(stimTimeVec,data.meanBinProb,'color',colors('blue-green'),'LineWidth',2)
hold on; 
plot(stimTimeVec,data.meanBinProb + data.stdBinProb,'color',colors('blue-green')','LineWidth',0.5)
plot(stimTimeVec,data.meanBinProb - data.stdBinProb,'color',colors('blue-green')','LineWidth',0.5)
xline(0,'--','color',colors('candy apple red'),'LineWidth',2);
title('blink location post-stimulus')
ylabel('Post-stim time (s)')
xlabel('Probability')
set(gca,'box','off')
xlim([-0.25,5]);
axis square
ax2.TickLength = [0.03,0.03];
%% blink transitions
ax3 = subplot(2,4,3);
p1 = plot(awakeProbability,'color',colorAwake,'LineWidth',2);
hold on
p2 = plot(nremProbability,'color',colorNREM,'LineWidth',2);
p3 = plot(remProbability,'color',colorREM,'LineWidth',2);
x1 = xline(7,'--','color',colors('candy apple red'),'LineWidth',2);
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
ax4 = subplot(2,4,4);
p1 = plot(timeVector,data.Awake.meanWhisk,'color',colorAwake,'LineWidth',2);
hold on
plot(timeVector,data.Awake.meanWhisk + data.Awake.stdWhisk,'color',colorAwake,'LineWidth',0.5)
plot(timeVector,data.Awake.meanWhisk - data.Awake.stdWhisk,'color',colorAwake,'LineWidth',0.5)
p2 = plot(timeVector,data.Asleep.meanWhisk,'color',colorAsleep,'LineWidth',2);
plot(timeVector,data.Asleep.meanWhisk + data.Asleep.stdWhisk,'color',colorAsleep,'LineWidth',0.5)
plot(timeVector,data.Asleep.meanWhisk - data.Asleep.stdWhisk,'color',colorAsleep,'LineWidth',0.5)
x1 = xline(0,'--','color',colors('candy apple red'),'LineWidth',2);
xlabel('Peri-blink Time (s)')
ylabel('Probability (%)')
title('Peri-blink whisk probability')
legend([p1,p2,x1],'Awake','Asleep','Blink','Location','NorthEast')
set(gca,'box','off')
axis square
ax4.TickLength = [0.03,0.03];
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'Summary Figures and Structures' delim 'Figure Panels' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig3A,[dirpath 'Fig3A_JNeurosci2022']);
    set(Fig3A,'PaperPositionMode','auto');
    print('-vector','-dpdf','-bestfit',[dirpath 'Fig3A_JNeurosci2022'])
end
%% HbT
Fig4A = figure('Name','Figure Panel 4 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
subplot(4,4,1)
p1 = plot(timeVector,data.Awake.meanHbT_highWhisk,'color',colors('smoky black'),'LineWidth',2);
hold on
plot(timeVector,data.Awake.meanHbT_highWhisk + data.Awake.stdHbT_highWhisk,'color',colors('smoky black'),'LineWidth',0.5)
plot(timeVector,data.Awake.meanHbT_highWhisk - data.Awake.stdHbT_highWhisk,'color',colors('smoky black'),'LineWidth',0.5)
p2 = plot(timeVector,data.Awake.meanHbT_lowWhisk,'color',colors('candy apple red'),'LineWidth',2);
plot(timeVector,data.Awake.meanHbT_lowWhisk + data.Awake.stdHbT_lowWhisk,'color',colors('candy apple red'),'LineWidth',0.5)
plot(timeVector,data.Awake.meanHbT_lowWhisk - data.Awake.stdHbT_lowWhisk,'color',colors('candy apple red'),'LineWidth',0.5)
p3 = plot(timeVector,data.Asleep.meanHbT_highWhisk,'color',colors('electric purple'),'LineWidth',2);
plot(timeVector,data.Asleep.meanHbT_highWhisk + data.Asleep.stdHbT_highWhisk,'color',colors('electric purple'),'LineWidth',0.5);
plot(timeVector,data.Asleep.meanHbT_highWhisk - data.Asleep.stdHbT_highWhisk,'color',colors('electric purple'),'LineWidth',0.5);
p4 = plot(timeVector,data.Asleep.meanHbT_lowWhisk,'color',colors('sapphire'),'LineWidth',2);
plot(timeVector,data.Asleep.meanHbT_lowWhisk + data.Asleep.stdHbT_lowWhisk,'color',colors('sapphire'),'LineWidth',0.5);
plot(timeVector,data.Asleep.meanHbT_lowWhisk - data.Asleep.stdHbT_lowWhisk,'color',colors('sapphire'),'LineWidth',0.5);
title('High Whisk Blink Awake HbT')
ylabel('\DeltaHbT (\muM)')
xlabel('Peri-blink time (s)')
legend([p1,p2,p3,p4],'awake whisking blink','awake low whisking blink','asleep whisking blink','asleep low whisking blink')
set(gca,'box','off')
xlim([-10,10])
axis square
%%
subplot(4,4,2);
plot(timeVector,data.Awake.meanHbT_highWhisk,'color',colors('smoky black'),'LineWidth',2);
hold on
plot(timeVector,data.Awake.meanHbT_highWhisk + data.Awake.stdHbT_highWhisk,'color',colors('smoky black'),'LineWidth',0.5)
plot(timeVector,data.Awake.meanHbT_highWhisk - data.Awake.stdHbT_highWhisk,'color',colors('smoky black'),'LineWidth',0.5)
title('High Whisk Blink Awake HbT')
ylabel('\DeltaHbT (\muM)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
axis square
%%
subplot(4,4,3);
plot(timeVector,data.Asleep.meanHbT_lowWhisk,'color',colors('smoky black'),'LineWidth',2);
hold on
plot(timeVector,data.Asleep.meanHbT_lowWhisk + data.Asleep.stdHbT_lowWhisk,'color',colors('smoky black'),'LineWidth',0.5)
plot(timeVector,data.Asleep.meanHbT_lowWhisk - data.Asleep.stdHbT_lowWhisk,'color',colors('smoky black'),'LineWidth',0.5)
title('Low Whisk Blink Asleep HbT')
ylabel('\DeltaHbT (\muM)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
axis square
subplot(4,4,4);
plot(timeVector,data.Asleep.meanHbT_highWhisk,'color',colors('smoky black'),'LineWidth',2);
hold on
plot(timeVector,data.Asleep.meanHbT_highWhisk + data.Asleep.stdHbT_highWhisk,'color',colors('smoky black'),'LineWidth',0.5)
plot(timeVector,data.Asleep.meanHbT_highWhisk - data.Asleep.stdHbT_highWhisk,'color',colors('smoky black'),'LineWidth',0.5)
title('High Whisk Blink Asleep HbT')
ylabel('\DeltaHbT (\muM)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
axis square
%% EMG
subplot(4,4,5);
plot(timeVector,data.Awake.meanEMG_lowWhisk,'color',colors('smoky black'),'LineWidth',2);
hold on
plot(timeVector,data.Awake.meanEMG_lowWhisk + data.Awake.stdEMG_lowWhisk,'color',colors('smoky black'),'LineWidth',0.5)
plot(timeVector,data.Awake.meanEMG_lowWhisk - data.Awake.stdEMG_lowWhisk,'color',colors('smoky black'),'LineWidth',0.5)
title('Awake EMG')
ylabel('Power (a.u.)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
axis square
subplot(4,4,6);
plot(timeVector,data.Awake.meanEMG_highWhisk,'color',colors('smoky black'),'LineWidth',2);
hold on
plot(timeVector,data.Awake.meanEMG_highWhisk + data.Awake.stdEMG_highWhisk,'color',colors('smoky black'),'LineWidth',0.5)
plot(timeVector,data.Awake.meanEMG_highWhisk - data.Awake.stdEMG_highWhisk,'color',colors('smoky black'),'LineWidth',0.5)
title('Awake EMG')
ylabel('Power (a.u.)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
axis square
subplot(4,4,7);
plot(timeVector,data.Asleep.meanEMG_lowWhisk,'color',colors('smoky black'),'LineWidth',2);
hold on
plot(timeVector,data.Asleep.meanEMG_lowWhisk + data.Asleep.stdEMG_lowWhisk,'color',colors('smoky black'),'LineWidth',0.5)
plot(timeVector,data.Asleep.meanEMG_lowWhisk - data.Asleep.stdEMG_lowWhisk,'color',colors('smoky black'),'LineWidth',0.5)
title('Asleep EMG')
ylabel('Power (a.u.)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
axis square
subplot(4,4,8);
plot(timeVector,data.Asleep.meanEMG_highWhisk,'color',colors('smoky black'),'LineWidth',2);
hold on
plot(timeVector,data.Asleep.meanEMG_highWhisk + data.Asleep.stdEMG_highWhisk,'color',colors('smoky black'),'LineWidth',0.5)
plot(timeVector,data.Asleep.meanEMG_highWhisk - data.Asleep.stdEMG_highWhisk,'color',colors('smoky black'),'LineWidth',0.5)
title('Asleep EMG')
ylabel('Power (a.u.)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
axis square
%% CORT
subplot(4,4,9);
imagesc(T,F,data.Awake.meanCort_lowWhisk)
title('Awake Cortical LFP')
ylabel('Freq (Hz)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
caxis([-20,20]) 
c1 = colorbar;
ylabel(c1,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
axis square
axis xy
subplot(4,4,10);
imagesc(T,F,data.Awake.meanCort_highWhisk)
title('Awake Cortical LFP')
ylabel('Freq (Hz)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
caxis([-20,20]) 
c2 = colorbar;
ylabel(c2,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
axis square
axis xy
subplot(4,4,11);
imagesc(T,F,data.Asleep.meanCort_lowWhisk)
title('Asleep Cortical LFP')
ylabel('Freq (Hz)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
caxis([-100,100]) 
c3 = colorbar;
ylabel(c3,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
axis square
axis xy
subplot(4,4,12);
imagesc(T,F,data.Asleep.meanCort_highWhisk)
title('Asleep Cortical LFP')
ylabel('Freq (Hz)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
caxis([-100,100]) 
c4 = colorbar;
ylabel(c4,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
axis square
axis xy
%% HIP
subplot(4,4,13);
imagesc(T,F,data.Awake.meanHip_lowWhisk)
title('Awake Hippocampal LFP')
ylabel('Freq (Hz)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
caxis([-20,20]) 
c5 = colorbar;
ylabel(c5,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
axis square
axis xy
subplot(4,4,14);
imagesc(T,F,data.Awake.meanHip_highWhisk)
title('Awake Hippocampal LFP')
ylabel('Freq (Hz)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
caxis([-20,20]) 
c6 = colorbar;
ylabel(c6,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
axis square
axis xy
subplot(4,4,15);
imagesc(T,F,data.Asleep.meanHip_lowWhisk)
title('Asleep Hippocampal LFP')
ylabel('Freq (Hz)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
caxis([-100,100]) 
c7 = colorbar;
ylabel(c7,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
axis square
axis xy
subplot(4,4,16);
imagesc(T,F,data.Asleep.meanHip_highWhisk)
title('Asleep Hippocampal LFP')
ylabel('Freq (Hz)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
caxis([-100,100]) 
c8 = colorbar;
ylabel(c8,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
axis square
axis xy
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'Summary Figures and Structures' delim 'Figure Panels' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig4A,[dirpath 'Fig4_JNeurosci2022']);
    set(Fig4A,'PaperPositionMode','auto');
    print('-vector','-dpdf','-bestfit',[dirpath 'Fig4_JNeurosci2022'])
end

end
