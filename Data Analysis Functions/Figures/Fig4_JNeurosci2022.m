function [] = Fig4_JNeurosci2022(rootFolder,saveFigs,delim)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: Generate figures and supporting information for Figure Panel 4
%________________________________________________________________________________________________________________________

%% blink coherogram
resultsStruct = 'Results_BlinkCoherogram';
load(resultsStruct);
animalIDs = fieldnames(Results_BlinkCoherogram);
behavFields = {'Awake','Asleep','All'};
dataTypes = {'HbT','gamma'};
% take data from each animal during the different arousal states
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    for bb = 1:length(dataTypes)
        dataType = dataTypes{1,bb};
        data.Coherogram.(dataType).dummyCheck = 1;
        for cc = 1:length(behavFields)
            behavField = behavFields{1,cc};
            % pre-allocate
            if isfield(data.Coherogram.(dataType),behavField) == false
                data.Coherogram.(dataType).(behavField).C = [];
                data.Coherogram.(dataType).(behavField).f = [];
                data.Coherogram.(dataType).(behavField).t = [];
                data.Coherogram.(dataType).(behavField).leadC = [];
                data.Coherogram.(dataType).(behavField).lagC = [];
                data.Coherogram.(dataType).(behavField).leadf = [];
                data.Coherogram.(dataType).(behavField).lagf = [];
            end
            % calculate change in coherence for coherogram based on time index
            C = Results_BlinkCoherogram.(animalID).(dataType).(behavField).C;
            meanC = mean(C(:,1:300),2);
            matC = meanC.*ones(size(C));
            msC = (C - matC);
            % concatenate coherence data from each animal
            data.Coherogram.(dataType).(behavField).C = cat(3,data.Coherogram.(dataType).(behavField).C,msC);
            data.Coherogram.(dataType).(behavField).t = cat(1,data.Coherogram.(dataType).(behavField).t,Results_BlinkCoherogram.(animalID).(dataType).(behavField).t);
            data.Coherogram.(dataType).(behavField).f = cat(1,data.Coherogram.(dataType).(behavField).f,Results_BlinkCoherogram.(animalID).(dataType).(behavField).f);
            data.Coherogram.(dataType).(behavField).leadC = cat(2,data.Coherogram.(dataType).(behavField).leadC,Results_BlinkCoherogram.(animalID).(dataType).(behavField).leadC);
            data.Coherogram.(dataType).(behavField).lagC = cat(2,data.Coherogram.(dataType).(behavField).lagC,Results_BlinkCoherogram.(animalID).(dataType).(behavField).lagC);
            data.Coherogram.(dataType).(behavField).leadf = cat(1,data.Coherogram.(dataType).(behavField).leadf,Results_BlinkCoherogram.(animalID).(dataType).(behavField).leadf);
            data.Coherogram.(dataType).(behavField).lagf = cat(1,data.Coherogram.(dataType).(behavField).lagf,Results_BlinkCoherogram.(animalID).(dataType).(behavField).lagf);
        end
    end
end
% mean and standard error or standard deviation of coherence data
for aa = 1:length(dataTypes)
    dataType = dataTypes{1,aa};
    for bb = 1:length(behavFields)
        behavField = behavFields{1,bb};
        data.Coherogram.(dataType).(behavField).meanC = mean(data.Coherogram.(dataType).(behavField).C,3);
        data.Coherogram.(dataType).(behavField).meanT = mean(data.Coherogram.(dataType).(behavField).t,1);
        data.Coherogram.(dataType).(behavField).meanF = mean(data.Coherogram.(dataType).(behavField).f,1);
        data.Coherogram.(dataType).(behavField).meanLeadC = mean(data.Coherogram.(dataType).(behavField).leadC,2);
        data.Coherogram.(dataType).(behavField).meanLagC = mean(data.Coherogram.(dataType).(behavField).lagC,2);
        data.Coherogram.(dataType).(behavField).meanLeadF = mean(data.Coherogram.(dataType).(behavField).leadf,1);
        data.Coherogram.(dataType).(behavField).meanLagF = mean(data.Coherogram.(dataType).(behavField).lagf,1);
        data.Coherogram.(dataType).(behavField).stdLeadC = std(data.Coherogram.(dataType).(behavField).leadC,0,2)./sqrt(size(data.Coherogram.(dataType).(behavField).leadC,2));
        data.Coherogram.(dataType).(behavField).stdLagC = std(data.Coherogram.(dataType).(behavField).lagC,0,2)./sqrt(size(data.Coherogram.(dataType).(behavField).lagC,2));
    end
end
% find 0:0.21 Hz mean in coherence
for aa = 1:length(dataTypes)
    dataType = dataTypes{1,aa};
    for bb = 1:length(behavFields)
        behavField = behavFields{1,bb};
        for cc = 1:size(data.Coherogram.(dataType).(behavField).leadC,2)
            F = round(data.Coherogram.(dataType).(behavField).leadf(cc,:),2);
            leadC = data.Coherogram.(dataType).(behavField).leadC(:,cc);
            lagC = data.Coherogram.(dataType).(behavField).lagC(:,cc);
            index021 = find(F == 0.21);
            data.Coherogram.(dataType).(behavField).leadC021(cc,1) = mean(leadC(1:index021(1)));
            data.Coherogram.(dataType).(behavField).lagC021(cc,1) = mean(lagC(1:index021(1)));
        end
    end
end
% mean and standard error or standard deviation of coherence data
for aa = 1:length(dataTypes)
    dataType = dataTypes{1,aa};
    for bb = 1:length(behavFields)
        behavField = behavFields{1,bb};
        data.Coherogram.(dataType).(behavField).meanLeadC021 = mean(data.Coherogram.(dataType).(behavField).leadC021,1);
        data.Coherogram.(dataType).(behavField).stdLeadC021 = std(data.Coherogram.(dataType).(behavField).leadC021,0,1);
        data.Coherogram.(dataType).(behavField).meanLagC021 = mean(data.Coherogram.(dataType).(behavField).lagC021,1);
        data.Coherogram.(dataType).(behavField).stdLagC021 = std(data.Coherogram.(dataType).(behavField).lagC021,0,1);
    end
