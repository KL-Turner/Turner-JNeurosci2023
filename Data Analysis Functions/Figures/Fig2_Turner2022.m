function [] = Fig2_Turner2022(rootFolder,saveFigs,delim)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Generate figures and supporting information for Figure Panel 2
%________________________________________________________________________________________________________________________

dataLocation = [rootFolder delim 'Analysis Structures'];
cd(dataLocation)
%% stimulus and whisking evoked pupil changes
resultsStruct = 'Results_Evoked.mat';
load(resultsStruct);
dataTypes = {'zDiameter'};
timeVector = (0:12*30)/30 - 2;
animalIDs = fieldnames(Results_Evoked);
% pre-allocate
for aa = 1:length(dataTypes)
    dataType = dataTypes{1,aa};
    data.Evoked.controlSolenoid.(dataType).data = [];
    data.Evoked.stimSolenoid.(dataType).data = [];
    data.Evoked.briefWhisk.(dataType).data = [];
    data.Evoked.interWhisk.(dataType).data = [];
    data.Evoked.extendWhisk.(dataType).data = [];
end
% concatenate each stimuli type from each animal
for cc = 1:length(animalIDs)
    animalID = animalIDs{cc,1};
    for bb = 1:length(dataTypes)
        dataType = dataTypes{1,bb};
        % whisking
        data.Evoked.briefWhisk.(dataType).data = cat(1,data.Evoked.briefWhisk.(dataType).data,Results_Evoked.(animalID).Whisk.(dataType).ShortWhisks.mean);
        data.Evoked.interWhisk.(dataType).data = cat(1,data.Evoked.interWhisk.(dataType).data,Results_Evoked.(animalID).Whisk.(dataType).IntermediateWhisks.mean);
        data.Evoked.extendWhisk.(dataType).data = cat(1,data.Evoked.extendWhisk.(dataType).data,Results_Evoked.(animalID).Whisk.(dataType).LongWhisks.mean);
        % solenoids
        data.Evoked.stimSolenoid.(dataType).data = cat(1,data.Evoked.stimSolenoid.(dataType).data,Results_Evoked.(animalID).Stim.(dataType).LPadSol.mean,Results_Evoked.(animalID).Stim.(dataType).RPadSol.mean);
        data.Evoked.controlSolenoid.(dataType).data = cat(1,data.Evoked.controlSolenoid.(dataType).data,Results_Evoked.(animalID).Stim.(dataType).AudSol.mean);
    end
end
% mean and standard error for each stimulation
for dd = 1:length(dataTypes)
    dataType = dataTypes{1,dd};
    data.Evoked.briefWhisk.(dataType).mean = mean(data.Evoked.briefWhisk.(dataType).data,1);
    data.Evoked.briefWhisk.(dataType).sem = std(data.Evoked.briefWhisk.(dataType).data,0,1)./sqrt(size(data.Evoked.briefWhisk.(dataType).data,1));
    data.Evoked.briefWhisk.(dataType).peak = max(data.Evoked.briefWhisk.(dataType).data,[],2);
    data.Evoked.briefWhisk.(dataType).meanPeak = mean(data.Evoked.briefWhisk.(dataType).peak,1);
    data.Evoked.briefWhisk.(dataType).stdPeak = std(data.Evoked.briefWhisk.(dataType).peak,0,1);
    data.Evoked.interWhisk.(dataType).mean = mean(data.Evoked.interWhisk.(dataType).data,1);
    data.Evoked.interWhisk.(dataType).sem = std(data.Evoked.interWhisk.(dataType).data,0,1)./sqrt(size(data.Evoked.interWhisk.(dataType).data,1));
    data.Evoked.interWhisk.(dataType).peak = max(data.Evoked.interWhisk.(dataType).data,[],2);
    data.Evoked.interWhisk.(dataType).meanPeak = mean(data.Evoked.interWhisk.(dataType).peak,1);
    data.Evoked.interWhisk.(dataType).stdPeak = std(data.Evoked.interWhisk.(dataType).peak,0,1);
    data.Evoked.extendWhisk.(dataType).mean = mean(data.Evoked.extendWhisk.(dataType).data,1);
    data.Evoked.extendWhisk.(dataType).sem = std(data.Evoked.extendWhisk.(dataType).data,0,1)./sqrt(size(data.Evoked.extendWhisk.(dataType).data,1));
    data.Evoked.extendWhisk.(dataType).peak = max(data.Evoked.extendWhisk.(dataType).data,[],2);
    data.Evoked.extendWhisk.(dataType).meanPeak = mean(data.Evoked.extendWhisk.(dataType).peak,1);
    data.Evoked.extendWhisk.(dataType).stdPeak = std(data.Evoked.extendWhisk.(dataType).peak,0,1);
    data.Evoked.stimSolenoid.(dataType).mean = mean(data.Evoked.stimSolenoid.(dataType).data,1);
    data.Evoked.stimSolenoid.(dataType).sem = std(data.Evoked.stimSolenoid.(dataType).data,0,1)./sqrt(size(data.Evoked.stimSolenoid.(dataType).data,1));
    data.Evoked.stimSolenoid.(dataType).peak = max(data.Evoked.stimSolenoid.(dataType).data,[],2);
    data.Evoked.stimSolenoid.(dataType).meanPeak = mean(data.Evoked.stimSolenoid.(dataType).peak,1);
    data.Evoked.stimSolenoid.(dataType).stdPeak = std(data.Evoked.stimSolenoid.(dataType).peak,0,1);
    data.Evoked.controlSolenoid.(dataType).mean = mean(data.Evoked.controlSolenoid.(dataType).data,1);
    data.Evoked.controlSolenoid.(dataType).sem = std(data.Evoked.controlSolenoid.(dataType).data,0,1)./sqrt(size(data.Evoked.controlSolenoid.(dataType).data,1));
    data.Evoked.controlSolenoid.(dataType).peak = max(data.Evoked.controlSolenoid.(dataType).data,[],2);
    data.Evoked.controlSolenoid.(dataType).meanPeak = mean(data.Evoked.controlSolenoid.(dataType).peak,1);
    data.Evoked.controlSolenoid.(dataType).stdPeak = std(data.Evoked.controlSolenoid.(dataType).peak,0,1);
