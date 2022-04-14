function [RestingBaselines] = UpdateManualRestingBaselines_JNeurosci2022(imagingType,hemoType)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Manually designate files with event times that correspond to appropriate rest
%________________________________________________________________________________________________________________________

disp('Calculating the resting baselines using manually selected files each unique day...'); disp(' ')
% character list of all ProcData files
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
% find and load RestingBaselines.mat struct
baselineDataFileStruct = dir('*_RestingBaselines.mat');
baselineDataFiles = {baselineDataFileStruct.name}';
baselineDataFileID = char(baselineDataFiles);
load(baselineDataFileID)
% find and load RestData.mat struct
restDataFileStruct = dir('*_RestData.mat');
restDataFiles = {restDataFileStruct.name}';
restDataFileID = char(restDataFiles);
load(restDataFileID)
% determine the animal's ID use the RestData.mat file's name for the current folder
fileBreaks = strfind(restDataFileID,'_');
animalID = restDataFileID(1:fileBreaks(1)-1);
% the RestData.mat struct has all resting events, regardless of duration. We want to set the threshold for rest as anything
% that is greater than a certain amount of time
RestCriteria.Fieldname = {'durations'};
RestCriteria.Comparison = {'gt'};
RestCriteria.Value = {5};
PuffCriteria.Fieldname = {'puffDistances'};
PuffCriteria.Comparison = {'gt'};
PuffCriteria.Value = {5};
% loop through each file and manually designate which files have appropriate amounts of rest
% if this is already completed, load the struct and skip
for a = 1:size(procDataFileIDs,1)
    disp(['Loading file ' num2str(a) ' of ' num2str(size(procDataFileIDs,1)) '...']); disp(' ')
    procDataFileID = procDataFileIDs(a,:);
    load(procDataFileID,'-mat')
    ManualDecisions.fileIDs{a,1} = procDataFileIDs(a,:);
    if isfield(ProcData,'manualBaselineInfo') == false
        saveFigs = 'n';
        baselineType = 'setDuration';
        b = false;
        while b == false
            % load a figure with the data to visualize which periods are rest. Note that this data is, by default, normalized
            % by the first 30 minutes of data which may or may not reflect accurate normalizations
            [singleTrialFig] = GenerateSingleFigures_JNeurosci2022(procDataFileID,RestingBaselines,baselineType,saveFigs,imagingType,hemoType);
            fileDecision = input(['Use data from ' procDataFileID ' for resting baseline calculation? (y/n): '],'s'); disp(' ')
            if strcmp(fileDecision,'y') || strcmp(fileDecision,'n')
                b = true;
                ManualDecisions.validFiles{a,1} = fileDecision;
                if strcmp(fileDecision,'y') == true
                    startTime = input('Input the start time for resting data: '); disp(' ')
                    endTime = input('Input the end time for resting data: '); disp(' ')
                    ManualDecisions.startTimes{a,1} = startTime;
                    ManualDecisions.endTimes{a,1} = endTime;
                    if isempty(startTime) == true || isempty(endTime) == true
                        b = false;
                    end
                else
                    startTime = 0;
                    endTime = 0;
                    ManualDecisions.startTimes{a,1} = 0;
                    ManualDecisions.endTimes{a,1} = 0;
                end
                close(singleTrialFig)
                load(procDataFileID)
                ProcData.manualBaselineInfo.fileDecision = fileDecision;
                ProcData.manualBaselineInfo.startTime = startTime;
                ProcData.manualBaselineInfo.endTime = endTime;
                save(procDataFileID,'ProcData')
            else
                b = false;
                close(singleTrialFig)
            end
        end
    else
        ManualDecisions.validFiles{a,1} = ProcData.manualBaselineInfo.fileDecision;
        ManualDecisions.startTimes{a,1} = ProcData.manualBaselineInfo.startTime;
        ManualDecisions.endTimes{a,1} = ProcData.manualBaselineInfo.endTime;
    end
end
% save structure with each file's decision and start/end time
save([animalID '_ManualBaselineFileList.mat'],'ManualDecisions')
% decimate the unique file list to identify which files we decided to use for resting time
% pull the start/end times along with each desired file
c = 1;
for d = 1:length(ManualDecisions.validFiles)
    if strcmp(ManualDecisions.validFiles{d,1},'y') == true
        fileBreaks = strfind(ManualDecisions.fileIDs{d,1},'_');
        subFilterFileList{c,1} = ManualDecisions.fileIDs{d,1}(fileBreaks(1) + 1:fileBreaks(end) - 1); %#ok<*AGROW>
        subFilterStartTimes{c,1} = ManualDecisions.startTimes{d,1};
        subFilterEndTimes{c,1} = ManualDecisions.endTimes{d,1};
        c = c + 1;
    end
