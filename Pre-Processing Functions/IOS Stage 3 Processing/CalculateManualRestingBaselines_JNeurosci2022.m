function [RestingBaselines] = CalculateManualRestingBaselines_JNeurosci2022(animalID,procDataFileIDs,RestData,RestingBaselines,imagingType)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% Ph.D. Candidate, Department of Bioengineering
% The Pennsylvania State University
%________________________________________________________________________________________________________________________
%
%   Purpose:
%________________________________________________________________________________________________________________________
%
%   Inputs:
%
%   Outputs:
%
%   Last Revision: October 4th, 2018
%________________________________________________________________________________________________________________________

disp('Calculating the resting baselines using manually selected files each unique day...'); disp(' ')

% The RestData.mat struct has all resting events, regardless of duration. We want to set the threshold for rest as anything
% that is greater than 10 seconds.
RestCriteria.Fieldname = {'durations'};
RestCriteria.Comparison = {'gt'};
RestCriteria.Value = {5};

puffCriteria.Fieldname = {'puffDistances'};
puffCriteria.Comparison = {'gt'};
puffCriteria.Value = {5};

baselineDataFileStruct = dir('*_RestingBaselines.mat');
baselineDataFiles = {baselineDataFileStruct.name}';
baselineDataFileID = char(baselineDataFiles);

manualBaselineFileStruct = dir('*_ManualBaselineFileList.mat');
manualBaselineFiles = {manualBaselineFileStruct.name}';
manualBaselineFileID = char(manualBaselineFiles);

if isfield(RestingBaselines,'manualSelection') == false && exist(manualBaselineFileID) == false
    validFiles = cell(size(procDataFileIDs,1),1);
    for a = 1:size(procDataFileIDs,1)
        disp(['Loading file ' num2str(a) ' of ' num2str(size(procDataFileIDs,1)) '...']); disp(' ')
        procDataFileID = procDataFileIDs(a,:);
        p{a,1} = procDataFileIDs(a,:);
        saveFigs = 'n';
        baselineType = 'setDuration';
        x = false;
        while x == false
            [singleTrialFig] = GenerateSingleFigures_JNeurosci2022(procDataFileID,RestingBaselines,baselineType,saveFigs,imagingType);
            fileDecision = input(['Use data from ' procDataFileID ' for resting baseline calculation? (y/n): '], 's'); disp(' ')
            if strcmp(fileDecision, 'y') || strcmp(fileDecision, 'n')
                x = true;
                validFiles{a,1} = fileDecision;
                close(singleTrialFig)
            else
                x = false;
                close(singleTrialFig)
            end
        end
    end
    save([animalID '_ManualBaselineFileList.mat'],'validFiles')
else
    for a = 1:size(procDataFileIDs,1)
        p{a,1} = procDataFileIDs(a,:);
    end
    disp('Manual-scoring already complete. Continuing...'); disp(' ')
    load(manualBaselineFileID)
end

q = 1;
for b = 1:length(validFiles)
    procDataFileID = procDataFileIDs(b,:);
    if strcmp(validFiles{b,1}, 'y') == true
        fileBreaks = strfind(procDataFileID, '_');
        subFilterList{q,1} = procDataFileID(fileBreaks(1)+1:fileBreaks(end)-1);
        q = q+1;
    end
end

