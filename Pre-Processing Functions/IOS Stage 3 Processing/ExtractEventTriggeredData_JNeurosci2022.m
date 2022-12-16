function [EventData] = ExtractEventTriggeredData_JNeurosci2022(procdataFiles,dataTypes,imagingType)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%
% Purpose: Extracts all event-triggered data from the data using behavioral flags
%________________________________________________________________________________________________________________________

EventData = [];
epoch.duration = 12;
epoch.offset = 2;
% control for dataTypes as string
if not(iscell(dataTypes))
    dataTypes = {dataTypes};
end
for a = 1:length(dataTypes)
    dataType = char(dataTypes(a));
    if strcmp(dataType,'CBV') == true || strcmp(dataType,'CBV_HbT') == true || strcmp(dataType,'GCaMP7s') == true || strcmp(dataType,'Deoxy') == true
        if strcmpi(imagingType,'bilateral') == true 
            subDataTypes = {'LH','adjLH','RH','adjRH'};
        elseif strcmpi(imagingType,'GCaMP') == true
            subDataTypes = {'LH','RH','frontalLH','frontalRH'};
        elseif strcmpi(imagingType,'single') == true
            subDataTypes = {'Barrels','adjBarrels','Veinous'};
        end
    elseif strcmp(dataType,'EMG') == true
        subDataTypes = {'emg'};
    elseif strcmp(dataType,'flow') == true
        subDataTypes = {'data'};
    else
        subDataTypes = {'deltaBandPower','thetaBandPower','alphaBandPower','betaBandPower','gammaBandPower','muaPower'};
    end
    temp = struct();
    for b = 1:size(procdataFiles,1)
        % load ProcData File
        filename = procdataFiles(b,:);
        load(filename);
        % get the date and file ID to include in the EventData structure
        [animal,fileDate,fileID] = GetFileInfo_JNeurosci2022(procdataFiles(b,:));
        % get the types of behaviors present in the file (stim,whisk,rest)
        holddata = fieldnames(ProcData.flags);
        behaviorFields = holddata([1,2],1);
        for c = 1:length(subDataTypes)
            sDT = char(subDataTypes(c));
            % set the sampling frequency for the dataType
            samplingRate = ProcData.notes.dsFs;
            trialDuration_sec = ProcData.notes.trialDuration_sec;
            % loop over the behaviors present in the file
            for d = 1:length(behaviorFields)
                % Pre-allocate space for unknown number of events using a
                % 'temporary' structure of cells
                if not(isfield(temp,sDT))
                    temp.(sDT) = [];
                end
                % create behavioral subfields for the temp structure, if needed
                if not(isfield(temp.(sDT),behaviorFields{d}))
                    subFields = fieldnames(ProcData.flags.(behaviorFields{d}));
                    blankCell = cell(1,size(procdataFiles,1));
                    structVals = cell(size(subFields));
                    structVals(:) = {blankCell};
                    temp.(sDT).(behaviorFields{d}) = cell2struct(structVals,subFields,1)';
                    temp.(sDT).(behaviorFields{d}).fileIDs = blankCell;
                    temp.(sDT).(behaviorFields{d}).fileDates = blankCell;
                    temp.(sDT).(behaviorFields{d}).data = blankCell;
                end
                % assemble a structure to send to the sub-functions
                fieldName2 = dataType;
                try
                    data = ProcData.data.(fieldName2);
                catch % some files don't have certain fields. Skip those
                    data = [];
                end
                data.Flags = ProcData.flags;
                data.notes = ProcData.notes;
                % extract the data from the epoch surrounding the event
                disp(['Extracting ' dataType ' ' sDT ' event-triggered ' behaviorFields{d} ' data from file ' num2str(b) ' of ' num2str(size(procdataFiles,1)) '...']); disp(' ');
                try
                    [chunkdata,evFilter] = ExtractBehavioralData(data,epoch,sDT,behaviorFields{d});
                catch
                    chunkdata = [];
                    evFilter = [];
                end
                % add epoch details to temp struct
                [temp] = AddEpochInfo(data,sDT,behaviorFields{d},temp,fileID,fileDate,evFilter,b);
                temp.(sDT).(behaviorFields{d}).data{b} = chunkdata;
                % add the sampling frequency, assume all Fs are the same for given datatype
                temp.(sDT).(behaviorFields{d}).samplingRate = {samplingRate};
                temp.(sDT).(behaviorFields{d}).trialDuration_sec = {trialDuration_sec};
            end
        end
    end
    % convert the temporary stuct into a final structure
    [EventData] = ProcessTempStruct(EventData,dataType,temp,epoch);