end
%% pupil diameter during different arousel states
resultsStruct = 'Results_BehavData.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_BehavData);
behavFields = {'Rest','Whisk','Stim','NREM','REM'};
% pre-allocate
for cc = 1:length(behavFields)
    behavField = behavFields{1,cc};
    data.Diameter.(behavField).mmDiameter = [];
    data.Diameter.(behavField).zDiameter = [];
    data.Diameter.(behavField).animalID = {};
    data.Diameter.(behavField).behavField = {};
end
% concatenate diameter from each arousal state for each animal
for cc = 1:length(animalIDs)
    animalID = animalIDs{cc,1};
    for dd = 1:length(behavFields)
        behavField = behavFields{1,dd};
        data.Diameter.(behavField).mmDiameter = cat(1,data.Diameter.(behavField).mmDiameter,mean(Results_BehavData.(animalID).(behavField).mmDiameter.eventMeans,'omitnan'));
        data.Diameter.(behavField).zDiameter = cat(1,data.Diameter.(behavField).zDiameter,mean(Results_BehavData.(animalID).(behavField).zDiameter.eventMeans,'omitnan'));
        data.Diameter.(behavField).animalID = cat(1,data.Diameter.(behavField).animalID,animalID);
        data.Diameter.(behavField).behavField = cat(1,data.Diameter.(behavField).behavField,behavField);
    end
end
% mean and standard deviation for the diameter during each arousal state
for ee = 1:length(behavFields)
    behavField = behavFields{1,ee};
    % diameter
    data.Diameter.(behavField).meanDiameter = mean(data.Diameter.(behavField).mmDiameter,1,'omitnan');
    data.Diameter.(behavField).stdDiameter = std(data.Diameter.(behavField).mmDiameter,0,1,'omitnan');
    % z diameter
    data.Diameter.(behavField).meanzDiameter = mean(data.Diameter.(behavField).zDiameter,1,'omitnan');
    data.Diameter.(behavField).stdzDiameter = std(data.Diameter.(behavField).zDiameter,0,1,'omitnan');
end
%% statistics - generalized linear mixed effects model (mm diameter)
mmDiameterTableSize = cat(1,data.Diameter.Rest.mmDiameter,data.Diameter.Whisk.mmDiameter,data.Diameter.Stim.mmDiameter,data.Diameter.NREM.mmDiameter,data.Diameter.REM.mmDiameter);
mmDiameterTable = table('Size',[size(mmDiameterTableSize,1),3],'VariableTypes',{'string','string','double'},'VariableNames',{'Mouse','Behavior','mmDiameter'});
mmDiameterTable.Mouse = cat(1,data.Diameter.Rest.animalID,data.Diameter.Whisk.animalID,data.Diameter.Stim.animalID,data.Diameter.NREM.animalID,data.Diameter.REM.animalID);
mmDiameterTable.Behavior = cat(1,data.Diameter.Rest.behavField,data.Diameter.Whisk.behavField,data.Diameter.Stim.behavField,data.Diameter.NREM.behavField,data.Diameter.REM.behavField);
mmDiameterTable.mmDiameter = cat(1,data.Diameter.Rest.mmDiameter,data.Diameter.Whisk.mmDiameter,data.Diameter.Stim.mmDiameter,data.Diameter.NREM.mmDiameter,data.Diameter.REM.mmDiameter);
mmDiameterFitFormula = 'mmDiameter ~ 1 + Behavior + (1|Mouse)';
mmDiameterStats = fitglme(mmDiameterTable,mmDiameterFitFormula);

[mm_pVal11,~,~,~] = coefTest(mmDiameterStats,[ 1  0  0  0  0 ]);
[mm_pVal12,~,~,~] = coefTest(mmDiameterStats,[ 1 -1  0  0  0 ]);
[mm_pVal13,~,~,~] = coefTest(mmDiameterStats,[ 1  0 -1  0  0 ]);
[mm_pVal14,~,~,~] = coefTest(mmDiameterStats,[ 1  0  0 -1  0 ]);
[mm_pVal15,~,~,~] = coefTest(mmDiameterStats,[ 1  0  0  0 -1 ]);

