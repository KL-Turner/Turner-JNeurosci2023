function [] = CategorizeData_JNeurosci2023(procDataFileID,stimulationType)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%
% Purpose: Catagorizes data based on behavioral flags from whisking/movement events
%________________________________________________________________________________________________________________________

% load and Setup
disp(['Categorizing data for: ' procDataFileID]); disp(' ')
load(procDataFileID)
% condense pulsed stimulations
if strcmp(stimulationType,'pulse') == true
    stimulationFields = fieldnames(ProcData.data.stimulations);
    for aa = 1:length(stimulationFields)
        stimulationTimes = ProcData.data.stimulations.(stimulationFields{aa,1});
        ProcData.data.stimulationsOriginal.(stimulationFields{aa,1}) = stimulationTimes;
        condensedStimulationTimes = [];
        cc = 1;
        if isempty(stimulationTimes) == false
            for bb = 1:length(stimulationTimes)
                if bb == 1
                    condensedStimulationTimes(1,bb) = stimulationTimes(1,bb);
                    cc = cc + 1;
                else
                    timeDifference = stimulationTimes(1,bb) - stimulationTimes(1,bb - 1);
                    if timeDifference > 1 % remove stimulations that are closer than 1 second to the previous
                        condensedStimulationTimes(1,cc) = stimulationTimes(1,bb);
                        cc = cc + 1;
                    end
                end
            end
            ProcData.data.stimulations.(stimulationFields{aa,1}) = condensedStimulationTimes;
        end
    end
end
whiskerSamplingRate = ProcData.notes.dsFs;
% process binary whisking waveform to detect whisking events
% setup parameters for link_binary_events
linkThresh = 0.5; % seconds, Link events < 0.5 seconds apart
breakThresh = 0; % seconds changed by atw on 2/6/18 from 0.07
% assume that whisks at the beginning/end of trial continue outside of the
% trial time. This will link any event occurring within "link_thresh"
% seconds to the beginning/end of the trial rather than assuming that it is
% a new/isolated event.
modBinWhiskers = ProcData.data.binWhiskerAngle;
% modBinWhiskers([1,end]) = 1;
% link the binarized whisking for use in GetWhiskingdata function
binWhiskers = LinkBinaryEvents_JNeurosci2023(gt(modBinWhiskers,0),[linkThresh breakThresh]*whiskerSamplingRate);
% added 2/6/18 with atw. Code throws errors if binWhiskers(1)=1 and binWhiskers(2) = 0, or if
% binWhiskers(1) = 0 and binWhiskers(2) = 1. This happens in GetWhiskingdata because starts of
% whisks are detected by taking the derivative of binWhiskers. Purpose of following lines is to
% handle trials where the above conditions occur and avoid difficult dimension errors.
if binWhiskers(1) == 0 && binWhiskers(2) == 1
    binWhiskers(1) = 1;
elseif binWhiskers(1) == 1 && binWhiskers(2) == 0
    binWhiskers(1) = 0;
end
if binWhiskers(end) == 0 && binWhiskers(end - 1) == 1
    binWhiskers(end) = 1;
elseif binWhiskers(end) == 1 && binWhiskers(end - 1) == 0
    binWhiskers(end) = 0;
end
% categorize data by behavior
% retrieve details on whisking events
[ProcData.flags.whisk] = GetWhiskingdata_JNeurosci2023(ProcData,binWhiskers);
% retrieve details on puffing events
[ProcData.flags.stim] = GetStimdata_JNeurosci2023(ProcData);
% identify and separate resting data
[ProcData.flags.rest] = GetRestdata(ProcData);
% Save ProcData structure
save(procDataFileID,'ProcData');
end

function [puffTimes] = GetPuffTimes_JNeurosci2023(ProcData)
try
    solNames = fieldnames(ProcData.data.stimulations);
catch
    solNames = fieldnames(ProcData.data.solenoids);
