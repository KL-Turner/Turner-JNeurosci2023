function [RestData] = ExtractPupilRestingData_JNeurosci2022(procDataFileIDs,dataTypes)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%
% Purpose: Extracts all resting data periods from the data using behavioral flags
%________________________________________________________________________________________________________________________

% load rest data file
restDataFileID = ls('*_RestData.mat');
load(restDataFileID)
RestData.Pupil = [];
% analyze each proc data file
for aa = 1:length(dataTypes)
    dataType = dataTypes{1,aa};
    zz = 1;
    for c = 1:size(procDataFileIDs,1)
        disp(['Extracting resting pupil area from ProcData file ' num2str(c) '/' num2str(size(procDataFileIDs,1))]); disp(' ')
        procDataFileID = procDataFileIDs(c,:);
        load(procDataFileID);
        if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
            % get the date and file identifier for the data to be saved with each resting event
            [animal,fileDate,fileID] = GetFileInfo_JNeurosci2022(procDataFileID);
            % sampling frequency for element of dataTypes
            Fs = ProcData.notes.pupilCamSamplingRate;
            % expected number of samples for element of dataType
            trialDuration_sec = ProcData.notes.trialDuration_sec;
            expectedLength = trialDuration_sec*Fs;
            % get information about periods of rest from the loaded file
            trialEventTimes = ProcData.flags.rest.eventTime';
            trialPuffDistances = ProcData.flags.rest.puffDistance;
            trialDurations = ProcData.flags.rest.duration';
            % initialize cell array for all periods of rest from the loaded file
            trialRestVals = cell(size(trialEventTimes'));
            for d = 1:length(trialEventTimes)
                % extract the whole duration of the resting event. Coerce the
                % start index to values above 1 to preclude rounding to 0.
                startInd = max(floor(trialEventTimes(d)*Fs),1);
                % convert the duration from seconds to samples.
                dur = round(trialDurations(d)*Fs);
                % get ending index for data chunk. If event occurs at the end of
                % the trial, assume animal whisks as soon as the trial ends and
                % give a 200 ms buffer.
                stopInd = min(startInd + dur,expectedLength - round(0.2*Fs));
                try
                    % extract data from the trial and add to the cell array for the current loaded file
                    if strcmp(dataType,'LH_HbT') == true
                        trialRestVals{d} = ProcData.data.CBV_HbT.adjLH(:,startInd:stopInd);
                    elseif strcmp(dataType,'RH_HbT') == true
                        trialRestVals{d} = ProcData.data.CBV_HbT.adjRH(:,startInd:stopInd);
                    elseif strcmp(dataType,'LH_gammaBandPower') == true
                        trialRestVals{d} = ProcData.data.cortical_LH.gammaBandPower(:,startInd:stopInd);
                    elseif strcmp(dataType,'RH_gammaBandPower') == true
                        trialRestVals{d} = ProcData.data.cortical_RH.gammaBandPower(:,startInd:stopInd);
                    else
                        trialRestVals{d} = ProcData.data.Pupil.(dataType)(:,startInd:stopInd);
                    end
                catch % some files don't have certain fields. Skip those
                    trialRestVals{d} = [];
                end
            end
            % add all periods of rest to a cell array for all files
            restVals{zz,1} = trialRestVals';
            % transfer information about resting periods to the new structure
            eventTimes{zz,1} = trialEventTimes';
            durations{zz,1} = trialDurations';
            puffDistances{zz,1} = trialPuffDistances';
            fileIDs{zz,1} = repmat({fileID},1,length(trialEventTimes));
            fileDates{zz,1} = repmat({fileDate},1,length(trialEventTimes));
            zz = zz + 1;
        end
    end
    % combine the cells from separate files into a single cell array of all resting periods
    RestData.Pupil.(dataType).data = [restVals{:}]';
    RestData.Pupil.(dataType).eventTimes = cell2mat(eventTimes);
    RestData.Pupil.(dataType).durations = cell2mat(durations);
    RestData.Pupil.(dataType).puffDistances = [puffDistances{:}]';
    RestData.Pupil.(dataType).fileIDs = [fileIDs{:}]';
    RestData.Pupil.(dataType).fileDates = [fileDates{:}]';
    RestData.Pupil.(dataType).CBVCamSamplingRate = Fs;
    RestData.Pupil.(dataType).trialDuration_sec = trialDuration_sec;
end
% save updated structure
save([animal '_RestData.mat'],'RestData','-v7.3');

end
