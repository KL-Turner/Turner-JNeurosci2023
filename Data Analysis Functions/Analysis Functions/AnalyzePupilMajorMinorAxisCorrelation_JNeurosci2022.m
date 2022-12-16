function [Results_AxisCorrelation] = AnalyzePupilMajorMinorAxisCorrelation_JNeurosci2022(animalID,rootFolder,delim,Results_AxisCorrelation)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Analyze the relationship between hemodynamics and pupil diameter
%________________________________________________________________________________________________________________________

% go to animal's data location
dataLocation = [rootFolder delim 'Data' delim animalID delim 'Bilateral Imaging'];
cd(dataLocation)
% list of ProcData files
procDataFileStruct = dir('*_ProcData.mat');
procDataFile = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFile);
% extract/concatenate data from each file
rValue = []; 
bb = 1;
for aa = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(aa,:);
    load(procDataFileID)
    if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
        pupilMinor = rmmissing(ProcData.data.Pupil.pupilMinor);
        pupilMajor = rmmissing(ProcData.data.Pupil.pupilMajor);
        rMatrix = corrcoef(pupilMinor,pupilMajor);
        rValue(bb,1) = rMatrix(2,1);
        bb = bb + 1;
    end
end
% save results
Results_AxisCorrelation.(animalID).rArray = rValue;
Results_AxisCorrelation.(animalID).meanR = mean(rValue);
% save data
cd([rootFolder delim])
save('Results_AxisCorrelation.mat','Results_AxisCorrelation')

end
