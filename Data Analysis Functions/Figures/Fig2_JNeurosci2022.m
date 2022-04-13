function [] = Fig2_JNeurosci2022(rootFolder,saveFigs,delim)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Generate figures and supporting information for Figure Panel 2
%________________________________________________________________________________________________________________________

%% stimulus and whisking evoked pupil changes
resultsStruct = 'Results_Evoked';
load(resultsStruct);
dataTypes = {'mmArea','mmDiameter','zArea','zDiameter'};
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
% statistics - generalized linear mixed effects model (mm diameter)
mmDiameterTableSize = cat(1,data.Diameter.Rest.mmDiameter,data.Diameter.Whisk.mmDiameter,data.Diameter.Stim.mmDiameter,data.Diameter.NREM.mmDiameter,data.Diameter.REM.mmDiameter);
mmDiameterTable = table('Size',[size(mmDiameterTableSize,1),3],'VariableTypes',{'string','string','double'},'VariableNames',{'Mouse','Behavior','mmDiameter'});
mmDiameterTable.Mouse = cat(1,data.Diameter.Rest.animalID,data.Diameter.Whisk.animalID,data.Diameter.Stim.animalID,data.Diameter.NREM.animalID,data.Diameter.REM.animalID);
mmDiameterTable.Behavior = cat(1,data.Diameter.Rest.behavField,data.Diameter.Whisk.behavField,data.Diameter.Stim.behavField,data.Diameter.NREM.behavField,data.Diameter.REM.behavField);
mmDiameterTable.mmDiameter = cat(1,data.Diameter.Rest.mmDiameter,data.Diameter.Whisk.mmDiameter,data.Diameter.Stim.mmDiameter,data.Diameter.NREM.mmDiameter,data.Diameter.REM.mmDiameter);
mmDiameterFitFormula = 'mmDiameter ~ 1 + Behavior + (1|Mouse)';
mmDiameterStats = fitglme(mmDiameterTable,mmDiameterFitFormula);
% statistics - generalized linear mixed effects model (z-units)
zDiameterTableSize = cat(1,data.Diameter.Rest.zDiameter,data.Diameter.Whisk.zDiameter,data.Diameter.Stim.zDiameter,data.Diameter.NREM.zDiameter,data.Diameter.REM.zDiameter);
zDiameterTable = table('Size',[size(zDiameterTableSize,1),3],'VariableTypes',{'string','string','double'},'VariableNames',{'Mouse','Behavior','zDiameter'});
zDiameterTable.Mouse = cat(1,data.Diameter.Rest.animalID,data.Diameter.Whisk.animalID,data.Diameter.Stim.animalID,data.Diameter.NREM.animalID,data.Diameter.REM.animalID);
zDiameterTable.Behavior = cat(1,data.Diameter.Rest.behavField,data.Diameter.Whisk.behavField,data.Diameter.Stim.behavField,data.Diameter.NREM.behavField,data.Diameter.REM.behavField);
zDiameterTable.zDiameter = cat(1,data.Diameter.Rest.zDiameter,data.Diameter.Whisk.zDiameter,data.Diameter.Stim.zDiameter,data.Diameter.NREM.zDiameter,data.Diameter.REM.zDiameter);
zDiameterFitFormula = 'zDiameter ~ 1 + Behavior + (1|Mouse)';
zDiameterStats = fitglme(zDiameterTable,zDiameterFitFormula);
%% pupil power spectrum
resultsStruct = 'Results_PowerSpectrum';
load(resultsStruct);
animalIDs = fieldnames(Results_PowerSpectrum);
behavFields = {'Rest','NREM','REM','Awake','Asleep','All'};
dataTypes = {'mmArea','mmDiameter','zArea','zDiameter'};
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
resultsStruct = 'Results_PreWhitenedPowerSpectrum';
load(resultsStruct);
animalIDs = fieldnames(Results_PreWhitenedPowerSpectrum);
behavFields = {'Rest','NREM','REM','Awake','Asleep','All'};
dataTypes = {'mmArea','mmDiameter','zArea','zDiameter'};
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
%% pupil HbT/gamma-band coherence
resultsStruct = 'Results_Coherence';
load(resultsStruct);
animalIDs = fieldnames(Results_Coherence);
behavFields = {'Rest','NREM','REM','Awake','Asleep','All'};
dataTypes = {'mmArea','mmDiameter','zArea','zDiameter'};
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
                gammaC = data.Coherr.(behavField).(dataType).HbTC(:,gg);
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
% statistics - generalized linear mixed effects model (0.02 HbT coherence)
HbTC002TableSize = cat(1,data.Coherr.Awake.zDiameter.HbTC002,data.Coherr.Asleep.zDiameter.HbTC002,data.Coherr.All.zDiameter.HbTC002);
HbTC002Table = table('Size',[size(HbTC002TableSize,1),3],'VariableTypes',{'string','string','double'},'VariableNames',{'Mouse','Behavior','HbTC002'});
HbTC002Table.Mouse = cat(1,data.Coherr.Awake.zDiameter.animalID,data.Coherr.Asleep.zDiameter.animalID,data.Coherr.All.zDiameter.animalID);
HbTC002Table.Behavior = cat(1,data.Coherr.Awake.zDiameter.behavField,data.Coherr.Asleep.zDiameter.behavField,data.Coherr.All.zDiameter.behavField);
HbTC002Table.HbTC002 = cat(1,data.Coherr.Awake.zDiameter.HbTC002,data.Coherr.Asleep.zDiameter.HbTC002,data.Coherr.All.zDiameter.HbTC002);
HbTC002FitFormula = 'HbTC002 ~ 1 + Behavior + (1|Mouse)';
HbTC002Stats = fitglme(HbTC002Table,HbTC002FitFormula);
% statistics - generalized linear mixed effects model (0.02 gamma coherence)
gammaC002TableSize = cat(1,data.Coherr.Awake.zDiameter.gammaC002,data.Coherr.Asleep.zDiameter.gammaC002,data.Coherr.All.zDiameter.gammaC002);
gammaC002Table = table('Size',[size(gammaC002TableSize,1),3],'VariableTypes',{'string','string','double'},'VariableNames',{'Mouse','Behavior','gammaC002'});
gammaC002Table.Mouse = cat(1,data.Coherr.Awake.zDiameter.animalID,data.Coherr.Asleep.zDiameter.animalID,data.Coherr.All.zDiameter.animalID);
gammaC002Table.Behavior = cat(1,data.Coherr.Awake.zDiameter.behavField,data.Coherr.Asleep.zDiameter.behavField,data.Coherr.All.zDiameter.behavField);
gammaC002Table.gammaC002 = cat(1,data.Coherr.Awake.zDiameter.gammaC002,data.Coherr.Asleep.zDiameter.gammaC002,data.Coherr.All.zDiameter.gammaC002);
gammaC002FitFormula = 'gammaC002 ~ 1 + Behavior + (1|Mouse)';
gammaC002Stats = fitglme(gammaC002Table,gammaC002FitFormula);
% statistics - generalized linear mixed effects model (0.35 HbT coherence)
HbTC035TableSize = cat(1,data.Coherr.Rest.zDiameter.HbTC035,data.Coherr.NREM.zDiameter.HbTC035,data.Coherr.REM.zDiameter.HbTC035,data.Coherr.Awake.zDiameter.HbTC035,data.Coherr.Asleep.zDiameter.HbTC035,data.Coherr.All.zDiameter.HbTC035);
HbTC035Table = table('Size',[size(HbTC035TableSize,1),3],'VariableTypes',{'string','string','double'},'VariableNames',{'Mouse','Behavior','HbTC035'});
HbTC035Table.Mouse = cat(1,data.Coherr.Rest.zDiameter.animalID,data.Coherr.NREM.zDiameter.animalID,data.Coherr.REM.zDiameter.animalID,data.Coherr.Awake.zDiameter.animalID,data.Coherr.Asleep.zDiameter.animalID,data.Coherr.All.zDiameter.animalID);
HbTC035Table.Behavior = cat(1,data.Coherr.Rest.zDiameter.behavField,data.Coherr.NREM.zDiameter.behavField,data.Coherr.REM.zDiameter.behavField,data.Coherr.Awake.zDiameter.behavField,data.Coherr.Asleep.zDiameter.behavField,data.Coherr.All.zDiameter.behavField);
HbTC035Table.HbTC035 = cat(1,data.Coherr.Rest.zDiameter.HbTC035,data.Coherr.NREM.zDiameter.HbTC035,data.Coherr.REM.zDiameter.HbTC035,data.Coherr.Awake.zDiameter.HbTC035,data.Coherr.Asleep.zDiameter.HbTC035,data.Coherr.All.zDiameter.HbTC035);
HbTC035FitFormula = 'HbTC035 ~ 1 + Behavior + (1|Mouse)';
HbTC035Stats = fitglme(HbTC035Table,HbTC035FitFormula);
% statistics - generalized linear mixed effects model (0.02 HbT coherence)
gammaC035TableSize = cat(1,data.Coherr.Rest.zDiameter.gammaC035,data.Coherr.NREM.zDiameter.gammaC035,data.Coherr.REM.zDiameter.gammaC035,data.Coherr.Awake.zDiameter.gammaC035,data.Coherr.Asleep.zDiameter.gammaC035,data.Coherr.All.zDiameter.gammaC035);
gammaC035Table = table('Size',[size(gammaC035TableSize,1),3],'VariableTypes',{'string','string','double'},'VariableNames',{'Mouse','Behavior','gammaC035'});
gammaC035Table.Mouse = cat(1,data.Coherr.Rest.zDiameter.animalID,data.Coherr.NREM.zDiameter.animalID,data.Coherr.REM.zDiameter.animalID,data.Coherr.Awake.zDiameter.animalID,data.Coherr.Asleep.zDiameter.animalID,data.Coherr.All.zDiameter.animalID);
gammaC035Table.Behavior = cat(1,data.Coherr.Rest.zDiameter.behavField,data.Coherr.NREM.zDiameter.behavField,data.Coherr.REM.zDiameter.behavField,data.Coherr.Awake.zDiameter.behavField,data.Coherr.Asleep.zDiameter.behavField,data.Coherr.All.zDiameter.behavField);
gammaC035Table.gammaC035 = cat(1,data.Coherr.Rest.zDiameter.gammaC035,data.Coherr.NREM.zDiameter.gammaC035,data.Coherr.REM.zDiameter.gammaC035,data.Coherr.Awake.zDiameter.gammaC035,data.Coherr.Asleep.zDiameter.gammaC035,data.Coherr.All.zDiameter.gammaC035);
gammaC035FitFormula = 'gammaC035 ~ 1 + Behavior + (1|Mouse)';
gammaC035Stats = fitglme(gammaC035Table,gammaC035FitFormula);
%% pupil HbT/gamma cross correlation
resultsStruct = 'Results_CrossCorrelation';
load(resultsStruct);
animalIDs = fieldnames(Results_CrossCorrelation);
behavFields = {'Rest','NREM','REM','Alert','Asleep','All'};
dataTypes = {'mmArea','mmDiameter','zArea','zDiameter'};
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
                data.XCorr.(behavField).(dataType).LH_peakLag_HbT = [];
                data.XCorr.(behavField).(dataType).LH_peak_HbT = [];
                % RH HbT
                data.XCorr.(behavField).(dataType).RH_xcVals_HbT = [];
                data.XCorr.(behavField).(dataType).RH_peakLag_HbT = [];
                data.XCorr.(behavField).(dataType).RH_peak_HbT = [];
                % LH gamma
                data.XCorr.(behavField).(dataType).LH_xcVals_gamma = [];
                data.XCorr.(behavField).(dataType).LH_peakLag_gamma = [];
                data.XCorr.(behavField).(dataType).LH_peak_gamma = [];
                % RH gamma
                data.XCorr.(behavField).(dataType).RH_xcVals_gamma = [];
                data.XCorr.(behavField).(dataType).RH_peakLag_gamma = [];
                data.XCorr.(behavField).(dataType).RH_peak_gamma = [];
                % lags and stats fields
                data.XCorr.(behavField).(dataType).lags = [];
                data.XCorr.(behavField).(dataType).animalID = {};
                data.XCorr.(behavField).(dataType).behavField = {};
                data.XCorr.(behavField).(dataType).LH = {};
                data.XCorr.(behavField).(dataType).RH = {};
            end
            samplingRate = 30;
            offset = 3; % sec
            % concatenate cross correlation during each arousal state, find peak + lag time
            if isfield(Results_CrossCorrelation.(animalID),behavField) == true
                if isempty(Results_CrossCorrelation.(animalID).(behavField).LH_HbT.(dataType).xcVals) == false
                    % LH HbT peak + lag time
                    data.XCorr.(behavField).(dataType).LH_xcVals_HbT = cat(1,data.XCorr.(behavField).(dataType).LH_xcVals_HbT,Results_CrossCorrelation.(animalID).(behavField).LH_HbT.(dataType).xcVals);
                    midPoint = floor(length(Results_CrossCorrelation.(animalID).(behavField).LH_HbT.(dataType).xcVals)/2);
                    [minVal,minIndex] = min(Results_CrossCorrelation.(animalID).(behavField).LH_HbT.(dataType).xcVals(midPoint - samplingRate*offset:midPoint + samplingRate*offset));
                    data.XCorr.(behavField).(dataType).LH_peakLag_HbT = cat(1,data.XCorr.(behavField).(dataType).LH_peakLag_HbT,minIndex/samplingRate - offset);
                    data.XCorr.(behavField).(dataType).LH_peak_HbT = cat(1,data.XCorr.(behavField).(dataType).LH_peak_HbT,minVal);
                    % RH HbT peak + lag time
                    data.XCorr.(behavField).(dataType).RH_xcVals_HbT = cat(1,data.XCorr.(behavField).(dataType).RH_xcVals_HbT,Results_CrossCorrelation.(animalID).(behavField).RH_HbT.(dataType).xcVals);
                    midPoint = floor(length(Results_CrossCorrelation.(animalID).(behavField).RH_HbT.(dataType).xcVals)/2);
                    [minVal,minIndex] = min(Results_CrossCorrelation.(animalID).(behavField).RH_HbT.(dataType).xcVals(midPoint - samplingRate*offset:midPoint + samplingRate*offset));
                    data.XCorr.(behavField).(dataType).RH_peakLag_HbT = cat(1,data.XCorr.(behavField).(dataType).RH_peakLag_HbT,minIndex/samplingRate - offset);
                    data.XCorr.(behavField).(dataType).RH_peak_HbT = cat(1,data.XCorr.(behavField).(dataType).RH_peak_HbT,minVal);
                    % LH gamma peak + lag time
                    data.XCorr.(behavField).(dataType).LH_xcVals_gamma = cat(1,data.XCorr.(behavField).(dataType).LH_xcVals_gamma,Results_CrossCorrelation.(animalID).(behavField).LH_gammaBandPower.(dataType).xcVals);
                    midPoint = floor(length(Results_CrossCorrelation.(animalID).(behavField).LH_gammaBandPower.(dataType).xcVals)/2);
                    [minVal,minIndex] = min(Results_CrossCorrelation.(animalID).(behavField).LH_gammaBandPower.(dataType).xcVals(midPoint - samplingRate*offset:midPoint + samplingRate*offset));
                    data.XCorr.(behavField).(dataType).LH_peakLag_gamma = cat(1,data.XCorr.(behavField).(dataType).LH_peakLag_gamma,minIndex/samplingRate - offset);
                    data.XCorr.(behavField).(dataType).LH_peak_gamma = cat(1,data.XCorr.(behavField).(dataType).LH_peak_gamma,minVal);
                    % RH gamma peak + lag time
                    data.XCorr.(behavField).(dataType).RH_xcVals_gamma = cat(1,data.XCorr.(behavField).(dataType).RH_xcVals_gamma,Results_CrossCorrelation.(animalID).(behavField).RH_gammaBandPower.(dataType).xcVals);
                    midPoint = floor(length(Results_CrossCorrelation.(animalID).(behavField).RH_gammaBandPower.(dataType).xcVals)/2);
                    [minVal,minIndex] = min(Results_CrossCorrelation.(animalID).(behavField).RH_gammaBandPower.(dataType).xcVals(midPoint - samplingRate*offset:midPoint + samplingRate*offset));
                    data.XCorr.(behavField).(dataType).RH_peakLag_gamma = cat(1,data.XCorr.(behavField).(dataType).RH_peakLag_gamma,minIndex/samplingRate - offset);
                    data.XCorr.(behavField).(dataType).RH_peak_gamma = cat(1,data.XCorr.(behavField).(dataType).RH_peak_gamma,minVal);
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
% mean and standard error/standard deviation of cross correlation values
for dd = 1:length(behavFields)
    behavField = behavFields{1,dd};
    for ff = 1:length(dataTypes)
        dataType = dataTypes{1,ff};
        % HbT XC mean/sem
        data.XCorr.(behavField).(dataType).xcVals_HbT = cat(1,data.XCorr.(behavField).(dataType).LH_xcVals_HbT,data.XCorr.(behavField).(dataType).RH_xcVals_HbT);
        data.XCorr.(behavField).(dataType).meanXcVals_HbT = mean(data.XCorr.(behavField).(dataType).xcVals_HbT,1);
        data.XCorr.(behavField).(dataType).semXcVals_HbT = std(data.XCorr.(behavField).(dataType).xcVals_HbT,0,1)./sqrt(size(data.XCorr.(behavField).(dataType).xcVals_HbT,1));
        % HbT peak lag mean/std
        data.XCorr.(behavField).(dataType).peakLag_HbT = cat(1,data.XCorr.(behavField).(dataType).LH_peakLag_HbT,data.XCorr.(behavField).(dataType).RH_peakLag_HbT);
        data.XCorr.(behavField).(dataType).meanPeakLag_HbT = mean(data.XCorr.(behavField).(dataType).peakLag_HbT,1);
        data.XCorr.(behavField).(dataType).stdPeakLag_HbT = std(data.XCorr.(behavField).(dataType).peakLag_HbT,0,1);
        % HbT peak mean/std
        data.XCorr.(behavField).(dataType).peak_HbT = cat(1,data.XCorr.(behavField).(dataType).LH_peak_HbT,data.XCorr.(behavField).(dataType).RH_peak_HbT);
        data.XCorr.(behavField).(dataType).meanPeak_HbT = mean(data.XCorr.(behavField).(dataType).peak_HbT,1);
        data.XCorr.(behavField).(dataType).stdPeak_HbT = std(data.XCorr.(behavField).(dataType).peak_HbT,0,1);
        % Gamma XC mean/sem
        data.XCorr.(behavField).(dataType).xcVals_gamma = cat(1,data.XCorr.(behavField).(dataType).LH_xcVals_gamma,data.XCorr.(behavField).(dataType).RH_xcVals_gamma);
        data.XCorr.(behavField).(dataType).meanXcVals_gamma = mean(data.XCorr.(behavField).(dataType).xcVals_gamma,1);
        data.XCorr.(behavField).(dataType).semXcVals_gamma = std(data.XCorr.(behavField).(dataType).xcVals_gamma,0,1)./sqrt(size(data.XCorr.(behavField).(dataType).xcVals_gamma,1));
        % Gamma peak lag mean/std
        data.XCorr.(behavField).(dataType).peakLag_gamma = cat(1,data.XCorr.(behavField).(dataType).LH_peakLag_gamma,data.XCorr.(behavField).(dataType).RH_peakLag_gamma);
        data.XCorr.(behavField).(dataType).meanPeakLag_gamma = mean(data.XCorr.(behavField).(dataType).peakLag_gamma,1);
        data.XCorr.(behavField).(dataType).stdPeakLag_gamma = std(data.XCorr.(behavField).(dataType).peakLag_gamma,0,1);
        % Gamma peak mean/std
        data.XCorr.(behavField).(dataType).peak_gamma = cat(1,data.XCorr.(behavField).(dataType).LH_peak_gamma,data.XCorr.(behavField).(dataType).RH_peak_gamma);
        data.XCorr.(behavField).(dataType).meanPeak_gamma = mean(data.XCorr.(behavField).(dataType).peak_gamma,1);
        data.XCorr.(behavField).(dataType).stdPeak_gamma = std(data.XCorr.(behavField).(dataType).peak_gamma,0,1);
        % Lags time vector
        data.XCorr.(behavField).(dataType).meanLags = mean(data.XCorr.(behavField).(dataType).lags,1);
    end
