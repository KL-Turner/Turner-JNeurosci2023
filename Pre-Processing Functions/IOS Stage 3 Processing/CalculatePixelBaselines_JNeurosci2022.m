function [RestingBaselines] = CalculatePixelBaselines_JNeurosci2022(procDataFileIDs,RestingBaselines,baselineType)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% Ph.D. Candidate, Department of Bioengineering
% The Pennsylvania State University
%________________________________________________________________________________________________________________________
%
%   Purpose: Uses the resting time indeces to extract the average resting power in each frequency bin during periods of
%            rest to normalize the spectrogram data.
%________________________________________________________________________________________________________________________

restFileList = unique(RestingBaselines.(baselineType).baselineFileInfo.fileIDs);      % Obtain the list of unique fileIDs
restPixels = cell(size(restFileList,1),1);
% Obtain the spectrogram information from all the resting files
for a = 1:length(restFileList)
    fileID = restFileList{a,1};   % FileID of currently loaded file
    % Load in frames from current file
    for b = 1:size(procDataFileIDs,1)
        procDataFileID = procDataFileIDs(b,:);
        [animalID,~,procDataFile] = GetFileInfo_JNeurosci2022(procDataFileID);
        if strcmp(fileID,procDataFile)
            load(procDataFileID)
            imageWidth = ProcData.notes.CBVCamPixelWidth;
            imageHeight = ProcData.notes.CBVCamPixelHeight;
            samplingRate = ProcData.notes.CBVCamSamplingRate;
            trialDuration_sec = ProcData.notes.trialDuration_sec;
            frameInds = 1:trialDuration_sec*samplingRate;
            windowCamFileID = [procDataFile '_WindowCam.bin'];
            [frames] = GetCBVFrameSubset_JNeurosci2022(windowCamFileID,imageHeight,imageWidth,frameInds);
            break
        end
    end
    restPixels{a,1} = frames;
end
for c = 1:length(restFileList)
    fileID = restFileList{c,1};
    strDay = ConvertDate_JNeurosci2022(fileID(1:6));
    frameSet = restPixels{c,1};
    trialRestData = [];
    for d = 1:length(RestingBaselines.(baselineType).baselineFileInfo.fileIDs)
        restFileID = RestingBaselines.(baselineType).baselineFileInfo.fileIDs{d,1};
        if strcmp(fileID,restFileID)
            try
                restDuration = floor(RestingBaselines.(baselineType).baselineFileInfo.durations(d,1)*samplingRate);
                startTime = floor(RestingBaselines.(baselineType).baselineFileInfo.eventTimes(d,1)*samplingRate);
            catch
                keyboard
            end
            try
                singleRestData = frameSet(:,:,(startTime:(startTime + restDuration)));
            catch
                singleRestData = frameSet(:,:,end - restDuration:end);
            end
            trialRestData = cat(3,singleRestData,trialRestData); %#ok<*AGROW>
        end
    end
    dayAvg = mean(trialRestData,3);
    RestingBaselines.(baselineType).CBV.pixelMatrix.(strDay) = dayAvg;
end
save([animalID '_RestingBaselines.mat'],'RestingBaselines');

end
