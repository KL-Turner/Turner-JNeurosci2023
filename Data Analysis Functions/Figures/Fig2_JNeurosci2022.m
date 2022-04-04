function [] = Fig2_JNeurosci2022(rootFolder,saveFigs,delim)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose:
%________________________________________________________________________________________________________________________

% behavior colors
colorRest = [(0/256),(166/256),(81/256)];
colorWhisk = [(31/256),(120/256),(179/256)];
colorStim = [(255/256),(28/256),(206/256)];
colorNREM = [(191/256),(0/256),(255/256)];
colorREM = [(254/256),(139/256),(0/256)];
colorAlert = [(255/256),(191/256),(0/256)];
colorAsleep = [(0/256),(128/256),(255/256)];
colorAll = [(183/256),(115/256),(51/256)];
%% Evoked pupil changes
resultsStruct = 'Results_Evoked';
load(resultsStruct);
dataTypes = {'mmArea','mmDiameter','zArea','zDiameter'};
timeVector = (0:12*30)/30 - 2;
animalIDs = fieldnames(Results_Evoked);
for aa = 1:length(dataTypes)
    dataType = dataTypes{1,aa};
    data.controlSolenoid.(dataType) = [];
    data.stimSolenoid.(dataType) = [];
    data.briefWhisk.(dataType) = [];
    data.interWhisk.(dataType) = [];
    data.extendWhisk.(dataType) = [];
end
%
for cc = 1:length(animalIDs)
    animalID = animalIDs{cc,1};
    for bb = 1:length(dataTypes)
        dataType = dataTypes{1,bb};
        % whisking
        data.briefWhisk.(dataType) = cat(1,data.briefWhisk.(dataType),Results_Evoked.(animalID).Whisk.(dataType).ShortWhisks.mean);
        data.interWhisk.(dataType) = cat(1,data.interWhisk.(dataType),Results_Evoked.(animalID).Whisk.(dataType).IntermediateWhisks.mean);
        data.extendWhisk.(dataType) = cat(1,data.extendWhisk.(dataType),Results_Evoked.(animalID).Whisk.(dataType).LongWhisks.mean);
        % solenoids
        data.stimSolenoid.(dataType) = cat(1,data.stimSolenoid.(dataType),Results_Evoked.(animalID).Stim.(dataType).LPadSol.mean,Results_Evoked.(animalID).Stim.(dataType).RPadSol.mean);
        data.controlSolenoid.(dataType) = cat(1,data.controlSolenoid.(dataType),Results_Evoked.(animalID).Stim.(dataType).AudSol.mean);
    end
end
%
for dd = 1:length(dataTypes)
    dataType = dataTypes{1,dd};
    procData.briefWhisk.(dataType).mean = mean(data.briefWhisk.(dataType),1);
    procData.briefWhisk.(dataType).sem = std(data.briefWhisk.(dataType),0,1)./sqrt(size(data.briefWhisk.(dataType),1));
    procData.interWhisk.(dataType).mean = mean(data.interWhisk.(dataType),1);
    procData.interWhisk.(dataType).sem = std(data.interWhisk.(dataType),0,1)./sqrt(size(data.interWhisk.(dataType),1));
    procData.extendWhisk.(dataType).mean = mean(data.extendWhisk.(dataType),1);
    procData.extendWhisk.(dataType).sem = std(data.extendWhisk.(dataType),0,1)./sqrt(size(data.extendWhisk.(dataType),1));
    procData.stimSolenoid.(dataType).mean = mean(data.stimSolenoid.(dataType),1);
    procData.stimSolenoid.(dataType).sem = std(data.stimSolenoid.(dataType),0,1)./sqrt(size(data.stimSolenoid.(dataType),1));
    procData.controlSolenoid.(dataType).mean = mean(data.controlSolenoid.(dataType),1);
    procData.controlSolenoid.(dataType).sem = std(data.controlSolenoid.(dataType),0,1)./sqrt(size(data.controlSolenoid.(dataType),1));
end
%% pupil diameter during different arousel states
resultsStruct = 'Results_BehavData.mat';
load(resultsStruct);
animalIDs = fieldnames(Results_BehavData);
behavFields = {'Rest','Whisk','Stim','NREM','REM'};
% mean HbT comparison between behaviors
% pre-allocate the date for each day
% pre-allocate
for cc = 1:length(behavFields)
    behavField = behavFields{1,cc};
    data.(behavField).indMeanDiameter = [];
    data.(behavField).indDiameter = [];
    data.(behavField).indMeanzDiameter = [];
    data.(behavField).indzDiameter = [];
end
% concatenate
for cc = 1:length(animalIDs)
    animalID = animalIDs{cc,1};
    for dd = 1:length(behavFields)
        behavField = behavFields{1,dd};
        data.(behavField).indMeanDiameter = cat(1,data.(behavField).indMeanDiameter,mean(Results_BehavData.(animalID).(behavField).mmDiameter.eventMeans,'omitnan'));
        data.(behavField).indMeanzDiameter = cat(1,data.(behavField).indMeanzDiameter,mean(Results_BehavData.(animalID).(behavField).zDiameter.eventMeans,'omitnan'));
        indDiameter = []; indzDiameter = [];
        for ee = 1:length(Results_BehavData.(animalID).(behavField).mmArea.indData)
            indDiameter = cat(2,indDiameter,Results_BehavData.(animalID).(behavField).mmDiameter.indData{ee,1});
            indzDiameter = cat(2,indzDiameter,Results_BehavData.(animalID).(behavField).zDiameter.indData{ee,1});
        end
        data.(behavField).indDiameter = cat(2,data.(behavField).indDiameter,indDiameter);
        data.(behavField).indzDiameter = cat(2,data.(behavField).indzDiameter,indzDiameter);
    end
end
% mean/std
for ee = 1:length(behavFields)
    behavField = behavFields{1,ee};
    % diameter
    data.(behavField).meanDiameter = mean(data.(behavField).indMeanDiameter,1,'omitnan');
    data.(behavField).stdDiameter = std(data.(behavField).indMeanDiameter,0,1,'omitnan');%./sqrt(length(data.(behavField.indMeanDiameter)));
    realIndex = ~isnan(data.(behavField).indDiameter);
    data.(behavField).indDiameter = data.(behavField).indDiameter(realIndex);
    % z diameter
    data.(behavField).meanzDiameter = mean(data.(behavField).indMeanzDiameter,1,'omitnan');
    data.(behavField).stdzDiameter = std(data.(behavField).indMeanzDiameter,0,1,'omitnan');%./sqrt(length(data.(behavField.indMeanzDiameter)));
    realIndex = ~isnan(data.(behavField).indzDiameter);
    data.(behavField).indzDiameter = data.(behavField).indzDiameter(realIndex);
end
numComp = 4;
% mm diameter
[~,pWhisk_mm,~,~] = ttest2(data.Rest.indMeanDiameter,data.Whisk.indMeanDiameter);
disp(['Bonferroni-corrected p-value (Rest vs. Whisk mmDiameter): ' num2str(pWhisk_mm/numComp)]); disp(' ')
[~,pStim_mm,~,~] = ttest2(data.Rest.indMeanDiameter,data.Stim.indMeanDiameter);
disp(['Bonferroni-corrected p-value (Rest vs. Stim mmDiameter): ' num2str(pStim_mm/numComp)]); disp(' ')
[~,pNREM_mm,~,~] = ttest2(data.Rest.indMeanDiameter,data.NREM.indMeanDiameter);
disp(['Bonferroni-corrected p-value (Rest vs. NREM mmDiameter): ' num2str(pNREM_mm/numComp)]); disp(' ')
[~,pREM_mm,~,~] = ttest2(data.Rest.indMeanDiameter,data.REM.indMeanDiameter);
disp(['Bonferroni-corrected p-value (Rest vs. REM mmDiameter): ' num2str(pREM_mm/numComp)]); disp(' ')
% z diameter
[~,pWhisk_z,~,~] = ttest2(data.Rest.indMeanDiameter,data.Whisk.indMeanzDiameter);
disp(['Bonferroni-corrected p-value (Rest vs. Whisk zDiameter): ' num2str(pWhisk_z/numComp)]); disp(' ')
[~,pStim_z,~,~] = ttest2(data.Rest.indMeanDiameter,data.Stim.indMeanzDiameter);
disp(['Bonferroni-corrected p-value (Rest vs. Stim zDiameter): ' num2str(pStim_z/numComp)]); disp(' ')
[~,pNREM_z,~,~] = ttest2(data.Rest.indMeanDiameter,data.NREM.indMeanzDiameter);
disp(['Bonferroni-corrected p-value (Rest vs. NREM zDiameter): ' num2str(pNREM_z/numComp)]); disp(' ')
[~,pREM_z,~,~] = ttest2(data.Rest.indMeanDiameter,data.REM.indMeanzDiameter);
disp(['Bonferroni-corrected p-value (Rest vs. REM zDiameter): ' num2str(pREM_z/numComp)]); disp(' ')
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
        data.(behavField).(dataType).S = [];
        data.(behavField).(dataType).f = [];
    end
