function [Results_BlinkSpectrogram] = AnalyzeBlinkSpectrogram_JNeurosci2022(animalID,rootFolder,delim,Results_BlinkSpectrogram)
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
blinkStates = {'Awake','Asleep','All'};
edgeTime = 35; % sec
for aa = 1:length(blinkStates)
    blinkState = blinkStates{1,aa};
    data.(blinkState).LH_HbT = [];
    data.(blinkState).RH_HbT = [];
    data.(blinkState).LH_gamma = [];
    data.(blinkState).RH_gamma = [];
end
for aa = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(aa,:);
    [animalID,~,fileID] = GetFileInfo_JNeurosci2022(procDataFileID);
    load(procDataFileID)
    if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
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
            % extract blink triggered data
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
        % spectrogram
        [LH_S,LH_t,LH_f,~] = mtspecgramc(LH_data,movingWin,params);
        [RH_S,RH_t,RH_f,~] = mtspecgramc(RH_data,movingWin,params);
        % leading/lagging power spectrum
        [LH_leadS,LH_leadf,~] = mtspectrumc(LH_leadData,params);
        [RH_leadS,RH_leadf,~] = mtspectrumc(RH_leadData,params);
        [LH_lagS,LH_lagf,~] = mtspectrumc(LH_lagData,params);
        [RH_lagS,RH_lagf,~] = mtspectrumc(RH_lagData,params);
        %% Save results
        Results_BlinkSpectrogram.(animalID).(dataType).(blinkState).LH_S = LH_S';
        Results_BlinkSpectrogram.(animalID).(dataType).(blinkState).LH_t = LH_t;
        Results_BlinkSpectrogram.(animalID).(dataType).(blinkState).LH_f = LH_f;
        Results_BlinkSpectrogram.(animalID).(dataType).(blinkState).RH_S = RH_S';
        Results_BlinkSpectrogram.(animalID).(dataType).(blinkState).RH_t = RH_t;
        Results_BlinkSpectrogram.(animalID).(dataType).(blinkState).RH_f = RH_f;
        Results_BlinkSpectrogram.(animalID).(dataType).(blinkState).LH_leadS = LH_leadS;
        Results_BlinkSpectrogram.(animalID).(dataType).(blinkState).RH_leadS = RH_leadS;
        Results_BlinkSpectrogram.(animalID).(dataType).(blinkState).LH_lagS = LH_lagS;
        Results_BlinkSpectrogram.(animalID).(dataType).(blinkState).RH_lagS = RH_lagS;
        Results_BlinkSpectrogram.(animalID).(dataType).(blinkState).LH_leadf = LH_leadf;
        Results_BlinkSpectrogram.(animalID).(dataType).(blinkState).RH_leadf = RH_leadf;
        Results_BlinkSpectrogram.(animalID).(dataType).(blinkState).LH_lagf = LH_lagf;
        Results_BlinkSpectrogram.(animalID).(dataType).(blinkState).RH_lagf = RH_lagf;
    end
end
% save data
cd([rootFolder delim])
save('Results_BlinkSpectrogram.mat','Results_BlinkSpectrogram','-v7.3')

end
