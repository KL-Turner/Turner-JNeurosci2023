function [Results_Evoked] = AnalyzeEvokedResponses_Pupil(animalID,rootFolder,delim,Results_Evoked)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose:
%________________________________________________________________________________________________________________________

%% function parameters
dataLocation = [rootFolder delim 'Data' delim animalID delim 'Bilateral Imaging'];
%% only run analysis for valid animal IDs
cd(dataLocation)
% find and load EventData.mat struct
eventDataFileStruct = dir('*_EventData.mat');
eventDataFile = {eventDataFileStruct.name}';
eventDataFileID = char(eventDataFile);
load(eventDataFileID,'-mat')
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
% find and load AllSpecStruct.mat struct
allSpecStructFileStruct = dir('*_AllSpecStructB.mat');
allSpecStructFile = {allSpecStructFileStruct.name}';
allSpecStructFileID = char(allSpecStructFile);
load(allSpecStructFileID,'-mat')
% criteria for whisking
WhiskCriteriaA.Fieldname = {'duration','duration','puffDistance'};
WhiskCriteriaA.Comparison = {'gt','lt','gt'};
WhiskCriteriaA.Value = {0.5,2,5};
WhiskCriteriaB.Fieldname = {'duration','duration','puffDistance'};
WhiskCriteriaB.Comparison = {'gt','lt','gt'};
WhiskCriteriaB.Value = {2,5,5};
WhiskCriteriaC.Fieldname = {'duration','puffDistance'};
WhiskCriteriaC.Comparison = {'gt','gt'};
WhiskCriteriaC.Value = {5,5};
WhiskCriteriaD.Fieldname = {'duration','duration','puffDistance'};
WhiskCriteriaD.Comparison = {'gt','lt','gt'};
WhiskCriteriaD.Value = {0.25,0.5,5};
WhiskCriteriaNames = {'ShortWhisks','IntermediateWhisks','LongWhisks','BlinkWhisks'};
% criteria for stimulation
StimCriteriaA.Value = {'LPadSol'};
StimCriteriaA.Fieldname = {'solenoidName'};
StimCriteriaA.Comparison = {'equal'};
StimCriteriaB.Value = {'RPadSol'};
StimCriteriaB.Fieldname = {'solenoidName'};
StimCriteriaB.Comparison = {'equal'};
StimCriteriaC.Value = {'AudSol'};
StimCriteriaC.Fieldname = {'solenoidName'};
StimCriteriaC.Comparison = {'equal'};
stimCriteriaNames = {'stimCriteriaA','stimCriteriaB','stimCriteriaC'};
dataTypes = {'mmArea','mmDiameter','zArea','zDiameter','LH_HbT','RH_HbT'};
%% analyze whisking-evoked responses
for aa = 1:length(dataTypes)
    dataType = dataTypes{1,aa};
    % pull a few necessary numbers from the EventData.mat struct such as trial duration and sampling rate
    samplingRate = EventData.Pupil.(dataType).whisk.samplingRate;
    offset = EventData.Pupil.pupilArea.whisk.epoch.offset;
    for bb = 1:length(WhiskCriteriaNames)
        whiskCriteriaName = WhiskCriteriaNames{1,bb};
        if strcmp(whiskCriteriaName,'ShortWhisks') == true
            WhiskCriteria = WhiskCriteriaA;
        elseif strcmp(whiskCriteriaName,'IntermediateWhisks') == true
            WhiskCriteria = WhiskCriteriaB;
        elseif strcmp(whiskCriteriaName,'LongWhisks') == true
            WhiskCriteria = WhiskCriteriaC;
        elseif strcmp(whiskCriteriaName,'BlinkWhisks') == true
            WhiskCriteria = WhiskCriteriaD;
        end
        % pull data from EventData.mat structure
        if strcmp(dataType,'LH_HbT') == true
            [whiskLogical] = FilterEvents_IOS(EventData.CBV_HbT.adjLH.whisk,WhiskCriteria);
            combWhiskLogical = logical(whiskLogical);
            [allWhiskData] = EventData.CBV_HbT.adjLH.whisk.data(combWhiskLogical,:);
            [allWhiskFileIDs] = EventData.CBV_HbT.adjLH.whisk.fileIDs(combWhiskLogical,:);
            [allWhiskEventTimes] = EventData.CBV_HbT.adjLH.whisk.eventTime(combWhiskLogical,:);
            allWhiskDurations = EventData.CBV_HbT.adjLH.whisk.duration(combWhiskLogical,:);
            % keep only the data that occurs within the manually-approved awake regions
            [finalWhiskData,~,~,~] = RemoveInvalidData_IOS(allWhiskData,allWhiskFileIDs,allWhiskDurations,allWhiskEventTimes,ManualDecisions);
        elseif strcmp(dataType,'RH_HbT') == true
            [whiskLogical] = FilterEvents_IOS(EventData.CBV_HbT.adjRH.whisk,WhiskCriteria);
            combWhiskLogical = logical(whiskLogical);
            [allWhiskData] = EventData.CBV_HbT.adjRH.whisk.data(combWhiskLogical,:);
            [allWhiskFileIDs] = EventData.CBV_HbT.adjRH.whisk.fileIDs(combWhiskLogical,:);
            [allWhiskEventTimes] = EventData.CBV_HbT.adjRH.whisk.eventTime(combWhiskLogical,:);
            allWhiskDurations = EventData.CBV_HbT.adjRH.whisk.duration(combWhiskLogical,:);
            % keep only the data that occurs within the manually-approved awake regions
            [finalWhiskData,~,~,~] = RemoveInvalidData_IOS(allWhiskData,allWhiskFileIDs,allWhiskDurations,allWhiskEventTimes,ManualDecisions);
        else
            [whiskLogical] = FilterEvents_IOS(EventData.Pupil.(dataType).whisk,WhiskCriteria);
            combWhiskLogical = logical(whiskLogical);
            [allWhiskData] = EventData.Pupil.(dataType).whisk.data(combWhiskLogical,:);
            [allWhiskFileIDs] = EventData.Pupil.(dataType).whisk.fileIDs(combWhiskLogical,:);
            [allWhiskEventTimes] = EventData.Pupil.(dataType).whisk.eventTime(combWhiskLogical,:);
            allWhiskDurations = EventData.Pupil.(dataType).whisk.duration(combWhiskLogical,:);
            % keep only the data that occurs within the manually-approved awake regions
            [finalWhiskData,~,~,~] = RemoveInvalidData_IOS(allWhiskData,allWhiskFileIDs,allWhiskDurations,allWhiskEventTimes,ManualDecisions);
        end
        % lowpass filter each whisking event and nanmean-subtract by the first 2 seconds
        procWhiskData = [];
        for cc = 1:size(finalWhiskData,1)
            whiskArray = finalWhiskData(cc,:);
            filtWhiskarray = sgolayfilt(whiskArray,3,17);
            procWhiskData(cc,:) = filtWhiskarray - nanmean(filtWhiskarray(1:(offset*samplingRate)));
        end
        meanWhiskData = nanmean(procWhiskData,1);
        stdWhiskData = nanstd(procWhiskData,0,1);
        % save results
        Results_Evoked.(animalID).Whisk.(dataType).(whiskCriteriaName).mean = meanWhiskData;
        Results_Evoked.(animalID).Whisk.(dataType).(whiskCriteriaName).stdev = stdWhiskData;
    end
    %% analyze stimulus-evoked responses
    for gg = 1:length(stimCriteriaNames)
        stimCriteriaName = stimCriteriaNames{1,gg};
        if strcmp(stimCriteriaName,'stimCriteriaA') == true
            StimCriteria = StimCriteriaA;
            solenoid = 'LPadSol';
        elseif strcmp(stimCriteriaName,'stimCriteriaB') == true
            StimCriteria = StimCriteriaB;
            solenoid = 'RPadSol';
        elseif strcmp(stimCriteriaName,'stimCriteriaC') == true
            StimCriteria = StimCriteriaC;
            solenoid = 'AudSol';
        end
        % pull data from EventData.mat structure
        if strcmp(dataType,'LH_HbT') == true
            allStimFilter = FilterEvents_IOS(EventData.CBV_HbT.adjLH.stim,StimCriteria);
            [allStimData] = EventData.CBV_HbT.adjLH.stim.data(allStimFilter,:);
            [allStimFileIDs] = EventData.CBV_HbT.adjLH.stim.fileIDs(allStimFilter,:);
            [allStimEventTimes] = EventData.CBV_HbT.adjLH.stim.eventTime(allStimFilter,:);
            allStimDurations = zeros(length(allStimEventTimes),1);
            % keep only the data that occurs within the manually-approved awake regions
            [finalStimData,~,~,~] = RemoveInvalidData_IOS(allStimData,allStimFileIDs,allStimDurations,allStimEventTimes,ManualDecisions);
        elseif strcmp(dataType,'RH_HbT') == true
            allStimFilter = FilterEvents_IOS(EventData.CBV_HbT.adjRH.stim,StimCriteria);
            [allStimData] = EventData.CBV_HbT.adjRH.stim.data(allStimFilter,:);
            [allStimFileIDs] = EventData.CBV_HbT.adjRH.stim.fileIDs(allStimFilter,:);
            [allStimEventTimes] = EventData.CBV_HbT.adjRH.stim.eventTime(allStimFilter,:);
            allStimDurations = zeros(length(allStimEventTimes),1);
            % keep only the data that occurs within the manually-approved awake regions
            [finalStimData,~,~,~] = RemoveInvalidData_IOS(allStimData,allStimFileIDs,allStimDurations,allStimEventTimes,ManualDecisions);
        else
            allStimFilter = FilterEvents_IOS(EventData.Pupil.(dataType).stim,StimCriteria);
            [allStimData] = EventData.Pupil.(dataType).stim.data(allStimFilter,:);
            [allStimFileIDs] = EventData.Pupil.(dataType).stim.fileIDs(allStimFilter,:);
            [allStimEventTimes] = EventData.Pupil.(dataType).stim.eventTime(allStimFilter,:);
            allStimDurations = zeros(length(allStimEventTimes),1);
            % keep only the data that occurs within the manually-approved awake regions
            [finalStimData,~,~,~] = RemoveInvalidData_IOS(allStimData,allStimFileIDs,allStimDurations,allStimEventTimes,ManualDecisions);
        end
        % lowpass filter each stim event and nanmean-subtract by the first 2 seconds
        procStimData = [];
        for kk = 1:size(finalStimData,1)
            stimArray = finalStimData(kk,:);
            filtStimarray = sgolayfilt(stimArray,3,17);
            procStimData(kk,:) = filtStimarray - nanmean(filtStimarray(1:(offset*samplingRate)));
        end
        meanStimData = nanmean(procStimData,1);
        stdStimData = nanstd(procStimData,0,1);
        % save results
        Results_Evoked.(animalID).Stim.(dataType).(solenoid).mean = meanStimData;
        Results_Evoked.(animalID).Stim.(dataType).(solenoid).std = stdStimData;
    end
end
% save data
cd([rootFolder delim])
save('Results_Evoked.mat','Results_Evoked')

end
