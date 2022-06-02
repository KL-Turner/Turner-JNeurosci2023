function [AnalysisResults] = Fig5_Turner2022(rootFolder,saveFigs,delim,AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: Generate figures and supporting information for Figure Panel 5
%________________________________________________________________________________________________________________________

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
asleepProbPerc = Results_SleepProbability.asleepProbPerc./100;
%% Sleep model accuracy based on pupil zDiameter alone
resultsStructB = 'Results_PupilSleepModel.mat';
load(resultsStructB);
animalIDs = fieldnames(Results_PupilSleepModel);
data.pupil.holdXlabels = []; data.pupil.holdYlabels = [];
for dd = 1:length(animalIDs)
    animalID = animalIDs{dd,1};
    if strcmp(animalID,'T141') == true
        Xodd = Results_PupilSleepModel.(animalID).SVM.Xodd;
        Yodd = Results_PupilSleepModel.(animalID).SVM.Yodd;
        exampleBoundary = Results_PupilSleepModel.(animalID).SVM.zBoundary;
    end
    data.pupil.rocX{dd,1} = Results_PupilSleepModel.(animalID).SVM.rocX';
    data.pupil.rocY{dd,1} = Results_PupilSleepModel.(animalID).SVM.rocY';
    data.pupil.rocAUC(dd,1) = Results_PupilSleepModel.(animalID).SVM.rocAUC;
    data.pupil.rocOPTROCPT{dd,1} = Results_PupilSleepModel.(animalID).SVM.rocOPTROCPT;
    data.pupil.loss(dd,:) = Results_PupilSleepModel.(animalID).SVM.loss;
    data.pupil.zBoundary(dd,1) = Results_PupilSleepModel.(animalID).SVM.zBoundary;
    data.pupil.mBoundary(dd,1) = Results_PupilSleepModel.(animalID).SVM.mmBoundary;
    data.pupil.holdXlabels = cat(1,data.pupil.holdXlabels,Results_PupilSleepModel.(animalID).SVM.testXlabels);
    data.pupil.holdYlabels = cat(1,data.pupil.holdYlabels,Results_PupilSleepModel.(animalID).SVM.testYlabels);
end
data.pupil.rocMeanAUC = mean(data.pupil.rocAUC,1);
data.pupil.rocStdAUC = std(data.pupil.rocAUC,0,1);
data.pupil.meanLoss = mean(data.pupil.loss,1);
data.pupil.stdLoss = std(data.pupil.loss,0,1);
data.pupil.meanZBoundary = mean(data.pupil.zBoundary,1);
data.pupil.stdZBoundary = std(data.pupil.zBoundary,0,1);
data.pupil.meanMBoundary = mean(data.pupil.mBoundary,1);
data.pupil.stdMBoundary = std(data.pupil.mBoundary,0,1);
%% Sleep model accuracy based on physiology
resultsStructB = 'Results_PhysioSleepModel.mat';
load(resultsStructB);
animalIDs = fieldnames(Results_PhysioSleepModel);
data.physio.holdXlabels = []; data.physio.holdYlabels = [];
for dd = 1:length(animalIDs)
    animalID = animalIDs{dd,1};
    data.physio.loss(dd,1) = Results_PhysioSleepModel.(animalID).SVM.loss;
    data.physio.holdXlabels = cat(1,data.physio.holdXlabels,Results_PhysioSleepModel.(animalID).SVM.testXlabels);
    data.physio.holdYlabels = cat(1,data.physio.holdYlabels,Results_PhysioSleepModel.(animalID).SVM.testYlabels);
end
data.physio.meanLoss = mean(data.physio.loss,1);
data.physio.stdLoss = std(data.physio.loss,0,1);
[lossStats.h,lossStats.p,lossStats.ci,lossStats.stats] = ttest2(data.physio.loss,data.pupil.loss);
%% pupil model coherence
resultsStruct = 'Results_PupilModelCoherence.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_PupilModelCoherence);
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    data.Coherr.pupilf(aa,:) = Results_PupilModelCoherence.(animalID).Pupil.f;
    data.Coherr.pupilC(aa,:) = Results_PupilModelCoherence.(animalID).Pupil.C;
    data.Coherr.physiof(aa,:) = Results_PupilModelCoherence.(animalID).Physio.f;
    data.Coherr.physioC(aa,:) = Results_PupilModelCoherence.(animalID).Physio.C;
end
data.Coherr.meanPupilf = mean(data.Coherr.pupilf,1);
data.Coherr.meanPupilC = mean(data.Coherr.pupilC,1);
data.Coherr.stdPupilC = std(data.Coherr.pupilC,0,1)/sqrt(size(data.Coherr.pupilC,1));
data.Coherr.meanPhysiof = mean(data.Coherr.physiof,1);
data.Coherr.meanPhysioC = mean(data.Coherr.physioC,1);
data.Coherr.stdPhysioC = std(data.Coherr.physioC,0,1)/sqrt(size(data.Coherr.physioC,1));
%% load data
dataStructure = 'Results_Example.mat';
load(dataStructure)
binTime = 5; % sec
for aa = 1:length(Results_Example.trueLabels)
    if strcmp(Results_Example.trueLabels{aa,1},'Not Sleep') == true
        trueAwake(aa,1) = 1;
        trueAsleep(aa,1) = 0;
    elseif strcmp(Results_Example.trueLabels{aa,1},'NREM Sleep') == true || strcmp(Results_Example.trueLabels{aa,1},'REM Sleep') == true
        trueAwake(aa,1) = 0;
        trueAsleep(aa,1) = 1;
    end
end
for aa = 1:length(Results_Example.trueLabels)
    if strcmp(Results_Example.trueLabels{aa,1},'Not Sleep') == true
        trueNREM(aa,1) = 0;
        trueREM(aa,1) = 0;
    elseif strcmp(Results_Example.trueLabels{aa,1},'NREM Sleep') == true
        trueNREM(aa,1) = 1;
        trueREM(aa,1) = 0;
    elseif strcmp(Results_Example.trueLabels{aa,1},'REM Sleep') == true
        trueNREM(aa,1) = 0;
        trueREM(aa,1) = 1;
    end
end
[physioPred,~] = predict(Results_PhysioSleepModel.T141.SVM.mdl,Results_Example.physioTable);
physioPredAwake = strcmp(physioPred,'Awake');
physioPredAsleep = strcmp(physioPred,'Asleep');
[pupilPred,~] = predict(Results_PupilSleepModel.T141.SVM.mdl,Results_Example.pupilTable);
pupilPredAwake = strcmp(pupilPred,'Awake');
pupilPredAsleep = strcmp(pupilPred,'Asleep');
%% load data
catTrueAwake = []; catTrueAsleep = []; catTrueNREM = []; catTrueREM = [];
catPhysioAwake = []; catPhysioAsleep = []; catPupilAwake = []; catPupilAsleep = [];
for qq = 1:length(Results_Example.allPhysioTables)
    physioTable = Results_Example.allPhysioTables{qq,1};
    physioModel = physioTable(:,1:end - 1);
    pupilTable = Results_Example.allPupilTables{qq,1};
    pupilModel = pupilTable(:,1);
    trueLabels = physioTable.behavState;
    for aa = 1:length(trueLabels)
        if strcmp(trueLabels{aa,1},'Not Sleep') == true
            allTrueAwake(aa,1) = 1;
            allTrueAsleep(aa,1) = 0;
        elseif strcmp(trueLabels{aa,1},'NREM Sleep') == true || strcmp(trueLabels{aa,1},'REM Sleep') == true
            allTrueAwake(aa,1) = 0;
            allTrueAsleep(aa,1) = 1;
        end
    end
    for aa = 1:length(trueLabels)
        if strcmp(trueLabels{aa,1},'Not Sleep') == true
            allTrueNREM(aa,1) = 0;
            allTrueREM(aa,1) = 0;
        elseif strcmp(trueLabels{aa,1},'NREM Sleep') == true
            allTrueNREM(aa,1) = 1;
            allTrueREM(aa,1) = 0;
        elseif strcmp(trueLabels{aa,1},'REM Sleep') == true
            allTrueNREM(aa,1) = 0;
            allTrueREM(aa,1) = 1;
        end
    end
    [allPhysioPred,~] = predict(Results_PhysioSleepModel.T141.SVM.mdl,physioModel);
    allPhysioPredAwake = strcmp(allPhysioPred,'Awake');
    allPhysioPredAsleep = strcmp(allPhysioPred,'Asleep');
    [allPupilPred,~] = predict(Results_PupilSleepModel.T141.SVM.mdl,pupilModel);
    allPupilPredAwake = strcmp(allPupilPred,'Awake');
    allPupilPredAsleep = strcmp(allPupilPred,'Asleep');
    if qq == 1
        catTrueAwake = allTrueAwake;
        catTrueAsleep = allTrueAsleep;
        catTrueNREM = allTrueNREM;
        catTrueREM = allTrueREM;
        catPhysioAwake = allPhysioPredAwake;
        catPhysioAsleep = allPhysioPredAsleep;
        catPupilAwake = allPupilPredAwake;
        catPupilAsleep = allPupilPredAsleep;
    else
        delayBins = Results_Example.timePadBins{qq - 1,1};
        timePadArray = NaN(length(delayBins),1);
        catTrueAwake = cat(1,catTrueAwake,timePadArray,allTrueAwake);
        catTrueAsleep = cat(1,catTrueAsleep,timePadArray,allTrueAsleep);
        catTrueNREM = cat(1,catTrueNREM,timePadArray,allTrueNREM);
        catTrueREM = cat(1,catTrueREM,timePadArray,allTrueREM);
        catPhysioAwake = cat(1,catPhysioAwake,timePadArray,allPhysioPredAwake);
        catPhysioAsleep = cat(1,catPhysioAsleep,timePadArray,allPhysioPredAsleep);
        catPupilAwake = cat(1,catPupilAwake,timePadArray,allPupilPredAwake);
        catPupilAsleep = cat(1,catPupilAsleep,timePadArray,allPupilPredAsleep);
    end
end
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
    dirpath = [rootFolder delim 'Figure Panels' delim];
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
%% Figure
Fig5B = figure('Name','Figure Panel 5 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
ax1 = subplot(2,3,1);
edges = -8:0.1:6.5;
yyaxis right
h1 = histogram(diameterAllCatMeans,edges,'Normalization','probability','EdgeColor',colors('black'),'FaceColor',colors('black'));
ylabel('Probability','rotation',-90,'VerticalAlignment','bottom')
yyaxis left
p1 = plot(edges,sgolayfilt(medfilt1(awakeProbPerc,10,'truncate'),3,17),'-','color',colors('battleship grey'),'LineWidth',2);
hold on
p2 = plot(edges,sgolayfilt(medfilt1(nremProbPerc,10,'truncate'),3,17),'-','color',colors('cyan'),'LineWidth',2);
p3 = plot(edges,sgolayfilt(medfilt1(remProbPerc,10,'truncate'),3,17),'-','color',colors('candy apple red'),'LineWidth',2);
p4 = plot(edges,sgolayfilt(medfilt1(asleepProbPerc,10,'truncate'),3,17),'-','color',colors('royal purple'),'LineWidth',2);
ylabel({'Arousal-state probability (%)'})
xlim([-8,6.5])
ylim([0,1])
legend([p1,p2,p3,p4,h1],'Awake','NREM','REM','Asleep','\DeltaArea','Location','NorthEast')
title('Diameter vs. arousal state')
xlabel('Diameter (z-units)')
axis square
set(gca,'box','off')
set(gca,'TickLength',[0.03,0.03]);
set(h1,'facealpha',0.2);
ax1.TickLength = [0.03,0.03];
ax1.YAxis(1).Color = colors('black');
ax1.YAxis(2).Color = colors('dark candy apple red');
%% Gamma
subplot(2,3,2)
gammaPupilImg = imread('GammaPupilStack.png'); % needs made by combining images in ImageJ (Z project min)
imshow(gammaPupilImg)
axis off
title('Pupil-Gamma')
xlabel('Diameter (z-units)')
ylabel('\DeltaP/P (%)')
%% HbT
subplot(2,3,3)
HbTPupilImg = imread('HbTPupilStack.png'); % needs made by combining images in ImageJ (Z project min)
imshow(HbTPupilImg)
axis off
title('Pupil-HbT')
xlabel('Diameter (z-units)')
ylabel('\Delta[HbT] (\muM)')
%% sleep model confusion matrix
subplot(2,4,5)
cm = confusionchart(data.physio.holdYlabels,data.physio.holdXlabels);
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
confVals = cm.NormalizedValues;
totalScores = sum(confVals(:));
modelAccuracy = round((sum(confVals([1,4])/totalScores))*100,1);
cm.Title = {'Physio SVM',['total accuracy: ' num2str(modelAccuracy) ' (%)']};
%% sleep model confusion matrix
subplot(2,4,6)
cm = confusionchart(data.pupil.holdYlabels,data.pupil.holdXlabels);
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
confVals = cm.NormalizedValues;
totalScores = sum(confVals(:));
modelAccuracy = round((sum(confVals([1,4])/totalScores))*100,1);
cm.Title = {'Pupil SVM',['total accuracy: ' num2str(modelAccuracy) ' (%)']};
%% sleep model 10-fold loss
ax6 = subplot(2,4,7);
s1 = scatter(ones(1,length(data.physio.loss))*1,data.physio.loss,75,'MarkerEdgeColor',colors('black'),'MarkerFaceColor',colors('black'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.physio.meanLoss,data.physio.stdLoss,'d','MarkerEdgeColor',colors('black'),'MarkerFaceColor',colors('black'));
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
s2 = scatter(ones(1,length(data.pupil.loss))*2,data.pupil.loss,75,'MarkerEdgeColor',colors('black'),'MarkerFaceColor',colors('sapphire'),'jitter','on','jitterAmount',0.25);
hold on
e2 = errorbar(2,data.pupil.meanLoss,data.pupil.stdLoss,'d','MarkerEdgeColor',colors('black'),'MarkerFaceColor',colors('black'));
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
title('10-fold cross validation')
ylabel('Loss (mean squared error)')
legend([s1,s2],'Physio mdl','Pupil mdl','Location','NorthWest')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,3])
ylim([0,0.2])
set(gca,'box','off')
ax6.TickLength = [0.03,0.03];
%% model coherence
subplot(2,4,8);
s1 = semilogx(data.Coherr.meanPhysiof,data.Coherr.meanPhysioC,'color',colors('black'),'LineWidth',2);
hold on
semilogx(data.Coherr.meanPhysiof,data.Coherr.meanPhysioC + data.Coherr.stdPhysioC,'color',colors('black'),'LineWidth',0.5);
semilogx(data.Coherr.meanPhysiof,data.Coherr.meanPhysioC - data.Coherr.stdPhysioC,'color',colors('black'),'LineWidth',0.5);
s2 = semilogx(data.Coherr.meanPupilf,data.Coherr.meanPupilC,'color',colors('sapphire'),'LineWidth',2);
semilogx(data.Coherr.meanPupilf,data.Coherr.meanPupilC + data.Coherr.stdPupilC,'color',colors('sapphire'),'LineWidth',0.5);
semilogx(data.Coherr.meanPupilf,data.Coherr.meanPupilC - data.Coherr.stdPupilC,'color',colors('sapphire'),'LineWidth',0.5);
x1 = xline(1/30,'color',[0,0.4,0]);
x2 = xline(1/60,'color','m');
title('Model accuracy coherence')
ylabel('Coherence')
xlabel('Freq (Hz)')
legend([s1,s2,x1,x2],'Physio mdl','Pupil mdl','NREM req','REM req')
axis square
% xlim([0.003,0])
ylim([0,1])
set(gca,'box','off')
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'Figure Panels' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig5B,[dirpath 'Fig5B_Turner2022']);
    set(Fig5B,'PaperPositionMode','auto');
    print('-vector','-dpdf','-fillpage',[dirpath 'Fig5B_Turner2022'])
