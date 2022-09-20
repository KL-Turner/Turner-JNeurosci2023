clear; clc;
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
HbTC002Table = table('Size',[size(HbTC002TableSize,1),3],'VariableTypes',{'string','string','double'},'VariableNames',{'Mouse','Behavior','HbTC002'});
HbTC002Table.Mouse = cat(1,data.Coherr.Alert.zDiameter.animalID,data.Coherr.Asleep.zDiameter.animalID,data.Coherr.All.zDiameter.animalID);
HbTC002Table.Behavior = cat(1,data.Coherr.Alert.zDiameter.behavField,data.Coherr.Asleep.zDiameter.behavField,data.Coherr.All.zDiameter.behavField);
HbTC002Table.HbTC002 = cat(1,data.Coherr.Alert.zDiameter.HbTC002,data.Coherr.Asleep.zDiameter.HbTC002,data.Coherr.All.zDiameter.HbTC002);
HbTC002FitFormula = 'HbTC002 ~ 1 + Behavior + (1|Mouse)';
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
HbTC002Table = table(array2table(HbTC002X,'VariableNames',{'Alert';'Asleep';'All'}),'RowNames',state);

%% statistics - generalized linear mixed effects model (0.02 gamma coherence)
gammaC002TableSize = cat(1,data.Coherr.Alert.zDiameter.gammaC002,data.Coherr.Asleep.zDiameter.gammaC002,data.Coherr.All.zDiameter.gammaC002);
gammaC002Table = table('Size',[size(gammaC002TableSize,1),3],'VariableTypes',{'string','string','double'},'VariableNames',{'Mouse','Behavior','gammaC002'});
gammaC002Table.Mouse = cat(1,data.Coherr.Alert.zDiameter.animalID,data.Coherr.Asleep.zDiameter.animalID,data.Coherr.All.zDiameter.animalID);
gammaC002Table.Behavior = cat(1,data.Coherr.Alert.zDiameter.behavField,data.Coherr.Asleep.zDiameter.behavField,data.Coherr.All.zDiameter.behavField);
gammaC002Table.gammaC002 = cat(1,data.Coherr.Alert.zDiameter.gammaC002,data.Coherr.Asleep.zDiameter.gammaC002,data.Coherr.All.zDiameter.gammaC002);
gammaC002FitFormula = 'gammaC002 ~ 1 + Behavior + (1|Mouse)';
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
gammaC002Table = table(array2table(gammaC002X,'VariableNames',{'Alert';'Asleep';'All'}),'RowNames',state);

%% statistics - generalized linear mixed effects model (0.35 HbT coherence)
HbTC035TableSize = cat(1,data.Coherr.Rest.zDiameter.HbTC035,data.Coherr.NREM.zDiameter.HbTC035,data.Coherr.REM.zDiameter.HbTC035,data.Coherr.Alert.zDiameter.HbTC035,data.Coherr.Asleep.zDiameter.HbTC035,data.Coherr.All.zDiameter.HbTC035);
HbTC035Table = table('Size',[size(HbTC035TableSize,1),3],'VariableTypes',{'string','string','double'},'VariableNames',{'Mouse','Behavior','HbTC035'});
HbTC035Table.Mouse = cat(1,data.Coherr.Rest.zDiameter.animalID,data.Coherr.NREM.zDiameter.animalID,data.Coherr.REM.zDiameter.animalID,data.Coherr.Alert.zDiameter.animalID,data.Coherr.Asleep.zDiameter.animalID,data.Coherr.All.zDiameter.animalID);
HbTC035Table.Behavior = cat(1,data.Coherr.Rest.zDiameter.behavField,data.Coherr.NREM.zDiameter.behavField,data.Coherr.REM.zDiameter.behavField,data.Coherr.Alert.zDiameter.behavField,data.Coherr.Asleep.zDiameter.behavField,data.Coherr.All.zDiameter.behavField);
HbTC035Table.HbTC035 = cat(1,data.Coherr.Rest.zDiameter.HbTC035,data.Coherr.NREM.zDiameter.HbTC035,data.Coherr.REM.zDiameter.HbTC035,data.Coherr.Alert.zDiameter.HbTC035,data.Coherr.Asleep.zDiameter.HbTC035,data.Coherr.All.zDiameter.HbTC035);
HbTC035FitFormula = 'HbTC035 ~ 1 + Behavior + (1|Mouse)';
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
HbTC035Table = table(array2table(HbTC035X,'VariableNames',{'Rest';'NREM';'REM';'Alert';'Asleep';'All'}),'RowNames',state);

