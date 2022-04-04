function [Results_BlinkPeriodogram] = AnalyzeBlinkPeriodogram_Pupil(animalID,rootFolder,delim,Results_BlinkPeriodogram)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Analyze the spectral power of hemodynamic [HbT] and neural signals (IOS)
%________________________________________________________________________________________________________________________

%% only run analysis for valid animal IDs
dataLocation = [rootFolder delim 'Data' delim animalID delim 'Bilateral Imaging'];
cd(dataLocation)
% character list of all ProcData file IDs
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
%% analyze periodogram during periods of all data
[~,dateList,~] = GetFileInfo_IOS(procDataFileIDs);
[uniqueDays,dayIndex] = GetUniqueDays_IOS(dateList);
for aa = 1:length(dayIndex)
    if aa < length(dayIndex)
        dayProcDataFileIDs{aa,1} = procDataFileIDs(dayIndex(aa,1):dayIndex(aa + 1) - 1,:);
    elseif aa == length(dayIndex)
        dayProcDataFileIDs{aa,1} = procDataFileIDs(dayIndex(aa,1):end,:);
    end
end
%%
trialDuration = 15;
samplingRate = 30;
for aa = 1:length(uniqueDays)
    uniqueDay = ConvertDate_IOS(uniqueDays{aa,1});
    procDataFileList = dayProcDataFileIDs{aa,1};
    for gg = 2:size(procDataFileList,1)
        leadFileID = procDataFileList(gg - 1,:);
        lagFileID = procDataFileList(gg,:);
        [~,~,leadFileInfo] = GetFileInfo_IOS(leadFileID);
        [~,~,lagFileInfo] = GetFileInfo_IOS(lagFileID);
        leadFileStr = ConvertDateTime_IOS(leadFileInfo);
        lagFileStr = ConvertDateTime_IOS(lagFileInfo);
        leadFileTime = datevec(leadFileStr);
        lagFileTime = datevec(lagFileStr);
        timeDifference = (etime(lagFileTime,leadFileTime) - (trialDuration*60))*samplingRate;   % seconds
        timePadSamples.(uniqueDay)(gg - 1,1) = timeDifference;
    end
end
%%
fullBlinkMat = [];
for bb = 1:size(dayProcDataFileIDs,1)
    uniqueDay = ConvertDate_IOS(uniqueDays{bb,1});
    procDataFileList = dayProcDataFileIDs{bb,1};
    catBlinkArray = [];
    matBlink = [];
    for cc = 1:size(procDataFileList,1)
        procDataFileID = procDataFileList(cc,:);
        load(procDataFileID,'-mat')
        try
            puffs = ProcData.data.stimulations.LPadSol;
        catch
            puffs = ProcData.data.solenoids.LPadSol;
        end
        clear blinkArray
        % don't include trials with stimulation
        if isempty(puffs) == true
            if strcmp(ProcData.data.Pupil.frameCheck,'y') == true
                try
                    blinks = ProcData.data.Pupil.shiftedBlinks;
                    if sum(blinks > trialDuration*samplingRate*60) > 0
                        blinks = ProcData.data.Pupil.blinkInds;
                    end
                    dd = 1;
                    verifiedBlinks = [];
                    for ee = 1:length(blinks)
                        if strcmp(ProcData.data.Pupil.blinkCheck{1,ee},'y') == true
                            verifiedBlinks(1,dd) = blinks(1,ee);
                            dd = dd + 1;
                        end
                    end
                    blinkArray = zeros(1,trialDuration*samplingRate*60);
                    blinkArray(verifiedBlinks) = 1;
                    blinkArray = blinkArray(1:trialDuration*samplingRate*60);
                catch
                    blinks = ProcData.data.Pupil.blinkInds;
                    dd = 1;
                    verifiedBlinks = [];
                    for ee = 1:length(blinks)
                        if strcmp(ProcData.data.Pupil.blinkCheck{1,ee},'y') == true
                            verifiedBlinks(1,dd) = blinks(1,ee);
                            dd = dd + 1;
                        end
                    end
                    blinkArray = zeros(1,trialDuration*samplingRate*60);
                    blinkArray(verifiedBlinks) = 1;
                    blinkArray = blinkArray(1:trialDuration*samplingRate*60);
                end
            else
                blinkArray = NaN(1,trialDuration*samplingRate*60);
            end
        else
            blinkArray = NaN(1,trialDuration*samplingRate*60);
        end
        if cc == 1
            catBlinkArray = blinkArray;
            matBlink = blinkArray;
        else
            catBlinkArray = cat(2,catBlinkArray,NaN(1,timePadSamples.(uniqueDay)(cc - 1,1)),blinkArray);
            matBlink = cat(1,matBlink,blinkArray);
        end
    end
    fullBlinkArray.(uniqueDay) = catBlinkArray;
    fullBlinkMat = cat(1,fullBlinkMat,matBlink);