end
%% hypnogram for model comparison
Fig5C = figure('Name','Figure Panel 5 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
subplot(10,1,1)
b1 = bar(((1:length(catTrueAwake))*binTime)/60/60,catTrueAwake,'FaceColor',colors('black'),'BarWidth',1);
hold on
b2 = bar(((1:length(catTrueNREM))*binTime)/60/60,catTrueNREM,'FaceColor',colors('cyan'),'BarWidth',1);
b3 = bar(((1:length(catTrueREM))*binTime)/60/60,catTrueREM,'FaceColor',colors('candy apple red'),'BarWidth',1);
title('Manually scored predictions');
legend([b1,b2,b3],'Awake','NREM','REM')
set(gca,'box','off')
subplot(10,1,2)
b1 = bar((1:length(catTrueAwake))*binTime,catTrueAwake,'FaceColor',colors('black'),'BarWidth',1);
hold on
b2 = bar((1:length(catTrueAsleep))*binTime,catTrueAsleep,'FaceColor',colors('royal purple'),'BarWidth',1);
title('Manually scored predictions');
legend([b1,b2],'Awake','Asleep')
set(gca,'box','off')
axis off
subplot(10,1,3)
bar((1:length(catPhysioAwake))*binTime,catPhysioAwake,'FaceColor',colors('black'),'BarWidth',1);
hold on
bar((1:length(catPhysioAsleep))*binTime,catPhysioAsleep,'FaceColor',colors('royal purple'),'BarWidth',1);
title('Physio model predictions');
set(gca,'box','off')
axis off
subplot(10,1,4)
bar((1:length(catPupilAwake))*binTime,catPupilAwake,'FaceColor',colors('black'),'BarWidth',1);
hold on
bar((1:length(catPupilAsleep))*binTime,catPupilAsleep,'FaceColor',colors('royal purple'),'BarWidth',1);
title('Pupil model predictions');
set(gca,'box','off')
axis off
subplot(10,1,5)
b1 = bar((1:length(trueAwake))*binTime,trueAwake,'FaceColor',colors('black'),'BarWidth',1);
hold on
b2 = bar((1:length(trueNREM))*binTime,trueNREM,'FaceColor',colors('cyan'),'BarWidth',1);
b3 = bar((1:length(trueREM))*binTime,trueREM,'FaceColor',colors('candy apple red'),'BarWidth',1);
title('Manually scored predictions');
legend([b1,b2,b3],'Awake','NREM','REM')
set(gca,'box','off')
axis off
subplot(10,1,6)
b1 = bar((1:length(trueAwake))*binTime,trueAwake,'FaceColor',colors('black'),'BarWidth',1);
hold on
b2 = bar((1:length(trueNREM))*binTime,trueNREM,'FaceColor',colors('cyan'),'BarWidth',1);
b3 = bar((1:length(trueREM))*binTime,trueREM,'FaceColor',colors('candy apple red'),'BarWidth',1);
title('Manually scored predictions');
legend([b1,b2,b3],'Awake','NREM','REM')
xlim([0,450])
set(gca,'box','off')
axis off
subplot(10,1,7)
b1 = bar((1:length(trueAwake))*binTime,trueAwake,'FaceColor',colors('black'),'BarWidth',1);
hold on
b2 = bar((1:length(trueAsleep))*binTime,trueAsleep,'FaceColor',colors('royal purple'),'BarWidth',1);
title('Manually scored predictions');
legend([b1,b2],'Awake','Asleep')
xlim([0,450])
set(gca,'box','off')
axis off
subplot(10,1,8)
bar((1:length(physioPredAwake))*binTime,physioPredAwake,'FaceColor',colors('black'),'BarWidth',1);
hold on
bar((1:length(physioPredAsleep))*binTime,physioPredAsleep,'FaceColor',colors('royal purple'),'BarWidth',1);
title('Physio model predictions');
xlim([0,450])
set(gca,'box','off')
axis off
subplot(10,1,9)
bar((1:length(pupilPredAwake))*binTime,pupilPredAwake,'FaceColor',colors('black'),'BarWidth',1);
hold on
bar((1:length(pupilPredAsleep))*binTime,pupilPredAsleep,'FaceColor',colors('royal purple'),'BarWidth',1);
title('Pupil model predictions');
xlim([0,450])
set(gca,'box','off')
axis off
subplot(10,1,10)
plot((1:length(Results_Example.filtPupilZDiameter))/Results_Example.dsFs,Results_Example.filtPupilZDiameter,'color',colors('black'));
hold on;
yline(exampleBoundary,'color',colors('custom green'),'LineWidth',2)
ylabel('Diameter (z-units)');
xlabel('Time (sec)')
xlim([0,450])
set(gca,'box','off')
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'Figure Panels' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig5C,[dirpath 'Fig5C_Turner2022']);
    set(Fig5C,'PaperPositionMode','auto');
    print('-vector','-dpdf','-fillpage',[dirpath 'Fig5C_Turner2022'])
