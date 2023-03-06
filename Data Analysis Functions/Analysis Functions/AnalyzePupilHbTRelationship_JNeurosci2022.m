function [Results_PupilHbTRelationship] = AnalyzePupilHbTRelationship_JNeurosci2022(animalID,rootFolder,delim,Results_PupilHbTRelationship)
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
% find and load manual baseline event information
scoringResultsFileStruct = dir('*Forest_ScoringResults.mat');
scoringResultsFile = {scoringResultsFileStruct.name}';
scoringResultsFileID = char(scoringResultsFile);
load(scoringResultsFileID,'-mat')
% find and load EventData.mat struct
procDataFileStruct = dir('*_ProcData.mat');
procDataFile = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFile);
% extract/concatenate data from each file
cat_Pupil = [];
catLH_HbT = [];
catRH_HbT = [];
for aa = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(aa,:);
    load(procDataFileID)
    if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
        for bb = 1:length(ProcData.sleep.parameters.Pupil.zDiameter)
            pupil = mean(ProcData.sleep.parameters.Pupil.zDiameter{bb,1});
            LH_HbT = mean(ProcData.sleep.parameters.CBV.hbtLH{bb,1});
            RH_HbT = mean(ProcData.sleep.parameters.CBV.hbtRH{bb,1});
            % group date based on arousal-state classification
            state = ScoringResults.labels{aa,1}{bb,1};
            if strcmp(state,'Not Sleep') == true
                if isfield(cat_Pupil,'Awake') == false
                    cat_Pupil.Awake = [];
                    catLH_HbT.Awake = [];
                    catRH_HbT.Awake = [];
                end
                cat_Pupil.Awake = cat(1,cat_Pupil.Awake,pupil);
                catLH_HbT.Awake = cat(1,catLH_HbT.Awake,LH_HbT);
                catRH_HbT.Awake = cat(1,catRH_HbT.Awake,RH_HbT);
            elseif strcmp(state,'NREM Sleep') == true
                if isfield(cat_Pupil,'NREM') == false
                    cat_Pupil.NREM = [];
                    catLH_HbT.NREM = [];
                    catRH_HbT.NREM = [];
                end
                cat_Pupil.NREM = cat(1,cat_Pupil.NREM,pupil);
                catLH_HbT.NREM = cat(1,catLH_HbT.NREM,LH_HbT);
                catRH_HbT.NREM = cat(1,catRH_HbT.NREM,RH_HbT);
            elseif strcmp(state,'REM Sleep') == true
                if isfield(cat_Pupil,'REM') == false
                    cat_Pupil.REM = [];
                    catLH_HbT.REM = [];
                    catRH_HbT.REM = [];
                end
                cat_Pupil.REM = cat(1,cat_Pupil.REM,pupil);
                catLH_HbT.REM = cat(1,catLH_HbT.REM,LH_HbT);
                catRH_HbT.REM = cat(1,catRH_HbT.REM,RH_HbT);
            end
        end
    end
end
% save results
Results_PupilHbTRelationship.(animalID) = [];
Results_PupilHbTRelationship.(animalID).Awake.Pupil = cat_Pupil.Awake;
Results_PupilHbTRelationship.(animalID).NREM.Pupil = cat_Pupil.NREM;
Results_PupilHbTRelationship.(animalID).REM.Pupil = cat_Pupil.REM;
Results_PupilHbTRelationship.(animalID).Awake.HbT = mean(cat(2,catLH_HbT.Awake,catRH_HbT.Awake),2);
Results_PupilHbTRelationship.(animalID).NREM.HbT = mean(cat(2,catLH_HbT.NREM,catRH_HbT.NREM),2);
Results_PupilHbTRelationship.(animalID).REM.HbT = mean(cat(2,catLH_HbT.REM,catRH_HbT.REM),2);
% save data
cd([rootFolder delim 'Analysis Structures\'])
save('Results_PupilHbTRelationship.mat','Results_PupilHbTRelationship')
cd([rootFolder delim])

end