end
% power spectra during different behaviors
% cd through each animal's directory and extract the appropriate analysis results
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    for bb = 1:length(behavFields)
        behavField = behavFields{1,bb};
        for cc = 1:length(dataTypes)
            dataType = dataTypes{1,cc};
            % don't concatenate empty arrays where there was no data for this behavior
            if isempty(Results_PowerSpectrum.(animalID).(behavField).(dataType).S) == false
                data.(behavField).(dataType).S = cat(2,data.(behavField).(dataType).S,Results_PowerSpectrum.(animalID).(behavField).(dataType).S);
                data.(behavField).(dataType).f = cat(1,data.(behavField).(dataType).f,Results_PowerSpectrum.(animalID).(behavField).(dataType).f);
            end
        end
    end
end
% take mean/StD of S/f
for aa = 1:length(behavFields)
    behavField = behavFields{1,aa};
    for bb = 1:length(dataTypes)
        dataType = dataTypes{1,bb};
        data.(behavField).(dataType).meanS = mean(data.(behavField).(dataType).S,2);
        data.(behavField).(dataType).semS = std(data.(behavField).(dataType).S,0,2)./sqrt(size(data.(behavField).(dataType).S,2));
        data.(behavField).(dataType).meanf = mean(data.(behavField).(dataType).f,1);
    end
end
%% pupil HbT/gamma coherence
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
    end
end
% power spectra during different behaviors
% cd through each animal's directory and extract the appropriate analysis results
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
            end
        end
    end
end
% take mean/StD of S/f
for aa = 1:length(behavFields)
    behavField = behavFields{1,aa};
    for bb = 1:length(dataTypes)
        dataType = dataTypes{1,bb};
        data.Coherr.(behavField).(dataType).meanHbTC = mean(data.Coherr.(behavField).(dataType).HbTC,2);
        data.Coherr.(behavField).(dataType).semHbTC = std(data.Coherr.(behavField).(dataType).HbTC,0,2)./sqrt(size(data.Coherr.(behavField).(dataType).HbTC,2));
        data.Coherr.(behavField).(dataType).meanHbTf = mean(data.Coherr.(behavField).(dataType).HbTf,1);

        data.Coherr.(behavField).(dataType).meanGammaC = mean(data.Coherr.(behavField).(dataType).gammaC,2);
        data.Coherr.(behavField).(dataType).semGammaC = std(data.Coherr.(behavField).(dataType).gammaC,0,2)./sqrt(size(data.Coherr.(behavField).(dataType).gammaC,2));
        data.Coherr.(behavField).(dataType).meanGammaf = mean(data.Coherr.(behavField).(dataType).gammaf,1);
    end
