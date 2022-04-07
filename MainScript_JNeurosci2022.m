function [] = MainScript_JNeurosci2022()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
% Purpose:
%
% Scripts used to pre-process the original data are located in the folder "Pre-Processing Scripts".
% Functions that are used in both the analysis and pre-processing are located in the analysis folder.
%________________________________________________________________________________________________________________________

% zap;
multiWaitbar('CloseAll');
%% verify code repository and data are in the current directory/added path
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
%% analysis subfunctions
runAnalysis = false;
if runAnalysis == true
    AnalyzePhysiologicalSleepModelAccuracy_Handler_JNeurosci2022(rootFolder,delim,false)
    AnalyzePupilSleepModelAccuracy_Handler_JNeurosci2022(rootFolder,delim,false)
    AnalyzeBehavioralArea_Handler_JNeurosci2022(rootFolder,delim,false)
    AnalyzeEvokedResponses_Handler_JNeurosci2022(rootFolder,delim,false)
    AnalyzePupilAreaSleepProbability_Handler_JNeurosci2022(rootFolder,delim,false)
    AnalyzeBlinkResponses_Handler_JNeurosci2022(rootFolder,delim,false)
    AnalyzePowerSpectrum_Handler_JNeurosci2022(rootFolder,delim,false)
    AnalyzeCoherence_Handler_JNeurosci2022(rootFolder,delim,false)
    AnalyzeCrossCorrelation_Handler_JNeurosci2022(rootFolder,delim,false)
    AnalyzeStimulusBlinks_Handler_JNeurosci2022(rootFolder,delim,true)
    AnalyzeBlinkPeriodogram_Handler_JNeurosci2022(rootFolder,delim,false)
    AnalyzePupilHbTRelationship_Handler_JNeurosci2022(rootFolder,delim,false)
    AnalyzePupilGammaRelationship_Handler_JNeurosci2022(rootFolder,delim,false)
    AnalyzeBlinkCoherogram_Handler_JNeurosci2022(rootFolder,delim,false)
    AnalyzeBlinkTransition_Handler_JNeurosci2022(rootFolder,delim,false)
    AnalyzeInterBlinkInterval_Handler_JNeurosci2022(rootFolder,delim,false)
    AnalyzePupilThreshold_Handler_JNeurosci2022(rootFolder,delim,false)
    AnalyzePupilExample_Handler_JNeurosci2022(rootFolder,delim,false)
    AnalyzeSleepModelCoherence_Handler_JNeurosci2022(rootFolder,delim,false)
    multiWaitbar('CloseAll');
end
%% main figures
disp('Loading analysis results and generating figures...'); disp(' ')
saveFigs = false;
Fig1_JNeurosci2022(rootFolder,saveFigs,delim)
Fig2_JNeurosci2022(rootFolder,saveFigs,delim)
Fig3_JNeurosci2022(rootFolder,saveFigs,delim)
Fig4_JNeurosci2022(rootFolder,saveFigs,delim)
Fig5_JNeurosci2022(rootFolder,saveFigs,delim)
end
