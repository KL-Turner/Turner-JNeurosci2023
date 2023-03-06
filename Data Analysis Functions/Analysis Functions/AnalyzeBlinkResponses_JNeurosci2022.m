function [Results_BlinkResponses] = AnalyzeBlinkResponses_JNeurosci2022(animalID,rootFolder,delim,Results_BlinkResponses)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Analyze behavioral, neural, and hemodynamic responses to blinking and create a triggered average
%________________________________________________________________________________________________________________________

% cd to animal folder/data location
dataLocation = [rootFolder delim 'Data' delim animalID delim 'Bilateral Imaging'];
cd(dataLocation)
% find and load RestingBaselines.mat struct
baselineDataFileStruct = dir('*_RestingBaselines.mat');
baselineDataFile = {baselineDataFileStruct.name}';
baselineDataFileID = char(baselineDataFile);
load(baselineDataFileID,'-mat')
% character list of ProcData file IDs
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
% find and load manual baseline event information
scoringResultsFileStruct = dir('*Forest_ScoringResults.mat');
scoringResultsFile = {scoringResultsFileStruct.name}';
scoringResultsFileID = char(scoringResultsFile);
load(scoringResultsFileID,'-mat')
% lowpass filter and sampling rates
trialDuration = 900; % sec
samplingRate = 30; % Hz
specSamplingRate = 10; % Hz
edgeTime = 10; % sec
binTime = 5; % sec
blinkStates = {'Awake','Asleep'};
[z,p,k] = butter(4,10/(samplingRate/2),'low');
[sos,g] = zp2sos(z,p,k);
% pre-allocation
for aa = 1:length(blinkStates)
    blinkState = blinkStates{1,aa};
    data.(blinkState).zDiameter =[];
    data.(blinkState).whisk = [];
    data.(blinkState).LH_HbT = [];
    data.(blinkState).RH_HbT = [];
    data.(blinkState).LH_cort = [];
    data.(blinkState).RH_cort = [];
    data.(blinkState).hip = [];
    data.(blinkState).EMG = [];
    data.(blinkState).zDiameter_lowWhisk =[];
    data.(blinkState).whisk_lowWhisk = [];
    data.(blinkState).EMG_lowWhisk = [];
    data.(blinkState).LH_HbT_lowWhisk = [];
    data.(blinkState).RH_HbT_lowWhisk = [];
    data.(blinkState).LH_cort_lowWhisk = [];
    data.(blinkState).RH_cort_lowWhisk = [];
    data.(blinkState).hip_lowWhisk = [];
    data.(blinkState).zDiameter_highWhisk =[];
    data.(blinkState).whisk_highWhisk = [];
    data.(blinkState).EMG_highWhisk = [];
    data.(blinkState).LH_HbT_highWhisk = [];
    data.(blinkState).RH_HbT_highWhisk = [];
    data.(blinkState).LH_cort_highWhisk = [];
    data.(blinkState).RH_cort_highWhisk = [];
    data.(blinkState).hip_highWhisk = [];
    data.(blinkState).T = [];
    data.(blinkState).F = [];