end
% find 0.1/0.01 Hz peaks in coherence
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
% take mean/StD of peak C
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
%% pupil cross correlation
resultsStruct = 'Results_CrossCorrelation';
load(resultsStruct);
animalIDs = fieldnames(Results_CrossCorrelation);
behavFields = {'Rest','NREM','REM','Alert','Asleep','All'};
dataTypes = {'mmArea','mmDiameter','zArea','zDiameter'};
% cd through each animal's directory and extract the appropriate analysis results
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    for bb = 1:length(behavFields)
        behavField = behavFields{1,bb};
        for cc = 1:length(dataTypes)
            dataType = dataTypes{1,cc};
            % pre-allocate necessary variable fields
            data.XCorr.(behavField).(dataType).dummCheck = 1;
            if isfield(data.XCorr.(behavField).(dataType),'LH_xcVals_HbT') == false
                data.XCorr.(behavField).(dataType).LH_xcVals_HbT = [];
                data.XCorr.(behavField).(dataType).LH_peakLag_HbT = [];
                data.XCorr.(behavField).(dataType).LH_peak_HbT = [];

                data.XCorr.(behavField).(dataType).RH_xcVals_HbT = [];
                data.XCorr.(behavField).(dataType).RH_peakLag_HbT = [];
                data.XCorr.(behavField).(dataType).RH_peak_HbT = [];

                data.XCorr.(behavField).(dataType).LH_xcVals_gamma = [];
                data.XCorr.(behavField).(dataType).LH_peakLag_gamma = [];
                data.XCorr.(behavField).(dataType).LH_peak_gamma = [];

                data.XCorr.(behavField).(dataType).RH_xcVals_gamma = [];
                data.XCorr.(behavField).(dataType).RH_peakLag_gamma = [];
                data.XCorr.(behavField).(dataType).RH_peak_gamma = [];

                data.XCorr.(behavField).(dataType).lags = [];

                data.XCorr.(behavField).(dataType).animalID = {};
                data.XCorr.(behavField).(dataType).behavField = {};
                data.XCorr.(behavField).(dataType).LH = {};
                data.XCorr.(behavField).(dataType).RH = {};
            end
            if isfield(Results_CrossCorrelation.(animalID),behavField) == true
                if isempty(Results_CrossCorrelation.(animalID).(behavField).LH_HbT.(dataType).xcVals) == false

                    data.XCorr.(behavField).(dataType).LH_xcVals_HbT = cat(1,data.XCorr.(behavField).(dataType).LH_xcVals_HbT,Results_CrossCorrelation.(animalID).(behavField).LH_HbT.(dataType).xcVals);
                    midPoint = floor(length(Results_CrossCorrelation.(animalID).(behavField).LH_HbT.(dataType).xcVals)/2);
                    [minVal,minIndex] = min(Results_CrossCorrelation.(animalID).(behavField).LH_HbT.(dataType).xcVals(midPoint:midPoint + 30*3));
                    %                     [maxVal,maxIndex] = max(Results_CrossCorrelation.(animalID).(behavField).LH_HbT.(dataType).xcVals(midPoint:midPoint + 30*3));
                    %                     if abs(minVal) > maxVal
                    index = minIndex;
                    data.XCorr.(behavField).(dataType).LH_peakLag_HbT = cat(1,data.XCorr.(behavField).(dataType).LH_peakLag_HbT,index/30);
                    data.XCorr.(behavField).(dataType).LH_peak_HbT = cat(1,data.XCorr.(behavField).(dataType).LH_peak_HbT,minVal);
                    %                     else
                    %                         index = maxIndex;
                    %                         data.XCorr.(behavField).(dataType).LH_peakLag_HbT = cat(1,data.XCorr.(behavField).(dataType).LH_peakLag_HbT,index/30);
                    %                         data.XCorr.(behavField).(dataType).LH_peak_HbT = cat(1,data.XCorr.(behavField).(dataType).LH_peak_HbT,maxVal);
                    %                     end

                    data.XCorr.(behavField).(dataType).RH_xcVals_HbT = cat(1,data.XCorr.(behavField).(dataType).RH_xcVals_HbT,Results_CrossCorrelation.(animalID).(behavField).RH_HbT.(dataType).xcVals);
                    midPoint = floor(length(Results_CrossCorrelation.(animalID).(behavField).RH_HbT.(dataType).xcVals)/2);
                    [minVal,minIndex] = min(Results_CrossCorrelation.(animalID).(behavField).RH_HbT.(dataType).xcVals(midPoint:midPoint + 30*3));
                    %                     [maxVal,maxIndex] = max(Results_CrossCorrelation.(animalID).(behavField).RH_HbT.(dataType).xcVals(midPoint:midPoint + 30*3));
                    %                     if abs(minVal) > maxVal
                    index = minIndex;
                    data.XCorr.(behavField).(dataType).RH_peakLag_HbT = cat(1,data.XCorr.(behavField).(dataType).RH_peakLag_HbT,index/30);
                    data.XCorr.(behavField).(dataType).RH_peak_HbT = cat(1,data.XCorr.(behavField).(dataType).RH_peak_HbT,minVal);
                    %                     else
                    %                         index = maxIndex;
                    %                         data.XCorr.(behavField).(dataType).RH_peakLag_HbT = cat(1,data.XCorr.(behavField).(dataType).RH_peakLag_HbT,index/30);
                    %                         data.XCorr.(behavField).(dataType).RH_peak_HbT = cat(1,data.XCorr.(behavField).(dataType).RH_peak_HbT,maxVal);
                    %                     end

                    data.XCorr.(behavField).(dataType).LH_xcVals_gamma = cat(1,data.XCorr.(behavField).(dataType).LH_xcVals_gamma,Results_CrossCorrelation.(animalID).(behavField).LH_gammaBandPower.(dataType).xcVals);
                    midPoint = floor(length(Results_CrossCorrelation.(animalID).(behavField).LH_gammaBandPower.(dataType).xcVals)/2);
                    [minVal,minIndex] = min(Results_CrossCorrelation.(animalID).(behavField).LH_gammaBandPower.(dataType).xcVals(midPoint - 30*3:midPoint));
                    %                     [maxVal,maxIndex] = max(Results_CrossCorrelation.(animalID).(behavField).LH_gammaBandPower.(dataType).xcVals(midPoint - 30*3:midPoint));
                    %                     if abs(minVal) > maxVal
                    index = minIndex;
                    data.XCorr.(behavField).(dataType).LH_peakLag_gamma = cat(1,data.XCorr.(behavField).(dataType).LH_peakLag_gamma,(length(midPoint - 30*3:midPoint) - index)/30);
                    data.XCorr.(behavField).(dataType).LH_peak_gamma = cat(1,data.XCorr.(behavField).(dataType).LH_peak_gamma,minVal);
                    %                     else
                    %                         index = maxIndex;
                    %                         data.XCorr.(behavField).(dataType).LH_peakLag_gamma = cat(1,data.XCorr.(behavField).(dataType).LH_peakLag_gamma,(length(midPoint - 30*3:midPoint) - index)/30);
                    %                         data.XCorr.(behavField).(dataType).LH_peak_gamma = cat(1,data.XCorr.(behavField).(dataType).LH_peak_gamma,maxVal);
                    %                     end

                    data.XCorr.(behavField).(dataType).RH_xcVals_gamma = cat(1,data.XCorr.(behavField).(dataType).RH_xcVals_gamma,Results_CrossCorrelation.(animalID).(behavField).RH_gammaBandPower.(dataType).xcVals);
                    midPoint = floor(length(Results_CrossCorrelation.(animalID).(behavField).RH_gammaBandPower.(dataType).xcVals)/2);
                    [minVal,minIndex] = min(Results_CrossCorrelation.(animalID).(behavField).RH_gammaBandPower.(dataType).xcVals(midPoint - 30*3:midPoint));
                    %                     [maxVal,maxIndex] = max(Results_CrossCorrelation.(animalID).(behavField).RH_gammaBandPower.(dataType).xcVals(midPoint - 30*3:midPoint));
                    %                     if abs(minVal) > maxVal
                    index = minIndex;
                    data.XCorr.(behavField).(dataType).RH_peakLag_gamma = cat(1,data.XCorr.(behavField).(dataType).RH_peakLag_gamma,(length(midPoint - 30*3:midPoint) - index)/30);
                    data.XCorr.(behavField).(dataType).RH_peak_gamma = cat(1,data.XCorr.(behavField).(dataType).RH_peak_gamma,minVal);
                    %                     else
                    %                         index = maxIndex;
                    %                         data.XCorr.(behavField).(dataType).RH_peakLag_gamma = cat(1,data.XCorr.(behavField).(dataType).RH_peakLag_gamma,(length(midPoint - 30*3:midPoint) - index)/30);
                    %                         data.XCorr.(behavField).(dataType).RH_peak_gamma = cat(1,data.XCorr.(behavField).(dataType).RH_peak_gamma,maxVal);
                    %                     end

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
% take the averages of each field through the proper dimension
for dd = 1:length(behavFields)
    behavField = behavFields{1,dd};
    for ff = 1:length(dataTypes)
        dataType = dataTypes{1,ff};
        % HbT XC mean/std
        data.XCorr.(behavField).(dataType).xcVals_HbT = cat(1,data.XCorr.(behavField).(dataType).LH_xcVals_HbT,data.XCorr.(behavField).(dataType).RH_xcVals_HbT);
        data.XCorr.(behavField).(dataType).meanXcVals_HbT = mean(data.XCorr.(behavField).(dataType).xcVals_HbT,1);
        data.XCorr.(behavField).(dataType).semXcVals_HbT = std(data.XCorr.(behavField).(dataType).xcVals_HbT,0,1)./sqrt(size(data.XCorr.(behavField).(dataType).xcVals_HbT,1));
        % HbT peak lag mean/std
        data.XCorr.(behavField).(dataType).peakLag_HbT = cat(1,data.XCorr.(behavField).(dataType).LH_peakLag_HbT,data.XCorr.(behavField).(dataType).RH_peakLag_HbT);
        data.XCorr.(behavField).(dataType).meanPeakLag_HbT = mean(data.XCorr.(behavField).(dataType).peakLag_HbT,1);
        data.XCorr.(behavField).(dataType).stdPeakLag_HbT = std(data.XCorr.(behavField).(dataType).peakLag_HbT,0,1);%./sqrt(size(data.XCorr.(behavField).(dataType).peakLag_HbT,1));
        % HbT peak mean/std
        data.XCorr.(behavField).(dataType).peak_HbT = cat(1,data.XCorr.(behavField).(dataType).LH_peak_HbT,data.XCorr.(behavField).(dataType).RH_peak_HbT);
        data.XCorr.(behavField).(dataType).meanPeak_HbT = mean(data.XCorr.(behavField).(dataType).peak_HbT,1);
        data.XCorr.(behavField).(dataType).stdPeak_HbT = std(data.XCorr.(behavField).(dataType).peak_HbT,0,1);%./sqrt(size(data.XCorr.(behavField).(dataType).peak_HbT,1));
        % Gamma XC mean/std
        data.XCorr.(behavField).(dataType).xcVals_gamma = cat(1,data.XCorr.(behavField).(dataType).LH_xcVals_gamma,data.XCorr.(behavField).(dataType).RH_xcVals_gamma);
        data.XCorr.(behavField).(dataType).meanXcVals_gamma = mean(data.XCorr.(behavField).(dataType).xcVals_gamma,1);
        data.XCorr.(behavField).(dataType).semXcVals_gamma = std(data.XCorr.(behavField).(dataType).xcVals_gamma,0,1)./sqrt(size(data.XCorr.(behavField).(dataType).xcVals_gamma,1));
        % Gamma peak lag mean/std
        data.XCorr.(behavField).(dataType).peakLag_gamma = cat(1,data.XCorr.(behavField).(dataType).LH_peakLag_gamma,data.XCorr.(behavField).(dataType).RH_peakLag_gamma);
        data.XCorr.(behavField).(dataType).meanPeakLag_gamma = mean(data.XCorr.(behavField).(dataType).peakLag_gamma,1);
        data.XCorr.(behavField).(dataType).stdPeakLag_gamma = std(data.XCorr.(behavField).(dataType).peakLag_gamma,0,1);%./sqrt(size(data.XCorr.(behavField).(dataType).peakLag_gamma,1));
        % Gamma peak mean/std
        data.XCorr.(behavField).(dataType).peak_gamma = cat(1,data.XCorr.(behavField).(dataType).LH_peak_gamma,data.XCorr.(behavField).(dataType).RH_peak_gamma);
        data.XCorr.(behavField).(dataType).meanPeak_gamma = mean(data.XCorr.(behavField).(dataType).peak_gamma,1);
        data.XCorr.(behavField).(dataType).stdPeak_gamma = std(data.XCorr.(behavField).(dataType).peak_gamma,0,1);%./sqrt(size(data.XCorr.(behavField).(dataType).peak_gamma,1));
        % Lags time vector
        data.XCorr.(behavField).(dataType).meanLags = mean(data.XCorr.(behavField).(dataType).lags,1);
    end
end
% statistics - generalized linear mixed effects model
gammaPeakTableSize = cat(1,data.XCorr.Rest.zDiameter.peak_gamma,data.XCorr.NREM.zDiameter.peak_gamma,data.XCorr.REM.zDiameter.peak_gamma,...
    data.XCorr.Alert.zDiameter.peak_gamma,data.XCorr.Asleep.zDiameter.peak_gamma,data.XCorr.All.zDiameter.peak_gamma);
gammaPeakTable = table('Size',[size(gammaPeakTableSize,1),4],'VariableTypes',{'string','double','string','string'},'VariableNames',{'Mouse','Peak','Behavior','Hemisphere'});
gammaPeakTable.Mouse = cat(1,data.XCorr.Rest.zDiameter.animalID,data.XCorr.Rest.zDiameter.animalID,data.XCorr.NREM.zDiameter.animalID,data.XCorr.NREM.zDiameter.animalID,...
    data.XCorr.REM.zDiameter.animalID,data.XCorr.REM.zDiameter.animalID,data.XCorr.Alert.zDiameter.animalID,data.XCorr.Alert.zDiameter.animalID,...
    data.XCorr.Asleep.zDiameter.animalID,data.XCorr.Asleep.zDiameter.animalID,data.XCorr.All.zDiameter.animalID,data.XCorr.All.zDiameter.animalID);
gammaPeakTable.Peak = cat(1,data.XCorr.Rest.zDiameter.peak_gamma,data.XCorr.NREM.zDiameter.peak_gamma,data.XCorr.REM.zDiameter.peak_gamma,...
    data.XCorr.Alert.zDiameter.peak_gamma,data.XCorr.Asleep.zDiameter.peak_gamma,data.XCorr.All.zDiameter.peak_gamma);
