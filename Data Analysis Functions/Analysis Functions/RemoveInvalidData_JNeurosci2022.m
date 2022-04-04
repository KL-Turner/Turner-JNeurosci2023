function [decData,decFileIDs,decDurations,decEventTimes] = RemoveInvalidData_IOS(data,fileIDs,durations,eventTimes,ManualDecisions)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: Remove resting events from the various fields that aren't in the manual selection
%________________________________________________________________________________________________________________________

trialDuration_sec = 900;   % sec
offset = 0.5;   % sec
x = 1;
for a = 1:size(data,1)
    fileID = fileIDs{a,1};
    startTime = eventTimes(a,1);
    endTime = startTime + durations(a,1);
    manualStartTime = [];
    manualEndTime = [];
    for b = 1:length(ManualDecisions.fileIDs)
        [~,~,manualFileID] = GetFileInfo_IOS(ManualDecisions.fileIDs{b,1});
        if strcmp(fileID,manualFileID) == true
            manualStartTime = ManualDecisions.startTimes{b,1};
            manualEndTime = ManualDecisions.endTimes{b,1};
        end
    end
    % check that the event falls within appropriate bounds
    if startTime >= manualStartTime && endTime <= manualEndTime
        if startTime >= offset && endTime <= (trialDuration_sec - offset)
            if iscell(data) == true
                decData{x,1} = data{a,1}; %#ok<*AGROW>
            else
                decData(x,:) = data(a,:);
            end
            decFileIDs{x,1} = fileIDs{a,1};
            decDurations(x,1) = durations(a,1);
            decEventTimes(x,1) = eventTimes(a,1);
            x = x + 1;
        end
    end
end

end

