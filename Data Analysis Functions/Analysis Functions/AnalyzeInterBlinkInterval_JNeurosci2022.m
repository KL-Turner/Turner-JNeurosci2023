function [Results_InterBlinkInterval] = AnalyzeInterBlinkInterval_Pupil(animalID,rootFolder,delim,Results_InterBlinkInterval)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose:
%________________________________________________________________________________________________________________________

%% only run analysis for valid animal IDs
dataLocation = [rootFolder delim 'Data' delim animalID delim 'Bilateral Imaging'];
cd(dataLocation)
% find and load RestingBaselines.mat struct
baselineDataFileStruct = dir('*_RestingBaselines.mat');
baselineDataFile = {baselineDataFileStruct.name}';
baselineDataFileID = char(baselineDataFile);
load(baselineDataFileID,'-mat')
% procdata file IDs
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
% find and load manual baseline event information
scoringResultsFileStruct = dir('*Forest_ScoringResults.mat');
scoringResultsFile = {scoringResultsFileStruct.name}';
scoringResultsFileID = char(scoringResultsFile);
load(scoringResultsFileID,'-mat')
samplingRate = 30; % lowpass filter
catDurations = [];
catAllDurations = [];
catInterBlinkInterval = [];
for aa = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(aa,:);
    [animalID,~,~] = GetFileInfo_IOS(procDataFileID);
    load(procDataFileID)
    if strcmp(ProcData.data.Pupil.frameCheck,'y') == true
        if isfield(ProcData.data.Pupil,'shiftedBlinks') == true
            blinks = ProcData.data.Pupil.shiftedBlinks;
        elseif isempty(ProcData.data.Pupil.blinkInds) == false
            blinks = ProcData.data.Pupil.blinkInds;
        else
            blinks = [];
        end
        bb = 1;
        verifiedBlinks = [];
        for cc = 1:length(blinks)
            if strcmp(ProcData.data.Pupil.blinkCheck{1,cc},'y') == true
                verifiedBlinks(1,bb) = blinks(1,cc);
                bb = bb + 1;
            end
        end
        % stimulation times
        try
            stimTimes = cat(2,ProcData.data.stimulations.LPadSol,ProcData.data.stimulations.RPadSol,ProcData.data.stimulations.AudSol);
            stimSamples = sort(round(stimTimes)*samplingRate,'ascend');
        catch
            stimTimes = cat(2,ProcData.data.solenoids.LPadSol,ProcData.data.solenoids.RPadSol,ProcData.data.solenoids.AudSol);
            stimSamples = sort(round(stimTimes)*samplingRate,'ascend');
        end
        qq = 1;
        blinkEvents = [];
        for xx = 1:length(verifiedBlinks)
            blinkSample = verifiedBlinks(1,xx);
            sampleCheck = true;
            for yy = 1:length(stimSamples)
                stimSample = stimSamples(1,yy);
                if blinkSample >= stimSample && blinkSample <= stimSample + samplingRate*5
                    sampleCheck = false;
                end
            end
            if sampleCheck == true
                blinkEvents(1,qq) = blinkSample;
                qq = qq + 1;
            end
        end
        % condense blinks
        condensedBlinkTimes = [];
        durations = [];
        if isempty(blinkEvents) == false
            cc = 1;
            for bb = 1:length(blinkEvents)
                if bb == 1
                    condensedBlinkTimes(1,bb) = blinkEvents(1,bb);
                    cc = cc + 1;
                else
                    timeDifference = blinkEvents(1,bb) - blinkEvents(1,bb - 1);
                    if timeDifference > 30
                        condensedBlinkTimes(1,cc) = blinkEvents(1,bb);
                        cc = cc + 1;
                    end
                end
            end
            blinkLogical = []; durations = [];
            for bb = 1:length(condensedBlinkTimes)
                blinkLogical(1,bb) = find(blinkEvents == condensedBlinkTimes(1,bb));
            end
            for cc = 1:length(blinkLogical)
                if cc < length(blinkLogical)
                    startTime = blinkEvents(blinkLogical(1,cc));
                    endTime = blinkEvents(blinkLogical(1,cc + 1) - 1);
                    durations(cc,1) = ((endTime - startTime) + 1)/30;
                elseif cc == length(blinkLogical)
                    if blinkLogical(1,cc) == length(blinkEvents)
                        durations(cc,1) = 1/30;
                    elseif blinkLogical(1,cc) < length(blinkEvents)
                        startTime = blinkEvents(blinkLogical(1,cc));
                        endTime = blinkEvents(end);
                        durations(cc,1) = ((endTime - startTime) + 1)/30;
                    end
                end
            end
            interBlinkInterval = [];
            for bb = 1:length(condensedBlinkTimes) - 1
                interBlinkInterval(bb,1) = condensedBlinkTimes(1,bb + 1)/30 - condensedBlinkTimes(1,bb)/30;
            end
        end
        if isempty(durations) == false
            if length(durations) > 1 == true
                catDurations = cat(1,catDurations,durations(1:end - 1));
            end
            catAllDurations = cat(1,catDurations,durations);
            catInterBlinkInterval = cat(1,catInterBlinkInterval,interBlinkInterval);
        end
    end
end
%% Save results
Results_InterBlinkInterval.(animalID).durations = catDurations;
Results_InterBlinkInterval.(animalID).allDurations = catAllDurations;
Results_InterBlinkInterval.(animalID).interBlinkInterval = catInterBlinkInterval;
% save data
cd([rootFolder delim])
save('Results_InterBlinkInterval.mat','Results_InterBlinkInterval')

end