gammaPeakTable.Behavior = cat(1,data.XCorr.Rest.zDiameter.behavField,data.XCorr.Rest.zDiameter.behavField,data.XCorr.NREM.zDiameter.behavField,data.XCorr.NREM.zDiameter.behavField,...
    data.XCorr.REM.zDiameter.behavField,data.XCorr.REM.zDiameter.behavField,data.XCorr.Alert.zDiameter.behavField,data.XCorr.Alert.zDiameter.behavField,...
    data.XCorr.Asleep.zDiameter.behavField,data.XCorr.Asleep.zDiameter.behavField,data.XCorr.All.zDiameter.behavField,data.XCorr.All.zDiameter.behavField);
gammaPeakTable.Hemisphere = cat(1,data.XCorr.Rest.zDiameter.LH,data.XCorr.Rest.zDiameter.RH,data.XCorr.NREM.zDiameter.LH,data.XCorr.NREM.zDiameter.RH,...
    data.XCorr.REM.zDiameter.LH,data.XCorr.REM.zDiameter.RH,data.XCorr.Alert.zDiameter.LH,data.XCorr.Alert.zDiameter.RH,...
    data.XCorr.Asleep.zDiameter.LH,data.XCorr.Asleep.zDiameter.RH,data.XCorr.All.zDiameter.LH,data.XCorr.All.zDiameter.RH);
