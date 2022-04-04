function [] = Fig3_JNeurosci2022(rootFolder,saveFigs,delim)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose:
%________________________________________________________________________________________________________________________

%% variables for loops
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
%% variables for loops
resultsStruct = 'Results_StimulusBlinks';
load(resultsStruct);
animalIDs = fieldnames(Results_StimulusBlinks);
%% pre-allocate data structure
data.stimPerc = []; data.binProb = []; data.indBinProb = []; data.duration = [];
% cd through each animal's directory and extract the appropriate analysis results
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    data.stimPerc = cat(1,data.stimPerc,Results_StimulusBlinks.(animalID).stimPercentage);
    data.duration = cat(1,data.duration,Results_StimulusBlinks.(animalID).stimPercentageDuration);
    data.binProb = cat(1,data.binProb,Results_StimulusBlinks.(animalID).binProbability);
    data.indBinProb = cat(1,data.indBinProb,Results_StimulusBlinks.(animalID).indBinProbability);
end
data.meanStimPerc = mean(data.stimPerc,1);
data.stdStimPerc = std(data.stimPerc,0,1);
data.meanDuration = mean(data.duration,1);
data.meanBinProb = mean(data.binProb,1);
data.stdBinProb = std(data.binProb,0,1);
data.meanIndBinProb = mean(data.indBinProb,1);
data.stdIndBinProb = std(data.indBinProb,0,1);

resultsStruct = 'Results_BlinkResponses';
load(resultsStruct);
animalIDs = fieldnames(Results_BlinkResponses);
timeVector = (0:20*30)/30 - 10;
data.Awake.zDiameter = []; data.Awake.whisk = []; data.Awake.HbT = []; data.Awake.cort = []; data.Awake.hip = []; data.Awake.EMG = [];
data.Asleep.zDiameter = []; data.Asleep.whisk = []; data.Asleep.HbT = []; data.Asleep.cort = []; data.Asleep.hip = []; data.Asleep.EMG = [];
data.Awake.zDiameter_T = []; data.Awake.whisk_T = []; data.Awake.HbT_T = []; data.Awake.cort_T = []; data.Awake.hip_T = []; data.Awake.EMG_T = [];
data.Asleep.zDiameter_T = []; data.Asleep.whisk_T = []; data.Asleep.HbT_T = []; data.Asleep.cort_T = []; data.Asleep.hip_T = []; data.Asleep.EMG_T = [];
data.Awake.zDiameter_F = []; data.Awake.whisk_F = []; data.Awake.HbT_F = []; data.Awake.cort_F = []; data.Awake.hip_F = []; data.Awake.EMG_F = [];
data.Asleep.zDiameter_F = []; data.Asleep.whisk_F = []; data.Asleep.HbT_F = []; data.Asleep.cort_F = []; data.Asleep.hip_F = []; data.Asleep.EMG_F = [];
blinkStates = {'Awake','Asleep'};
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    for bb = 1:length(blinkStates)
        blinkState = blinkStates{1,bb};
        %%
        if isempty(Results_BlinkResponses.(animalID).(blinkState).zDiameter) == false
            data.(blinkState).zDiameter  = cat(1,data.(blinkState).zDiameter,Results_BlinkResponses.(animalID).(blinkState).zDiameter);
        end
        data.(blinkState).whisk  = cat(1,data.(blinkState).whisk,Results_BlinkResponses.(animalID).(blinkState).whisk);
        data.(blinkState).HbT  = cat(1,data.(blinkState).HbT,Results_BlinkResponses.(animalID).(blinkState).LH_HbT,Results_BlinkResponses.(animalID).(blinkState).RH_HbT);
        data.(blinkState).cort = cat(3,data.(blinkState).cort,Results_BlinkResponses.(animalID).(blinkState).LH_cort,Results_BlinkResponses.(animalID).(blinkState).RH_cort);
        data.(blinkState).hip = cat(3,data.(blinkState).hip,Results_BlinkResponses.(animalID).(blinkState).hip);
        data.(blinkState).EMG = cat(1,data.(blinkState).EMG,Results_BlinkResponses.(animalID).(blinkState).EMG);
        %%
        if isempty(Results_BlinkResponses.(animalID).(blinkState).zDiameter_T) == false
            data.(blinkState).zDiameter_T  = cat(1,data.(blinkState).zDiameter_T,Results_BlinkResponses.(animalID).(blinkState).zDiameter_T);
        end
        if isempty(Results_BlinkResponses.(animalID).(blinkState).whisk_T) == false
            data.(blinkState).whisk_T  = cat(1,data.(blinkState).whisk_T,Results_BlinkResponses.(animalID).(blinkState).whisk_T);
            data.(blinkState).HbT_T  = cat(1,data.(blinkState).HbT_T,Results_BlinkResponses.(animalID).(blinkState).LH_HbT_T,Results_BlinkResponses.(animalID).(blinkState).RH_HbT_T);
            data.(blinkState).cort_T = cat(3,data.(blinkState).cort_T,Results_BlinkResponses.(animalID).(blinkState).LH_cort_T,Results_BlinkResponses.(animalID).(blinkState).RH_cort_T);
            data.(blinkState).hip_T = cat(3,data.(blinkState).hip_T,Results_BlinkResponses.(animalID).(blinkState).hip_T);
            data.(blinkState).EMG_T = cat(1,data.(blinkState).EMG_T,Results_BlinkResponses.(animalID).(blinkState).EMG_T);
        end
        %%
        if isempty(Results_BlinkResponses.(animalID).(blinkState).zDiameter_F) == false
            data.(blinkState).zDiameter_F  = cat(1,data.(blinkState).zDiameter_F,Results_BlinkResponses.(animalID).(blinkState).zDiameter_F);
        end
        if isempty(Results_BlinkResponses.(animalID).(blinkState).whisk_F) == false
            data.(blinkState).whisk_F  = cat(1,data.(blinkState).whisk_F,Results_BlinkResponses.(animalID).(blinkState).whisk_F);
            data.(blinkState).HbT_F  = cat(1,data.(blinkState).HbT_F,Results_BlinkResponses.(animalID).(blinkState).LH_HbT_F,Results_BlinkResponses.(animalID).(blinkState).RH_HbT_F);
            data.(blinkState).cort_F = cat(3,data.(blinkState).cort_F,Results_BlinkResponses.(animalID).(blinkState).LH_cort_F,Results_BlinkResponses.(animalID).(blinkState).RH_cort_F);
            data.(blinkState).hip_F = cat(3,data.(blinkState).hip_F,Results_BlinkResponses.(animalID).(blinkState).hip_F);
            data.(blinkState).EMG_F = cat(1,data.(blinkState).EMG_F,Results_BlinkResponses.(animalID).(blinkState).EMG_F);
        end
        T = Results_BlinkResponses.(animalID).(blinkState).T;
        F = Results_BlinkResponses.(animalID).(blinkState).F;
    end