end
% statistics
[HbTCoherStats.h,HbTCoherStats.p,HbTCoherStats.ci,HbTCoherStats.stats] = ttest2(data.Coherogram.HbT.Awake.leadC021,data.Coherogram.HbT.Awake.lagC021);
[GammaCoherStats.h,GammaCoherStats.p,GammaCoherStats.ci,GammaCoherStats.stats] = ttest2(data.Coherogram.gamma.Awake.leadC021,data.Coherogram.gamma.Awake.lagC021);
%% blink spectrogram
resultsStruct = 'Results_BlinkSpectrogram';
load(resultsStruct);
animalIDs = fieldnames(Results_BlinkSpectrogram);
behavFields = {'Awake','Asleep','All'};
dataTypes = {'HbT','gamma'};
% take data from each animal during the different arousal states
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    for bb = 1:length(dataTypes)
        dataType = dataTypes{1,bb};
        data.Spectrogram.(dataType).dummyCheck = 1;
        for cc = 1:length(behavFields)
            behavField = behavFields{1,cc};
            % pre-allocate
            if isfield(data.Spectrogram.(dataType),behavField) == false
                data.Spectrogram.(dataType).(behavField).S = [];
                data.Spectrogram.(dataType).(behavField).f = [];
                data.Spectrogram.(dataType).(behavField).t = [];
                data.Spectrogram.(dataType).(behavField).leadS = [];
                data.Spectrogram.(dataType).(behavField).lagS = [];
                data.Spectrogram.(dataType).(behavField).leadf = [];
                data.Spectrogram.(dataType).(behavField).lagf = [];
            end
            % calculate change in power for spectrogram based on time index
            LH_S = Results_BlinkSpectrogram.(animalID).(dataType).(behavField).LH_S;
            RH_S = Results_BlinkSpectrogram.(animalID).(dataType).(behavField).RH_S;
            meanLH_S = mean(LH_S(:,1:300),2);
            meanRH_S = mean(RH_S(:,1:300),2);
            matLH_S = meanLH_S.*ones(size(LH_S));
            matRH_S = meanRH_S.*ones(size(RH_S));
            msLH_S = ((LH_S - matLH_S)./matLH_S)*.100;
            msRH_S = ((RH_S - matRH_S)./matLH_S)*.100;
            % concatenate power data from each animal
            data.Spectrogram.(dataType).(behavField).S = cat(3,data.Spectrogram.(dataType).(behavField).S,msLH_S,msRH_S);
            data.Spectrogram.(dataType).(behavField).t = cat(1,data.Spectrogram.(dataType).(behavField).t,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).LH_t,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).RH_t);
            data.Spectrogram.(dataType).(behavField).f = cat(1,data.Spectrogram.(dataType).(behavField).f,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).LH_f,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).RH_f);
            data.Spectrogram.(dataType).(behavField).leadS = cat(2,data.Spectrogram.(dataType).(behavField).leadS,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).LH_leadS,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).RH_leadS);
            data.Spectrogram.(dataType).(behavField).lagS = cat(2,data.Spectrogram.(dataType).(behavField).lagS,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).LH_lagS,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).RH_lagS);
            data.Spectrogram.(dataType).(behavField).leadf = cat(1,data.Spectrogram.(dataType).(behavField).leadf,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).LH_leadf,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).RH_leadf);
            data.Spectrogram.(dataType).(behavField).lagf = cat(1,data.Spectrogram.(dataType).(behavField).lagf,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).LH_lagf,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).RH_lagf);
        end
    end
end
% mean and standard error or standard deviation of coherence data
for aa = 1:length(dataTypes)
    dataType = dataTypes{1,aa};
    for bb = 1:length(behavFields)
        behavField = behavFields{1,bb};
        data.Spectrogram.(dataType).(behavField).meanS = mean(data.Spectrogram.(dataType).(behavField).S,3);
        data.Spectrogram.(dataType).(behavField).meanT = mean(data.Spectrogram.(dataType).(behavField).t,1);
        data.Spectrogram.(dataType).(behavField).meanF = mean(data.Spectrogram.(dataType).(behavField).f,1);
        data.Spectrogram.(dataType).(behavField).meanLeadS = mean(data.Spectrogram.(dataType).(behavField).leadS,2);
        data.Spectrogram.(dataType).(behavField).meanLagS = mean(data.Spectrogram.(dataType).(behavField).lagS,2);
        data.Spectrogram.(dataType).(behavField).meanLeadF = mean(data.Spectrogram.(dataType).(behavField).leadf,1);
        data.Spectrogram.(dataType).(behavField).meanLagF = mean(data.Spectrogram.(dataType).(behavField).lagf,1);
        data.Spectrogram.(dataType).(behavField).stdLeadS = std(data.Spectrogram.(dataType).(behavField).leadS,0,2)./sqrt(size(data.Spectrogram.(dataType).(behavField).leadS,2));
        data.Spectrogram.(dataType).(behavField).stdLagS = std(data.Spectrogram.(dataType).(behavField).lagS,0,2)./sqrt(size(data.Spectrogram.(dataType).(behavField).lagS,2));
    end
end
% find 0:0.21 Hz mean in power
for aa = 1:length(dataTypes)
    dataType = dataTypes{1,aa};
    for bb = 1:length(behavFields)
        behavField = behavFields{1,bb};
        for cc = 1:size(data.Spectrogram.(dataType).(behavField).leadS,2)
            F = round(data.Spectrogram.(dataType).(behavField).leadf(cc,:),2);
            leadS = data.Spectrogram.(dataType).(behavField).leadS(:,cc);
            lagS = data.Spectrogram.(dataType).(behavField).lagS(:,cc);
            index021 = find(F == 0.21);
            data.Spectrogram.(dataType).(behavField).leadS021(cc,1) = mean(leadS(1:index021(1)));
            data.Spectrogram.(dataType).(behavField).lagS021(cc,1) = mean(lagS(1:index021(1)));
        end
    end
end
% mean and standard error or standard deviation of coherence data
for aa = 1:length(dataTypes)
    dataType = dataTypes{1,aa};
    for bb = 1:length(behavFields)
        behavField = behavFields{1,bb};
        data.Spectrogram.(dataType).(behavField).meanLeadS021 = mean(data.Spectrogram.(dataType).(behavField).leadS021,1);
        data.Spectrogram.(dataType).(behavField).stdLeadS021 = std(data.Spectrogram.(dataType).(behavField).leadS021,0,1);
        data.Spectrogram.(dataType).(behavField).meanLagS021 = mean(data.Spectrogram.(dataType).(behavField).lagS021,1);
        data.Spectrogram.(dataType).(behavField).stdLagS021 = std(data.Spectrogram.(dataType).(behavField).lagS021,0,1);
    end
