function [RestingBaselines] = CalculateSpectrogramBaselines_JNeurosci2022(animal,neuralDataTypes,trialDuration_sec,RestingBaselines,baselineType)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Uses the resting time indeces to extract the average resting power in each frequency bin during periods of
%          rest to normalize the spectrogram data.
%________________________________________________________________________________________________________________________

for a = 1:length(neuralDataTypes)
    neuralDataType = neuralDataTypes{1,a};
    restFileList = unique(RestingBaselines.(baselineType).baselineFileInfo.fileIDs); % obtain the list of unique fileIDs
    restS1C = cell(size(restFileList,1),1);
    restS1B = cell(size(restFileList,1),1);
    restS5A = cell(size(restFileList,1),1);
    % obtain the spectrogram information from all the resting files
    for b = 1:length(restFileList)
        fileID = restFileList{b,1};   % FileID of currently loaded file
        % load in neural data from current file
        clear SpecData
        specDataFileIDA = [animal '_' fileID '_SpecDataA.mat'];
        load(specDataFileIDA,'-mat')
        S5A = SpecData.(neuralDataType).S;
        T5A = round(SpecData.(neuralDataType).T,3);
        restS5A{b,1} = S5A;
        clear SpecData
        specDataFileIDB = [animal '_' fileID '_SpecDataB.mat'];
        load(specDataFileIDB,'-mat')
        S1B = SpecData.(neuralDataType).S;
        T1B = round(SpecData.(neuralDataType).T,1);
        restS1B{b,1} = S1B;
        clear SpecData
        specDataFileIDC = [animal '_' fileID '_SpecDataC.mat'];
        load(specDataFileIDC,'-mat')
        S1C = SpecData.(neuralDataType).S;
        T1C = round(SpecData.(neuralDataType).T,1);
        restS1C{b,1} = S1C;
    end
    for d = 1:length(restFileList)
        fileID = restFileList{d,1};
        strDay = ConvertDate_JNeurosci2022(fileID(1:6));
        S1C_data = restS1C{d,1};
        S1B_data = restS1B{d,1};
        S5C_data = restS5A{d,1};
        binSize1C = 30;
        binSize1B = 10;
        binSize5A = 5;
        S1C_trialRest = [];
        S1B_trialRest = [];
        S5A_trialRest = [];
        for e = 1:length(RestingBaselines.(baselineType).baselineFileInfo.fileIDs)
            restFileID = RestingBaselines.(baselineType).baselineFileInfo.fileIDs{e,1};
            if strcmp(fileID,restFileID)
                restDuration1C = round(RestingBaselines.(baselineType).baselineFileInfo.durations(e,1),1);
                restDuration1B = round(RestingBaselines.(baselineType).baselineFileInfo.durations(e,1),1);
                restDuration5A = round(RestingBaselines.(baselineType).baselineFileInfo.durations(e,1),1);
                startTime1C = round(RestingBaselines.(baselineType).baselineFileInfo.eventTimes(e,1),1);
                startTime1B = round(RestingBaselines.(baselineType).baselineFileInfo.eventTimes(e,1),1);
                startTime5A = round(RestingBaselines.(baselineType).baselineFileInfo.eventTimes(e,1),1);
                % 1 second spectrogram conditions and indexing
                if startTime1C >= 0.5 && (startTime1C + restDuration1C) <= (trialDuration_sec - 0.5)
                    startTime1C_index = find(T1C == startTime1C);
                    startTime1C_index = startTime1C_index(1);
                    restDuration1C_Index = restDuration1C*binSize1C - 1;
                    restDuration1C_Index = restDuration1C_Index(1);
                    S1C_single_rest = S1C_data(:,(startTime1C_index:(startTime1C_index + restDuration1C_Index)));
                    S1C_trialRest = [S1C_single_rest,S1C_trialRest]; %#ok<*AGROW>
                end
                % 1 second (B) spectrogram conditions and indexing
                if startTime1B >= 0.5 && (startTime1B + restDuration1B) <= (trialDuration_sec - 0.5)
                    startTime1B_index = find(T1B == startTime1B);
                    startTime1B_index = startTime1B_index(1);
                    restDuration1B_Index = restDuration1B*binSize1B - 1;
                    restDuration1B_Index = restDuration1B_Index(1);
                    S1B_single_rest = S1B_data(:,(startTime1B_index:(startTime1B_index + restDuration1B_Index)));
                    S1B_trialRest = [S1B_single_rest,S1B_trialRest]; %#ok<*AGROW>
                end
                % 5 second spectrogram conditions and indexing
                if startTime5A >= 2.5 && (startTime5A + restDuration5A) <= (trialDuration_sec - 2.5)
                    [~,startTime5A_index] = min(abs(T5A - startTime5A));
                    restDuration5A_Index = floor(restDuration5A*binSize5A) - 1;
                    S5A_single_rest = S5C_data(:,(startTime5A_index:(startTime5A_index + restDuration5A_Index)));
                    S5A_trialRest = [S5A_single_rest,S5A_trialRest];
                end
            end
        end
        S_trialAvg1C = mean(S1C_trialRest,2);
        S_trialAvg1B = mean(S1B_trialRest,2);
        S_trialAvg5A = mean(S5A_trialRest,2);
        trialRestData.([strDay '_' fileID]).oneSecC.S_avg = S_trialAvg1C;
        trialRestData.([strDay '_' fileID]).oneSecB.S_avg = S_trialAvg1B;
        trialRestData.([strDay '_' fileID]).fiveSecA.S_avg = S_trialAvg5A;
    end
    fields = fieldnames(trialRestData);
    uniqueDays = GetUniqueDays_JNeurosci2022(RestingBaselines.(baselineType).baselineFileInfo.fileIDs);
    for f = 1:length(uniqueDays)
        g = 1;
        for field = 1:length(fields)
            if strcmp(fields{field}(7:12),uniqueDays{f})
                stringDay = ConvertDate_JNeurosci2022(uniqueDays{f});
                S_avgs.oneSecC.(stringDay){g,1} = trialRestData.(fields{field}).oneSecC.S_avg;
                S_avgs.oneSecB.(stringDay){g,1} = trialRestData.(fields{field}).oneSecB.S_avg;
                S_avgs.fiveSecA.(stringDay){g,1} = trialRestData.(fields{field}).fiveSecA.S_avg;
                g = g + 1;
            end
        end
    end
    dayFields = fieldnames(S_avgs.oneSecC);
    for h = 1:length(dayFields)
        dayVals1C = [];
        dayVals1B = [];
        dayVals5A = [];
        for j = 1:length(S_avgs.oneSecC.(dayFields{h}))
            dayVals1C = [dayVals1C,S_avgs.oneSecC.(dayFields{h}){j,1}];
            dayVals1B = [dayVals1B,S_avgs.oneSecB.(dayFields{h}){j,1}];
            dayVals5A = [dayVals5A,S_avgs.fiveSecA.(dayFields{h}){j,1}];
        end
        disp(['Adding spectrogram baseline to baseline file for ' neuralDataType ' on ' dayFields{h} '...']); disp(' ')
        RestingBaselines.Spectrograms.(neuralDataType).oneSecC.(dayFields{h}) = mean(dayVals1C,2);
        RestingBaselines.Spectrograms.(neuralDataType).oneSecB.(dayFields{h}) = mean(dayVals1B,2);
        RestingBaselines.Spectrograms.(neuralDataType).fiveSecA.(dayFields{h}) = mean(dayVals5A,2);
    end
end
save([animal '_RestingBaselines.mat'],'RestingBaselines');

end