end
% find the fieldnames of RestData and loop through each field. Each fieldname should be a different dataType of interest.
% these will typically be CBV, Delta, Theta, Gamma, and MUA, etc
dataTypes = fieldnames(RestData);
for e = 1:length(dataTypes)
    dataType = char(dataTypes(e));
    % find any sub-dataTypes. These are typically LH, RH
    subDataTypes = fieldnames(RestData.(dataType));
    for f = 1:length(subDataTypes)
        subDataType = char(subDataTypes(f));
        % use the criteria we specified earlier to find all resting events that are greater than the criteria
        [restLogical] = FilterEvents_JNeurosci2022(RestData.(dataType).(subDataType),RestCriteria);
        [puffLogical] = FilterEvents_JNeurosci2022(RestData.(dataType).(subDataType),PuffCriteria);
        combRestLogical = logical(restLogical.*puffLogical);
        allRestFileIDs = RestData.(dataType).(subDataType).fileIDs(combRestLogical,:);
        allRestDurations = RestData.(dataType).(subDataType).durations(combRestLogical,:);
        allRestEventTimes = RestData.(dataType).(subDataType).eventTimes(combRestLogical,:);
        allRestingData = RestData.(dataType).(subDataType).data(combRestLogical,:);
        % find the unique days and unique file IDs
        uniqueDays = GetUniqueDays_JNeurosci2022(RestData.(dataType).(subDataType).fileIDs);
        uniqueFiles = unique(RestData.(dataType).(subDataType).fileIDs);
        numberOfFiles = length(unique(RestData.(dataType).(subDataType).fileIDs));
        % loop through each unique day in order to create a logical to filter the file list
        for g = 1:length(uniqueDays)
            uniqueDay = uniqueDays(g);
            h = 1;
            for j = 1:numberOfFiles
                uniqueFileID = uniqueFiles(j);
                uniqueFileID_short = uniqueFileID{1}(1:6);
                goodFile = 'n';
                % determine if the file occurs during this specific day - this is for all files
                for k = 1:length(subFilterFileList)
                    subFilterFile = subFilterFileList{k,1};
                    if strcmp(uniqueFileID,subFilterFile) == true
                        goodFile = 'y';
                    end
                end
                % determine whether the approved files are part of the 'approved' file list
                if strcmp(uniqueDay,uniqueFileID_short) == true && strcmp(goodFile,'y') == true
                    uniqueDayFiltLogical{g,1}(j,1) = 1;
                    h = h + 1;
                else
                    uniqueDayFiltLogical{g,1}(j,1) = 0;
                end
            end
        end
        finalUniqueDayFiltLogical = any(sum(cell2mat(uniqueDayFiltLogical'),2),2);
        % now that the appropriate files from each day are identified, loop through each file name with respect to the original
        % list of ALL resting files, only keeping the ones that fall within the first targetMinutes of each day.
        filtRestFiles = uniqueFiles(finalUniqueDayFiltLogical,:);
        for m = 1:length(allRestFileIDs)
            fileCompare = strcmp(allRestFileIDs{m},filtRestFiles);
            includeFile = sum(fileCompare);
            if includeFile == 1
                allFileFilter(m,1) = 1;
            else
                allFileFilter(m,1) = 0;
            end
        end
        AllFileFilter = logical(allFileFilter);
        filtFileIDs = allRestFileIDs(AllFileFilter,:);
        filtDurations = allRestDurations(AllFileFilter,:);
        filtEventTimes = allRestEventTimes(AllFileFilter,:);
        filtRestData = allRestingData(AllFileFilter,:);
        % now that we have decimated the original list to only reflect the proper unique day, approved files
        % we want to only take events that occur during our approved time duration
        for n = 1:length(filtFileIDs)
            finalFileID = filtFileIDs{n,1};
            for o = 1:length(subFilterFileList)
                sFile = subFilterFileList{o,1};
                if strcmp(finalFileID,sFile) == true
                    sTime = subFilterStartTimes{o,1};
                    eTime = subFilterEndTimes{o,1};
                end
            end
            eventTime = filtEventTimes(n,1);
            % 2 seconds before event time, 10 seconds after
            if (eventTime-2) >= sTime && (eventTime+10) <= eTime
                eventTimeFilter(n,1) = 1;
            else
                eventTimeFilter(n,1) = 0;
            end
        end
        EventTimeFilter = logical(eventTimeFilter);
        finalEventFileIDs = filtFileIDs(EventTimeFilter,:);
        finalEventDurations = filtDurations(EventTimeFilter,:);
        finalEventTimes = filtEventTimes(EventTimeFilter,:);
        finalEventRestData = filtRestData(EventTimeFilter,:);
        % again loop through each unique day and pull out the data that corresponds to the final resting files
        for p = 1:length(uniqueDays)
            q= 1;
            for r = 1:length(finalEventFileIDs)
                uniqueFileID_short = finalEventFileIDs{r,1}(1:6);
                uniqueDate{p,1} = ConvertDate_JNeurosci2022(uniqueDays{p,1});
                if strcmp(uniqueFileID_short,uniqueDays{p,1}) == 1
                    tempData.(uniqueDate{p,1}){q,1} = finalEventRestData{r,1};
                    q = q + 1;
                end
            end
        end
        % find the means of each unique day
        for s = 1:size(uniqueDate,1)
            tempDataMeans{s,1} = cellfun(@(x)mean(x),tempData.(uniqueDate{s,1}));
        end
        % save the means into the Baseline struct under the current loop iteration with the associated dates
        for t = 1:length(uniqueDays)
            RestingBaselines.manualSelection.(dataType).(subDataType).(uniqueDate{t,1}) = mean(tempDataMeans{t,1});
        end
    end
end
% save results
RestingBaselines.manualSelection.baselineFileInfo.fileIDs = finalEventFileIDs;
RestingBaselines.manualSelection.baselineFileInfo.eventTimes = finalEventTimes;
RestingBaselines.manualSelection.baselineFileInfo.durations = finalEventDurations;
RestingBaselines.manualSelection.baselineFileInfo.selections = ManualDecisions.validFiles;
RestingBaselines.manualSelection.baselineFileInfo.selectionFiles = ManualDecisions.fileIDs;
save(baselineDataFileID,'RestingBaselines')

end
