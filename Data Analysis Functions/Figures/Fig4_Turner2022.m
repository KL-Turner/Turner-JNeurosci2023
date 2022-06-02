function [] = Fig4_Turner2022(rootFolder,saveFigs,delim)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: Generate figures and supporting information for Figure Panel 4
%________________________________________________________________________________________________________________________

%% blink coherogram
resultsStruct = 'Results_BlinkCoherogram.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_BlinkCoherogram);
animalIDs(ismember(animalIDs,'T189')) = [];
% behavFields = {'Awake','Asleep','All'};
behavFields = {'Awake','Asleep'};
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
[AwakeHbTCoherStats.h,AwakeHbTCoherStats.p,AwakeHbTCoherStats.ci,AwakeHbTCoherStats.stats] = ttest2(data.Coherogram.HbT.Awake.leadC021,data.Coherogram.HbT.Awake.lagC021);
[AwakeGammaCoherStats.h,AwakeGammaCoherStats.p,AwakeGammaCoherStats.ci,AwakeGammaCoherStats.stats] = ttest2(data.Coherogram.gamma.Awake.leadC021,data.Coherogram.gamma.Awake.lagC021);
[AsleepHbTCoherStats.h,AsleepHbTCoherStats.p,AsleepHbTCoherStats.ci,AsleepHbTCoherStats.stats] = ttest2(data.Coherogram.HbT.Asleep.leadC021,data.Coherogram.HbT.Asleep.lagC021);
[AsleepGammaCoherStats.h,AsleepGammaCoherStats.p,AsleepGammaCoherStats.ci,AsleepGammaCoherStats.stats] = ttest2(data.Coherogram.gamma.Asleep.leadC021,data.Coherogram.gamma.Asleep.lagC021);
%% blink spectrogram
resultsStruct = 'Results_BlinkSpectrogram.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_BlinkSpectrogram);
animalIDs(ismember(animalIDs,'T189')) = [];
% behavFields = {'Awake','Asleep','All'};
behavFields = {'Awake','Asleep'};
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
            if strcmp(dataType,'gamma') == true
                LH_S = Results_BlinkSpectrogram.(animalID).(dataType).(behavField).LH_S*10e18;
                RH_S = Results_BlinkSpectrogram.(animalID).(dataType).(behavField).RH_S*10e18;
            else
                LH_S = Results_BlinkSpectrogram.(animalID).(dataType).(behavField).LH_S;
                RH_S = Results_BlinkSpectrogram.(animalID).(dataType).(behavField).RH_S;
            end
            meanLH_S = mean(LH_S(:,1:300),2);
            meanRH_S = mean(RH_S(:,1:300),2);
            matLH_S = meanLH_S.*ones(size(LH_S));
            matRH_S = meanRH_S.*ones(size(RH_S));
            msLH_S = ((LH_S - matLH_S)./matLH_S)*.100;
            msRH_S = ((RH_S - matRH_S)./matLH_S)*.100;
            %             % concatenate power data from each animal
            data.Spectrogram.(dataType).(behavField).S = cat(3,data.Spectrogram.(dataType).(behavField).S,msLH_S,msRH_S);
            data.Spectrogram.(dataType).(behavField).t = cat(1,data.Spectrogram.(dataType).(behavField).t,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).LH_t,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).RH_t);
            data.Spectrogram.(dataType).(behavField).f = cat(1,data.Spectrogram.(dataType).(behavField).f,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).LH_f,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).RH_f);
            if strcmp(dataType,'gamma') == true
                data.Spectrogram.(dataType).(behavField).leadS = cat(2,data.Spectrogram.(dataType).(behavField).leadS,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).LH_leadS.*10e18,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).RH_leadS.*10e18);
                data.Spectrogram.(dataType).(behavField).lagS = cat(2,data.Spectrogram.(dataType).(behavField).lagS,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).LH_lagS.*10e18,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).RH_lagS.*10e18);
            else
                data.Spectrogram.(dataType).(behavField).leadS = cat(2,data.Spectrogram.(dataType).(behavField).leadS,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).LH_leadS,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).RH_leadS);
                data.Spectrogram.(dataType).(behavField).lagS = cat(2,data.Spectrogram.(dataType).(behavField).lagS,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).LH_lagS,Results_BlinkSpectrogram.(animalID).(dataType).(behavField).RH_lagS);
            end
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
[AwakeHbTPowerStats.h,AwakeHbTPowerStats.p,AwakeHbTPowerStats.ci,AwakeHbTPowerStats.stats] = ttest2(data.Spectrogram.HbT.Awake.leadS021,data.Spectrogram.HbT.Awake.lagS021);
[AwakeGammaPowerStats.h,AwakeGammaPowerStats.p,AwakeGammaPowerStats.ci,AwakeGammaPowerStats.stats] = ttest2(data.Spectrogram.gamma.Awake.leadS021,data.Spectrogram.gamma.Awake.lagS021);
[AsleepHbTPowerStats.h,AsleepHbTPowerStats.p,AsleepHbTPowerStats.ci,AsleepHbTPowerStats.stats] = ttest2(data.Spectrogram.HbT.Asleep.leadS021,data.Spectrogram.HbT.Asleep.lagS021);
[AsleepGammaPowerStats.h,AsleepGammaPowerStats.p,AsleepGammaPowerStats.ci,AsleepGammaPowerStats.stats] = ttest2(data.Spectrogram.gamma.Asleep.leadS021,data.Spectrogram.gamma.Asleep.lagS021);
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
Fig4 =  figure('Name','Figure Panel 4 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
% awake gamma-band coherence
ax1 = subplot(4,5,1);
s1 = semilogx(data.Coherogram.gamma.Awake.meanLeadF,data.Coherogram.gamma.Awake.meanLeadC,'color',colors('caribbean green'),'LineWidth',2);
hold on
semilogx(data.Coherogram.gamma.Awake.meanLeadF,data.Coherogram.gamma.Awake.meanLeadC + data.Coherogram.gamma.Awake.stdLeadC,'color',colors('caribbean green'),'LineWidth',0.5)
semilogx(data.Coherogram.gamma.Awake.meanLeadF,data.Coherogram.gamma.Awake.meanLeadC - data.Coherogram.gamma.Awake.stdLeadC,'color',colors('caribbean green'),'LineWidth',0.5)
s2 = semilogx(data.Coherogram.gamma.Awake.meanLagF,data.Coherogram.gamma.Awake.meanLagC,'color',colors('caribbean blue'),'LineWidth',2);
semilogx(data.Coherogram.gamma.Awake.meanLagF,data.Coherogram.gamma.Awake.meanLagC + data.Coherogram.gamma.Awake.stdLagC,'color',colors('caribbean blue'),'LineWidth',0.5)
semilogx(data.Coherogram.gamma.Awake.meanLagF,data.Coherogram.gamma.Awake.meanLagC - data.Coherogram.gamma.Awake.stdLagC,'color',colors('caribbean blue'),'LineWidth',0.5)
xline(0.2,'color',colors('black'),'LineWidth',2)
axis tight
ylabel('Coherence')
xlabel('Freq (Hz)')
title('Awake gamma pre/post blink coherence')
legend([s1,s2],'pre blink','post blink')
axis square
xlim([1/10,3])
ylim([0,0.5])
set(gca,'box','off')
ax1.TickLength = [0.03,0.03];
% awake gamma-band coherence scatter
ax2 = subplot(4,5,2);
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
title('Awake gamma coherence from 0-0.2 Hz')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,3])
ylim([0,0.6])
set(gca,'box','off')
ax2.TickLength = [0.03,0.03];
% awake gamma-band power
ax3 = subplot(4,5,3);
loglog(data.Spectrogram.gamma.Awake.meanLeadF,data.Spectrogram.gamma.Awake.meanLeadS,'color',colors('caribbean green'),'LineWidth',2);
hold on;
loglog(data.Spectrogram.gamma.Awake.meanLeadF,data.Spectrogram.gamma.Awake.meanLeadS + data.Spectrogram.gamma.Awake.stdLeadS,'color',colors('caribbean green'),'LineWidth',0.5);
loglog(data.Spectrogram.gamma.Awake.meanLeadF,data.Spectrogram.gamma.Awake.meanLeadS - data.Spectrogram.gamma.Awake.stdLeadS,'color',colors('caribbean green'),'LineWidth',0.5);
loglog(data.Spectrogram.gamma.Awake.meanLagF,data.Spectrogram.gamma.Awake.meanLagS,'color',colors('caribbean blue'),'LineWidth',2);
loglog(data.Spectrogram.gamma.Awake.meanLagF,data.Spectrogram.gamma.Awake.meanLagS + data.Spectrogram.gamma.Awake.stdLagS,'color',colors('caribbean blue'),'LineWidth',0.5);
loglog(data.Spectrogram.gamma.Awake.meanLagF,data.Spectrogram.gamma.Awake.meanLagS - data.Spectrogram.gamma.Awake.stdLagS,'color',colors('caribbean blue'),'LineWidth',0.5);
xline(0.2,'color',colors('black'),'LineWidth',2)
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
title('Awake gamma pre/post blink power')
axis square
axis tight
xlim([1/10,3])
set(gca,'box','off')
ax3.TickLength = [0.03,0.03];
% awake gamma-band power scatter
ax4 = subplot(4,5,4);
scatter(ones(1,length(data.Spectrogram.gamma.Awake.leadS021))*1,data.Spectrogram.gamma.Awake.leadS021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('caribbean green'),'jitter','on','jitterAmount',0.25);
hold on
scatter(1,data.Spectrogram.gamma.Awake.meanLeadS021,100,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.Spectrogram.gamma.Awake.lagS021))*2,data.Spectrogram.gamma.Awake.lagS021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('caribbean blue'),'jitter','on','jitterAmount',0.25);
scatter(2,data.Spectrogram.gamma.Awake.meanLagS021,100,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
ylabel('Power (a.u.)')
title('Awake gamma power from 0-0.2 Hz')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,3])
set(gca,'box','off')
set(gca,'yscale','log')
ax4.TickLength = [0.03,0.03];
% awake gamma-band coherence vs. power change
ax5 = subplot(4,5,5);
scatter(diffPower.gamma.Awake,diffCoher.gamma.Awake,75,'MarkerEdgeColor',colors('caribbean green'),'MarkerFaceColor',colors('caribbean blue'))
xlabel('\DeltaPower')
ylabel('\DeltaCoherence')
title('Awake gamma pre/post blink difference')
axis square
set(gca,'box','off')
set(gca,'xscale','log')
ax5.TickLength = [0.03,0.03];
% awake HbT-band coherence
ax6 = subplot(4,5,6);
s1 = semilogx(data.Coherogram.HbT.Awake.meanLeadF,data.Coherogram.HbT.Awake.meanLeadC,'color',colors('candy apple red'),'LineWidth',2);
hold on
semilogx(data.Coherogram.HbT.Awake.meanLeadF,data.Coherogram.HbT.Awake.meanLeadC + data.Coherogram.HbT.Awake.stdLeadC,'color',colors('candy apple red'),'LineWidth',0.5)
semilogx(data.Coherogram.HbT.Awake.meanLeadF,data.Coherogram.HbT.Awake.meanLeadC - data.Coherogram.HbT.Awake.stdLeadC,'color',colors('candy apple red'),'LineWidth',0.5)
s2 = semilogx(data.Coherogram.HbT.Awake.meanLagF,data.Coherogram.HbT.Awake.meanLagC,'color',colors('deep carrot orange'),'LineWidth',2);
semilogx(data.Coherogram.HbT.Awake.meanLagF,data.Coherogram.HbT.Awake.meanLagC + data.Coherogram.HbT.Awake.stdLagC,'color',colors('deep carrot orange'),'LineWidth',0.5)
semilogx(data.Coherogram.HbT.Awake.meanLagF,data.Coherogram.HbT.Awake.meanLagC - data.Coherogram.HbT.Awake.stdLagC,'color',colors('deep carrot orange'),'LineWidth',0.5)
xline(0.2,'color',colors('black'),'LineWidth',2)
axis tight
ylabel('Coherence')
xlabel('Freq (Hz)')
title('Awake HbT pre/post blink coherence')
legend([s1,s2],'pre blink','post blink')
axis square
xlim([1/10,3])
ylim([0.7,1])
set(gca,'box','off')
ax6.TickLength = [0.03,0.03];
% awake HbT-band coherence scatter
ax7 = subplot(4,5,7);
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
title('Awake HbT coherence from 0-0.2 Hz')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,3])
ylim([0.7,0.95])
set(gca,'box','off')
ax7.TickLength = [0.03,0.03];
% awake HbT-band power
ax8 = subplot(4,5,8);
loglog(data.Spectrogram.HbT.Awake.meanLeadF,data.Spectrogram.HbT.Awake.meanLeadS,'color',colors('candy apple red'),'LineWidth',2);
hold on;
loglog(data.Spectrogram.HbT.Awake.meanLeadF,data.Spectrogram.HbT.Awake.meanLeadS + data.Spectrogram.HbT.Awake.stdLeadS,'color',colors('candy apple red'),'LineWidth',0.5);
loglog(data.Spectrogram.HbT.Awake.meanLeadF,data.Spectrogram.HbT.Awake.meanLeadS - data.Spectrogram.HbT.Awake.stdLeadS,'color',colors('candy apple red'),'LineWidth',0.5);
loglog(data.Spectrogram.HbT.Awake.meanLagF,data.Spectrogram.HbT.Awake.meanLagS,'color',colors('deep carrot orange'),'LineWidth',2);
loglog(data.Spectrogram.HbT.Awake.meanLagF,data.Spectrogram.HbT.Awake.meanLagS + data.Spectrogram.HbT.Awake.stdLagS,'color',colors('deep carrot orange'),'LineWidth',0.5);
loglog(data.Spectrogram.HbT.Awake.meanLagF,data.Spectrogram.HbT.Awake.meanLagS - data.Spectrogram.HbT.Awake.stdLagS,'color',colors('deep carrot orange'),'LineWidth',0.5);
xline(0.2,'color',colors('black'),'LineWidth',2)
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
title('Awake HbT pre/post blink power')
axis square
axis tight
xlim([1/10,3])
set(gca,'box','off')
ax8.TickLength = [0.03,0.03];
% awake HbT-band power scatter
ax9 = subplot(4,5,9);
scatter(ones(1,length(data.Spectrogram.HbT.Awake.leadS021))*1,data.Spectrogram.HbT.Awake.leadS021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('candy apple red'),'jitter','on','jitterAmount',0.25);
hold on
scatter(1,data.Spectrogram.HbT.Awake.meanLeadS021,100,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.Spectrogram.HbT.Awake.lagS021))*2,data.Spectrogram.HbT.Awake.lagS021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('deep carrot orange'),'jitter','on','jitterAmount',0.25);
scatter(2,data.Spectrogram.HbT.Awake.meanLagS021,100,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
ylabel('Power (a.u.)')
title('Awake HbT power from 0-0.2 Hz')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,3])
ylim([0,300])
set(gca,'box','off')
set(gca,'yscale','log')
ax9.TickLength = [0.03,0.03];
% awake HbT-band coherence vs. power change
ax10 = subplot(4,5,10);
scatter(diffPower.HbT.Awake,diffCoher.HbT.Awake,75,'MarkerEdgeColor',colors('candy apple red'),'MarkerFaceColor',colors('deep carrot orange'))
xlabel('\DeltaPower')
ylabel('\DeltaCoherence')
title('Awake HbT pre/post blink difference')
axis square
set(gca,'box','off')
set(gca,'xscale','log')
ax10.TickLength = [0.03,0.03];
% awake gamma-band coherence
ax1 = subplot(4,5,11);
s1 = semilogx(data.Coherogram.gamma.Asleep.meanLeadF,data.Coherogram.gamma.Asleep.meanLeadC,'color',colors('caribbean green'),'LineWidth',2);
hold on
semilogx(data.Coherogram.gamma.Asleep.meanLeadF,data.Coherogram.gamma.Asleep.meanLeadC + data.Coherogram.gamma.Asleep.stdLeadC,'color',colors('caribbean green'),'LineWidth',0.5)
semilogx(data.Coherogram.gamma.Asleep.meanLeadF,data.Coherogram.gamma.Asleep.meanLeadC - data.Coherogram.gamma.Asleep.stdLeadC,'color',colors('caribbean green'),'LineWidth',0.5)
s2 = semilogx(data.Coherogram.gamma.Asleep.meanLagF,data.Coherogram.gamma.Asleep.meanLagC,'color',colors('caribbean blue'),'LineWidth',2);
semilogx(data.Coherogram.gamma.Asleep.meanLagF,data.Coherogram.gamma.Asleep.meanLagC + data.Coherogram.gamma.Asleep.stdLagC,'color',colors('caribbean blue'),'LineWidth',0.5)
semilogx(data.Coherogram.gamma.Asleep.meanLagF,data.Coherogram.gamma.Asleep.meanLagC - data.Coherogram.gamma.Asleep.stdLagC,'color',colors('caribbean blue'),'LineWidth',0.5)
xline(0.2,'color',colors('black'),'LineWidth',2)
axis tight
ylabel('Coherence')
xlabel('Freq (Hz)')
title('Asleep gamma pre/post blink coherence')
legend([s1,s2],'pre blink','post blink')
axis square
xlim([1/10,3])
ylim([0,0.55])
set(gca,'box','off')
ax1.TickLength = [0.03,0.03];
% awake gamma-band coherence scatter
ax2 = subplot(4,5,12);
scatter(ones(1,length(data.Coherogram.gamma.Asleep.leadC021))*1,data.Coherogram.gamma.Asleep.leadC021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('caribbean green'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.Coherogram.gamma.Asleep.meanLeadC021,data.Coherogram.gamma.Asleep.stdLeadC021,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.Coherogram.gamma.Asleep.lagC021))*2,data.Coherogram.gamma.Asleep.lagC021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('caribbean blue'),'jitter','on','jitterAmount',0.25);
hold on
e2 = errorbar(2,data.Coherogram.gamma.Asleep.meanLagC021,data.Coherogram.gamma.Asleep.stdLagC021,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
ylabel('Coherence')
title('Asleep gamma coherence from 0-0.2 Hz')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,3])
ylim([0,1])
set(gca,'box','off')
ax2.TickLength = [0.03,0.03];
% awake gamma-band power
ax3 = subplot(4,5,13);
loglog(data.Spectrogram.gamma.Asleep.meanLeadF,data.Spectrogram.gamma.Asleep.meanLeadS,'color',colors('caribbean green'),'LineWidth',2);
hold on;
loglog(data.Spectrogram.gamma.Asleep.meanLeadF,data.Spectrogram.gamma.Asleep.meanLeadS + data.Spectrogram.gamma.Asleep.stdLeadS,'color',colors('caribbean green'),'LineWidth',0.5);
loglog(data.Spectrogram.gamma.Asleep.meanLeadF,data.Spectrogram.gamma.Asleep.meanLeadS - data.Spectrogram.gamma.Asleep.stdLeadS,'color',colors('caribbean green'),'LineWidth',0.5);
loglog(data.Spectrogram.gamma.Asleep.meanLagF,data.Spectrogram.gamma.Asleep.meanLagS,'color',colors('caribbean blue'),'LineWidth',2);
loglog(data.Spectrogram.gamma.Asleep.meanLagF,data.Spectrogram.gamma.Asleep.meanLagS + data.Spectrogram.gamma.Asleep.stdLagS,'color',colors('caribbean blue'),'LineWidth',0.5);
loglog(data.Spectrogram.gamma.Asleep.meanLagF,data.Spectrogram.gamma.Asleep.meanLagS - data.Spectrogram.gamma.Asleep.stdLagS,'color',colors('caribbean blue'),'LineWidth',0.5);
xline(0.2,'color',colors('black'),'LineWidth',2)
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
title('Asleep gamma pre/post blink power')
axis square
axis tight
xlim([1/10,3])
set(gca,'box','off')
ax3.TickLength = [0.03,0.03];
% awake gamma-band power scatter
ax4 = subplot(4,5,14);
scatter(ones(1,length(data.Spectrogram.gamma.Asleep.leadS021))*1,data.Spectrogram.gamma.Asleep.leadS021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('caribbean green'),'jitter','on','jitterAmount',0.25);
hold on
scatter(1,data.Spectrogram.gamma.Asleep.meanLeadS021,100,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.Spectrogram.gamma.Asleep.lagS021))*2,data.Spectrogram.gamma.Asleep.lagS021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('caribbean blue'),'jitter','on','jitterAmount',0.25);
scatter(2,data.Spectrogram.gamma.Asleep.meanLagS021,100,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
ylabel('Power (a.u.)')
title('Asleep gamma power from 0-0.2 Hz')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,3])
set(gca,'box','off')
set(gca,'yscale','log')
ax4.TickLength = [0.03,0.03];
% awake gamma-band coherence vs. power change
ax5 = subplot(4,5,15);
scatter(diffPower.gamma.Asleep,diffCoher.gamma.Asleep,75,'MarkerEdgeColor',colors('caribbean green'),'MarkerFaceColor',colors('caribbean blue'))
xlabel('\DeltaPower')
ylabel('\DeltaCoherence')
title('Asleep gamma pre/post blink difference')
axis square
set(gca,'box','off')
set(gca,'xscale','log')
ax5.TickLength = [0.03,0.03];
% awake HbT-band coherence
ax6 = subplot(4,5,16);
s1 = semilogx(data.Coherogram.HbT.Asleep.meanLeadF,data.Coherogram.HbT.Asleep.meanLeadC,'color',colors('candy apple red'),'LineWidth',2);
hold on
semilogx(data.Coherogram.HbT.Asleep.meanLeadF,data.Coherogram.HbT.Asleep.meanLeadC + data.Coherogram.HbT.Asleep.stdLeadC,'color',colors('candy apple red'),'LineWidth',0.5)
semilogx(data.Coherogram.HbT.Asleep.meanLeadF,data.Coherogram.HbT.Asleep.meanLeadC - data.Coherogram.HbT.Asleep.stdLeadC,'color',colors('candy apple red'),'LineWidth',0.5)
s2 = semilogx(data.Coherogram.HbT.Asleep.meanLagF,data.Coherogram.HbT.Asleep.meanLagC,'color',colors('deep carrot orange'),'LineWidth',2);
semilogx(data.Coherogram.HbT.Asleep.meanLagF,data.Coherogram.HbT.Asleep.meanLagC + data.Coherogram.HbT.Asleep.stdLagC,'color',colors('deep carrot orange'),'LineWidth',0.5)
semilogx(data.Coherogram.HbT.Asleep.meanLagF,data.Coherogram.HbT.Asleep.meanLagC - data.Coherogram.HbT.Asleep.stdLagC,'color',colors('deep carrot orange'),'LineWidth',0.5)
xline(0.2,'color',colors('black'),'LineWidth',2)
axis tight
ylabel('Coherence')
xlabel('Freq (Hz)')
title('Asleep HbT pre/post blink coherence')
legend([s1,s2],'pre blink','post blink')
axis square
xlim([1/10,3])
ylim([0.6,1])
set(gca,'box','off')
ax6.TickLength = [0.03,0.03];
% awake HbT-band coherence scatter
ax7 = subplot(4,5,17);
scatter(ones(1,length(data.Coherogram.HbT.Asleep.leadC021))*1,data.Coherogram.HbT.Asleep.leadC021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('candy apple red'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.Coherogram.HbT.Asleep.meanLeadC021,data.Coherogram.HbT.Asleep.stdLeadC021,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.Coherogram.HbT.Asleep.lagC021))*2,data.Coherogram.HbT.Asleep.lagC021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('deep carrot orange'),'jitter','on','jitterAmount',0.25);
hold on
e2 = errorbar(2,data.Coherogram.HbT.Asleep.meanLagC021,data.Coherogram.HbT.Asleep.stdLagC021,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
ylabel('Coherence')
title('Asleep HbT coherence from 0-0.2 Hz')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,3])
ylim([0.7,1])
set(gca,'box','off')
ax7.TickLength = [0.03,0.03];
% awake HbT-band power
ax8 = subplot(4,5,18);
loglog(data.Spectrogram.HbT.Asleep.meanLeadF,data.Spectrogram.HbT.Asleep.meanLeadS,'color',colors('candy apple red'),'LineWidth',2);
hold on;
loglog(data.Spectrogram.HbT.Asleep.meanLeadF,data.Spectrogram.HbT.Asleep.meanLeadS + data.Spectrogram.HbT.Asleep.stdLeadS,'color',colors('candy apple red'),'LineWidth',0.5);
loglog(data.Spectrogram.HbT.Asleep.meanLeadF,data.Spectrogram.HbT.Asleep.meanLeadS - data.Spectrogram.HbT.Asleep.stdLeadS,'color',colors('candy apple red'),'LineWidth',0.5);
loglog(data.Spectrogram.HbT.Asleep.meanLagF,data.Spectrogram.HbT.Asleep.meanLagS,'color',colors('deep carrot orange'),'LineWidth',2);
loglog(data.Spectrogram.HbT.Asleep.meanLagF,data.Spectrogram.HbT.Asleep.meanLagS + data.Spectrogram.HbT.Asleep.stdLagS,'color',colors('deep carrot orange'),'LineWidth',0.5);
loglog(data.Spectrogram.HbT.Asleep.meanLagF,data.Spectrogram.HbT.Asleep.meanLagS - data.Spectrogram.HbT.Asleep.stdLagS,'color',colors('deep carrot orange'),'LineWidth',0.5);
xline(0.2,'color',colors('black'),'LineWidth',2)
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
title('Asleep HbT pre/post blink power')
axis square
axis tight
xlim([1/10,3])
set(gca,'box','off')
ax8.TickLength = [0.03,0.03];
% awake HbT-band power scatter
ax9 = subplot(4,5,19);
scatter(ones(1,length(data.Spectrogram.HbT.Asleep.leadS021))*1,data.Spectrogram.HbT.Asleep.leadS021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('candy apple red'),'jitter','on','jitterAmount',0.25);
hold on
scatter(1,data.Spectrogram.HbT.Asleep.meanLeadS021,100,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.Spectrogram.HbT.Asleep.lagS021))*2,data.Spectrogram.HbT.Asleep.lagS021,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('deep carrot orange'),'jitter','on','jitterAmount',0.25);
scatter(2,data.Spectrogram.HbT.Asleep.meanLagS021,100,'d','MarkerEdgeColor','k','MarkerFaceColor',colors('black'));
ylabel('Power (a.u.)')
title('Asleep HbT power from 0-0.2 Hz')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,3])
% ylim([0,300])
set(gca,'box','off')
set(gca,'yscale','log')
ax9.TickLength = [0.03,0.03];
% awake HbT-band coherence vs. power change
ax10 = subplot(4,5,20);
scatter(diffPower.HbT.Asleep,diffCoher.HbT.Asleep,75,'MarkerEdgeColor',colors('candy apple red'),'MarkerFaceColor',colors('deep carrot orange'))
xlabel('\DeltaPower')
ylabel('\DeltaCoherence')
title('Asleep HbT pre/post blink difference')
axis square
set(gca,'box','off')
set(gca,'xscale','log')
ax10.TickLength = [0.03,0.03];
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'Figure Panels' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig4,[dirpath 'Fig4_Turner2022']);
    set(Fig4,'PaperPositionMode','auto');
    print('-vector','-dpdf','-fillpage',[dirpath 'Fig4_Turner2022'])
    % text diary
    diaryFile = [dirpath 'Fig4_Text.txt'];
    if exist(diaryFile,'file') == 2
        delete(diaryFile)
    end
    diary(diaryFile)
    diary on
    % coherence and power statistics
    disp('======================================================================================================================')
    disp('Awake Gamma-band lead vs. lag coherence statistics')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Awake Gamma-band lead coherence ' num2str(data.Coherogram.gamma.Awake.meanLeadC021) ' ± ' num2str(data.Coherogram.gamma.Awake.stdLeadC021) ' (n = ' num2str(length(data.Coherogram.gamma.Awake.leadC021)) ') mice']); disp(' ')
    disp(['Awake Gamma-band lag coherence ' num2str(data.Coherogram.gamma.Awake.meanLagC021) ' ± ' num2str(data.Coherogram.gamma.Awake.stdLagC021) ' (n = ' num2str(length(data.Coherogram.gamma.Awake.lagC021)) ') mice']); disp(' ')
    disp(['Lead vs. Lag coherence p < ' num2str(AwakeGammaCoherStats.p)]); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp('======================================================================================================================')
    disp('Awake Gamma-band lead vs. lag power statistics')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Awake Gamma-band lead power ' num2str(data.Spectrogram.gamma.Awake.meanLeadS021) ' ± ' num2str(data.Spectrogram.gamma.Awake.stdLeadS021) ' (n = ' num2str(length(data.Spectrogram.gamma.Awake.leadS021)/2) ') mice']); disp(' ')
    disp(['Awake Gamma-band lag power ' num2str(data.Spectrogram.gamma.Awake.meanLagS021) ' ± ' num2str(data.Spectrogram.gamma.Awake.stdLagS021) ' (n = ' num2str(length(data.Spectrogram.gamma.Awake.lagS021)/2) ') mice']); disp(' ')
    disp(['Lead vs. Lag power p < ' num2str(AwakeGammaPowerStats.p)]); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp('======================================================================================================================')
    disp('Awake HbT lead vs. lag coherence statistics')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Awake HbT lead coherence ' num2str(data.Coherogram.HbT.Awake.meanLeadC021) ' ± ' num2str(data.Coherogram.HbT.Awake.stdLeadC021) ' (n = ' num2str(length(data.Coherogram.HbT.Awake.leadC021)) ') mice']); disp(' ')
    disp(['Awake HbT lag coherence ' num2str(data.Coherogram.HbT.Awake.meanLagC021) ' ± ' num2str(data.Coherogram.HbT.Awake.stdLagC021) ' (n = ' num2str(length(data.Coherogram.HbT.Awake.lagC021)) ') mice']); disp(' ')
    disp(['Lead vs. Lag coherence p < ' num2str(AwakeHbTCoherStats.p)]); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp('======================================================================================================================')
    disp('Awake HbT lead vs. lag power statistics')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Awake HbT lead power ' num2str(data.Spectrogram.HbT.Awake.meanLeadS021) ' ± ' num2str(data.Spectrogram.HbT.Awake.stdLeadS021) ' (n = ' num2str(length(data.Spectrogram.HbT.Awake.leadS021)/2) ') mice']); disp(' ')
    disp(['Awake HbT lag power ' num2str(data.Spectrogram.HbT.Awake.meanLagS021) ' ± ' num2str(data.Spectrogram.HbT.Awake.stdLagS021) ' (n = ' num2str(length(data.Spectrogram.HbT.Awake.lagS021)/2) ') mice']); disp(' ')
    disp(['Lead vs. Lag power p < ' num2str(AwakeHbTPowerStats.p)]); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    % coherence and power statistics
    disp('======================================================================================================================')
    disp('Asleep Gamma-band lead vs. lag coherence statistics')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Asleep Gamma-band lead coherence ' num2str(data.Coherogram.gamma.Asleep.meanLeadC021) ' ± ' num2str(data.Coherogram.gamma.Asleep.stdLeadC021) ' (n = ' num2str(length(data.Coherogram.gamma.Asleep.leadC021)) ') mice']); disp(' ')
    disp(['Asleep Gamma-band lag coherence ' num2str(data.Coherogram.gamma.Asleep.meanLagC021) ' ± ' num2str(data.Coherogram.gamma.Asleep.stdLagC021) ' (n = ' num2str(length(data.Coherogram.gamma.Asleep.lagC021)) ') mice']); disp(' ')
    disp(['Lead vs. Lag coherence p < ' num2str(AsleepGammaCoherStats.p)]); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp('======================================================================================================================')
    disp('Asleep Gamma-band lead vs. lag power statistics')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Asleep Gamma-band lead power ' num2str(data.Spectrogram.gamma.Asleep.meanLeadS021) ' ± ' num2str(data.Spectrogram.gamma.Asleep.stdLeadS021) ' (n = ' num2str(length(data.Spectrogram.gamma.Asleep.leadS021)/2) ') mice']); disp(' ')
    disp(['Asleep Gamma-band lag power ' num2str(data.Spectrogram.gamma.Asleep.meanLagS021) ' ± ' num2str(data.Spectrogram.gamma.Asleep.stdLagS021) ' (n = ' num2str(length(data.Spectrogram.gamma.Asleep.lagS021)/2) ') mice']); disp(' ')
    disp(['Lead vs. Lag power p < ' num2str(AsleepGammaPowerStats.p)]); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp('======================================================================================================================')
    disp('Asleep HbT lead vs. lag coherence statistics')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Asleep HbT lead coherence ' num2str(data.Coherogram.HbT.Asleep.meanLeadC021) ' ± ' num2str(data.Coherogram.HbT.Asleep.stdLeadC021) ' (n = ' num2str(length(data.Coherogram.HbT.Asleep.leadC021)) ') mice']); disp(' ')
    disp(['Asleep HbT lag coherence ' num2str(data.Coherogram.HbT.Asleep.meanLagC021) ' ± ' num2str(data.Coherogram.HbT.Asleep.stdLagC021) ' (n = ' num2str(length(data.Coherogram.HbT.Asleep.lagC021)) ') mice']); disp(' ')
    disp(['Lead vs. Lag coherence p < ' num2str(AsleepHbTCoherStats.p)]); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp('======================================================================================================================')
    disp('Asleep HbT lead vs. lag power statistics')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Asleep HbT lead power ' num2str(data.Spectrogram.HbT.Asleep.meanLeadS021) ' ± ' num2str(data.Spectrogram.HbT.Asleep.stdLeadS021) ' (n = ' num2str(length(data.Spectrogram.HbT.Asleep.leadS021)/2) ') mice']); disp(' ')
    disp(['Asleep HbT lag power ' num2str(data.Spectrogram.HbT.Asleep.meanLagS021) ' ± ' num2str(data.Spectrogram.HbT.Asleep.stdLagS021) ' (n = ' num2str(length(data.Spectrogram.HbT.Asleep.lagS021)/2) ') mice']); disp(' ')
    disp(['Lead vs. Lag power p < ' num2str(AsleepHbTPowerStats.p)]); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    diary off
end

end
