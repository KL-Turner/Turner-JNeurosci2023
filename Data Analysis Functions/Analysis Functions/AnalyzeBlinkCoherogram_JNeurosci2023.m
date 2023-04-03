function [Results_BlinkCoherogram] = AnalyzeBlinkCoherogram_JNeurosci2023(animalID,rootFolder,delim,Results_BlinkCoherogram)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Analyze the coherence during time leading/lagging periods of blinking
%________________________________________________________________________________________________________________________

% go to animal's data folder
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
samplingRate = 30; % lowpass filter
blinkStates = {'Awake','Asleep','All'};
edgeTime = 35; % sec
binTime = 5; % sec
for aa = 1:length(blinkStates)
    blinkState = blinkStates{1,aa};
    data.(blinkState).LH_HbT = [];
    data.(blinkState).RH_HbT = [];
    data.(blinkState).LH_gamma = [];
    data.(blinkState).RH_gamma = [];
end
for aa = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(aa,:);
    [animalID,~,fileID] = GetFileInfo_JNeurosci2023(procDataFileID);
    load(procDataFileID)
    % only run on data with accurate diameter tracking
    if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
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
        % condense blinks
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
            % condense blinks that occur with 1 second of each other
            for dd = 1:length(condensedBlinkTimes)
                blink = condensedBlinkTimes(1,dd);
                if (blink/samplingRate) >= edgeTime && (blink/samplingRate) <= (900 - edgeTime)
                    for zz = 1:length(ScoringResults.fileIDs)
                        if strcmp(ScoringResults.fileIDs{zz,1},fileID) == true
                            labels = ScoringResults.labels{zz,1};
                        end
                    end
                    blinkArousalBin = ceil((blink/samplingRate)/5);
                    blinkScore = labels(blinkArousalBin - 1,1);
                    if strcmp(blinkScore,'Not Sleep') == true
                        blinkState = 'Awake';
                    elseif strcmp(blinkScore,'NREM Sleep') == true || strcmp(blinkScore,'REM Sleep') == true
                        blinkState = 'Asleep';
                    end
                    % LH HbT
                    data.(blinkState).LH_HbT = cat(2,data.(blinkState).LH_HbT,ProcData.data.CBV_HbT.adjLH((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate)))');
                    data.All.LH_HbT = cat(2,data.All.LH_HbT,ProcData.data.CBV_HbT.adjLH((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate)))');
                    % RH HbT
                    data.(blinkState).RH_HbT = cat(2,data.(blinkState).RH_HbT,ProcData.data.CBV_HbT.adjRH((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate)))');
                    data.All.RH_HbT = cat(2,data.All.RH_HbT,ProcData.data.CBV_HbT.adjRH((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate)))');
                    % LH gamma
                    data.(blinkState).LH_gamma = cat(2,data.(blinkState).LH_gamma,ProcData.data.cortical_LH.gammaBandPower((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate)))');
                    data.All.LH_gamma = cat(2,data.All.LH_gamma,ProcData.data.cortical_LH.gammaBandPower((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate)))');
                    % RH gamma
                    data.(blinkState).RH_gamma = cat(2,data.(blinkState).RH_gamma,ProcData.data.cortical_RH.gammaBandPower((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate)))');
                    data.All.RH_gamma = cat(2,data.All.RH_gamma,ProcData.data.cortical_RH.gammaBandPower((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate)))');
                end
            end
        end
    end
end
%% analyze coherogram
dataTypes = {'HbT','gamma'};
% parameters
params.tapers = [1,1]; % Tapers [n, 2n - 1]
params.pad = 1;
params.Fs = samplingRate;
params.fpass = [0,3]; % Pass band [0, nyquist]
params.trialave = 1;
params.err = [2,0.05];
movingWin = [10,1/samplingRate];
for bb = 1:length(dataTypes)
    dataType = dataTypes{1,bb};
    for aa = 1:length(blinkStates)
        blinkState = blinkStates{1,aa};
        if strcmp(dataType,'HbT') == true
            LH_data = detrend(data.(blinkState).LH_HbT,'constant');
            RH_data = detrend(data.(blinkState).RH_HbT,'constant');
        elseif strcmp(dataType,'gamma') == true
            LH_data = detrend(data.(blinkState).LH_gamma,'constant');
            RH_data = detrend(data.(blinkState).RH_gamma,'constant');
        end
        midpoint = round(size(LH_data,1)/2);
        LH_leadData = detrend(LH_data(midpoint - 15*samplingRate:midpoint - 5*samplingRate,:),'constant');
        RH_leadData = detrend(RH_data(midpoint - 15*samplingRate:midpoint - 5*samplingRate,:),'constant');
        LH_lagData = detrend(LH_data(midpoint + 5*samplingRate:midpoint + 15*samplingRate,:),'constant');
        RH_lagData = detrend(RH_data(midpoint + 5*samplingRate:midpoint + 15*samplingRate,:),'constant');
        % coherogram
        [C,phi,~,~,~,t,f] = cohgramc(LH_data,RH_data,movingWin,params);
        % leading/lagging coherence
        [leadC,~,~,~,~,leadf] = coherencyc(LH_leadData,RH_leadData,params);
        [lagC,~,~,~,~,lagf] = coherencyc(LH_lagData,RH_lagData,params);
        % save results
        Results_BlinkCoherogram.(animalID).(dataType).(blinkState).C = C';
        Results_BlinkCoherogram.(animalID).(dataType).(blinkState).phi = phi;
        Results_BlinkCoherogram.(animalID).(dataType).(blinkState).t = t;
        Results_BlinkCoherogram.(animalID).(dataType).(blinkState).f = f;
        Results_BlinkCoherogram.(animalID).(dataType).(blinkState).leadC = leadC;
        Results_BlinkCoherogram.(animalID).(dataType).(blinkState).lagC = lagC;
        Results_BlinkCoherogram.(animalID).(dataType).(blinkState).leadf = leadf;
        Results_BlinkCoherogram.(animalID).(dataType).(blinkState).lagf = lagf;
    end
end
% save data
cd([rootFolder delim 'Analysis Structures\'])
save('Results_BlinkCoherogram.mat','Results_BlinkCoherogram','-v7.3')
cd([rootFolder delim])

end
