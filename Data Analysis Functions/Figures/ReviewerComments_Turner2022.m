function [] = ReviewerComments_Turner2022(rootFolder,saveFigs,delim)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: Generate figures and supporting information for Figure Panel 5
%________________________________________________________________________________________________________________________

%% Pupil-HbT relationship
resultsStruct = 'Results_AxisCorrelation.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_AxisCorrelation);
%
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    coefR(aa,1) = Results_AxisCorrelation.(animalID).meanR;
end
% mean & std of correlation between major and minor axis
meanR = mean(coefR);
stdR = std(coefR,0,1);
%%
resultsStruct = 'Results_PupilREM.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_PupilREM);
hbtOpen = []; hbtClosed = [];
gammaOpen = []; gammaClosed = [];
hipOpen = []; hipClosed = [];
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    hbtOpen = cat(2,hbtOpen,Results_PupilREM.(animalID).LH_HbT_open,Results_PupilREM.(animalID).RH_HbT_open);
    hbtClosed = cat(2,hbtClosed,Results_PupilREM.(animalID).LH_HbT_closed,Results_PupilREM.(animalID).RH_HbT_closed);
    gammaOpen = cat(2,gammaOpen,Results_PupilREM.(animalID).LH_gamma_open,Results_PupilREM.(animalID).RH_gamma_open);
    gammaClosed = cat(2,gammaClosed,Results_PupilREM.(animalID).LH_gamma_closed,Results_PupilREM.(animalID).RH_gamma_closed);
    hipOpen = cat(2,hipOpen,Results_PupilREM.(animalID).hip_theta_open);
    hipClosed = cat(2,hipClosed,Results_PupilREM.(animalID).hip_theta_closed);
