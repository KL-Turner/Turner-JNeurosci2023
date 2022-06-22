%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: 1) Categorize behavioral (rest,whisk,stim) data using previously processed data structures, add 'flags'
%            2) Create a temporary RestData structure that contains periods of rest - use this for initial figures
%            3) Analyze neural data and create different spectrograms for each file's electrodes
%            4) Uses periods when animal is not being stimulated or moving to establish an initial baseline
%            5) Manually select awake files for a slightly different baseline not based on hard time vals
%            6) Use the best baseline to convert reflectance changes to total hemoglobin
%            7) Re-create the RestData structure now that we can deltaHbT
%            8) Create an EventData structure looking at the different data types after whisking or stimulation
%            9) Apply the resting baseline to each data type to create a percentage change
%            10) Use the time indeces of the resting baseline file to apply a percentage change to the spectrograms
%            11) Use the time indeces of the resting baseline file to create a reflectance pixel-based baseline
%            12) Generate a summary figure for all of the analyzed and processed data
%________________________________________________________________________________________________________________________

% load the script's necessary variables and data structures.
% clear the workspace variables and command windyow.
zap;
% character list of all RawData files
rawDataFileStruct = dir('*_RawData.mat');
rawDataFiles = {rawDataFileStruct.name}';
rawDataFileIDs = char(rawDataFiles);
% character list of all ProcData files
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
[animalID,~,~] = GetFileInfo_Turner2022(procDataFileIDs(1,:));
% parameters used for various animal analysis
curDir = cd;
dirBreaks = strfind(curDir,'\');
curFolder = curDir(dirBreaks(end) + 1:end);
imagingType = input('Input imaging type (bilateral, single, GCaMP): ','s'); disp(' ')
stimulationType = input('Input stimulation type (single or pulse): ','s'); disp(' ')
ledColor = input('Input isosbestic LED color (green or lime): ','s'); disp(' ')
if strcmpi(imagingType,'GCaMP') == true
    dataTypes = {'CBV','GCaMP7s','Deoxy','cortical_LH','cortical_RH','hippocampus','EMG'};
    updatedDataTypes = {'CBV','CBV_HbT','GCaMP7s','Deoxy','cortical_LH','cortical_RH','hippocampus','EMG'};
else
    dataTypes = {'CBV','cortical_LH','cortical_RH','hippocampus','EMG'};
    updatedDataTypes = {'CBV','CBV_HbT','cortical_LH','cortical_RH','hippocampus','EMG'};
end
neuralDataTypes = {'cortical_LH','cortical_RH','hippocampus'};
basefile = ([animalID '_RestingBaselines.mat']);
% categorize data
for a = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(a,:);
    disp(['Analyzing file ' num2str(a) ' of ' num2str(size(procDataFileIDs,1)) '...']); disp(' ')
    CategorizeData_Turner2022(procDataFileID,stimulationType)
end
% create RestData data structure
[RestData] = ExtractRestingData_Turner2022(procDataFileIDs,dataTypes,imagingType);
% analyze the spectrogram for each session.
CreateTrialSpectrograms_Turner2022(rawDataFileIDs,neuralDataTypes);
% create Baselines data structure
baselineType = 'setDuration';
trialDuration_sec = 900;
targetMinutes = 60;
[RestingBaselines] = CalculateRestingBaselines_Turner2022(animalID,targetMinutes,trialDuration_sec,RestData);
% Find spectrogram baselines for each day
[RestingBaselines] = CalculateSpectrogramBaselines_Turner2022(animalID,neuralDataTypes,trialDuration_sec,RestingBaselines,baselineType);
% Normalize spectrogram by baseline
NormalizeSpectrograms_Turner2022(neuralDataTypes,RestingBaselines);
% manually select files for custom baseline calculation
hemoType = 'reflectance';
[RestingBaselines] = CalculateManualRestingBaselinesTimeIndeces_Turner2022(imagingType,hemoType);
% add delta HbT field to each processed data file
updatedBaselineType = 'manualSelection';
UpdateTotalHemoglobin_Turner2022(procDataFileIDs,RestingBaselines,updatedBaselineType,imagingType,ledColor)
if strcmpi(imagingType,'GCaMP') == true
    CorrectGCaMPattenuation_Turner2022(procDataFileIDs,RestingBaselines)
end
% re-create the RestData structure now that HbT is available
[RestData] = ExtractRestingData_Turner2022(procDataFileIDs,updatedDataTypes,imagingType);
% create the EventData structure for CBV and neural data
[EventData] = ExtractEventTriggeredData_Turner2022(procDataFileIDs,updatedDataTypes,imagingType);
% normalize RestData and EventData structures by the resting baseline
% character list of all ProcData files
restDataFileStruct = dir('*_RestData.mat');
restDataFiles = {restDataFileStruct.name}';
restDataFileIDs = char(restDataFiles);
load(restDataFileIDs)
% character list of all ProcData files
eventDataFileStruct = dir('*_EventData.mat');
eventDataFiles = {eventDataFileStruct.name}';
eventDataFileIDs = char(eventDataFiles);
load(eventDataFileIDs)
% character list of all ProcData files
baseDataFileStruct = dir('*_RestingBaselines.mat');
baseDataFiles = {baseDataFileStruct.name}';
baseDataFileIDs = char(baseDataFiles);
load(baseDataFileIDs)
[RestData] = NormBehavioralDataStruct_Turner2022(RestData,RestingBaselines,updatedBaselineType);
save([animalID '_RestData.mat'],'RestData','-v7.3')
[EventData] = NormBehavioralDataStruct_Turner2022(EventData,RestingBaselines,updatedBaselineType);
save([animalID '_EventData.mat'],'EventData','-v7.3')
% analyze the spectrogram baseline for each session.
% find spectrogram baselines for each day
[RestingBaselines] = CalculateSpectrogramBaselines_Turner2022(animalID,neuralDataTypes,trialDuration_sec,RestingBaselines,updatedBaselineType);
% normalize spectrogram by baseline
NormalizeSpectrograms_Turner2022(neuralDataTypes,RestingBaselines);
% create a structure with all spectrograms for convenient analysis further downstream
CreateAllSpecDataStruct_Turner2022(animalID,neuralDataTypes)
% generate single trial figures
updatedBaselineType = 'manualSelection';
saveFigs = 'y';
% HbT
hemoType = 'HbT';
if strcmpi(imagingType,'GCaMP') == true
    for bb = 1:size(procDataFileIDs,1)
        procDataFileID = procDataFileIDs(bb,:);
        [figHandle] = GenerateSingleFigures_GCaMP_Turner2022(procDataFileID,RestingBaselines,saveFigs,hemoType,'somatosensory');
        close(figHandle)
%         [figHandle] = GenerateSingleFigures_GCaMP_Turner2022(procDataFileID,RestingBaselines,saveFigs,hemoType,'frontal');
%         close(figHandle)
    end
else
    for bb = 1:size(procDataFileIDs,1)
        procDataFileID = procDataFileIDs(bb,:);
        [figHandle] = GenerateSingleFigures_Turner2022(procDataFileID,RestingBaselines,updatedBaselineType,saveFigs,imagingType,hemoType);
        close(figHandle)
    end
end
% isoflurane manual set
% SetIsofluraneHbT_Turner2022()
% identify motion artifacts in neural data
% CheckNeuralMotionArtifacts_Turner2022(procDataFileIDs,RestingBaselines,baselineType,imagingType,hemoType)