end
puffList = cell(1,length(solNames));
for sN = 1:length(solNames)
    try
        puffList{sN} = ProcData.data.stimulations.(solNames{sN});
    catch
        puffList{sN} = ProcData.data.solenoids.(solNames{sN});
    end
end
puffTimes = cell2mat(puffList);
end

function [Stim] = GetStimdata_JNeurosci2023(ProcData)
% setup
whiskerSamplingRate = ProcData.notes.dsFs;
forceSensorSamplingRate = ProcData.notes.dsFs;
puffTimes = GetPuffTimes_JNeurosci2023(ProcData);
trialDuration = ProcData.notes.trialDuration_sec;
% set time intervals for calculation of the whisk scores
preTime = 1;
postTime = 1;
% get puffer IDs
try
    solNames = fieldnames(ProcData.data.stimulations);
catch
    solNames = fieldnames(ProcData.data.solenoids);
end
Stim.solenoidName = cell(length(puffTimes),1);
Stim.eventTime = zeros(length(puffTimes),1);
Stim.whiskScore_Pre = zeros(length(puffTimes),1);
Stim.whiskScore_Post = zeros(length(puffTimes),1);
Stim.movementScore_Pre = zeros(length(puffTimes),1);
Stim.movementScore_Post = zeros(length(puffTimes),1);
j = 1;
for sN = 1:length(solNames)
    try
        solPuffTimes = ProcData.data.stimulations.(solNames{sN});
    catch
        solPuffTimes = ProcData.data.solenoids.(solNames{sN});
    end
    for spT = 1:length(solPuffTimes)
        if trialDuration - solPuffTimes(spT) <= postTime
            disp(['Puff at time: ' solPuffTimes(spT) ' is too close to trial end'])
            continue;
        end
        % set indexes for pre and post periods
        wPuffInd = round(solPuffTimes(spT)*whiskerSamplingRate);
        mPuffInd = round(solPuffTimes(spT)*forceSensorSamplingRate);
        wPreStart = max(round((solPuffTimes(spT) - preTime)*whiskerSamplingRate),1);
        mPreStart = max(round((solPuffTimes(spT) - preTime)*forceSensorSamplingRate),1);
        wPostEnd = round((solPuffTimes(spT) + postTime)*whiskerSamplingRate);
        mPostEnd = round((solPuffTimes(spT) + postTime)*forceSensorSamplingRate);
        % calculate the percent of the pre-stim time that the animal moved or whisked
        whiskScorePre = sum(ProcData.data.binWhiskerAngle(wPreStart:wPuffInd))/(preTime*whiskerSamplingRate);
        whiskScorePost = sum(ProcData.data.binWhiskerAngle(wPuffInd:wPostEnd))/(postTime*whiskerSamplingRate);
        moveScorePre = sum(ProcData.data.binForceSensor(mPreStart:mPuffInd))/(preTime*forceSensorSamplingRate);
        moveScorePost = sum(ProcData.data.binForceSensor(mPuffInd:mPostEnd))/(postTime*forceSensorSamplingRate);
        % add to Stim structure
        Stim.solenoidName{j} = solNames{sN};
        Stim.eventTime(j) = solPuffTimes(spT)';
        Stim.whiskScore_Pre(j) = whiskScorePre';
        Stim.whiskScore_Post(j) = whiskScorePost';
        Stim.movementScore_Pre(j) = moveScorePre';
        Stim.movementScore_Post(j) = moveScorePost';
        j = j + 1;
    end
