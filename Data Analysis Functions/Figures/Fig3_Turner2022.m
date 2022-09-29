function [] = Fig3_Turner2022(rootFolder,saveFigs,delim)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Generate figures and supporting information for Figure Panel 3
%________________________________________________________________________________________________________________________

dataLocation = [rootFolder delim 'Analysis Structures'];
cd(dataLocation)
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
    dirpath = [rootFolder delim 'MATLAB Figures' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    %% axis for composite images
    Fig3A = figure('Name','Figure Panel 3 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
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
    set(Fig3A,'PaperPositionMode','auto');
    savefig(Fig3A,[dirpath 'Fig3A_Turner2022']);
    print('-vector','-dpdf','-fillpage',[dirpath 'Fig3A_Turner2022'])
    close(Fig3A)
    imwrite(h1Img,[dirpath 'Fig3_HbTAwake_Turner2022.png'])
    imwrite(h2Img,[dirpath 'Fig3_HbTNREM_Turner2022.png'])
    imwrite(h3Img,[dirpath 'Fig3_HbTREM_Turner2022.png'])
    imwrite(h4Img,[dirpath 'Fig3_GammaAwake_Turner2022.png'])
    imwrite(h5Img,[dirpath 'Fig3_GammaNREM_Turner2022.png'])
    imwrite(h6Img,[dirpath 'Fig3_GammaREM_Turner2022.png'])
end
%% pupil HbT/gamma-band coherence
resultsStruct = 'Results_Coherence.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_Coherence);
behavFields = {'Rest','NREM','REM','Alert','Asleep','All'};
dataTypes = {'zDiameter'};
% pre-allocate data structure
for aa = 1:length(behavFields)
    behavField = behavFields{1,aa};
    for bb = 1:length(dataTypes)
        dataType = dataTypes{1,bb};
        data.Coherr.(behavField).(dataType).HbTC = [];
        data.Coherr.(behavField).(dataType).HbTf = [];
        data.Coherr.(behavField).(dataType).gammaC = [];
        data.Coherr.(behavField).(dataType).gammaf = [];
        data.Coherr.(behavField).(dataType).animalID = {};
        data.Coherr.(behavField).(dataType).behavField = {};
        data.Coherr.(behavField).(dataType).hemisphere = {};
    end
end
% concatenate coherence during different arousal states for each animal
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    for bb = 1:length(behavFields)
        behavField = behavFields{1,bb};
        for cc = 1:length(dataTypes)
            dataType = dataTypes{1,cc};
            % don't concatenate empty arrays where there was no data for this behavior
            if isempty(Results_Coherence.(animalID).(behavField).(dataType).LH_HbT.C) == false
                data.Coherr.(behavField).(dataType).HbTC = cat(2,data.Coherr.(behavField).(dataType).HbTC,Results_Coherence.(animalID).(behavField).(dataType).LH_HbT.C,Results_Coherence.(animalID).(behavField).(dataType).RH_HbT.C);
                data.Coherr.(behavField).(dataType).HbTf = cat(1,data.Coherr.(behavField).(dataType).HbTf,Results_Coherence.(animalID).(behavField).(dataType).LH_HbT.f,Results_Coherence.(animalID).(behavField).(dataType).RH_HbT.f);
                data.Coherr.(behavField).(dataType).gammaC = cat(2,data.Coherr.(behavField).(dataType).gammaC,Results_Coherence.(animalID).(behavField).(dataType).LH_gammaBandPower.C,Results_Coherence.(animalID).(behavField).(dataType).RH_gammaBandPower.C);
                data.Coherr.(behavField).(dataType).gammaf = cat(1,data.Coherr.(behavField).(dataType).gammaf,Results_Coherence.(animalID).(behavField).(dataType).LH_gammaBandPower.f,Results_Coherence.(animalID).(behavField).(dataType).RH_gammaBandPower.f);
                data.Coherr.(behavField).(dataType).animalID = cat(1,data.Coherr.(behavField).(dataType).animalID,animalID,animalID);
                data.Coherr.(behavField).(dataType).behavField = cat(1,data.Coherr.(behavField).(dataType).behavField,behavField,behavField);
                data.Coherr.(behavField).(dataType).hemisphere = cat(1,data.Coherr.(behavField).(dataType).hemisphere,'LH','RH');
            end
        end
    end
end
% mean and standard error for arousal state coherence
for aa = 1:length(behavFields)
    behavField = behavFields{1,aa};
    for bb = 1:length(dataTypes)
        dataType = dataTypes{1,bb};
        % HbT
        data.Coherr.(behavField).(dataType).meanHbTC = mean(data.Coherr.(behavField).(dataType).HbTC,2);
        data.Coherr.(behavField).(dataType).semHbTC = std(data.Coherr.(behavField).(dataType).HbTC,0,2)./sqrt(size(data.Coherr.(behavField).(dataType).HbTC,2));
        data.Coherr.(behavField).(dataType).meanHbTf = mean(data.Coherr.(behavField).(dataType).HbTf,1);
        % gamma-band
        data.Coherr.(behavField).(dataType).meanGammaC = mean(data.Coherr.(behavField).(dataType).gammaC,2);
        data.Coherr.(behavField).(dataType).semGammaC = std(data.Coherr.(behavField).(dataType).gammaC,0,2)./sqrt(size(data.Coherr.(behavField).(dataType).gammaC,2));
        data.Coherr.(behavField).(dataType).meanGammaf = mean(data.Coherr.(behavField).(dataType).gammaf,1);
    end
end
% find 0.02 Hz peak in coherence
for ee = 1:length(behavFields)
    behavField = behavFields{1,ee};
    for ff = 1:length(dataTypes)
        dataType = dataTypes{1,ff};
        for gg = 1:size(data.Coherr.(behavField).(dataType).HbTC,2)
            if strcmp(behavField,'Rest') == true
                f_short = data.Coherr.(behavField).(dataType).HbTf(gg,:);
                HbTC = data.Coherr.(behavField).(dataType).HbTC(:,gg);
                gammaC = data.Coherr.(behavField).(dataType).gammaC(:,gg);
                f_long = 0:0.01:0.5;
                HbTC_long = interp1(f_short,HbTC,f_long);
                gammaC_long = interp1(f_short,gammaC,f_long);
                index03 = find(f_long == 0.35);
                data.Coherr.(behavField).(dataType).HbTC035(gg,1) = HbTC_long(index03);
                data.Coherr.(behavField).(dataType).gammaC035(gg,1) = gammaC_long(index03);
            elseif strcmp(behavField,'NREM') == true || strcmp(behavField,'REM') == true
                F = round(data.Coherr.(behavField).(dataType).HbTf(gg,:),2);
                HbTC = data.Coherr.(behavField).(dataType).HbTC(:,gg);
                gammaC = data.Coherr.(behavField).(dataType).gammaC(:,gg);
                index03 = find(F == 0.35);
                data.Coherr.(behavField).(dataType).HbTC035(gg,1) = HbTC(index03(1));
                data.Coherr.(behavField).(dataType).gammaC035(gg,1) = gammaC(index03(1));
            else
                F = round(data.Coherr.(behavField).(dataType).HbTf(gg,:),3);
                HbTC = data.Coherr.(behavField).(dataType).HbTC(:,gg);
                gammaC = data.Coherr.(behavField).(dataType).gammaC(:,gg);
                index03 = find(F == 0.35);
                index002 = find(F == 0.02);
                data.Coherr.(behavField).(dataType).HbTC035(gg,1) = HbTC(index03(1));
                data.Coherr.(behavField).(dataType).HbTC002(gg,1) = HbTC(index002(1));
                data.Coherr.(behavField).(dataType).gammaC035(gg,1) = gammaC(index03(1));
                data.Coherr.(behavField).(dataType).gammaC002(gg,1) = gammaC(index002(1));
            end
        end
    end
end
% mean and standard deviation of peak coherence
for ee = 1:length(behavFields)
    behavField = behavFields{1,ee};
    for ff = 1:length(dataTypes)
        dataType = dataTypes{1,ff};
        if strcmp(behavField,'Rest') == true || strcmp(behavField,'NREM') == true || strcmp(behavField,'REM') == true
            data.Coherr.(behavField).(dataType).meanHbTC035 = mean(data.Coherr.(behavField).(dataType).HbTC035,1);
            data.Coherr.(behavField).(dataType).stdHbTC035 = std(data.Coherr.(behavField).(dataType).HbTC035,0,1);
            data.Coherr.(behavField).(dataType).meanGammaC035 = mean(data.Coherr.(behavField).(dataType).gammaC035,1);
            data.Coherr.(behavField).(dataType).stdGammaC035 = std(data.Coherr.(behavField).(dataType).gammaC035,0,1);
        else
            data.Coherr.(behavField).(dataType).meanHbTC035 = mean(data.Coherr.(behavField).(dataType).HbTC035,1);
            data.Coherr.(behavField).(dataType).stdHbTC035 = std(data.Coherr.(behavField).(dataType).HbTC035,0,1);
            data.Coherr.(behavField).(dataType).meanHbTC002 = mean(data.Coherr.(behavField).(dataType).HbTC002,1);
            data.Coherr.(behavField).(dataType).stdHbTC002 = std(data.Coherr.(behavField).(dataType).HbTC002,0,1);
            data.Coherr.(behavField).(dataType).meanGammaC035 = mean(data.Coherr.(behavField).(dataType).gammaC035,1);
            data.Coherr.(behavField).(dataType).stdGammaC035 = std(data.Coherr.(behavField).(dataType).gammaC035,0,1);
            data.Coherr.(behavField).(dataType).meanGammaC002 = mean(data.Coherr.(behavField).(dataType).gammaC002,1);
            data.Coherr.(behavField).(dataType).stdGammaC002 = std(data.Coherr.(behavField).(dataType).gammaC002,0,1);
        end
    end
end
%% statistics - generalized linear mixed effects model (0.02 HbT coherence)
HbTC002TableSize = cat(1,data.Coherr.Alert.zDiameter.HbTC002,data.Coherr.Asleep.zDiameter.HbTC002,data.Coherr.All.zDiameter.HbTC002);
HbTC002Table = table('Size',[size(HbTC002TableSize,1),4],'VariableTypes',{'string','string','string','double'},'VariableNames',{'Mouse','Behavior','Hemisphere','HbTC002'});
HbTC002Table.Mouse = cat(1,data.Coherr.Alert.zDiameter.animalID,data.Coherr.Asleep.zDiameter.animalID,data.Coherr.All.zDiameter.animalID);
HbTC002Table.Behavior = cat(1,data.Coherr.Alert.zDiameter.behavField,data.Coherr.Asleep.zDiameter.behavField,data.Coherr.All.zDiameter.behavField);
HbTC002Table.Hemisphere = cat(1,data.Coherr.Alert.zDiameter.hemisphere,data.Coherr.Asleep.zDiameter.hemisphere,data.Coherr.All.zDiameter.hemisphere);
HbTC002Table.HbTC002 = cat(1,data.Coherr.Alert.zDiameter.HbTC002,data.Coherr.Asleep.zDiameter.HbTC002,data.Coherr.All.zDiameter.HbTC002);
HbTC002FitFormula = 'HbTC002 ~ 1 + Behavior + (1|Mouse) + (1|Mouse:Hemisphere)';
HbTC002Stats = fitglme(HbTC002Table,HbTC002FitFormula);

[HbTC002_pVal11,~,~,~] = coefTest(HbTC002Stats,[ 1  0  0 ]);
[HbTC002_pVal12,~,~,~] = coefTest(HbTC002Stats,[ 1 -1  0 ]);
[HbTC002_pVal13,~,~,~] = coefTest(HbTC002Stats,[ 1  0 -1 ]);

[HbTC002_pVal21,~,~,~] = coefTest(HbTC002Stats,[-1  1  0 ]);
[HbTC002_pVal22,~,~,~] = coefTest(HbTC002Stats,[ 0  1  0 ]);
[HbTC002_pVal23,~,~,~] = coefTest(HbTC002Stats,[ 0  1 -1 ]);

[HbTC002_pVal31,~,~,~] = coefTest(HbTC002Stats,[-1  0  1 ]);
[HbTC002_pVal32,~,~,~] = coefTest(HbTC002Stats,[ 0 -1  1 ]);
[HbTC002_pVal33,~,~,~] = coefTest(HbTC002Stats,[ 0  0  1 ]);

HbTC002X = [HbTC002_pVal11,HbTC002_pVal12,HbTC002_pVal13;...
    HbTC002_pVal21,HbTC002_pVal22,HbTC002_pVal23;...
    HbTC002_pVal31,HbTC002_pVal32,HbTC002_pVal33];

state = {'Alert';'Asleep';'All'};
HbTC002StatsTable = table(array2table(HbTC002X,'VariableNames',{'Alert';'Asleep';'All'}),'RowNames',state);
%% statistics - generalized linear mixed effects model (0.02 gamma coherence)
gammaC002TableSize = cat(1,data.Coherr.Alert.zDiameter.gammaC002,data.Coherr.Asleep.zDiameter.gammaC002,data.Coherr.All.zDiameter.gammaC002);
gammaC002Table = table('Size',[size(gammaC002TableSize,1),4],'VariableTypes',{'string','string','string','double'},'VariableNames',{'Mouse','Behavior','Hemisphere','gammaC002'});
gammaC002Table.Mouse = cat(1,data.Coherr.Alert.zDiameter.animalID,data.Coherr.Asleep.zDiameter.animalID,data.Coherr.All.zDiameter.animalID);
gammaC002Table.Behavior = cat(1,data.Coherr.Alert.zDiameter.behavField,data.Coherr.Asleep.zDiameter.behavField,data.Coherr.All.zDiameter.behavField);
gammaC002Table.Hemisphere = cat(1,data.Coherr.Alert.zDiameter.hemisphere,data.Coherr.Asleep.zDiameter.hemisphere,data.Coherr.All.zDiameter.hemisphere);
gammaC002Table.gammaC002 = cat(1,data.Coherr.Alert.zDiameter.gammaC002,data.Coherr.Asleep.zDiameter.gammaC002,data.Coherr.All.zDiameter.gammaC002);
gammaC002FitFormula = 'gammaC002 ~ 1 + Behavior + (1|Mouse) + (1|Mouse:Hemisphere)';
gammaC002Stats = fitglme(gammaC002Table,gammaC002FitFormula);

[gammaC002_pVal11,~,~,~] = coefTest(gammaC002Stats,[ 1  0  0 ]);
[gammaC002_pVal12,~,~,~] = coefTest(gammaC002Stats,[ 1 -1  0 ]);
[gammaC002_pVal13,~,~,~] = coefTest(gammaC002Stats,[ 1  0 -1 ]);

[gammaC002_pVal21,~,~,~] = coefTest(gammaC002Stats,[-1  1  0 ]);
[gammaC002_pVal22,~,~,~] = coefTest(gammaC002Stats,[ 0  1  0 ]);
[gammaC002_pVal23,~,~,~] = coefTest(gammaC002Stats,[ 0  1 -1 ]);

[gammaC002_pVal31,~,~,~] = coefTest(gammaC002Stats,[-1  0  1 ]);
[gammaC002_pVal32,~,~,~] = coefTest(gammaC002Stats,[ 0 -1  1 ]);
[gammaC002_pVal33,~,~,~] = coefTest(gammaC002Stats,[ 0  0  1 ]);

gammaC002X = [gammaC002_pVal11,gammaC002_pVal12,gammaC002_pVal13;...
    gammaC002_pVal21,gammaC002_pVal22,gammaC002_pVal23;...
    gammaC002_pVal31,gammaC002_pVal32,gammaC002_pVal33];

state = {'Alert';'Asleep';'All'};
gammaC002StatsTable = table(array2table(gammaC002X,'VariableNames',{'Alert';'Asleep';'All'}),'RowNames',state);
%% statistics - generalized linear mixed effects model (0.35 HbT coherence)
HbTC035TableSize = cat(1,data.Coherr.Rest.zDiameter.HbTC035,data.Coherr.NREM.zDiameter.HbTC035,data.Coherr.REM.zDiameter.HbTC035,data.Coherr.Alert.zDiameter.HbTC035,data.Coherr.Asleep.zDiameter.HbTC035,data.Coherr.All.zDiameter.HbTC035);
HbTC035Table = table('Size',[size(HbTC035TableSize,1),4],'VariableTypes',{'string','string','string','double'},'VariableNames',{'Mouse','Behavior','Hemisphere','HbTC035'});
HbTC035Table.Mouse = cat(1,data.Coherr.Rest.zDiameter.animalID,data.Coherr.NREM.zDiameter.animalID,data.Coherr.REM.zDiameter.animalID,data.Coherr.Alert.zDiameter.animalID,data.Coherr.Asleep.zDiameter.animalID,data.Coherr.All.zDiameter.animalID);
HbTC035Table.Behavior = cat(1,data.Coherr.Rest.zDiameter.behavField,data.Coherr.NREM.zDiameter.behavField,data.Coherr.REM.zDiameter.behavField,data.Coherr.Alert.zDiameter.behavField,data.Coherr.Asleep.zDiameter.behavField,data.Coherr.All.zDiameter.behavField);
HbTC035Table.Hemisphere = cat(1,data.Coherr.Rest.zDiameter.behavField,data.Coherr.NREM.zDiameter.behavField,data.Coherr.REM.zDiameter.behavField,data.Coherr.Alert.zDiameter.hemisphere,data.Coherr.Asleep.zDiameter.hemisphere,data.Coherr.All.zDiameter.hemisphere);
HbTC035Table.HbTC035 = cat(1,data.Coherr.Rest.zDiameter.HbTC035,data.Coherr.NREM.zDiameter.HbTC035,data.Coherr.REM.zDiameter.HbTC035,data.Coherr.Alert.zDiameter.HbTC035,data.Coherr.Asleep.zDiameter.HbTC035,data.Coherr.All.zDiameter.HbTC035);
HbTC035FitFormula = 'HbTC035 ~ 1 + Behavior + (1|Mouse) + (1|Mouse:Hemisphere)';
HbTC035Stats = fitglme(HbTC035Table,HbTC035FitFormula);

[HbTC035_pVal11,~,~,~] = coefTest(HbTC035Stats,[ 1  0  0  0  0  0 ]);
[HbTC035_pVal12,~,~,~] = coefTest(HbTC035Stats,[ 1 -1  0  0  0  0 ]);
[HbTC035_pVal13,~,~,~] = coefTest(HbTC035Stats,[ 1  0 -1  0  0  0 ]);
[HbTC035_pVal14,~,~,~] = coefTest(HbTC035Stats,[ 1  0  0 -1  0  0 ]);
[HbTC035_pVal15,~,~,~] = coefTest(HbTC035Stats,[ 1  0  0  0 -1  0 ]);
[HbTC035_pVal16,~,~,~] = coefTest(HbTC035Stats,[ 1  0  0  0  0 -1 ]);

[HbTC035_pVal21,~,~,~] = coefTest(HbTC035Stats,[-1  1  0  0  0  0 ]);
[HbTC035_pVal22,~,~,~] = coefTest(HbTC035Stats,[ 0  1  0  0  0  0 ]);
[HbTC035_pVal23,~,~,~] = coefTest(HbTC035Stats,[ 0  1 -1  0  0  0 ]);
[HbTC035_pVal24,~,~,~] = coefTest(HbTC035Stats,[ 0  1  0 -1  0  0 ]);
[HbTC035_pVal25,~,~,~] = coefTest(HbTC035Stats,[ 0  1  0  0 -1  0 ]);
[HbTC035_pVal26,~,~,~] = coefTest(HbTC035Stats,[ 0  1  0  0  0 -1 ]);

[HbTC035_pVal31,~,~,~] = coefTest(HbTC035Stats,[-1  0  1  0  0  0 ]);
[HbTC035_pVal32,~,~,~] = coefTest(HbTC035Stats,[ 0 -1  1  0  0  0 ]);
[HbTC035_pVal33,~,~,~] = coefTest(HbTC035Stats,[ 0  0  1  0  0  0 ]);
[HbTC035_pVal34,~,~,~] = coefTest(HbTC035Stats,[ 0  0  1 -1  0  0 ]);
[HbTC035_pVal35,~,~,~] = coefTest(HbTC035Stats,[ 0  0  1  0 -1  0 ]);
[HbTC035_pVal36,~,~,~] = coefTest(HbTC035Stats,[ 0  0  1  0  0 -1 ]);

[HbTC035_pVal41,~,~,~] = coefTest(HbTC035Stats,[-1  0  0  1  0  0 ]);
[HbTC035_pVal42,~,~,~] = coefTest(HbTC035Stats,[ 0 -1  0  1  0  0 ]);
[HbTC035_pVal43,~,~,~] = coefTest(HbTC035Stats,[ 0  0 -1  1  0  0 ]);
[HbTC035_pVal44,~,~,~] = coefTest(HbTC035Stats,[ 0  0  0  1  0  0 ]);
[HbTC035_pVal45,~,~,~] = coefTest(HbTC035Stats,[ 0  0  0  1 -1  0 ]);
[HbTC035_pVal46,~,~,~] = coefTest(HbTC035Stats,[ 0  0  0  1  0 -1 ]);

[HbTC035_pVal51,~,~,~] = coefTest(HbTC035Stats,[-1  0  0  0  1  0 ]);
[HbTC035_pVal52,~,~,~] = coefTest(HbTC035Stats,[ 0 -1  0  0  1  0 ]);
[HbTC035_pVal53,~,~,~] = coefTest(HbTC035Stats,[ 0  0 -1  0  1  0 ]);
[HbTC035_pVal54,~,~,~] = coefTest(HbTC035Stats,[ 0  0  0 -1  1  0 ]);
[HbTC035_pVal55,~,~,~] = coefTest(HbTC035Stats,[ 0  0  0  0  1  0 ]);
[HbTC035_pVal56,~,~,~] = coefTest(HbTC035Stats,[ 0  0  0  0  1 -1 ]);

[HbTC035_pVal61,~,~,~] = coefTest(HbTC035Stats,[-1  0  0  0  0  1 ]);
[HbTC035_pVal62,~,~,~] = coefTest(HbTC035Stats,[ 0 -1  0  0  0  1 ]);
[HbTC035_pVal63,~,~,~] = coefTest(HbTC035Stats,[ 0  0 -1  0  0  1 ]);
[HbTC035_pVal64,~,~,~] = coefTest(HbTC035Stats,[ 0  0  0 -1  0  1 ]);
[HbTC035_pVal65,~,~,~] = coefTest(HbTC035Stats,[ 0  0  0  0 -1  1 ]);
[HbTC035_pVal66,~,~,~] = coefTest(HbTC035Stats,[ 0  0  0  0  0  1 ]);

HbTC035X = [HbTC035_pVal11,HbTC035_pVal12,HbTC035_pVal13,HbTC035_pVal14,HbTC035_pVal15,HbTC035_pVal16;...
    HbTC035_pVal21,HbTC035_pVal22,HbTC035_pVal23,HbTC035_pVal24,HbTC035_pVal25,HbTC035_pVal26;...
    HbTC035_pVal31,HbTC035_pVal32,HbTC035_pVal33,HbTC035_pVal34,HbTC035_pVal35,HbTC035_pVal36;...
    HbTC035_pVal41,HbTC035_pVal42,HbTC035_pVal43,HbTC035_pVal44,HbTC035_pVal45,HbTC035_pVal46;...
    HbTC035_pVal51,HbTC035_pVal52,HbTC035_pVal53,HbTC035_pVal54,HbTC035_pVal55,HbTC035_pVal56;...
    HbTC035_pVal61,HbTC035_pVal62,HbTC035_pVal63,HbTC035_pVal64,HbTC035_pVal65,HbTC035_pVal66];

state = {'Rest';'NREM';'REM';'Alert';'Asleep';'All'};
HbTC035StatsTable = table(array2table(HbTC035X,'VariableNames',{'Rest';'NREM';'REM';'Alert';'Asleep';'All'}),'RowNames',state);
%% statistics - generalized linear mixed effects model (0.02 HbT coherence)
gammaC035TableSize = cat(1,data.Coherr.Rest.zDiameter.gammaC035,data.Coherr.NREM.zDiameter.gammaC035,data.Coherr.REM.zDiameter.gammaC035,data.Coherr.Alert.zDiameter.gammaC035,data.Coherr.Asleep.zDiameter.gammaC035,data.Coherr.All.zDiameter.gammaC035);
gammaC035Table = table('Size',[size(gammaC035TableSize,1),4],'VariableTypes',{'string','string','string','double'},'VariableNames',{'Mouse','Behavior','Hemisphere','gammaC035'});
gammaC035Table.Mouse = cat(1,data.Coherr.Rest.zDiameter.animalID,data.Coherr.NREM.zDiameter.animalID,data.Coherr.REM.zDiameter.animalID,data.Coherr.Alert.zDiameter.animalID,data.Coherr.Asleep.zDiameter.animalID,data.Coherr.All.zDiameter.animalID);
gammaC035Table.Behavior = cat(1,data.Coherr.Rest.zDiameter.behavField,data.Coherr.NREM.zDiameter.behavField,data.Coherr.REM.zDiameter.behavField,data.Coherr.Alert.zDiameter.behavField,data.Coherr.Asleep.zDiameter.behavField,data.Coherr.All.zDiameter.behavField);
gammaC035Table.Hemisphere = cat(1,data.Coherr.Rest.zDiameter.behavField,data.Coherr.NREM.zDiameter.behavField,data.Coherr.REM.zDiameter.behavField,data.Coherr.Alert.zDiameter.hemisphere,data.Coherr.Asleep.zDiameter.hemisphere,data.Coherr.All.zDiameter.hemisphere);
gammaC035Table.gammaC035 = cat(1,data.Coherr.Rest.zDiameter.gammaC035,data.Coherr.NREM.zDiameter.gammaC035,data.Coherr.REM.zDiameter.gammaC035,data.Coherr.Alert.zDiameter.gammaC035,data.Coherr.Asleep.zDiameter.gammaC035,data.Coherr.All.zDiameter.gammaC035);
gammaC035FitFormula = 'gammaC035 ~ 1 + Behavior + (1|Mouse) + (1|Mouse:Hemisphere)';
gammaC035Stats = fitglme(gammaC035Table,gammaC035FitFormula);

[gammaC035_pVal11,~,~,~] = coefTest(gammaC035Stats,[ 1  0  0  0  0  0 ]);
[gammaC035_pVal12,~,~,~] = coefTest(gammaC035Stats,[ 1 -1  0  0  0  0 ]);
[gammaC035_pVal13,~,~,~] = coefTest(gammaC035Stats,[ 1  0 -1  0  0  0 ]);
[gammaC035_pVal14,~,~,~] = coefTest(gammaC035Stats,[ 1  0  0 -1  0  0 ]);
[gammaC035_pVal15,~,~,~] = coefTest(gammaC035Stats,[ 1  0  0  0 -1  0 ]);
[gammaC035_pVal16,~,~,~] = coefTest(gammaC035Stats,[ 1  0  0  0  0 -1 ]);

[gammaC035_pVal21,~,~,~] = coefTest(gammaC035Stats,[-1  1  0  0  0  0 ]);
[gammaC035_pVal22,~,~,~] = coefTest(gammaC035Stats,[ 0  1  0  0  0  0 ]);
[gammaC035_pVal23,~,~,~] = coefTest(gammaC035Stats,[ 0  1 -1  0  0  0 ]);
[gammaC035_pVal24,~,~,~] = coefTest(gammaC035Stats,[ 0  1  0 -1  0  0 ]);
[gammaC035_pVal25,~,~,~] = coefTest(gammaC035Stats,[ 0  1  0  0 -1  0 ]);
[gammaC035_pVal26,~,~,~] = coefTest(gammaC035Stats,[ 0  1  0  0  0 -1 ]);

[gammaC035_pVal31,~,~,~] = coefTest(gammaC035Stats,[-1  0  1  0  0  0 ]);
[gammaC035_pVal32,~,~,~] = coefTest(gammaC035Stats,[ 0 -1  1  0  0  0 ]);
[gammaC035_pVal33,~,~,~] = coefTest(gammaC035Stats,[ 0  0  1  0  0  0 ]);
[gammaC035_pVal34,~,~,~] = coefTest(gammaC035Stats,[ 0  0  1 -1  0  0 ]);
[gammaC035_pVal35,~,~,~] = coefTest(gammaC035Stats,[ 0  0  1  0 -1  0 ]);
[gammaC035_pVal36,~,~,~] = coefTest(gammaC035Stats,[ 0  0  1  0  0 -1 ]);

[gammaC035_pVal41,~,~,~] = coefTest(gammaC035Stats,[-1  0  0  1  0  0 ]);
[gammaC035_pVal42,~,~,~] = coefTest(gammaC035Stats,[ 0 -1  0  1  0  0 ]);
[gammaC035_pVal43,~,~,~] = coefTest(gammaC035Stats,[ 0  0 -1  1  0  0 ]);
[gammaC035_pVal44,~,~,~] = coefTest(gammaC035Stats,[ 0  0  0  1  0  0 ]);
[gammaC035_pVal45,~,~,~] = coefTest(gammaC035Stats,[ 0  0  0  1 -1  0 ]);
[gammaC035_pVal46,~,~,~] = coefTest(gammaC035Stats,[ 0  0  0  1  0 -1 ]);

[gammaC035_pVal51,~,~,~] = coefTest(gammaC035Stats,[-1  0  0  0  1  0 ]);
[gammaC035_pVal52,~,~,~] = coefTest(gammaC035Stats,[ 0 -1  0  0  1  0 ]);
[gammaC035_pVal53,~,~,~] = coefTest(gammaC035Stats,[ 0  0 -1  0  1  0 ]);
[gammaC035_pVal54,~,~,~] = coefTest(gammaC035Stats,[ 0  0  0 -1  1  0 ]);
[gammaC035_pVal55,~,~,~] = coefTest(gammaC035Stats,[ 0  0  0  0  1  0 ]);
[gammaC035_pVal56,~,~,~] = coefTest(gammaC035Stats,[ 0  0  0  0  1 -1 ]);

[gammaC035_pVal61,~,~,~] = coefTest(gammaC035Stats,[-1  0  0  0  0  1 ]);
[gammaC035_pVal62,~,~,~] = coefTest(gammaC035Stats,[ 0 -1  0  0  0  1 ]);
[gammaC035_pVal63,~,~,~] = coefTest(gammaC035Stats,[ 0  0 -1  0  0  1 ]);
[gammaC035_pVal64,~,~,~] = coefTest(gammaC035Stats,[ 0  0  0 -1  0  1 ]);
[gammaC035_pVal65,~,~,~] = coefTest(gammaC035Stats,[ 0  0  0  0 -1  1 ]);
[gammaC035_pVal66,~,~,~] = coefTest(gammaC035Stats,[ 0  0  0  0  0  1 ]);

gammaC035X = [gammaC035_pVal11,gammaC035_pVal12,gammaC035_pVal13,gammaC035_pVal14,gammaC035_pVal15,gammaC035_pVal16;...
    gammaC035_pVal21,gammaC035_pVal22,gammaC035_pVal23,gammaC035_pVal24,gammaC035_pVal25,gammaC035_pVal26;...
    gammaC035_pVal31,gammaC035_pVal32,gammaC035_pVal33,gammaC035_pVal34,gammaC035_pVal35,gammaC035_pVal36;...
    gammaC035_pVal41,gammaC035_pVal42,gammaC035_pVal43,gammaC035_pVal44,gammaC035_pVal45,gammaC035_pVal46;...
    gammaC035_pVal51,gammaC035_pVal52,gammaC035_pVal53,gammaC035_pVal54,gammaC035_pVal55,gammaC035_pVal56;...
    gammaC035_pVal61,gammaC035_pVal62,gammaC035_pVal63,gammaC035_pVal64,gammaC035_pVal65,gammaC035_pVal66];

state = {'Rest';'NREM';'REM';'Alert';'Asleep';'All'};
gammaC035StatsTable = table(array2table(gammaC035X,'VariableNames',{'Rest';'NREM';'REM';'Alert';'Asleep';'All'}),'RowNames',state);
%% bonferroni adjusted alphas
comparisons = 3;
alpha3A = 0.05/comparisons;
alpha3B = 0.01/comparisons;
alpha3C = 0.001/comparisons;
comparisons = 15;
alpha15A = 0.05/comparisons;
alpha15B = 0.01/comparisons;
alpha15C = 0.001/comparisons;
%% pupil HbT/gamma cross correlation
resultsStruct = 'Results_CrossCorrelation.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_CrossCorrelation);
behavFields = {'Rest','NREM','REM','Alert','Asleep','All'};
dataTypes = {'zDiameter'};
% concatenate the cross-correlation during different arousal states for each animal
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    for bb = 1:length(behavFields)
        behavField = behavFields{1,bb};
        for cc = 1:length(dataTypes)
            dataType = dataTypes{1,cc};
            % pre-allocate necessary variable fields
            data.XCorr.(behavField).(dataType).dummCheck = 1;
            if isfield(data.XCorr.(behavField).(dataType),'LH_xcVals_HbT') == false
                % LH HbT
                data.XCorr.(behavField).(dataType).LH_xcVals_HbT = [];
                % RH HbT
                data.XCorr.(behavField).(dataType).RH_xcVals_HbT = [];
                % LH gamma
                data.XCorr.(behavField).(dataType).LH_xcVals_gamma = [];
                % RH gamma
                data.XCorr.(behavField).(dataType).RH_xcVals_gamma = [];
                % lags and stats fields
                data.XCorr.(behavField).(dataType).lags = [];
                data.XCorr.(behavField).(dataType).animalID = {};
                data.XCorr.(behavField).(dataType).behavField = {};
                data.XCorr.(behavField).(dataType).LH = {};
                data.XCorr.(behavField).(dataType).RH = {};
            end
            % concatenate cross correlation during each arousal state, find peak + lag time
            if isfield(Results_CrossCorrelation.(animalID),behavField) == true
                if isempty(Results_CrossCorrelation.(animalID).(behavField).LH_HbT.(dataType).xcVals) == false
                    % LH HbT peak + lag time
                    data.XCorr.(behavField).(dataType).LH_xcVals_HbT = cat(1,data.XCorr.(behavField).(dataType).LH_xcVals_HbT,Results_CrossCorrelation.(animalID).(behavField).LH_HbT.(dataType).xcVals);
                    % RH HbT peak + lag time
                    data.XCorr.(behavField).(dataType).RH_xcVals_HbT = cat(1,data.XCorr.(behavField).(dataType).RH_xcVals_HbT,Results_CrossCorrelation.(animalID).(behavField).RH_HbT.(dataType).xcVals);
                    % LH gamma peak + lag time
                    data.XCorr.(behavField).(dataType).LH_xcVals_gamma = cat(1,data.XCorr.(behavField).(dataType).LH_xcVals_gamma,Results_CrossCorrelation.(animalID).(behavField).LH_gammaBandPower.(dataType).xcVals);
                    % RH gamma peak + lag time
                    data.XCorr.(behavField).(dataType).RH_xcVals_gamma = cat(1,data.XCorr.(behavField).(dataType).RH_xcVals_gamma,Results_CrossCorrelation.(animalID).(behavField).RH_gammaBandPower.(dataType).xcVals);
                    % lags and stats fields
                    data.XCorr.(behavField).(dataType).lags = cat(1,data.XCorr.(behavField).(dataType).lags,Results_CrossCorrelation.(animalID).(behavField).LH_HbT.(dataType).lags,Results_CrossCorrelation.(animalID).(behavField).RH_HbT.(dataType).lags);
                    data.XCorr.(behavField).(dataType).animalID = cat(1,data.XCorr.(behavField).(dataType).animalID,animalID);
                    data.XCorr.(behavField).(dataType).behavField = cat(1,data.XCorr.(behavField).(dataType).behavField,behavField);
                    data.XCorr.(behavField).(dataType).LH = cat(1,data.XCorr.(behavField).(dataType).LH,'LH');
                    data.XCorr.(behavField).(dataType).RH = cat(1,data.XCorr.(behavField).(dataType).RH,'RH');
                end
            end
        end
    end
end
samplingRate = 30;
% mean and standard error/standard deviation of cross correlation values
for dd = 1:length(behavFields)
    behavField = behavFields{1,dd};
    for ff = 1:length(dataTypes)
        dataType = dataTypes{1,ff};
        % Lags time vector
        data.XCorr.(behavField).(dataType).meanLags = mean(data.XCorr.(behavField).(dataType).lags,1);
        % HbT XC mean/sem
        data.XCorr.(behavField).(dataType).xcVals_HbT = cat(1,data.XCorr.(behavField).(dataType).LH_xcVals_HbT,data.XCorr.(behavField).(dataType).RH_xcVals_HbT);
        data.XCorr.(behavField).(dataType).meanXcVals_HbT = mean(data.XCorr.(behavField).(dataType).xcVals_HbT,1);
        data.XCorr.(behavField).(dataType).stdXcVals_HbT = std(data.XCorr.(behavField).(dataType).xcVals_HbT,0,1);
        data.XCorr.(behavField).(dataType).semXcVals_HbT = std(data.XCorr.(behavField).(dataType).xcVals_HbT,0,1)./sqrt(size(data.XCorr.(behavField).(dataType).xcVals_HbT,1));
        % find peak lag time and value/std at that time
        [~,idx] = max(abs(data.XCorr.(behavField).(dataType).meanXcVals_HbT));
        data.XCorr.(behavField).(dataType).peakHbTVal = data.XCorr.(behavField).(dataType).meanXcVals_HbT(1,idx);
        data.XCorr.(behavField).(dataType).peakHbTStD = data.XCorr.(behavField).(dataType).stdXcVals_HbT(1,idx);
        data.XCorr.(behavField).(dataType).peakHbTLag = data.XCorr.(behavField).(dataType).meanLags(1,idx)/samplingRate;
        % Gamma XC mean/sem
        data.XCorr.(behavField).(dataType).xcVals_gamma = cat(1,data.XCorr.(behavField).(dataType).LH_xcVals_gamma,data.XCorr.(behavField).(dataType).RH_xcVals_gamma);
        data.XCorr.(behavField).(dataType).meanXcVals_gamma = mean(data.XCorr.(behavField).(dataType).xcVals_gamma,1);
        data.XCorr.(behavField).(dataType).stdXcVals_gamma = std(data.XCorr.(behavField).(dataType).xcVals_gamma,0,1);
        data.XCorr.(behavField).(dataType).semXcVals_gamma = std(data.XCorr.(behavField).(dataType).xcVals_gamma,0,1)./sqrt(size(data.XCorr.(behavField).(dataType).xcVals_gamma,1));
        % find peak lag time and value/std at that time
        [~,idx] = max(abs(data.XCorr.(behavField).(dataType).meanXcVals_gamma));
        data.XCorr.(behavField).(dataType).peakGammaVal = data.XCorr.(behavField).(dataType).meanXcVals_gamma(1,idx);
        data.XCorr.(behavField).(dataType).peakGammaStD = data.XCorr.(behavField).(dataType).stdXcVals_gamma(1,idx);
        data.XCorr.(behavField).(dataType).peakGammaLag = data.XCorr.(behavField).(dataType).meanLags(1,idx)/samplingRate;
    end
end
%% figures
Fig3 = figure('Name','Figure Panel 3 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
%% Gamma
subplot(4,3,1)
gammaPupilImg = imread('GammaPupilStack.png'); % needs made by combining images in ImageJ (Z project min)
imshow(gammaPupilImg)
axis off
title('Gamma-Pupil Relationship')
xlabel('Diameter (z-units)')
ylabel('\DeltaP/P (%)')
%% gamma-pupil cross correlation [rest, NREM, REM]
ax2 = subplot(4,3,2);
freq = 30;
lagSec = 5;
plot(data.XCorr.Rest.zDiameter.meanLags,data.XCorr.Rest.zDiameter.meanXcVals_gamma,'color',colors('custom rest'),'LineWidth',2);
hold on
plot(data.XCorr.Rest.zDiameter.meanLags,data.XCorr.Rest.zDiameter.meanXcVals_gamma + data.XCorr.Rest.zDiameter.semXcVals_gamma,'color',colors('custom rest'),'LineWidth',0.5);
plot(data.XCorr.Rest.zDiameter.meanLags,data.XCorr.Rest.zDiameter.meanXcVals_gamma - data.XCorr.Rest.zDiameter.semXcVals_gamma,'color',colors('custom rest'),'LineWidth',0.5);
plot(data.XCorr.NREM.zDiameter.meanLags,data.XCorr.NREM.zDiameter.meanXcVals_gamma,'color',colors('custom nrem'),'LineWidth',2);
plot(data.XCorr.NREM.zDiameter.meanLags,data.XCorr.NREM.zDiameter.meanXcVals_gamma + data.XCorr.NREM.zDiameter.semXcVals_gamma,'color',colors('custom nrem'),'LineWidth',0.5);
plot(data.XCorr.NREM.zDiameter.meanLags,data.XCorr.NREM.zDiameter.meanXcVals_gamma - data.XCorr.NREM.zDiameter.semXcVals_gamma,'color',colors('custom nrem'),'LineWidth',0.5);
plot(data.XCorr.REM.zDiameter.meanLags,data.XCorr.REM.zDiameter.meanXcVals_gamma,'color',colors('custom rem'),'LineWidth',2);
plot(data.XCorr.REM.zDiameter.meanLags,data.XCorr.REM.zDiameter.meanXcVals_gamma + data.XCorr.REM.zDiameter.semXcVals_gamma,'color',colors('custom rem'),'LineWidth',0.5);
plot(data.XCorr.REM.zDiameter.meanLags,data.XCorr.REM.zDiameter.meanXcVals_gamma - data.XCorr.REM.zDiameter.semXcVals_gamma,'color',colors('custom rem'),'LineWidth',0.5);
xticks([-lagSec*freq,-lagSec*freq/2,0,lagSec*freq/2,lagSec*freq])
xticklabels({'-5','-2.5','0','2.5','5'})
xlim([-lagSec*freq,lagSec*freq])
ylim([-0.35,0.15])
xlabel('Lags (s)')
ylabel('Correlation')
title('Gamma-Pupil XCorr')
axis square
set(gca,'box','off')
ax2.TickLength = [0.03,0.03];
%% gamma-pupil cross correlation [alert, asleep, all]
ax3 = subplot(4,3,3);
freq = 30;
lagSec = 30;
plot(data.XCorr.Alert.zDiameter.meanLags,data.XCorr.Alert.zDiameter.meanXcVals_gamma,'color',colors('custom alert'),'LineWidth',2);
hold on
plot(data.XCorr.Alert.zDiameter.meanLags,data.XCorr.Alert.zDiameter.meanXcVals_gamma + data.XCorr.Alert.zDiameter.semXcVals_gamma,'color',colors('custom alert'),'LineWidth',0.5);
plot(data.XCorr.Alert.zDiameter.meanLags,data.XCorr.Alert.zDiameter.meanXcVals_gamma - data.XCorr.Alert.zDiameter.semXcVals_gamma,'color',colors('custom alert'),'LineWidth',0.5);
plot(data.XCorr.Asleep.zDiameter.meanLags,data.XCorr.Asleep.zDiameter.meanXcVals_gamma,'color',colors('custom asleep'),'LineWidth',2);
plot(data.XCorr.Asleep.zDiameter.meanLags,data.XCorr.Asleep.zDiameter.meanXcVals_gamma + data.XCorr.Asleep.zDiameter.semXcVals_gamma,'color',colors('custom asleep'),'LineWidth',0.5);
plot(data.XCorr.Asleep.zDiameter.meanLags,data.XCorr.Asleep.zDiameter.meanXcVals_gamma - data.XCorr.Asleep.zDiameter.semXcVals_gamma,'color',colors('custom asleep'),'LineWidth',0.5);
plot(data.XCorr.All.zDiameter.meanLags,data.XCorr.All.zDiameter.meanXcVals_gamma,'color',colors('custom all'),'LineWidth',2);
plot(data.XCorr.All.zDiameter.meanLags,data.XCorr.All.zDiameter.meanXcVals_gamma + data.XCorr.All.zDiameter.semXcVals_gamma,'color',colors('custom all'),'LineWidth',0.5);
plot(data.XCorr.All.zDiameter.meanLags,data.XCorr.All.zDiameter.meanXcVals_gamma - data.XCorr.All.zDiameter.semXcVals_gamma,'color',colors('custom all'),'LineWidth',0.5);
xticks([-lagSec*freq,-lagSec*freq/2,0,lagSec*freq/2,lagSec*freq])
xticklabels({'-30','-15','0','15','30'})
xlim([-lagSec*freq,lagSec*freq])
ylim([-0.35,0.15])
xlabel('Lags (s)')
ylabel('Correlation')
title('Gamma-Pupil XCorr')
axis square
set(gca,'box','off')
ax3.TickLength = [0.03,0.03];
%% gamma-pupil coherence during arousal states
ax4 = subplot(4,3,4);
semilogx(data.Coherr.Rest.zDiameter.meanGammaf,data.Coherr.Rest.zDiameter.meanGammaC,'color',colors('custom rest'),'LineWidth',2);
hold on
semilogx(data.Coherr.Rest.zDiameter.meanGammaf,data.Coherr.Rest.zDiameter.meanGammaC + data.Coherr.Rest.zDiameter.semGammaC,'color',colors('custom rest'),'LineWidth',0.5);
semilogx(data.Coherr.Rest.zDiameter.meanGammaf,data.Coherr.Rest.zDiameter.meanGammaC - data.Coherr.Rest.zDiameter.semGammaC,'color',colors('custom rest'),'LineWidth',0.5);
rectangle('Position',[0.005,0.1,0.1 - 0.005,1],'FaceColor','w','EdgeColor','w')
semilogx(data.Coherr.NREM.zDiameter.meanGammaf,data.Coherr.NREM.zDiameter.meanGammaC,'color',colors('custom nrem'),'LineWidth',2);
semilogx(data.Coherr.NREM.zDiameter.meanGammaf,data.Coherr.NREM.zDiameter.meanGammaC + data.Coherr.NREM.zDiameter.semGammaC,'color',colors('custom nrem'),'LineWidth',0.5);
semilogx(data.Coherr.NREM.zDiameter.meanGammaf,data.Coherr.NREM.zDiameter.meanGammaC - data.Coherr.NREM.zDiameter.semGammaC,'color',colors('custom nrem'),'LineWidth',0.5);
rectangle('Position',[0.005,0.1,1/30 - 0.005,1],'FaceColor','w','EdgeColor','w')
semilogx(data.Coherr.REM.zDiameter.meanGammaf,data.Coherr.REM.zDiameter.meanGammaC,'color',colors('custom rem'),'LineWidth',2);
semilogx(data.Coherr.REM.zDiameter.meanGammaf,data.Coherr.REM.zDiameter.meanGammaC + data.Coherr.REM.zDiameter.semGammaC,'color',colors('custom rem'),'LineWidth',0.5);
semilogx(data.Coherr.REM.zDiameter.meanGammaf,data.Coherr.REM.zDiameter.meanGammaC - data.Coherr.REM.zDiameter.semGammaC,'color',colors('custom rem'),'LineWidth',0.5);
rectangle('Position',[0.005,0.1,1/60 - 0.005,1],'FaceColor','w','EdgeColor','w')
semilogx(data.Coherr.Alert.zDiameter.meanGammaf,data.Coherr.Alert.zDiameter.meanGammaC,'color',colors('custom alert'),'LineWidth',2);
semilogx(data.Coherr.Alert.zDiameter.meanGammaf,data.Coherr.Alert.zDiameter.meanGammaC + data.Coherr.Alert.zDiameter.semGammaC,'color',colors('custom alert'),'LineWidth',0.5);
semilogx(data.Coherr.Alert.zDiameter.meanGammaf,data.Coherr.Alert.zDiameter.meanGammaC - data.Coherr.Alert.zDiameter.semGammaC,'color',colors('custom alert'),'LineWidth',0.5);
semilogx(data.Coherr.Asleep.zDiameter.meanGammaf,data.Coherr.Asleep.zDiameter.meanGammaC,'color',colors('custom asleep'),'LineWidth',2);
semilogx(data.Coherr.Asleep.zDiameter.meanGammaf,data.Coherr.Asleep.zDiameter.meanGammaC + data.Coherr.Asleep.zDiameter.semGammaC,'color',colors('custom asleep'),'LineWidth',0.5);
semilogx(data.Coherr.Asleep.zDiameter.meanGammaf,data.Coherr.Asleep.zDiameter.meanGammaC - data.Coherr.Asleep.zDiameter.semGammaC,'color',colors('custom asleep'),'LineWidth',0.5);
semilogx(data.Coherr.All.zDiameter.meanGammaf,data.Coherr.All.zDiameter.meanGammaC,'color',colors('custom all'),'LineWidth',2);
semilogx(data.Coherr.All.zDiameter.meanGammaf,data.Coherr.All.zDiameter.meanGammaC + data.Coherr.All.zDiameter.semGammaC,'color',colors('custom all'),'LineWidth',0.5);
semilogx(data.Coherr.All.zDiameter.meanGammaf,data.Coherr.All.zDiameter.meanGammaC - data.Coherr.All.zDiameter.semGammaC,'color',colors('custom all'),'LineWidth',0.5);
xline(0.02,'color','b');
xline(0.35,'color','r');
title('Gamma-Pupil coherence')
ylabel('Coherence')
xlabel('Freq (Hz)')
axis square
xlim([0.003,1])
ylim([0,1])
set(gca,'box','off')
ax4.TickLength = [0.03,0.03];
%% gamma-pupil coherence stats
ax5 = subplot(4,3,5);
scatter(ones(1,length(data.Coherr.Alert.zDiameter.gammaC002))*1,data.Coherr.Alert.zDiameter.gammaC002,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom alert'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.Coherr.Alert.zDiameter.meanGammaC002,data.Coherr.Alert.zDiameter.stdGammaC002,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.Coherr.Asleep.zDiameter.gammaC002))*2,data.Coherr.Asleep.zDiameter.gammaC002,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom asleep'),'jitter','on','jitterAmount',0.25);
e2 = errorbar(2,data.Coherr.Asleep.zDiameter.meanGammaC002,data.Coherr.Asleep.zDiameter.stdGammaC002,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
scatter(ones(1,length(data.Coherr.All.zDiameter.gammaC002))*3,data.Coherr.All.zDiameter.gammaC002,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom all'),'jitter','on','jitterAmount',0.25);
e3 = errorbar(3,data.Coherr.All.zDiameter.meanGammaC002,data.Coherr.All.zDiameter.stdGammaC002,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e3.Color = 'black';
e3.MarkerSize = 10;
e3.CapSize = 10;
title('Gamma-Pupil coherence @ 0.02 Hz')
ylabel('Coherence')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,4])
set(gca,'box','off')
ax5.TickLength = [0.03,0.03];
%% gamma-pupil coherence stats
ax6 = subplot(4,3,6);
scatter(ones(1,length(data.Coherr.Rest.zDiameter.gammaC035))*1,data.Coherr.Rest.zDiameter.gammaC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom rest'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.Coherr.Rest.zDiameter.meanGammaC035,data.Coherr.Rest.zDiameter.stdGammaC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.Coherr.NREM.zDiameter.gammaC035))*2,data.Coherr.NREM.zDiameter.gammaC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom nrem'),'jitter','on','jitterAmount',0.25);
e2 = errorbar(2,data.Coherr.NREM.zDiameter.meanGammaC035,data.Coherr.NREM.zDiameter.stdGammaC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
scatter(ones(1,length(data.Coherr.REM.zDiameter.gammaC035))*3,data.Coherr.REM.zDiameter.gammaC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom rem'),'jitter','on','jitterAmount',0.25);
e3 = errorbar(3,data.Coherr.REM.zDiameter.meanGammaC035,data.Coherr.REM.zDiameter.stdGammaC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e3.Color = 'black';
e3.MarkerSize = 10;
e3.CapSize = 10;
scatter(ones(1,length(data.Coherr.Alert.zDiameter.gammaC035))*4,data.Coherr.Alert.zDiameter.gammaC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom alert'),'jitter','on','jitterAmount',0.25);
e4 = errorbar(4,data.Coherr.Alert.zDiameter.meanGammaC035,data.Coherr.Alert.zDiameter.stdGammaC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e4.Color = 'black';
e4.MarkerSize = 10;
e4.CapSize = 10;
scatter(ones(1,length(data.Coherr.Asleep.zDiameter.gammaC035))*5,data.Coherr.Asleep.zDiameter.gammaC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom asleep'),'jitter','on','jitterAmount',0.25);
e5 = errorbar(5,data.Coherr.Asleep.zDiameter.meanGammaC035,data.Coherr.Asleep.zDiameter.stdGammaC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e5.Color = 'black';
e5.MarkerSize = 10;
e5.CapSize = 10;
scatter(ones(1,length(data.Coherr.All.zDiameter.gammaC035))*6,data.Coherr.All.zDiameter.gammaC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom all'),'jitter','on','jitterAmount',0.25);
e6 = errorbar(6,data.Coherr.All.zDiameter.meanGammaC035,data.Coherr.All.zDiameter.stdGammaC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e6.Color = 'black';
e6.MarkerSize = 10;
e6.CapSize = 10;
title('Gamma-Pupil coherence @ 0.35 Hz')
ylabel('Coherence')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,7])
set(gca,'box','off')
ax6.TickLength = [0.03,0.03];
%% HbT
subplot(4,3,7)
HbTPupilImg = imread('HbTPupilStack.png'); % needs made by combining images in ImageJ (Z project min)
imshow(HbTPupilImg)
axis off
title('HbT-Pupil Relationship')
xlabel('Diameter (z-units)')
ylabel('\Delta[HbT] (\muM)')
%% HbT-pupil cross correlation [rest, NREM, REM]
ax8 = subplot(4,3,8);
freq = 30;
lagSec = 5;
plot(data.XCorr.Rest.zDiameter.meanLags,data.XCorr.Rest.zDiameter.meanXcVals_HbT,'color',colors('custom rest'),'LineWidth',2);
hold on
plot(data.XCorr.Rest.zDiameter.meanLags,data.XCorr.Rest.zDiameter.meanXcVals_HbT + data.XCorr.Rest.zDiameter.semXcVals_HbT,'color',colors('custom rest'),'LineWidth',0.5);
plot(data.XCorr.Rest.zDiameter.meanLags,data.XCorr.Rest.zDiameter.meanXcVals_HbT - data.XCorr.Rest.zDiameter.semXcVals_HbT,'color',colors('custom rest'),'LineWidth',0.5);
plot(data.XCorr.NREM.zDiameter.meanLags,data.XCorr.NREM.zDiameter.meanXcVals_HbT,'color',colors('custom nrem'),'LineWidth',2);
plot(data.XCorr.NREM.zDiameter.meanLags,data.XCorr.NREM.zDiameter.meanXcVals_HbT + data.XCorr.NREM.zDiameter.semXcVals_HbT,'color',colors('custom nrem'),'LineWidth',0.5);
plot(data.XCorr.NREM.zDiameter.meanLags,data.XCorr.NREM.zDiameter.meanXcVals_HbT - data.XCorr.NREM.zDiameter.semXcVals_HbT,'color',colors('custom nrem'),'LineWidth',0.5);
plot(data.XCorr.REM.zDiameter.meanLags,data.XCorr.REM.zDiameter.meanXcVals_HbT,'color',colors('custom rem'),'LineWidth',2);
plot(data.XCorr.REM.zDiameter.meanLags,data.XCorr.REM.zDiameter.meanXcVals_HbT + data.XCorr.REM.zDiameter.semXcVals_HbT,'color',colors('custom rem'),'LineWidth',0.5);
plot(data.XCorr.REM.zDiameter.meanLags,data.XCorr.REM.zDiameter.meanXcVals_HbT - data.XCorr.REM.zDiameter.semXcVals_HbT,'color',colors('custom rem'),'LineWidth',0.5);
xticks([-lagSec*freq,-lagSec*freq/2,0,lagSec*freq/2,lagSec*freq])
xticklabels({'-5','-2.5','0','2.5','5'})
xlim([-lagSec*freq,lagSec*freq])
ylim([-0.7,0.3])
xlabel('Lags (s)')
ylabel('Correlation')
title('HbT-Pupil XCorr')
axis square
set(gca,'box','off')
ax8.TickLength = [0.03,0.03];
%% HbT-pupil cross correlation [alert, asleep, all]
ax9 = subplot(4,3,9);
freq = 30;
lagSec = 30;
plot(data.XCorr.Alert.zDiameter.meanLags,data.XCorr.Alert.zDiameter.meanXcVals_HbT,'color',colors('custom alert'),'LineWidth',2);
hold on
plot(data.XCorr.Alert.zDiameter.meanLags,data.XCorr.Alert.zDiameter.meanXcVals_HbT + data.XCorr.Alert.zDiameter.semXcVals_HbT,'color',colors('custom alert'),'LineWidth',0.5);
plot(data.XCorr.Alert.zDiameter.meanLags,data.XCorr.Alert.zDiameter.meanXcVals_HbT - data.XCorr.Alert.zDiameter.semXcVals_HbT,'color',colors('custom alert'),'LineWidth',0.5);
plot(data.XCorr.Asleep.zDiameter.meanLags,data.XCorr.Asleep.zDiameter.meanXcVals_HbT,'color',colors('custom asleep'),'LineWidth',2);
plot(data.XCorr.Asleep.zDiameter.meanLags,data.XCorr.Asleep.zDiameter.meanXcVals_HbT + data.XCorr.Asleep.zDiameter.semXcVals_HbT,'color',colors('custom asleep'),'LineWidth',0.5);
plot(data.XCorr.Asleep.zDiameter.meanLags,data.XCorr.Asleep.zDiameter.meanXcVals_HbT - data.XCorr.Asleep.zDiameter.semXcVals_HbT,'color',colors('custom asleep'),'LineWidth',0.5);
plot(data.XCorr.All.zDiameter.meanLags,data.XCorr.All.zDiameter.meanXcVals_HbT,'color',colors('custom all'),'LineWidth',2);
plot(data.XCorr.All.zDiameter.meanLags,data.XCorr.All.zDiameter.meanXcVals_HbT + data.XCorr.All.zDiameter.semXcVals_HbT,'color',colors('custom all'),'LineWidth',0.5);
plot(data.XCorr.All.zDiameter.meanLags,data.XCorr.All.zDiameter.meanXcVals_HbT - data.XCorr.All.zDiameter.semXcVals_HbT,'color',colors('custom all'),'LineWidth',0.5);
xticks([-lagSec*freq,-lagSec*freq/2,0,lagSec*freq/2,lagSec*freq])
xticklabels({'-30','-15','0','15','30'})
xlim([-lagSec*freq,lagSec*freq])
ylim([-0.7,0.3])
xlabel('Lags (s)')
ylabel('Correlation')
title('HbT-Pupil XCorr')
axis square
set(gca,'box','off')
ax9.TickLength = [0.03,0.03];
%% HbT-pupil coherence
ax10 = subplot(4,3,10);
semilogx(data.Coherr.Rest.zDiameter.meanHbTf,data.Coherr.Rest.zDiameter.meanHbTC,'color',colors('custom rest'),'LineWidth',2);
hold on
semilogx(data.Coherr.Rest.zDiameter.meanHbTf,data.Coherr.Rest.zDiameter.meanHbTC + data.Coherr.Rest.zDiameter.semHbTC,'color',colors('custom rest'),'LineWidth',0.5);
semilogx(data.Coherr.Rest.zDiameter.meanHbTf,data.Coherr.Rest.zDiameter.meanHbTC - data.Coherr.Rest.zDiameter.semHbTC,'color',colors('custom rest'),'LineWidth',0.5);
rectangle('Position',[0.005,0.1,0.1 - 0.005,1],'FaceColor','w','EdgeColor','w')
semilogx(data.Coherr.NREM.zDiameter.meanHbTf,data.Coherr.NREM.zDiameter.meanHbTC,'color',colors('custom nrem'),'LineWidth',2);
semilogx(data.Coherr.NREM.zDiameter.meanHbTf,data.Coherr.NREM.zDiameter.meanHbTC + data.Coherr.NREM.zDiameter.semHbTC,'color',colors('custom nrem'),'LineWidth',0.5);
semilogx(data.Coherr.NREM.zDiameter.meanHbTf,data.Coherr.NREM.zDiameter.meanHbTC - data.Coherr.NREM.zDiameter.semHbTC,'color',colors('custom nrem'),'LineWidth',0.5);
rectangle('Position',[0.005,0.1,1/30 - 0.005,1],'FaceColor','w','EdgeColor','w')
semilogx(data.Coherr.REM.zDiameter.meanHbTf,data.Coherr.REM.zDiameter.meanHbTC,'color',colors('custom rem'),'LineWidth',2);
semilogx(data.Coherr.REM.zDiameter.meanHbTf,data.Coherr.REM.zDiameter.meanHbTC + data.Coherr.REM.zDiameter.semHbTC,'color',colors('custom rem'),'LineWidth',0.5);
semilogx(data.Coherr.REM.zDiameter.meanHbTf,data.Coherr.REM.zDiameter.meanHbTC - data.Coherr.REM.zDiameter.semHbTC,'color',colors('custom rem'),'LineWidth',0.5);
rectangle('Position',[0.005,0.1,1/60 - 0.005,1],'FaceColor','w','EdgeColor','w')
semilogx(data.Coherr.Alert.zDiameter.meanHbTf,data.Coherr.Alert.zDiameter.meanHbTC,'color',colors('custom alert'),'LineWidth',2);
semilogx(data.Coherr.Alert.zDiameter.meanHbTf,data.Coherr.Alert.zDiameter.meanHbTC + data.Coherr.Alert.zDiameter.semHbTC,'color',colors('custom alert'),'LineWidth',0.5);
semilogx(data.Coherr.Alert.zDiameter.meanHbTf,data.Coherr.Alert.zDiameter.meanHbTC - data.Coherr.Alert.zDiameter.semHbTC,'color',colors('custom alert'),'LineWidth',0.5);
semilogx(data.Coherr.Asleep.zDiameter.meanHbTf,data.Coherr.Asleep.zDiameter.meanHbTC,'color',colors('custom asleep'),'LineWidth',2);
semilogx(data.Coherr.Asleep.zDiameter.meanHbTf,data.Coherr.Asleep.zDiameter.meanHbTC + data.Coherr.Asleep.zDiameter.semHbTC,'color',colors('custom asleep'),'LineWidth',0.5);
semilogx(data.Coherr.Asleep.zDiameter.meanHbTf,data.Coherr.Asleep.zDiameter.meanHbTC - data.Coherr.Asleep.zDiameter.semHbTC,'color',colors('custom asleep'),'LineWidth',0.5);
semilogx(data.Coherr.All.zDiameter.meanHbTf,data.Coherr.All.zDiameter.meanHbTC,'color',colors('custom all'),'LineWidth',2);
semilogx(data.Coherr.All.zDiameter.meanHbTf,data.Coherr.All.zDiameter.meanHbTC + data.Coherr.All.zDiameter.semHbTC,'color',colors('custom all'),'LineWidth',0.5);
semilogx(data.Coherr.All.zDiameter.meanHbTf,data.Coherr.All.zDiameter.meanHbTC - data.Coherr.All.zDiameter.semHbTC,'color',colors('custom all'),'LineWidth',0.5);
xline(0.02,'color','b');
xline(0.35,'color','r');
title('HbT-Pupil coherence')
ylabel('Coherence')
xlabel('Freq (Hz)')
axis square
xlim([0.003,1])
ylim([0,1])
set(gca,'box','off')
ax10.TickLength = [0.03,0.03];
%% HbT-pupil coherence Stats
ax11 = subplot(4,3,11);
scatter(ones(1,length(data.Coherr.Alert.zDiameter.HbTC002))*1,data.Coherr.Alert.zDiameter.HbTC002,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom alert'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.Coherr.Alert.zDiameter.meanHbTC002,data.Coherr.Alert.zDiameter.stdHbTC002,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.Coherr.Asleep.zDiameter.HbTC002))*2,data.Coherr.Asleep.zDiameter.HbTC002,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom asleep'),'jitter','on','jitterAmount',0.25);
e2 = errorbar(2,data.Coherr.Asleep.zDiameter.meanHbTC002,data.Coherr.Asleep.zDiameter.stdHbTC002,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
scatter(ones(1,length(data.Coherr.All.zDiameter.HbTC002))*3,data.Coherr.All.zDiameter.HbTC002,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom all'),'jitter','on','jitterAmount',0.25);
e3 = errorbar(3,data.Coherr.All.zDiameter.meanHbTC002,data.Coherr.All.zDiameter.stdHbTC002,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e3.Color = 'black';
e3.MarkerSize = 10;
e3.CapSize = 10;
title('HbT-Pupil coherence @ 0.02/0.35 Hz')
ylabel('Coherece')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,4])
set(gca,'box','off')
ax11.TickLength = [0.03,0.03];
%% HbT-pupil coherence Stats
ax12 = subplot(4,3,12);
scatter(ones(1,length(data.Coherr.Rest.zDiameter.HbTC035))*1,data.Coherr.Rest.zDiameter.HbTC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom rest'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.Coherr.Rest.zDiameter.meanHbTC035,data.Coherr.Rest.zDiameter.stdHbTC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.Coherr.NREM.zDiameter.HbTC035))*2,data.Coherr.NREM.zDiameter.HbTC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom nrem'),'jitter','on','jitterAmount',0.25);
e2 = errorbar(2,data.Coherr.NREM.zDiameter.meanHbTC035,data.Coherr.NREM.zDiameter.stdHbTC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
scatter(ones(1,length(data.Coherr.REM.zDiameter.HbTC035))*3,data.Coherr.REM.zDiameter.HbTC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom rem'),'jitter','on','jitterAmount',0.25);
e3 = errorbar(3,data.Coherr.REM.zDiameter.meanHbTC035,data.Coherr.REM.zDiameter.stdHbTC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e3.Color = 'black';
e3.MarkerSize = 10;
e3.CapSize = 10;
scatter(ones(1,length(data.Coherr.Alert.zDiameter.HbTC035))*4,data.Coherr.Alert.zDiameter.HbTC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom alert'),'jitter','on','jitterAmount',0.25);
e4 = errorbar(4,data.Coherr.Alert.zDiameter.meanHbTC035,data.Coherr.Alert.zDiameter.stdHbTC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e4.Color = 'black';
e4.MarkerSize = 10;
e4.CapSize = 10;
scatter(ones(1,length(data.Coherr.Asleep.zDiameter.HbTC035))*5,data.Coherr.Asleep.zDiameter.HbTC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom asleep'),'jitter','on','jitterAmount',0.25);
e5 = errorbar(5,data.Coherr.Asleep.zDiameter.meanHbTC035,data.Coherr.Asleep.zDiameter.stdHbTC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e5.Color = 'black';
e5.MarkerSize = 10;
e5.CapSize = 10;
scatter(ones(1,length(data.Coherr.All.zDiameter.HbTC035))*6,data.Coherr.All.zDiameter.HbTC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom all'),'jitter','on','jitterAmount',0.25);
e6 = errorbar(6,data.Coherr.All.zDiameter.meanHbTC035,data.Coherr.All.zDiameter.stdHbTC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e6.Color = 'black';
e6.MarkerSize = 10;
e6.CapSize = 10;
title('HbT-Pupil coherence @ 0.35 Hz')
ylabel('Coherece')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,7])
set(gca,'box','off')
ax12.TickLength = [0.03,0.03];
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'MATLAB Figures' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig3,[dirpath 'Fig3_Turner2022']);
    set(Fig3,'PaperPositionMode','auto');
    print('-vector','-dpdf','-bestfit',[dirpath 'Fig3_Turner2022'])
    % text diary
    diaryFile = [dirpath 'Fig3_Text.txt'];
    if exist(diaryFile,'file') == 2
        delete(diaryFile)
    end
    diary(diaryFile)
    diary on
    % coherence between pupil diameter and HbT @ 0.35 Hz
    disp('======================================================================================================================')
    disp('GLME stats for z-unit diameter vs. HbT coherence during Rest, NREM, REM, Alert, Asleep, All')
    disp('======================================================================================================================')
    disp(HbTC035Stats)
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Rest   [HbT]-pupil coherence: ' num2str(round(data.Coherr.Rest.zDiameter.meanHbTC035,2)) ' ± ' num2str(round(data.Coherr.Rest.zDiameter.stdHbTC035,2)) ' (n = ' num2str(length(data.Coherr.Rest.zDiameter.HbTC035)/2) ') mice']); disp(' ')
    disp(['NREM   [HbT]-pupil coherence: ' num2str(round(data.Coherr.NREM.zDiameter.meanHbTC035,2)) ' ± ' num2str(round(data.Coherr.NREM.zDiameter.stdHbTC035,2)) ' (n = ' num2str(length(data.Coherr.NREM.zDiameter.HbTC035)/2) ') mice']); disp(' ')
    disp(['REM    [HbT]-pupil coherence: ' num2str(round(data.Coherr.REM.zDiameter.meanHbTC035,2)) ' ± ' num2str(round(data.Coherr.REM.zDiameter.stdHbTC035,2)) ' (n = ' num2str(length(data.Coherr.REM.zDiameter.HbTC035)/2) ') mice']); disp(' ')
    disp(['Alert  [HbT]-pupil coherence: ' num2str(round(data.Coherr.Alert.zDiameter.meanHbTC035,2)) ' ± ' num2str(round(data.Coherr.Alert.zDiameter.stdHbTC035,2)) ' (n = ' num2str(length(data.Coherr.Alert.zDiameter.HbTC035)/2) ') mice']); disp(' ')
    disp(['Asleep [HbT]-pupil coherence: ' num2str(round(data.Coherr.Asleep.zDiameter.meanHbTC035,2)) ' ± ' num2str(round(data.Coherr.Asleep.zDiameter.stdHbTC035,2)) ' (n = ' num2str(length(data.Coherr.Asleep.zDiameter.HbTC035)/2) ') mice']); disp(' ')
    disp(['All    [HbT]-pupil coherence: ' num2str(round(data.Coherr.All.zDiameter.meanHbTC035,2)) ' ± ' num2str(round(data.Coherr.All.zDiameter.stdHbTC035,2)) ' (n = ' num2str(length(data.Coherr.All.zDiameter.HbTC035)/2) ') mice']); disp(' ')
    disp(['*p < ' num2str(alpha15A) ' **p < ' num2str(alpha15B) ' ***p < ' num2str(alpha15C)]);
    disp(HbTC035StatsTable{1,1})
    disp(HbTC035StatsTable{2,1})
    disp(HbTC035StatsTable{3,1})
    disp(HbTC035StatsTable{4,1})
    disp(HbTC035StatsTable{5,1})
    disp(HbTC035StatsTable{6,1})
    disp('----------------------------------------------------------------------------------------------------------------------')
    % coherence between pupil diameter and HbT @ 0.02 Hz
    disp('======================================================================================================================')
    disp('GLME stats for z-unit diameter vs. HbT coherence during Rest, NREM, REM, Alert, Asleep, All')
    disp('======================================================================================================================')
    disp(HbTC002Stats)
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Alert  [HbT]-pupil coherence: ' num2str(round(data.Coherr.Alert.zDiameter.meanHbTC002,2)) ' ± ' num2str(round(data.Coherr.Alert.zDiameter.stdHbTC002,2)) ' (n = ' num2str(length(data.Coherr.Alert.zDiameter.HbTC002)/2) ') mice']); disp(' ')
    disp(['Asleep [HbT]-pupil coherence: ' num2str(round(data.Coherr.Asleep.zDiameter.meanHbTC002,2)) ' ± ' num2str(round(data.Coherr.Asleep.zDiameter.stdHbTC002,2)) ' (n = ' num2str(length(data.Coherr.Asleep.zDiameter.HbTC002)/2) ') mice']); disp(' ')
    disp(['All    [HbT]-pupil coherence: ' num2str(round(data.Coherr.All.zDiameter.meanHbTC002,2)) ' ± ' num2str(round(data.Coherr.All.zDiameter.stdHbTC002,2)) ' (n = ' num2str(length(data.Coherr.All.zDiameter.HbTC002)/2) ') mice']); disp(' ')
    disp(['*p < ' num2str(alpha3A) ' **p < ' num2str(alpha3B) ' ***p < ' num2str(alpha3C)]);
    disp(HbTC002StatsTable{1,1})
    disp(HbTC002StatsTable{2,1})
    disp(HbTC002StatsTable{3,1})
    disp('----------------------------------------------------------------------------------------------------------------------')
    % coherence between pupil diameter and gamma @ 0.35 Hz
    disp('======================================================================================================================')
    disp('GLME stats for z-unit diameter vs. Gamma coherence during Rest, NREM, REM, Alert, Asleep, All')
    disp('======================================================================================================================')
    disp(gammaC035Stats)
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Rest   Gamma-pupil coherence: ' num2str(round(data.Coherr.Rest.zDiameter.meanGammaC035,2)) ' ± ' num2str(round(data.Coherr.Rest.zDiameter.stdGammaC035,2)) ' (n = ' num2str(length(data.Coherr.Rest.zDiameter.gammaC035)/2) ') mice']); disp(' ')
    disp(['NREM   Gamma-pupil coherence: ' num2str(round(data.Coherr.NREM.zDiameter.meanGammaC035,2)) ' ± ' num2str(round(data.Coherr.NREM.zDiameter.stdGammaC035,2)) ' (n = ' num2str(length(data.Coherr.NREM.zDiameter.gammaC035)/2) ') mice']); disp(' ')
    disp(['REM    Gamma-pupil coherence: ' num2str(round(data.Coherr.REM.zDiameter.meanGammaC035,2)) ' ± ' num2str(round(data.Coherr.REM.zDiameter.stdGammaC035,2)) ' (n = ' num2str(length(data.Coherr.REM.zDiameter.gammaC035)/2) ') mice']); disp(' ')
    disp(['Alert  Gamma-pupil coherence: ' num2str(round(data.Coherr.Alert.zDiameter.meanGammaC035,2)) ' ± ' num2str(round(data.Coherr.Alert.zDiameter.stdGammaC035,2)) ' (n = ' num2str(length(data.Coherr.Alert.zDiameter.gammaC035)/2) ') mice']); disp(' ')
    disp(['Asleep Gamma-pupil coherence: ' num2str(round(data.Coherr.Asleep.zDiameter.meanGammaC035,2)) ' ± ' num2str(round(data.Coherr.Asleep.zDiameter.stdGammaC035,2)) ' (n = ' num2str(length(data.Coherr.Asleep.zDiameter.gammaC035)/2) ') mice']); disp(' ')
    disp(['All    Gamma-pupil coherence: ' num2str(round(data.Coherr.All.zDiameter.meanGammaC035,2)) ' ± ' num2str(round(data.Coherr.All.zDiameter.stdGammaC035,2)) ' (n = ' num2str(length(data.Coherr.All.zDiameter.gammaC035)/2) ') mice']); disp(' ')
    disp(['*p < ' num2str(alpha15A) ' **p < ' num2str(alpha15B) ' ***p < ' num2str(alpha15C)]);
    disp(gammaC035StatsTable{1,1})
    disp(gammaC035StatsTable{2,1})
    disp(gammaC035StatsTable{3,1})
    disp(gammaC035StatsTable{4,1})
    disp(gammaC035StatsTable{5,1})
    disp(gammaC035StatsTable{6,1})
    disp('----------------------------------------------------------------------------------------------------------------------')
    % coherence between pupil diameter and gamma @ 0.02 Hz
    disp('======================================================================================================================')
    disp('GLME stats for z-unit diameter vs. Gamma coherence during Alert, Asleep, All')
    disp('======================================================================================================================')
    disp(gammaC002Stats)
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Alert  Gamma-pupil coherence: ' num2str(round(data.Coherr.Alert.zDiameter.meanGammaC002,2)) ' ± ' num2str(round(data.Coherr.Alert.zDiameter.stdGammaC002,2)) ' (n = ' num2str(length(data.Coherr.Alert.zDiameter.gammaC002)/2) ') mice']); disp(' ')
    disp(['Asleep Gamma-pupil coherence: ' num2str(round(data.Coherr.Asleep.zDiameter.meanGammaC002,2)) ' ± ' num2str(round(data.Coherr.Asleep.zDiameter.stdGammaC002,2)) ' (n = ' num2str(length(data.Coherr.Asleep.zDiameter.gammaC002)/2) ') mice']); disp(' ')
    disp(['All    Gamma-pupil coherence: ' num2str(round(data.Coherr.All.zDiameter.meanGammaC002,2)) ' ± ' num2str(round(data.Coherr.All.zDiameter.stdGammaC002,2)) ' (n = ' num2str(length(data.Coherr.All.zDiameter.gammaC002)/2) ') mice']); disp(' ')
    disp(['*p < ' num2str(alpha3A) ' **p < ' num2str(alpha3B) ' ***p < ' num2str(alpha3C)]);
    disp(gammaC002StatsTable{1,1})
    disp(gammaC002StatsTable{2,1})
    disp(gammaC002StatsTable{3,1})
    disp('----------------------------------------------------------------------------------------------------------------------')
    % cross correlation between [HbT] and pupil diameter
    disp('======================================================================================================================')
    disp('Peak HbT-Pupil cross-correlation and lag time for Rest, NREM, REM, Alert, Asleep, All')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Rest   [HbT]-pupil peak cross-correlation: ' num2str(data.XCorr.Rest.zDiameter.peakHbTVal) ' ± ' num2str(data.XCorr.Rest.zDiameter.peakHbTStD) ' at a lag time of ' num2str(data.XCorr.Rest.zDiameter.peakHbTLag) ' seconds (n = ' num2str(size(data.XCorr.Rest.zDiameter.xcVals_HbT,1)/2) ') mice']); disp(' ')
    disp(['NREM   [HbT]-pupil peak cross-correlation: ' num2str(data.XCorr.NREM.zDiameter.peakHbTVal) ' ± ' num2str(data.XCorr.NREM.zDiameter.peakHbTStD) ' at a lag time of ' num2str(data.XCorr.NREM.zDiameter.peakHbTLag) 'seconds (n = ' num2str(size(data.XCorr.NREM.zDiameter.xcVals_HbT,1)/2) ') mice']); disp(' ')
    disp(['REM    [HbT]-pupil peak cross-correlation: ' num2str(data.XCorr.REM.zDiameter.peakHbTVal) ' ± ' num2str(data.XCorr.REM.zDiameter.peakHbTStD) ' at a lag time of ' num2str(data.XCorr.REM.zDiameter.peakHbTLag) ' seconds (n = ' num2str(size(data.XCorr.REM.zDiameter.xcVals_HbT,1)/2) ') mice']); disp(' ')
    disp(['Alert  [HbT]-pupil peak cross-correlation: ' num2str(data.XCorr.Alert.zDiameter.peakHbTVal) ' ± ' num2str(data.XCorr.Alert.zDiameter.peakHbTStD) ' at a lag time of ' num2str(data.XCorr.Alert.zDiameter.peakHbTLag) ' seconds (n = ' num2str(size(data.XCorr.Alert.zDiameter.xcVals_HbT,1)/2) ') mice']); disp(' ')
    disp(['Asleep [HbT]-pupil peak cross-correlation: ' num2str(data.XCorr.Asleep.zDiameter.peakHbTVal) ' ± ' num2str(data.XCorr.Asleep.zDiameter.peakHbTStD) ' at a lag time of ' num2str(data.XCorr.Asleep.zDiameter.peakHbTLag) ' seconds (n = ' num2str(size(data.XCorr.Asleep.zDiameter.xcVals_HbT,1)/2) ') mice']); disp(' ')
    disp(['All    [HbT]-pupil peak cross-correlation: ' num2str(data.XCorr.All.zDiameter.peakHbTVal) ' ± ' num2str(data.XCorr.All.zDiameter.peakHbTStD) ' at a lag time of ' num2str(data.XCorr.All.zDiameter.peakHbTLag) ' seconds (n = ' num2str(size(data.XCorr.All.zDiameter.xcVals_HbT,1)/2) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    % cross correlation between gamma-band and pupil diameter
    disp('======================================================================================================================')
    disp('Peak Gamma-Pupil cross-correlation and lag time for Rest, NREM, REM, Alert, Asleep, All')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Rest   Gamma-pupil peak cross-correlation: ' num2str(data.XCorr.Rest.zDiameter.peakGammaVal) ' ± ' num2str(data.XCorr.Rest.zDiameter.peakGammaStD) ' at a lag time of ' num2str(data.XCorr.Rest.zDiameter.peakGammaLag) ' seconds (n = ' num2str(size(data.XCorr.Rest.zDiameter.xcVals_gamma,1)/2) ') mice']); disp(' ')
    disp(['NREM   Gamma-pupil peak cross-correlation: ' num2str(data.XCorr.NREM.zDiameter.peakGammaVal) ' ± ' num2str(data.XCorr.NREM.zDiameter.peakGammaStD) ' at a lag time of ' num2str(data.XCorr.NREM.zDiameter.peakGammaLag) ' seconds (n = ' num2str(size(data.XCorr.NREM.zDiameter.xcVals_gamma,1)/2) ') mice']); disp(' ')
    disp(['REM    Gamma-pupil peak cross-correlation: ' num2str(data.XCorr.REM.zDiameter.peakGammaVal) ' ± ' num2str(data.XCorr.REM.zDiameter.peakGammaStD) ' at a lag time of ' num2str(data.XCorr.REM.zDiameter.peakGammaLag) ' seconds (n = ' num2str(size(data.XCorr.REM.zDiameter.xcVals_gamma,1)/2) ') mice']); disp(' ')
    disp(['Alert  Gamma-pupil peak cross-correlation: ' num2str(data.XCorr.Alert.zDiameter.peakGammaVal) ' ± ' num2str(data.XCorr.Alert.zDiameter.peakGammaStD) ' at a lag time of ' num2str(data.XCorr.Alert.zDiameter.peakGammaLag) ' seconds (n = ' num2str(size(data.XCorr.Alert.zDiameter.xcVals_gamma,1)/2) ') mice']); disp(' ')
    disp(['Asleep Gamma-pupil peak cross-correlation: ' num2str(data.XCorr.Asleep.zDiameter.peakGammaVal) ' ± ' num2str(data.XCorr.Asleep.zDiameter.peakGammaStD) ' at a lag time of ' num2str(data.XCorr.Asleep.zDiameter.peakGammaLag) ' seconds (n = ' num2str(size(data.XCorr.Asleep.zDiameter.xcVals_gamma,1)/2) ') mice']); disp(' ')
    disp(['All    Gamma-pupil peak cross-correlation: ' num2str(data.XCorr.All.zDiameter.peakGammaVal) ' ± ' num2str(data.XCorr.All.zDiameter.peakGammaStD) ' at a lag time of ' num2str(data.XCorr.All.zDiameter.peakGammaLag) ' seconds (n = ' num2str(size(data.XCorr.All.zDiameter.xcVals_gamma,1)/2) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    diary off
end
cd(rootFolder)
end
