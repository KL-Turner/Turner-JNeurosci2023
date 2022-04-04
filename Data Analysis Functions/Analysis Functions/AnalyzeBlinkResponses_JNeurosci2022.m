function [Results_BlinkResponses] = AnalyzeBlinkResponses_Pupil(animalID,rootFolder,delim,Results_BlinkResponses)
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
samplingRate = 30;    % lowpass filter
[z,p,k] = butter(4,10/(samplingRate/2),'low');
[sos,g] = zp2sos(z,p,k);
[z2,p2,k2] = butter(4,1/(samplingRate/2),'low');
[sos2,g2] = zp2sos(z2,p2,k2);
specSamplingRate = 10;
blinkStates = {'Awake','Asleep'};
edgeTime = 10; % sec
for aa = 1:length(blinkStates)
    blinkState = blinkStates{1,aa};
    data.(blinkState).zDiameter =[];
    data.(blinkState).LH_HbT = [];
    data.(blinkState).RH_HbT = [];
    data.(blinkState).LH_cort = [];
    data.(blinkState).RH_cort = [];
    data.(blinkState).hip = [];
    data.(blinkState).whisk = [];
    data.(blinkState).EMG = [];
    data.(blinkState).zDiameter_T =[];
    data.(blinkState).LH_HbT_T = [];
    data.(blinkState).RH_HbT_T = [];
    data.(blinkState).LH_cort_T = [];
    data.(blinkState).RH_cort_T = [];
    data.(blinkState).hip_T = [];
    data.(blinkState).whisk_T = [];
    data.(blinkState).EMG_T = [];
    data.(blinkState).zDiameter_F =[];
    data.(blinkState).LH_HbT_F = [];
    data.(blinkState).RH_HbT_F = [];
    data.(blinkState).LH_cort_F = [];
    data.(blinkState).RH_cort_F = [];
    data.(blinkState).hip_F = [];
    data.(blinkState).whisk_F = [];
    data.(blinkState).EMG_F = [];
end
for aa = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(aa,:);
    [animalID,fileDate,fileID] = GetFileInfo_IOS(procDataFileID);
    strDay = ConvertDate_IOS(fileDate);
    load(procDataFileID)
    if strcmp(ProcData.data.Pupil.frameCheck,'y') == true
        specDataFileID = [animalID '_' fileID '_SpecDataB.mat'];
        load(specDataFileID)
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
                if (blink/samplingRate) >= 11 && (blink/samplingRate) <= 889
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
                    
                    linkThresh = 0.5;   % seconds, Link events < 0.5 seconds apart
                    breakThresh = 0;   % seconds changed by atw on 2/6/18 from 0.07
                    binWhiskerAngle = [0,ProcData.data.binWhiskerAngle,0];
                    binWhiskers = LinkBinaryEvents_IOS(gt(binWhiskerAngle,0),[linkThresh breakThresh]*30);
                    binWhiskerAngleArray = binWhiskers((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate)));
                    data.(blinkState).whisk = cat(1,data.(blinkState).whisk,binWhiskerAngle);
                    
                    if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
                        try
                            zDiameter = filtfilt(sos2,g2,ProcData.data.Pupil.zDiameter);
                        catch
                            zDiameter = ProcData.data.Pupil.zDiameter;
                        end
                        zDiameterArray = zDiameter((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate)));
                        zDiameterArray2 = zDiameterArray;% - mean(zDiameterArray((edgeTime - 5.5)*samplingRate:(edgeTime - 0.5)*samplingRate));
                        data.(blinkState).zDiameter = cat(1,data.(blinkState).zDiameter,zDiameterArray2);
                        
                        if sum(binWhiskerAngleArray(270:330)) <= 10
                            data.(blinkState).zDiameter_T = cat(1,data.(blinkState).zDiameter_T,zDiameterArray2);
                        else
                            data.(blinkState).zDiameter_F = cat(1,data.(blinkState).zDiameter_F,zDiameterArray2);
                        end
                        
                    end
                    
                    
                    
%                     LH_HbT = filtfilt(sos2,g2,ProcData.data.CBV_HbT.adjLH);
                    LH_HbT = ProcData.data.CBV_HbT.adjLH;
                    LH_hbtArray = LH_HbT((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate)));
                    LH_hbtArray2 = LH_hbtArray;% - mean(LH_hbtArray((edgeTime - 5.5)*samplingRate:(edgeTime - 0.5)*samplingRate));
                    data.(blinkState).LH_HbT = cat(1,data.(blinkState).LH_HbT,LH_hbtArray2);
                    