end
%
for bb = 1:length(blinkStates)
    blinkState = blinkStates{1,bb};
    data.(blinkState).meanDiameter = mean(data.(blinkState).zDiameter,1);
    data.(blinkState).stdDiameter = std(data.(blinkState).zDiameter,0,1)./sqrt(size(data.(blinkState).zDiameter,1));
    data.(blinkState).meanHbT = mean(data.(blinkState).HbT,1);
    data.(blinkState).stdHbT = std(data.(blinkState).HbT,0,1)./sqrt(size(data.(blinkState).HbT,1));
    data.(blinkState).meanCort = mean(data.(blinkState).cort,3).*100;
    data.(blinkState).meanHip = mean(data.(blinkState).hip,3).*100;
    data.(blinkState).meanEMG = mean(data.(blinkState).EMG,1);
    data.(blinkState).stdEMG = std(data.(blinkState).EMG,0,1)./sqrt(size(data.(blinkState).EMG,1));
    data.(blinkState).meanWhisk = mean(data.(blinkState).whisk*100,1);
    data.(blinkState).stdWhisk = std(data.(blinkState).whisk*100,0,1)./sqrt(size(data.(blinkState).whisk,1));
    
    data.(blinkState).meanDiameter_T = mean(data.(blinkState).zDiameter_T,1);
    data.(blinkState).stdDiameter_T = std(data.(blinkState).zDiameter_T,0,1)./sqrt(size(data.(blinkState).zDiameter_T,1));
    data.(blinkState).meanHbT_T = mean(data.(blinkState).HbT_T,1);
    data.(blinkState).stdHbT_T = std(data.(blinkState).HbT_T,0,1)./sqrt(size(data.(blinkState).HbT_T,1));
    data.(blinkState).meanCort_T = mean(data.(blinkState).cort_T,3).*100;
    data.(blinkState).meanHip_T = mean(data.(blinkState).hip_T,3).*100;
    data.(blinkState).meanEMG_T = mean(data.(blinkState).EMG_T,1);
    data.(blinkState).stdEMG_T = std(data.(blinkState).EMG_T,0,1)./sqrt(size(data.(blinkState).EMG_T,1));
    data.(blinkState).meanWhisk_T = mean(data.(blinkState).whisk_T*100,1);
    data.(blinkState).stdWhisk_T = std(data.(blinkState).whisk_T*100,0,1)./sqrt(size(data.(blinkState).whisk_T,1));
    
    data.(blinkState).meanDiameter_F = mean(data.(blinkState).zDiameter_F,1);
    data.(blinkState).stdDiameter_F = std(data.(blinkState).zDiameter_F,0,1)./sqrt(size(data.(blinkState).zDiameter_F,1));
    data.(blinkState).meanHbT_F = mean(data.(blinkState).HbT_F,1);
    data.(blinkState).stdHbT_F = std(data.(blinkState).HbT_F,0,1)./sqrt(size(data.(blinkState).HbT_F,1));
    data.(blinkState).meanCort_F = mean(data.(blinkState).cort_F,3).*100;
    data.(blinkState).meanHip_F = mean(data.(blinkState).hip_F,3).*100;
    data.(blinkState).meanEMG_F = mean(data.(blinkState).EMG_F,1);
    data.(blinkState).stdEMG_F = std(data.(blinkState).EMG_F,0,1)./sqrt(size(data.(blinkState).EMG_F,1));
    data.(blinkState).meanWhisk_F = mean(data.(blinkState).whisk_F*100,1);
    data.(blinkState).stdWhisk_F = std(data.(blinkState).whisk_F*100,0,1)./sqrt(size(data.(blinkState).whisk_F,1));