end
% statistics
[HbTPowerStats.h,HbTPowerStats.p,HbTPowerStats.ci,HbTPowerStats.stats] = ttest2(data.Spectrogram.HbT.Awake.leadS021,data.Spectrogram.HbT.Awake.lagS021);
[GammaPowerStats.h,GammaPowerStats.p,GammaPowerStats.ci,GammaPowerStats.stats] = ttest2(data.Spectrogram.gamma.Awake.leadS021,data.Spectrogram.gamma.Awake.lagS021);
%% power vs coherence differences
for aa = 1:length(dataTypes)
    dataType = dataTypes{1,aa};
    for bb = 1:length(behavFields)
        behavField = behavFields{1,bb};
        diffPower.(dataType).(behavField) = [];
        diffCoher.(dataType).(behavField) = [];
        % power difference
        for cc = 1:length(data.Spectrogram.(dataType).(behavField).leadS021)
            diffPower.(dataType).(behavField) = cat(1,diffPower.(dataType).(behavField),abs(data.Spectrogram.(dataType).(behavField).leadS021(cc,1) - data.Spectrogram.(dataType).(behavField).lagS021(cc,1)));
        end
        % coherence difference
        for cc = 1:length(data.Coherogram.(dataType).(behavField).leadC021)
            diffCoher.(dataType).(behavField) = cat(1,diffCoher.(dataType).(behavField),abs(data.Coherogram.(dataType).(behavField).leadC021(cc,1) - data.Coherogram.(dataType).(behavField).lagC021(cc,1)),abs(data.Coherogram.(dataType).(behavField).leadC021(cc,1) - data.Coherogram.(dataType).(behavField).lagC021(cc,1)));
        end
    end
