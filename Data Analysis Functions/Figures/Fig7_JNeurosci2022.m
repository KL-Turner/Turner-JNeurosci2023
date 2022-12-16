function [AnalysisResults] = Fig7_JNeurosci2022(rootFolder,saveFigs,delim,AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: Generate figures and supporting information for Figure Panel 7
%________________________________________________________________________________________________________________________

dataLocation = [rootFolder delim 'Analysis Structures'];
cd(dataLocation)
%% MDL predictions vs. manual scores
dataStructure = 'Results_Example.mat';
load(dataStructure)
binTime = 5; % sec
% extract and binarize the true labels for single 15 minute example
for aa = 1:length(Results_Example.trueLabels)
    if strcmp(Results_Example.trueLabels{aa,1},'Not Sleep') == true
        trueAwake(aa,1) = 1;
        trueNREM(aa,1) = 0;
        trueREM(aa,1) = 0;
    elseif strcmp(Results_Example.trueLabels{aa,1},'NREM Sleep') == true
        trueAwake(aa,1) = 0;
        trueNREM(aa,1) = 1;
        trueREM(aa,1) = 0;
    elseif strcmp(Results_Example.trueLabels{aa,1},'REM Sleep') == true
        trueAwake(aa,1) = 0;
        trueNREM(aa,1) = 0;
        trueREM(aa,1) = 1;
    end
end
% pupil MDL predictions for single 15 minute example
resultsStruct = 'Results_PupilSleepModel.mat';
load(resultsStruct);
[pupilPred,~] = predict(Results_PupilSleepModel.T141.pupil.mdl,Results_Example.pupilTable);
dataLength = size(Results_Example.pupilTable,1);
[pupilPred] = FilterIndexREM_JNeurosci2022(pupilPred,dataLength);
pupilPredAwake = strcmp(pupilPred,'Not Sleep');
pupilPredNREM = strcmp(pupilPred,'NREM Sleep');
pupilPredREM = strcmp(pupilPred,'REM Sleep');
% physio MDL predictions for single 15 minute example
resultsStruct = 'Results_PhysioSleepModel.mat';
load(resultsStruct);
[physioPred,~] = predict(Results_PhysioSleepModel.T141.physio.mdl,Results_Example.physioTable);
[physioPred] = FilterIndexREM_JNeurosci2022(physioPred,dataLength);
physioPredAwake = strcmp(physioPred,'Not Sleep');
physioPredNREM = strcmp(physioPred,'NREM Sleep');
physioPredREM = strcmp(physioPred,'REM Sleep');
% combined MDL predictions for single 15 minute example
resultsStruct = 'Results_CombinedSleepModel.mat';
load(resultsStruct);
[combinedPred,~] = predict(Results_CombinedSleepModel.T141.combined.mdl,Results_Example.combinedTable);
[combinedPred] = FilterIndexREM_JNeurosci2022(combinedPred,dataLength);
combinedPredAwake = strcmp(combinedPred,'Not Sleep');
combinedPredNREM = strcmp(combinedPred,'NREM Sleep');
combinedPredREM = strcmp(combinedPred,'REM Sleep');
%% MDL predictions vs. manual scores for entire day
catTrueAwake = []; catTrueNREM = []; catTrueREM = [];
catPupilAwake = []; catPupilNREM = []; catPupilREM = [];
catPhysioAwake = []; catPhysioNREM = []; catPhysioREM = [];
catCombinedAwake = []; catCombinedNREM = []; catCombinedREM = [];
for qq = 1:length(Results_Example.allPhysioTables)
    % pupil MDL
    pupilTable = Results_Example.allPupilTables{qq,1};
    pupilModel = pupilTable(:,1:end -1);
    [allPupilPred,~] = predict(Results_PupilSleepModel.T141.pupil.mdl,pupilModel);
    [allPupilPred] = FilterIndexREM_JNeurosci2022(allPupilPred,dataLength);
    % physio MDL
    physioTable = Results_Example.allPhysioTables{qq,1};
    physioModel = physioTable(:,1:end - 1);
    [allPhysioPred,~] = predict(Results_PhysioSleepModel.T141.physio.mdl,physioModel);
    [allPhysioPred] = FilterIndexREM_JNeurosci2022(allPhysioPred,dataLength);
    % combined MDL
    combinedTable = Results_Example.allCombinedTables{qq,1};
    combinedModel = combinedTable(:,1:end -1);
    [allCombinedPred,~] = predict(Results_CombinedSleepModel.T141.combined.mdl,combinedModel);
    [allCombinedPred] = FilterIndexREM_JNeurosci2022(allCombinedPred,dataLength);

    trueLabels = pupilTable.behavState;
    % extract and binarize the labels
    for aa = 1:length(trueLabels)
        if strcmp(trueLabels{aa,1},'Not Sleep') == true
            allTrueAwake(aa,1) = 1;
            allTrueNREM(aa,1) = 0;
            allTrueREM(aa,1) = 0;
        elseif strcmp(trueLabels{aa,1},'NREM Sleep') == true
            allTrueAwake(aa,1) = 0;
            allTrueNREM(aa,1) = 1;
            allTrueREM(aa,1) = 0;
        elseif strcmp(trueLabels{aa,1},'REM Sleep') == true
            allTrueAwake(aa,1) = 0;
            allTrueNREM(aa,1) = 0;
            allTrueREM(aa,1) = 1;
        end
    end
    % pupil mdl predictions
    allPupilPredAwake = strcmp(allPupilPred,'Not Sleep');
    allPupilPredNREM = strcmp(allPupilPred,'NREM Sleep');
    allPupilPredREM = strcmp(allPupilPred,'REM Sleep');
    % physio mdl predictions
    allPhysioPredAwake = strcmp(allPhysioPred,'Not Sleep');
    allPhysioPredNREM = strcmp(allPhysioPred,'NREM Sleep');
    allPhysioPredREM = strcmp(allPhysioPred,'REM Sleep');
    % combined mdl predictions
    allCombinedPredAwake = strcmp(allCombinedPred,'Not Sleep');
    allCombinedPredNREM = strcmp(allCombinedPred,'NREM Sleep');
    allCombinedPredREM = strcmp(allCombinedPred,'REM Sleep');
    if qq == 1
        % manual scores
        catTrueAwake = allTrueAwake;
        catTrueNREM = allTrueNREM;
        catTrueREM = allTrueREM;
        % pupil mdl scores
        catPupilAwake = allPupilPredAwake;
        catPupilNREM = allPupilPredNREM;
        catPupilREM = allPupilPredREM;
        % physio mdl scores
        catPhysioAwake = allPhysioPredAwake;
        catPhysioNREM = allPhysioPredNREM;
        catPhysioREM = allPhysioPredREM;
        % combined mdl scores
        catCombinedAwake = allCombinedPredAwake;
        catCombinedNREM = allCombinedPredNREM;
        catCombinedREM = allCombinedPredREM;
    else
        delayBins = Results_Example.timePadBins{qq - 1,1};
        timePadArray = NaN(length(delayBins),1);
        % manual scores
        catTrueAwake = cat(1,catTrueAwake,timePadArray,allTrueAwake);
        catTrueNREM = cat(1,catTrueNREM,timePadArray,allTrueNREM);
        catTrueREM = cat(1,catTrueREM,timePadArray,allTrueREM);
        % pupil mdl scores
        catPupilAwake = cat(1,catPupilAwake,timePadArray,allPupilPredAwake);
        catPupilNREM = cat(1,catPupilNREM,timePadArray,allPupilPredNREM);
        catPupilREM = cat(1,catPupilREM,timePadArray,allPupilPredREM);
        % physio mdl scores
        catPhysioAwake = cat(1,catPhysioAwake,timePadArray,allPhysioPredAwake);
        catPhysioNREM = cat(1,catPhysioNREM,timePadArray,allPhysioPredNREM);
        catPhysioREM = cat(1,catPhysioREM,timePadArray,allPhysioPredREM);
        % combined scores
        catCombinedAwake = cat(1,catCombinedAwake,timePadArray,allCombinedPredAwake);
        catCombinedNREM = cat(1,catCombinedNREM,timePadArray,allCombinedPredNREM);
        catCombinedREM = cat(1,catCombinedREM,timePadArray,allCombinedPredREM);
    end
end
%% sleep model accuracy using RF and out of bag error
resultsStruct = 'Results_PupilSleepModel.mat';
load(resultsStruct);
data.pupil.holdXlabels = []; data.pupil.holdYlabels = []; data.pupil.loss = [];
resultsStruct = 'Results_PhysioSleepModel.mat';
load(resultsStruct);
data.physio.holdXlabels = []; data.physio.holdYlabels = []; data.physio.loss = [];
resultsStruct = 'Results_CombinedSleepModel.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_PupilSleepModel);
data.combined.holdXlabels = []; data.combined.holdYlabels = []; data.combined.loss = [];
% extract data from summary structures
for dd = 1:length(animalIDs)
    animalID = animalIDs{dd,1};
    % pupil MDL
    data.pupil.holdXlabels = cat(1,data.pupil.holdXlabels,Results_PupilSleepModel.(animalID).pupil.predictedTestingLabels);
    data.pupil.holdYlabels = cat(1,data.pupil.holdYlabels,Results_PupilSleepModel.(animalID).pupil.trueTestingLabels);
    data.pupil.loss = cat(1,data.pupil.loss,Results_PupilSleepModel.(animalID).pupil.outOfBagError);
    % physio MDL
    data.physio.holdXlabels = cat(1,data.physio.holdXlabels,Results_PhysioSleepModel.(animalID).physio.predictedTestingLabels);
    data.physio.holdYlabels = cat(1,data.physio.holdYlabels,Results_PhysioSleepModel.(animalID).physio.trueTestingLabels);
    data.physio.loss = cat(1,data.physio.loss,Results_PhysioSleepModel.(animalID).physio.outOfBagError);
    % combined MDL
    data.combined.holdXlabels = cat(1,data.combined.holdXlabels,Results_CombinedSleepModel.(animalID).combined.predictedTestingLabels);
    data.combined.holdYlabels = cat(1,data.combined.holdYlabels,Results_CombinedSleepModel.(animalID).combined.trueTestingLabels);
    data.combined.loss = cat(1,data.combined.loss,Results_CombinedSleepModel.(animalID).combined.outOfBagError);
end
data.pupil.meanLoss = mean(data.pupil.loss,1);
data.pupil.stdLoss = std(data.pupil.loss,0,1);
data.physio.meanLoss = mean(data.physio.loss,1);
data.physio.stdLoss = std(data.physio.loss,0,1);
data.combined.meanLoss = mean(data.combined.loss,1);
data.combined.stdLoss = std(data.combined.loss,0,1);
% stats
[PupilPhysioStats.h,PupilPhysioStats.p,PupilPhysioStats.ci,PupilPhysioStats.stats] = ttest(data.pupil.loss,data.physio.loss);
[PupilCombinedStats.h,PupilCombinedStats.p,PupilCombinedStats.ci,PupilCombinedStats.stats] = ttest(data.pupil.loss,data.combined.loss);
[PhysioCombinedStats.h,PhysioCombinedStats.p,PhysioCombinedStats.ci,PhysioCombinedStats.stats] = ttest(data.physio.loss,data.combined.loss);
% bonferroni correction
comparisons = 3;
alpha1 = 0.05/comparisons;
alpha2 = 0.01/comparisons;
alpha3 = 0.001/comparisons;
%% Figure panel 7
Fig7C = figure('Name','Figure Panel 7 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
% sleep model confusion matrix
subplot(1,4,1)
cm = confusionchart(data.pupil.holdYlabels,data.pupil.holdXlabels);
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
confVals = cm.NormalizedValues;
totalScores = sum(confVals(:));
modelAccuracy = round((sum(confVals([1,5,9])/totalScores))*100,1);
cm.Title = {'Pupil MDL',['total accuracy: ' num2str(modelAccuracy) ' (%)']};
% sleep model confusion matrix
subplot(1,4,2)
cm = confusionchart(data.physio.holdYlabels,data.physio.holdXlabels);
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
confVals = cm.NormalizedValues;
totalScores = sum(confVals(:));
modelAccuracy = round((sum(confVals([1,5,9])/totalScores))*100,1);
cm.Title = {'Physio MDL',['total accuracy: ' num2str(modelAccuracy) ' (%)']};
% sleep model confusion matrix
subplot(1,4,3)
cm = confusionchart(data.combined.holdYlabels,data.combined.holdXlabels);
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
confVals = cm.NormalizedValues;
totalScores = sum(confVals(:));
modelAccuracy = round((sum(confVals([1,5,9])/totalScores))*100,1);
cm.Title = {'Combined MDL',['total accuracy: ' num2str(modelAccuracy) ' (%)']};
% sleep model 10-fold loss
subplot(1,4,4);
s1 = scatter(ones(1,length(data.pupil.loss))*1,data.pupil.loss,75,'MarkerEdgeColor',colors('black'),'MarkerFaceColor',colors('sapphire'),'jitter','on','jitterAmount',0);
hold on
e1 = errorbar(1,data.pupil.meanLoss,data.pupil.stdLoss,'d','MarkerEdgeColor',colors('black'),'MarkerFaceColor',colors('black'));
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
s2 = scatter(ones(1,length(data.physio.loss))*2,data.physio.loss,75,'MarkerEdgeColor',colors('black'),'MarkerFaceColor',colors('custom green'),'jitter','on','jitterAmount',0);
hold on
e2 = errorbar(2,data.physio.meanLoss,data.physio.stdLoss,'d','MarkerEdgeColor',colors('black'),'MarkerFaceColor',colors('black'));
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
s3 = scatter(ones(1,length(data.combined.loss))*3,data.combined.loss,75,'MarkerEdgeColor',colors('black'),'MarkerFaceColor',colors('royal purple'),'jitter','on','jitterAmount',0);
hold on
e3 = errorbar(3,data.combined.meanLoss,data.combined.stdLoss,'d','MarkerEdgeColor',colors('black'),'MarkerFaceColor',colors('black'));
e3.Color = 'black';
e3.MarkerSize = 10;
e3.CapSize = 10;
ylabel('Out of bag error')
legend([s1,s2,s3],'Pupil mdl','Physio mdl','Combined mdl','Location','NorthWest')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,4])
set(gca,'box','off')
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'MATLAB Figures' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig7C,[dirpath 'Fig7C_JNeurosci2022']);
    set(Fig7C,'PaperPositionMode','auto');
    print('-vector','-dpdf','-fillpage',[dirpath 'Fig7C_JNeurosci2022'])