end
% go through each ProcData file
for aa = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(aa,:);
    [animalID,fileDate,fileID] = GetFileInfo_JNeurosci2022(procDataFileID);
    strDay = ConvertDate_JNeurosci2022(fileDate);
    load(procDataFileID)
    % only extract data from files with an accurate diameter measurements
    if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
        specDataFileID = [animalID '_' fileID '_SpecDataB.mat'];
        load(specDataFileID)
        % extract blinking index
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
                % can only keep blinks that occur within the window of a trial for +/- 10 seconds
                if (blink/samplingRate) >= edgeTime + 1 && (blink/samplingRate) <= (trialDuration - edgeTime - 1)
                    for zz = 1:length(ScoringResults.fileIDs)
                        % find sleep scores associated with this file ID
                        if strcmp(ScoringResults.fileIDs{zz,1},fileID) == true
                            labels = ScoringResults.labels{zz,1};
                        end
                    end
                    blinkArousalBin = ceil((blink/samplingRate)/binTime);
                    blinkScore = labels(blinkArousalBin - 1,1);
                    if strcmp(blinkScore,'Not Sleep') == true
                        blinkState = 'Awake';
                    elseif strcmp(blinkScore,'NREM Sleep') == true || strcmp(blinkScore,'REM Sleep') == true
                        blinkState = 'Asleep';
                    end
                    % pupil diameter
                    zDiameter = ProcData.data.Pupil.zDiameter;
                    zDiameterArray = zDiameter((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate)));
                    data.(blinkState).zDiameter = cat(1,data.(blinkState).zDiameter,zDiameterArray);
                    % whisking events
                    binWhiskerAngle = [0,ProcData.data.binWhiskerAngle,0];
                    binWhiskerAngleArray = binWhiskerAngle((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate)));
                    data.(blinkState).whisk = cat(1,data.(blinkState).whisk,binWhiskerAngleArray);
                    % EMG
                    EMG = filtfilt(sos,g,ProcData.data.EMG.emg - RestingBaselines.manualSelection.EMG.emg.(strDay).mean);
                    emgArray = EMG((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate)));
                    data.(blinkState).EMG = cat(1,data.(blinkState).EMG,emgArray);
                    % LH HBT
                    LH_HbT = ProcData.data.CBV_HbT.adjLH;
                    LH_hbtArray = LH_HbT((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate)));
                    data.(blinkState).LH_HbT = cat(1,data.(blinkState).LH_HbT,LH_hbtArray);
                    % RH HbT
                    RH_HbT = ProcData.data.CBV_HbT.adjRH;
                    RH_hbtArray = RH_HbT((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate)));
                    data.(blinkState).RH_HbT = cat(1,data.(blinkState).RH_HbT,RH_hbtArray);
                    % LH cortical
                    LH_corticalS_Data = SpecData.cortical_LH.normS;
                    data.(blinkState).F = SpecData.cortical_LH.F;
                    T = round(SpecData.cortical_LH.T,1);
                    data.(blinkState).T = -edgeTime:(1/specSamplingRate):edgeTime;
                    startTimeIndex = find(T == round((blink/samplingRate) - edgeTime,1));
                    durationIndex = startTimeIndex + edgeTime*2*specSamplingRate;
                    LH_corticalS_Vals = LH_corticalS_Data(:,startTimeIndex:durationIndex);
                    data.(blinkState).LH_cort = cat(3,data.(blinkState).LH_cort,LH_corticalS_Vals);
                    % RH cortical
                    RH_corticalS_Data = SpecData.cortical_RH.normS;
                    RH_corticalS_Vals = RH_corticalS_Data(:,startTimeIndex:durationIndex);
                    data.(blinkState).RH_cort = cat(3,data.(blinkState).RH_cort,RH_corticalS_Vals);
                    % hippocampus
                    hipS_Data = SpecData.hippocampus.normS;
                    hipS_Vals = hipS_Data(:,startTimeIndex:durationIndex);
                    data.(blinkState).hip = cat(3,data.(blinkState).hip,hipS_Vals);
                    % separate into high vs. low whisking criteria
                    if sum(binWhiskerAngleArray((edgeTime - 1)*samplingRate:(edgeTime + 1)*samplingRate)) <= samplingRate/3
                        data.(blinkState).zDiameter_lowWhisk = cat(1,data.(blinkState).zDiameter_lowWhisk,zDiameterArray);
                        data.(blinkState).whisk_lowWhisk = cat(1,data.(blinkState).whisk_lowWhisk,binWhiskerAngleArray);
                        data.(blinkState).LH_HbT_lowWhisk = cat(1,data.(blinkState).LH_HbT_lowWhisk,LH_hbtArray);
                        data.(blinkState).RH_HbT_lowWhisk = cat(1,data.(blinkState).RH_HbT_lowWhisk,RH_hbtArray);
                        data.(blinkState).LH_cort_lowWhisk = cat(3,data.(blinkState).LH_cort_lowWhisk,LH_corticalS_Vals);
                        data.(blinkState).RH_cort_lowWhisk = cat(3,data.(blinkState).RH_cort_lowWhisk,RH_corticalS_Vals);
                        data.(blinkState).hip_lowWhisk = cat(3,data.(blinkState).hip_lowWhisk,hipS_Vals);
                        data.(blinkState).EMG_lowWhisk = cat(1,data.(blinkState).EMG_lowWhisk,emgArray);
                    elseif sum(binWhiskerAngleArray((edgeTime - 1)*samplingRate:(edgeTime + 1)*samplingRate)) >= samplingRate
                        data.(blinkState).zDiameter_highWhisk = cat(1,data.(blinkState).zDiameter_highWhisk,zDiameterArray);
                        data.(blinkState).whisk_highWhisk = cat(1,data.(blinkState).whisk_highWhisk,binWhiskerAngleArray);
                        data.(blinkState).LH_HbT_highWhisk = cat(1,data.(blinkState).LH_HbT_highWhisk,LH_hbtArray);
                        data.(blinkState).RH_HbT_highWhisk = cat(1,data.(blinkState).RH_HbT_highWhisk,RH_hbtArray);
                        data.(blinkState).LH_cort_highWhisk = cat(3,data.(blinkState).LH_cort_highWhisk,LH_corticalS_Vals);
                        data.(blinkState).RH_cort_highWhisk = cat(3,data.(blinkState).RH_cort_highWhisk,RH_corticalS_Vals);
                        data.(blinkState).hip_highWhisk = cat(3,data.(blinkState).hip_highWhisk,hipS_Vals);
                        data.(blinkState).EMG_highWhisk = cat(1,data.(blinkState).EMG_highWhisk,emgArray);
                    end
                end
            end
        end
    end