end
fullBlinkMat = fullBlinkMat';
%%
animalMax = 1;
for aa = 1:length(uniqueDays)
    uniqueDay = ConvertDate_IOS(uniqueDays{aa,1});
    dayMax = length(fullBlinkArray.(uniqueDay));
    if dayMax >= animalMax
        animalMax = dayMax;
    end
end
maxSamples = 5*60*60*samplingRate;
for aa = 1:length(uniqueDays)
    uniqueDay = ConvertDate_IOS(uniqueDays{aa,1});
    dayLength = length(fullBlinkArray.(uniqueDay));
    sampleDifference = maxSamples - dayLength;
    if sampleDifference >= 0
        finalBlinkArray.(uniqueDay) = cat(2,fullBlinkArray.(uniqueDay),NaN(1,sampleDifference));
    elseif sampleDifference <= 0
        finalBlinkArray.(uniqueDay) = fullBlinkArray.(uniqueDay)(1:maxSamples);
    end
end
%%
bb = 1;
plombBlinkArrays = [];
fs = 30;
dsFs = 2;
for aa = 1:length(uniqueDays)
    uniqueDay = ConvertDate_IOS(uniqueDays{aa,1});
    if sum(finalBlinkArray.(uniqueDay),'omitnan') >= 50
        tempArray = finalBlinkArray.(uniqueDay);
        numBins = length(tempArray)/(fs/dsFs);
        samplesPerBin = fs/dsFs;
        dsBlinkArray = [];
        for cc = 1:numBins
            if cc == 1
                tempArrayVal = sum(tempArray(cc:cc*samplesPerBin));
            else
                tempArrayVal = sum(tempArray((cc - 1)*samplesPerBin:cc*samplesPerBin));
            end
            if tempArrayVal >= 1
                dsBlinkArray(1,cc) = 1;
            elseif tempArrayVal == 0
                dsBlinkArray(1,cc) = 0;
            elseif isnan(tempArrayVal) == true
                dsBlinkArray(1,cc) = NaN;
            end
        end
        plombBlinkArrays(:,bb) = detrend(dsBlinkArray,'constant','omitnan');
        bb = bb + 1;
    end
end
%%
bb = 1; procBlinkMat = [];
for aa = 1:size(fullBlinkMat,2)
    if sum(isnan(fullBlinkMat(:,aa))) == 0
        if sum(fullBlinkMat(:,aa)) >= 5
            procBlinkMat(:,bb) = detrend(fullBlinkMat(:,aa),'constant');
            bb = bb + 1;
        end
    end
end
%% periodogram
if isempty(plombBlinkArrays) == false
    % save results
    Results_BlinkPeriodogram.(animalID).blinkArray = plombBlinkArrays;
else
    % save results
    Results_BlinkPeriodogram.(animalID).blinkArray = [];
end
%%
if isempty(procBlinkMat) == false
    % parameters for mtspectrumc - information available in function
    params.tapers = [10,19];   % Tapers [n, 2n - 1]
    params.pad = 1;
    params.Fs = fs;
    params.fpass = [0,1];   % Pass band [0, nyquist]
    params.trialave = 1;
    params.err = [2,0.05];
    % calculate the power spectra of the desired signals
    [S,f2,sErr] = mtspectrumc(procBlinkMat,params);
    % save results
    Results_BlinkPeriodogram.(animalID).S = S;
    Results_BlinkPeriodogram.(animalID).f = f2;
    Results_BlinkPeriodogram.(animalID).sErr = sErr;
else
    % save results
    Results_BlinkPeriodogram.(animalID).S = [];
    Results_BlinkPeriodogram.(animalID).f = [];
    Results_BlinkPeriodogram.(animalID).sErr = [];
end
%% save data
cd([rootFolder delim])
save('Results_BlinkPeriodogram.mat','Results_BlinkPeriodogram')

end