end
%% example trial
Fig7B =  figure('Name','Figure Panel 7 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
sgtitle('Example Trial')
% pupil zDiameter
subplot(3,1,1);
plot((1:length(Results_Example.filtPupilDiameter))/Results_Example.dsFs,Results_Example.filtPupilDiameter,'color',colors('black'));
ylabel('Diameter (z-units)')
set(gca,'Xticklabel',[])
set(gca,'box','off')
xticks([0,60,120,180,240,300,360,420,480,540,600,660,720,780,840,900])
% eye motion
subplot(3,1,2);
p1 = plot((1:length(Results_Example.filtCentroidX))/Results_Example.dsFs,Results_Example.filtCentroidX - mean(Results_Example.filtCentroidX(200*Results_Example.dsFs:250*Results_Example.dsFs)),'color',colors('custom green'));
hold on
p2 = plot((1:length(Results_Example.filtCentroidY))/Results_Example.dsFs,Results_Example.filtCentroidY - mean(Results_Example.filtCentroidY(200*Results_Example.dsFs:250*Results_Example.dsFs)),'color',colors('cocoa brown'));
ylabel('Position (mm)')
legend([p1,p2],'Temporal-Nasal','Dorsal-Ventral')
set(gca,'Xticklabel',[])
set(gca,'box','off')
xticks([0,60,120,180,240,300,360,420,480,540,600,660,720,780,840,900])
% eye location
subplot(3,1,3);
plot((1:length(Results_Example.filtEyeMotion))/Results_Example.dsFs,Results_Example.filtEyeMotion,'color',colors('black'));
ylabel('|\DeltaPosition| (mm)')
set(gca,'Xticklabel',[])
set(gca,'box','off')
xticks([0,60,120,180,240,300,360,420,480,540,600,660,720,780,840,900])
legend([p1,p2],'medial-lateral','ventral-dorsal')
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'MATLAB Figures' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig7B,[dirpath 'Fig7B_JNeurosci2022']);
    set(Fig7B,'PaperPositionMode','auto');
    print('-vector','-dpdf','-fillpage',[dirpath 'Fig7B_JNeurosci2022'])