end



%% variables for loops
resultsStruct = 'Results_BlinkTransition';
load(resultsStruct);
animalIDs = fieldnames(Results_BlinkTransition);
% take data from each animal corresponding to the CBV-gamma relationship
catAwakeMat = [];
catNremMat = [];
catRemMat = [];
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    catAwakeMat = cat(1,catAwakeMat,Results_BlinkTransition.(animalID).awakeProbabilityMatrix);
    catNremMat = cat(1,catNremMat,Results_BlinkTransition.(animalID).nremProbabilityMatrix);
    catRemMat = cat(1,catRemMat,Results_BlinkTransition.(animalID).remProbabilityMatrix);
end
% average probability
awakeProbability = smooth(mean(catAwakeMat,1))*100;
nremProbability = smooth(mean(catNremMat,1))*100;
remProbability = smooth(mean(catRemMat,1))*100;

%% variables for loops
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
%% figures
Fig3 = figure('Name','Figure Panel 3 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
%%
subplot(2,4,1)
title('Interblink interval vs. blink duration')
scatter(blinkDuration,interblink)
axis square
%%
subplot(2,4,2)
title('Interblink interval histogram')
histogram(allInterBlink,'Normalization','Probability')
axis square
%%
subplot(2,4,3)
semilogx(data.meanf1,data.meanS)
title('Power Spectrum')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
set(gca,'box','off')
xlim([0.003,1]);
axis square
%%
subplot(2,4,4)
semilogx(data.meanF2,data.meanPxx)
title('Lomb-Scargle Periodogram')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
set(gca,'box','off')
xlim([0.003,1]);
axis square
%%
subplot(2,4,5)
p1 = plot(timeVector,data.Awake.meanWhisk,'k','LineWidth',2);
hold on
plot(timeVector,data.Awake.meanWhisk + data.Awake.stdWhisk,'k','LineWidth',0.5)
plot(timeVector,data.Awake.meanWhisk - data.Awake.stdWhisk,'k','LineWidth',0.5)
p2 = plot(timeVector,data.Asleep.meanWhisk,'r','LineWidth',2);
plot(timeVector,data.Asleep.meanWhisk + data.Asleep.stdWhisk,'r','LineWidth',0.5)
plot(timeVector,data.Asleep.meanWhisk - data.Asleep.stdWhisk,'r','LineWidth',0.5)
xlabel('Time (s)')
ylabel('Probability (%)')
title('Whisk probability before/after blink')
legend([p1,p2],'Awake','Asleep')
set(gca,'box','off')
axis square
%%
subplot(2,4,6)
plot(0.5:0.5:5,data.meanBinProb,'k','LineWidth',2)
hold on; 
plot(0.5:0.5:5,data.meanBinProb + data.stdBinProb,'k','LineWidth',0.5)
plot(0.5:0.5:5,data.meanBinProb - data.stdBinProb,'k','LineWidth',0.5)
title('Probability of defensive blinking post-stimulus')
ylabel('Time (s)')
xlabel('Probability (%)')
set(gca,'box','off')
xlim([0,5]);
axis square
%%
subplot(2,4,7)
scatter(data.duration,data.stimPerc,75,'MarkerEdgeColor','k','MarkerFaceColor','k');
hold on
e1 = errorbar(data.meanDuration,data.meanStimPerc,data.stdStimPerc,'d','MarkerEdgeColor','k','MarkerFaceColor','g');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
title('Probability of defensive blinking post-whisker stimulus')
xlabel('Peri-blink whisk duration (s)')
ylabel('Probability (%)')
set(gca,'box','off')
% xlim([0.5,1.5]);
axis square
%%
subplot(2,4,8)
p1 = plot(awakeProbability);
hold on
p2 = plot(nremProbability);
p3 = plot(remProbability);
x1 = xline(7);
title('Arousal state probability adjacent to blinking')
xlabel('Time (sec)')
ylabel('Probability (%)')
legend([p1,p2,p3,x1],'Awake','NREM','REM','Blink')
xticks([1,3,5,7,9,11,13])
xticklabels({'-30','-20','-10','0','10','20','30'})
xlim([1,13])
ylim([0,100])
axis square
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'Summary Figures and Structures' delim 'Figure Panels' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig3,[dirpath 'Fig3_JNeurosci2022']);
    set(Fig3,'PaperPositionMode','auto');
    print('-vector','-dpdf','-bestfit',[dirpath 'Fig3_JNeurosci2022'])
end

end