end
save([animal '_EventData.mat'],'EventData','-v7.3');

end

function [chunkdata,evFilter] = ExtractBehavioralData(data,epoch,dataType,behavior)
% setup variables
eventTime = data.Flags.(behavior).eventTime;
trialDuration = data.notes.trialDuration_sec;
samplingRate = data.notes.dsFs;
% get the content from data.(dataType)
data = getfield(data,{},dataType,{});
% calculate start/stop times (seconds) for the events
allEpochStarts = eventTime - epoch.offset*ones(size(eventTime));
allEpochEnds = allEpochStarts + epoch.duration*ones(size(eventTime));
% filter out events which are too close to the beginning or end of trials
startFilter = allEpochStarts > 0;
stopFilter = round(allEpochEnds) < trialDuration; % apply "round" to give an extra half second buffer and prevent indexing errors
evFilter = logical(startFilter.*stopFilter);
% convert the starts from seconds to samples, round down to the nearest sample, coerce the value above 1.
epochStarts = max(floor(allEpochStarts(evFilter)*samplingRate),1);
% calculate stops indices using the duration of the epoch, this avoids potential matrix dimension erros caused by differences in rounding when converting from seconds to samples.
sampleDur = round(epoch.duration*samplingRate);
epochStops = epochStarts + sampleDur*ones(size(epochStarts));
% extract the chunk of data from the trial
chunkdata = zeros(sampleDur + 1,length(epochStarts),size(data,1));
for a = 1:length(epochStarts)
    chunkInds = epochStarts(a):epochStops(a);
    chunkdata(:,a,:) = data(:,chunkInds)';
end

end

function [temp] = AddEpochInfo(data,dataType,behavior,temp,fileID,fileDate,evFilter,f)
% get the field names for each behavior
fields = fieldnames(data.Flags.(behavior));
% filter out the events which are too close to the trial edge
for a = 1:length(fields)
    field = fields{a};
    temp.(dataType).(behavior).(field){f} = data.Flags.(behavior).(field)(evFilter,:)';
end
% tag each event with the file ID, arrange cell array horizontally for later processing.
temp.(dataType).(behavior).fileIDs{f} = repmat({fileID},1,sum(evFilter));
temp.(dataType).(behavior).fileDates{f} = repmat({fileDate},1,sum(evFilter));

end

function [EventData] = ProcessTempStruct(EventData,dataType,temp,epoch)
% get the dataTypes from temp
dTs = fieldnames(temp);
for a = 1:length(dTs)
    dT = dTs{a};
    % get dataType names
    behaviorFields = fieldnames(temp.(dT));
    % intialize Behavior fields of the dataType sub-structure
    structArray2 = cell(size(behaviorFields));
    EventData.(dataType).(dT) = cell2struct(structArray2,behaviorFields,1);
    for b = 1:length(behaviorFields)
        behavior = behaviorFields{b};
        % get Behavior names
        eventFields = fieldnames(temp.(dT).(behavior));
        % initialize Event fields for the Behavior sub-structure
        structArray3 = cell(size(eventFields));
        EventData.(dataType).(dT).(behavior) = cell2struct(structArray3,eventFields,1);
        for c = 1:length(eventFields)
            evField = eventFields{c};
            transferArray = [temp.(dT).(behavior).(evField){:}];
            EventData.(dataType).(dT).(behavior).(evField) = permute(transferArray,unique([2,1,ndims(transferArray)],'stable'));
        end
        EventData.(dataType).(dT).(behavior).epoch = epoch;
    end
end

end