% Find the fieldnames of RestData and loop through each field. Each fieldname should be a different dataType of interest.
% These will typically be CBV, Delta, Theta, Gamma, and MUA
dataTypes = fieldnames(RestData);
for a = 1:length(dataTypes)
    dataType = char(dataTypes(a));   % Load each loop iteration's fieldname as a character string
    subDataTypes = fieldnames(RestData.(dataType));   % Find the hemisphere dataTypes. These are typically LH, RH
    
    % Loop through each hemisphere dataType (LH, RH) because they are subfields and will have unique baselines
    for b = 1:length(subDataTypes)
        subDataType = char(subDataTypes(b));   % Load each loop iteration's hemisphere fieldname as a character string
        
        % Use the RestCriteria we specified earlier to find all resting events that are greater than the criteria
        [restLogical] = FilterEvents_JNeurosci2022(RestData.(dataType).(subDataType), RestCriteria);   % Output is a logical
        [puffLogical] = FilterEvents_JNeurosci2022(RestData.(dataType).(subDataType), puffCriteria);   % Output is a logical
        combRestLogical = logical(restLogical.*puffLogical);
        allRestFiles = RestData.(dataType).(subDataType).fileIDs(combRestLogical, :);   % Overall logical for all resting file names that meet criteria
        allRestDurations = RestData.(dataType).(subDataType).durations(combRestLogical, :);
        allRestEventTimes = RestData.(dataType).(subDataType).eventTimes(combRestLogical, :);
        restingData = RestData.(dataType).(subDataType).data(combRestLogical, :);   % Pull out data from all those resting files that meet criteria
        
        uniqueDays = GetUniqueDays_JNeurosci2022(RestData.(dataType).(subDataType).fileIDs);   % Find the unique days of imaging
        uniqueFiles = unique(RestData.(dataType).(subDataType).fileIDs);   % Find the unique files from the filelist. This removes duplicates
        % since most files have more than one resting event
        numberOfFiles = length(unique(RestData.(dataType).(subDataType).fileIDs));   % Find the number of unique files
        
        % Loop through each unique day in order to create a logical to filter the file list
        for c = 1:length(uniqueDays)
            day = uniqueDays(c);
            f = 1;
            for nOF = 1:numberOfFiles
                file = uniqueFiles(nOF);
                fileID = file{1}(1:6);
                goodFile = 'n';
                for z = 1:length(subFilterList)
                    subFilterFile = subFilterList{z,1};
                    if strcmp(file, subFilterFile) == true
                        goodFile = 'y';
                    end
                end
                
                if strcmp(day, fileID) && strcmp(goodFile, 'y')
                    filtLogical{c, 1}(nOF, 1) = 1;
                    f = f + 1;
                else
                    filtLogical{c, 1}(nOF, 1) = 0;
                end
            end
        end
        % Combine the 3 logicals so that it reflects the first "x" number of files from each day
        finalLogical = any(sum(cell2mat(filtLogical'), 2), 2);
        
        % Now that the appropriate files from each day are identified, loop through each file name with respect to the original
        % list of ALL resting files, only keeping the ones that fall within the first targetMinutes of each day.
        filtRestFiles = uniqueFiles(finalLogical, :);
        for d = 1:length(allRestFiles)
            logic = strcmp(allRestFiles{d}, filtRestFiles);
            logicSum = sum(logic);
            if logicSum == 1
                fileFilter(d, 1) = 1;
            else
                fileFilter(d, 1) = 0;
            end
        end
        
        finalFileFilter = logical(fileFilter);
        finalFileIDs = allRestFiles(finalFileFilter, :);
        finalFileDurations = allRestDurations(finalFileFilter, :);
        finalFileEventTimes = allRestEventTimes(finalFileFilter, :);
        finalRestData = restingData(finalFileFilter, :);
        
        % Loop through each unique day and pull out the data that corresponds to the resting files
        for e = 1:length(uniqueDays)
            z = 1;
            for f = 1:length(finalFileIDs)
                fileID = finalFileIDs{f, 1}(1:6);
                date{e, 1} = ConvertDate_JNeurosci2022(uniqueDays{e, 1});
                if strcmp(fileID, uniqueDays{e, 1}) == 1
                    tempData.(date{e, 1}){z, 1} = finalRestData{f, 1};
                    z = z + 1;
                end
            end
        end
        
        % find the means of each unique day
        for g = 1:size(date, 1)
            tempData_means{g, 1} = cellfun(@(x) mean(x), tempData.(date{g, 1}));    % LH date-specific means
        end
        
        % Save the means into the Baseline struct under the current loop iteration with the associated dates
        for h = 1:length(uniqueDays)
            RestingBaselines.manualSelection.(dataType).(subDataType).(date{h, 1}) = mean(tempData_means{h, 1});    % LH date-specific means
        end
        
    end
end

RestingBaselines.manualSelection.baselineFileInfo.fileIDs = finalFileIDs;
RestingBaselines.manualSelection.baselineFileInfo.eventTimes = finalFileEventTimes;
RestingBaselines.manualSelection.baselineFileInfo.durations = finalFileDurations;
RestingBaselines.manualSelection.baselineFileInfo.selections = validFiles;
RestingBaselines.manualSelection.baselineFileInfo.selectionFiles = p;

save(baselineDataFileID, 'RestingBaselines')

end
