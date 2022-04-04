function [Results_PowerSpectrum] = AnalyzePowerSpectrum_Pupil(animalID,rootFolder,delim,Results_PowerSpectrum)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Analyze the spectral power of hemodynamic [HbT] and neural signals (IOS)
%________________________________________________________________________________________________________________________

%% function parameters
dataTypes = {'mmArea','mmDiameter','zArea','zDiameter','LH_HbT','RH_HbT','LH_gammaBandPower','RH_gammaBandPower'};
modelType = 'Forest';
params.minTime.Rest = 10;
params.minTime.NREM = 30;
params.minTime.REM = 60;
%% only run analysis for valid animal IDs
dataLocation = [rootFolder delim 'Data' delim animalID delim 'Bilateral Imaging'];
cd(dataLocation)
% character list of all ProcData file IDs
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
% find and load RestData.mat struct
restDataFileStruct = dir('*_RestData.mat');
restDataFile = {restDataFileStruct.name}';
restDataFileID = char(restDataFile);
load(restDataFileID,'-mat')
% find and load manual baseline event information
manualBaselineFileStruct = dir('*_ManualBaselineFileList.mat');
manualBaselineFile = {manualBaselineFileStruct.name}';
manualBaselineFileID = char(manualBaselineFile);
load(manualBaselineFileID,'-mat')
% find and load RestingBaselines.mat strut
baselineDataFileStruct = dir('*_RestingBaselines.mat');
baselineDataFile = {baselineDataFileStruct.name}';
baselineDataFileID = char(baselineDataFile);
load(baselineDataFileID,'-mat')
% find and load SleepData.mat strut
SleepDataFileStruct = dir('*_SleepData.mat');
SleepDataFile = {SleepDataFileStruct.name}';
SleepDataFileID = char(SleepDataFile);
load(SleepDataFileID,'-mat')
% scoring results
% find and load manual baseline event information
scoringResultsFileStruct = dir('*Forest_ScoringResults.mat');
scoringResultsFile = {scoringResultsFileStruct.name}';
scoringResultsFileID = char(scoringResultsFile);
load(scoringResultsFileID,'-mat')
samplingRate = RestData.CBV_HbT.adjLH.CBVCamSamplingRate;
% criteria for resting
RestCriteria.Fieldname = {'durations'};
RestCriteria.Comparison = {'gt'};
RestCriteria.Value = {params.minTime.Rest};
RestPuffCriteria.Fieldname = {'puffDistances'};
RestPuffCriteria.Comparison = {'gt'};
RestPuffCriteria.Value = {5};
% go through each valid data type for behavior-based power spectrum analysis
for aa = 1:length(dataTypes)
    dataType = dataTypes{1,aa};
    %% analyze power spectra during periods of rest
    % pull data from RestData.mat structure
    [restLogical] = FilterEvents_IOS(RestData.Pupil.(dataType),RestCriteria);
    [puffLogical] = FilterEvents_IOS(RestData.Pupil.(dataType),RestPuffCriteria);
    combRestLogical = logical(restLogical.*puffLogical);
    restFileIDs = RestData.Pupil.(dataType).fileIDs(combRestLogical,:);
    restEventTimes = RestData.Pupil.(dataType).eventTimes(combRestLogical,:);
    restDurations = RestData.Pupil.(dataType).durations(combRestLogical,:);
    restData = RestData.Pupil.(dataType).data(combRestLogical,:);
    % keep only the data that occurs within the manually-approved awake regions
    [finalRestData,~,~,~] = RemoveInvalidData_IOS(restData,restFileIDs,restDurations,restEventTimes,ManualDecisions);
    clear procRestData
    if isempty(finalRestData) == false
        % detrend and truncate data to minimum length to match events
        for bb = 1:length(finalRestData)
            if length(finalRestData{bb,1}) < params.minTime.Rest*samplingRate
                restChunkSampleDiff = params.minTime.Rest*samplingRate - length(finalRestData{bb,1});
                restPad = (ones(1,restChunkSampleDiff))*finalRestData{bb,1}(end);
                procRestData{bb,1} = horzcat(finalRestData{bb,1},restPad); %#ok<*AGROW>
                procRestData{bb,1} = detrend(procRestData{bb,1},'constant');
            else
                procRestData{bb,1} = detrend(finalRestData{bb,1}(1:(params.minTime.Rest*samplingRate)),'constant');
            end
        end
        % input data as time (1st dimension, vertical) by trials (2nd dimension, horizontunstimy)
        zz = 1;
        for cc = 1:length(procRestData)
            if sum(isnan(procRestData{cc,1})) == 0
                restDataMat(:,zz) = procRestData{cc,1};
                zz = zz + 1;
            end
        end
        % parameters for mtspectrumc - information available in function
        params.tapers = [1,1];   % Tapers [n, 2n - 1]
        params.pad = 1;
        params.Fs = samplingRate;
        params.fpass = [0,1];   % Pass band [0, nyquist]
        params.trialave = 1;
        params.err = [2,0.05];
        % calculate the power spectra of the desired signals
        [rest_S,rest_f,rest_sErr] = mtspectrumc(restDataMat,params);
        % save results
        Results_PowerSpectrum.(animalID).Rest.(dataType).S = rest_S;
        Results_PowerSpectrum.(animalID).Rest.(dataType).f = rest_f;
        Results_PowerSpectrum.(animalID).Rest.(dataType).sErr = rest_sErr;
    else
        % save results
        Results_PowerSpectrum.(animalID).Rest.(dataType).S = [];
        Results_PowerSpectrum.(animalID).Rest.(dataType).f = [];
        Results_PowerSpectrum.(animalID).Rest.(dataType).sErr = [];
    end
    %% analyze power spectra during periods of alert
    zz = 1;
    clear awakeData procAwakeData
    awakeData = [];
    for bb = 1:size(procDataFileIDs,1)
        procDataFileID = procDataFileIDs(bb,:);
        [~,fileDate,awakeDataFileID] = GetFileInfo_IOS(procDataFileID);
        strDay = ConvertDate_IOS(fileDate);
        scoringLabels = [];
        for cc = 1:length(ScoringResults.fileIDs)
            if strcmp(awakeDataFileID,ScoringResults.fileIDs{cc,1}) == true
                scoringLabels = ScoringResults.labels{cc,1};
            end
        end
        % check labels to match arousal state
        if sum(strcmp(scoringLabels,'Not Sleep')) > 144   % 36 bins (180 total) or 3 minutes of Asleep
            load(procDataFileID,'-mat')
            if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
                try
                    puffs = ProcData.data.stimulations.LPadSol;
                catch
                    puffs = ProcData.data.solenoids.LPadSol;
                end
                % don't include trials with stimulation
                if isempty(puffs) == true
                    if strcmp(dataType,'LH_HbT') == true
                        awakeData{zz,1} = ProcData.data.CBV_HbT.adjLH;
                        zz = zz + 1;
                    elseif strcmp(dataType,'RH_HbT') == true
                        awakeData{zz,1} = ProcData.data.CBV_HbT.adjRH;
                        zz = zz + 1;
                    elseif strcmp(dataType,'LH_gammaBandPower') == true
                        awakeData{zz,1} = (ProcData.data.cortical_RH.gammaBandPower - RestingBaselines.manualSelection.cortical_LH.gammaBandPower.(strDay).mean)./RestingBaselines.manualSelection.cortical_LH.gammaBandPower.(strDay).mean;
                        zz = zz + 1;
                    elseif strcmp(dataType,'RH_gammaBandPower') == true
                        awakeData{zz,1} = (ProcData.data.cortical_RH.gammaBandPower - RestingBaselines.manualSelection.cortical_RH.gammaBandPower.(strDay).mean)./RestingBaselines.manualSelection.cortical_RH.gammaBandPower.(strDay).mean;
                        zz = zz + 1;
                    else
                        if sum(isnan(ProcData.data.Pupil.(dataType))) == 0
                            awakeData{zz,1} = ProcData.data.Pupil.(dataType);
                            zz = zz + 1;
                        end
                    end
                end
            end
        end
    end
    if isempty(awakeData) == false
        % detrend data
        for bb = 1:length(awakeData)
            procAwakeData{bb,1} = detrend(awakeData{bb,1},'constant');
        end
        % input data as time (1st dimension, vertical) by trials (2nd dimension, horizontunstimy)
        awakeDataMat = zeros(length(procAwakeData{1,1}),length(procAwakeData));
        for cc = 1:length(procAwakeData)
            awakeDataMat(:,cc) = procAwakeData{cc,1};
        end
        % calculate the power spectra of the desired signals
        params.tapers = [10,19];   % Tapers [n, 2n - 1]
        [awake_S,awake_f,awake_sErr] = mtspectrumc(awakeDataMat,params);
        % save results
        Results_PowerSpectrum.(animalID).Awake.(dataType).S = awake_S;
        Results_PowerSpectrum.(animalID).Awake.(dataType).f = awake_f;
        Results_PowerSpectrum.(animalID).Awake.(dataType).sErr = awake_sErr;
    else
        % save results
        Results_PowerSpectrum.(animalID).Awake.(dataType).S = [];
        Results_PowerSpectrum.(animalID).Awake.(dataType).f = [];
        Results_PowerSpectrum.(animalID).Awake.(dataType).sErr = [];
    end
    %% analyze power spectra during periods of Asleep
    zz = 1;
    clear asleepData procAsleepData
    asleepData = [];
    for bb = 1:size(procDataFileIDs,1)
        procDataFileID = procDataFileIDs(bb,:);
        [~,fileDate,asleepDataFileID] = GetFileInfo_IOS(procDataFileID);
        strDay = ConvertDate_IOS(fileDate);
        scoringLabels = [];
        for cc = 1:length(ScoringResults.fileIDs)
            if strcmp(asleepDataFileID,ScoringResults.fileIDs{cc,1}) == true
                scoringLabels = ScoringResults.labels{cc,1};
            end
        end
        % check labels to match arousal state
        if sum(strcmp(scoringLabels,'Not Sleep')) < 36   % 36 bins (180 total) or 3 minutes of awake
            load(procDataFileID,'-mat')
            if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
                try
                    puffs = ProcData.data.stimulations.LPadSol;
                catch
                    puffs = ProcData.data.solenoids.LPadSol;
                end
                % don't include trials with stimulation
                if isempty(puffs) == true
                    if strcmp(dataType,'LH_HbT') == true
                        asleepData{zz,1} = ProcData.data.CBV_HbT.adjLH;
                        zz = zz + 1;
                    elseif strcmp(dataType,'RH_HbT') == true
                        asleepData{zz,1} = ProcData.data.CBV_HbT.adjRH;
                        zz = zz + 1;
                    elseif strcmp(dataType,'LH_gammaBandPower') == true
                        asleepData{zz,1} = (ProcData.data.cortical_RH.gammaBandPower - RestingBaselines.manualSelection.cortical_LH.gammaBandPower.(strDay).mean)./RestingBaselines.manualSelection.cortical_LH.gammaBandPower.(strDay).mean;
                        zz = zz + 1;
                    elseif strcmp(dataType,'RH_gammaBandPower') == true
                        asleepData{zz,1} = (ProcData.data.cortical_RH.gammaBandPower - RestingBaselines.manualSelection.cortical_RH.gammaBandPower.(strDay).mean)./RestingBaselines.manualSelection.cortical_RH.gammaBandPower.(strDay).mean;
                        zz = zz + 1;
                    else
                        if sum(isnan(ProcData.data.Pupil.(dataType))) == 0
                            asleepData{zz,1} = ProcData.data.Pupil.(dataType);
                            zz = zz + 1;
                        end
                    end
                end
            end
        end
    end
    if isempty(asleepData) == false
        % detrend data
        for bb = 1:length(asleepData)
            procAsleepData{bb,1} = detrend(asleepData{bb,1},'constant');
        end
        % input data as time (1st dimension, vertical) by trials (2nd dimension, horizontunstimy)
        asleepDataMat = zeros(length(procAsleepData{1,1}),length(procAsleepData));
        for cc = 1:length(procAsleepData)
            asleepDataMat(:,cc) = procAsleepData{cc,1};
        end
        % calculate the power spectra of the desired signals
        params.tapers = [10,19];   % Tapers [n, 2n - 1]
        [asleep_S,asleep_f,asleep_sErr] = mtspectrumc(asleepDataMat,params);
        % save results
        Results_PowerSpectrum.(animalID).Asleep.(dataType).S = asleep_S;
        Results_PowerSpectrum.(animalID).Asleep.(dataType).f = asleep_f;
        Results_PowerSpectrum.(animalID).Asleep.(dataType).sErr = asleep_sErr;
    else
        % save results
        Results_PowerSpectrum.(animalID).Asleep.(dataType).S = [];
        Results_PowerSpectrum.(animalID).Asleep.(dataType).f = [];
        Results_PowerSpectrum.(animalID).Asleep.(dataType).sErr = [];
    end
    %% analyze power spectra during periods of all data
    zz = 1;
    clear allData procAllData
    allData = [];
    for bb = 1:size(procDataFileIDs,1)
        procDataFileID = procDataFileIDs(bb,:);
        [~,fileDate,~] = GetFileInfo_IOS(procDataFileID);
        strDay = ConvertDate_IOS(fileDate);
        load(procDataFileID,'-mat')
        if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
            try
                puffs = ProcData.data.stimulations.LPadSol;
            catch
                puffs = ProcData.data.solenoids.LPadSol;
            end
            % don't include trials with stimulation
            if isempty(puffs) == true
                if strcmp(dataType,'LH_HbT') == true
                    allData{zz,1} = ProcData.data.CBV_HbT.adjLH;
                    zz = zz + 1;
                elseif strcmp(dataType,'RH_HbT') == true
                    allData{zz,1} = ProcData.data.CBV_HbT.adjRH;
                    zz = zz + 1;
                elseif strcmp(dataType,'LH_gammaBandPower') == true
                    allData{zz,1} = (ProcData.data.cortical_RH.gammaBandPower - RestingBaselines.manualSelection.cortical_LH.gammaBandPower.(strDay).mean)./RestingBaselines.manualSelection.cortical_LH.gammaBandPower.(strDay).mean;
                    zz = zz + 1;
                elseif strcmp(dataType,'RH_gammaBandPower') == true
                    allData{zz,1} = (ProcData.data.cortical_RH.gammaBandPower - RestingBaselines.manualSelection.cortical_RH.gammaBandPower.(strDay).mean)./RestingBaselines.manualSelection.cortical_RH.gammaBandPower.(strDay).mean;
                    zz = zz + 1;
                else
                    if sum(isnan(ProcData.data.Pupil.(dataType))) == 0
                        allData{zz,1} = ProcData.data.Pupil.(dataType);
                        zz = zz + 1;
                    end
                end
            end
        end
    end
    if isempty(allData) == false
        % detrend data
        for bb = 1:length(allData)
            procAllData{bb,1} = detrend(allData{bb,1},'constant');
        end
        % input data as time (1st dimension, vertical) by trials (2nd dimension, horizontunstimy)
        allDataMat = zeros(length(procAllData{1,1}),length(procAllData));
        for cc = 1:length(procAllData)
            allDataMat(:,cc) = procAllData{cc,1};
        end
        % calculate the power spectra of the desired signals
        params.tapers = [10,19];   % Tapers [n, 2n - 1]
        [all_S,all_f,all_sErr] = mtspectrumc(allDataMat,params);
        % save results
        Results_PowerSpectrum.(animalID).All.(dataType).S = all_S;
        Results_PowerSpectrum.(animalID).All.(dataType).f = all_f;
        Results_PowerSpectrum.(animalID).All.(dataType).sErr = all_sErr;
    else
        % save results
        Results_PowerSpectrum.(animalID).All.(dataType).S = [];
        Results_PowerSpectrum.(animalID).All.(dataType).f = [];
        Results_PowerSpectrum.(animalID).All.(dataType).sErr = [];
    end
    %% analyze power spectra during periods of NREM
    % pull data from SleepData.mat structure
    [nremData,~,~] = RemoveStimSleepData_IOS(animalID,SleepData.(modelType).NREM.data.Pupil.(dataType).data,SleepData.(modelType).NREM.data.Pupil.fileIDs,SleepData.(modelType).NREM.data.Pupil.binTimes);
    if isempty(nremData) == false
        % detrend and truncate data to minimum length to match events
        for dd = 1:length(nremData)
            nremData{dd,1} = detrend(nremData{dd,1}(1:(params.minTime.NREM*samplingRate)),'constant');
        end
        % input data as time (1st dimension, vertical) by trials (2nd dimension, horizontunstimy)
        zz = 1;
        for ee = 1:length(nremData)
            if sum(isnan(nremData{ee,1})) == 0
                nremMat(:,zz) = nremData{ee,1};
                zz = zz + 1;
            end
        end
        % calculate the power spectra of the desired signals
        params.tapers = [3,5];   % Tapers [n, 2n - 1]
        [nrem_S,nrem_f,nrem_sErr] = mtspectrumc(nremMat,params);
        % save results
        Results_PowerSpectrum.(animalID).NREM.(dataType).S = nrem_S;
        Results_PowerSpectrum.(animalID).NREM.(dataType).f = nrem_f;
        Results_PowerSpectrum.(animalID).NREM.(dataType).sErr = nrem_sErr;
    else
        % save results
        Results_PowerSpectrum.(animalID).NREM.(dataType).S = [];
        Results_PowerSpectrum.(animalID).NREM.(dataType).f = [];
        Results_PowerSpectrum.(animalID).NREM.(dataType).sErr = [];
    end
    %% analyze power spectra during periods of REM
    % pull data from SleepData.mat structure
    if isempty(SleepData.(modelType).REM.data.Pupil) == false
        [remData,~,~] = RemoveStimSleepData_IOS(animalID,SleepData.(modelType).REM.data.Pupil.(dataType).data,SleepData.(modelType).REM.data.Pupil.fileIDs,SleepData.(modelType).REM.data.Pupil.binTimes);
    else
        remData = [];
    end
    if isempty(remData) == false
        % detrend and truncate data to minimum length to match events
        for dd = 1:length(remData)
            remData{dd,1} = detrend(remData{dd,1}(1:(params.minTime.REM*samplingRate)),'constant');
        end
        % input data as time (1st dimension, vertical) by trials (2nd dimension, horizontunstimy)
        zz = 1;
        for ee = 1:length(remData)
            if sum(isnan(remData{ee,1})) == 0
                remMat(:,zz) = remData{ee,1};
                zz = zz + 1;
            end
        end
        % calculate the power spectra of the desired signals
        params.tapers = [5,9];   % Tapers [n, 2n - 1]
        [rem_S,rem_f,rem_sErr] = mtspectrumc(remMat,params);
        % save results
        Results_PowerSpectrum.(animalID).REM.(dataType).S = rem_S;
        Results_PowerSpectrum.(animalID).REM.(dataType).f = rem_f;
        Results_PowerSpectrum.(animalID).REM.(dataType).sErr = rem_sErr;
    else
        % save results
        Results_PowerSpectrum.(animalID).REM.(dataType).S = [];
        Results_PowerSpectrum.(animalID).REM.(dataType).f = [];
        Results_PowerSpectrum.(animalID).REM.(dataType).sErr = [];
    end
end
%% save data
cd([rootFolder delim])
save('Results_PowerSpectrum.mat','Results_PowerSpectrum')

end