end
%% hypnogram for model comparison
Fig7A = figure('Name','Figure Panel 7 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
subplot(4,1,1)
b1 = bar((1:length(trueAwake))*binTime,trueAwake,'FaceColor',colors('black'),'BarWidth',1);
hold on
b2 = bar((1:length(trueNREM))*binTime,trueNREM,'FaceColor',colors('cyan'),'BarWidth',1);
b3 = bar((1:length(trueREM))*binTime,trueREM,'FaceColor',colors('candy apple red'),'BarWidth',1);
title('Manually scored predictions');
legend([b1,b2,b3],'Awake','NREM','REM')
xlim([0,900])
set(gca,'box','off')
axis off
subplot(4,1,2)
bar((1:length(pupilPredAwake))*binTime,pupilPredAwake,'FaceColor',colors('black'),'BarWidth',1);
hold on
bar((1:length(pupilPredNREM))*binTime,pupilPredNREM,'FaceColor',colors('cyan'),'BarWidth',1);
bar((1:length(pupilPredREM))*binTime,pupilPredREM,'FaceColor',colors('candy apple red'),'BarWidth',1);
title('Pupil model predictions');
xlim([0,900])
set(gca,'box','off')
axis off
subplot(4,1,3)
bar((1:length(physioPredAwake))*binTime,physioPredAwake,'FaceColor',colors('black'),'BarWidth',1);
hold on
bar((1:length(physioPredNREM))*binTime,physioPredNREM,'FaceColor',colors('cyan'),'BarWidth',1);
bar((1:length(physioPredREM))*binTime,physioPredREM,'FaceColor',colors('candy apple red'),'BarWidth',1);
title('physio model predictions');
xlim([0,900])
set(gca,'box','off')
axis off
subplot(4,1,4)
bar((1:length(combinedPredAwake))*binTime,combinedPredAwake,'FaceColor',colors('black'),'BarWidth',1);
hold on
bar((1:length(combinedPredNREM))*binTime,combinedPredNREM,'FaceColor',colors('cyan'),'BarWidth',1);
bar((1:length(combinedPredREM))*binTime,combinedPredREM,'FaceColor',colors('candy apple red'),'BarWidth',1);
title('combined model predictions');
xlim([0,900])
set(gca,'box','off')
axis off
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'MATLAB Figures' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig7A,[dirpath 'Fig7A_JNeurosci2022']);
    set(Fig7A,'PaperPositionMode','auto');
    print('-vector','-dpdf','-fillpage',[dirpath 'Fig7A_JNeurosci2022'])
    % text diary
    diaryFile = [dirpath 'Fig7_Text.txt'];
    if exist(diaryFile,'file') == 2
        delete(diaryFile)
    end
    diary(diaryFile)
    diary on
    % example boundary decision
    % Pupil model loss
    disp('======================================================================================================================')
    disp('Pupil model out-of-bag error')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Pupil model out-of-bag error: ' num2str(data.pupil.meanLoss) ' ± ' num2str(data.pupil.stdLoss) ' (n = ' num2str(length(data.pupil.loss)) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    % Physio model loss
    disp('======================================================================================================================')
    disp('Physiol model out-of-bag error')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Physio model out-of-bag error: ' num2str(data.physio.meanLoss) ' ± ' num2str(data.physio.stdLoss) ' (n = ' num2str(length(data.physio.loss)) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    % Pupil model loss
    disp('======================================================================================================================')
    disp('Combined model out-of-bag error')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Combined model out-of-bag error: ' num2str(data.combined.meanLoss) ' ± ' num2str(data.combined.stdLoss) ' (n = ' num2str(length(data.combined.loss)) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp('======================================================================================================================')
    disp('Stats')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Pupil vs. Physio: p < ' num2str(PupilPhysioStats.p)]); disp(' ')
    disp(['Pupil vs. Combined: p < ' num2str(PupilCombinedStats.p)]); disp(' ')
    disp(['Physio vs. Combined: p < ' num2str(PhysioCombinedStats.p)]); disp(' ')
    disp(['Bonferroni corrected significance levels (3 comparisons): *p < ' num2str(alpha1) ' **p < ' num2str(alpha2) ' ***p < ' num2str(alpha3)])
    disp('----------------------------------------------------------------------------------------------------------------------')
    diary off
end
cd(rootFolder)
end