end
% take the mean of each category
for bb = 1:length(blinkStates)
    blinkState = blinkStates{1,bb};
    % pupil diameter
    Results_BlinkResponses.(animalID).(blinkState).zDiameter = mean(data.(blinkState).zDiameter,1);
    Results_BlinkResponses.(animalID).(blinkState).zDiameter_lowWhisk = mean(data.(blinkState).zDiameter_lowWhisk,1);
    Results_BlinkResponses.(animalID).(blinkState).zDiameter_highWhisk = mean(data.(blinkState).zDiameter_highWhisk,1);
    % whisking
    Results_BlinkResponses.(animalID).(blinkState).whisk = mean(data.(blinkState).whisk,1);
    Results_BlinkResponses.(animalID).(blinkState).whisk_lowWhisk = mean(data.(blinkState).whisk_lowWhisk,1);
    Results_BlinkResponses.(animalID).(blinkState).whisk_highWhisk = mean(data.(blinkState).whisk_highWhisk,1);
    % EMG
    Results_BlinkResponses.(animalID).(blinkState).EMG = mean(data.(blinkState).EMG,1);
    Results_BlinkResponses.(animalID).(blinkState).EMG_lowWhisk = mean(data.(blinkState).EMG_lowWhisk,1);
    Results_BlinkResponses.(animalID).(blinkState).EMG_highWhisk = mean(data.(blinkState).EMG_highWhisk,1);
    % LH HbT
    Results_BlinkResponses.(animalID).(blinkState).LH_HbT = mean(data.(blinkState).LH_HbT,1);
    Results_BlinkResponses.(animalID).(blinkState).LH_HbT_lowWhisk = mean(data.(blinkState).LH_HbT_lowWhisk,1);
    Results_BlinkResponses.(animalID).(blinkState).LH_HbT_highWhisk = mean(data.(blinkState).LH_HbT_highWhisk,1);
    % RH HbT
    Results_BlinkResponses.(animalID).(blinkState).RH_HbT = mean(data.(blinkState).RH_HbT,1);
    Results_BlinkResponses.(animalID).(blinkState).RH_HbT_lowWhisk = mean(data.(blinkState).RH_HbT_lowWhisk,1);
    Results_BlinkResponses.(animalID).(blinkState).RH_HbT_highWhisk = mean(data.(blinkState).RH_HbT_highWhisk,1);
    % LH cortical
    Results_BlinkResponses.(animalID).(blinkState).LH_cort = mean(data.(blinkState).LH_cort,3);
    Results_BlinkResponses.(animalID).(blinkState).LH_cort_lowWhisk = mean(data.(blinkState).LH_cort_lowWhisk,3);
    Results_BlinkResponses.(animalID).(blinkState).LH_cort_highWhisk = mean(data.(blinkState).LH_cort_highWhisk,3);
    % RH cortical
    Results_BlinkResponses.(animalID).(blinkState).RH_cort = mean(data.(blinkState).RH_cort,3);
    Results_BlinkResponses.(animalID).(blinkState).RH_cort_lowWhisk = mean(data.(blinkState).RH_cort_lowWhisk,3);
    Results_BlinkResponses.(animalID).(blinkState).RH_cort_highWhisk = mean(data.(blinkState).RH_cort_highWhisk,3);
    % hippocampus
    Results_BlinkResponses.(animalID).(blinkState).hip = mean(data.(blinkState).hip,3);
    Results_BlinkResponses.(animalID).(blinkState).hip_lowWhisk = mean(data.(blinkState).hip_lowWhisk,3);
    Results_BlinkResponses.(animalID).(blinkState).hip_highWhisk = mean(data.(blinkState).hip_highWhisk,3);
    % time/frequency vectors and counts for each stimulation
    Results_BlinkResponses.(animalID).(blinkState).T = data.(blinkState).T;
    Results_BlinkResponses.(animalID).(blinkState).F = data.(blinkState).F;
    Results_BlinkResponses.(animalID).(blinkState).count = size(data.(blinkState).zDiameter,1);
    Results_BlinkResponses.(animalID).(blinkState).count_lowWhisk = size(data.(blinkState).zDiameter_lowWhisk,1);
    Results_BlinkResponses.(animalID).(blinkState).count_highWhisk = size(data.(blinkState).zDiameter_highWhisk,1);
end
% save data
cd([rootFolder delim 'Analysis Structures\'])
save('Results_BlinkResponses.mat','Results_BlinkResponses')
cd([rootFolder delim])

end
