function [] = MainScript_Turner2022()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Generate figure panels for Turner et al. Pupil Manuscript (TBD) 2022
%
% Functions used to pre-process the original data are located in the folder "Pre-Processing Functions"
% Functions used to analyze data for figures are located in the folder "Data Analysis Functions"
% Functions optained from 3rd party are located in the folder "Shared Functions"
%________________________________________________________________________________________________________________________

% verify code repository and data are in the current directory/added path
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
% add root folder to Matlab's working directory
addpath(genpath(rootFolder))
zap;
multiWaitbar('CloseAll');
% analysis subfunctions
runAnalysis = false;
if runAnalysis == true
    AnalyzePupilSleepModelAccuracy_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeLaggedPupilSleepModelAccuracy_Handler_Turner2022(rootFolder,delim,false)
    AnalyzePhysioSleepModelAccuracy_Handler_Turner2022(rootFolder,delim,false)
    AnalyzePupilExample_Handler_Turner2022(rootFolder,delim,false)
    AnalyzePupilExample2_Handler_Turner2022(rootFolder,delim,false)
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
    AnalyzeSleepModelCoherence_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeCrossCorrelation_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeBlinkTransition_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeInterBlinkInterval_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeBlinkResponses_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeStimulusBlinks_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeBlinkPeriodogram_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeBlinkCoherogram_Handler_Turner2022(rootFolder,delim,false)
    AnalyzeBlinkSpectrogram_Handler_Turner2022(rootFolder,delim,false)
    multiWaitbar('CloseAll');
end
% main figures
disp('Loading analysis results and generating figures...'); disp(' ')
saveFigs = true;
Fig5_Turner2022(rootFolder,saveFigs,delim)
Fig4_Turner2022(rootFolder,saveFigs,delim)
Fig3_Turner2022(rootFolder,saveFigs,delim)
Fig2_Turner2022(rootFolder,saveFigs,delim)
Fig1_Turner2022(rootFolder,saveFigs,delim)
% supplemental pupil tracking movie
if exist('VideoS1.mp4','file') ~= 2
    VideoS1_Turner2022()
end

end
