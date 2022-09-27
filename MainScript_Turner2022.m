function [] = MainScript_Turner2022()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Generate figure panels for Turner et al. Pupil Manuscript, J Neurosci 2022
%
% Functions used to pre-process the original data are located in the folder "Pre-Processing Functions"
% Functions used to analyze data for figures are located in the folder "Data Analysis Functions"
% Functions optained from 3rd party are located in the folder "Shared Functions"
%________________________________________________________________________________________________________________________

% Verify code repository and data are in the current directory/added path
currentFolder = pwd;
addpath(genpath(currentFolder));
fileparts = strsplit(currentFolder,filesep);
if ismac
    rootFolder = fullfile(filesep,fileparts{1:end});
    delim = '/';
else
    rootFolder = fullfile(fileparts{1:end});
    delim = '\';
end
% Add root folder to Matlab's working directory
addpath(genpath(rootFolder))
zap;
multiWaitbar('CloseAll');
% Analysis subfunctions
runAnalysis = false;
if runAnalysis == true
    dataLocation = [rootFolder delim 'Analysis Structures'];
    cd(dataLocation)
    AnalyzeSleepModelAccuracy_Handler_Turner2022(rootFolder,delim,false)
    AnalyzePupilExample_Handler_Turner2022(rootFolder,delim,false)
    AnalyzePupilThreshold_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeAnimalStateTime_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeBehavioralArea_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeEvokedResponses_Handler_Turner2022(rootFolder,delim,false)
    AnalyzePupilAreaSleepProbability_Handler_Turner2022(rootFolder,delim,false)
    AnalyzePupilHbTRelationship_Handler_Turner2022(rootFolder,delim,false)
    AnalyzePupilGammaRelationship_Handler_Turner2022(rootFolder,delim,false)
    AnalyzePowerSpectrum_Handler_Turner2022(rootFolder,delim,false)
    AnalyzePreWhitenedPowerSpectrum_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeCoherence_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeCrossCorrelation_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeBlinkTransition_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeInterBlinkInterval_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeBlinkResponses_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeStimulusBlinks_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeBlinkCoherogram_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeBlinkSpectrogram_Handler_Turner2022(rootFolder,delim,false)
    AnalyzePupilMajorMinorAxisCorrelation_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeEyesOpenEyesClosedREM_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeTransitionalAverages_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeArousalStateEyeMotion_Handler_Turner2022(rootFolder,delim,false)
    multiWaitbar('CloseAll');
    cd(rootFolder)
end
% Main figures
disp('Loading analysis results and generating figures...'); disp(' ')
saveFigs = true;
% Figure Panel 8 is schematic diagram
Fig7_Turner2022(rootFolder,saveFigs,delim)
Fig6_Turner2022(rootFolder,saveFigs,delim)
Fig5_Turner2022(rootFolder,saveFigs,delim)
Fig4_Turner2022(rootFolder,saveFigs,delim)
Fig3_Turner2022(rootFolder,saveFigs,delim)
Fig2_Turner2022(rootFolder,saveFigs,delim)
Fig1_Turner2022(rootFolder,saveFigs,delim)
% Supplemental pupil tracking movie
if exist('VideoS1.mp4','file') ~= 2
    VideoS1_Turner2022()
end

end