end
%% coherence vs. power during awake blinking figure
Fig5A =  figure('Name','Figure Panel 4 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
% awake gamma-band coherogram
ax1 = subplot(4,4,1);
Semilog_ImageSC(data.Coherogram.gamma.Awake.meanT,data.Coherogram.gamma.Awake.meanF,data.Coherogram.gamma.Awake.meanC,'y')
c1 = colorbar;
ylabel(c1,'\DeltaCoherence (%)','rotation',-90,'VerticalAlignment','bottom')
caxis([-0.15,0.05])
ylabel('Freq (Hz)')
xlabel('Time (sec)')
title('Gamma coherogram')
xlim([10,60])
xticks([data.Coherogram.gamma.Awake.meanT(1),15,25,35,45,55,data.Coherogram.gamma.Awake.meanT(end)])
xticklabels({'-30','-20','-10','0','10','20','30'})
axis square
axis xy
set(gca,'box','off')
ax1.TickLength = [0.03,0.03];
% awake gamma-band coherence
ax2 = subplot(4,4,2);
s1 = semilogx(data.Coherogram.gamma.Awake.meanLeadF,data.Coherogram.gamma.Awake.meanLeadC,'color',colors('caribbean green'),'LineWidth',2);
hold on
semilogx(data.Coherogram.gamma.Awake.meanLeadF,data.Coherogram.gamma.Awake.meanLeadC + data.Coherogram.gamma.Awake.stdLeadC,'color',colors('caribbean green'),'LineWidth',0.5)
semilogx(data.Coherogram.gamma.Awake.meanLeadF,data.Coherogram.gamma.Awake.meanLeadC - data.Coherogram.gamma.Awake.stdLeadC,'color',colors('caribbean green'),'LineWidth',0.5)
s2 = semilogx(data.Coherogram.gamma.Awake.meanLagF,data.Coherogram.gamma.Awake.meanLagC,'color',colors('caribbean blue'),'LineWidth',2);
semilogx(data.Coherogram.gamma.Awake.meanLagF,data.Coherogram.gamma.Awake.meanLagC + data.Coherogram.gamma.Awake.stdLagC,'color',colors('caribbean blue'),'LineWidth',0.5)
semilogx(data.Coherogram.gamma.Awake.meanLagF,data.Coherogram.gamma.Awake.meanLagC - data.Coherogram.gamma.Awake.stdLagC,'color',colors('caribbean blue'),'LineWidth',0.5)
xline(0.21,'color',colors('black'),'LineWidth',2)
axis tight
ylabel('Coherence')
xlabel('Freq (Hz)')
title('Gamma lead/lag coherence')
legend([s1,s2],'lead blink','lag blink')
axis square
xlim([1/10,3])
ylim([0.1,0.45])
set(gca,'box','off')
ax2.TickLength = [0.03,0.03];
% awake gamma-band coherence scatter
ax3 = subplot(4,4,3);
scatter(ones(1,length(data.Coherogram.gamma.Awake.leadC021))*1,data.Coherogram.gamma.Awake.leadC021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('caribbean green'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.Coherogram.gamma.Awake.meanLeadC021,data.Coherogram.gamma.Awake.stdLeadC021,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.Coherogram.gamma.Awake.lagC021))*2,data.Coherogram.gamma.Awake.lagC021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('caribbean blue'),'jitter','on','jitterAmount',0.25);
hold on
e2 = errorbar(2,data.Coherogram.gamma.Awake.meanLagC021,data.Coherogram.gamma.Awake.stdLagC021,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
ylabel('Coherence')
title('Gamma coherence from 0-0.2 Hz')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,3])
ylim([0,0.6])
set(gca,'box','off')
ax3.TickLength = [0.03,0.03];
% awake gamma-band coherence vs. power change
ax4 = subplot(4,4,[4,8]);
scatter(diffPower.gamma.Awake,diffCoher.gamma.Awake,75,'MarkerEdgeColor',colors('caribbean green'),'MarkerFaceColor',colors('caribbean blue'))
xlabel('\DeltaPower')
ylabel('\DeltaCoherence')
title('Gamma lead/lag blink')
axis square
set(gca,'box','off')
set(gca,'xscale','log')
ax4.TickLength = [0.03,0.03];
% awake gamma-band spectrogram
ax5 = subplot(4,4,5);
Semilog_ImageSC(data.Spectrogram.gamma.Awake.meanT,data.Spectrogram.gamma.Awake.meanF,data.Spectrogram.gamma.Awake.meanS,'y')
c1 = colorbar;
ylabel(c1,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
caxis([-0.15,0.05])
ylabel('Freq (Hz)')
xlabel('Time (sec)')
title('Gamma spectrogram')
xlim([10,60])
xticks([data.Spectrogram.gamma.Awake.meanT(1),15,25,35,45,55,data.Spectrogram.gamma.Awake.meanT(end)])
xticklabels({'-30','-20','-10','0','10','20','30'})
axis square
axis xy
set(gca,'box','off')
ax5.TickLength = [0.03,0.03];
% awake gamma-band power
ax6 = subplot(4,4,6);
loglog(data.Spectrogram.gamma.Awake.meanLeadF,data.Spectrogram.gamma.Awake.meanLeadS,'color',colors('caribbean green'),'LineWidth',2);
hold on;
loglog(data.Spectrogram.gamma.Awake.meanLeadF,data.Spectrogram.gamma.Awake.meanLeadS + data.Spectrogram.gamma.Awake.stdLeadS,'color',colors('caribbean green'),'LineWidth',0.5);
loglog(data.Spectrogram.gamma.Awake.meanLeadF,data.Spectrogram.gamma.Awake.meanLeadS - data.Spectrogram.gamma.Awake.stdLeadS,'color',colors('caribbean green'),'LineWidth',0.5);
loglog(data.Spectrogram.gamma.Awake.meanLagF,data.Spectrogram.gamma.Awake.meanLagS,'color',colors('caribbean blue'),'LineWidth',2);
loglog(data.Spectrogram.gamma.Awake.meanLagF,data.Spectrogram.gamma.Awake.meanLagS + data.Spectrogram.gamma.Awake.stdLagS,'color',colors('caribbean blue'),'LineWidth',0.5);
loglog(data.Spectrogram.gamma.Awake.meanLagF,data.Spectrogram.gamma.Awake.meanLagS - data.Spectrogram.gamma.Awake.stdLagS,'color',colors('caribbean blue'),'LineWidth',0.5);
xline(0.21,'color',colors('black'),'LineWidth',2)
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
title('Gamma lead/lag power')
axis square
axis tight
xlim([1/10,3])
set(gca,'box','off')
ax6.TickLength = [0.03,0.03];
% awake gamma-band power scatter
ax7 = subplot(4,4,7);
scatter(ones(1,length(data.Spectrogram.gamma.Awake.leadS021))*1,data.Spectrogram.gamma.Awake.leadS021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('caribbean green'),'jitter','on','jitterAmount',0.25);
hold on
scatter(1,data.Spectrogram.gamma.Awake.meanLeadS021,100,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.Spectrogram.gamma.Awake.lagS021))*2,data.Spectrogram.gamma.Awake.lagS021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('caribbean blue'),'jitter','on','jitterAmount',0.25);
scatter(2,data.Spectrogram.gamma.Awake.meanLagS021,100,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
ylabel('Power (a.u.)')
title('Gamma power from 0-0.2 Hz')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,3])
ylim([4.5e-23,5.5e-17])
set(gca,'box','off')
set(gca,'yscale','log')
ax7.TickLength = [0.03,0.03];
% awake HbT coherogram
ax9 = subplot(4,4,9);
Semilog_ImageSC(data.Coherogram.HbT.Awake.meanT,data.Coherogram.HbT.Awake.meanF,data.Coherogram.HbT.Awake.meanC,'y')
c1 = colorbar;
ylabel(c1,'\DeltaCoherence (%)','rotation',-90,'VerticalAlignment','bottom')
caxis([-0.05,0.05])
ylabel('Freq (Hz)')
xlabel('Time (sec)')
title('HbT coherogram')
xlim([10,60])
xticks([data.Coherogram.gamma.Awake.meanT(1),15,25,35,45,55,data.Coherogram.gamma.Awake.meanT(end)])
xticklabels({'-30','-20','-10','0','10','20','30'})
axis square
axis xy
set(gca,'box','off')
ax9.TickLength = [0.03,0.03];
% awake HbT coherence
ax10 = subplot(4,4,10);
s1 = semilogx(data.Coherogram.HbT.Awake.meanLeadF,data.Coherogram.HbT.Awake.meanLeadC,'color',colors('candy apple red'),'LineWidth',2);
hold on
semilogx(data.Coherogram.HbT.Awake.meanLeadF,data.Coherogram.HbT.Awake.meanLeadC + data.Coherogram.HbT.Awake.stdLeadC,'color',colors('candy apple red'),'LineWidth',0.5)
semilogx(data.Coherogram.HbT.Awake.meanLeadF,data.Coherogram.HbT.Awake.meanLeadC - data.Coherogram.HbT.Awake.stdLeadC,'color',colors('candy apple red'),'LineWidth',0.5)
s2 = semilogx(data.Coherogram.HbT.Awake.meanLagF,data.Coherogram.HbT.Awake.meanLagC,'color',colors('deep carrot orange'),'LineWidth',2);
semilogx(data.Coherogram.HbT.Awake.meanLagF,data.Coherogram.HbT.Awake.meanLagC + data.Coherogram.HbT.Awake.stdLagC,'color',colors('deep carrot orange'),'LineWidth',0.5)
semilogx(data.Coherogram.HbT.Awake.meanLagF,data.Coherogram.HbT.Awake.meanLagC - data.Coherogram.HbT.Awake.stdLagC,'color',colors('deep carrot orange'),'LineWidth',0.5)
xline(0.21,'color',colors('black'),'LineWidth',2)
axis tight
ylabel('Coherence')
xlabel('Freq (Hz)')
title('HbT lead/lag coherence')
legend([s1,s2],'lead blink','lag blink')
xlim([1/10,3])
ylim([0.75,0.9])
axis square
set(gca,'box','off')
ax10.TickLength = [0.03,0.03];
% awake HbT coherence scatter
ax11 = subplot(4,4,11);
scatter(ones(1,length(data.Coherogram.HbT.Awake.leadC021))*1,data.Coherogram.HbT.Awake.leadC021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('candy apple red'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.Coherogram.HbT.Awake.meanLeadC021,data.Coherogram.HbT.Awake.stdLeadC021,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.Coherogram.HbT.Awake.lagC021))*2,data.Coherogram.HbT.Awake.lagC021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('deep carrot orange'),'jitter','on','jitterAmount',0.25);
hold on
e2 = errorbar(2,data.Coherogram.HbT.Awake.meanLagC021,data.Coherogram.HbT.Awake.stdLagC021,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
ylabel('Coherence')
title('HbT coherence from 0-0.2 Hz')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,3])
ylim([0.7,0.95])
set(gca,'box','off')
ax11.TickLength = [0.03,0.03];
% awake HbT coherence vs. power change
ax12 = subplot(4,4,[12,16]);
scatter(diffPower.HbT.Awake,diffCoher.HbT.Awake,75,'MarkerEdgeColor',colors('candy apple red'),'MarkerFaceColor',colors('deep carrot orange'))
xlabel('\DeltaPower')
ylabel('\DeltaCoherence')
title('HbT lead/lag blink')
axis square
set(gca,'box','off')
set(gca,'xscale','log')
ax12.TickLength = [0.03,0.03];
% awake HbT spectrogram
ax13 = subplot(4,4,13);
Semilog_ImageSC(data.Spectrogram.HbT.Awake.meanT,data.Spectrogram.HbT.Awake.meanF,data.Spectrogram.HbT.Awake.meanS,'y')
c1 = colorbar;
ylabel(c1,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
caxis([-0.05,0.05])
ylabel('Freq (Hz)')
xlabel('Time (sec)')
title('HbT spectrogram')
xlim([10,60])
xticks([data.Spectrogram.HbT.Awake.meanT(1),15,25,35,45,55,data.Spectrogram.HbT.Awake.meanT(end)])
xticklabels({'-30','-20','-10','0','10','20','30'})
axis square
axis xy
set(gca,'box','off')
ax13.TickLength = [0.03,0.03];
% awake HbT power
ax14 = subplot(4,4,14);
loglog(data.Spectrogram.HbT.Awake.meanLeadF,data.Spectrogram.HbT.Awake.meanLeadS,'color',colors('candy apple red'),'LineWidth',2);
hold on;
loglog(data.Spectrogram.HbT.Awake.meanLeadF,data.Spectrogram.HbT.Awake.meanLeadS + data.Spectrogram.HbT.Awake.stdLeadS,'color',colors('candy apple red'),'LineWidth',0.5);
loglog(data.Spectrogram.HbT.Awake.meanLeadF,data.Spectrogram.HbT.Awake.meanLeadS - data.Spectrogram.HbT.Awake.stdLeadS,'color',colors('candy apple red'),'LineWidth',0.5);
loglog(data.Spectrogram.HbT.Awake.meanLagF,data.Spectrogram.HbT.Awake.meanLagS,'color',colors('deep carrot orange'),'LineWidth',2);
loglog(data.Spectrogram.HbT.Awake.meanLagF,data.Spectrogram.HbT.Awake.meanLagS + data.Spectrogram.HbT.Awake.stdLagS,'color',colors('deep carrot orange'),'LineWidth',0.5);
loglog(data.Spectrogram.HbT.Awake.meanLagF,data.Spectrogram.HbT.Awake.meanLagS - data.Spectrogram.HbT.Awake.stdLagS,'color',colors('deep carrot orange'),'LineWidth',0.5);
xline(0.21,'color',colors('black'),'LineWidth',2)
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
title('HbT lead/lag power')
axis square
axis tight
xlim([1/10,3])
set(gca,'box','off')
ax14.TickLength = [0.03,0.03];
% awake HbT power scatter
ax15 = subplot(4,4,15);
scatter(ones(1,length(data.Spectrogram.HbT.Awake.leadS021))*1,data.Spectrogram.HbT.Awake.leadS021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('candy apple red'),'jitter','on','jitterAmount',0.25);
hold on
scatter(1,data.Spectrogram.HbT.Awake.meanLeadS021,100,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
scatter(ones(1,length(data.Spectrogram.HbT.Awake.lagS021))*2,data.Spectrogram.HbT.Awake.lagS021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('deep carrot orange'),'jitter','on','jitterAmount',0.25);
scatter(2,data.Spectrogram.HbT.Awake.meanLagS021,100,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
ylabel('Power (a.u.)')
title('HbT power from 0-0.2 Hz')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,3])
ylim([0,300])
set(gca,'box','off')
set(gca,'yscale','log')
ax15.TickLength = [0.03,0.03];
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'Summary Figures and Structures' delim 'Figure Panels' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig5A,[dirpath 'Fig4_JNeurosci2022']);
    % remove surface subplots because they take forever to render
    cla(ax1);
    set(ax1,'YLim',[0,3]);
    cla(ax5);
    set(ax5,'YLim',[0,3]);
    cla(ax9);
    set(ax9,'YLim',[0,3]);
    cla(ax13);
    set(ax13,'YLim',[0,3]);
    set(Fig5A,'PaperPositionMode','auto');
    print('-vector','-dpdf','-bestfit',[dirpath 'Fig5A_JNeurosci2022'])
    close(Fig5A)
    % subplot figure
    subplotImgs = figure('Name','Figure Panel 4 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
    % example 1 LH cortical LFP
    subplot(2,2,1)
    Semilog_ImageSC(data.Coherogram.gamma.Awake.meanT,data.Coherogram.gamma.Awake.meanF,data.Coherogram.gamma.Awake.meanC,'y')
    xlim([10,60])
    caxis([-0.15,0.05])
    axis square
    axis xy
    axis off
    set(gca,'box','off')
    subplot(2,2,2)
    Semilog_ImageSC(data.Spectrogram.gamma.Awake.meanT,data.Spectrogram.gamma.Awake.meanF,data.Spectrogram.gamma.Awake.meanS,'y')
    xlim([10,60])
    caxis([-0.15,0.05])
    axis square
    axis xy
    axis off
    subplot(2,2,3)
    Semilog_ImageSC(data.Coherogram.HbT.Awake.meanT,data.Coherogram.HbT.Awake.meanF,data.Coherogram.HbT.Awake.meanC,'y')
    xlim([10,60])
    caxis([-0.15,0.05])
    axis square
    axis xy
    axis off
    set(gca,'box','off')
    subplot(2,2,4)
    Semilog_ImageSC(data.Spectrogram.HbT.Awake.meanT,data.Spectrogram.HbT.Awake.meanF,data.Spectrogram.HbT.Awake.meanS,'y')
    xlim([10,60])
    caxis([-0.15,0.05])
    axis square
    axis xy
    axis off
    set(gca,'box','off')
    print('-vector','-dtiffn',[dirpath 'Fig4_CohImages'])
    close(subplotImgs)
    % coherence vs. power during awake blinking figure
    figure('Name','Figure Panel 4 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
    % awake gamma-band coherogram
    ax1 = subplot(4,4,1);
    Semilog_ImageSC(data.Coherogram.gamma.Awake.meanT,data.Coherogram.gamma.Awake.meanF,data.Coherogram.gamma.Awake.meanC,'y')
    c1 = colorbar;
    ylabel(c1,'\DeltaCoherence (%)','rotation',-90,'VerticalAlignment','bottom')
    caxis([-0.15,0.05])
    ylabel('Freq (Hz)')
    xlabel('Time (sec)')
    title('Gamma coherogram')
    xlim([10,60])
    xticks([data.Coherogram.gamma.Awake.meanT(1),15,25,35,45,55,data.Coherogram.gamma.Awake.meanT(end)])
    xticklabels({'-30','-20','-10','0','10','20','30'})
    axis square
    axis xy
    set(gca,'box','off')
    ax1.TickLength = [0.03,0.03];
    % awake gamma-band coherence
    ax2 = subplot(4,4,2);
    s1 = semilogx(data.Coherogram.gamma.Awake.meanLeadF,data.Coherogram.gamma.Awake.meanLeadC,'color',colors('caribbean green'),'LineWidth',2);
    hold on
    semilogx(data.Coherogram.gamma.Awake.meanLeadF,data.Coherogram.gamma.Awake.meanLeadC + data.Coherogram.gamma.Awake.stdLeadC,'color',colors('caribbean green'),'LineWidth',0.5)
    semilogx(data.Coherogram.gamma.Awake.meanLeadF,data.Coherogram.gamma.Awake.meanLeadC - data.Coherogram.gamma.Awake.stdLeadC,'color',colors('caribbean green'),'LineWidth',0.5)
    s2 = semilogx(data.Coherogram.gamma.Awake.meanLagF,data.Coherogram.gamma.Awake.meanLagC,'color',colors('caribbean blue'),'LineWidth',2);
    semilogx(data.Coherogram.gamma.Awake.meanLagF,data.Coherogram.gamma.Awake.meanLagC + data.Coherogram.gamma.Awake.stdLagC,'color',colors('caribbean blue'),'LineWidth',0.5)
    semilogx(data.Coherogram.gamma.Awake.meanLagF,data.Coherogram.gamma.Awake.meanLagC - data.Coherogram.gamma.Awake.stdLagC,'color',colors('caribbean blue'),'LineWidth',0.5)
    xline(0.21,'color',colors('black'),'LineWidth',2)
    axis tight
    ylabel('Coherence')
    xlabel('Freq (Hz)')
    title('Gamma lead/lag coherence')
    legend([s1,s2],'lead blink','lag blink')
    axis square
    xlim([1/10,3])
    ylim([0.1,0.45])
    set(gca,'box','off')
    ax2.TickLength = [0.03,0.03];
    % awake gamma-band coherence scatter
    ax3 = subplot(4,4,3);
    scatter(ones(1,length(data.Coherogram.gamma.Awake.leadC021))*1,data.Coherogram.gamma.Awake.leadC021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('caribbean green'),'jitter','on','jitterAmount',0.25);
    hold on
    e1 = errorbar(1,data.Coherogram.gamma.Awake.meanLeadC021,data.Coherogram.gamma.Awake.stdLeadC021,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
    e1.Color = 'black';
    e1.MarkerSize = 10;
    e1.CapSize = 10;
    scatter(ones(1,length(data.Coherogram.gamma.Awake.lagC021))*2,data.Coherogram.gamma.Awake.lagC021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('caribbean blue'),'jitter','on','jitterAmount',0.25);
    hold on
    e2 = errorbar(2,data.Coherogram.gamma.Awake.meanLagC021,data.Coherogram.gamma.Awake.stdLagC021,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
    e2.Color = 'black';
    e2.MarkerSize = 10;
    e2.CapSize = 10;
    ylabel('Coherence')
    title('Gamma coherence from 0-0.2 Hz')
    set(gca,'xtick',[])
    set(gca,'xticklabel',[])
    axis square
    xlim([0,3])
    ylim([0,0.6])
    set(gca,'box','off')
    ax3.TickLength = [0.03,0.03];
    % awake gamma-band coherence vs. power change
    ax4 = subplot(4,4,[4,8]);
    scatter(diffPower.gamma.Awake,diffCoher.gamma.Awake,75,'MarkerEdgeColor',colors('caribbean green'),'MarkerFaceColor',colors('caribbean blue'))
    xlabel('\DeltaPower')
    ylabel('\DeltaCoherence')
    title('Gamma lead/lag blink')
    axis square
    set(gca,'box','off')
    set(gca,'xscale','log')
    ax4.TickLength = [0.03,0.03];
    % awake gamma-band spectrogram
    ax4 = subplot(4,4,5);
    Semilog_ImageSC(data.Spectrogram.gamma.Awake.meanT,data.Spectrogram.gamma.Awake.meanF,data.Spectrogram.gamma.Awake.meanS,'y')
    c1 = colorbar;
    ylabel(c1,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
    caxis([-0.15,0.05])
    ylabel('Freq (Hz)')
    xlabel('Time (sec)')
    title('Gamma spectrogram')
    xlim([10,60])
    xticks([data.Spectrogram.gamma.Awake.meanT(1),15,25,35,45,55,data.Spectrogram.gamma.Awake.meanT(end)])
    xticklabels({'-30','-20','-10','0','10','20','30'})
    axis square
    axis xy
    set(gca,'box','off')
    ax4.TickLength = [0.03,0.03];
    % awake gamma-band power
    ax6 = subplot(4,4,6);
    loglog(data.Spectrogram.gamma.Awake.meanLeadF,data.Spectrogram.gamma.Awake.meanLeadS,'color',colors('caribbean green'),'LineWidth',2);
    hold on;
    loglog(data.Spectrogram.gamma.Awake.meanLeadF,data.Spectrogram.gamma.Awake.meanLeadS + data.Spectrogram.gamma.Awake.stdLeadS,'color',colors('caribbean green'),'LineWidth',0.5);
    loglog(data.Spectrogram.gamma.Awake.meanLeadF,data.Spectrogram.gamma.Awake.meanLeadS - data.Spectrogram.gamma.Awake.stdLeadS,'color',colors('caribbean green'),'LineWidth',0.5);
    loglog(data.Spectrogram.gamma.Awake.meanLagF,data.Spectrogram.gamma.Awake.meanLagS,'color',colors('caribbean blue'),'LineWidth',2);
    loglog(data.Spectrogram.gamma.Awake.meanLagF,data.Spectrogram.gamma.Awake.meanLagS + data.Spectrogram.gamma.Awake.stdLagS,'color',colors('caribbean blue'),'LineWidth',0.5);
    loglog(data.Spectrogram.gamma.Awake.meanLagF,data.Spectrogram.gamma.Awake.meanLagS - data.Spectrogram.gamma.Awake.stdLagS,'color',colors('caribbean blue'),'LineWidth',0.5);
    xline(0.21,'color',colors('black'),'LineWidth',2)
    ylabel('Power (a.u.)')
    xlabel('Freq (Hz)')
    title('Gamma lead/lag power')
    axis square
    axis tight
    xlim([1/10,3])
    set(gca,'box','off')
    ax6.TickLength = [0.03,0.03];
    % awake gamma-band power scatter
    ax7 = subplot(4,4,7);
    scatter(ones(1,length(data.Spectrogram.gamma.Awake.leadS021))*1,data.Spectrogram.gamma.Awake.leadS021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('caribbean green'),'jitter','on','jitterAmount',0.25);
    hold on
    scatter(1,data.Spectrogram.gamma.Awake.meanLeadS021,100,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
    e1.MarkerSize = 10;
    e1.CapSize = 10;
    scatter(ones(1,length(data.Spectrogram.gamma.Awake.lagS021))*2,data.Spectrogram.gamma.Awake.lagS021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('caribbean blue'),'jitter','on','jitterAmount',0.25);
    scatter(2,data.Spectrogram.gamma.Awake.meanLagS021,100,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
    ylabel('Power (a.u.)')
    title('Gamma power from 0-0.2 Hz')
    set(gca,'xtick',[])
    set(gca,'xticklabel',[])
    axis square
    xlim([0,3])
    ylim([4.5e-23,5.5e-17])
    set(gca,'box','off')
    set(gca,'yscale','log')
    ax7.TickLength = [0.03,0.03];
    % awake HbT coherogram
    ax9 = subplot(4,4,9);
    Semilog_ImageSC(data.Coherogram.HbT.Awake.meanT,data.Coherogram.HbT.Awake.meanF,data.Coherogram.HbT.Awake.meanC,'y')
    c1 = colorbar;
    ylabel(c1,'\DeltaCoherence (%)','rotation',-90,'VerticalAlignment','bottom')
    caxis([-0.05,0.05])
    ylabel('Freq (Hz)')
    xlabel('Time (sec)')
    title('HbT coherogram')
    xlim([10,60])
    xticks([data.Coherogram.gamma.Awake.meanT(1),15,25,35,45,55,data.Coherogram.gamma.Awake.meanT(end)])
    xticklabels({'-30','-20','-10','0','10','20','30'})
    axis square
    axis xy
    set(gca,'box','off')
    ax9.TickLength = [0.03,0.03];
    % awake HbT coherence
    ax10 = subplot(4,4,10);
    s1 = semilogx(data.Coherogram.HbT.Awake.meanLeadF,data.Coherogram.HbT.Awake.meanLeadC,'color',colors('candy apple red'),'LineWidth',2);
    hold on
    semilogx(data.Coherogram.HbT.Awake.meanLeadF,data.Coherogram.HbT.Awake.meanLeadC + data.Coherogram.HbT.Awake.stdLeadC,'color',colors('candy apple red'),'LineWidth',0.5)
    semilogx(data.Coherogram.HbT.Awake.meanLeadF,data.Coherogram.HbT.Awake.meanLeadC - data.Coherogram.HbT.Awake.stdLeadC,'color',colors('candy apple red'),'LineWidth',0.5)
    s2 = semilogx(data.Coherogram.HbT.Awake.meanLagF,data.Coherogram.HbT.Awake.meanLagC,'color',colors('deep carrot orange'),'LineWidth',2);
    semilogx(data.Coherogram.HbT.Awake.meanLagF,data.Coherogram.HbT.Awake.meanLagC + data.Coherogram.HbT.Awake.stdLagC,'color',colors('deep carrot orange'),'LineWidth',0.5)
    semilogx(data.Coherogram.HbT.Awake.meanLagF,data.Coherogram.HbT.Awake.meanLagC - data.Coherogram.HbT.Awake.stdLagC,'color',colors('deep carrot orange'),'LineWidth',0.5)
    xline(0.21,'color',colors('black'),'LineWidth',2)
    axis tight
    ylabel('Coherence')
    xlabel('Freq (Hz)')
    title('HbT lead/lag coherence')
    legend([s1,s2],'lead blink','lag blink')
    xlim([1/10,3])
    ylim([0.75,0.9])
    axis square
    set(gca,'box','off')
    ax10.TickLength = [0.03,0.03];
    % awake HbT coherence scatter
    ax11 = subplot(4,4,11);
    scatter(ones(1,length(data.Coherogram.HbT.Awake.leadC021))*1,data.Coherogram.HbT.Awake.leadC021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('candy apple red'),'jitter','on','jitterAmount',0.25);
    hold on
    e1 = errorbar(1,data.Coherogram.HbT.Awake.meanLeadC021,data.Coherogram.HbT.Awake.stdLeadC021,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
    e1.Color = 'black';
    e1.MarkerSize = 10;
    e1.CapSize = 10;
    scatter(ones(1,length(data.Coherogram.HbT.Awake.lagC021))*2,data.Coherogram.HbT.Awake.lagC021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('deep carrot orange'),'jitter','on','jitterAmount',0.25);
    hold on
    e2 = errorbar(2,data.Coherogram.HbT.Awake.meanLagC021,data.Coherogram.HbT.Awake.stdLagC021,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
    e2.Color = 'black';
    e2.MarkerSize = 10;
    e2.CapSize = 10;
    ylabel('Coherence')
    title('HbT coherence from 0-0.2 Hz')
    set(gca,'xtick',[])
    set(gca,'xticklabel',[])
    axis square
    xlim([0,3])
    ylim([0.7,0.95])
    set(gca,'box','off')
    ax11.TickLength = [0.03,0.03];
    % awake HbT coherence vs. power change
    ax12 = subplot(4,4,[12,16]);
    scatter(diffPower.HbT.Awake,diffCoher.HbT.Awake,75,'MarkerEdgeColor',colors('candy apple red'),'MarkerFaceColor',colors('deep carrot orange'))
    xlabel('\DeltaPower')
    ylabel('\DeltaCoherence')
    title('HbT lead/lag blink')
    axis square
    set(gca,'box','off')
    set(gca,'xscale','log')
    ax12.TickLength = [0.03,0.03];
    % awake HbT spectrogram
    ax13 = subplot(4,4,13);
    Semilog_ImageSC(data.Spectrogram.HbT.Awake.meanT,data.Spectrogram.HbT.Awake.meanF,data.Spectrogram.HbT.Awake.meanS,'y')
    c1 = colorbar;
    ylabel(c1,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
    caxis([-0.05,0.05])
    ylabel('Freq (Hz)')
    xlabel('Time (sec)')
    title('HbT spectrogram')
    xlim([10,60])
    xticks([data.Spectrogram.HbT.Awake.meanT(1),15,25,35,45,55,data.Spectrogram.HbT.Awake.meanT(end)])
    xticklabels({'-30','-20','-10','0','10','20','30'})
    axis square
    axis xy
    set(gca,'box','off')
    ax13.TickLength = [0.03,0.03];
    % awake HbT power
    ax14 = subplot(4,4,14);
    loglog(data.Spectrogram.HbT.Awake.meanLeadF,data.Spectrogram.HbT.Awake.meanLeadS,'color',colors('candy apple red'),'LineWidth',2);
    hold on;
    loglog(data.Spectrogram.HbT.Awake.meanLeadF,data.Spectrogram.HbT.Awake.meanLeadS + data.Spectrogram.HbT.Awake.stdLeadS,'color',colors('candy apple red'),'LineWidth',0.5);
    loglog(data.Spectrogram.HbT.Awake.meanLeadF,data.Spectrogram.HbT.Awake.meanLeadS - data.Spectrogram.HbT.Awake.stdLeadS,'color',colors('candy apple red'),'LineWidth',0.5);
    loglog(data.Spectrogram.HbT.Awake.meanLagF,data.Spectrogram.HbT.Awake.meanLagS,'color',colors('deep carrot orange'),'LineWidth',2);
    loglog(data.Spectrogram.HbT.Awake.meanLagF,data.Spectrogram.HbT.Awake.meanLagS + data.Spectrogram.HbT.Awake.stdLagS,'color',colors('deep carrot orange'),'LineWidth',0.5);
    loglog(data.Spectrogram.HbT.Awake.meanLagF,data.Spectrogram.HbT.Awake.meanLagS - data.Spectrogram.HbT.Awake.stdLagS,'color',colors('deep carrot orange'),'LineWidth',0.5);
    xline(0.21,'color',colors('black'),'LineWidth',2)
    ylabel('Power (a.u.)')
    xlabel('Freq (Hz)')
    title('HbT lead/lag power')
    axis square
    axis tight
    xlim([1/10,3])
    set(gca,'box','off')
    ax14.TickLength = [0.03,0.03];
    % awake HbT power scatter
    ax15 = subplot(4,4,15);
    scatter(ones(1,length(data.Spectrogram.HbT.Awake.leadS021))*1,data.Spectrogram.HbT.Awake.leadS021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('candy apple red'),'jitter','on','jitterAmount',0.25);
    hold on
    scatter(1,data.Spectrogram.HbT.Awake.meanLeadS021,100,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
    scatter(ones(1,length(data.Spectrogram.HbT.Awake.lagS021))*2,data.Spectrogram.HbT.Awake.lagS021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('deep carrot orange'),'jitter','on','jitterAmount',0.25);
    scatter(2,data.Spectrogram.HbT.Awake.meanLagS021,100,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
    ylabel('Power (a.u.)')
    title('HbT power from 0-0.2 Hz')
    set(gca,'xtick',[])
    set(gca,'xticklabel',[])
    axis square
    xlim([0,3])
    ylim([0,300])
    set(gca,'box','off')
    set(gca,'yscale','log')
    ax15.TickLength = [0.03,0.03];
    % text diary
    diaryFile = [dirpath 'Fig4_Text.txt'];
    if exist(diaryFile,'file') == 2
        delete(diaryFile)
    end
    diary(diaryFile)
    diary on
    % coherence and power statistics
    disp('======================================================================================================================')
    disp('Gamma-band lead vs. lag coherence statistics')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Gamma-band lead coherence ' num2str(data.Coherogram.gamma.Awake.meanLeadC021) ' +/- ' num2str(data.Coherogram.gamma.Awake.stdLeadC021) ' (n = ' num2str(length(data.Coherogram.gamma.Awake.leadC021)) ') mice']); disp(' ')
    disp(['Gamma-band lag coherence ' num2str(data.Coherogram.gamma.Awake.meanLagC021) ' +/- ' num2str(data.Coherogram.gamma.Awake.stdLagC021) ' (n = ' num2str(length(data.Coherogram.gamma.Awake.lagC021)) ') mice']); disp(' ')
    disp(['Lead vs. Lag coherence p < ' num2str(GammaCoherStats.p)]); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp('======================================================================================================================')
    disp('Gamma-band lead vs. lag power statistics')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Gamma-band lead power ' num2str(data.Spectrogram.gamma.Awake.meanLeadS021) ' +/- ' num2str(data.Spectrogram.gamma.Awake.stdLeadS021) ' (n = ' num2str(length(data.Spectrogram.gamma.Awake.leadS021)/2) ') mice']); disp(' ')
    disp(['Gamma-band lag power ' num2str(data.Spectrogram.gamma.Awake.meanLagS021) ' +/- ' num2str(data.Spectrogram.gamma.Awake.stdLagS021) ' (n = ' num2str(length(data.Spectrogram.gamma.Awake.lagS021)/2) ') mice']); disp(' ')
    disp(['Lead vs. Lag power p < ' num2str(GammaPowerStats.p)]); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp('======================================================================================================================')
    disp('HbT lead vs. lag coherence statistics')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['HbT lead coherence ' num2str(data.Coherogram.HbT.Awake.meanLeadC021) ' +/- ' num2str(data.Coherogram.HbT.Awake.stdLeadC021) ' (n = ' num2str(length(data.Coherogram.HbT.Awake.leadC021)) ') mice']); disp(' ')
    disp(['HbT lag coherence ' num2str(data.Coherogram.HbT.Awake.meanLagC021) ' +/- ' num2str(data.Coherogram.HbT.Awake.stdLagC021) ' (n = ' num2str(length(data.Coherogram.HbT.Awake.lagC021)) ') mice']); disp(' ')
    disp(['Lead vs. Lag coherence p < ' num2str(HbTCoherStats.p)]); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp('======================================================================================================================')
    disp('HbT lead vs. lag power statistics')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['HbT lead power ' num2str(data.Spectrogram.HbT.Awake.meanLeadS021) ' +/- ' num2str(data.Spectrogram.HbT.Awake.stdLeadS021) ' (n = ' num2str(length(data.Spectrogram.HbT.Awake.leadS021)/2) ') mice']); disp(' ')
    disp(['HbT lag power ' num2str(data.Spectrogram.HbT.Awake.meanLagS021) ' +/- ' num2str(data.Spectrogram.HbT.Awake.stdLagS021) ' (n = ' num2str(length(data.Spectrogram.HbT.Awake.lagS021)/2) ') mice']); disp(' ')
    disp(['Lead vs. Lag power p < ' num2str(HbTPowerStats.p)]); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    diary off
end

end
