function [] = Fig5_JNeurosci2022(rootFolder,saveFigs,delim)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: Generate figure panel 8 for Turner_Gheres_Proctor_Drew_eLife2020
%________________________________________________________________________________________________________________________

%% variables for loops
resultsStruct = 'Results_BlinkCoherogram';
load(resultsStruct);
animalIDs = fieldnames(Results_BlinkCoherogram);
behavFields = {'Awake','Asleep','All'};
dataTypes = {'HbT','gamma','left','right'};
%% take data from each animal corresponding to the CBV-gamma relationship
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    for bb = 1:length(dataTypes)
        dataType = dataTypes{1,bb};
        data.(dataType).dummyCheck = 1;
        for cc = 1:length(behavFields)
            behavField = behavFields{1,cc};
            if isfield(data.(dataType),behavField) == false
                data.(dataType).(behavField).C = [];
                data.(dataType).(behavField).f = [];
                data.(dataType).(behavField).t = [];
                data.(dataType).(behavField).leadC = [];
                data.(dataType).(behavField).lagC = [];
                data.(dataType).(behavField).leadf = [];
                data.(dataType).(behavField).lagf = [];
                data.(dataType).(behavField).leadS = [];
                data.(dataType).(behavField).lagS = [];
            end
            C = Results_BlinkCoherogram.(animalID).(dataType).(behavField).C;
            meanC = mean(C(:,1:40*10),2);
            matC = meanC.*ones(size(C));
            msC = (C - matC);
            data.(dataType).(behavField).C = cat(3,data.(dataType).(behavField).C,msC);
            data.(dataType).(behavField).t = cat(1,data.(dataType).(behavField).t,Results_BlinkCoherogram.(animalID).(dataType).(behavField).t);
            data.(dataType).(behavField).f = cat(1,data.(dataType).(behavField).f,Results_BlinkCoherogram.(animalID).(dataType).(behavField).f);
            data.(dataType).(behavField).leadC = cat(2,data.(dataType).(behavField).leadC,Results_BlinkCoherogram.(animalID).(dataType).(behavField).leadC);
            data.(dataType).(behavField).lagC = cat(2,data.(dataType).(behavField).lagC,Results_BlinkCoherogram.(animalID).(dataType).(behavField).lagC);
            data.(dataType).(behavField).leadf = cat(1,data.(dataType).(behavField).leadf,Results_BlinkCoherogram.(animalID).(dataType).(behavField).leadf);
            data.(dataType).(behavField).lagf = cat(1,data.(dataType).(behavField).lagf,Results_BlinkCoherogram.(animalID).(dataType).(behavField).lagf);
            data.(dataType).(behavField).leadS = cat(2,data.(dataType).(behavField).leadS,Results_BlinkCoherogram.(animalID).(dataType).(behavField).LH_leadS,Results_BlinkCoherogram.(animalID).(dataType).(behavField).RH_leadS);
            data.(dataType).(behavField).lagS = cat(2,data.(dataType).(behavField).lagS,Results_BlinkCoherogram.(animalID).(dataType).(behavField).LH_lagS,Results_BlinkCoherogram.(animalID).(dataType).(behavField).RH_lagS);
        end
    end
end
for aa = 1:length(behavFields)
    behavField = behavFields{1,aa};
    data.gammaHbT.(behavField).C = cat(3,data.left.(behavField).C,data.right.(behavField).C);
    data.gammaHbT.(behavField).t = cat(1,data.left.(behavField).t,data.right.(behavField).t);
    data.gammaHbT.(behavField).f = cat(1,data.left.(behavField).f,data.right.(behavField).f);
    data.gammaHbT.(behavField).leadC = cat(1,data.left.(behavField).leadC,data.right.(behavField).leadC);
    data.gammaHbT.(behavField).lagC = cat(1,data.left.(behavField).lagC,data.right.(behavField).lagC);
    data.gammaHbT.(behavField).leadf = cat(2,data.left.(behavField).leadf,data.right.(behavField).leadf);
    data.gammaHbT.(behavField).lagf = cat(2,data.left.(behavField).lagf,data.right.(behavField).lagf);