gammaPeakFitFormula = 'Peak ~ 1 + Behavior + (1|Mouse) + (1|Mouse:Hemisphere)';
gammaPeakStats = fitglme(gammaPeakTable,gammaPeakFitFormula); %#ok<*NASGU>
%% figures
Fig2A = figure('Name','Figure Panel 2 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
%%
subplot(3,4,1);
%
p1 = plot(timeVector,procData.interWhisk.zDiameter.mean,'color',colors('vegas gold'),'LineWidth',2);
hold on
plot(timeVector,procData.interWhisk.zDiameter.mean + procData.interWhisk.zDiameter.sem,'color',colors('vegas gold'),'LineWidth',0.5)
plot(timeVector,procData.interWhisk.zDiameter.mean - procData.interWhisk.zDiameter.sem,'color',colors('vegas gold'),'LineWidth',0.5)
%
p2 = plot(timeVector,procData.stimSolenoid.zDiameter.mean,'color',colors('dark candy apple red'),'LineWidth',2);
plot(timeVector,procData.stimSolenoid.zDiameter.mean + procData.stimSolenoid.zDiameter.sem,'color',colors('dark candy apple red'),'LineWidth',0.5)
plot(timeVector,procData.stimSolenoid.zDiameter.mean - procData.stimSolenoid.zDiameter.sem,'color',colors('dark candy apple red'),'LineWidth',0.5)
%
p3 = plot(timeVector,procData.controlSolenoid.zDiameter.mean,'color',colors('deep carrot orange'),'LineWidth',2);
hold on
plot(timeVector,procData.controlSolenoid.zDiameter.mean + procData.controlSolenoid.zDiameter.sem,'color',colors('deep carrot orange'),'LineWidth',0.5)
plot(timeVector,procData.controlSolenoid.zDiameter.mean - procData.controlSolenoid.zDiameter.sem,'color',colors('deep carrot orange'),'LineWidth',0.5)
ylabel('\DeltaZ Units')
xlabel('Time (s)')
title('Evoked pupil zDiameter')
legend([p1,p2,p3],'Whisk','Stim','Aud')
set(gca,'box','off')
xlim([-2,10])
axis square
%% mm pupil diameter scatter
ax2 = subplot(3,4,2);
scatter(ones(1,length(data.Rest.indMeanDiameter))*1,data.Rest.indMeanDiameter,75,'MarkerEdgeColor','k','MarkerFaceColor',colorRest,'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.Rest.meanDiameter,data.Rest.stdDiameter,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.Whisk.indMeanDiameter))*2,data.Whisk.indMeanDiameter,75,'MarkerEdgeColor','k','MarkerFaceColor',colorWhisk,'jitter','on','jitterAmount',0.25);
e2 = errorbar(2,data.Whisk.meanDiameter,data.Whisk.stdDiameter,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
scatter(ones(1,length(data.Stim.indMeanDiameter))*3,data.Stim.indMeanDiameter,75,'MarkerEdgeColor','k','MarkerFaceColor',colorStim,'jitter','on','jitterAmount',0.25);
e3 = errorbar(3,data.Stim.meanDiameter,data.Stim.stdDiameter,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e3.Color = 'black';
e3.MarkerSize = 10;
e3.CapSize = 10;
scatter(ones(1,length(data.NREM.indMeanDiameter))*4,data.NREM.indMeanDiameter,75,'MarkerEdgeColor','k','MarkerFaceColor',colorNREM,'jitter','on','jitterAmount',0.25);
e4 = errorbar(4,data.NREM.meanDiameter,data.NREM.stdDiameter,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e4.Color = 'black';
e4.MarkerSize = 10;
e4.CapSize = 10;
scatter(ones(1,length(data.REM.indMeanDiameter))*5,data.REM.indMeanDiameter,75,'MarkerEdgeColor','k','MarkerFaceColor',colorREM,'jitter','on','jitterAmount',0.25);
e5 = errorbar(5,data.REM.meanDiameter,data.REM.stdDiameter,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e5.Color = 'black';
e5.MarkerSize = 10;
e5.CapSize = 10;
ylabel('Diameter (mm)')
title('Arousal pupil diameter (mm)')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,length(behavFields) + 1])
set(gca,'box','off')
ax2.TickLength = [0.03,0.03];
%% mm pupil diameter scatter
ax4 = subplot(3,4,3);
scatter(ones(1,length(data.Rest.indMeanzDiameter))*1,data.Rest.indMeanzDiameter,75,'MarkerEdgeColor','k','MarkerFaceColor',colorRest,'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.Rest.meanzDiameter,data.Rest.stdzDiameter,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.Whisk.indMeanzDiameter))*2,data.Whisk.indMeanzDiameter,75,'MarkerEdgeColor','k','MarkerFaceColor',colorWhisk,'jitter','on','jitterAmount',0.25);
e2 = errorbar(2,data.Whisk.meanzDiameter,data.Whisk.stdzDiameter,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
scatter(ones(1,length(data.Stim.indMeanzDiameter))*3,data.Stim.indMeanzDiameter,75,'MarkerEdgeColor','k','MarkerFaceColor',colorStim,'jitter','on','jitterAmount',0.25);
e3 = errorbar(3,data.Stim.meanzDiameter,data.Stim.stdzDiameter,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e3.Color = 'black';
e3.MarkerSize = 10;
e3.CapSize = 10;
scatter(ones(1,length(data.NREM.indMeanzDiameter))*4,data.NREM.indMeanzDiameter,75,'MarkerEdgeColor','k','MarkerFaceColor',colorNREM,'jitter','on','jitterAmount',0.25);
e4 = errorbar(4,data.NREM.meanzDiameter,data.NREM.stdzDiameter,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e4.Color = 'black';
e4.MarkerSize = 10;
e4.CapSize = 10;
scatter(ones(1,length(data.REM.indMeanzDiameter))*5,data.REM.indMeanzDiameter,75,'MarkerEdgeColor','k','MarkerFaceColor',colorREM,'jitter','on','jitterAmount',0.25);
e5 = errorbar(5,data.REM.meanzDiameter,data.REM.stdzDiameter,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e5.Color = 'black';
e5.MarkerSize = 10;
e5.CapSize = 10;
ylabel('Z units')
title('Arousal pupil diameter (z units)')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,length(behavFields) + 1])
set(gca,'box','off')
ax4.TickLength = [0.03,0.03];
%%
subplot(3,4,4);
L1 = loglog(data.Rest.zDiameter.meanf,data.Rest.zDiameter.meanS,'color',colorRest,'LineWidth',2);
hold on
rectangle('Position',[0.005,0.1,0.1 - 0.005,1],'FaceColor','w','EdgeColor','w')
L2 = loglog(data.NREM.zDiameter.meanf,data.NREM.zDiameter.meanS,'color',colorNREM,'LineWidth',2);
rectangle('Position',[0.005,0.1,1/30 - 0.005,5],'FaceColor','w','EdgeColor','w')
L3 = loglog(data.REM.zDiameter.meanf,data.REM.zDiameter.meanS,'color',colorREM,'LineWidth',2);
rectangle('Position',[0.005,0.1,1/60 - 0.005,1],'FaceColor','w','EdgeColor','w')
L4 = loglog(data.Awake.zDiameter.meanf,data.Awake.zDiameter.meanS,'color',colorAlert,'LineWidth',2);
L5 = loglog(data.Asleep.zDiameter.meanf,data.Asleep.zDiameter.meanS,'color',colorAsleep,'LineWidth',2);
L6 = loglog(data.All.zDiameter.meanf,data.All.zDiameter.meanS,'color',colorAll,'LineWidth',2);
xline(1/10,'color','k');
xline(1/30,'color','k');
xline(1/60,'color','k');
title('Pupil power spectrum')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
legend([L1,L2,L3,L4,L5,L6],'Rest','NREM','REM','Alert','Asleep','All','Location','NorthEast')
% axis square
axis tight
xlim([0.003,1])
set(gca,'box','off')
%%
subplot(3,4,5);
semilogx(data.Coherr.Rest.zDiameter.meanHbTf,data.Coherr.Rest.zDiameter.meanHbTC,'color',colorRest,'LineWidth',2);
hold on
semilogx(data.Coherr.Rest.zDiameter.meanHbTf,data.Coherr.Rest.zDiameter.meanHbTC + data.Coherr.Rest.zDiameter.semHbTC,'color',colorRest,'LineWidth',0.5);
semilogx(data.Coherr.Rest.zDiameter.meanHbTf,data.Coherr.Rest.zDiameter.meanHbTC - data.Coherr.Rest.zDiameter.semHbTC,'color',colorRest,'LineWidth',0.5);
rectangle('Position',[0.005,0.1,0.1 - 0.005,1],'FaceColor','w','EdgeColor','w')
semilogx(data.Coherr.NREM.zDiameter.meanHbTf,data.Coherr.NREM.zDiameter.meanHbTC,'color',colorNREM,'LineWidth',2);
semilogx(data.Coherr.NREM.zDiameter.meanHbTf,data.Coherr.NREM.zDiameter.meanHbTC + data.Coherr.NREM.zDiameter.semHbTC,'color',colorNREM,'LineWidth',0.5);
semilogx(data.Coherr.NREM.zDiameter.meanHbTf,data.Coherr.NREM.zDiameter.meanHbTC - data.Coherr.NREM.zDiameter.semHbTC,'color',colorNREM,'LineWidth',0.5);
rectangle('Position',[0.005,0.1,1/30 - 0.005,1],'FaceColor','w','EdgeColor','w')
semilogx(data.Coherr.REM.zDiameter.meanHbTf,data.Coherr.REM.zDiameter.meanHbTC,'color',colorREM,'LineWidth',2);
semilogx(data.Coherr.REM.zDiameter.meanHbTf,data.Coherr.REM.zDiameter.meanHbTC + data.Coherr.REM.zDiameter.semHbTC,'color',colorREM,'LineWidth',0.5);
semilogx(data.Coherr.REM.zDiameter.meanHbTf,data.Coherr.REM.zDiameter.meanHbTC - data.Coherr.REM.zDiameter.semHbTC,'color',colorREM,'LineWidth',0.5);
rectangle('Position',[0.005,0.1,1/60 - 0.005,1],'FaceColor','w','EdgeColor','w')
semilogx(data.Coherr.Awake.zDiameter.meanHbTf,data.Coherr.Awake.zDiameter.meanHbTC,'color',colorAlert,'LineWidth',2);
semilogx(data.Coherr.Awake.zDiameter.meanHbTf,data.Coherr.Awake.zDiameter.meanHbTC + data.Coherr.Awake.zDiameter.semHbTC,'color',colorAlert,'LineWidth',0.5);
semilogx(data.Coherr.Awake.zDiameter.meanHbTf,data.Coherr.Awake.zDiameter.meanHbTC - data.Coherr.Awake.zDiameter.semHbTC,'color',colorAlert,'LineWidth',0.5);
semilogx(data.Coherr.Asleep.zDiameter.meanHbTf,data.Coherr.Asleep.zDiameter.meanHbTC,'color',colorAsleep,'LineWidth',2);
semilogx(data.Coherr.Asleep.zDiameter.meanHbTf,data.Coherr.Asleep.zDiameter.meanHbTC + data.Coherr.Asleep.zDiameter.semHbTC,'color',colorAsleep,'LineWidth',0.5);
semilogx(data.Coherr.Asleep.zDiameter.meanHbTf,data.Coherr.Asleep.zDiameter.meanHbTC - data.Coherr.Asleep.zDiameter.semHbTC,'color',colorAsleep,'LineWidth',0.5);
semilogx(data.Coherr.All.zDiameter.meanHbTf,data.Coherr.All.zDiameter.meanHbTC,'color',colorAll,'LineWidth',2);
semilogx(data.Coherr.All.zDiameter.meanHbTf,data.Coherr.All.zDiameter.meanHbTC + data.Coherr.All.zDiameter.semHbTC,'color',colorAll,'LineWidth',0.5);
semilogx(data.Coherr.All.zDiameter.meanHbTf,data.Coherr.All.zDiameter.meanHbTC - data.Coherr.All.zDiameter.semHbTC,'color',colorAll,'LineWidth',0.5);
xline(1/50,'color','b');
xline(1/10,'color','k');
xline(1/30,'color','k');
xline(1/60,'color','k');
title('Pupil-HbT coherence')
ylabel('Coherence')
xlabel('Freq (Hz)')
% axis square
xlim([0.003,1])
ylim([0,1])
set(gca,'box','off')
%% HbT:Pupil Stats
subplot(3,4,6)
scatter(ones(1,length(data.Coherr.Awake.zDiameter.HbTC002))*1,data.Coherr.Awake.zDiameter.HbTC002,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAlert,'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.Coherr.Awake.zDiameter.meanHbTC002,data.Coherr.Awake.zDiameter.stdHbTC002,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.Coherr.Asleep.zDiameter.HbTC002))*2,data.Coherr.Asleep.zDiameter.HbTC002,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAsleep,'jitter','on','jitterAmount',0.25);
hold on
e2 = errorbar(2,data.Coherr.Asleep.zDiameter.meanHbTC002,data.Coherr.Asleep.zDiameter.stdHbTC002,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
scatter(ones(1,length(data.Coherr.All.zDiameter.HbTC002))*3,data.Coherr.All.zDiameter.HbTC002,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAll,'jitter','on','jitterAmount',0.25);
hold on
e3 = errorbar(3,data.Coherr.All.zDiameter.meanHbTC002,data.Coherr.All.zDiameter.stdHbTC002,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e3.Color = 'black';
e3.MarkerSize = 10;
e3.CapSize = 10;
title('Pupil-HbT coherence @ 0.02 Hz')
ylabel('Coherece')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,4])
set(gca,'box','off')
ax2.TickLength = [0.03,0.03];
%%
subplot(3,4,7);
semilogx(data.Coherr.Rest.zDiameter.meanGammaf,data.Coherr.Rest.zDiameter.meanGammaC,'color',colorRest,'LineWidth',2);
hold on
semilogx(data.Coherr.Rest.zDiameter.meanGammaf,data.Coherr.Rest.zDiameter.meanGammaC + data.Coherr.Rest.zDiameter.semGammaC,'color',colorRest,'LineWidth',0.5);
semilogx(data.Coherr.Rest.zDiameter.meanGammaf,data.Coherr.Rest.zDiameter.meanGammaC - data.Coherr.Rest.zDiameter.semGammaC,'color',colorRest,'LineWidth',0.5);
rectangle('Position',[0.005,0.1,0.1 - 0.005,1],'FaceColor','w','EdgeColor','w')
semilogx(data.Coherr.NREM.zDiameter.meanGammaf,data.Coherr.NREM.zDiameter.meanGammaC,'color',colorNREM,'LineWidth',2);
semilogx(data.Coherr.NREM.zDiameter.meanGammaf,data.Coherr.NREM.zDiameter.meanGammaC + data.Coherr.NREM.zDiameter.semGammaC,'color',colorNREM,'LineWidth',0.5);
semilogx(data.Coherr.NREM.zDiameter.meanGammaf,data.Coherr.NREM.zDiameter.meanGammaC - data.Coherr.NREM.zDiameter.semGammaC,'color',colorNREM,'LineWidth',0.5);
rectangle('Position',[0.005,0.1,1/30 - 0.005,1],'FaceColor','w','EdgeColor','w')
semilogx(data.Coherr.REM.zDiameter.meanGammaf,data.Coherr.REM.zDiameter.meanGammaC,'color',colorREM,'LineWidth',2);
semilogx(data.Coherr.REM.zDiameter.meanGammaf,data.Coherr.REM.zDiameter.meanGammaC + data.Coherr.REM.zDiameter.semGammaC,'color',colorREM,'LineWidth',0.5);
semilogx(data.Coherr.REM.zDiameter.meanGammaf,data.Coherr.REM.zDiameter.meanGammaC - data.Coherr.REM.zDiameter.semGammaC,'color',colorREM,'LineWidth',0.5);
rectangle('Position',[0.005,0.1,1/60 - 0.005,1],'FaceColor','w','EdgeColor','w')
semilogx(data.Coherr.Awake.zDiameter.meanGammaf,data.Coherr.Awake.zDiameter.meanGammaC,'color',colorAlert,'LineWidth',2);
semilogx(data.Coherr.Awake.zDiameter.meanGammaf,data.Coherr.Awake.zDiameter.meanGammaC + data.Coherr.Awake.zDiameter.semGammaC,'color',colorAlert,'LineWidth',0.5);
semilogx(data.Coherr.Awake.zDiameter.meanGammaf,data.Coherr.Awake.zDiameter.meanGammaC - data.Coherr.Awake.zDiameter.semGammaC,'color',colorAlert,'LineWidth',0.5);
semilogx(data.Coherr.Asleep.zDiameter.meanGammaf,data.Coherr.Asleep.zDiameter.meanGammaC,'color',colorAsleep,'LineWidth',2);
semilogx(data.Coherr.Asleep.zDiameter.meanGammaf,data.Coherr.Asleep.zDiameter.meanGammaC + data.Coherr.Asleep.zDiameter.semGammaC,'color',colorAsleep,'LineWidth',0.5);
semilogx(data.Coherr.Asleep.zDiameter.meanGammaf,data.Coherr.Asleep.zDiameter.meanGammaC - data.Coherr.Asleep.zDiameter.semGammaC,'color',colorAsleep,'LineWidth',0.5);
semilogx(data.Coherr.All.zDiameter.meanGammaf,data.Coherr.All.zDiameter.meanGammaC,'color',colorAll,'LineWidth',2);
semilogx(data.Coherr.All.zDiameter.meanGammaf,data.Coherr.All.zDiameter.meanGammaC + data.Coherr.All.zDiameter.semGammaC,'color',colorAll,'LineWidth',0.5);
semilogx(data.Coherr.All.zDiameter.meanGammaf,data.Coherr.All.zDiameter.meanGammaC - data.Coherr.All.zDiameter.semGammaC,'color',colorAll,'LineWidth',0.5);
xline(1/50,'color','b');
xline(1/10,'color','k');
xline(1/30,'color','k');
xline(1/60,'color','k');
title('Pupil-Gamma coherence')
ylabel('Coherence')
xlabel('Freq (Hz)')
% axis square
xlim([0.003,1])
ylim([0,1])
set(gca,'box','off')
%% gamma:Pupil Stats
subplot(3,4,8)
scatter(ones(1,length(data.Coherr.Awake.zDiameter.gammaC002))*1,data.Coherr.Awake.zDiameter.gammaC002,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAlert,'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.Coherr.Awake.zDiameter.meanGammaC002,data.Coherr.Awake.zDiameter.stdGammaC002,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.Coherr.Asleep.zDiameter.gammaC002))*2,data.Coherr.Asleep.zDiameter.gammaC002,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAsleep,'jitter','on','jitterAmount',0.25);
hold on
e2 = errorbar(2,data.Coherr.Asleep.zDiameter.meanGammaC002,data.Coherr.Asleep.zDiameter.stdGammaC002,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
scatter(ones(1,length(data.Coherr.All.zDiameter.gammaC002))*3,data.Coherr.All.zDiameter.gammaC002,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAll,'jitter','on','jitterAmount',0.25);
hold on
e3 = errorbar(3,data.Coherr.All.zDiameter.meanGammaC002,data.Coherr.All.zDiameter.stdGammaC002,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e3.Color = 'black';
e3.MarkerSize = 10;
e3.CapSize = 10;
title('Pupil-Gamma coherence @ 0.02 Hz')
ylabel('Coherence')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,4])
set(gca,'box','off')
ax2.TickLength = [0.03,0.03];
%% HbT-Pupil cross correlation [rest, NREM, REM]
subplot(3,4,9);
freq = 30;
lagSec = 5;
plot(data.XCorr.Rest.zDiameter.meanLags,data.XCorr.Rest.zDiameter.meanXcVals_HbT,'color',colorRest,'LineWidth',2);
hold on
plot(data.XCorr.Rest.zDiameter.meanLags,data.XCorr.Rest.zDiameter.meanXcVals_HbT + data.XCorr.Rest.zDiameter.semXcVals_HbT,'color',colorRest,'LineWidth',0.5);
plot(data.XCorr.Rest.zDiameter.meanLags,data.XCorr.Rest.zDiameter.meanXcVals_HbT - data.XCorr.Rest.zDiameter.semXcVals_HbT,'color',colorRest,'LineWidth',0.5);
plot(data.XCorr.NREM.zDiameter.meanLags,data.XCorr.NREM.zDiameter.meanXcVals_HbT,'color',colorNREM,'LineWidth',2);
plot(data.XCorr.NREM.zDiameter.meanLags,data.XCorr.NREM.zDiameter.meanXcVals_HbT + data.XCorr.NREM.zDiameter.semXcVals_HbT,'color',colorNREM,'LineWidth',0.5);
plot(data.XCorr.NREM.zDiameter.meanLags,data.XCorr.NREM.zDiameter.meanXcVals_HbT - data.XCorr.NREM.zDiameter.semXcVals_HbT,'color',colorNREM,'LineWidth',0.5);
plot(data.XCorr.REM.zDiameter.meanLags,data.XCorr.REM.zDiameter.meanXcVals_HbT,'color',colorREM,'LineWidth',2);
plot(data.XCorr.REM.zDiameter.meanLags,data.XCorr.REM.zDiameter.meanXcVals_HbT + data.XCorr.REM.zDiameter.semXcVals_HbT,'color',colorREM,'LineWidth',0.5);
plot(data.XCorr.REM.zDiameter.meanLags,data.XCorr.REM.zDiameter.meanXcVals_HbT - data.XCorr.REM.zDiameter.semXcVals_HbT,'color',colorREM,'LineWidth',0.5);
title({'Blank-SAP treated RH REM','MUA-[HbT] XCorr'})
xticks([-lagSec*freq,-lagSec*freq/2,0,lagSec*freq/2,lagSec*freq])
xticklabels({'-5','-2.5','0','2.5','5'})
xlim([-lagSec*freq,lagSec*freq])
xlabel('Lags (s)')
ylabel('Correlation')
title('Pupil-HbT XCorr')
axis square
set(gca,'box','off')
%% HbT-Pupil cross correlation [alert, asleep, all]
subplot(3,4,10);
freq = 30;
lagSec = 10;
plot(data.XCorr.Alert.zDiameter.meanLags,data.XCorr.Alert.zDiameter.meanXcVals_HbT,'color',colorAlert,'LineWidth',2);
hold on
plot(data.XCorr.Alert.zDiameter.meanLags,data.XCorr.Alert.zDiameter.meanXcVals_HbT + data.XCorr.Alert.zDiameter.semXcVals_HbT,'color',colorAlert,'LineWidth',0.5);
plot(data.XCorr.Alert.zDiameter.meanLags,data.XCorr.Alert.zDiameter.meanXcVals_HbT - data.XCorr.Alert.zDiameter.semXcVals_HbT,'color',colorAlert,'LineWidth',0.5);
plot(data.XCorr.Asleep.zDiameter.meanLags,data.XCorr.Asleep.zDiameter.meanXcVals_HbT,'color',colorAsleep,'LineWidth',2);
plot(data.XCorr.Asleep.zDiameter.meanLags,data.XCorr.Asleep.zDiameter.meanXcVals_HbT + data.XCorr.Asleep.zDiameter.semXcVals_HbT,'color',colorAsleep,'LineWidth',0.5);
plot(data.XCorr.Asleep.zDiameter.meanLags,data.XCorr.Asleep.zDiameter.meanXcVals_HbT - data.XCorr.Asleep.zDiameter.semXcVals_HbT,'color',colorAsleep,'LineWidth',0.5);
plot(data.XCorr.All.zDiameter.meanLags,data.XCorr.All.zDiameter.meanXcVals_HbT,'color',colorAll,'LineWidth',2);
plot(data.XCorr.All.zDiameter.meanLags,data.XCorr.All.zDiameter.meanXcVals_HbT + data.XCorr.All.zDiameter.semXcVals_HbT,'color',colorAll,'LineWidth',0.5);
plot(data.XCorr.All.zDiameter.meanLags,data.XCorr.All.zDiameter.meanXcVals_HbT - data.XCorr.All.zDiameter.semXcVals_HbT,'color',colorAll,'LineWidth',0.5);
title({'Blank-SAP treated RH REM','MUA-[HbT] XCorr'})
xticks([-lagSec*freq,-lagSec*freq/2,0,lagSec*freq/2,lagSec*freq])
xticklabels({'-10','-5','0','5','10'})
xlim([-lagSec*freq,lagSec*freq])
xlabel('Lags (s)')
ylabel('Correlation')
title('Pupil-HbT XCorr')
axis square
set(gca,'box','off')
%% Gamma-Pupil cross correlation [rest, NREM, REM]
subplot(3,4,11);
freq = 30;
lagSec = 5;
plot(data.XCorr.Rest.zDiameter.meanLags,data.XCorr.Rest.zDiameter.meanXcVals_gamma,'color',colorRest,'LineWidth',2);
hold on
plot(data.XCorr.Rest.zDiameter.meanLags,data.XCorr.Rest.zDiameter.meanXcVals_gamma + data.XCorr.Rest.zDiameter.semXcVals_gamma,'color',colorRest,'LineWidth',0.5);
plot(data.XCorr.Rest.zDiameter.meanLags,data.XCorr.Rest.zDiameter.meanXcVals_gamma - data.XCorr.Rest.zDiameter.semXcVals_gamma,'color',colorRest,'LineWidth',0.5);
plot(data.XCorr.NREM.zDiameter.meanLags,data.XCorr.NREM.zDiameter.meanXcVals_gamma,'color',colorNREM,'LineWidth',2);
plot(data.XCorr.NREM.zDiameter.meanLags,data.XCorr.NREM.zDiameter.meanXcVals_gamma + data.XCorr.NREM.zDiameter.semXcVals_gamma,'color',colorNREM,'LineWidth',0.5);
plot(data.XCorr.NREM.zDiameter.meanLags,data.XCorr.NREM.zDiameter.meanXcVals_gamma - data.XCorr.NREM.zDiameter.semXcVals_gamma,'color',colorNREM,'LineWidth',0.5);
plot(data.XCorr.REM.zDiameter.meanLags,data.XCorr.REM.zDiameter.meanXcVals_gamma,'color',colorREM,'LineWidth',2);
plot(data.XCorr.REM.zDiameter.meanLags,data.XCorr.REM.zDiameter.meanXcVals_gamma + data.XCorr.REM.zDiameter.semXcVals_gamma,'color',colorREM,'LineWidth',0.5);
plot(data.XCorr.REM.zDiameter.meanLags,data.XCorr.REM.zDiameter.meanXcVals_gamma - data.XCorr.REM.zDiameter.semXcVals_gamma,'color',colorREM,'LineWidth',0.5);
title({'Blank-SAP treated RH REM','MUA-[HbT] XCorr'})
xticks([-lagSec*freq,-lagSec*freq/2,0,lagSec*freq/2,lagSec*freq])
xticklabels({'-5','-2.5','0','2.5','5'})
xlim([-lagSec*freq,lagSec*freq])
xlabel('Lags (s)')
ylabel('Correlation')
title('Pupil-Gamma XCorr')
axis square
set(gca,'box','off')
%% Gamma-Pupil cross correlation [alert, asleep, all]
subplot(3,4,12);
freq = 30;
lagSec = 10;
plot(data.XCorr.Alert.zDiameter.meanLags,data.XCorr.Alert.zDiameter.meanXcVals_gamma,'color',colorAlert,'LineWidth',2);
hold on
plot(data.XCorr.Alert.zDiameter.meanLags,data.XCorr.Alert.zDiameter.meanXcVals_gamma + data.XCorr.Alert.zDiameter.semXcVals_gamma,'color',colorAlert,'LineWidth',0.5);
plot(data.XCorr.Alert.zDiameter.meanLags,data.XCorr.Alert.zDiameter.meanXcVals_gamma - data.XCorr.Alert.zDiameter.semXcVals_gamma,'color',colorAlert,'LineWidth',0.5);
plot(data.XCorr.Asleep.zDiameter.meanLags,data.XCorr.Asleep.zDiameter.meanXcVals_gamma,'color',colorAsleep,'LineWidth',2);
plot(data.XCorr.Asleep.zDiameter.meanLags,data.XCorr.Asleep.zDiameter.meanXcVals_gamma + data.XCorr.Asleep.zDiameter.semXcVals_gamma,'color',colorAsleep,'LineWidth',0.5);
plot(data.XCorr.Asleep.zDiameter.meanLags,data.XCorr.Asleep.zDiameter.meanXcVals_gamma - data.XCorr.Asleep.zDiameter.semXcVals_gamma,'color',colorAsleep,'LineWidth',0.5);
plot(data.XCorr.All.zDiameter.meanLags,data.XCorr.All.zDiameter.meanXcVals_gamma,'color',colorAll,'LineWidth',2);
plot(data.XCorr.All.zDiameter.meanLags,data.XCorr.All.zDiameter.meanXcVals_gamma + data.XCorr.All.zDiameter.semXcVals_gamma,'color',colorAll,'LineWidth',0.5);
plot(data.XCorr.All.zDiameter.meanLags,data.XCorr.All.zDiameter.meanXcVals_gamma - data.XCorr.All.zDiameter.semXcVals_gamma,'color',colorAll,'LineWidth',0.5);
title({'Blank-SAP treated RH REM','MUA-[HbT] XCorr'})
xticks([-lagSec*freq,-lagSec*freq/2,0,lagSec*freq/2,lagSec*freq])
xticklabels({'-10','-5','0','5','10'})
xlim([-lagSec*freq,lagSec*freq])
xlabel('Lags (s)')
ylabel('Correlation')
title('Pupil-Gamma XCorr')
axis square
set(gca,'box','off')
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'Summary Figures and Structures' delim 'Figure Panels' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig2A,[dirpath 'Fig2A_JNeurosci2022']);
    set(Fig2A,'PaperPositionMode','auto');
    print('-vector','-dpdf','-bestfit',[dirpath 'Fig2A_JNeurosci2022'])
end
%%
Fig2B = figure('Name','Figure Panel 2 - Turner et al. 2022','Units','Normalized','OuterPosition',[0,0,1,1]);
subplot(2,2,1)
scatter(ones(1,length(data.XCorr.Rest.zDiameter.peak_HbT))*1,data.XCorr.Rest.zDiameter.peak_HbT,75,'MarkerEdgeColor','k','MarkerFaceColor',colorRest,'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.XCorr.Rest.zDiameter.meanPeak_HbT,data.XCorr.Rest.zDiameter.stdPeak_HbT,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.XCorr.NREM.zDiameter.peak_HbT))*2,data.XCorr.NREM.zDiameter.peak_HbT,75,'MarkerEdgeColor','k','MarkerFaceColor',colorNREM,'jitter','on','jitterAmount',0.25);
hold on
e2 = errorbar(2,data.XCorr.NREM.zDiameter.meanPeak_HbT,data.XCorr.NREM.zDiameter.stdPeak_HbT,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
scatter(ones(1,length(data.XCorr.REM.zDiameter.peak_HbT))*3,data.XCorr.REM.zDiameter.peak_HbT,75,'MarkerEdgeColor','k','MarkerFaceColor',colorREM,'jitter','on','jitterAmount',0.25);
hold on
e3 = errorbar(3,data.XCorr.REM.zDiameter.meanPeak_HbT,data.XCorr.REM.zDiameter.stdPeak_HbT,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e3.Color = 'black';
e3.MarkerSize = 10;
e3.CapSize = 10;
scatter(ones(1,length(data.XCorr.Alert.zDiameter.peak_HbT))*4,data.XCorr.Alert.zDiameter.peak_HbT,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAlert,'jitter','on','jitterAmount',0.25);
hold on
e4 = errorbar(4,data.XCorr.Alert.zDiameter.meanPeak_HbT,data.XCorr.Alert.zDiameter.stdPeak_HbT,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e4.Color = 'black';
e4.MarkerSize = 10;
e4.CapSize = 10;
scatter(ones(1,length(data.XCorr.Asleep.zDiameter.peak_HbT))*5,data.XCorr.Asleep.zDiameter.peak_HbT,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAsleep,'jitter','on','jitterAmount',0.25);
hold on
e5 = errorbar(5,data.XCorr.Asleep.zDiameter.meanPeak_HbT,data.XCorr.Asleep.zDiameter.stdPeak_HbT,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e5.Color = 'black';
e5.MarkerSize = 10;
e5.CapSize = 10;
scatter(ones(1,length(data.XCorr.All.zDiameter.peak_HbT))*6,data.XCorr.All.zDiameter.peak_HbT,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAll,'jitter','on','jitterAmount',0.25);
hold on
e6 = errorbar(6,data.XCorr.All.zDiameter.meanPeak_HbT,data.XCorr.All.zDiameter.stdPeak_HbT,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e6.Color = 'black';
e6.MarkerSize = 10;
e6.CapSize = 10;
title('HbT peak correlation')
ylabel('Corr. Coef')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,7])
set(gca,'box','off')
ax2.TickLength = [0.03,0.03];
%%
subplot(2,2,2)
scatter(ones(1,length(data.XCorr.Rest.zDiameter.peakLag_HbT))*1,data.XCorr.Rest.zDiameter.peakLag_HbT,75,'MarkerEdgeColor','k','MarkerFaceColor',colorRest,'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.XCorr.Rest.zDiameter.meanPeakLag_HbT,data.XCorr.Rest.zDiameter.stdPeakLag_HbT,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.XCorr.NREM.zDiameter.peakLag_HbT))*2,data.XCorr.NREM.zDiameter.peakLag_HbT,75,'MarkerEdgeColor','k','MarkerFaceColor',colorNREM,'jitter','on','jitterAmount',0.25);
hold on
e2 = errorbar(2,data.XCorr.NREM.zDiameter.meanPeakLag_HbT,data.XCorr.NREM.zDiameter.stdPeakLag_HbT,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
scatter(ones(1,length(data.XCorr.REM.zDiameter.peakLag_HbT))*3,data.XCorr.REM.zDiameter.peakLag_HbT,75,'MarkerEdgeColor','k','MarkerFaceColor',colorREM,'jitter','on','jitterAmount',0.25);
hold on
e3 = errorbar(3,data.XCorr.REM.zDiameter.meanPeakLag_HbT,data.XCorr.REM.zDiameter.stdPeakLag_HbT,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e3.Color = 'black';
e3.MarkerSize = 10;
e3.CapSize = 10;
scatter(ones(1,length(data.XCorr.Alert.zDiameter.peakLag_HbT))*4,data.XCorr.Alert.zDiameter.peakLag_HbT,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAlert,'jitter','on','jitterAmount',0.25);
hold on
e4 = errorbar(4,data.XCorr.Alert.zDiameter.meanPeakLag_HbT,data.XCorr.Alert.zDiameter.stdPeakLag_HbT,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e4.Color = 'black';
e4.MarkerSize = 10;
e4.CapSize = 10;
scatter(ones(1,length(data.XCorr.Asleep.zDiameter.peakLag_HbT))*5,data.XCorr.Asleep.zDiameter.peakLag_HbT,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAsleep,'jitter','on','jitterAmount',0.25);
hold on
e5 = errorbar(5,data.XCorr.Asleep.zDiameter.meanPeakLag_HbT,data.XCorr.Asleep.zDiameter.stdPeakLag_HbT,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e5.Color = 'black';
e5.MarkerSize = 10;
e5.CapSize = 10;
scatter(ones(1,length(data.XCorr.All.zDiameter.peakLag_HbT))*6,data.XCorr.All.zDiameter.peakLag_HbT,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAll,'jitter','on','jitterAmount',0.25);
hold on
e6 = errorbar(6,data.XCorr.All.zDiameter.meanPeakLag_HbT,data.XCorr.All.zDiameter.stdPeakLag_HbT,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e6.Color = 'black';
e6.MarkerSize = 10;
e6.CapSize = 10;
title('HbT peak lag time')
ylabel('Time (s)')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,7])
set(gca,'box','off')
ax2.TickLength = [0.03,0.03];
%%
subplot(2,2,3)
scatter(ones(1,length(data.XCorr.Rest.zDiameter.peak_gamma))*1,data.XCorr.Rest.zDiameter.peak_gamma,75,'MarkerEdgeColor','k','MarkerFaceColor',colorRest,'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.XCorr.Rest.zDiameter.meanPeak_gamma,data.XCorr.Rest.zDiameter.stdPeak_gamma,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.XCorr.NREM.zDiameter.peak_gamma))*2,data.XCorr.NREM.zDiameter.peak_gamma,75,'MarkerEdgeColor','k','MarkerFaceColor',colorNREM,'jitter','on','jitterAmount',0.25);
hold on
e2 = errorbar(2,data.XCorr.NREM.zDiameter.meanPeak_gamma,data.XCorr.NREM.zDiameter.stdPeak_gamma,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
scatter(ones(1,length(data.XCorr.REM.zDiameter.peak_gamma))*3,data.XCorr.REM.zDiameter.peak_gamma,75,'MarkerEdgeColor','k','MarkerFaceColor',colorREM,'jitter','on','jitterAmount',0.25);
hold on
e3 = errorbar(3,data.XCorr.REM.zDiameter.meanPeak_gamma,data.XCorr.REM.zDiameter.stdPeak_gamma,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e3.Color = 'black';
e3.MarkerSize = 10;
e3.CapSize = 10;
scatter(ones(1,length(data.XCorr.Alert.zDiameter.peak_gamma))*4,data.XCorr.Alert.zDiameter.peak_gamma,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAlert,'jitter','on','jitterAmount',0.25);
hold on
e4 = errorbar(4,data.XCorr.Alert.zDiameter.meanPeak_gamma,data.XCorr.Alert.zDiameter.stdPeak_gamma,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e4.Color = 'black';
e4.MarkerSize = 10;
e4.CapSize = 10;
scatter(ones(1,length(data.XCorr.Asleep.zDiameter.peak_gamma))*5,data.XCorr.Asleep.zDiameter.peak_gamma,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAsleep,'jitter','on','jitterAmount',0.25);
hold on
e5 = errorbar(5,data.XCorr.Asleep.zDiameter.meanPeak_gamma,data.XCorr.Asleep.zDiameter.stdPeak_gamma,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e5.Color = 'black';
e5.MarkerSize = 10;
e5.CapSize = 10;
scatter(ones(1,length(data.XCorr.All.zDiameter.peak_gamma))*6,data.XCorr.All.zDiameter.peak_gamma,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAll,'jitter','on','jitterAmount',0.25);
hold on
e6 = errorbar(6,data.XCorr.All.zDiameter.meanPeak_gamma,data.XCorr.All.zDiameter.stdPeak_gamma,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e6.Color = 'black';
e6.MarkerSize = 10;
e6.CapSize = 10;
title('Gamma peak correlation')
ylabel('Corr. Coef')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,7])
set(gca,'box','off')
ax2.TickLength = [0.03,0.03];
%%
subplot(2,2,4)
scatter(ones(1,length(data.XCorr.Rest.zDiameter.peakLag_gamma))*1,data.XCorr.Rest.zDiameter.peakLag_gamma,75,'MarkerEdgeColor','k','MarkerFaceColor',colorRest,'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.XCorr.Rest.zDiameter.meanPeakLag_gamma,data.XCorr.Rest.zDiameter.stdPeakLag_gamma,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(ones(1,length(data.XCorr.NREM.zDiameter.peakLag_gamma))*2,data.XCorr.NREM.zDiameter.peakLag_gamma,75,'MarkerEdgeColor','k','MarkerFaceColor',colorNREM,'jitter','on','jitterAmount',0.25);
hold on
e2 = errorbar(2,data.XCorr.NREM.zDiameter.meanPeakLag_gamma,data.XCorr.NREM.zDiameter.stdPeakLag_gamma,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
scatter(ones(1,length(data.XCorr.REM.zDiameter.peakLag_gamma))*3,data.XCorr.REM.zDiameter.peakLag_gamma,75,'MarkerEdgeColor','k','MarkerFaceColor',colorREM,'jitter','on','jitterAmount',0.25);
hold on
e3 = errorbar(3,data.XCorr.REM.zDiameter.meanPeakLag_gamma,data.XCorr.REM.zDiameter.stdPeakLag_gamma,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e3.Color = 'black';
e3.MarkerSize = 10;
e3.CapSize = 10;
scatter(ones(1,length(data.XCorr.Alert.zDiameter.peakLag_gamma))*4,data.XCorr.Alert.zDiameter.peakLag_gamma,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAlert,'jitter','on','jitterAmount',0.25);
hold on
e4 = errorbar(4,data.XCorr.Alert.zDiameter.meanPeakLag_gamma,data.XCorr.Alert.zDiameter.stdPeakLag_gamma,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e4.Color = 'black';
e4.MarkerSize = 10;
e4.CapSize = 10;
scatter(ones(1,length(data.XCorr.Asleep.zDiameter.peakLag_gamma))*5,data.XCorr.Asleep.zDiameter.peakLag_gamma,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAsleep,'jitter','on','jitterAmount',0.25);
hold on
e5 = errorbar(5,data.XCorr.Asleep.zDiameter.meanPeakLag_gamma,data.XCorr.Asleep.zDiameter.stdPeakLag_gamma,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e5.Color = 'black';
e5.MarkerSize = 10;
e5.CapSize = 10;
scatter(ones(1,length(data.XCorr.All.zDiameter.peakLag_gamma))*6,data.XCorr.All.zDiameter.peakLag_gamma,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAll,'jitter','on','jitterAmount',0.25);
hold on
e6 = errorbar(6,data.XCorr.All.zDiameter.meanPeakLag_gamma,data.XCorr.All.zDiameter.stdPeakLag_gamma,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e6.Color = 'black';
e6.MarkerSize = 10;
e6.CapSize = 10;
title('Gamma peak lag time')
ylabel('Time (s)')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,7])
set(gca,'box','off')
ax2.TickLength = [0.03,0.03];
%% save figure(s)
if saveFigs == true
    dirpath = [rootFolder delim 'Summary Figures and Structures' delim 'Figure Panels' delim];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(Fig2B,[dirpath 'Fig2B_JNeurosci2022']);
    set(Fig2B,'PaperPositionMode','auto');
    print('-vector','-dpdf','-bestfit',[dirpath 'Fig2B_JNeurosci2022'])
end

end