%% statistics - generalized linear mixed effects model (0.02 HbT coherence)
gammaC035TableSize = cat(1,data.Coherr.Rest.zDiameter.gammaC035,data.Coherr.NREM.zDiameter.gammaC035,data.Coherr.REM.zDiameter.gammaC035,data.Coherr.Alert.zDiameter.gammaC035,data.Coherr.Asleep.zDiameter.gammaC035,data.Coherr.All.zDiameter.gammaC035);
gammaC035Table = table('Size',[size(gammaC035TableSize,1),3],'VariableTypes',{'string','string','double'},'VariableNames',{'Mouse','Behavior','gammaC035'});
gammaC035Table.Mouse = cat(1,data.Coherr.Rest.zDiameter.animalID,data.Coherr.NREM.zDiameter.animalID,data.Coherr.REM.zDiameter.animalID,data.Coherr.Alert.zDiameter.animalID,data.Coherr.Asleep.zDiameter.animalID,data.Coherr.All.zDiameter.animalID);
gammaC035Table.Behavior = cat(1,data.Coherr.Rest.zDiameter.behavField,data.Coherr.NREM.zDiameter.behavField,data.Coherr.REM.zDiameter.behavField,data.Coherr.Alert.zDiameter.behavField,data.Coherr.Asleep.zDiameter.behavField,data.Coherr.All.zDiameter.behavField);
gammaC035Table.gammaC035 = cat(1,data.Coherr.Rest.zDiameter.gammaC035,data.Coherr.NREM.zDiameter.gammaC035,data.Coherr.REM.zDiameter.gammaC035,data.Coherr.Alert.zDiameter.gammaC035,data.Coherr.Asleep.zDiameter.gammaC035,data.Coherr.All.zDiameter.gammaC035);
gammaC035FitFormula = 'gammaC035 ~ 1 + Behavior + (1|Mouse)';
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
gammaC035Table = table(array2table(gammaC035X,'VariableNames',{'Rest';'NREM';'REM';'Alert';'Asleep';'All'}),'RowNames',state);

%% bonferroni adjusted alphas
comparisons = 3;
alpha3A = 0.05/comparisons;
alpha3B = 0.01/comparisons;
alpha3C = 0.001/comparisons;
comparisons = 10;
alpha10A = 0.05/comparisons;
alpha10B = 0.01/comparisons;
alpha10C = 0.001/comparisons;
comparisons = 15;
alpha15A = 0.05/comparisons;
alpha15B = 0.01/comparisons;
alpha15C = 0.001/comparisons;

%% save figure(s)
% text diary
diaryFile = 'StatsDemo_Text.txt';
if exist(diaryFile,'file') == 2
    delete(diaryFile)