end
%% SVM decision scatter
Fig5D = figure('Name','Figure Panel 5 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
subplot(1,4,1);
gscatter(Xodd.zDiameter,randn(length(Xodd.zDiameter),1),Yodd.behavState,[colors('black');colors('royal purple')]);
hold on;
xline(exampleBoundary,'color',colors('custom green'),'LineWidth',2)
title('Single predictor, binary class SVM')
xlabel('Diameter (z-units)')
legend('Awake','Asleep','Decision boundary','Location','NorthEast')
axis square
set(gca,'YTickLabel',[]);
set(gca,'box','off')
%% SVM boundary
subplot(1,4,2)
scatter(ones(1,length(data.pupil.mBoundary))*1,data.pupil.mBoundary,75,'MarkerEdgeColor',colors('black'),'MarkerFaceColor',colors('custom green'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.pupil.meanMBoundary,data.pupil.stdMBoundary,'d','MarkerEdgeColor',colors('black'),'MarkerFaceColor',colors('black'));
e1.Color = colors('black');
e1.MarkerSize = 10;
e1.CapSize = 10;
title('SVM pupil hyperplane (mm)')
ylabel('Decision (mm)')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,2])
set(gca,'box','off')
ax6.TickLength = [0.03,0.03];
%% ROC
subplot(1,4,3)
for aa = 1:length(data.pupil.rocX)
    hold on
    plot(data.pupil.rocX{aa,1},data.pupil.rocY{aa,1},'color',colors('black'))
    plot(data.pupil.rocOPTROCPT{aa,1}(1),data.pupil.rocOPTROCPT{aa,1}(2),'o','color',colors('turquoise'))