end
%% mean
dataTypes = {'HbT','gamma'};
for aa = 1:length(dataTypes)
    dataType = dataTypes{1,aa};
    for bb = 1:length(behavFields)
        behavField = behavFields{1,bb};
        data.(dataType).(behavField).meanC = mean(data.(dataType).(behavField).C,3);
        data.(dataType).(behavField).meanT = mean(data.(dataType).(behavField).t,1);
        data.(dataType).(behavField).meanF = mean(data.(dataType).(behavField).f,1);
        data.(dataType).(behavField).meanLeadC = mean(data.(dataType).(behavField).leadC,2);
        data.(dataType).(behavField).meanLagC = mean(data.(dataType).(behavField).lagC,2);
        data.(dataType).(behavField).meanLeadF = mean(data.(dataType).(behavField).leadf,1);
        data.(dataType).(behavField).meanLagF = mean(data.(dataType).(behavField).lagf,1);
        data.(dataType).(behavField).stdLeadC = std(data.(dataType).(behavField).leadC,0,2)./sqrt(size(data.(dataType).(behavField).leadC,2));
        data.(dataType).(behavField).stdLagC = std(data.(dataType).(behavField).lagC,0,2)./sqrt(size(data.(dataType).(behavField).lagC,2));
        data.(dataType).(behavField).meanLeadS = mean(data.(dataType).(behavField).leadS,2);
        data.(dataType).(behavField).meanLagS = mean(data.(dataType).(behavField).lagS,2);
        data.(dataType).(behavField).stdLeadS = std(data.(dataType).(behavField).leadS,0,2)./sqrt(size(data.(dataType).(behavField).leadS,2));
        data.(dataType).(behavField).stdLagS = std(data.(dataType).(behavField).lagS,0,2)./sqrt(size(data.(dataType).(behavField).lagS,2));
        
    end
end

% find 0.1/0.01 Hz peaks in coherence
for ee = 1:length(dataTypes)
    dataType = dataTypes{1,ee};
    for ff = 1:length(behavFields)
        behavField = behavFields{1,ff};
        for gg = 1:size(data.(dataType).(behavField).leadC,2)
            F = round(data.(dataType).(behavField).leadf(gg,:),2);
            leadC = data.(dataType).(behavField).leadC(:,gg);
            lagC = data.(dataType).(behavField).lagC(:,gg);
            index035 = find(F == 0.23);
            data.(dataType).(behavField).leadC035(gg,1) = mean(leadC(1:index035(1)));
            data.(dataType).(behavField).lagC035(gg,1) = mean(lagC(1:index035(1)));
        end
    end
end
% take mean/StD of peak C
for ee = 1:length(dataTypes)
    dataType = dataTypes{1,ee};
    for ff = 1:length(behavFields)
        behavField = behavFields{1,ff};
        data.(dataType).(behavField).meanLeadC035 = mean(data.(dataType).(behavField).leadC035,1);
        data.(dataType).(behavField).stdLeadC035 = std(data.(dataType).(behavField).leadC035,0,1);
        data.(dataType).(behavField).meanLagC035 = mean(data.(dataType).(behavField).lagC035,1);
        data.(dataType).(behavField).stdLagC035 = std(data.(dataType).(behavField).lagC035,0,1);
    end
