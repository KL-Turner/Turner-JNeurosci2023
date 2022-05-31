function [Results_BlinkTransition] = AnalyzeBlinkTransition_Turner2022(animalID,rootFolder,delim,Results_BlinkTransition)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Analyze arousal state probability transitions around blinking
%________________________________________________________________________________________________________________________

% go to animal's data location
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
trialDuration = 900;
samplingRate = 30; % lowpass filter
edgeTime = 30; % sec
binTime = 5; % sec
arousalClassifications = [];
fileIDs = {};
blinkTimes = [];
for aa = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(aa,:);
    [animalID,~,fileID] = GetFileInfo_Turner2022(procDataFileID);
    load(procDataFileID)
    % only run on data with accurate diameter tracking
    if strcmp(ProcData.data.Pupil.frameCheck,'y') == true
        % extract blink index
        if isfield(ProcData.data.Pupil,'shiftedBlinks') == true
            blinks = ProcData.data.Pupil.shiftedBlinks;
        elseif isempty(ProcData.data.Pupil.blinkInds) == false
            blinks = ProcData.data.Pupil.blinkInds;
        else
            blinks = [];
        end
        bb = 1;
        verifiedBlinks = [];
        % only keep manually verified blinks
        for cc = 1:length(blinks)
            if strcmp(ProcData.data.Pupil.blinkCheck{1,cc},'y') == true
                verifiedBlinks(1,bb) = blinks(1,cc);
                bb = bb + 1;
            end
        end
        % stimulation times
        if isfield(ProcData.data,'stimulations') == true
            stimTimes = cat(2,ProcData.data.stimulations.LPadSol,ProcData.data.stimulations.RPadSol,ProcData.data.stimulations.AudSol);
            stimSamples = sort(round(stimTimes)*samplingRate,'ascend');
        elseif isfield(ProcData.data,'solenoids') == true
            stimTimes = cat(2,ProcData.data.solenoids.LPadSol,ProcData.data.solenoids.RPadSol,ProcData.data.solenoids.AudSol);
            stimSamples = sort(round(stimTimes)*samplingRate,'ascend');
        end
        qq = 1;
        blinkEvents = [];
        % verify that each blink is 5 seconds away from a puff window
        for xx = 1:length(verifiedBlinks)
            blinkSample = verifiedBlinks(1,xx);
            sampleCheck = true;
            for yy = 1:length(stimSamples)
                stimSample = stimSamples(1,yy);
                if (blinkSample >= stimSample) == true
                    if (blinkSample <= stimSample + samplingRate*binTime) == true
                        sampleCheck = false;
                    end
                elseif (blinkSample <= stimSample) == true
                    if (blinkSample >= stimSample - samplingRate*binTime) == true
                        sampleCheck = false;
                    end
                end
            end
            % keep blinks that have been screened to occur outside of stimulation window
            if sampleCheck == true
                blinkEvents(1,qq) = blinkSample;
                qq = qq + 1;
            end
        end
        % condense blinks that occur with 1 second of each other
        condensedBlinkTimes = [];
        if isempty(blinkEvents) == false
            cc = 1;
            for bb = 1:length(blinkEvents)
                if bb == 1
                    condensedBlinkTimes(1,bb) = blinkEvents(1,bb);
                    cc = cc + 1;
                else
                    timeDifference = blinkEvents(1,bb) - blinkEvents(1,bb - 1);
                    if timeDifference > samplingRate
                        condensedBlinkTimes(1,cc) = blinkEvents(1,bb);
                        cc = cc + 1;
                    end
                end
            end
            % extract blink triggered data and group based on arousal state
            for dd = 1:length(condensedBlinkTimes)
                blink = condensedBlinkTimes(1,dd);
                if (blink/samplingRate) >= edgeTime && (blink/samplingRate) <= (trialDuration - edgeTime)
                    for zz = 1:length(ScoringResults.fileIDs)
                        % find sleep scores associated with this file ID
                        if strcmp(ScoringResults.fileIDs{zz,1},fileID) == true
                            labels = ScoringResults.labels{zz,1};
                        end
                    end
                    blinkSec = blink/samplingRate;
                    blinkBin = ceil(blinkSec/binTime);
                    arousalClassifications = cat(1,arousalClassifications,labels(blinkBin - edgeTime/binTime:blinkBin + edgeTime/binTime)');
                    fileIDs = cat(1,fileIDs,{fileID});
                    blinkTimes = cat(1,blinkTimes,blink);
                end
            end
        end
    end
end
% binarize arousal classifications for probability comparison
arousalClasses = {'Not Sleep','NREM Sleep','REM Sleep'};
reshapedArousalClassicifications = reshape(arousalClassifications,[size(arousalClassifications,1)*size(arousalClassifications,2),1]);
for aa = 1:length(arousalClasses)
    for bb = 1:length(reshapedArousalClassicifications)
        if strcmp(reshapedArousalClassicifications(bb),arousalClasses{1,aa}) == true
            classArray(bb) = 1;
        else
            classArray(bb) = 0;
        end
    end
    classMatrix{aa,1} = reshape(classArray,[size(arousalClassifications,1),size(arousalClassifications,2)]);
end
% save results
Results_BlinkTransition.(animalID).awakeProbabilityMatrix = classMatrix{1,1};
Results_BlinkTransition.(animalID).nremProbabilityMatrix = classMatrix{2,1};
Results_BlinkTransition.(animalID).remProbabilityMatrix = classMatrix{3,1};
% save data
cd([rootFolder delim])
save('Results_BlinkTransition.mat','Results_BlinkTransition')

end