end
% statistics - generalized linear mixed effects model
% gammaPeakTableSize = cat(1,data.XCorr.Rest.zDiameter.peak_gamma,data.XCorr.NREM.zDiameter.peak_gamma,data.XCorr.REM.zDiameter.peak_gamma,...
%     data.XCorr.Alert.zDiameter.peak_gamma,data.XCorr.Asleep.zDiameter.peak_gamma,data.XCorr.All.zDiameter.peak_gamma);
% gammaPeakTable = table('Size',[size(gammaPeakTableSize,1),4],'VariableTypes',{'string','double','string','string'},'VariableNames',{'Mouse','Peak','Behavior','Hemisphere'});
% gammaPeakTable.Mouse = cat(1,data.XCorr.Rest.zDiameter.animalID,data.XCorr.Rest.zDiameter.animalID,data.XCorr.NREM.zDiameter.animalID,data.XCorr.NREM.zDiameter.animalID,...
%     data.XCorr.REM.zDiameter.animalID,data.XCorr.REM.zDiameter.animalID,data.XCorr.Alert.zDiameter.animalID,data.XCorr.Alert.zDiameter.animalID,...
%     data.XCorr.Asleep.zDiameter.animalID,data.XCorr.Asleep.zDiameter.animalID,data.XCorr.All.zDiameter.animalID,data.XCorr.All.zDiameter.animalID);
% gammaPeakTable.Peak = cat(1,data.XCorr.Rest.zDiameter.peak_gamma,data.XCorr.NREM.zDiameter.peak_gamma,data.XCorr.REM.zDiameter.peak_gamma,...
%     data.XCorr.Alert.zDiameter.peak_gamma,data.XCorr.Asleep.zDiameter.peak_gamma,data.XCorr.All.zDiameter.peak_gamma);
% gammaPeakTable.Behavior = cat(1,data.XCorr.Rest.zDiameter.behavField,data.XCorr.Rest.zDiameter.behavField,data.XCorr.NREM.zDiameter.behavField,data.XCorr.NREM.zDiameter.behavField,...
%     data.XCorr.REM.zDiameter.behavField,data.XCorr.REM.zDiameter.behavField,data.XCorr.Alert.zDiameter.behavField,data.XCorr.Alert.zDiameter.behavField,...
%     data.XCorr.Asleep.zDiameter.behavField,data.XCorr.Asleep.zDiameter.behavField,data.XCorr.All.zDiameter.behavField,data.XCorr.All.zDiameter.behavField);
% gammaPeakTable.Hemisphere = cat(1,data.XCorr.Rest.zDiameter.LH,data.XCorr.Rest.zDiameter.RH,data.XCorr.NREM.zDiameter.LH,data.XCorr.NREM.zDiameter.RH,...
%     data.XCorr.REM.zDiameter.LH,data.XCorr.REM.zDiameter.RH,data.XCorr.Alert.zDiameter.LH,data.XCorr.Alert.zDiameter.RH,...
%     data.XCorr.Asleep.zDiameter.LH,data.XCorr.Asleep.zDiameter.RH,data.XCorr.All.zDiameter.LH,data.XCorr.All.zDiameter.RH);
% gammaPeakFitFormula = 'Peak ~ 1 + Behavior + (1|Mouse) + (1|Mouse:Hemisphere)';
% gammaPeakStats = fitglme(gammaPeakTable,gammaPeakFitFormula); %#ok<*NASGU>
%% figures
Fig2 = figure('Name','Figure Panel 2 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
%% stimulus/whisking evoked zDiameter changes
ax1 = subplot(3,4,1);
p1 = plot(timeVector,data.Evoked.interWhisk.zDiameter.mean,'color',colors('vegas gold'),'LineWidth',2);
hold on
plot(timeVector,data.Evoked.interWhisk.zDiameter.mean + data.Evoked.interWhisk.zDiameter.sem,'color',colors('vegas gold'),'LineWidth',0.5)
plot(timeVector,data.Evoked.interWhisk.zDiameter.mean - data.Evoked.interWhisk.zDiameter.sem,'color',colors('vegas gold'),'LineWidth',0.5)
p2 = plot(timeVector,data.Evoked.stimSolenoid.zDiameter.mean,'color',colors('dark candy apple red'),'LineWidth',2);
plot(timeVector,data.Evoked.stimSolenoid.zDiameter.mean + data.Evoked.stimSolenoid.zDiameter.sem,'color',colors('dark candy apple red'),'LineWidth',0.5)
plot(timeVector,data.Evoked.stimSolenoid.zDiameter.mean - data.Evoked.stimSolenoid.zDiameter.sem,'color',colors('dark candy apple red'),'LineWidth',0.5)
p3 = plot(timeVector,data.Evoked.controlSolenoid.zDiameter.mean,'color',colors('deep carrot orange'),'LineWidth',2);
plot(timeVector,data.Evoked.controlSolenoid.zDiameter.mean + data.Evoked.controlSolenoid.zDiameter.sem,'color',colors('deep carrot orange'),'LineWidth',0.5)
plot(timeVector,data.Evoked.controlSolenoid.zDiameter.mean - data.Evoked.controlSolenoid.zDiameter.sem,'color',colors('deep carrot orange'),'LineWidth',0.5)
ylabel('\DeltaZ Units')
xlabel('Time (s)')
title('Evoked pupil zDiameter')
legend([p1,p2,p3],'Whisk','Stim','Aud','Location','NorthEast')
set(gca,'box','off')
xlim([-2,10])
axis square
ax1.TickLength = [0.03,0.03];
%% mm pupil diameter during arousal states
ax2 = subplot(3,4,2);
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
ax3 = subplot(3,4,3);
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
ylabel('Z units')
title('Arousal pupil diameter (z units)')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,6])
set(gca,'box','off')
ax3.TickLength = [0.03,0.03];
%% zDiameter pupil power spectrum during arousal states
ax4 = subplot(3,4,4);
L1 = loglog(data.PowerSpec.Rest.zDiameter.meanf,data.PowerSpec.Rest.zDiameter.meanS,'color',colors('custom rest'),'LineWidth',2);
hold on
loglog(data.PowerSpec.Rest.zDiameter.meanf,data.PowerSpec.Rest.zDiameter.meanS + data.PowerSpec.Rest.zDiameter.semS,'color',colors('custom rest'),'LineWidth',0.5);
loglog(data.PowerSpec.Rest.zDiameter.meanf,data.PowerSpec.Rest.zDiameter.meanS - data.PowerSpec.Rest.zDiameter.semS,'color',colors('custom rest'),'LineWidth',0.5);
rectangle('Position',[0.005,0.1,0.1 - 0.005,1],'FaceColor','w','EdgeColor','w')
L2 = loglog(data.PowerSpec.NREM.zDiameter.meanf,data.PowerSpec.NREM.zDiameter.meanS,'color',colors('custom nrem'),'LineWidth',2);
loglog(data.PowerSpec.NREM.zDiameter.meanf,data.PowerSpec.NREM.zDiameter.meanS + data.PowerSpec.NREM.zDiameter.semS,'color',colors('custom nrem'),'LineWidth',0.5);
loglog(data.PowerSpec.NREM.zDiameter.meanf,data.PowerSpec.NREM.zDiameter.meanS - data.PowerSpec.NREM.zDiameter.semS,'color',colors('custom nrem'),'LineWidth',0.5);
rectangle('Position',[0.005,0.1,1/30 - 0.005,5],'FaceColor','w','EdgeColor','w')
L3 = loglog(data.PowerSpec.REM.zDiameter.meanf,data.PowerSpec.REM.zDiameter.meanS,'color',colors('custom rem'),'LineWidth',2);
loglog(data.PowerSpec.REM.zDiameter.meanf,data.PowerSpec.REM.zDiameter.meanS + data.PowerSpec.REM.zDiameter.semS,'color',colors('custom rem'),'LineWidth',0.5);
loglog(data.PowerSpec.REM.zDiameter.meanf,data.PowerSpec.REM.zDiameter.meanS - data.PowerSpec.REM.zDiameter.semS,'color',colors('custom rem'),'LineWidth',0.5);
rectangle('Position',[0.005,0.1,1/60 - 0.005,5],'FaceColor','w','EdgeColor','w')
L4 = loglog(data.PowerSpec.Awake.zDiameter.meanf,data.PowerSpec.Awake.zDiameter.meanS,'color',colors('custom alert'),'LineWidth',2);
loglog(data.PowerSpec.Awake.zDiameter.meanf,data.PowerSpec.Awake.zDiameter.meanS + data.PowerSpec.Awake.zDiameter.semS,'color',colors('custom alert'),'LineWidth',0.5);
loglog(data.PowerSpec.Awake.zDiameter.meanf,data.PowerSpec.Awake.zDiameter.meanS - data.PowerSpec.Awake.zDiameter.semS,'color',colors('custom alert'),'LineWidth',0.5);
L5 = loglog(data.PowerSpec.Asleep.zDiameter.meanf,data.PowerSpec.Asleep.zDiameter.meanS,'color',colors('custom asleep'),'LineWidth',2);
loglog(data.PowerSpec.Asleep.zDiameter.meanf,data.PowerSpec.Asleep.zDiameter.meanS + data.PowerSpec.Asleep.zDiameter.semS,'color',colors('custom asleep'),'LineWidth',0.5);
loglog(data.PowerSpec.Asleep.zDiameter.meanf,data.PowerSpec.Asleep.zDiameter.meanS - data.PowerSpec.Asleep.zDiameter.semS,'color',colors('custom asleep'),'LineWidth',0.5);
L6 = loglog(data.PowerSpec.All.zDiameter.meanf,data.PowerSpec.All.zDiameter.meanS,'color',colors('custom all'),'LineWidth',2);
loglog(data.PowerSpec.All.zDiameter.meanf,data.PowerSpec.All.zDiameter.meanS + data.PowerSpec.All.zDiameter.semS,'color',colors('custom all'),'LineWidth',0.5);
loglog(data.PowerSpec.All.zDiameter.meanf,data.PowerSpec.All.zDiameter.meanS - data.PowerSpec.All.zDiameter.semS,'color',colors('custom all'),'LineWidth',0.5);
title('Pupil power spectrum')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
legend([L1,L2,L3,L4,L5,L6],'Rest','NREM','REM','Alert','Asleep','All','Location','SouthWest')
axis square
axis tight
xlim([0.003,1])
set(gca,'box','off')
ax4.TickLength = [0.03,0.03];
%% HbT-pupil coherence
ax5 = subplot(3,4,5);
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
semilogx(data.Coherr.Awake.zDiameter.meanHbTf,data.Coherr.Awake.zDiameter.meanHbTC,'color',colors('custom alert'),'LineWidth',2);
semilogx(data.Coherr.Awake.zDiameter.meanHbTf,data.Coherr.Awake.zDiameter.meanHbTC + data.Coherr.Awake.zDiameter.semHbTC,'color',colors('custom alert'),'LineWidth',0.5);
semilogx(data.Coherr.Awake.zDiameter.meanHbTf,data.Coherr.Awake.zDiameter.meanHbTC - data.Coherr.Awake.zDiameter.semHbTC,'color',colors('custom alert'),'LineWidth',0.5);
semilogx(data.Coherr.Asleep.zDiameter.meanHbTf,data.Coherr.Asleep.zDiameter.meanHbTC,'color',colors('custom asleep'),'LineWidth',2);
semilogx(data.Coherr.Asleep.zDiameter.meanHbTf,data.Coherr.Asleep.zDiameter.meanHbTC + data.Coherr.Asleep.zDiameter.semHbTC,'color',colors('custom asleep'),'LineWidth',0.5);
semilogx(data.Coherr.Asleep.zDiameter.meanHbTf,data.Coherr.Asleep.zDiameter.meanHbTC - data.Coherr.Asleep.zDiameter.semHbTC,'color',colors('custom asleep'),'LineWidth',0.5);
semilogx(data.Coherr.All.zDiameter.meanHbTf,data.Coherr.All.zDiameter.meanHbTC,'color',colors('custom all'),'LineWidth',2);
semilogx(data.Coherr.All.zDiameter.meanHbTf,data.Coherr.All.zDiameter.meanHbTC + data.Coherr.All.zDiameter.semHbTC,'color',colors('custom all'),'LineWidth',0.5);
semilogx(data.Coherr.All.zDiameter.meanHbTf,data.Coherr.All.zDiameter.meanHbTC - data.Coherr.All.zDiameter.semHbTC,'color',colors('custom all'),'LineWidth',0.5);
xline(0.02,'color','b');
xline(0.35,'color','r');
title('Pupil-HbT coherence')
ylabel('Coherence')
xlabel('Freq (Hz)')
axis square
xlim([0.003,1])
ylim([0,1])
set(gca,'box','off')
ax5.TickLength = [0.03,0.03];
%% HbT-pupil coherence Stats
ax6 = subplot(3,4,6);
scatter(ones(1,length(data.Coherr.Awake.zDiameter.HbTC002))*1,data.Coherr.Awake.zDiameter.HbTC002,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom alert'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.Coherr.Awake.zDiameter.meanHbTC002,data.Coherr.Awake.zDiameter.stdHbTC002,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
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
scatter(ones(1,length(data.Coherr.Rest.zDiameter.HbTC035))*5,data.Coherr.Rest.zDiameter.HbTC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom rest'),'jitter','on','jitterAmount',0.25);
e4 = errorbar(5,data.Coherr.Rest.zDiameter.meanHbTC035,data.Coherr.Rest.zDiameter.stdHbTC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e4.Color = 'black';
e4.MarkerSize = 10;
e4.CapSize = 10;
scatter(ones(1,length(data.Coherr.NREM.zDiameter.HbTC035))*6,data.Coherr.NREM.zDiameter.HbTC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom nrem'),'jitter','on','jitterAmount',0.25);
e5 = errorbar(6,data.Coherr.NREM.zDiameter.meanHbTC035,data.Coherr.NREM.zDiameter.stdHbTC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e5.Color = 'black';
e5.MarkerSize = 10;
e5.CapSize = 10;
scatter(ones(1,length(data.Coherr.REM.zDiameter.HbTC035))*7,data.Coherr.REM.zDiameter.HbTC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom rem'),'jitter','on','jitterAmount',0.25);
e6 = errorbar(7,data.Coherr.REM.zDiameter.meanHbTC035,data.Coherr.REM.zDiameter.stdHbTC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e6.Color = 'black';
e6.MarkerSize = 10;
e6.CapSize = 10;
scatter(ones(1,length(data.Coherr.Awake.zDiameter.HbTC035))*8,data.Coherr.Awake.zDiameter.HbTC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom alert'),'jitter','on','jitterAmount',0.25);
e7 = errorbar(8,data.Coherr.Awake.zDiameter.meanHbTC035,data.Coherr.Awake.zDiameter.stdHbTC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e7.Color = 'black';
e7.MarkerSize = 10;
e7.CapSize = 10;
scatter(ones(1,length(data.Coherr.Asleep.zDiameter.HbTC035))*9,data.Coherr.Asleep.zDiameter.HbTC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom asleep'),'jitter','on','jitterAmount',0.25);
e8 = errorbar(9,data.Coherr.Asleep.zDiameter.meanHbTC035,data.Coherr.Asleep.zDiameter.stdHbTC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e8.Color = 'black';
e8.MarkerSize = 10;
e8.CapSize = 10;
scatter(ones(1,length(data.Coherr.All.zDiameter.HbTC035))*10,data.Coherr.All.zDiameter.HbTC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom all'),'jitter','on','jitterAmount',0.25);
e9 = errorbar(10,data.Coherr.All.zDiameter.meanHbTC035,data.Coherr.All.zDiameter.stdHbTC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e9.Color = 'black';
e9.MarkerSize = 10;
e9.CapSize = 10;
title('Pupil-HbT coherence @ 0.02/0.35 Hz')
ylabel('Coherece')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,11])
set(gca,'box','off')
ax6.TickLength = [0.03,0.03];
%% gamma-pupil coherence during arousal states
ax7 = subplot(3,4,7);
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
semilogx(data.Coherr.Awake.zDiameter.meanGammaf,data.Coherr.Awake.zDiameter.meanGammaC,'color',colors('custom alert'),'LineWidth',2);
semilogx(data.Coherr.Awake.zDiameter.meanGammaf,data.Coherr.Awake.zDiameter.meanGammaC + data.Coherr.Awake.zDiameter.semGammaC,'color',colors('custom alert'),'LineWidth',0.5);
semilogx(data.Coherr.Awake.zDiameter.meanGammaf,data.Coherr.Awake.zDiameter.meanGammaC - data.Coherr.Awake.zDiameter.semGammaC,'color',colors('custom alert'),'LineWidth',0.5);
semilogx(data.Coherr.Asleep.zDiameter.meanGammaf,data.Coherr.Asleep.zDiameter.meanGammaC,'color',colors('custom asleep'),'LineWidth',2);
semilogx(data.Coherr.Asleep.zDiameter.meanGammaf,data.Coherr.Asleep.zDiameter.meanGammaC + data.Coherr.Asleep.zDiameter.semGammaC,'color',colors('custom asleep'),'LineWidth',0.5);
semilogx(data.Coherr.Asleep.zDiameter.meanGammaf,data.Coherr.Asleep.zDiameter.meanGammaC - data.Coherr.Asleep.zDiameter.semGammaC,'color',colors('custom asleep'),'LineWidth',0.5);
semilogx(data.Coherr.All.zDiameter.meanGammaf,data.Coherr.All.zDiameter.meanGammaC,'color',colors('custom all'),'LineWidth',2);
semilogx(data.Coherr.All.zDiameter.meanGammaf,data.Coherr.All.zDiameter.meanGammaC + data.Coherr.All.zDiameter.semGammaC,'color',colors('custom all'),'LineWidth',0.5);
semilogx(data.Coherr.All.zDiameter.meanGammaf,data.Coherr.All.zDiameter.meanGammaC - data.Coherr.All.zDiameter.semGammaC,'color',colors('custom all'),'LineWidth',0.5);
xline(0.02,'color','b');
xline(0.35,'color','r');
title('Pupil-Gamma coherence')
ylabel('Coherence')
xlabel('Freq (Hz)')
axis square
xlim([0.003,1])
ylim([0,1])
set(gca,'box','off')
ax7.TickLength = [0.03,0.03];
%% gamma-pupil coherence stats
ax8 = subplot(3,4,8);
scatter(ones(1,length(data.Coherr.Awake.zDiameter.gammaC002))*1,data.Coherr.Awake.zDiameter.gammaC002,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom alert'),'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.Coherr.Awake.zDiameter.meanGammaC002,data.Coherr.Awake.zDiameter.stdGammaC002,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
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
scatter(ones(1,length(data.Coherr.Rest.zDiameter.gammaC035))*5,data.Coherr.Rest.zDiameter.gammaC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom rest'),'jitter','on','jitterAmount',0.25);
e4 = errorbar(5,data.Coherr.Rest.zDiameter.meanGammaC035,data.Coherr.Rest.zDiameter.stdGammaC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e4.Color = 'black';
e4.MarkerSize = 10;
e4.CapSize = 10;
scatter(ones(1,length(data.Coherr.NREM.zDiameter.gammaC035))*6,data.Coherr.NREM.zDiameter.gammaC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom nrem'),'jitter','on','jitterAmount',0.25);
e5 = errorbar(6,data.Coherr.NREM.zDiameter.meanGammaC035,data.Coherr.NREM.zDiameter.stdGammaC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e5.Color = 'black';
e5.MarkerSize = 10;
e5.CapSize = 10;
scatter(ones(1,length(data.Coherr.REM.zDiameter.gammaC035))*7,data.Coherr.REM.zDiameter.gammaC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom rem'),'jitter','on','jitterAmount',0.25);
e6 = errorbar(7,data.Coherr.REM.zDiameter.meanGammaC035,data.Coherr.REM.zDiameter.stdGammaC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e6.Color = 'black';
e6.MarkerSize = 10;
e6.CapSize = 10;
scatter(ones(1,length(data.Coherr.Awake.zDiameter.gammaC035))*8,data.Coherr.Awake.zDiameter.gammaC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom alert'),'jitter','on','jitterAmount',0.25);
e7 = errorbar(8,data.Coherr.Awake.zDiameter.meanGammaC035,data.Coherr.Awake.zDiameter.stdGammaC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e7.Color = 'black';
e7.MarkerSize = 10;
e7.CapSize = 10;
scatter(ones(1,length(data.Coherr.Asleep.zDiameter.gammaC035))*9,data.Coherr.Asleep.zDiameter.gammaC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom asleep'),'jitter','on','jitterAmount',0.25);
e8 = errorbar(9,data.Coherr.Asleep.zDiameter.meanGammaC035,data.Coherr.Asleep.zDiameter.stdGammaC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e8.Color = 'black';
e8.MarkerSize = 10;
e8.CapSize = 10;
scatter(ones(1,length(data.Coherr.All.zDiameter.gammaC035))*10,data.Coherr.All.zDiameter.gammaC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom all'),'jitter','on','jitterAmount',0.25);
e9 = errorbar(10,data.Coherr.All.zDiameter.meanGammaC035,data.Coherr.All.zDiameter.stdGammaC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e9.Color = 'black';
e9.MarkerSize = 10;
e9.CapSize = 10;
title('Pupil-Gamma coherence @ 0.02/0.35 Hz')
ylabel('Coherence')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,11])
set(gca,'box','off')
ax8.TickLength = [0.03,0.03];
%% HbT-pupil cross correlation [rest, NREM, REM]
ax9 = subplot(3,4,9);
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
xlabel('Lags (s)')
ylabel('Correlation')
title('Pupil-HbT XCorr')
axis square
set(gca,'box','off')
ax9.TickLength = [0.03,0.03];
%% HbT-pupil cross correlation [alert, asleep, all]
ax10 = subplot(3,4,10);
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
xlabel('Lags (s)')
ylabel('Correlation')
title('Pupil-HbT XCorr')
axis square
set(gca,'box','off')
ax10.TickLength = [0.03,0.03];
%% gamma-pupil cross correlation [rest, NREM, REM]
ax11 = subplot(3,4,11);
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
xlabel('Lags (s)')
ylabel('Correlation')
title('Pupil-Gamma XCorr')
axis square
set(gca,'box','off')
ax11.TickLength = [0.03,0.03];
%% gamma-pupil cross correlation [alert, asleep, all]
ax12 = subplot(3,4,12);
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
xlabel('Lags (s)')
ylabel('Correlation')
title('Pupil-Gamma XCorr')
axis square
set(gca,'box','off')
ax12.TickLength = [0.03,0.03];
% link axis
linkaxes([ax9,ax10],'y')
linkaxes([ax11,ax12],'y')
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'Summary Figures and Structures' delim 'Figure Panels' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig2,[dirpath 'Fig2_JNeurosci2022']);
    set(Fig2,'PaperPositionMode','auto');
    print('-vector','-dpdf','-bestfit',[dirpath 'Fig2_JNeurosci2022'])
    % text diary
    diaryFile = [dirpath 'Fig2_Text.txt'];
    if exist(diaryFile,'file') == 2
        delete(diaryFile)
    end
    diary(diaryFile)
    diary on
    % peak whisk/stim
    disp('======================================================================================================================')
    disp('Peak change in z-unit post-stimulation/whisking')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Whisker stimulation z-unit increase ' num2str(data.Evoked.stimSolenoid.zDiameter.meanPeak) ' +/- ' num2str(data.Evoked.stimSolenoid.zDiameter.stdPeak) ' (n = ' num2str(length(data.Evoked.stimSolenoid.zDiameter.peak)/2) ') mice']); disp(' ')
    disp(['Auditory stimulation z-unit increase ' num2str(data.Evoked.controlSolenoid.zDiameter.meanPeak) ' +/- ' num2str(data.Evoked.controlSolenoid.zDiameter.stdPeak) ' (n = ' num2str(length(data.Evoked.controlSolenoid.zDiameter.peak)) ') mice']); disp(' ')
    disp(['2-5 sec volitional whisking z-unit increase ' num2str(data.Evoked.interWhisk.zDiameter.meanPeak) ' +/- ' num2str(data.Evoked.interWhisk.zDiameter.stdPeak) ' (n = ' num2str(length(data.Evoked.interWhisk.zDiameter.peak)) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    % mm diameter statistical diary
    disp('======================================================================================================================')
    disp('GLME stats for mm diameter during Rest, Whisk, Stim, NREM, and REM')
    disp('======================================================================================================================')
    disp(mmDiameterStats)
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Rest diameter (mm): ' num2str(round(data.Diameter.Rest.meanDiameter,2)) ' +/- ' num2str(round(data.Diameter.Whisk.stdDiameter,2)) ' (n = ' num2str(length(data.Diameter.Rest.mmDiameter)) ') mice']); disp(' ')
    disp(['Whisk diameter (mm): ' num2str(round(data.Diameter.Whisk.meanDiameter,2)) ' +/- ' num2str(round(data.Diameter.Whisk.stdDiameter,2)) ' (n = ' num2str(length(data.Diameter.Whisk.mmDiameter)) ') mice']); disp(' ')
    disp(['Stim diameter (mm): ' num2str(round(data.Diameter.Stim.meanDiameter,2)) ' +/- ' num2str(round(data.Diameter.Stim.stdDiameter,2)) ' (n = ' num2str(length(data.Diameter.Stim.mmDiameter)) ') mice']); disp(' ')
    disp(['NREM diameter (mm): ' num2str(round(data.Diameter.NREM.meanDiameter,2)) ' +/- ' num2str(round(data.Diameter.NREM.stdDiameter,2)) ' (n = ' num2str(length(data.Diameter.NREM.mmDiameter)) ') mice']); disp(' ')
    disp(['REM diameter (mm): ' num2str(round(data.Diameter.REM.meanDiameter,2)) ' +/- ' num2str(round(data.Diameter.REM.stdDiameter,2)) ' (n = ' num2str(length(data.Diameter.REM.mmDiameter)) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    % z-unit Diameter statistical diary
    disp('======================================================================================================================')
    disp('GLME stats for z-unit diameter during Rest, Whisk, Stim, NREM, and REM')
    disp('======================================================================================================================')
    disp(zDiameterStats)
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Rest diameter (z-unit): ' num2str(round(data.Diameter.Rest.meanzDiameter,2)) ' +/- ' num2str(round(data.Diameter.Whisk.stdzDiameter,2)) ' (n = ' num2str(length(data.Diameter.Rest.zDiameter)) ') mice']); disp(' ')
    disp(['Whisk diameter (z-unit): ' num2str(round(data.Diameter.Whisk.meanzDiameter,2)) ' +/- ' num2str(round(data.Diameter.Whisk.stdzDiameter,2)) ' (n = ' num2str(length(data.Diameter.Whisk.zDiameter)) ') mice']); disp(' ')
    disp(['Stim diameter (z-unit): ' num2str(round(data.Diameter.Stim.meanzDiameter,2)) ' +/- ' num2str(round(data.Diameter.Stim.stdzDiameter,2)) ' (n = ' num2str(length(data.Diameter.Stim.zDiameter)) ') mice']); disp(' ')
    disp(['NREM diameter (z-unit): ' num2str(round(data.Diameter.NREM.meanzDiameter,2)) ' +/- ' num2str(round(data.Diameter.NREM.stdzDiameter,2)) ' (n = ' num2str(length(data.Diameter.NREM.zDiameter)) ') mice']); disp(' ')
    disp(['REM diameter (z-unit): ' num2str(round(data.Diameter.REM.meanzDiameter,2)) ' +/- ' num2str(round(data.Diameter.REM.stdzDiameter,2)) ' (n = ' num2str(length(data.Diameter.REM.zDiameter)) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    % coherence between pupil diameter and HbT @ 0.35 Hz
    disp('======================================================================================================================')
    disp('GLME stats for z-unit diameter vs. HbT coherence during Rest, NREM, REM, Alert, Asleep, All')
    disp('======================================================================================================================')
    disp(HbTC035Stats)
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Rest coherence - [HbT] (\muM) vs. pupil diameter (z-units): ' num2str(round(data.Coherr.Rest.zDiameter.meanHbTC035,2)) ' +/- ' num2str(round(data.Coherr.Rest.zDiameter.stdHbTC035,2)) ' (n = ' num2str(length(data.Coherr.Rest.zDiameter.HbTC035)/2) ') mice']); disp(' ')
    disp(['NREM coherence - [HbT] (\muM) vs. pupil diameter (z-units): ' num2str(round(data.Coherr.NREM.zDiameter.meanHbTC035,2)) ' +/- ' num2str(round(data.Coherr.NREM.zDiameter.stdHbTC035,2)) ' (n = ' num2str(length(data.Coherr.NREM.zDiameter.HbTC035)/2) ') mice']); disp(' ')
    disp(['REM coherence - [HbT] (\muM) vs. pupil diameter (z-units): ' num2str(round(data.Coherr.REM.zDiameter.meanHbTC035,2)) ' +/- ' num2str(round(data.Coherr.REM.zDiameter.stdHbTC035,2)) ' (n = ' num2str(length(data.Coherr.REM.zDiameter.HbTC035)/2) ') mice']); disp(' ')
    disp(['Alert coherence - [HbT] (\muM) vs. pupil diameter (z-units):: ' num2str(round(data.Coherr.Awake.zDiameter.meanHbTC035,2)) ' +/- ' num2str(round(data.Coherr.Awake.zDiameter.stdHbTC035,2)) ' (n = ' num2str(length(data.Coherr.Awake.zDiameter.HbTC035)/2) ') mice']); disp(' ')
    disp(['Asleep coherence - [HbT] (\muM) vs. pupil diameter (z-units):: ' num2str(round(data.Coherr.Asleep.zDiameter.meanHbTC035,2)) ' +/- ' num2str(round(data.Coherr.Asleep.zDiameter.stdHbTC035,2)) ' (n = ' num2str(length(data.Coherr.Asleep.zDiameter.HbTC035)/2) ') mice']); disp(' ')
    disp(['All coherence - [HbT] (\muM) vs. pupil diameter (z-units):: ' num2str(round(data.Coherr.All.zDiameter.meanHbTC035,2)) ' +/- ' num2str(round(data.Coherr.All.zDiameter.stdHbTC035,2)) ' (n = ' num2str(length(data.Coherr.All.zDiameter.HbTC035)/2) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    % coherence between pupil diameter and HbT @ 0.02 Hz
    disp('======================================================================================================================')
    disp('GLME stats for z-unit diameter vs. HbT coherence during Rest, NREM, REM, Alert, Asleep, All')
    disp('======================================================================================================================')
    disp(HbTC002Stats)
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Alert coherence - [HbT] (\muM) vs. pupil diameter (z-units):: ' num2str(round(data.Coherr.Awake.zDiameter.meanHbTC002,2)) ' +/- ' num2str(round(data.Coherr.Awake.zDiameter.stdHbTC002,2)) ' (n = ' num2str(length(data.Coherr.Awake.zDiameter.HbTC002)/2) ') mice']); disp(' ')
    disp(['Asleep coherence - [HbT] (\muM) vs. pupil diameter (z-units):: ' num2str(round(data.Coherr.Asleep.zDiameter.meanHbTC002,2)) ' +/- ' num2str(round(data.Coherr.Asleep.zDiameter.stdHbTC002,2)) ' (n = ' num2str(length(data.Coherr.Asleep.zDiameter.HbTC002)/2) ') mice']); disp(' ')
    disp(['All coherence - [HbT] (\muM) vs. pupil diameter (z-units):: ' num2str(round(data.Coherr.All.zDiameter.meanHbTC002,2)) ' +/- ' num2str(round(data.Coherr.All.zDiameter.stdHbTC002,2)) ' (n = ' num2str(length(data.Coherr.All.zDiameter.HbTC002)/2) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    % coherence between pupil diameter and gamma @ 0.35 Hz
    disp('======================================================================================================================')
    disp('GLME stats for z-unit diameter vs. Gamma coherence during Rest, NREM, REM, Alert, Asleep, All')
    disp('======================================================================================================================')
    disp(gammaC035Stats)
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Rest coherence - Gamma-band (\DeltaP/P) vs. pupil diameter (z-units): ' num2str(round(data.Coherr.Rest.zDiameter.meanGammaC035,2)) ' +/- ' num2str(round(data.Coherr.Rest.zDiameter.stdGammaC035,2)) ' (n = ' num2str(length(data.Coherr.Rest.zDiameter.gammaC035)/2) ') mice']); disp(' ')
    disp(['NREM coherence - Gamma-band (\DeltaP/P) vs. pupil diameter (z-units): ' num2str(round(data.Coherr.NREM.zDiameter.meanGammaC035,2)) ' +/- ' num2str(round(data.Coherr.NREM.zDiameter.stdGammaC035,2)) ' (n = ' num2str(length(data.Coherr.NREM.zDiameter.gammaC035)/2) ') mice']); disp(' ')
    disp(['REM coherence - Gamma-band (\DeltaP/P) vs. pupil diameter (z-units): ' num2str(round(data.Coherr.REM.zDiameter.meanGammaC035,2)) ' +/- ' num2str(round(data.Coherr.REM.zDiameter.stdGammaC035,2)) ' (n = ' num2str(length(data.Coherr.REM.zDiameter.gammaC035)/2) ') mice']); disp(' ')
    disp(['Alert coherence - Gamma-band (\DeltaP/P) vs. pupil diameter (z-units):: ' num2str(round(data.Coherr.Awake.zDiameter.meanGammaC035,2)) ' +/- ' num2str(round(data.Coherr.Awake.zDiameter.stdGammaC035,2)) ' (n = ' num2str(length(data.Coherr.Awake.zDiameter.gammaC035)/2) ') mice']); disp(' ')
    disp(['Asleep coherence - Gamma-band (\DeltaP/P) vs. pupil diameter (z-units):: ' num2str(round(data.Coherr.Asleep.zDiameter.meanGammaC035,2)) ' +/- ' num2str(round(data.Coherr.Asleep.zDiameter.stdGammaC035,2)) ' (n = ' num2str(length(data.Coherr.Asleep.zDiameter.gammaC035)/2) ') mice']); disp(' ')
    disp(['All coherence - Gamma-band (\DeltaP/P) vs. pupil diameter (z-units):: ' num2str(round(data.Coherr.All.zDiameter.meanGammaC035,2)) ' +/- ' num2str(round(data.Coherr.All.zDiameter.stdGammaC035,2)) ' (n = ' num2str(length(data.Coherr.All.zDiameter.gammaC035)/2) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    % coherence between pupil diameter and gamma @ 0.02 Hz
    disp('======================================================================================================================')
    disp('GLME stats for z-unit diameter vs. Gamma coherence during Alert, Asleep, All')
    disp('======================================================================================================================')
    disp(gammaC002Stats)
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Alert coherence - Gamma-band (\DeltaP/P) vs. pupil diameter (z-units):: ' num2str(round(data.Coherr.Awake.zDiameter.meanGammaC002,2)) ' +/- ' num2str(round(data.Coherr.Awake.zDiameter.stdGammaC002,2)) ' (n = ' num2str(length(data.Coherr.Awake.zDiameter.gammaC002)/2) ') mice']); disp(' ')
    disp(['Asleep coherence - Gamma-band (\DeltaP/P) vs. pupil diameter (z-units):: ' num2str(round(data.Coherr.Asleep.zDiameter.meanGammaC002,2)) ' +/- ' num2str(round(data.Coherr.Asleep.zDiameter.stdGammaC002,2)) ' (n = ' num2str(length(data.Coherr.Asleep.zDiameter.gammaC002)/2) ') mice']); disp(' ')
    disp(['All coherence - Gamma-band (\DeltaP/P) vs. pupil diameter (z-units):: ' num2str(round(data.Coherr.All.zDiameter.meanGammaC002,2)) ' +/- ' num2str(round(data.Coherr.All.zDiameter.stdGammaC002,2)) ' (n = ' num2str(length(data.Coherr.All.zDiameter.gammaC002)/2) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    % cross correlation between [HbT] and pupil diameter
    disp('======================================================================================================================')
    disp('Peak cross-correlation and lag time for Rest, NREM, REM, Alert, Asleep, All')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Rest [HbT]-diameter peak cross-correlation: ' num2str(data.XCorr.Rest.zDiameter.meanPeak_HbT) ' +/- ' num2str(data.XCorr.Rest.zDiameter.stdPeak_HbT) ' (n = ' num2str(length(data.XCorr.Rest.zDiameter.peak_HbT)/2) ') mice']); disp(' ')
    disp(['Rest [HbT]-diameter lag time (sec): ' num2str(data.XCorr.Rest.zDiameter.meanPeakLag_HbT) ' +/- ' num2str(data.XCorr.Rest.zDiameter.stdPeakLag_HbT) ' (n = ' num2str(length(data.XCorr.Rest.zDiameter.peakLag_HbT)/2) ') mice']); disp(' ')
    disp(['NREM [HbT]-diameter peak cross-correlation: ' num2str(data.XCorr.NREM.zDiameter.meanPeak_HbT) ' +/- ' num2str(data.XCorr.NREM.zDiameter.stdPeak_HbT) ' (n = ' num2str(length(data.XCorr.NREM.zDiameter.peak_HbT)/2) ') mice']); disp(' ')
    disp(['NREM [HbT]-diameter lag time (sec): ' num2str(data.XCorr.NREM.zDiameter.meanPeakLag_HbT) ' +/- ' num2str(data.XCorr.NREM.zDiameter.stdPeakLag_HbT) ' (n = ' num2str(length(data.XCorr.NREM.zDiameter.peakLag_HbT)/2) ') mice']); disp(' ')
    disp(['REM [HbT]-diameter peak cross-correlation: ' num2str(data.XCorr.REM.zDiameter.meanPeak_HbT) ' +/- ' num2str(data.XCorr.REM.zDiameter.stdPeak_HbT) ' (n = ' num2str(length(data.XCorr.REM.zDiameter.peak_HbT)/2) ') mice']); disp(' ')
    disp(['REM [HbT]-diameter lag time (sec): ' num2str(data.XCorr.REM.zDiameter.meanPeakLag_HbT) ' +/- ' num2str(data.XCorr.REM.zDiameter.stdPeakLag_HbT) ' (n = ' num2str(length(data.XCorr.REM.zDiameter.peakLag_HbT)/2) ') mice']); disp(' ')
    disp(['Alert [HbT]-diameter peak cross-correlation: ' num2str(data.XCorr.Alert.zDiameter.meanPeak_HbT) ' +/- ' num2str(data.XCorr.Alert.zDiameter.stdPeak_HbT) ' (n = ' num2str(length(data.XCorr.Alert.zDiameter.peak_HbT)/2) ') mice']); disp(' ')
    disp(['Alert [HbT]-diameter lag time (sec): ' num2str(data.XCorr.Alert.zDiameter.meanPeakLag_HbT) ' +/- ' num2str(data.XCorr.Alert.zDiameter.stdPeakLag_HbT) ' (n = ' num2str(length(data.XCorr.Alert.zDiameter.peakLag_HbT)/2) ') mice']); disp(' ')
    disp(['Asleep [HbT]-diameter peak cross-correlation: ' num2str(data.XCorr.Asleep.zDiameter.meanPeak_HbT) ' +/- ' num2str(data.XCorr.Asleep.zDiameter.stdPeak_HbT) ' (n = ' num2str(length(data.XCorr.Asleep.zDiameter.peak_HbT)/2) ') mice']); disp(' ')
    disp(['Asleep [HbT]-diameter lag time (sec): ' num2str(data.XCorr.Asleep.zDiameter.meanPeakLag_HbT) ' +/- ' num2str(data.XCorr.Asleep.zDiameter.stdPeakLag_HbT) ' (n = ' num2str(length(data.XCorr.Asleep.zDiameter.peakLag_HbT)/2) ') mice']); disp(' ')
    disp(['All [HbT]-diameter peak cross-correlation: ' num2str(data.XCorr.All.zDiameter.meanPeak_HbT) ' +/- ' num2str(data.XCorr.All.zDiameter.stdPeak_HbT) ' (n = ' num2str(length(data.XCorr.All.zDiameter.peak_HbT)/2) ') mice']); disp(' ')
    disp(['All [HbT]-diameter lag time (sec): ' num2str(data.XCorr.All.zDiameter.meanPeakLag_HbT) ' +/- ' num2str(data.XCorr.All.zDiameter.stdPeakLag_HbT) ' (n = ' num2str(length(data.XCorr.All.zDiameter.peakLag_HbT)/2) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    % cross correlation between gamma-band and pupil diameter
    disp('======================================================================================================================')
    disp('Peak cross-correlation and lag time for Rest, NREM, REM, Alert, Asleep, All')
    disp('======================================================================================================================')
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Rest gamma-diameter peak cross-correlation: ' num2str(data.XCorr.Rest.zDiameter.meanPeak_gamma) ' +/- ' num2str(data.XCorr.Rest.zDiameter.stdPeak_gamma) ' (n = ' num2str(length(data.XCorr.Rest.zDiameter.peak_gamma)/2) ') mice']); disp(' ')
    disp(['Rest gamma-diameter lag time (sec): ' num2str(data.XCorr.Rest.zDiameter.meanPeakLag_gamma) ' +/- ' num2str(data.XCorr.Rest.zDiameter.stdPeakLag_gamma) ' (n = ' num2str(length(data.XCorr.Rest.zDiameter.peakLag_gamma)/2) ') mice']); disp(' ')
    disp(['NREM gamma-diameter peak cross-correlation: ' num2str(data.XCorr.NREM.zDiameter.meanPeak_gamma) ' +/- ' num2str(data.XCorr.NREM.zDiameter.stdPeak_gamma) ' (n = ' num2str(length(data.XCorr.NREM.zDiameter.peak_gamma)/2) ') mice']); disp(' ')
    disp(['NREM gamma-diameter lag time (sec): ' num2str(data.XCorr.NREM.zDiameter.meanPeakLag_gamma) ' +/- ' num2str(data.XCorr.NREM.zDiameter.stdPeakLag_gamma) ' (n = ' num2str(length(data.XCorr.NREM.zDiameter.peakLag_gamma)/2) ') mice']); disp(' ')
    disp(['REM gamma-diameter peak cross-correlation: ' num2str(data.XCorr.REM.zDiameter.meanPeak_gamma) ' +/- ' num2str(data.XCorr.REM.zDiameter.stdPeak_gamma) ' (n = ' num2str(length(data.XCorr.REM.zDiameter.peak_gamma)/2) ') mice']); disp(' ')
    disp(['REM gamma-diameter lag time (sec): ' num2str(data.XCorr.REM.zDiameter.meanPeakLag_gamma) ' +/- ' num2str(data.XCorr.REM.zDiameter.stdPeakLag_gamma) ' (n = ' num2str(length(data.XCorr.REM.zDiameter.peakLag_gamma)/2) ') mice']); disp(' ')
    disp(['Alert gamma-diameter peak cross-correlation: ' num2str(data.XCorr.Alert.zDiameter.meanPeak_gamma) ' +/- ' num2str(data.XCorr.Alert.zDiameter.stdPeak_gamma) ' (n = ' num2str(length(data.XCorr.Alert.zDiameter.peak_gamma)/2) ') mice']); disp(' ')
    disp(['Alert gamma-diameter lag time (sec): ' num2str(data.XCorr.Alert.zDiameter.meanPeakLag_gamma) ' +/- ' num2str(data.XCorr.Alert.zDiameter.stdPeakLag_gamma) ' (n = ' num2str(length(data.XCorr.Alert.zDiameter.peakLag_gamma)/2) ') mice']); disp(' ')
    disp(['Asleep gamma-diameter peak cross-correlation: ' num2str(data.XCorr.Asleep.zDiameter.meanPeak_gamma) ' +/- ' num2str(data.XCorr.Asleep.zDiameter.stdPeak_gamma) ' (n = ' num2str(length(data.XCorr.Asleep.zDiameter.peak_gamma)/2) ') mice']); disp(' ')
    disp(['Asleep gamma-diameter lag time (sec): ' num2str(data.XCorr.Asleep.zDiameter.meanPeakLag_gamma) ' +/- ' num2str(data.XCorr.Asleep.zDiameter.stdPeakLag_gamma) ' (n = ' num2str(length(data.XCorr.Asleep.zDiameter.peakLag_gamma)/2) ') mice']); disp(' ')
    disp(['All gamma-diameter peak cross-correlation: ' num2str(data.XCorr.All.zDiameter.meanPeak_gamma) ' +/- ' num2str(data.XCorr.All.zDiameter.stdPeak_gamma) ' (n = ' num2str(length(data.XCorr.All.zDiameter.peak_gamma)/2) ') mice']); disp(' ')
    disp(['All gamma-diameter lag time (sec): ' num2str(data.XCorr.All.zDiameter.meanPeakLag_gamma) ' +/- ' num2str(data.XCorr.All.zDiameter.stdPeakLag_gamma) ' (n = ' num2str(length(data.XCorr.All.zDiameter.peakLag_gamma)/2) ') mice']); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    diary off
end

end
