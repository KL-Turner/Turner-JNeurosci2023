function [Results_PupilGammaRelationship] = AnalyzePupilGammaRelationship_Pupil(animalID,rootFolder,delim,Results_PupilGammaRelationship)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Analyze the relationship between gamma-band power and hemodynamics [Gamma] (IOS)
%________________________________________________________________________________________________________________________

%% function parameters
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
catLH_Gamma = [];
catRH_Gamma = [];
for aa = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(aa,:);
    load(procDataFileID)
    if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
        for bb = 1:length(ProcData.sleep.parameters.Pupil.zDiameter)
            pupil = mean(ProcData.sleep.parameters.Pupil.zDiameter{bb,1});
            LH_Gamma = mean(ProcData.sleep.parameters.cortical_LH.specGammaBandPower{bb,1}{1,1});
            RH_Gamma = mean(ProcData.sleep.parameters.cortical_RH.specGammaBandPower{bb,1}{1,1});
            % group date based on arousal-state classification
            state = ScoringResults.labels{aa,1}{bb,1};
            if strcmp(state,'Not Sleep') == true
                if isfield(cat_Pupil,'Awake') == false
                    cat_Pupil.Awake = [];
                    catLH_Gamma.Awake = [];
                    catRH_Gamma.Awake = [];
                end
                cat_Pupil.Awake = cat(1,cat_Pupil.Awake,pupil);
                catLH_Gamma.Awake = cat(1,catLH_Gamma.Awake,LH_Gamma);
                catRH_Gamma.Awake = cat(1,catRH_Gamma.Awake,RH_Gamma);
            elseif strcmp(state,'NREM Sleep') == true
                if isfield(cat_Pupil,'NREM') == false
                    cat_Pupil.NREM = [];
                    catLH_Gamma.NREM = [];
                    catRH_Gamma.NREM = [];
                end
                cat_Pupil.NREM = cat(1,cat_Pupil.NREM,pupil);
                catLH_Gamma.NREM = cat(1,catLH_Gamma.NREM,LH_Gamma);
                catRH_Gamma.NREM = cat(1,catRH_Gamma.NREM,RH_Gamma);
            elseif strcmp(state,'REM Sleep') == true
                if isfield(cat_Pupil,'REM') == false
                    cat_Pupil.REM = [];
                    catLH_Gamma.REM = [];
                    catRH_Gamma.REM = [];
                end
                cat_Pupil.REM = cat(1,cat_Pupil.REM,pupil);
                catLH_Gamma.REM = cat(1,catLH_Gamma.REM,LH_Gamma);
                catRH_Gamma.REM = cat(1,catRH_Gamma.REM,RH_Gamma);
            end
        end
    end
end
% save results
Results_PupilGammaRelationship.(animalID) = [];
Results_PupilGammaRelationship.(animalID).Awake.Pupil = cat_Pupil.Awake;
Results_PupilGammaRelationship.(animalID).NREM.Pupil = cat_Pupil.NREM;
Results_PupilGammaRelationship.(animalID).REM.Pupil = cat_Pupil.REM;
Results_PupilGammaRelationship.(animalID).Awake.Gamma = mean(cat(2,catLH_Gamma.Awake,catRH_Gamma.Awake),2);
Results_PupilGammaRelationship.(animalID).NREM.Gamma = mean(cat(2,catLH_Gamma.NREM,catRH_Gamma.NREM),2);
Results_PupilGammaRelationship.(animalID).REM.Gamma = mean(cat(2,catLH_Gamma.REM,catRH_Gamma.REM),2);
% save data
cd([rootFolder delim])
save('Results_PupilGammaRelationship.mat','Results_PupilGammaRelationship')

end