end
xlabel('False positive rate')
ylabel('True positive rate')
title('ROC Curve')
xlim([-0.05,1])
ylim([0,1.05])
axis square
%% ROC AUC
subplot(1,4,4)
scatter(ones(1,length(data.pupil.rocAUC))*1,data.pupil.rocAUC,75,'MarkerEdgeColor',colors('black'),'MarkerFaceColor',colors('battleship grey'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.pupil.rocMeanAUC,data.pupil.rocStdAUC,'d','MarkerEdgeColor',colors('black'),'MarkerFaceColor',colors('black'));
e1.Color = colors('black');
e1.MarkerSize = 10;
e1.CapSize = 10;
title('ROC area under curve')
ylabel('AUC (1 = perfect model)')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,2])
set(gca,'box','off')
ax6.TickLength = [0.03,0.03];
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'Figure Panels' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig5D,[dirpath 'Fig5D_Turner2022']);
    set(Fig5D,'PaperPositionMode','auto');
    print('-vector','-dpdf','-fillpage',[dirpath 'Fig5D_Turner2022'])
    % text diary
    diaryFile = [dirpath 'Fig5_Text.txt'];
    if exist(diaryFile,'file') == 2
        delete(diaryFile)
    end
    diary(diaryFile)
    diary on
    % example boundary decision
    disp('======================================================================================================================')
    disp('Example boundary decision')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Example boundary: ' num2str(exampleBoundary) ' z-units']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    % Mean z-unit decision boundary
    disp('======================================================================================================================')
    disp('Mean z-unit decision boundary')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['z-unit decision boundary: ' num2str(data.pupil.meanZBoundary) ' ± ' num2str(data.pupil.stdZBoundary) ' z-units (n = ' num2str(length(data.pupil.zBoundary)) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    % Mean mm decision boundary
    disp('======================================================================================================================')
    disp('Mean mm decision boundary')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['mm decision boundary: ' num2str(data.pupil.meanMBoundary) ' ± ' num2str(data.pupil.stdMBoundary) ' mm (n = ' num2str(length(data.pupil.mBoundary)) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    % Physio model loss
    disp('======================================================================================================================')
    disp('Physiol model loss')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Physio model loss: ' num2str(data.physio.meanLoss) ' ± ' num2str(data.physio.stdLoss) ' (n = ' num2str(length(data.physio.loss)) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    % Pupil model loss
    disp('======================================================================================================================')
    disp('Pupil model loss')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Pupil model loss: ' num2str(data.pupil.meanLoss) ' ± ' num2str(data.pupil.stdLoss) ' (n = ' num2str(length(data.pupil.loss)) ') mice']); disp(' ')
    disp(['p < ' num2str(lossStats.p)]); disp(' ')    
    disp('----------------------------------------------------------------------------------------------------------------------')
    % Mean ROC AUC
    disp('======================================================================================================================')
    disp('Pupil ROC AUC')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['AUC: ' num2str(data.pupil.rocMeanAUC) ' ± ' num2str(data.pupil.rocStdAUC) ' (n = ' num2str(length(data.pupil.rocAUC)) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    diary off
end

end
