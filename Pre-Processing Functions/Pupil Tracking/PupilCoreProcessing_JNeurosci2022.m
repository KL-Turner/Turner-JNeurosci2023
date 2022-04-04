function [] = PupilCoreProcessing_JNeurosci2022()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: 1) Track pupil diameter and detect periods of blinking
%            2) Patch any NaN values or droppped camera frames via interpolation
%            3) Manually check the first 5 and last 5 frames of each session to verify eye integrity/discharge
%            4) Manually check each blink for false positives
%            5) Manually check each file's pupil diameter
%            6) Extract resting pupil area and add it to RestData.mat structure
%            7) Determine baseline pupil area during rest and add it to RestingBaselines.mat
%            8) Extract whisking/stimulus triggered pupil area and add it to EventData.mat
%            9) Normalize RestData.mat and EventData.mat structures using resting baseline
%           10) Update pupil data in SleepData.mat
%________________________________________________________________________________________________________________________

%% BLOCK PURPOSE: [0] Load the script's necessary variables and data structures.
% Clear the workspace variables and command windyow.
% zap;
disp('Analyzing Block [0] Preparing the workspace and loading variables.'); disp(' ')
% Character list of all ProcData files
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
[animalID,~,~] = GetFileInfo_JNeurosci2022(procDataFileIDs(1,:));
%% BLOCK PURPOSE: [1] Track pupil area and blink detetction
disp('Analyzing Block [1] Tracking pupil area and blink detection.'); disp(' ')
RunPupilTracker_iterativeCorrection_backup(procDataFileIDs)
%% BLOCK PURPOSE: [2] Patch pupil area
disp('Analyzing Block [2]Patching NaN values and interpolating dropped frames.'); disp(' ')
for aa = 1:size(procDataFileIDs,1)
    disp(['Patching pupil area of file ' num2str(aa) '/' num2str(size(procDataFileIDs,1))]); disp(' ')
    PatchPupilArea_JNeurosci2022(procDataFileIDs(aa,:))
end
%% BLOCK PURPOSE: [3] Check eye quality
disp('Analyzing Block [3] Manually check eye quality.'); disp(' ')
for bb = 1:size(procDataFileIDs,1)
    disp(['Manually checking eye of file ' num2str(bb) '/' num2str(size(procDataFileIDs,1))]); disp(' ')
    CheckPupilVideoFrames_JNeurosci2022(procDataFileIDs(bb,:))
end
%% BLOCK PURPOSE: [4] Verify blinks
disp('Analyzing Block [4] Manually check blinks.'); disp(' ')
for cc = 1:size(procDataFileIDs,1)
    disp(['Manually checking blinks of file ' num2str(cc) '/' num2str(size(procDataFileIDs,1))]); disp(' ')
    CheckPupilBlinks_JNeurosci2022(procDataFileIDs(cc,:))
end
%% BLOCK PURPOSE: [5] Verify pupil area
disp('Analyzing Block [4] Manually check pupil area.'); disp(' ')
for dd = 1:size(procDataFileIDs,1)
    disp(['Manually checking pupil area of file ' num2str(dd) '/' num2str(size(procDataFileIDs,1))]); disp(' ')
    CheckPupilDiameter_JNeurosci2022(procDataFileIDs(dd,:))
end
%% BLOCK PURPOSE: [6] Convert area to diameter
disp('Analyzing Block [6] Converting pupil area to diameter in mm'); disp(' ')
for ee = 1:size(procDataFileIDs,1)
    disp(['Converting pupil area to pupil diameter of file ' num2str(ee) '/' num2str(size(procDataFileIDs,1))]); disp(' ')
    ConvertPupilAreaToDiameter_JNeurosci2022(procDataFileIDs(ee,:))
end
%% BLOCK PURPOSE: [7] Add pupil area to RestData.mat
disp('Analyzing Block [6] Adding pupil area to RestData.mat'); disp(' ')
dataTypes = {'pupilArea','diameter','mmArea','mmDiameter'};
ExtractPupilRestingData_JNeurosci2022(procDataFileIDs,dataTypes);
%% BLOCK PURPOSE: [8] Add pupil baseline to Restingbaselines.mat
disp('Analyzing Block [7] Adding pupil baseline to RestingBaselines.mat'); disp(' ')
[RestingBaselines] = AddPupilRestingBaseline_JNeurosci2022();
%% BLOCK PURPOSE: [9] zScore pupil data
disp('Analyzing Block [7] Z-scoring pupil data'); disp(' ')
for ff = 1:size(procDataFileIDs,1)
    disp(['Z-scoring pupil data of file ' num2str(ff) '/' num2str(size(procDataFileIDs,1))]); disp(' ')
    procDataFileID = procDataFileIDs(ff,:);
    zScorePupilData_JNeurosci2022(procDataFileID,RestingBaselines)
end
%% BLOCK PURPOSE: [10] Add pupil area to RestData.mat
disp('Analyzing Block [10] Adding pupil area to RestData.mat'); disp(' ')
dataTypes = {'pupilArea','diameter','mmArea','mmDiameter','zArea','zDiameter','LH_HbT','RH_HbT','LH_gammaBandPower','RH_gammaBandPower'};
[RestData] = ExtractPupilRestingData_JNeurosci2022(procDataFileIDs,dataTypes);
%% BLOCK PURPOSE: [11] Add pupil area to EventData.mat
disp('Analyzing Block [11] Add pupil whisk/stim data to EventData.mat'); disp(' ')
[EventData] = ExtractPupilEventTriggeredData_JNeurosci2022(procDataFileIDs);
%% BLOCK PURPOSE: [12] Normalize Rest/Event data structures
disp('Analyzing Block [12] Normalizing Rest/Event data structures.'); disp(' ')
[RestData] = NormBehavioralDataStruct_JNeurosci2022(RestData,RestingBaselines,'manualSelection');
save([animalID '_RestData.mat'],'RestData','-v7.3')
[EventData] = NormBehavioralDataStruct_JNeurosci2022(EventData,RestingBaselines,'manualSelection');
save([animalID '_EventData.mat'],'EventData','-v7.3')
%% BLOCK PURPOSE: [13] Add pupil data to SleepData.mat
disp('Analyzing Block [13] Adding pupil data to SleepData structure.'); disp(' ')
AddPupilSleepParameters_JNeurosci2022(procDataFileIDs)
UpdatePupilSleepData_JNeurosci2022(procDataFileIDs)
%% fin
disp('Pupil Core Processing - Complete.'); disp(' ')