[mm_pVal21,~,~,~] = coefTest(mmDiameterStats,[-1  1  0  0  0 ]);
[mm_pVal22,~,~,~] = coefTest(mmDiameterStats,[ 0  1  0  0  0 ]);
[mm_pVal23,~,~,~] = coefTest(mmDiameterStats,[ 0  1 -1  0  0 ]);
[mm_pVal24,~,~,~] = coefTest(mmDiameterStats,[ 0  1  0 -1  0 ]);
[mm_pVal25,~,~,~] = coefTest(mmDiameterStats,[ 0  1  0  0 -1 ]);

[mm_pVal31,~,~,~] = coefTest(mmDiameterStats,[-1  0  1  0  0 ]);
[mm_pVal32,~,~,~] = coefTest(mmDiameterStats,[ 0 -1  1  0  0 ]);
[mm_pVal33,~,~,~] = coefTest(mmDiameterStats,[ 0  0  1  0  0 ]);
[mm_pVal34,~,~,~] = coefTest(mmDiameterStats,[ 0  0  1 -1  0 ]);
[mm_pVal35,~,~,~] = coefTest(mmDiameterStats,[ 0  0  1  0 -1 ]);

[mm_pVal41,~,~,~] = coefTest(mmDiameterStats,[-1  0  0  1  0 ]);
[mm_pVal42,~,~,~] = coefTest(mmDiameterStats,[ 0 -1  0  1  0 ]);
[mm_pVal43,~,~,~] = coefTest(mmDiameterStats,[ 0  0 -1  1  0 ]);
[mm_pVal44,~,~,~] = coefTest(mmDiameterStats,[ 0  0  0  1  0 ]);
[mm_pVal45,~,~,~] = coefTest(mmDiameterStats,[ 0  0  0  1 -1 ]);

[mm_pVal51,~,~,~] = coefTest(mmDiameterStats,[-1  0  0  0  1 ]);
[mm_pVal52,~,~,~] = coefTest(mmDiameterStats,[ 0 -1  0  0  1 ]);
[mm_pVal53,~,~,~] = coefTest(mmDiameterStats,[ 0  0 -1  0  1 ]);
[mm_pVal54,~,~,~] = coefTest(mmDiameterStats,[ 0  0  0 -1  1 ]);
[mm_pVal55,~,~,~] = coefTest(mmDiameterStats,[ 0  0  0  0  1 ]);

mmX = [mm_pVal11,mm_pVal12,mm_pVal13,mm_pVal14,mm_pVal15;...
    mm_pVal21,mm_pVal22,mm_pVal23,mm_pVal24,mm_pVal25;...
    mm_pVal31,mm_pVal32,mm_pVal33,mm_pVal34,mm_pVal35;...
    mm_pVal41,mm_pVal42,mm_pVal43,mm_pVal44,mm_pVal45;...
    mm_pVal51,mm_pVal52,mm_pVal53,mm_pVal54,mm_pVal55];

state = {'Rest';'Whisk';'Stim';'NREM';'REM'};
mmTable = table(array2table(mmX,'VariableNames',{'Rest','Whisk','Stim','NREM','REM'}),'RowNames',state);
%% statistics - generalized linear mixed effects model (z-units)
zDiameterTableSize = cat(1,data.Diameter.Rest.zDiameter,data.Diameter.Whisk.zDiameter,data.Diameter.Stim.zDiameter,data.Diameter.NREM.zDiameter,data.Diameter.REM.zDiameter);
zDiameterTable = table('Size',[size(zDiameterTableSize,1),3],'VariableTypes',{'string','string','double'},'VariableNames',{'Mouse','Behavior','zDiameter'});
zDiameterTable.Mouse = cat(1,data.Diameter.Rest.animalID,data.Diameter.Whisk.animalID,data.Diameter.Stim.animalID,data.Diameter.NREM.animalID,data.Diameter.REM.animalID);
zDiameterTable.Behavior = cat(1,data.Diameter.Rest.behavField,data.Diameter.Whisk.behavField,data.Diameter.Stim.behavField,data.Diameter.NREM.behavField,data.Diameter.REM.behavField);
zDiameterTable.zDiameter = cat(1,data.Diameter.Rest.zDiameter,data.Diameter.Whisk.zDiameter,data.Diameter.Stim.zDiameter,data.Diameter.NREM.zDiameter,data.Diameter.REM.zDiameter);
zDiameterFitFormula = 'zDiameter ~ 1 + Behavior + (1|Mouse)';
zDiameterStats = fitglme(zDiameterTable,zDiameterFitFormula);

[z_pVal11,~,~,~] = coefTest(zDiameterStats,[ 1  0  0  0  0 ]);
[z_pVal12,~,~,~] = coefTest(zDiameterStats,[ 1 -1  0  0  0 ]);
[z_pVal13,~,~,~] = coefTest(zDiameterStats,[ 1  0 -1  0  0 ]);
[z_pVal14,~,~,~] = coefTest(zDiameterStats,[ 1  0  0 -1  0 ]);
[z_pVal15,~,~,~] = coefTest(zDiameterStats,[ 1  0  0  0 -1 ]);

