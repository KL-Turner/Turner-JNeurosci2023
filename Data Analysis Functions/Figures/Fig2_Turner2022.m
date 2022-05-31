function [] = Fig2_Turner2022(rootFolder,saveFigs,delim)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Generate figures and supporting information for Figure Panel 2
%________________________________________________________________________________________________________________________

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
% statistics - generalized linear mixed effects model (0.02 HbT coherence)
HbTC002TableSize = cat(1,data.Coherr.Alert.zDiameter.HbTC002,data.Coherr.Asleep.zDiameter.HbTC002,data.Coherr.All.zDiameter.HbTC002);
HbTC002Table = table('Size',[size(HbTC002TableSize,1),3],'VariableTypes',{'string','string','double'},'VariableNames',{'Mouse','Behavior','HbTC002'});
HbTC002Table.Mouse = cat(1,data.Coherr.Alert.zDiameter.animalID,data.Coherr.Asleep.zDiameter.animalID,data.Coherr.All.zDiameter.animalID);
HbTC002Table.Behavior = cat(1,data.Coherr.Alert.zDiameter.behavField,data.Coherr.Asleep.zDiameter.behavField,data.Coherr.All.zDiameter.behavField);
HbTC002Table.HbTC002 = cat(1,data.Coherr.Alert.zDiameter.HbTC002,data.Coherr.Asleep.zDiameter.HbTC002,data.Coherr.All.zDiameter.HbTC002);
HbTC002FitFormula = 'HbTC002 ~ 1 + Behavior + (1|Mouse)';
HbTC002Stats = fitglme(HbTC002Table,HbTC002FitFormula);
% statistics - generalized linear mixed effects model (0.02 gamma coherence)
gammaC002TableSize = cat(1,data.Coherr.Alert.zDiameter.gammaC002,data.Coherr.Asleep.zDiameter.gammaC002,data.Coherr.All.zDiameter.gammaC002);
gammaC002Table = table('Size',[size(gammaC002TableSize,1),3],'VariableTypes',{'string','string','double'},'VariableNames',{'Mouse','Behavior','gammaC002'});
gammaC002Table.Mouse = cat(1,data.Coherr.Alert.zDiameter.animalID,data.Coherr.Asleep.zDiameter.animalID,data.Coherr.All.zDiameter.animalID);
gammaC002Table.Behavior = cat(1,data.Coherr.Alert.zDiameter.behavField,data.Coherr.Asleep.zDiameter.behavField,data.Coherr.All.zDiameter.behavField);
gammaC002Table.gammaC002 = cat(1,data.Coherr.Alert.zDiameter.gammaC002,data.Coherr.Asleep.zDiameter.gammaC002,data.Coherr.All.zDiameter.gammaC002);
gammaC002FitFormula = 'gammaC002 ~ 1 + Behavior + (1|Mouse)';
gammaC002Stats = fitglme(gammaC002Table,gammaC002FitFormula);
% statistics - generalized linear mixed effects model (0.35 HbT coherence)
HbTC035TableSize = cat(1,data.Coherr.Rest.zDiameter.HbTC035,data.Coherr.NREM.zDiameter.HbTC035,data.Coherr.REM.zDiameter.HbTC035,data.Coherr.Alert.zDiameter.HbTC035,data.Coherr.Asleep.zDiameter.HbTC035,data.Coherr.All.zDiameter.HbTC035);
HbTC035Table = table('Size',[size(HbTC035TableSize,1),3],'VariableTypes',{'string','string','double'},'VariableNames',{'Mouse','Behavior','HbTC035'});
HbTC035Table.Mouse = cat(1,data.Coherr.Rest.zDiameter.animalID,data.Coherr.NREM.zDiameter.animalID,data.Coherr.REM.zDiameter.animalID,data.Coherr.Alert.zDiameter.animalID,data.Coherr.Asleep.zDiameter.animalID,data.Coherr.All.zDiameter.animalID);
HbTC035Table.Behavior = cat(1,data.Coherr.Rest.zDiameter.behavField,data.Coherr.NREM.zDiameter.behavField,data.Coherr.REM.zDiameter.behavField,data.Coherr.Alert.zDiameter.behavField,data.Coherr.Asleep.zDiameter.behavField,data.Coherr.All.zDiameter.behavField);
HbTC035Table.HbTC035 = cat(1,data.Coherr.Rest.zDiameter.HbTC035,data.Coherr.NREM.zDiameter.HbTC035,data.Coherr.REM.zDiameter.HbTC035,data.Coherr.Alert.zDiameter.HbTC035,data.Coherr.Asleep.zDiameter.HbTC035,data.Coherr.All.zDiameter.HbTC035);
HbTC035FitFormula = 'HbTC035 ~ 1 + Behavior + (1|Mouse)';
HbTC035Stats = fitglme(HbTC035Table,HbTC035FitFormula);
% statistics - generalized linear mixed effects model (0.02 HbT coherence)
gammaC035TableSize = cat(1,data.Coherr.Rest.zDiameter.gammaC035,data.Coherr.NREM.zDiameter.gammaC035,data.Coherr.REM.zDiameter.gammaC035,data.Coherr.Alert.zDiameter.gammaC035,data.Coherr.Asleep.zDiameter.gammaC035,data.Coherr.All.zDiameter.gammaC035);
gammaC035Table = table('Size',[size(gammaC035TableSize,1),3],'VariableTypes',{'string','string','double'},'VariableNames',{'Mouse','Behavior','gammaC035'});
gammaC035Table.Mouse = cat(1,data.Coherr.Rest.zDiameter.animalID,data.Coherr.NREM.zDiameter.animalID,data.Coherr.REM.zDiameter.animalID,data.Coherr.Alert.zDiameter.animalID,data.Coherr.Asleep.zDiameter.animalID,data.Coherr.All.zDiameter.animalID);
gammaC035Table.Behavior = cat(1,data.Coherr.Rest.zDiameter.behavField,data.Coherr.NREM.zDiameter.behavField,data.Coherr.REM.zDiameter.behavField,data.Coherr.Alert.zDiameter.behavField,data.Coherr.Asleep.zDiameter.behavField,data.Coherr.All.zDiameter.behavField);
gammaC035Table.gammaC035 = cat(1,data.Coherr.Rest.zDiameter.gammaC035,data.Coherr.NREM.zDiameter.gammaC035,data.Coherr.REM.zDiameter.gammaC035,data.Coherr.Alert.zDiameter.gammaC035,data.Coherr.Asleep.zDiameter.gammaC035,data.Coherr.All.zDiameter.gammaC035);
gammaC035FitFormula = 'gammaC035 ~ 1 + Behavior + (1|Mouse)';
gammaC035Stats = fitglme(gammaC035Table,gammaC035FitFormula);
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
title('Pupil power spectrum')
xline(1/10)
xline(1/30)
xline(1/60)
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
legend([L1,L2,L3,L4,L5,L6],'Rest','NREM','REM','Alert','Asleep','All','Location','NorthWest')
axis square
xlim([0.003,1])
ylim([0.000035,0.0012])
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
scatter(ones(1,length(data.Coherr.Alert.zDiameter.HbTC035))*8,data.Coherr.Alert.zDiameter.HbTC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom alert'),'jitter','on','jitterAmount',0.25);
e7 = errorbar(8,data.Coherr.Alert.zDiameter.meanHbTC035,data.Coherr.Alert.zDiameter.stdHbTC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
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
scatter(ones(1,length(data.Coherr.Alert.zDiameter.gammaC035))*8,data.Coherr.Alert.zDiameter.gammaC035,75,'MarkerEdgeColor','k','MarkerFaceColor',colors('custom alert'),'jitter','on','jitterAmount',0.25);
e7 = errorbar(8,data.Coherr.Alert.zDiameter.meanGammaC035,data.Coherr.Alert.zDiameter.stdGammaC035,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
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
ylim([-0.7,0.3])
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
ylim([-0.7,0.3])
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
ylim([-0.35,0.15])
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
ylim([-0.35,0.15])
xlabel('Lags (s)')
ylabel('Correlation')
title('Pupil-Gamma XCorr')
axis square
set(gca,'box','off')
ax12.TickLength = [0.03,0.03];
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'Figure Panels' delim];
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
    disp('----------------------------------------------------------------------------------------------------------------------')
    % cross correlation between [HbT] and pupil diameter
    disp('======================================================================================================================')
    disp('Peak cross-correlation and lag time for Rest, NREM, REM, Alert, Asleep, All')
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
    disp('Peak cross-correlation and lag time for Rest, NREM, REM, Alert, Asleep, All')
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

end
