function [Results_Coherence] = AnalyzeCoherence_Pupil(animalID,rootFolder,delim,Results_Coherence)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Analyze the spectral coherence between neural-hemodynamic [HbT] signals (IOS)
%________________________________________________________________________________________________________________________

%% function parameters
dataTypes = {'mmArea','mmDiameter','zArea','zDiameter'};
hemDataTypes = {'LH_HbT','RH_HbT','LH_gammaBandPower','RH_gammaBandPower'};
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
% find and load RestingBaselines.mat struct
baselineDataFileStruct = dir('*_RestingBaselines.mat');
baselineDataFile = {baselineDataFileStruct.name}';
baselineDataFileID = char(baselineDataFile);
load(baselineDataFileID,'-mat')
% find and load AsleepData.mat struct
sleepDataFileStruct = dir('*_SleepData.mat');
sleepDataFile = {sleepDataFileStruct.name}';
sleepDataFileID = char(sleepDataFile);
load(sleepDataFileID,'-mat')
%
scoringResultsFileStruct = dir('*Forest_ScoringResults.mat');
scoringResultsFile = {scoringResultsFileStruct.name}';
scoringResultsFileID = char(scoringResultsFile);
load(scoringResultsFileID,'-mat')
% lowpass filter
samplingRate = RestData.CBV_HbT.adjLH.CBVCamSamplingRate;
% criteria for resting
RestCriteria.Fieldname = {'durations'};
RestCriteria.Comparison = {'gt'};
RestCriteria.Value = {params.minTime.Rest};
RestPuffCriteria.Fieldname = {'puffDistances'};
RestPuffCriteria.Comparison = {'gt'};
RestPuffCriteria.Value = {5};
% go through each valid data type for arousal-based coherence analysis
for zzz = 1:length(hemDataTypes)
    hemDataType = hemDataTypes{1,zzz};
    for aa = 1:length(dataTypes)
        dataType = dataTypes{1,aa};
        %% analyze neural-hemo coherence during periods of rest
        % pull data from RestData.mat structure
        [restLogical] = FilterEvents_IOS(RestData.Pupil.(dataType),RestCriteria);
        [puffLogical] = FilterEvents_IOS(RestData.Pupil.(dataType),RestPuffCriteria);
        combRestLogical = logical(restLogical.*puffLogical);
        restFileIDs = RestData.Pupil.(dataType).fileIDs(combRestLogical,:);
        restEventTimes = RestData.Pupil.(dataType).eventTimes(combRestLogical,:);
        restDurations = RestData.Pupil.(dataType).durations(combRestLogical,:);
        HbT_restData = RestData.Pupil.(hemDataType).data(combRestLogical,:);
        Pupil_restData = RestData.Pupil.(dataType).data(combRestLogical,:);
        % keep only the data that occurs within the manually-approved awake regions
        [HbT_finalRestData,~,~,~] = RemoveInvalidData_IOS(HbT_restData,restFileIDs,restDurations,restEventTimes,ManualDecisions);
        [Pupil_FinalRestData,~,~,~] = RemoveInvalidData_IOS(Pupil_restData,restFileIDs,restDurations,restEventTimes,ManualDecisions);
        clear HbT_procRestData Pupil_procRestData
        % filter, detrend, and truncate data to minimum length to match events
        for bb = 1:length(HbT_finalRestData)
            if length(HbT_finalRestData{bb,1}) < params.minTime.Rest*samplingRate
                restChunkSampleDiff = params.minTime.Rest*samplingRate - length(HbT_finalRestData{bb,1});
                HbT_restPad = (ones(1,restChunkSampleDiff))*HbT_finalRestData{bb,1}(end);
                Pupil_restPad = (ones(1,restChunkSampleDiff))*Pupil_FinalRestData{bb,1}(end);
                HbT_procRestData{bb,1} = horzcat(HbT_finalRestData{bb,1},HbT_restPad); %#ok<*AGROW>
                Pupil_procRestData{bb,1} = horzcat(Pupil_FinalRestData{bb,1},Pupil_restPad);
                HbT_procRestData{bb,1} = detrend(HbT_procRestData{bb,1},'constant');
                Pupil_procRestData{bb,1} = detrend(Pupil_procRestData{bb,1},'constant');
            else
                HbT_procRestData{bb,1} = detrend(HbT_finalRestData{bb,1}(1:(params.minTime.Rest*samplingRate)),'constant');
                Pupil_procRestData{bb,1} = detrend(Pupil_FinalRestData{bb,1}(1:(params.minTime.Rest*samplingRate)),'constant');
            end
        end
        % input data as time(1st dimension, vertical) by trials (2nd dimension, horizontunstimy)
        zz = 1;
        for cc = 1:length(HbT_procRestData)
            if sum(isnan(Pupil_procRestData{cc,1})) == 0
                HbT_restDataMat(:,zz) = HbT_procRestData{cc,1};
                Pupil_restDataMat(:,zz) = Pupil_procRestData{cc,1};
                zz = zz + 1;
            end
        end
        % parameters for coherencyc - information available in function
        params.tapers = [1,1]; % Tapers [n, 2n - 1]
        params.pad = 1;
        params.Fs = samplingRate;
        params.fpass = [0,1]; % Pass band [0, nyquist]
        params.trialave = 1;
        params.err = [2,0.05];
        % calculate the coherence between desired signals
        [C_RestData,~,~,~,~,f_RestData,confC_RestData,~,cErr_RestData] = coherencyc_eLife2020(HbT_restDataMat,Pupil_restDataMat,params);
        % save results
        Results_Coherence.(animalID).Rest.(dataType).(hemDataType).C = C_RestData;
        Results_Coherence.(animalID).Rest.(dataType).(hemDataType).f = f_RestData;
        Results_Coherence.(animalID).Rest.(dataType).(hemDataType).confC = confC_RestData;
        Results_Coherence.(animalID).Rest.(dataType).(hemDataType).cErr = cErr_RestData;
        %% analyze neural-hemo coherence during periods of alert
        zz = 1;
        clear HbT_awakeData Pupil_awakeData HbT_procAwakeData Pupil_procAwakeData
        HbT_awakeData = []; Pupil_awakeData = [];
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
            if sum(strcmp(scoringLabels,'Not Sleep')) > 144   % 36 bins (180 total) or 3 minutes of asleep
                load(procDataFileID,'-mat')
                % don't include trials with stimulation
                if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
                    try
                        puffs = ProcData.data.stimulations.LPadSol;
                    catch
                        puffs = ProcData.data.solenoids.LPadSol;
                    end
                    if isempty(puffs) == true
                        if sum(isnan(ProcData.data.Pupil.(dataType))) == 0
                            if strcmp(hemDataType,'LH_HbT') == true
                                HbT_awakeData{zz,1} = ProcData.data.CBV_HbT.adjLH;
                            elseif strcmp(hemDataType,'RH_HbT') == true
                                HbT_awakeData{zz,1} = ProcData.data.CBV_HbT.adjRH;
                            elseif strcmp(hemDataType,'LH_gammaBandPower') == true
                                HbT_awakeData{zz,1} = (ProcData.data.cortical_RH.gammaBandPower - RestingBaselines.manualSelection.cortical_LH.gammaBandPower.(strDay).mean)./RestingBaselines.manualSelection.cortical_LH.gammaBandPower.(strDay).mean;
                            elseif strcmp(hemDataType,'RH_gammaBandPower') == true
                                HbT_awakeData{zz,1} = (ProcData.data.cortical_RH.gammaBandPower - RestingBaselines.manualSelection.cortical_RH.gammaBandPower.(strDay).mean)./RestingBaselines.manualSelection.cortical_RH.gammaBandPower.(strDay).mean;
                            end
                            Pupil_awakeData{zz,1} = ProcData.data.Pupil.(dataType);
                            zz = zz + 1;
                        end
                    end
                end
            end
        end
        % filter and detrend data
        if isempty(HbT_awakeData) == false
            for bb = 1:length(HbT_awakeData)
                HbT_procAwakeData{bb,1} = detrend(HbT_awakeData{bb,1},'constant');
                Pupil_procAwakeData{bb,1} = detrend(Pupil_awakeData{bb,1},'constant');
            end
            % input data as time (1st dimension, vertical) by trials (2nd dimension, horizontunstimy)
            HbT_awakeDataMat = zeros(length(HbT_procAwakeData{1,1}),length(HbT_procAwakeData));
            Pupil_awakeDataMat = zeros(length(Pupil_procAwakeData{1,1}),length(Pupil_procAwakeData));
            for cc = 1:length(HbT_procAwakeData)
                HbT_awakeDataMat(:,cc) = HbT_procAwakeData{cc,1};
                Pupil_awakeDataMat(:,cc) = Pupil_procAwakeData{cc,1};
            end
            % calculate the coherence between desired signals
            params.tapers = [10,19]; % Tapers [n, 2n - 1]
            [C_AwakeData,~,~,~,~,f_AwakeData,confC_AwakeData,~,cErr_AwakeData] = coherencyc(HbT_awakeDataMat,Pupil_awakeDataMat,params);
            % save results
            Results_Coherence.(animalID).Awake.(dataType).(hemDataType).C = C_AwakeData;
            Results_Coherence.(animalID).Awake.(dataType).(hemDataType).f = f_AwakeData;
            Results_Coherence.(animalID).Awake.(dataType).(hemDataType).confC = confC_AwakeData;
            Results_Coherence.(animalID).Awake.(dataType).(hemDataType).cErr = cErr_AwakeData;
        else
            % save results
            Results_Coherence.(animalID).Awake.(dataType).(hemDataType).C = [];
            Results_Coherence.(animalID).Awake.(dataType).(hemDataType).f = [];
            Results_Coherence.(animalID).Awake.(dataType).(hemDataType).confC = [];
            Results_Coherence.(animalID).Awake.(dataType).(hemDataType).cErr = [];
        end
        %% analyze neural-hemo coherence during periods of aasleep
        zz = 1;
        clear HbT_asleepData Pupil_asleepData HbT_procAsleepData Pupil_procAsleepData
        HbT_asleepData = []; Pupil_asleepData = [];
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
                        if sum(isnan(ProcData.data.Pupil.(dataType))) == 0
                            if strcmp(hemDataType,'LH_HbT') == true
                                HbT_asleepData{zz,1} = ProcData.data.CBV_HbT.adjLH;
                            elseif strcmp(hemDataType,'RH_HbT') == true
                                HbT_asleepData{zz,1} = ProcData.data.CBV_HbT.adjRH;
                            elseif strcmp(hemDataType,'LH_gammaBandPower') == true
                                HbT_asleepData{zz,1} = (ProcData.data.cortical_RH.gammaBandPower - RestingBaselines.manualSelection.cortical_LH.gammaBandPower.(strDay).mean)./RestingBaselines.manualSelection.cortical_LH.gammaBandPower.(strDay).mean;
                            elseif strcmp(hemDataType,'RH_gammaBandPower') == true
                                HbT_asleepData{zz,1} = (ProcData.data.cortical_RH.gammaBandPower - RestingBaselines.manualSelection.cortical_RH.gammaBandPower.(strDay).mean)./RestingBaselines.manualSelection.cortical_RH.gammaBandPower.(strDay).mean;
                            end
                            Pupil_asleepData{zz,1} = ProcData.data.Pupil.(dataType);
                            zz = zz + 1;
                        end
                    end
                end
            end
        end
        % filter and detrend data
        if isempty(HbT_asleepData) == false
            for bb = 1:length(HbT_asleepData)
                HbT_procAsleepData{bb,1} = detrend(HbT_asleepData{bb,1},'constant');
                Pupil_procAsleepData{bb,1} = detrend(Pupil_asleepData{bb,1},'constant');
            end
            % input data as time (1st dimension, vertical) by trials (2nd dimension, horizontunstimy)
            HbT_asleepDataMat = zeros(length(HbT_procAsleepData{1,1}),length(HbT_procAsleepData));
            Pupil_asleepDataMat = zeros(length(Pupil_procAsleepData{1,1}),length(Pupil_procAsleepData));
            for cc = 1:length(HbT_procAsleepData)
                HbT_asleepDataMat(:,cc) = HbT_procAsleepData{cc,1};
                Pupil_asleepDataMat(:,cc) = Pupil_procAsleepData{cc,1};
            end
            % calculate the coherence between desired signals
            params.tapers = [10,19]; % Tapers [n, 2n - 1]
            [C_AsleepData,~,~,~,~,f_AsleepData,confC_AsleepData,~,cErr_AsleepData] = coherencyc(HbT_asleepDataMat,Pupil_asleepDataMat,params);
            % save results
            Results_Coherence.(animalID).Asleep.(dataType).(hemDataType).C = C_AsleepData;
            Results_Coherence.(animalID).Asleep.(dataType).(hemDataType).f = f_AsleepData;
            Results_Coherence.(animalID).Asleep.(dataType).(hemDataType).confC = confC_AsleepData;
            Results_Coherence.(animalID).Asleep.(dataType).(hemDataType).cErr = cErr_AsleepData;
        else
            % save results
            Results_Coherence.(animalID).Asleep.(dataType).(hemDataType).C = [];
            Results_Coherence.(animalID).Asleep.(dataType).(hemDataType).f = [];
            Results_Coherence.(animalID).Asleep.(dataType).(hemDataType).confC = [];
            Results_Coherence.(animalID).Asleep.(dataType).(hemDataType).cErr = [];
        end
        %% analyze neural-hemo coherence during periods of all data
        zz = 1;
        clear HbT_allData Pupil_allData HbT_allData Pupil_allData
        HbT_allData = []; Pupil_allData = [];
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
                    if sum(isnan(ProcData.data.Pupil.(dataType))) == 0
                        if strcmp(hemDataType,'LH_HbT') == true
                            HbT_allData{zz,1} = ProcData.data.CBV_HbT.adjLH;
                        elseif strcmp(hemDataType,'RH_HbT') == true
                            HbT_allData{zz,1} = ProcData.data.CBV_HbT.adjRH;
                        elseif strcmp(hemDataType,'LH_gammaBandPower') == true
                            HbT_allData{zz,1} = (ProcData.data.cortical_RH.gammaBandPower - RestingBaselines.manualSelection.cortical_LH.gammaBandPower.(strDay).mean)./RestingBaselines.manualSelection.cortical_LH.gammaBandPower.(strDay).mean;
                        elseif strcmp(hemDataType,'RH_gammaBandPower') == true
                            HbT_allData{zz,1} = (ProcData.data.cortical_RH.gammaBandPower - RestingBaselines.manualSelection.cortical_RH.gammaBandPower.(strDay).mean)./RestingBaselines.manualSelection.cortical_RH.gammaBandPower.(strDay).mean;
                        end
                        Pupil_allData{zz,1} = ProcData.data.Pupil.(dataType);
                        zz = zz + 1;
                    end
                end
            end
        end
        % filter and detrend data
        if isempty(HbT_allData) == false
            for bb = 1:length(HbT_allData)
                HbT_procAllData{bb,1} = detrend(HbT_allData{bb,1},'constant');
                Pupil_procAllData{bb,1} = detrend(Pupil_allData{bb,1},'constant');
            end
            % input data as time (1st dimension, vertical) by trials (2nd dimension, horizontunstimy)
            HbT_allDataMat = zeros(length(HbT_procAllData{1,1}),length(HbT_procAllData));
            Pupil_allDataMat = zeros(length(Pupil_procAllData{1,1}),length(Pupil_procAllData));
            for cc = 1:length(HbT_procAllData)
                HbT_allDataMat(:,cc) = HbT_procAllData{cc,1};
                Pupil_allDataMat(:,cc) = Pupil_procAllData{cc,1};
            end
            % calculate the coherence between desired signals
            params.tapers = [10,19]; % Tapers [n, 2n - 1]
            [C_AllData,~,~,~,~,f_AllData,confC_AllData,~,cErr_AllData] = coherencyc(HbT_allDataMat,Pupil_allDataMat,params);
            % save results
            Results_Coherence.(animalID).All.(dataType).(hemDataType).C = C_AllData;
            Results_Coherence.(animalID).All.(dataType).(hemDataType).f = f_AllData;
            Results_Coherence.(animalID).All.(dataType).(hemDataType).confC = confC_AllData;
            Results_Coherence.(animalID).All.(dataType).(hemDataType).cErr = cErr_AllData;
        else
            % save results
            Results_Coherence.(animalID).All.(dataType).(hemDataType).C = [];
            Results_Coherence.(animalID).All.(dataType).(hemDataType).f = [];
            Results_Coherence.(animalID).All.(dataType).(hemDataType).confC = [];
            Results_Coherence.(animalID).All.(dataType).(hemDataType).cErr = [];
        end
        %% analyze neural-hemo coherence during periods of NREM
        % pull data from AsleepData.mat structure
        if isempty(SleepData.(modelType).NREM.data.Pupil) == false
            [HbT_nremData,~,~] = RemoveStimSleepData_IOS(animalID,SleepData.(modelType).NREM.data.Pupil.(hemDataType).data,SleepData.(modelType).NREM.data.Pupil.fileIDs,SleepData.(modelType).NREM.data.Pupil.binTimes);
            [Pupil_nremData,~,~] = RemoveStimSleepData_IOS(animalID,SleepData.(modelType).NREM.data.Pupil.(dataType).data,SleepData.(modelType).NREM.data.Pupil.fileIDs,SleepData.(modelType).NREM.data.Pupil.binTimes);
        else
            HbT_nremData = [];
            Pupil_nremData = [];
        end
        if isempty(HbT_nremData) == false
            clear HbT_procNremData Pupil_procNremData
            % filter, detrend, and truncate data to minimum length to match events
            for ee = 1:length(HbT_nremData)
                HbT_procNremData{ee,1} = detrend(HbT_nremData{ee,1}(1:(params.minTime.NREM*samplingRate)),'constant');
                Pupil_procNremData{ee,1} = detrend(Pupil_nremData{ee,1}(1:(params.minTime.NREM*samplingRate)),'constant');
            end
            % input data as time (1st dimension, vertical) by trials (2nd dimension, horizontunstimy)
            zz = 1;
            for ff = 1:length(HbT_procNremData)
                if sum(isnan(Pupil_procNremData{ff,1})) == 0
                    HbT_nremMat(:,zz) = HbT_procNremData{ff,1};
                    Pupil_nremMat(:,zz) = Pupil_procNremData{ff,1};
                    zz = zz + 1;
                end
            end
            % calculate the coherence between desired signals
            params.tapers = [3,5]; % Tapers [n, 2n - 1]
            [C_nrem,~,~,~,~,f_nrem,confC_nrem,~,cErr_nrem] = coherencyc(HbT_nremMat,Pupil_nremMat,params);
            % save results
            Results_Coherence.(animalID).NREM.(dataType).(hemDataType).C = C_nrem;
            Results_Coherence.(animalID).NREM.(dataType).(hemDataType).f = f_nrem;
            Results_Coherence.(animalID).NREM.(dataType).(hemDataType).confC = confC_nrem;
            Results_Coherence.(animalID).NREM.(dataType).(hemDataType).cErr = cErr_nrem;
        else
            % save results
            Results_Coherence.(animalID).NREM.(dataType).(hemDataType).C = [];
            Results_Coherence.(animalID).NREM.(dataType).(hemDataType).f = [];
            Results_Coherence.(animalID).NREM.(dataType).(hemDataType).confC = [];
            Results_Coherence.(animalID).NREM.(dataType).(hemDataType).cErr = [];
        end
        %% analyze neural-hemo coherence during periods of REM
        % pull data from AsleepData.mat structure
        if isempty(SleepData.(modelType).REM.data.Pupil) == false
            [HbT_remData,~,~] = RemoveStimSleepData_IOS(animalID,SleepData.(modelType).REM.data.Pupil.(hemDataType).data,SleepData.(modelType).REM.data.Pupil.fileIDs,SleepData.(modelType).REM.data.Pupil.binTimes);
            [Pupil_remData,~,~] = RemoveStimSleepData_IOS(animalID,SleepData.(modelType).REM.data.Pupil.(dataType).data,SleepData.(modelType).REM.data.Pupil.fileIDs,SleepData.(modelType).REM.data.Pupil.binTimes);
        else
            HbT_remData = [];
            Pupil_remData = [];
        end
        if isempty(HbT_remData) == false
            clear HbT_procRemData Pupil_procRemData
            % filter, detrend, and truncate data to minimum length to match events
            for ee = 1:length(HbT_remData)
                HbT_procRemData{ee,1} = detrend(HbT_remData{ee,1}(1:(params.minTime.REM*samplingRate)),'constant');
                Pupil_procRemData{ee,1} = detrend(Pupil_remData{ee,1}(1:(params.minTime.REM*samplingRate)),'constant');
            end
            % input data as time (1st dimension, vertical) by trials (2nd dimension, horizontunstimy)
            zz = 1;
            for ff = 1:length(HbT_procRemData)
                if sum(isnan(Pupil_procRemData{ff,1})) == 0
                    HbT_remMat(:,zz) = HbT_procRemData{ff,1};
                    Pupil_remMat(:,zz) = Pupil_procRemData{ff,1};
                    zz = zz + 1;
                end
            end
            % calculate the coherence between desired signals
            params.tapers = [5,9]; % Tapers [n, 2n - 1]
            [C_rem,~,~,~,~,f_rem,confC_rem,~,cErr_rem] = coherencyc(HbT_remMat,Pupil_remMat,params);
            % save results
            Results_Coherence.(animalID).REM.(dataType).(hemDataType).C = C_rem;
            Results_Coherence.(animalID).REM.(dataType).(hemDataType).f = f_rem;
            Results_Coherence.(animalID).REM.(dataType).(hemDataType).confC = confC_rem;
            Results_Coherence.(animalID).REM.(dataType).(hemDataType).cErr = cErr_rem;
        else
            % save results
            Results_Coherence.(animalID).REM.(dataType).(hemDataType).C = [];
            Results_Coherence.(animalID).REM.(dataType).(hemDataType).f = [];
            Results_Coherence.(animalID).REM.(dataType).(hemDataType).confC = [];
            Results_Coherence.(animalID).REM.(dataType).(hemDataType).cErr = [];
        end
    end
end
% save data
cd([rootFolder delim])
save('Results_Coherence.mat','Results_Coherence')

end