[z_pVal21,~,~,~] = coefTest(zDiameterStats,[-1  1  0  0  0 ]);
[z_pVal22,~,~,~] = coefTest(zDiameterStats,[ 0  1  0  0  0 ]);
[z_pVal23,~,~,~] = coefTest(zDiameterStats,[ 0  1 -1  0  0 ]);
[z_pVal24,~,~,~] = coefTest(zDiameterStats,[ 0  1  0 -1  0 ]);
[z_pVal25,~,~,~] = coefTest(zDiameterStats,[ 0  1  0  0 -1 ]);

[z_pVal31,~,~,~] = coefTest(zDiameterStats,[-1  0  1  0  0 ]);
[z_pVal32,~,~,~] = coefTest(zDiameterStats,[ 0 -1  1  0  0 ]);
[z_pVal33,~,~,~] = coefTest(zDiameterStats,[ 0  0  1  0  0 ]);
[z_pVal34,~,~,~] = coefTest(zDiameterStats,[ 0  0  1 -1  0 ]);
[z_pVal35,~,~,~] = coefTest(zDiameterStats,[ 0  0  1  0 -1 ]);

[z_pVal41,~,~,~] = coefTest(zDiameterStats,[-1  0  0  1  0 ]);
[z_pVal42,~,~,~] = coefTest(zDiameterStats,[ 0 -1  0  1  0 ]);
[z_pVal43,~,~,~] = coefTest(zDiameterStats,[ 0  0 -1  1  0 ]);
[z_pVal44,~,~,~] = coefTest(zDiameterStats,[ 0  0  0  1  0 ]);
[z_pVal45,~,~,~] = coefTest(zDiameterStats,[ 0  0  0  1 -1 ]);

[z_pVal51,~,~,~] = coefTest(zDiameterStats,[-1  0  0  0  1 ]);
[z_pVal52,~,~,~] = coefTest(zDiameterStats,[ 0 -1  0  0  1 ]);
[z_pVal53,~,~,~] = coefTest(zDiameterStats,[ 0  0 -1  0  1 ]);
[z_pVal54,~,~,~] = coefTest(zDiameterStats,[ 0  0  0 -1  1 ]);
[z_pVal55,~,~,~] = coefTest(zDiameterStats,[ 0  0  0  0  1 ]);

zX = [z_pVal11,z_pVal12,z_pVal13,z_pVal14,z_pVal15;...
    z_pVal21,z_pVal22,z_pVal23,z_pVal24,z_pVal25;...
    z_pVal31,z_pVal32,z_pVal33,z_pVal34,z_pVal35;...
    z_pVal41,z_pVal42,z_pVal43,z_pVal44,z_pVal45;...
    z_pVal51,z_pVal52,z_pVal53,z_pVal54,z_pVal55];

state = {'Rest';'Whisk';'Stim';'NREM';'REM'};
zTable = table(array2table(zX,'VariableNames',{'Rest','Whisk','Stim','NREM','REM'}),'RowNames',state);

% Bonferroni corrected confidence levels
comparisons = 10;
alpha10A = 0.05/comparisons;
alpha10B = 0.01/comparisons;
alpha10C = 0.001/comparisons;
%% pupil power spectrum
resultsStruct = 'Results_PowerSpectrum.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_PowerSpectrum);
behavFields = {'Rest','NREM','REM','Alert','Asleep','All'};
dataTypes = {'zDiameter'};
% pre-allocate data structure
for aa = 1:length(behavFields)
    behavField = behavFields{1,aa};
    for bb = 1:length(dataTypes)
        dataType = dataTypes{1,bb};
        data.PowerSpec.(behavField).(dataType).S = [];
        data.PowerSpec.(behavField).(dataType).f = [];
    end
end
% concatenate power spectra during different arousal states for each animal
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    for bb = 1:length(behavFields)
        behavField = behavFields{1,bb};
        for cc = 1:length(dataTypes)
            dataType = dataTypes{1,cc};
            % don't concatenate empty arrays where there was no data for this behavior
            if isempty(Results_PowerSpectrum.(animalID).(behavField).(dataType).S) == false
                data.PowerSpec.(behavField).(dataType).S = cat(2,data.PowerSpec.(behavField).(dataType).S,Results_PowerSpectrum.(animalID).(behavField).(dataType).S);
                data.PowerSpec.(behavField).(dataType).f = cat(1,data.PowerSpec.(behavField).(dataType).f,Results_PowerSpectrum.(animalID).(behavField).(dataType).f);
            end
        end
    end
end
% mean and standard error for arousal state power
for aa = 1:length(behavFields)
    behavField = behavFields{1,aa};
    for bb = 1:length(dataTypes)
        dataType = dataTypes{1,bb};
        data.PowerSpec.(behavField).(dataType).meanS = mean(data.PowerSpec.(behavField).(dataType).S,2);
        data.PowerSpec.(behavField).(dataType).semS = std(data.PowerSpec.(behavField).(dataType).S,0,2)./sqrt(size(data.PowerSpec.(behavField).(dataType).S,2));
        data.PowerSpec.(behavField).(dataType).meanf = mean(data.PowerSpec.(behavField).(dataType).f,1);
    end
