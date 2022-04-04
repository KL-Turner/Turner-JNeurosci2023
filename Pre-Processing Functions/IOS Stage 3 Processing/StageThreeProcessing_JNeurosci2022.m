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

%% BLOCK PURPOSE: [0] Load the script's necessary variables and data structures.
% Clear the workspace variables and command windyow.
zap;
disp('Analyzing Block [0] Preparing the workspace and loading variables.'); disp(' ')
% Character list of all RawData files
rawDataFileStruct = dir('*_RawData.mat');
rawDataFiles = {rawDataFileStruct.name}';
rawDataFileIDs = char(rawDataFiles);
% Character list of all ProcData files
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
[animalID,~,~] = GetFileInfo_JNeurosci2022(procDataFileIDs(1,:));
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
%% BLOCK PURPOSE: [1] Categorize data
disp('Analyzing Block [1] Categorizing data.'); disp(' ')
for a = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(a,:);
    disp(['Analyzing file ' num2str(a) ' of ' num2str(size(procDataFileIDs,1)) '...']); disp(' ')
    CategorizeData_JNeurosci2022(procDataFileID,stimulationType)
end
%% BLOCK PURPOSE: [2] Create RestData data structure
disp('Analyzing Block [2] Create RestData struct for CBV and neural data.'); disp(' ')
[RestData] = ExtractRestingData_JNeurosci2022(procDataFileIDs,dataTypes,imagingType);
%% BLOCK PURPOSE: [3] Analyze the spectrogram for each session.
disp('Analyzing Block [3] Analyzing the spectrogram for each file.'); disp(' ')
CreateTrialSpectrograms_JNeurosci2022(rawDataFileIDs,neuralDataTypes);
%% BLOCK PURPOSE: [4] Create Baselines data structure
disp('Analyzing Block [4] Create baselines structure for CBV and neural data.'); disp(' ')
baselineType = 'setDuration';
trialDuration_sec = 900;
targetMinutes = 60;
[RestingBaselines] = CalculateRestingBaselines_JNeurosci2022(animalID,targetMinutes,trialDuration_sec,RestData);
% Find spectrogram baselines for each day
[RestingBaselines] = CalculateSpectrogramBaselines_JNeurosci2022(animalID,neuralDataTypes,trialDuration_sec,RestingBaselines,baselineType);
% Normalize spectrogram by baseline
NormalizeSpectrograms_JNeurosci2022(neuralDataTypes,RestingBaselines);
%% BLOCK PURPOSE: [5] Manually select files for custom baseline calculation
disp('Analyzing Block [5] Manually select files for custom baseline calculation.'); disp(' ')
hemoType = 'reflectance';
[RestingBaselines] = CalculateManualRestingBaselinesTimeIndeces_JNeurosci2022(imagingType,hemoType);
%% BLOCK PURPOSE [6] Add delta HbT field to each processed data file
disp('Analyzing Block [6] Adding delta HbT to each ProcData file.'); disp(' ')
updatedBaselineType = 'manualSelection';
UpdateTotalHemoglobin_JNeurosci2022(procDataFileIDs,RestingBaselines,updatedBaselineType,imagingType,ledColor)
if strcmpi(imagingType,'GCaMP') == true
    CorrectGCaMPattenuation_JNeurosci2022(procDataFileIDs,RestingBaselines)
end
%% BLOCK PURPOSE: [7] Re-create the RestData structure now that HbT is available
disp('Analyzing Block [7] Creating RestData struct for CBV and neural data.'); disp(' ')
[RestData] = ExtractRestingData_JNeurosci2022(procDataFileIDs,updatedDataTypes,imagingType);
%% BLOCK PURPOSE: [8] Create the EventData structure for CBV and neural data
disp('Analyzing Block [8] Create EventData struct for CBV and neural data.'); disp(' ')
[EventData] = ExtractEventTriggeredData_JNeurosci2022(procDataFileIDs,updatedDataTypes,imagingType);
%% BLOCK PURPOSE: [9] Normalize RestData and EventData structures by the resting baseline
% Character list of all ProcData files
restDataFileStruct = dir('*_RestData.mat');
restDataFiles = {restDataFileStruct.name}';
restDataFileIDs = char(restDataFiles);
load(restDataFileIDs)
% Character list of all ProcData files
eventDataFileStruct = dir('*_EventData.mat');
eventDataFiles = {eventDataFileStruct.name}';
eventDataFileIDs = char(eventDataFiles);
load(eventDataFileIDs)
% Character list of all ProcData files
baseDataFileStruct = dir('*_RestingBaselines.mat');
baseDataFiles = {baseDataFileStruct.name}';
baseDataFileIDs = char(baseDataFiles);
load(baseDataFileIDs)
disp('Analyzing Block [9] Normalizing RestData and EventData structures by the resting baseline.'); disp(' ')
[RestData] = NormBehavioralDataStruct_JNeurosci2022(RestData,RestingBaselines,updatedBaselineType);
save([animalID '_RestData.mat'],'RestData','-v7.3')
[EventData] = NormBehavioralDataStruct_JNeurosci2022(EventData,RestingBaselines,updatedBaselineType);
save([animalID '_EventData.mat'],'EventData','-v7.3')
%% BLOCK PURPOSE: [10] Analyze the spectrogram baseline for each session.
disp('Analyzing Block [10] Analyzing the spectrogram for each file and normalizing by the resting baseline.'); disp(' ')
% Find spectrogram baselines for each day
[RestingBaselines] = CalculateSpectrogramBaselines_JNeurosci2022(animalID,neuralDataTypes,trialDuration_sec,RestingBaselines,updatedBaselineType);
% Normalize spectrogram by baseline
NormalizeSpectrograms_JNeurosci2022(neuralDataTypes,RestingBaselines);
% Create a structure with all spectrograms for convenient analysis further downstream
CreateAllSpecDataStruct_JNeurosci2022(animalID,neuralDataTypes)
%% BLOCK PURPOSE [11] Generate single trial figures
disp('Analyzing Block [11] Generating single trial summary figures'); disp(' ')
updatedBaselineType = 'manualSelection';
saveFigs = 'y';
% HbT
hemoType = 'HbT';
if strcmpi(imagingType,'GCaMP') == true
    for bb = 1:size(procDataFileIDs,1)
        procDataFileID = procDataFileIDs(bb,:);
        [figHandle] = GenerateSingleFigures_GCaMP(procDataFileID,RestingBaselines,updatedBaselineType,saveFigs,imagingType,hemoType);
        close(figHandle)
    end
else
    for bb = 1:size(procDataFileIDs,1)
        procDataFileID = procDataFileIDs(bb,:);
        [figHandle] = GenerateSingleFigures_JNeurosci2022(procDataFileID,RestingBaselines,updatedBaselineType,saveFigs,imagingType,hemoType);
        close(figHandle)
    end
end
%% Isoflurane manual set
% SetIsofluraneHbT_JNeurosci2022()

%% Neural motion artifacts
% CheckNeuralMotionArtifacts_JNeurosci2022(procDataFileIDs,RestingBaselines,baselineType,imagingType,hemoType)

disp('Stage Three Processing - Complete.'); disp(' ')
