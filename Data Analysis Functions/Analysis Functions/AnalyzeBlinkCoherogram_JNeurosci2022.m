function [Results_BlinkCoherogram] = AnalyzeBlinkCoherogram_Pupil(animalID,rootFolder,delim,Results_BlinkCoherogram)
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
blinkStates = {'All','Awake','Asleep'};
edgeTime = 30; % sec
for aa = 1:length(blinkStates)
    blinkState = blinkStates{1,aa};
    data.(blinkState).LH_HbT = [];
    data.(blinkState).RH_HbT = [];
    data.(blinkState).LH_gamma = [];
    data.(blinkState).RH_gamma = [];
end
for aa = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(aa,:);
    [animalID,~,fileID] = GetFileInfo_IOS(procDataFileID);
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
            % extract blink triggered data
            for dd = 1:length(condensedBlinkTimes)
                blink = condensedBlinkTimes(1,dd);
                if (blink/samplingRate) >= 61 && (blink/samplingRate) <= 839
                    for zz = 1:length(ScoringResults.fileIDs)
                        if strcmp(ScoringResults.fileIDs{zz,1},fileID) == true
                            labels = ScoringResults.labels{zz,1};
                        end
                    end
                    blinkArousalBin = ceil((blink/samplingRate)/5);
                    try
                        blinkScore = labels(blinkArousalBin - 1,1);
                    catch
                        blinkScore = labels(blinkArousalBin,1);
                    end
                    if strcmp(blinkScore,'Not Sleep') == true
                        blinkState = 'Awake';
                    elseif strcmp(blinkScore,'NREM Sleep') == true || strcmp(blinkScore,'REM Sleep') == true
                        blinkState = 'Asleep';
                    end
                    % LH HbT
                    data.(blinkState).LH_HbT = cat(1,data.(blinkState).LH_HbT,detrend(ProcData.data.CBV_HbT.adjLH((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate))),'constant'));
                    data.All.LH_HbT = cat(1,data.All.LH_HbT,detrend(ProcData.data.CBV_HbT.adjLH((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate))),'constant'));
                    % RH HbT
                    data.(blinkState).RH_HbT = cat(1,data.(blinkState).RH_HbT,detrend(ProcData.data.CBV_HbT.adjRH((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate))),'constant'));
                    data.All.RH_HbT = cat(1,data.All.RH_HbT,detrend(ProcData.data.CBV_HbT.adjRH((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate))),'constant'));
                    % LH gamma
                    data.(blinkState).LH_gamma = cat(1,data.(blinkState).LH_gamma,detrend(ProcData.data.cortical_LH.gammaBandPower((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate))),'constant'));
                    data.All.LH_gamma = cat(1,data.All.LH_gamma,detrend(ProcData.data.cortical_LH.gammaBandPower((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate))),'constant'));
                    % RH gamma
                    data.(blinkState).RH_gamma = cat(1,data.(blinkState).RH_gamma,detrend(ProcData.data.cortical_RH.gammaBandPower((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate))),'constant'));
                    data.All.RH_gamma = cat(1,data.All.RH_gamma,detrend(ProcData.data.cortical_RH.gammaBandPower((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate))),'constant'));
                end
            end
        end
    end
end
%% analyze coherogram
dataTypes = {'HbT','gamma','left','right'};
% parameters
params.tapers = [1,1]; % Tapers [n, 2n - 1]
params.pad = 1;
params.Fs = samplingRate;
params.fpass = [0,3]; % Pass band [0, nyquist]
params.trialave = 1;
params.err = [2,0.05];
movingWin = [10,1/30];
for bb = 1:length(dataTypes)
    dataType = dataTypes{1,bb};
    for aa = 1:length(blinkStates)
        blinkState = blinkStates{1,aa};
        switch dataType
            case 'HbT'
                data1 = data.(blinkState).LH_HbT';
                data2 = data.(blinkState).RH_HbT';
            case 'gamma'
                data1 = data.(blinkState).LH_gamma';
                data2 = data.(blinkState).RH_gamma';
            case 'left'
                data1 = data.(blinkState).LH_HbT';
                data2 = data.(blinkState).LH_gamma';
            case 'right'
                data1 = data.(blinkState).RH_HbT';
                data2 = data.(blinkState).RH_gamma';
        end
        data3 = data1(540:840,:);
        data4 = data2(540:840,:);
        data5 = data1(960:1260,:);
        data6 = data2(960:1260,:);
        % coherogram
        [C,phi,~,~,~,t,f] = cohgramc(data1,data2,movingWin,params);
        % leading/lagging coherence
        [leadC,~,~,~,~,leadf] = coherencyc(data3,data4,params);
        [lagC,~,~,~,~,lagf] = coherencyc(data5,data6,params);
        % leading/lagging power spectrum
        [LH_leadS,pwrf,~] = mtspectrumc(data3,params);
        [RH_leadS,~,~] = mtspectrumc(data4,params);
        [LH_lagS,~,~] = mtspectrumc(data5,params);
        [RH_lagS,~,~] = mtspectrumc(data6,params);
        %% Save results
        Results_BlinkCoherogram.(animalID).(dataType).(blinkState).C = C';
        Results_BlinkCoherogram.(animalID).(dataType).(blinkState).phi = phi;
        Results_BlinkCoherogram.(animalID).(dataType).(blinkState).t = t;
        Results_BlinkCoherogram.(animalID).(dataType).(blinkState).f = f;
        Results_BlinkCoherogram.(animalID).(dataType).(blinkState).leadC = leadC;
        Results_BlinkCoherogram.(animalID).(dataType).(blinkState).lagC = lagC;
        Results_BlinkCoherogram.(animalID).(dataType).(blinkState).leadf = leadf;
        Results_BlinkCoherogram.(animalID).(dataType).(blinkState).lagf = lagf;
        Results_BlinkCoherogram.(animalID).(dataType).(blinkState).LH_leadS = LH_leadS;
        Results_BlinkCoherogram.(animalID).(dataType).(blinkState).RH_leadS = RH_leadS;
        Results_BlinkCoherogram.(animalID).(dataType).(blinkState).LH_lagS = LH_lagS;
        Results_BlinkCoherogram.(animalID).(dataType).(blinkState).RH_lagS = RH_lagS;
        Results_BlinkCoherogram.(animalID).(dataType).(blinkState).pwrf = pwrf;
    end
end
% save data
cd([rootFolder delim])
save('Results_BlinkCoherogram.mat','Results_BlinkCoherogram','-v7.3')

end