end
%% pupil pre whitened power spectrum
resultsStruct = 'Results_PreWhitenedPowerSpectrum.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_PreWhitenedPowerSpectrum);
behavFields = {'Rest','NREM','REM','Alert','Asleep','All'};
dataTypes = {'zDiameter'};
% pre-allocate data structure
for aa = 1:length(behavFields)
    behavField = behavFields{1,aa};
    for bb = 1:length(dataTypes)
        dataType = dataTypes{1,bb};
        data.PreWhitenedPowerSpec.(behavField).(dataType).S = [];
        data.PreWhitenedPowerSpec.(behavField).(dataType).f = [];
    end
end
% concatenate power spectra during different arousal states for each animal
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    for bb = 1:length(behavFields)
        behavField = behavFields{1,bb};
        for cc = 1:length(dataTypes)
            dataType = dataTypes{1,cc};
            % don't concatenate empty arrays where there was no data for this behavior
            if isempty(Results_PreWhitenedPowerSpectrum.(animalID).(behavField).(dataType).S) == false
                data.PreWhitenedPowerSpec.(behavField).(dataType).S = cat(2,data.PreWhitenedPowerSpec.(behavField).(dataType).S,Results_PreWhitenedPowerSpectrum.(animalID).(behavField).(dataType).S);
                data.PreWhitenedPowerSpec.(behavField).(dataType).f = cat(1,data.PreWhitenedPowerSpec.(behavField).(dataType).f,Results_PreWhitenedPowerSpectrum.(animalID).(behavField).(dataType).f);
            end
        end
    end
end
% mean and standard error for arousal state power
for aa = 1:length(behavFields)
    behavField = behavFields{1,aa};
    for bb = 1:length(dataTypes)
        dataType = dataTypes{1,bb};
        data.PreWhitenedPowerSpec.(behavField).(dataType).meanS = mean(data.PreWhitenedPowerSpec.(behavField).(dataType).S,2);
        data.PreWhitenedPowerSpec.(behavField).(dataType).semS = std(data.PreWhitenedPowerSpec.(behavField).(dataType).S,0,2)./sqrt(size(data.PreWhitenedPowerSpec.(behavField).(dataType).S,2));
        data.PreWhitenedPowerSpec.(behavField).(dataType).meanf = mean(data.PreWhitenedPowerSpec.(behavField).(dataType).f,1);
    end