%                     RH_HbT = filtfilt(sos2,g2,ProcData.data.CBV_HbT.adjRH);
                    RH_HbT = ProcData.data.CBV_HbT.adjRH;
                    RH_hbtArray = RH_HbT((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate)));
                    RH_hbtArray2 = RH_hbtArray;% - mean(RH_hbtArray((edgeTime - 5.5)*samplingRate:(edgeTime - 0.5)*samplingRate));
                    data.(blinkState).RH_HbT = cat(1,data.(blinkState).RH_HbT,RH_hbtArray2);
                    
                    LH_corticalS_Data = SpecData.cortical_LH.normS;
                    data.(blinkState).F = SpecData.cortical_LH.F;
                    T = round(SpecData.cortical_LH.T,1);
                    data.(blinkState).T = -edgeTime:(1/specSamplingRate):edgeTime;
                    startTimeIndex = find(T == round((blink/samplingRate) - edgeTime,1));
                    durationIndex = startTimeIndex + edgeTime*2*specSamplingRate;
                    LH_corticalS_Vals = LH_corticalS_Data(:,startTimeIndex:durationIndex);
                    data.(blinkState).LH_cort = cat(3,data.(blinkState).LH_cort,LH_corticalS_Vals);
                    
                    RH_corticalS_Data = SpecData.cortical_RH.normS;
                    RH_corticalS_Vals = RH_corticalS_Data(:,startTimeIndex:durationIndex);
                    data.(blinkState).RH_cort = cat(3,data.(blinkState).RH_cort,RH_corticalS_Vals);
                    
                    hipS_Data = SpecData.hippocampus.normS;
                    hipS_Vals = hipS_Data(:,startTimeIndex:durationIndex);
                    data.(blinkState).hip = cat(3,data.(blinkState).hip,hipS_Vals);
                    
                    EMG = filtfilt(sos,g,ProcData.data.EMG.emg - RestingBaselines.manualSelection.EMG.emg.(strDay).mean);
                    emgArray = EMG((blink - (edgeTime*samplingRate)):(blink + (edgeTime*samplingRate)));
                    emgArray2 = emgArray - mean(emgArray((edgeTime - 5.5)*samplingRate:(edgeTime - 0.5)*samplingRate));
                    data.(blinkState).EMG = cat(1,data.(blinkState).EMG,emgArray2);
                    
                    if sum(binWhiskerAngleArray(270:330)) <= 10
                        data.(blinkState).whisk_T = cat(1,data.(blinkState).whisk_T,binWhiskerAngleArray);
                        data.(blinkState).LH_HbT_T = cat(1,data.(blinkState).LH_HbT_T,LH_hbtArray2);
                        data.(blinkState).RH_HbT_T = cat(1,data.(blinkState).RH_HbT_T,RH_hbtArray2);
                        data.(blinkState).LH_cort_T = cat(3,data.(blinkState).LH_cort_T,LH_corticalS_Vals);
                        data.(blinkState).RH_cort_T = cat(3,data.(blinkState).RH_cort_T,RH_corticalS_Vals);
                        data.(blinkState).hip_T = cat(3,data.(blinkState).hip_T,hipS_Vals);
                        data.(blinkState).EMG_T = cat(1,data.(blinkState).EMG_T,emgArray2);
                    elseif sum(binWhiskerAngleArray(270:330)) >= 30
                        data.(blinkState).whisk_F = cat(1,data.(blinkState).whisk_F,binWhiskerAngleArray);
                        data.(blinkState).LH_HbT_F = cat(1,data.(blinkState).LH_HbT_F,LH_hbtArray2);
                        data.(blinkState).RH_HbT_F = cat(1,data.(blinkState).RH_HbT_F,RH_hbtArray2);
                        data.(blinkState).LH_cort_F = cat(3,data.(blinkState).LH_cort_F,LH_corticalS_Vals);
                        data.(blinkState).RH_cort_F = cat(3,data.(blinkState).RH_cort_F,RH_corticalS_Vals);
                        data.(blinkState).hip_F = cat(3,data.(blinkState).hip_F,hipS_Vals);
                        data.(blinkState).EMG_F = cat(1,data.(blinkState).EMG_F,emgArray2);
                    end
                end
            end
        end
    end
