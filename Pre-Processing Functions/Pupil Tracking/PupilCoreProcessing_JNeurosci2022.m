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

%% load the script's necessary variables and data structures.
% clear the workspace variables and command windyow.
zap;
% character list of all ProcData files
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
% [animalID,~,~] = GetFileInfo_JNeurosci2022(procDataFileIDs(1,:));
% %% track pupil area and blink detetction
% RunPupilTracker_JNeurosci2022(procDataFileIDs)
% %% patch pupil area
% for aa = 1:size(procDataFileIDs,1)
%     disp(['Patching pupil area of file ' num2str(aa) '/' num2str(size(procDataFileIDs,1))]); disp(' ')
%     PatchPupilArea_JNeurosci2022(procDataFileIDs(aa,:))
% end
% %% check eye quality
% for bb = 1:size(procDataFileIDs,1)
%     disp(['Manually checking eye of file ' num2str(bb) '/' num2str(size(procDataFileIDs,1))]); disp(' ')
%     CheckPupilVideoFrames_JNeurosci2022(procDataFileIDs(bb,:))
% end
% %% verify blinks
% for cc = 1:size(procDataFileIDs,1)
%     disp(['Manually checking blinks of file ' num2str(cc) '/' num2str(size(procDataFileIDs,1))]); disp(' ')
%     CheckPupilBlinks_JNeurosci2022(procDataFileIDs(cc,:))
% end
% %% verify pupil area
% for dd = 1:size(procDataFileIDs,1)
%     disp(['Manually checking pupil area of file ' num2str(dd) '/' num2str(size(procDataFileIDs,1))]); disp(' ')
%     CheckPupilDiameter_JNeurosci2022(procDataFileIDs(dd,:))
% end
% %% convert area to diameter
% for ee = 1:size(procDataFileIDs,1)
%     disp(['Converting pupil area to pupil diameter of file ' num2str(ee) '/' num2str(size(procDataFileIDs,1))]); disp(' ')
%     ConvertPupilAreaToDiameter_JNeurosci2022(procDataFileIDs(ee,:))
% end
% %% add pupil area to RestData.mat
% dataTypes = {'pupilArea','diameter','mmArea','mmDiameter','patchCentroidX','patchCentroidY'};
% ExtractPupilRestingData_JNeurosci2022(procDataFileIDs,dataTypes);
%% add pupil baseline to Restingbaselines.mat
% [RestingBaselines] = AddPupilRestingBaseline_JNeurosci2022();
% %% zScore pupil data
% for ff = 1:size(procDataFileIDs,1)
%     disp(['Z-scoring pupil data of file ' num2str(ff) '/' num2str(size(procDataFileIDs,1))]); disp(' ')
%     procDataFileID = procDataFileIDs(ff,:);
%     zScorePupilData_JNeurosci2022(procDataFileID,RestingBaselines)
% end
% %% add pupil area to RestData.mat
% dataTypes = {'pupilArea','diameter','mmArea','mmDiameter','zArea','zDiameter','LH_HbT','RH_HbT','LH_gammaBandPower','RH_gammaBandPower'};
% [RestData] = ExtractPupilRestingData_JNeurosci2022(procDataFileIDs,dataTypes);
% %% add pupil area to EventData.mat
% [EventData] = ExtractPupilEventTriggeredData_JNeurosci2022(procDataFileIDs);
% %% normalize Rest/Event data structures
% [RestData] = NormBehavioralDataStruct_JNeurosci2022(RestData,RestingBaselines,'manualSelection');
% save([animalID '_RestData.mat'],'RestData','-v7.3')
% [EventData] = NormBehavioralDataStruct_JNeurosci2022(EventData,RestingBaselines,'manualSelection');
% save([animalID '_EventData.mat'],'EventData','-v7.3')
%% add pupil data to SleepData.mat
% load resting baseline file
baselineDataFileStruct = dir('*_RestingBaselines.mat');
baselineDataFiles = {baselineDataFileStruct.name}';
baselineDataFileID = char(baselineDataFiles);
load(baselineDataFileID)
AddPupilSleepParameters_JNeurosci2022(procDataFileIDs,RestingBaselines)
UpdatePupilSleepData_JNeurosci2022(procDataFileIDs)