end
%% figures
Fig2 = figure('Name','Figure Panel 2 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
%% mm pupil diameter during arousal states
ax2 = subplot(1,4,1);
s1 = scatter(ones(1,length(data.Diameter.Rest.mmDiameter))*1,data.Diameter.Rest.mmDiameter,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom rest'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.Diameter.Rest.meanDiameter,data.Diameter.Rest.stdDiameter,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
s2 = scatter(ones(1,length(data.Diameter.Whisk.mmDiameter))*2,data.Diameter.Whisk.mmDiameter,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom whisk'),'jitter','on','jitterAmount',0.25);
e2 = errorbar(2,data.Diameter.Whisk.meanDiameter,data.Diameter.Whisk.stdDiameter,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
s3 = scatter(ones(1,length(data.Diameter.Stim.mmDiameter))*3,data.Diameter.Stim.mmDiameter,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom stim'),'jitter','on','jitterAmount',0.25);
e3 = errorbar(3,data.Diameter.Stim.meanDiameter,data.Diameter.Stim.stdDiameter,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e3.Color = 'black';
e3.MarkerSize = 10;
e3.CapSize = 10;
s4 = scatter(ones(1,length(data.Diameter.NREM.mmDiameter))*4,data.Diameter.NREM.mmDiameter,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom nrem'),'jitter','on','jitterAmount',0.25);
e4 = errorbar(4,data.Diameter.NREM.meanDiameter,data.Diameter.NREM.stdDiameter,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e4.Color = 'black';
e4.MarkerSize = 10;
e4.CapSize = 10;
s5 = scatter(ones(1,length(data.Diameter.REM.mmDiameter))*5,data.Diameter.REM.mmDiameter,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom rem'),'jitter','on','jitterAmount',0.25);
e5 = errorbar(5,data.Diameter.REM.meanDiameter,data.Diameter.REM.stdDiameter,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e5.Color = 'black';
e5.MarkerSize = 10;
e5.CapSize = 10;
ylabel('Diameter (mm)')
title('Arousal pupil diameter (mm)')
legend([s1,s2,s3,s4,s5],'Rest','Whisk','Stim','NREM','REM','Location','NorthEast')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,6])
set(gca,'box','off')
ax2.TickLength = [0.03,0.03];
%% z-unit pupil diameter during arousal states
ax3 = subplot(1,4,2);
scatter(ones(1,length(data.Diameter.Rest.zDiameter))*1,data.Diameter.Rest.zDiameter,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom rest'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.Diameter.Rest.meanzDiameter,data.Diameter.Rest.stdzDiameter,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.Diameter.Whisk.zDiameter))*2,data.Diameter.Whisk.zDiameter,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom whisk'),'jitter','on','jitterAmount',0.25);
e2 = errorbar(2,data.Diameter.Whisk.meanzDiameter,data.Diameter.Whisk.stdzDiameter,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
scatter(ones(1,length(data.Diameter.Stim.zDiameter))*3,data.Diameter.Stim.zDiameter,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom stim'),'jitter','on','jitterAmount',0.25);
e3 = errorbar(3,data.Diameter.Stim.meanzDiameter,data.Diameter.Stim.stdzDiameter,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e3.Color = 'black';
e3.MarkerSize = 10;
e3.CapSize = 10;
scatter(ones(1,length(data.Diameter.NREM.zDiameter))*4,data.Diameter.NREM.zDiameter,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom nrem'),'jitter','on','jitterAmount',0.25);
e4 = errorbar(4,data.Diameter.NREM.meanzDiameter,data.Diameter.NREM.stdzDiameter,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e4.Color = 'black';
e4.MarkerSize = 10;
e4.CapSize = 10;
scatter(ones(1,length(data.Diameter.REM.zDiameter))*5,data.Diameter.REM.zDiameter,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom rem'),'jitter','on','jitterAmount',0.25);
e5 = errorbar(5,data.Diameter.REM.meanzDiameter,data.Diameter.REM.stdzDiameter,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e5.Color = 'black';
e5.MarkerSize = 10;
e5.CapSize = 10;
ylabel('Diameter (z-units')
title('Arousal pupil diameter (z-units)')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,6])
set(gca,'box','off')
ax3.TickLength = [0.03,0.03];
%% stimulus/whisking evoked zDiameter changes
ax1 = subplot(1,4,3);
p1 = plot(timeVector,data.Evoked.interWhisk.zDiameter.mean,'color',colors('sapphire'),'LineWidth',2);
hold on
plot(timeVector,data.Evoked.interWhisk.zDiameter.mean + data.Evoked.interWhisk.zDiameter.sem,'color',colors('sapphire'),'LineWidth',0.5)
plot(timeVector,data.Evoked.interWhisk.zDiameter.mean - data.Evoked.interWhisk.zDiameter.sem,'color',colors('sapphire'),'LineWidth',0.5)
p2 = plot(timeVector,data.Evoked.stimSolenoid.zDiameter.mean,'color',colors('magenta'),'LineWidth',2);
plot(timeVector,data.Evoked.stimSolenoid.zDiameter.mean + data.Evoked.stimSolenoid.zDiameter.sem,'color',colors('magenta'),'LineWidth',0.5)
plot(timeVector,data.Evoked.stimSolenoid.zDiameter.mean - data.Evoked.stimSolenoid.zDiameter.sem,'color',colors('magenta'),'LineWidth',0.5)
p3 = plot(timeVector,data.Evoked.controlSolenoid.zDiameter.mean,'color',colors('black'),'LineWidth',2);
plot(timeVector,data.Evoked.controlSolenoid.zDiameter.mean + data.Evoked.controlSolenoid.zDiameter.sem,'color',colors('black'),'LineWidth',0.5)
plot(timeVector,data.Evoked.controlSolenoid.zDiameter.mean - data.Evoked.controlSolenoid.zDiameter.sem,'color',colors('black'),'LineWidth',0.5)
title('Evoked diameter (z-units)')
ylabel('\Deltaz-units')
xlabel('Time (s)')
legend([p1,p2,p3],'Whisk','Stim','Aud','Location','NorthEast')
set(gca,'box','off')
xlim([-2,10])
axis square
ax1.TickLength = [0.03,0.03];
%% zDiameter pupil power spectrum during arousal states
ax4 = subplot(1,4,4);
L1 = loglog(data.PreWhitenedPowerSpec.Rest.zDiameter.meanf,data.PreWhitenedPowerSpec.Rest.zDiameter.meanS,'color',colors('custom rest'),'LineWidth',2);
hold on
loglog(data.PreWhitenedPowerSpec.Rest.zDiameter.meanf,data.PreWhitenedPowerSpec.Rest.zDiameter.meanS + data.PreWhitenedPowerSpec.Rest.zDiameter.semS,'color',colors('custom rest'),'LineWidth',0.5);
loglog(data.PreWhitenedPowerSpec.Rest.zDiameter.meanf,data.PreWhitenedPowerSpec.Rest.zDiameter.meanS - data.PreWhitenedPowerSpec.Rest.zDiameter.semS,'color',colors('custom rest'),'LineWidth',0.5);
rectangle('Position',[0.004,0.00004,0.1 - 0.004,0.001],'FaceColor','w','EdgeColor','w')
L2 = loglog(data.PreWhitenedPowerSpec.NREM.zDiameter.meanf,data.PreWhitenedPowerSpec.NREM.zDiameter.meanS,'color',colors('custom nrem'),'LineWidth',2);
loglog(data.PreWhitenedPowerSpec.NREM.zDiameter.meanf,data.PreWhitenedPowerSpec.NREM.zDiameter.meanS + data.PreWhitenedPowerSpec.NREM.zDiameter.semS,'color',colors('custom nrem'),'LineWidth',0.5);
loglog(data.PreWhitenedPowerSpec.NREM.zDiameter.meanf,data.PreWhitenedPowerSpec.NREM.zDiameter.meanS - data.PreWhitenedPowerSpec.NREM.zDiameter.semS,'color',colors('custom nrem'),'LineWidth',0.5);
rectangle('Position',[0.004,0.00004,1/30 - 0.004,0.001],'FaceColor','w','EdgeColor','w')
L3 = loglog(data.PreWhitenedPowerSpec.REM.zDiameter.meanf,data.PreWhitenedPowerSpec.REM.zDiameter.meanS,'color',colors('custom rem'),'LineWidth',2);
loglog(data.PreWhitenedPowerSpec.REM.zDiameter.meanf,data.PreWhitenedPowerSpec.REM.zDiameter.meanS + data.PreWhitenedPowerSpec.REM.zDiameter.semS,'color',colors('custom rem'),'LineWidth',0.5);
loglog(data.PreWhitenedPowerSpec.REM.zDiameter.meanf,data.PreWhitenedPowerSpec.REM.zDiameter.meanS - data.PreWhitenedPowerSpec.REM.zDiameter.semS,'color',colors('custom rem'),'LineWidth',0.5);
rectangle('Position',[0.004,0.00004,1/60 - 0.004,0.001],'FaceColor','w','EdgeColor','w')
L4 = loglog(data.PreWhitenedPowerSpec.Alert.zDiameter.meanf,data.PreWhitenedPowerSpec.Alert.zDiameter.meanS,'color',colors('custom alert'),'LineWidth',2);
loglog(data.PreWhitenedPowerSpec.Alert.zDiameter.meanf,data.PreWhitenedPowerSpec.Alert.zDiameter.meanS + data.PreWhitenedPowerSpec.Alert.zDiameter.semS,'color',colors('custom alert'),'LineWidth',0.5);
loglog(data.PreWhitenedPowerSpec.Alert.zDiameter.meanf,data.PreWhitenedPowerSpec.Alert.zDiameter.meanS - data.PreWhitenedPowerSpec.Alert.zDiameter.semS,'color',colors('custom alert'),'LineWidth',0.5);
L5 = loglog(data.PreWhitenedPowerSpec.Asleep.zDiameter.meanf,data.PreWhitenedPowerSpec.Asleep.zDiameter.meanS,'color',colors('custom asleep'),'LineWidth',2);
loglog(data.PreWhitenedPowerSpec.Asleep.zDiameter.meanf,data.PreWhitenedPowerSpec.Asleep.zDiameter.meanS + data.PreWhitenedPowerSpec.Asleep.zDiameter.semS,'color',colors('custom asleep'),'LineWidth',0.5);
loglog(data.PreWhitenedPowerSpec.Asleep.zDiameter.meanf,data.PreWhitenedPowerSpec.Asleep.zDiameter.meanS - data.PreWhitenedPowerSpec.Asleep.zDiameter.semS,'color',colors('custom asleep'),'LineWidth',0.5);
L6 = loglog(data.PreWhitenedPowerSpec.All.zDiameter.meanf,data.PreWhitenedPowerSpec.All.zDiameter.meanS,'color',colors('custom all'),'LineWidth',2);
loglog(data.PreWhitenedPowerSpec.All.zDiameter.meanf,data.PreWhitenedPowerSpec.All.zDiameter.meanS + data.PreWhitenedPowerSpec.All.zDiameter.semS,'color',colors('custom all'),'LineWidth',0.5);
loglog(data.PreWhitenedPowerSpec.All.zDiameter.meanf,data.PreWhitenedPowerSpec.All.zDiameter.meanS - data.PreWhitenedPowerSpec.All.zDiameter.semS,'color',colors('custom all'),'LineWidth',0.5);
xline(1/10)
xline(1/30)
xline(1/60)
title('Diameter power spectrum')
ylabel('Pre-whitened power (a.u.)')
xlabel('Freq (Hz)')
legend([L1,L2,L3,L4,L5,L6],'Rest','NREM','REM','Alert','Asleep','All','Location','NorthWest')
axis square
xlim([0.003,1])
ylim([0.000035,0.0012])
set(gca,'box','off')
ax4.TickLength = [0.03,0.03];
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'MATLAB Figures' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig2,[dirpath 'Fig2_Turner2022']);
    set(Fig2,'PaperPositionMode','auto');
    print('-vector','-dpdf','-bestfit',[dirpath 'Fig2_Turner2022'])
    % text diary
    diaryFile = [dirpath 'Fig2_Text.txt'];
    if exist(diaryFile,'file') == 2
        delete(diaryFile)
    end
    diary(diaryFile)
    diary on
    % mm diameter statistical diary
    disp('======================================================================================================================')
    disp('GLME stats for mm diameter during Rest, Whisk, Stim, NREM, and REM')
    disp('======================================================================================================================')
    disp(mmDiameterStats)
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Rest  diameter (mm): ' num2str(round(data.Diameter.Rest.meanDiameter,2)) ' ± ' num2str(round(data.Diameter.Whisk.stdDiameter,2)) ' (n = ' num2str(length(data.Diameter.Rest.mmDiameter)) ') mice']); disp(' ')
    disp(['Whisk diameter (mm): ' num2str(round(data.Diameter.Whisk.meanDiameter,2)) ' ± ' num2str(round(data.Diameter.Whisk.stdDiameter,2)) ' (n = ' num2str(length(data.Diameter.Whisk.mmDiameter)) ') mice']); disp(' ')
    disp(['Stim  diameter (mm): ' num2str(round(data.Diameter.Stim.meanDiameter,2)) ' ± ' num2str(round(data.Diameter.Stim.stdDiameter,2)) ' (n = ' num2str(length(data.Diameter.Stim.mmDiameter)) ') mice']); disp(' ')
    disp(['NREM  diameter (mm): ' num2str(round(data.Diameter.NREM.meanDiameter,2)) ' ± ' num2str(round(data.Diameter.NREM.stdDiameter,2)) ' (n = ' num2str(length(data.Diameter.NREM.mmDiameter)) ') mice']); disp(' ')
    disp(['REM   diameter (mm): ' num2str(round(data.Diameter.REM.meanDiameter,2)) ' ± ' num2str(round(data.Diameter.REM.stdDiameter,2)) ' (n = ' num2str(length(data.Diameter.REM.mmDiameter)) ') mice']); disp(' ')
    disp(['*p < ' num2str(alpha10A) ' **p < ' num2str(alpha10B) ' ***p < ' num2str(alpha10C)]);
    disp(mmTable)
    disp('----------------------------------------------------------------------------------------------------------------------')
    % z-unit Diameter statistical diary
    disp('======================================================================================================================')
    disp('GLME stats for z-unit diameter during Rest, Whisk, Stim, NREM, and REM')
    disp('======================================================================================================================')
    disp(zDiameterStats)
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Rest  diameter (z-unit): ' num2str(round(data.Diameter.Rest.meanzDiameter,2)) ' ± ' num2str(round(data.Diameter.Whisk.stdzDiameter,2)) ' (n = ' num2str(length(data.Diameter.Rest.zDiameter)) ') mice']); disp(' ')
    disp(['Whisk diameter (z-unit): ' num2str(round(data.Diameter.Whisk.meanzDiameter,2)) ' ± ' num2str(round(data.Diameter.Whisk.stdzDiameter,2)) ' (n = ' num2str(length(data.Diameter.Whisk.zDiameter)) ') mice']); disp(' ')
    disp(['Stim  diameter (z-unit): ' num2str(round(data.Diameter.Stim.meanzDiameter,2)) ' ± ' num2str(round(data.Diameter.Stim.stdzDiameter,2)) ' (n = ' num2str(length(data.Diameter.Stim.zDiameter)) ') mice']); disp(' ')
    disp(['NREM  diameter (z-unit): ' num2str(round(data.Diameter.NREM.meanzDiameter,2)) ' ± ' num2str(round(data.Diameter.NREM.stdzDiameter,2)) ' (n = ' num2str(length(data.Diameter.NREM.zDiameter)) ') mice']); disp(' ')
    disp(['REM   diameter (z-unit): ' num2str(round(data.Diameter.REM.meanzDiameter,2)) ' ± ' num2str(round(data.Diameter.REM.stdzDiameter,2)) ' (n = ' num2str(length(data.Diameter.REM.zDiameter)) ') mice']); disp(' ')
    disp(['*p < ' num2str(alpha10A) ' **p < ' num2str(alpha10B) ' ***p < ' num2str(alpha10C)]);
    disp(zTable)
    disp('----------------------------------------------------------------------------------------------------------------------')
    % peak whisk/stim
    disp('======================================================================================================================')
    disp('Peak change in z-unit post-stimulation/whisking')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Whisker stimulation z-unit increase ' num2str(data.Evoked.stimSolenoid.zDiameter.meanPeak) ' ± ' num2str(data.Evoked.stimSolenoid.zDiameter.stdPeak) ' (n = ' num2str(length(data.Evoked.stimSolenoid.zDiameter.peak)/2) ') mice']); disp(' ')
    disp(['Auditory stimulation z-unit increase ' num2str(data.Evoked.controlSolenoid.zDiameter.meanPeak) ' ± ' num2str(data.Evoked.controlSolenoid.zDiameter.stdPeak) ' (n = ' num2str(length(data.Evoked.controlSolenoid.zDiameter.peak)) ') mice']); disp(' ')
    disp(['Volitional whisking z-unit increase ' num2str(data.Evoked.interWhisk.zDiameter.meanPeak) ' ± ' num2str(data.Evoked.interWhisk.zDiameter.stdPeak) ' (n = ' num2str(length(data.Evoked.interWhisk.zDiameter.peak)) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    diary off
end
cd(rootFolder)
end
