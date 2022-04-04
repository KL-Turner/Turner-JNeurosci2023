function [] = UpdatePupilSleepData_JNeurosci2022(procDataFileIDs)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% Ph.D. Candidate, Department of Bioengineering
% The Pennsylvania State University
%________________________________________________________________________________________________________________________
%
%   Purpose: This function uses the sleep logicals in each ProcData file to find periods where there are 60 seconds of
%            consecutive ones within the sleep logical (12 or more). If a ProcData file's sleep logical contains one or
%            more of these 60 second periods, each of those bins is gathered from the data and put into the SleepEventData.mat
%            struct along with the file's name.
%________________________________________________________________________________________________________________________
%
%   Inputs: The function loops through each ProcData file within the current folder - no inputs to the function itself
%           This was done as it was easier to add to the SleepEventData struct instead of loading it and then adding to it
%           with each ProcData loop.
%
%   Outputs: SleepEventData.mat struct
%________________________________________________________________________________________________________________________

sleepDataFileStruct = dir('*_SleepData.mat');
sleepDataFiles = {sleepDataFileStruct.name}';
sleepDataFileID = char(sleepDataFiles);
load(sleepDataFileID)
modelName = 'Forest';
NREMsleepTime = 30;   % seconds
REMsleepTime = 60;   % seconds
SleepData.Forest.NREM.data.Pupil = [];
SleepData.Forest.REM.data.Pupil = [];
dataTypes = {'pupilArea','diameter','mmArea','mmDiameter','zArea','zDiameter','LH_HbT','RH_HbT','LH_gammaBandPower','RH_gammaBandPower'};
%% BLOCK PURPOSE: Create sleep scored data structure.
% Identify sleep epochs and place in SleepEventData.mat structure
sleepBins = NREMsleepTime/5;
for a = 1:size(procDataFileIDs,1) % Loop through the list of ProcData files
    clearvars -except sleepBins a procDataFileIDs NREMsleepTime REMsleepTime SleepData modelName sleepDataFileID dataTypes
    procDataFileID = procDataFileIDs(a,:); % Pull character string associated with the current file
    load(procDataFileID); % Load in procDataFile associated with character string
    [~,~,fileID] = GetFileInfo_JNeurosci2022(procDataFileID); % Gather file info
    if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
        nremLogical = ProcData.sleep.logicals.(modelName).nremLogical; % Logical - ones denote potential sleep epoches (5 second bins)
        targetTime = ones(1,sleepBins);   % Target time
        sleepIndex = find(conv(nremLogical,targetTime) >= sleepBins) - (sleepBins - 1); % Find the periods of time where there are at least 11 more
        % 5 second epochs following. This is not the full list.
        if isempty(sleepIndex) % If sleepIndex is empty, skip this file
            % Skip file
        else
            sleepCriteria = (0:(sleepBins - 1)); % This will be used to fix the issue in sleepIndex
            fixedSleepIndex = unique(sleepIndex + sleepCriteria); % sleep Index now has the proper time stamps from sleep logical
            for indexCount = 1:length(fixedSleepIndex) % Loop through the length of sleep Index, and pull out associated data
                for aa = 1:length(dataTypes)
                    dataType = dataTypes{1,aa};
                    if strcmp(dataType,'LH_HbT') == true
                        data.(dataType).data{indexCount,1} = ProcData.sleep.parameters.CBV.hbtLH{fixedSleepIndex(indexCount),1}; %#ok<*AGROW>
                    elseif strcmp(dataType,'RH_HbT') == true
                        data.(dataType).data{indexCount,1} = ProcData.sleep.parameters.CBV.hbtRH{fixedSleepIndex(indexCount),1}; %#ok<*AGROW>
                    elseif strcmp(dataType,'LH_gammaBandPower') == true
                        data.(dataType).data{indexCount,1} = ProcData.sleep.parameters.cortical_LH.gammaBandPower{fixedSleepIndex(indexCount),1}; %#ok<*AGROW>
                    elseif strcmp(dataType,'RH_gammaBandPower') == true
                        data.(dataType).data{indexCount,1} = ProcData.sleep.parameters.cortical_RH.gammaBandPower{fixedSleepIndex(indexCount),1}; %#ok<*AGROW>
                    else
                        data.(dataType).data{indexCount,1} = ProcData.sleep.parameters.Pupil.(dataType){fixedSleepIndex(indexCount),1}; %#ok<*AGROW>
                    end
                end
                binTimes{indexCount,1} = 5*fixedSleepIndex(indexCount);
            end
            indexBreaks = find(fixedSleepIndex(2:end) - fixedSleepIndex(1:end - 1) > 1); % Find if there are numerous sleep periods
            if isempty(indexBreaks) % If there is only one period of sleep in this file and not multiple
                % pupil area
                for aa = 1:length(dataTypes)
                    dataType = dataTypes{1,aa};
                    data.(dataType).matpupilArea = cell2mat(data.(dataType).data);
                    data.(dataType).arraypupilArea = reshape(data.(dataType).matpupilArea',[1,size(data.(dataType).matpupilArea,2)*size(data.(dataType).matpupilArea,1)]);
                    data.(dataType).cellpupilArea = {data.(dataType).arraypupilArea};
                end
                % bin times
                matBinTimes = cell2mat(binTimes);
                arrayBinTimes = reshape(matBinTimes',[1,size(matBinTimes,2)*size(matBinTimes,1)]);
                cellBinTimes = {arrayBinTimes};
            else
                count = length(fixedSleepIndex);
                holdIndex = zeros(1,(length(indexBreaks) + 1));
                for indexCounter = 1:length(indexBreaks) + 1
                    if indexCounter == 1
                        holdIndex(indexCounter) = indexBreaks(indexCounter);
                    elseif indexCounter == length(indexBreaks) + 1
                        holdIndex(indexCounter) = count - indexBreaks(indexCounter - 1);
                    else
                        holdIndex(indexCounter)= indexBreaks(indexCounter) - indexBreaks(indexCounter - 1);
                    end
                end
                for aa = 1:length(dataTypes)
                    dataType = dataTypes{1,aa};
                    splitCounter = 1:length(data.(dataType).data);
                    convertedMat2Cell = mat2cell(splitCounter',holdIndex);
                    for matCounter = 1:length(convertedMat2Cell)
                        data.(dataType).mat2CellpupilArea{matCounter,1} = data.(dataType).data(convertedMat2Cell{matCounter,1});
                        mat2CellBinTimes{matCounter,1} = binTimes(convertedMat2Cell{matCounter,1});
                    end
                    for cellCounter = 1:length(data.(dataType).mat2CellpupilArea)
                        % pupil area
                        data.(dataType).matpupilArea = cell2mat(data.(dataType).mat2CellpupilArea{cellCounter, 1});
                        data.(dataType).arraypupilArea = reshape(data.(dataType).matpupilArea',[1,size(data.(dataType).matpupilArea,2)*size(data.(dataType).matpupilArea,1)]);
                        data.(dataType).cellpupilArea{cellCounter, 1} = data.(dataType).arraypupilArea;
                        % bin times
                        matBinTimes = cell2mat(mat2CellBinTimes{cellCounter,1});
                        arrayBinTimes = reshape(matBinTimes',[1,size(matBinTimes,2)*size(matBinTimes,1)]);
                        cellBinTimes{cellCounter,1} = arrayBinTimes;
                    end
                    %% BLOCK PURPOSE: Save the data in the SleepEventData struct
                    for cellLength = 1:size(data.(dataType).cellpupilArea,1) % Loop through however many sleep epochs this file has
                        if isfield(SleepData.(modelName).NREM.data.Pupil,(dataType)) == false
                            SleepData.(modelName).NREM.data.Pupil.(dataType).data{cellLength,1} = data.(dataType).cellpupilArea{1,1};
                            if aa == 1
                                SleepData.(modelName).NREM.data.Pupil.binTimes{cellLength,1} = cellBinTimes{1,1};
                                SleepData.(modelName).NREM.data.Pupil.fileIDs{cellLength,1} = fileID;
                            end
                        else
                            SleepData.(modelName).NREM.data.Pupil.(dataType).data{size(SleepData.(modelName).NREM.data.Pupil.(dataType).data,1) + 1,1} = data.(dataType).cellpupilArea{cellLength,1};
                            if aa == 1
                                SleepData.(modelName).NREM.data.Pupil.binTimes{size(SleepData.(modelName).NREM.data.Pupil.binTimes,1) + 1,1} = cellBinTimes{cellLength,1};
                                SleepData.(modelName).NREM.data.Pupil.fileIDs{size(SleepData.(modelName).NREM.data.Pupil.fileIDs,1) + 1,1} = fileID;
                            end
                        end
                    end
                    disp(['Adding NREM sleeping epochs from ProcData file ' num2str(a) ' of ' num2str(size(procDataFileIDs, 1)) '...']); disp(' ')
                end
            end
        end
    end
end
%% REM
sleepBins = REMsleepTime/5;
for a = 1:size(procDataFileIDs,1) % Loop through the list of ProcData files
    clearvars -except sleepBins a procDataFileIDs REMsleepTime REMsleepTime SleepData modelName sleepDataFileID dataTypes
    procDataFileID = procDataFileIDs(a,:); % Pull character string associated with the current file
    load(procDataFileID); % Load in procDataFile associated with character string
    [~,~,fileID] = GetFileInfo_JNeurosci2022(procDataFileID); % Gather file info
    if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
        remLogical = ProcData.sleep.logicals.(modelName).remLogical; % Logical - ones denote potential sleep epoches (5 second bins)
        targetTime = ones(1,sleepBins);   % Target time
        sleepIndex = find(conv(remLogical,targetTime) >= sleepBins) - (sleepBins - 1); % Find the periods of time where there are at least 11 more
        % 5 second epochs following. This is not the full list.
        if isempty(sleepIndex) % If sleepIndex is empty, skip this file
            % Skip file
        else
            sleepCriteria = (0:(sleepBins - 1)); % This will be used to fix the issue in sleepIndex
            fixedSleepIndex = unique(sleepIndex + sleepCriteria); % sleep Index now has the proper time stamps from sleep logical
            for indexCount = 1:length(fixedSleepIndex) % Loop through the length of sleep Index, and pull out associated data
                for aa = 1:length(dataTypes)
                    dataType = dataTypes{1,aa};
                    if strcmp(dataType,'LH_HbT') == true
                        data.(dataType).data{indexCount,1} = ProcData.sleep.parameters.CBV.hbtLH{fixedSleepIndex(indexCount),1}; %#ok<*AGROW>
                    elseif strcmp(dataType,'RH_HbT') == true
                        data.(dataType).data{indexCount,1} = ProcData.sleep.parameters.CBV.hbtRH{fixedSleepIndex(indexCount),1}; %#ok<*AGROW>
                    elseif strcmp(dataType,'LH_gammaBandPower') == true
                        data.(dataType).data{indexCount,1} = ProcData.sleep.parameters.cortical_LH.gammaBandPower{fixedSleepIndex(indexCount),1}; %#ok<*AGROW>
                    elseif strcmp(dataType,'RH_gammaBandPower') == true
                        data.(dataType).data{indexCount,1} = ProcData.sleep.parameters.cortical_RH.gammaBandPower{fixedSleepIndex(indexCount),1}; %#ok<*AGROW>
                    else
                        data.(dataType).data{indexCount,1} = ProcData.sleep.parameters.Pupil.(dataType){fixedSleepIndex(indexCount),1}; %#ok<*AGROW>
                    end
                end
                binTimes{indexCount,1} = 5*fixedSleepIndex(indexCount);
            end
            indexBreaks = find(fixedSleepIndex(2:end) - fixedSleepIndex(1:end - 1) > 1); % Find if there are numerous sleep periods
            if isempty(indexBreaks) % If there is only one period of sleep in this file and not multiple
                % pupil area
                for aa = 1:length(dataTypes)
                    dataType = dataTypes{1,aa};
                    data.(dataType).matpupilArea = cell2mat(data.(dataType).data);
                    data.(dataType).arraypupilArea = reshape(data.(dataType).matpupilArea',[1,size(data.(dataType).matpupilArea,2)*size(data.(dataType).matpupilArea,1)]);
                    data.(dataType).cellpupilArea = {data.(dataType).arraypupilArea};
                end
                % bin times
                matBinTimes = cell2mat(binTimes);
                arrayBinTimes = reshape(matBinTimes',[1,size(matBinTimes,2)*size(matBinTimes,1)]);
                cellBinTimes = {arrayBinTimes};
            else
                count = length(fixedSleepIndex);
                holdIndex = zeros(1,(length(indexBreaks) + 1));
                for indexCounter = 1:length(indexBreaks) + 1
                    if indexCounter == 1
                        holdIndex(indexCounter) = indexBreaks(indexCounter);
                    elseif indexCounter == length(indexBreaks) + 1
                        holdIndex(indexCounter) = count - indexBreaks(indexCounter - 1);
                    else
                        holdIndex(indexCounter)= indexBreaks(indexCounter) - indexBreaks(indexCounter - 1);
                    end
                end
                for aa = 1:length(dataTypes)
                    dataType = dataTypes{1,aa};
                    splitCounter = 1:length(data.(dataType).data);
                    convertedMat2Cell = mat2cell(splitCounter',holdIndex);
                    for matCounter = 1:length(convertedMat2Cell)
                        data.(dataType).mat2CellpupilArea{matCounter,1} = data.(dataType).data(convertedMat2Cell{matCounter,1});
                        mat2CellBinTimes{matCounter,1} = binTimes(convertedMat2Cell{matCounter,1});
                    end
                    for cellCounter = 1:length(data.(dataType).mat2CellpupilArea)
                        % pupil area
                        data.(dataType).matpupilArea = cell2mat(data.(dataType).mat2CellpupilArea{cellCounter, 1});
                        data.(dataType).arraypupilArea = reshape(data.(dataType).matpupilArea',[1,size(data.(dataType).matpupilArea,2)*size(data.(dataType).matpupilArea,1)]);
                        data.(dataType).cellpupilArea{cellCounter, 1} = data.(dataType).arraypupilArea;
                        % bin times
                        matBinTimes = cell2mat(mat2CellBinTimes{cellCounter,1});
                        arrayBinTimes = reshape(matBinTimes',[1,size(matBinTimes,2)*size(matBinTimes,1)]);
                        cellBinTimes{cellCounter,1} = arrayBinTimes;
                    end
                    %% BLOCK PURPOSE: Save the data in the SleepEventData struct
                    for cellLength = 1:size(data.(dataType).cellpupilArea,1) % Loop through however many sleep epochs this file has
                        if isfield(SleepData.(modelName).REM.data.Pupil,(dataType)) == false
                            SleepData.(modelName).REM.data.Pupil.(dataType).data{cellLength,1} = data.(dataType).cellpupilArea{1,1};
                            if aa == 1
                                SleepData.(modelName).REM.data.Pupil.binTimes{cellLength,1} = cellBinTimes{1,1};
                                SleepData.(modelName).REM.data.Pupil.fileIDs{cellLength,1} = fileID;
                            end
                        else
                            SleepData.(modelName).REM.data.Pupil.(dataType).data{size(SleepData.(modelName).REM.data.Pupil.(dataType).data,1) + 1,1} = data.(dataType).cellpupilArea{cellLength,1};
                            if aa == 1
                                SleepData.(modelName).REM.data.Pupil.binTimes{size(SleepData.(modelName).REM.data.Pupil.binTimes,1) + 1,1} = cellBinTimes{cellLength,1};
                                SleepData.(modelName).REM.data.Pupil.fileIDs{size(SleepData.(modelName).REM.data.Pupil.fileIDs,1) + 1,1} = fileID;
                            end
                        end
                    end
                    disp(['Adding REM sleeping epochs from ProcData file ' num2str(a) ' of ' num2str(size(procDataFileIDs, 1)) '...']); disp(' ')
                end
            end
        end
    end
end
disp([modelName ' model data added to SleepData structure.']); disp(' ')
save(sleepDataFileID,'SleepData')

end