end
[HbTStats.h,HbTStats.p,HbTStats.ci,HbTStats.stats] = ttest2(data.HbT.Awake.leadC035,data.HbT.Awake.lagC035,'Alpha',0.01);
[GammaStats.h,GammaStats.p,GammaStats.ci,GammaStats.stats] = ttest2(data.gamma.Awake.leadC035,data.gamma.Awake.lagC035,'Alpha',0.01);
%%
Fig5A =  figure('Name','Figure Panel 2 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
ax1 = subplot(2,4,1);
Semilog_ImageSC(data.HbT.Awake.meanT,data.HbT.Awake.meanF,data.HbT.Awake.meanC,'y')
c1 = colorbar;
ylabel(c1,'\DeltaCoherence (%)','rotation',-90,'VerticalAlignment','bottom')
caxis([-0.15,0.05])
ylabel('Freq (Hz)')
xlabel('Time (sec)')
title('HbT coherogram')
xticks([10,20,30,40,50])
xticklabels({'-20','-10','0','10','20'})
axis square
axis xy
set(gca,'box','off')
%%
subplot(2,4,2)
s1 = semilogx(data.HbT.Awake.meanLeadF,data.HbT.Awake.meanLeadC,'r','LineWidth',2);
hold on
semilogx(data.HbT.Awake.meanLeadF,data.HbT.Awake.meanLeadC + data.HbT.Awake.stdLeadC,'r','LineWidth',0.5)
semilogx(data.HbT.Awake.meanLeadF,data.HbT.Awake.meanLeadC - data.HbT.Awake.stdLeadC,'r','LineWidth',0.5)
s2 = semilogx(data.HbT.Awake.meanLagF,data.HbT.Awake.meanLagC,'b','LineWidth',2);
semilogx(data.HbT.Awake.meanLagF,data.HbT.Awake.meanLagC + data.HbT.Awake.stdLagC,'b','LineWidth',0.5)
semilogx(data.HbT.Awake.meanLagF,data.HbT.Awake.meanLagC - data.HbT.Awake.stdLagC,'b','LineWidth',0.5)
xline(0.23)
axis tight
ylabel('Coherence')
xlabel('Freq (Hz)')
title('HbT lead/lag coherence')
legend([s1,s2],'leading blink +/- SEM','lagging blink +/- SEM')
axis square
%%
subplot(2,4,3)
scatter(ones(1,length(data.HbT.Awake.leadC035))*1,data.HbT.Awake.leadC035,75,'MarkerEdgeColor','k','MarkerFaceColor','r','jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.HbT.Awake.meanLeadC035,data.HbT.Awake.stdLeadC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.HbT.Awake.lagC035))*2,data.HbT.Awake.lagC035,75,'MarkerEdgeColor','k','MarkerFaceColor','b','jitter','on','jitterAmount',0.25);
hold on
e2 = errorbar(2,data.HbT.Awake.meanLagC035,data.HbT.Awake.stdLagC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
ylabel('Coherence')
title('HbT coherence from 0-0.23 Hz')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,3])
ylim([0,1])
set(gca,'box','off')
%%
subplot(2,4,4)
loglog(data.HbT.Awake.meanLeadF,data.HbT.Awake.meanLeadS,'r','LineWidth',2);
hold on;
% loglog(data.HbT.Awake.meanLeadF,data.HbT.Awake.meanLeadS + data.HbT.Awake.stdLeadS,'r','LineWidth',0.5);
% loglog(data.HbT.Awake.meanLeadF,data.HbT.Awake.meanLeadS - data.HbT.Awake.stdLeadS,'r','LineWidth',0.5);
loglog(data.HbT.Awake.meanLagF,data.HbT.Awake.meanLagS,'b','LineWidth',2);
% loglog(data.HbT.Awake.meanLeadF,data.HbT.Awake.meanLagS + data.HbT.Awake.stdLagS,'b','LineWidth',0.5);
% loglog(data.HbT.Awake.meanLeadF,data.HbT.Awake.meanLagS - data.HbT.Awake.stdLagS,'b','LineWidth',0.5);
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
title('HbT lead/lag power')
axis square
axis tight
xlim([0.03,1])
set(gca,'box','off')
%%
ax2 = subplot(2,4,5);
Semilog_ImageSC(data.gamma.Awake.meanT,data.gamma.Awake.meanF,data.gamma.Awake.meanC,'y')
c1 = colorbar;
ylabel(c1,'\DeltaCoherence (%)','rotation',-90,'VerticalAlignment','bottom')
caxis([-0.15,0.05])
ylabel('Freq (Hz)')
xlabel('Time (sec)')
title('Gamma coherogram')
xticks([10,20,30,40,50])
xticklabels({'-20','-10','0','10','20'})
axis square
axis xy
set(gca,'box','off')
%%
subplot(2,4,6)
s1 = semilogx(data.gamma.Awake.meanLeadF,data.gamma.Awake.meanLeadC,'r','LineWidth',2);
hold on
semilogx(data.gamma.Awake.meanLeadF,data.gamma.Awake.meanLeadC + data.gamma.Awake.stdLeadC,'r','LineWidth',0.5)
semilogx(data.gamma.Awake.meanLeadF,data.gamma.Awake.meanLeadC - data.gamma.Awake.stdLeadC,'r','LineWidth',0.5)
s2 = semilogx(data.gamma.Awake.meanLagF,data.gamma.Awake.meanLagC,'b','LineWidth',2);
semilogx(data.gamma.Awake.meanLagF,data.gamma.Awake.meanLagC + data.gamma.Awake.stdLagC,'b','LineWidth',0.5)
semilogx(data.gamma.Awake.meanLagF,data.gamma.Awake.meanLagC - data.gamma.Awake.stdLagC,'b','LineWidth',0.5)
xline(0.23)
axis tight
ylabel('Coherence')
xlabel('Freq (Hz)')
title('Gamma lead/lag coherence')
legend([s1,s2],'leading blink +/- SEM','lagging blink +/- SEM')
axis square
%%
subplot(2,4,7)
scatter(ones(1,length(data.gamma.Awake.leadC035))*1,data.gamma.Awake.leadC035,75,'MarkerEdgeColor','k','MarkerFaceColor','r','jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.gamma.Awake.meanLeadC035,data.gamma.Awake.stdLeadC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.gamma.Awake.lagC035))*2,data.gamma.Awake.lagC035,75,'MarkerEdgeColor','k','MarkerFaceColor','b','jitter','on','jitterAmount',0.25);
hold on
e2 = errorbar(2,data.gamma.Awake.meanLagC035,data.gamma.Awake.stdLagC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
ylabel('Coherence')
title('Gamma coherence from 0-0.23 Hz')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,3])
ylim([0,1])
set(gca,'box','off')
%%
subplot(2,4,8)
loglog(data.gamma.Awake.meanLeadF,data.gamma.Awake.meanLeadS,'r','LineWidth',2);
hold on;
% loglog(data.gamma.Awake.meanLeadF,data.gamma.Awake.meanLeadS + data.gamma.Awake.stdLeadS,'r','LineWidth',0.5);
% loglog(data.gamma.Awake.meanLeadF,data.gamma.Awake.meanLeadS - data.gamma.Awake.stdLeadS,'r','LineWidth',0.5);
loglog(data.gamma.Awake.meanLagF,data.gamma.Awake.meanLagS,'b','LineWidth',2);
% loglog(data.gamma.Awake.meanLeadF,data.gamma.Awake.meanLagS + data.gamma.Awake.stdLagS,'b','LineWidth',0.5);
% loglog(data.gamma.Awake.meanLeadF,data.gamma.Awake.meanLagS - data.gamma.Awake.stdLagS,'b','LineWidth',0.5);
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
title('Gamma lead/lag power')
axis square
axis tight
xlim([0.03,1])
set(gca,'box','off')
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'Summary Figures and Structures' delim 'Figure Panels' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig5A,[dirpath 'Fig5A_JNeurosci2022']);
    % remove surface subplots because they take forever to render
    cla(ax1);
    set(ax1,'YLim',[0,3]);
    cla(ax2);
    set(ax2,'YLim',[0,3]);
    set(Fig5A,'PaperPositionMode','auto');
    print('-vector','-dpdf','-bestfit',[dirpath 'Fig5A_JNeurosci2022'])
    close(Fig5A)
    % subplot figure
    subplotImgs = figure;
    % example 1 LH cortical LFP
    subplot(1,2,1)
    Semilog_ImageSC(data.HbT.Awake.meanT,data.HbT.Awake.meanF,data.HbT.Awake.meanC,'y')
    caxis([-0.15,0.05])
    axis square
    axis xy
    axis off
    set(gca,'box','off')
    subplot(1,2,2)
    Semilog_ImageSC(data.gamma.Awake.meanT,data.gamma.Awake.meanF,data.gamma.Awake.meanC,'y')
    caxis([-0.15,0.05])
    axis square
    axis xy
    axis off
    set(gca,'box','off')
    print('-vector','-dtiffn',[dirpath 'Fig5_CohImages'])
    close(subplotImgs)
    figure('Name','Figure Panel 5 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
    subplot(2,4,1);
    Semilog_ImageSC(data.HbT.Awake.meanT,data.HbT.Awake.meanF,data.HbT.Awake.meanC,'y')
    c1 = colorbar;
    ylabel(c1,'\DeltaCoherence (%)','rotation',-90,'VerticalAlignment','bottom')
    caxis([-0.15,0.05])
    ylabel('Freq (Hz)')
    xlabel('Time (sec)')
    title('HbT coherogram')
    xticks([10,20,30,40,50])
    xticklabels({'-20','-10','0','10','20'})
    axis square
    axis xy
    set(gca,'box','off')
    %%
    subplot(2,4,2)
    s1 = semilogx(data.HbT.Awake.meanLeadF,data.HbT.Awake.meanLeadC,'r','LineWidth',2);
    hold on
    semilogx(data.HbT.Awake.meanLeadF,data.HbT.Awake.meanLeadC + data.HbT.Awake.stdLeadC,'r','LineWidth',0.5)
    semilogx(data.HbT.Awake.meanLeadF,data.HbT.Awake.meanLeadC - data.HbT.Awake.stdLeadC,'r','LineWidth',0.5)
    s2 = semilogx(data.HbT.Awake.meanLagF,data.HbT.Awake.meanLagC,'b','LineWidth',2);
    semilogx(data.HbT.Awake.meanLagF,data.HbT.Awake.meanLagC + data.HbT.Awake.stdLagC,'b','LineWidth',0.5)
    semilogx(data.HbT.Awake.meanLagF,data.HbT.Awake.meanLagC - data.HbT.Awake.stdLagC,'b','LineWidth',0.5)
    xline(0.23)
    axis tight
    ylabel('Coherence')
    xlabel('Freq (Hz)')
    title('HbT lead/lag coherence')
    legend([s1,s2],'leading blink +/- SEM','lagging blink +/- SEM')
    axis square
    %%
    subplot(2,4,3)
    scatter(ones(1,length(data.HbT.Awake.leadC035))*1,data.HbT.Awake.leadC035,75,'MarkerEdgeColor','k','MarkerFaceColor','r','jitter','on','jitterAmount',0.25);
    hold on
    e1 = errorbar(1,data.HbT.Awake.meanLeadC035,data.HbT.Awake.stdLeadC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
    e1.Color = 'black';
    e1.MarkerSize = 10;
    e1.CapSize = 10;
    scatter(ones(1,length(data.HbT.Awake.lagC035))*2,data.HbT.Awake.lagC035,75,'MarkerEdgeColor','k','MarkerFaceColor','b','jitter','on','jitterAmount',0.25);
    hold on
    e2 = errorbar(2,data.HbT.Awake.meanLagC035,data.HbT.Awake.stdLagC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
    e2.Color = 'black';
    e2.MarkerSize = 10;
    e2.CapSize = 10;
    ylabel('Coherence')
    title('HbT coherence from 0-0.23 Hz')
    set(gca,'xtick',[])
    set(gca,'xticklabel',[])
    axis square
    xlim([0,3])
    ylim([0,1])
    set(gca,'box','off')
    %%
    subplot(2,4,4)
    loglog(data.HbT.Awake.meanLeadF,data.HbT.Awake.meanLeadS,'r','LineWidth',2);
    hold on;
    % loglog(data.HbT.Awake.meanLeadF,data.HbT.Awake.meanLeadS + data.HbT.Awake.stdLeadS,'r','LineWidth',0.5);
    % loglog(data.HbT.Awake.meanLeadF,data.HbT.Awake.meanLeadS - data.HbT.Awake.stdLeadS,'r','LineWidth',0.5);
    loglog(data.HbT.Awake.meanLagF,data.HbT.Awake.meanLagS,'b','LineWidth',2);
    % loglog(data.HbT.Awake.meanLeadF,data.HbT.Awake.meanLagS + data.HbT.Awake.stdLagS,'b','LineWidth',0.5);
    % loglog(data.HbT.Awake.meanLeadF,data.HbT.Awake.meanLagS - data.HbT.Awake.stdLagS,'b','LineWidth',0.5);
    ylabel('Power (a.u.)')
    xlabel('Freq (Hz)')
    title('HbT lead/lag power')
    axis square
    axis tight
    xlim([0.03,1])
    set(gca,'box','off')
    %%
    subplot(2,4,5);
    Semilog_ImageSC(data.gamma.Awake.meanT,data.gamma.Awake.meanF,data.gamma.Awake.meanC,'y')
    c1 = colorbar;
    ylabel(c1,'\DeltaCoherence (%)','rotation',-90,'VerticalAlignment','bottom')
    caxis([-0.15,0.05])
    ylabel('Freq (Hz)')
    xlabel('Time (sec)')
    title('Gamma coherogram')
    xticks([10,20,30,40,50])
    xticklabels({'-20','-10','0','10','20'})
    axis square
    axis xy
    set(gca,'box','off')
    %%
    subplot(2,4,6)
    s1 = semilogx(data.gamma.Awake.meanLeadF,data.gamma.Awake.meanLeadC,'r','LineWidth',2);
    hold on
    semilogx(data.gamma.Awake.meanLeadF,data.gamma.Awake.meanLeadC + data.gamma.Awake.stdLeadC,'r','LineWidth',0.5)
    semilogx(data.gamma.Awake.meanLeadF,data.gamma.Awake.meanLeadC - data.gamma.Awake.stdLeadC,'r','LineWidth',0.5)
    s2 = semilogx(data.gamma.Awake.meanLagF,data.gamma.Awake.meanLagC,'b','LineWidth',2);
    semilogx(data.gamma.Awake.meanLagF,data.gamma.Awake.meanLagC + data.gamma.Awake.stdLagC,'b','LineWidth',0.5)
    semilogx(data.gamma.Awake.meanLagF,data.gamma.Awake.meanLagC - data.gamma.Awake.stdLagC,'b','LineWidth',0.5)
    xline(0.23)
    axis tight
    ylabel('Coherence')
    xlabel('Freq (Hz)')
    title('Gamma lead/lag coherence')
    legend([s1,s2],'leading blink +/- SEM','lagging blink +/- SEM')
    axis square
    %%
    subplot(2,4,7)
    scatter(ones(1,length(data.gamma.Awake.leadC035))*1,data.gamma.Awake.leadC035,75,'MarkerEdgeColor','k','MarkerFaceColor','r','jitter','on','jitterAmount',0.25);
    hold on
    e1 = errorbar(1,data.gamma.Awake.meanLeadC035,data.gamma.Awake.stdLeadC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
    e1.Color = 'black';
    e1.MarkerSize = 10;
    e1.CapSize = 10;
    scatter(ones(1,length(data.gamma.Awake.lagC035))*2,data.gamma.Awake.lagC035,75,'MarkerEdgeColor','k','MarkerFaceColor','b','jitter','on','jitterAmount',0.25);
    hold on
    e2 = errorbar(2,data.gamma.Awake.meanLagC035,data.gamma.Awake.stdLagC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
    e2.Color = 'black';
    e2.MarkerSize = 10;
    e2.CapSize = 10;
    ylabel('Coherence')
    title('Gamma coherence from 0-0.23 Hz')
    set(gca,'xtick',[])
    set(gca,'xticklabel',[])
    axis square
    xlim([0,3])
    ylim([0,1])
    set(gca,'box','off')
    %%
    subplot(2,4,8)
    loglog(data.gamma.Awake.meanLeadF,data.gamma.Awake.meanLeadS,'r','LineWidth',2);
    hold on;
    % loglog(data.gamma.Awake.meanLeadF,data.gamma.Awake.meanLeadS + data.gamma.Awake.stdLeadS,'r','LineWidth',0.5);
    % loglog(data.gamma.Awake.meanLeadF,data.gamma.Awake.meanLeadS - data.gamma.Awake.stdLeadS,'r','LineWidth',0.5);
    loglog(data.gamma.Awake.meanLagF,data.gamma.Awake.meanLagS,'b','LineWidth',2);
    % loglog(data.gamma.Awake.meanLeadF,data.gamma.Awake.meanLagS + data.gamma.Awake.stdLagS,'b','LineWidth',0.5);
    % loglog(data.gamma.Awake.meanLeadF,data.gamma.Awake.meanLagS - data.gamma.Awake.stdLagS,'b','LineWidth',0.5);
    ylabel('Power (a.u.)')
    xlabel('Freq (Hz)')
    title('Gamma lead/lag power')
    axis square
    axis tight
    xlim([0.03,1])
    set(gca,'box','off')
end

end