end
% calculate the time to the closest puff, omit comparison of puff to itself
% (see nonzeros)
puffMat = ones(length(puffTimes),1)*puffTimes;
timeElapsed = abs(nonzeros(puffMat - puffMat'));
% if no other puff occurred during the trial, store 0 as a place holder.
if isempty(timeElapsed)
    puffTimeElapsed = 0;
else
    % if not empty, Reshape the array to compensate for nonzeros command
    puffTimeElapsed = reshape(timeElapsed,numel(puffTimes) - 1,numel(puffTimes));
end
% convert to cell and add to struct, if length of Puff_Times = 0, coerce to
% 1 to accommodate the NaN entry.
puffTimeCell = mat2cell(puffTimeElapsed',ones(max(length(puffTimes),1),1));
Stim.PuffDistance = puffTimeCell;
end

function [Whisk] = GetWhiskingdata_JNeurosci2023(ProcData,binWhiskerAngle)
% setup
whiskerSamplingRate = ProcData.notes.dsFs;
forceSensorSamplingRate = ProcData.notes.dsFs;
% get Puff Times
[puffTimes] = GetPuffTimes_JNeurosci2023(ProcData);
% find the starts of whisking
whiskEdge = diff(binWhiskerAngle);
whiskSamples = find(whiskEdge > 0);
whiskStarts = whiskSamples/whiskerSamplingRate;
% classify each whisking event by duration, whisking intensity, rest durations
sampleVec = 1:length(binWhiskerAngle);
% identify periods of whisking/resting, include beginning and end of trial
% if needed (hence unique command) for correct interval calculation
highSamples = unique([1,sampleVec(binWhiskerAngle),sampleVec(end)]);
lowSamples = unique([1,sampleVec(not(binWhiskerAngle)),sampleVec(end)]);
% calculate the number of samples between consecutive high/low samples.
dHigh = diff(highSamples);
dLow = diff(lowSamples);
% identify skips in sample numbers which correspond to rests/whisks,
% convert from samples to seconds.
restLength = dHigh(dHigh > 1);
whiskLength = dLow(dLow > 1);
restDur = restLength/whiskerSamplingRate;
whiskDur = whiskLength/whiskerSamplingRate;
% control for the beginning/end of the trial to correctly map rests/whisks
% onto the whisk_starts.
if binWhiskerAngle(1)
    whiskDur(1) = [];
    whiskLength(1) = [];
end
if not(binWhiskerAngle(end))
    restDur(end) = [];
end
% calculate the whisking intensity -> sum(ProcData.Bin_wwf)/sum(Bin_wwf)
% over the duration of the whisk. Calculate the movement intensity over the same interval.
whiskInt = zeros(size(whiskStarts));
movementInt = zeros(size(whiskStarts));
for wS = 1:length(whiskSamples)
    % whisking intensity
    whiskInds = whiskSamples(wS):whiskSamples(wS) + whiskLength(wS);
    whiskInt(wS) = sum(ProcData.data.binWhiskerAngle(whiskInds))/numel(whiskInds);
    % movement intensity
    movementStart = round(whiskStarts(wS)*forceSensorSamplingRate);
    movementDur = round(whiskDur(wS)*forceSensorSamplingRate);
    movementInds = max(movementStart,1):min(movementStart + movementDur,length(ProcData.data.binForceSensor));
    movementInt(wS) = sum(ProcData.data.binForceSensor(movementInds))/numel(movementInds);
end
% calculate the time to the closest puff
% if no puff occurred during the trial, store 0 as a place holder.
if isempty(puffTimes)
    puffTimes = 0;
end
puffMat = ones(length(whiskSamples),1)*puffTimes;
whiskMat = whiskSamples'*ones(1,length(puffTimes))/whiskerSamplingRate;
puffTimeElapsed = abs(whiskMat - puffMat);
% convert to cell
puffTimeCell = mat2cell(puffTimeElapsed,ones(length(whiskStarts),1));
% error handle
if length(restDur) ~= length(whiskDur)
    disp('Error in GetWhiskdata! The number of whisks does not equal the number of rests...'); disp(' ')
    keyboard;
end
% compile into final structure
Whisk.eventTime = whiskStarts';
Whisk.duration = whiskDur';
Whisk.restTime = restDur';
Whisk.whiskScore = whiskInt';
Whisk.movementScore = movementInt';
Whisk.puffDistance = puffTimeCell;
end

function [Rest] = GetRestdata(ProcData)
% setup
whiskerSamplingRate = ProcData.notes.dsFs;
forceSensorSamplingRate = ProcData.notes.dsFs;
% get stimulation times
[puffTimes] = GetPuffTimes_JNeurosci2023(ProcData);
% recalculate linked binarized wwf without omitting any possible whisks,
% this avoids inclusion of brief whisker movements in periods of rest.
% assume that whisks at the beginning/end of trial continue outside of the
% trial time. This will link any event occurring within "link_thresh"
% seconds to the beginning/end of the trial rather than assuming that it is
% a new/isolated event.
modBinarizedWhiskers = ProcData.data.binWhiskerAngle;
modBinarizedWhiskers([1,end]) = 1;
modBinarizedForceSensor = ProcData.data.binForceSensor;
modBinarizedForceSensor([1,end]) = 1;
linkThresh = 0.5; % seconds
breakThresh = 0; % seconds
binWhiskerAngle = LinkBinaryEvents_JNeurosci2023(gt(modBinarizedWhiskers,0),[linkThresh breakThresh]*whiskerSamplingRate);
binForceSensor = LinkBinaryEvents_JNeurosci2023(modBinarizedForceSensor,[linkThresh breakThresh]*forceSensorSamplingRate);
% combine binWhiskerAngle, binForceSensor, and puffTimes, to find periods of rest.
% downsample bin_wwf to match length of bin_pswf
sampleVec = 1:length(binWhiskerAngle);
whiskHigh = sampleVec(binWhiskerAngle)/whiskerSamplingRate;
dsBinarizedWhiskers = zeros(size(binForceSensor));
% find Bin_wwf == 1. Convert indexes into pswf time. Coerce converted indexes
% between 1 and length(Bin_pswf). Take only unique values.
dsInds = min(max(round(whiskHigh*forceSensorSamplingRate),1),length(binForceSensor));
dsBinarizedWhiskers(unique(dsInds)) = 1;
% combine binarized whisking and body movement
wfBin = logical(min(dsBinarizedWhiskers + binForceSensor,1));
Fs = forceSensorSamplingRate;
% add puff times into the Bin_wf
puffInds = round(puffTimes*Fs);
wfBin(puffInds) = 1;
% find index for end of whisking event
edge = diff(wfBin);
samples = find([not(wfBin(1)),edge < 0]);
stops = samples/Fs;
% identify periods of whisking/resting, include beginning and end of trial
% if needed (hence unique command) for correct interval calculation
sampleVec = 1:length(logical(wfBin));
highSamples = unique([1,sampleVec(wfBin),sampleVec(end)]);
lowSamples = unique([1,sampleVec(not(wfBin)),sampleVec(end)]);
% calculate the number of samples between consecutive high/low samples.
dHigh = diff(highSamples);
dLow = diff(lowSamples);
% identify skips in sample numbers which correspond to rests/whisks,
% convert from samples to seconds.
restLength = dHigh(dHigh > 1);
restDur = restLength/Fs;
whiskLength = dLow(dLow > 1);
whiskDur = whiskLength/Fs;
% control for the beginning/end of the trial to correctly map rests/whisks
% onto the whisk_starts. Use index 2 and end-1 since it is assumed that the
% first and last indexes of a trial are the end/beginning of a volitional movement.
if not(wfBin(2))
    whiskDur = [NaN,whiskDur];
end
if wfBin(end - 1)
    whiskDur(end) = [];
end
% calculate the time to the closest puff
% if no puff occurred during the trial, store 0 as a place holder.
if isempty(puffTimes)
    puffTimes = 0;
end
puffMat = ones(length(samples),1)*puffTimes;
restMat = samples'*ones(1,length(puffTimes))/Fs;
puffTimeElapsed = abs(restMat - puffMat);
% convert to cell
puffTimeCell = mat2cell(puffTimeElapsed,ones(length(samples),1));
% compile into a structure
Rest.eventTime = stops';
Rest.duration = restDur';
Rest.puffDistance = puffTimeCell;
Rest.whiskDuration = whiskDur';
end