end
meanHbTOpen = mean(hbtOpen,'omitnan');
stdHbTOpen = std(hbtOpen,0,2,'omitnan');
meanHbTClosed = mean(hbtClosed,'omitnan');
stdHbTClosed = std(hbtClosed,0,2,'omitnan');
meanGammaOpen = mean(gammaOpen,'omitnan');
stdGammaOpen = std(gammaOpen,0,2,'omitnan');
meanGammaClosed = mean(gammaClosed,'omitnan');
stdGammaClosed = std(gammaClosed,0,2,'omitnan');
meanHipOpen = mean(hipOpen,'omitnan');
stdHipOpen = std(hipOpen,0,2,'omitnan');
meanHipClosed = mean(hipClosed,'omitnan');
stdHipClosed = std(hipClosed,0,2,'omitnan');
figure;
subplot(1,3,1)
s1 = scatter(ones(1,length(hbtOpen))*1,hbtOpen,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('candy apple red'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,meanHbTOpen,stdHbTOpen,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
s2 = scatter(ones(1,length(hbtClosed))*2,hbtClosed,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('sapphire'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(2,meanHbTClosed,stdHbTClosed,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
ylabel('\Delta[HbT] (\muM)')
title('REM HbT')
legend([s1,s2],'Eyes open','Eyes closed')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,3])
set(gca,'box','off')
subplot(1,3,2)
s1 = scatter(ones(1,length(gammaOpen))*1,gammaOpen,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('candy apple red'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,meanGammaOpen,stdGammaOpen,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
s2 = scatter(ones(1,length(gammaClosed))*2,gammaClosed,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('sapphire'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(2,meanGammaClosed,stdGammaClosed,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
ylabel('\DeltaP/P (%)')
title('REM Cort Gamma')
legend([s1,s2],'Eyes open','Eyes closed')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,3])
set(gca,'box','off')
subplot(1,3,3)
s1 = scatter(ones(1,length(hipOpen))*1,hipOpen,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('candy apple red'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,meanHipOpen,stdHipOpen,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
s2 = scatter(ones(1,length(hipClosed))*2,hipClosed,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('sapphire'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(2,meanHipClosed,stdHipClosed,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
ylabel('\DeltaP/P (%)')
title('REM Hip Theta')
legend([s1,s2],'Eyes open','Eyes closed')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,3])
set(gca,'box','off')
%%
resultsStruct = 'Results_Transitions.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_Transitions);
transitions = {'AWAKEtoNREM','NREMtoAWAKE','NREMtoREM','REMtoAWAKE'};
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    for bb = 1:length(transitions)
        transition = transitions{1,bb};
        data.(transition).mmDiameter(aa,:) = mean(Results_Transitions.(animalID).(transition).mmDiameter);
        data.(transition).zDiameter(aa,:) = mean(Results_Transitions.(animalID).(transition).zDiameter);
    end
end
% take average for each behavioral transition
for cc = 1:length(transitions)
    transition = transitions{1,cc};
    data.(transition).meanZ = mean(data.(transition).zDiameter,1);
    data.(transition).stdZ = std(data.(transition).zDiameter,0,1);
    data.(transition).meanMM = mean(data.(transition).mmDiameter,1);
    data.(transition).stdMM = std(data.(transition).mmDiameter,0,1);
end
T1 = -30 + (1/30):(1/30):30;
%% mm figure
figure
ax1 = subplot(2,2,1);
plot(T1,data.AWAKEtoNREM.meanMM,'-','color',colors('dark candy apple red'),'LineWidth',2);
hold on
plot(T1,data.AWAKEtoNREM.meanMM + data.AWAKEtoNREM.stdMM,'-','color',colors('dark candy apple red'),'LineWidth',0.5);
plot(T1,data.AWAKEtoNREM.meanMM - data.AWAKEtoNREM.stdMM,'-','color',colors('dark candy apple red'),'LineWidth',0.5);
xlim([-30,30])
title('Awake to NREM')
xlabel('Time (s)')
ylabel('Diameter (mm)')
set(gca,'box','off')
%
ax2 = subplot(2,2,2);
plot(T1,data.NREMtoAWAKE.meanMM,'-','color',colors('sapphire'),'LineWidth',2);
hold on
plot(T1,data.NREMtoAWAKE.meanMM + data.NREMtoAWAKE.stdMM,'-','color',colors('sapphire'),'LineWidth',0.5);
plot(T1,data.NREMtoAWAKE.meanMM - data.NREMtoAWAKE.stdMM,'-','color',colors('sapphire'),'LineWidth',0.5);
xlim([-30,30])
title('NREM to Awake')
xlabel('Time (s)')
ylabel('Diameter (mm)')
set(gca,'box','off')
%
ax3 = subplot(2,2,3);
plot(T1,data.NREMtoREM.meanMM,'-','color',colors('carrot orange'),'LineWidth',2);
hold on
plot(T1,data.NREMtoREM.meanMM + data.NREMtoREM.stdMM,'-','color',colors('carrot orange'),'LineWidth',0.5);
plot(T1,data.NREMtoREM.meanMM - data.NREMtoREM.stdMM,'-','color',colors('carrot orange'),'LineWidth',0.5);
xlim([-30,30])
title('NREM to REM')
xlabel('Time (s)')
ylabel('Diameter (mm)')
set(gca,'box','off')
%
ax4 = subplot(2,2,4);
plot(T1,data.REMtoAWAKE.meanMM,'-','color',colors('vegas gold'),'LineWidth',2);
hold on
plot(T1,data.REMtoAWAKE.meanMM + data.REMtoAWAKE.stdMM,'-','color',colors('vegas gold'),'LineWidth',0.5);
plot(T1,data.REMtoAWAKE.meanMM - data.REMtoAWAKE.stdMM,'-','color',colors('vegas gold'),'LineWidth',0.5);
xlim([-30,30])
title('REM to Awake')
xlabel('Time (s)')
ylabel('Diameter (mm)')
set(gca,'box','off')
linkaxes([ax1,ax2,ax3,ax4],'xy')
%% z-unit figure
figure
ax1 = subplot(2,2,1);
plot(T1,data.AWAKEtoNREM.meanZ,'-','color',colors('dark candy apple red'),'LineWidth',2);
hold on
plot(T1,data.AWAKEtoNREM.meanZ + data.AWAKEtoNREM.stdZ,'-','color',colors('dark candy apple red'),'LineWidth',0.5);
plot(T1,data.AWAKEtoNREM.meanZ - data.AWAKEtoNREM.stdZ,'-','color',colors('dark candy apple red'),'LineWidth',0.5);
xlim([-30,30])
title('Awake to NREM')
xlabel('Time (s)')
ylabel('Diameter (Z)')
set(gca,'box','off')
%
ax2 = subplot(2,2,2);
plot(T1,data.NREMtoAWAKE.meanZ,'-','color',colors('sapphire'),'LineWidth',2);
hold on
plot(T1,data.NREMtoAWAKE.meanZ + data.NREMtoAWAKE.stdZ,'-','color',colors('sapphire'),'LineWidth',0.5);
plot(T1,data.NREMtoAWAKE.meanZ - data.NREMtoAWAKE.stdZ,'-','color',colors('sapphire'),'LineWidth',0.5);
xlim([-30,30])
title('NREM to Awake')
xlabel('Time (s)')
ylabel('Diameter (Z)')
set(gca,'box','off')
%
ax3 = subplot(2,2,3);
plot(T1,data.NREMtoREM.meanZ,'-','color',colors('carrot orange'),'LineWidth',2);
hold on
plot(T1,data.NREMtoREM.meanZ + data.NREMtoREM.stdZ,'-','color',colors('carrot orange'),'LineWidth',0.5);
plot(T1,data.NREMtoREM.meanZ - data.NREMtoREM.stdZ,'-','color',colors('carrot orange'),'LineWidth',0.5);
xlim([-30,30])
title('NREM to REM')
xlabel('Time (s)')
ylabel('Diameter (Z)')
set(gca,'box','off')
%
ax4 = subplot(2,2,4);
plot(T1,data.REMtoAWAKE.meanZ,'-','color',colors('vegas gold'),'LineWidth',2);
hold on
plot(T1,data.REMtoAWAKE.meanZ + data.REMtoAWAKE.stdZ,'-','color',colors('vegas gold'),'LineWidth',0.5);
plot(T1,data.REMtoAWAKE.meanZ - data.REMtoAWAKE.stdZ,'-','color',colors('vegas gold'),'LineWidth',0.5);
xlim([-30,30])
title('REM to Awake')
xlabel('Time (s)')
ylabel('Diameter (Z)')
set(gca,'box','off')
linkaxes([ax1,ax2,ax3,ax4],'xy')
%% sleep model accuracy based on pupil alone
resultsStruct = 'Results_PupilSleepModel.mat';
load(resultsStruct);
resultsStruct = 'Results_PhysioSleepModel.mat';
load(resultsStruct);
resultsStruct = 'Results_CombinedSleepModel.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_PupilSleepModel);
data.pupil.holdXlabels = []; data.pupil.holdYlabels = [];
data.physio.holdXlabels = []; data.physio.holdYlabels = [];
data.combined.holdXlabels = []; data.combined.holdYlabels = [];
for dd = 1:length(animalIDs)
    animalID = animalIDs{dd,1};
    data.pupil.holdXlabels = cat(1,data.pupil.holdXlabels,Results_PupilSleepModel.(animalID).pupil.predictedTestingLabels);
    data.pupil.holdYlabels = cat(1,data.pupil.holdYlabels,Results_PupilSleepModel.(animalID).pupil.trueTestingLabels);
    data.physio.holdXlabels = cat(1,data.physio.holdXlabels,Results_PhysioSleepModel.(animalID).physio.predictedTestingLabels);
    data.physio.holdYlabels = cat(1,data.physio.holdYlabels,Results_PhysioSleepModel.(animalID).physio.trueTestingLabels);
    data.combined.holdXlabels = cat(1,data.combined.holdXlabels,Results_CombinedSleepModel.(animalID).combined.predictedTestingLabels);
    data.combined.holdYlabels = cat(1,data.combined.holdYlabels,Results_CombinedSleepModel.(animalID).combined.trueTestingLabels);
end
% figure
figure;
subplot(1,3,1)
cm = confusionchart(data.pupil.holdYlabels,data.pupil.holdXlabels);
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
confVals = cm.NormalizedValues;
totalScores = sum(confVals(:));
modelAccuracy = round((sum(confVals([1,5,9])/totalScores))*100,1);
cm.Title = {'Pupil RF',['total accuracy: ' num2str(modelAccuracy) ' (%)']};
subplot(1,3,2)
cm = confusionchart(data.physio.holdYlabels,data.physio.holdXlabels);
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
confVals = cm.NormalizedValues;
totalScores = sum(confVals(:));
modelAccuracy = round((sum(confVals([1,5,9])/totalScores))*100,1);
cm.Title = {'Phsio RF',['total accuracy: ' num2str(modelAccuracy) ' (%)']};
subplot(1,3,3)
cm = confusionchart(data.combined.holdYlabels,data.combined.holdXlabels);
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
confVals = cm.NormalizedValues;
totalScores = sum(confVals(:));
modelAccuracy = round((sum(confVals([1,5,9])/totalScores))*100,1);
cm.Title = {'Combined RF',['total accuracy: ' num2str(modelAccuracy) ' (%)']};