end
diary(diaryFile)
diary on
% mm diameter statistical diary
disp('======================================================================================================================')
disp('GLME stats for mm diameter during Rest, Whisk, Stim, NREM, and REM')
disp('======================================================================================================================')
disp(mmDiameterStats); disp(' ')
disp(['Rest  diameter (mm): ' num2str(round(data.Diameter.Rest.meanDiameter,2)) ' ± ' num2str(round(data.Diameter.Whisk.stdDiameter,2)) ' (n = ' num2str(length(data.Diameter.Rest.mmDiameter)) ') mice']); disp(' ')
disp(['Whisk diameter (mm): ' num2str(round(data.Diameter.Whisk.meanDiameter,2)) ' ± ' num2str(round(data.Diameter.Whisk.stdDiameter,2)) ' (n = ' num2str(length(data.Diameter.Whisk.mmDiameter)) ') mice']); disp(' ')
disp(['Stim  diameter (mm): ' num2str(round(data.Diameter.Stim.meanDiameter,2)) ' ± ' num2str(round(data.Diameter.Stim.stdDiameter,2)) ' (n = ' num2str(length(data.Diameter.Stim.mmDiameter)) ') mice']); disp(' ')
disp(['NREM  diameter (mm): ' num2str(round(data.Diameter.NREM.meanDiameter,2)) ' ± ' num2str(round(data.Diameter.NREM.stdDiameter,2)) ' (n = ' num2str(length(data.Diameter.NREM.mmDiameter)) ') mice']); disp(' ')
disp(['REM   diameter (mm): ' num2str(round(data.Diameter.REM.meanDiameter,2)) ' ± ' num2str(round(data.Diameter.REM.stdDiameter,2)) ' (n = ' num2str(length(data.Diameter.REM.mmDiameter)) ') mice']); disp(' ')
disp(['*p < ' num2str(alpha10A) ' **p < ' num2str(alpha10B) ' ***p < ' num2str(alpha10C)]); disp(' ')
disp(mmTable); disp(' ')
% z-unit Diameter statistical diary
disp('======================================================================================================================')
disp('GLME stats for z-unit diameter during Rest, Whisk, Stim, NREM, and REM')
disp('======================================================================================================================')
disp(zDiameterStats); disp(' ')
disp(['Rest  diameter (z-unit): ' num2str(round(data.Diameter.Rest.meanzDiameter,2)) ' ± ' num2str(round(data.Diameter.Whisk.stdzDiameter,2)) ' (n = ' num2str(length(data.Diameter.Rest.zDiameter)) ') mice']); disp(' ')
disp(['Whisk diameter (z-unit): ' num2str(round(data.Diameter.Whisk.meanzDiameter,2)) ' ± ' num2str(round(data.Diameter.Whisk.stdzDiameter,2)) ' (n = ' num2str(length(data.Diameter.Whisk.zDiameter)) ') mice']); disp(' ')
disp(['Stim  diameter (z-unit): ' num2str(round(data.Diameter.Stim.meanzDiameter,2)) ' ± ' num2str(round(data.Diameter.Stim.stdzDiameter,2)) ' (n = ' num2str(length(data.Diameter.Stim.zDiameter)) ') mice']); disp(' ')
disp(['NREM  diameter (z-unit): ' num2str(round(data.Diameter.NREM.meanzDiameter,2)) ' ± ' num2str(round(data.Diameter.NREM.stdzDiameter,2)) ' (n = ' num2str(length(data.Diameter.NREM.zDiameter)) ') mice']); disp(' ')
disp(['REM   diameter (z-unit): ' num2str(round(data.Diameter.REM.meanzDiameter,2)) ' ± ' num2str(round(data.Diameter.REM.stdzDiameter,2)) ' (n = ' num2str(length(data.Diameter.REM.zDiameter)) ') mice']); disp(' ')
disp(['*p < ' num2str(alpha10A) ' **p < ' num2str(alpha10B) ' ***p < ' num2str(alpha10C)]); disp(' ')
disp(zTable); disp(' ')
% coherence between pupil diameter and HbT @ 0.35 Hz
disp('======================================================================================================================')
disp('GLME stats for z-unit diameter vs. HbT coherence during Rest, NREM, REM, Alert, Asleep, All @ 0.35 Hz')
disp('======================================================================================================================')
disp(HbTC035Stats); disp(' ')
disp(['Rest   [HbT]-pupil coherence: ' num2str(round(data.Coherr.Rest.zDiameter.meanHbTC035,2)) ' ± ' num2str(round(data.Coherr.Rest.zDiameter.stdHbTC035,2)) ' (n = ' num2str(length(data.Coherr.Rest.zDiameter.HbTC035)/2) ') mice']); disp(' ')
disp(['NREM   [HbT]-pupil coherence: ' num2str(round(data.Coherr.NREM.zDiameter.meanHbTC035,2)) ' ± ' num2str(round(data.Coherr.NREM.zDiameter.stdHbTC035,2)) ' (n = ' num2str(length(data.Coherr.NREM.zDiameter.HbTC035)/2) ') mice']); disp(' ')
disp(['REM    [HbT]-pupil coherence: ' num2str(round(data.Coherr.REM.zDiameter.meanHbTC035,2)) ' ± ' num2str(round(data.Coherr.REM.zDiameter.stdHbTC035,2)) ' (n = ' num2str(length(data.Coherr.REM.zDiameter.HbTC035)/2) ') mice']); disp(' ')
disp(['Alert  [HbT]-pupil coherence: ' num2str(round(data.Coherr.Alert.zDiameter.meanHbTC035,2)) ' ± ' num2str(round(data.Coherr.Alert.zDiameter.stdHbTC035,2)) ' (n = ' num2str(length(data.Coherr.Alert.zDiameter.HbTC035)/2) ') mice']); disp(' ')
disp(['Asleep [HbT]-pupil coherence: ' num2str(round(data.Coherr.Asleep.zDiameter.meanHbTC035,2)) ' ± ' num2str(round(data.Coherr.Asleep.zDiameter.stdHbTC035,2)) ' (n = ' num2str(length(data.Coherr.Asleep.zDiameter.HbTC035)/2) ') mice']); disp(' ')
disp(['All    [HbT]-pupil coherence: ' num2str(round(data.Coherr.All.zDiameter.meanHbTC035,2)) ' ± ' num2str(round(data.Coherr.All.zDiameter.stdHbTC035,2)) ' (n = ' num2str(length(data.Coherr.All.zDiameter.HbTC035)/2) ') mice']); disp(' ')
disp(['*p < ' num2str(alpha15A) ' **p < ' num2str(alpha15B) ' ***p < ' num2str(alpha15C)]); disp(' ')
disp(HbTC035Table); disp(' ')
disp('----------------------------------------------------------------------------------------------------------------------')
% coherence between pupil diameter and HbT @ 0.02 Hz
disp('======================================================================================================================')
disp('GLME stats for z-unit diameter vs. HbT coherence during Rest, NREM, REM, Alert, Asleep, All @ 0.02 Hz')
disp('======================================================================================================================')
disp(HbTC002Stats); disp(' ')
disp(['Alert  [HbT]-pupil coherence: ' num2str(round(data.Coherr.Alert.zDiameter.meanHbTC002,2)) ' ± ' num2str(round(data.Coherr.Alert.zDiameter.stdHbTC002,2)) ' (n = ' num2str(length(data.Coherr.Alert.zDiameter.HbTC002)/2) ') mice']); disp(' ')
disp(['Asleep [HbT]-pupil coherence: ' num2str(round(data.Coherr.Asleep.zDiameter.meanHbTC002,2)) ' ± ' num2str(round(data.Coherr.Asleep.zDiameter.stdHbTC002,2)) ' (n = ' num2str(length(data.Coherr.Asleep.zDiameter.HbTC002)/2) ') mice']); disp(' ')
disp(['All    [HbT]-pupil coherence: ' num2str(round(data.Coherr.All.zDiameter.meanHbTC002,2)) ' ± ' num2str(round(data.Coherr.All.zDiameter.stdHbTC002,2)) ' (n = ' num2str(length(data.Coherr.All.zDiameter.HbTC002)/2) ') mice']); disp(' ')
disp(['*p < ' num2str(alpha3A) ' **p < ' num2str(alpha3B) ' ***p < ' num2str(alpha3C)]); disp(' ')
disp(HbTC002Table); disp(' ')
% coherence between pupil diameter and gamma @ 0.35 Hz
disp('======================================================================================================================')
disp('GLME stats for z-unit diameter vs. Gamma coherence during Rest, NREM, REM, Alert, Asleep, All @ 0.35 Hz')
disp('======================================================================================================================')
disp(gammaC035Stats); disp(' ')
disp('----------------------------------------------------------------------------------------------------------------------')
disp(['Rest   Gamma-pupil coherence: ' num2str(round(data.Coherr.Rest.zDiameter.meanGammaC035,2)) ' ± ' num2str(round(data.Coherr.Rest.zDiameter.stdGammaC035,2)) ' (n = ' num2str(length(data.Coherr.Rest.zDiameter.gammaC035)/2) ') mice']); disp(' ')
disp(['NREM   Gamma-pupil coherence: ' num2str(round(data.Coherr.NREM.zDiameter.meanGammaC035,2)) ' ± ' num2str(round(data.Coherr.NREM.zDiameter.stdGammaC035,2)) ' (n = ' num2str(length(data.Coherr.NREM.zDiameter.gammaC035)/2) ') mice']); disp(' ')
disp(['REM    Gamma-pupil coherence: ' num2str(round(data.Coherr.REM.zDiameter.meanGammaC035,2)) ' ± ' num2str(round(data.Coherr.REM.zDiameter.stdGammaC035,2)) ' (n = ' num2str(length(data.Coherr.REM.zDiameter.gammaC035)/2) ') mice']); disp(' ')
disp(['Alert  Gamma-pupil coherence: ' num2str(round(data.Coherr.Alert.zDiameter.meanGammaC035,2)) ' ± ' num2str(round(data.Coherr.Alert.zDiameter.stdGammaC035,2)) ' (n = ' num2str(length(data.Coherr.Alert.zDiameter.gammaC035)/2) ') mice']); disp(' ')
disp(['Asleep Gamma-pupil coherence: ' num2str(round(data.Coherr.Asleep.zDiameter.meanGammaC035,2)) ' ± ' num2str(round(data.Coherr.Asleep.zDiameter.stdGammaC035,2)) ' (n = ' num2str(length(data.Coherr.Asleep.zDiameter.gammaC035)/2) ') mice']); disp(' ')
disp(['All    Gamma-pupil coherence: ' num2str(round(data.Coherr.All.zDiameter.meanGammaC035,2)) ' ± ' num2str(round(data.Coherr.All.zDiameter.stdGammaC035,2)) ' (n = ' num2str(length(data.Coherr.All.zDiameter.gammaC035)/2) ') mice']); disp(' ')
disp(['*p < ' num2str(alpha15A) ' **p < ' num2str(alpha15B) ' ***p < ' num2str(alpha15C)]); disp(' ')
disp(gammaC035Table); disp(' ')
% coherence between pupil diameter and gamma @ 0.02 Hz
disp('======================================================================================================================')
disp('GLME stats for z-unit diameter vs. Gamma coherence during Alert, Asleep, All @ 0.02 Hz')
disp('======================================================================================================================')
disp(gammaC002Stats); disp(' ')
disp(['Alert  Gamma-pupil coherence: ' num2str(round(data.Coherr.Alert.zDiameter.meanGammaC002,2)) ' ± ' num2str(round(data.Coherr.Alert.zDiameter.stdGammaC002,2)) ' (n = ' num2str(length(data.Coherr.Alert.zDiameter.gammaC002)/2) ') mice']); disp(' ')
disp(['Asleep Gamma-pupil coherence: ' num2str(round(data.Coherr.Asleep.zDiameter.meanGammaC002,2)) ' ± ' num2str(round(data.Coherr.Asleep.zDiameter.stdGammaC002,2)) ' (n = ' num2str(length(data.Coherr.Asleep.zDiameter.gammaC002)/2) ') mice']); disp(' ')
disp(['All    Gamma-pupil coherence: ' num2str(round(data.Coherr.All.zDiameter.meanGammaC002,2)) ' ± ' num2str(round(data.Coherr.All.zDiameter.stdGammaC002,2)) ' (n = ' num2str(length(data.Coherr.All.zDiameter.gammaC002)/2) ') mice']); disp(' ')
disp(['*p < ' num2str(alpha3A) ' **p < ' num2str(alpha3B) ' ***p < ' num2str(alpha3C)]); disp(' ')
disp(gammaC002Table); disp(' ')
diary off