end
%
blinkStates = {'Awake','Asleep'};
for bb = 1:length(blinkStates)
    blinkState = blinkStates{1,bb};
    Results_BlinkResponses.(animalID).(blinkState).zDiameter = mean(data.(blinkState).zDiameter,1);
    Results_BlinkResponses.(animalID).(blinkState).zDiameter_T = mean(data.(blinkState).zDiameter_T,1);
    Results_BlinkResponses.(animalID).(blinkState).zDiameter_F = mean(data.(blinkState).zDiameter_F,1);
    
    Results_BlinkResponses.(animalID).(blinkState).whisk = mean(data.(blinkState).whisk,1);
    Results_BlinkResponses.(animalID).(blinkState).whisk_T = mean(data.(blinkState).whisk_T,1);
    Results_BlinkResponses.(animalID).(blinkState).whisk_F = mean(data.(blinkState).whisk_F,1);
    
    Results_BlinkResponses.(animalID).(blinkState).LH_HbT = mean(data.(blinkState).LH_HbT,1);
    Results_BlinkResponses.(animalID).(blinkState).LH_HbT_T = mean(data.(blinkState).LH_HbT_T,1);
    Results_BlinkResponses.(animalID).(blinkState).LH_HbT_F = mean(data.(blinkState).LH_HbT_F,1);
    
    Results_BlinkResponses.(animalID).(blinkState).RH_HbT = mean(data.(blinkState).RH_HbT,1);
    Results_BlinkResponses.(animalID).(blinkState).RH_HbT_T = mean(data.(blinkState).RH_HbT_T,1);
    Results_BlinkResponses.(animalID).(blinkState).RH_HbT_F = mean(data.(blinkState).RH_HbT_F,1);
    
    %
    try
    meanLH_CortS = mean(data.(blinkState).LH_cort,3);
    baseLH_CortSVals = mean(meanLH_CortS(:,(edgeTime - 5.5)*specSamplingRate:(edgeTime - 0.5)*specSamplingRate),2);
    baseMatrixLH_CortSVals = baseLH_CortSVals.*ones(size(meanLH_CortS));
    msLH_SVals = (meanLH_CortS);% - baseMatrixLH_CortSVals);
    Results_BlinkResponses.(animalID).(blinkState).LH_cort = msLH_SVals;
    catch
            Results_BlinkResponses.(animalID).(blinkState).LH_cort = [];
    end
    
    try
        meanLH_CortS = mean(data.(blinkState).LH_cort_T,3);
        baseLH_CortSVals = mean(meanLH_CortS(:,(edgeTime - 5.5)*specSamplingRate:(edgeTime - 0.5)*specSamplingRate),2);
        baseMatrixLH_CortSVals = baseLH_CortSVals.*ones(size(meanLH_CortS));
        msLH_SVals = (meanLH_CortS);% - baseMatrixLH_CortSVals);
        Results_BlinkResponses.(animalID).(blinkState).LH_cort_T = msLH_SVals;
    catch
        Results_BlinkResponses.(animalID).(blinkState).LH_cort_T = [];
    end
    
    try
    meanLH_CortS = mean(data.(blinkState).LH_cort_F,3);
    baseLH_CortSVals = mean(meanLH_CortS(:,(edgeTime - 5.5)*specSamplingRate:(edgeTime - 0.5)*specSamplingRate),2);
    baseMatrixLH_CortSVals = baseLH_CortSVals.*ones(size(meanLH_CortS));
    msLH_SVals = (meanLH_CortS);% - baseMatrixLH_CortSVals);
    Results_BlinkResponses.(animalID).(blinkState).LH_cort_F = msLH_SVals;
    catch
            Results_BlinkResponses.(animalID).(blinkState).LH_cort_F = [];
    end
    
    %
    try
    meanRH_CortS = mean(data.(blinkState).RH_cort,3);
    baseRH_CortSVals = mean(meanRH_CortS(:,(edgeTime - 5.5)*specSamplingRate:(edgeTime - 0.5)*specSamplingRate),2);
    baseMatrixRH_CortSVals = baseRH_CortSVals.*ones(size(meanRH_CortS));
    msRH_SVals = (meanRH_CortS);% - baseMatrixRH_CortSVals);
    Results_BlinkResponses.(animalID).(blinkState).RH_cort = msRH_SVals;
    catch
            Results_BlinkResponses.(animalID).(blinkState).RH_cort = [];
    end
    
    try
        meanRH_CortS = mean(data.(blinkState).RH_cort_T,3);
        baseRH_CortSVals = mean(meanRH_CortS(:,(edgeTime - 5.5)*specSamplingRate:(edgeTime - 0.5)*specSamplingRate),2);
        baseMatrixRH_CortSVals = baseRH_CortSVals.*ones(size(meanRH_CortS));
        msRH_SVals = (meanRH_CortS);% - baseMatrixRH_CortSVals);
        Results_BlinkResponses.(animalID).(blinkState).RH_cort_T = msRH_SVals;
    catch
        Results_BlinkResponses.(animalID).(blinkState).RH_cort_T = [];
    end
    
    try
    meanRH_CortS = mean(data.(blinkState).RH_cort_F,3);
    baseRH_CortSVals = mean(meanRH_CortS(:,(edgeTime - 5.5)*specSamplingRate:(edgeTime - 0.5)*specSamplingRate),2);
    baseMatrixRH_CortSVals = baseRH_CortSVals.*ones(size(meanRH_CortS));
    msRH_SVals = (meanRH_CortS);% - baseMatrixRH_CortSVals);
    Results_BlinkResponses.(animalID).(blinkState).RH_cort_F = msRH_SVals;
    catch
            Results_BlinkResponses.(animalID).(blinkState).RH_cort_F = [];
    end
    %
    try
    meanHip_CortS = mean(data.(blinkState).hip,3);
    baseHip_CortSVals = mean(meanHip_CortS(:,(edgeTime - 5.5)*specSamplingRate:(edgeTime - 0.5)*specSamplingRate),2);
    baseMatrixHip_CortSVals = baseHip_CortSVals.*ones(size(meanHip_CortS));
    msHip_SVals = (meanHip_CortS);% - baseMatrixHip_CortSVals);
    Results_BlinkResponses.(animalID).(blinkState).hip = msHip_SVals;
    catch
            Results_BlinkResponses.(animalID).(blinkState).hip = [];

    end
    
    try
        meanHip_CortS = mean(data.(blinkState).hip_T,3);
        baseHip_CortSVals = mean(meanHip_CortS(:,(edgeTime - 5.5)*specSamplingRate:(edgeTime - 0.5)*specSamplingRate),2);
        baseMatrixHip_CortSVals = baseHip_CortSVals.*ones(size(meanHip_CortS));
        msHip_SVals = (meanHip_CortS);% - baseMatrixHip_CortSVals);
        Results_BlinkResponses.(animalID).(blinkState).hip_T = msHip_SVals;
    catch
        Results_BlinkResponses.(animalID).(blinkState).hip_T = [];
    end
    
    try
    meanHip_CortS = mean(data.(blinkState).hip_F,3);
    baseHip_CortSVals = mean(meanHip_CortS(:,(edgeTime - 5.5)*specSamplingRate:(edgeTime - 0.5)*specSamplingRate),2);
    baseMatrixHip_CortSVals = baseHip_CortSVals.*ones(size(meanHip_CortS));
    msHip_SVals = (meanHip_CortS);% - baseMatrixHip_CortSVals);
    Results_BlinkResponses.(animalID).(blinkState).hip_F = msHip_SVals;
    catch
            Results_BlinkResponses.(animalID).(blinkState).hip_F = [];
    end
    %
    Results_BlinkResponses.(animalID).(blinkState).EMG = mean(data.(blinkState).EMG,1);
    Results_BlinkResponses.(animalID).(blinkState).EMG_T = mean(data.(blinkState).EMG_T,1);
    Results_BlinkResponses.(animalID).(blinkState).EMG_F = mean(data.(blinkState).EMG_F,1);
    
    Results_BlinkResponses.(animalID).(blinkState).T = data.(blinkState).T;
    Results_BlinkResponses.(animalID).(blinkState).F = data.(blinkState).F;
end
% save data
cd([rootFolder delim])
save('Results_BlinkResponses.mat','Results_BlinkResponses')

end
