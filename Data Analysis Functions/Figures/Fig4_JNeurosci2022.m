function [] = Fig4_JNeurosci2022(rootFolder,saveFigs,delim)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose:
%________________________________________________________________________________________________________________________

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
%% HbT
Fig4A = figure('Name','Figure Panel 4 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
subplot(4,4,1);
plot(timeVector,data.Awake.meanHbT_T,'color',colors('smoky black'),'LineWidth',2);
hold on
plot(timeVector,data.Awake.meanHbT_T + data.Awake.stdHbT_T,'color',colors('smoky black'),'LineWidth',0.5)
plot(timeVector,data.Awake.meanHbT_T - data.Awake.stdHbT_T,'color',colors('smoky black'),'LineWidth',0.5)
title('Low Whisk Blink Awake HbT')
ylabel('\DeltaHbT (\muM)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
axis square
subplot(4,4,2);
plot(timeVector,data.Awake.meanHbT_F,'color',colors('smoky black'),'LineWidth',2);
hold on
plot(timeVector,data.Awake.meanHbT_F + data.Awake.stdHbT_F,'color',colors('smoky black'),'LineWidth',0.5)
plot(timeVector,data.Awake.meanHbT_F - data.Awake.stdHbT_F,'color',colors('smoky black'),'LineWidth',0.5)
title('High Whisk Blink Awake HbT')
ylabel('\DeltaHbT (\muM)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
axis square
subplot(4,4,3);
plot(timeVector,data.Asleep.meanHbT_T,'color',colors('smoky black'),'LineWidth',2);
hold on
plot(timeVector,data.Asleep.meanHbT_T + data.Asleep.stdHbT_T,'color',colors('smoky black'),'LineWidth',0.5)
plot(timeVector,data.Asleep.meanHbT_T - data.Asleep.stdHbT_T,'color',colors('smoky black'),'LineWidth',0.5)
title('Low Whisk Blink Asleep HbT')
ylabel('\DeltaHbT (\muM)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
axis square
subplot(4,4,4);
plot(timeVector,data.Asleep.meanHbT_F,'color',colors('smoky black'),'LineWidth',2);
hold on
plot(timeVector,data.Asleep.meanHbT_F + data.Asleep.stdHbT_F,'color',colors('smoky black'),'LineWidth',0.5)
plot(timeVector,data.Asleep.meanHbT_F - data.Asleep.stdHbT_F,'color',colors('smoky black'),'LineWidth',0.5)
title('High Whisk Blink Asleep HbT')
ylabel('\DeltaHbT (\muM)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
axis square
%% EMG
subplot(4,4,5);
plot(timeVector,data.Awake.meanEMG_T,'color',colors('smoky black'),'LineWidth',2);
hold on
plot(timeVector,data.Awake.meanEMG_T + data.Awake.stdEMG_T,'color',colors('smoky black'),'LineWidth',0.5)
plot(timeVector,data.Awake.meanEMG_T - data.Awake.stdEMG_T,'color',colors('smoky black'),'LineWidth',0.5)
title('Awake EMG')
ylabel('Power (a.u.)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
axis square
subplot(4,4,6);
plot(timeVector,data.Awake.meanEMG_F,'color',colors('smoky black'),'LineWidth',2);
hold on
plot(timeVector,data.Awake.meanEMG_F + data.Awake.stdEMG_F,'color',colors('smoky black'),'LineWidth',0.5)
plot(timeVector,data.Awake.meanEMG_F - data.Awake.stdEMG_F,'color',colors('smoky black'),'LineWidth',0.5)
title('Awake EMG')
ylabel('Power (a.u.)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
axis square
subplot(4,4,7);
plot(timeVector,data.Asleep.meanEMG_T,'color',colors('smoky black'),'LineWidth',2);
hold on
plot(timeVector,data.Asleep.meanEMG_T + data.Asleep.stdEMG_T,'color',colors('smoky black'),'LineWidth',0.5)
plot(timeVector,data.Asleep.meanEMG_T - data.Asleep.stdEMG_T,'color',colors('smoky black'),'LineWidth',0.5)
title('Asleep EMG')
ylabel('Power (a.u.)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
axis square
subplot(4,4,8);
plot(timeVector,data.Asleep.meanEMG_F,'color',colors('smoky black'),'LineWidth',2);
hold on
plot(timeVector,data.Asleep.meanEMG_F + data.Asleep.stdEMG_F,'color',colors('smoky black'),'LineWidth',0.5)
plot(timeVector,data.Asleep.meanEMG_F - data.Asleep.stdEMG_F,'color',colors('smoky black'),'LineWidth',0.5)
title('Asleep EMG')
ylabel('Power (a.u.)')
xlabel('Peri-blink time (s)')
set(gca,'box','off')
xlim([-10,10])
axis square
%% CORT
subplot(4,4,9);
imagesc(T,F,data.Awake.meanCort_T)
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
imagesc(T,F,data.Awake.meanCort_F)
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
imagesc(T,F,data.Asleep.meanCort_T)
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
imagesc(T,F,data.Asleep.meanCort_F)
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
imagesc(T,F,data.Awake.meanHip_T)
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
imagesc(T,F,data.Awake.meanHip_F)
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
imagesc(T,F,data.Asleep.meanHip_T)
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
imagesc(T,F,data.Asleep.meanHip_F)
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
