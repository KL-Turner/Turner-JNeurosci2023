function [] = AnalyzePupilAreaSleepProbability_Turner2022(animalIDs,rootFolder,delim)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Analyze the probability of arousal-state classification based on diameter
%________________________________________________________________________________________________________________________

% function parameters
allCatLabels = [];
diameterAllCatMeans = [];
% extract data from each animal's sleep scoring results
for aa = 1:length(animalIDs)
    animalID = animalIDs{1,aa};
    dataLocation = [rootFolder delim 'Data' delim animalID delim 'Bilateral Imaging'];
    cd(dataLocation)
    % add this animal's scoring labels with the other animal'ss
    scoringResults = ls('*Forest_ScoringResults.mat');
    load(scoringResults,'-mat')
    % take the mean of each 5 second bin
    procDataFileStruct = dir('*_ProcData.mat');
    procDataFiles = {procDataFileStruct.name}';
    procDataFileIDs = char(procDataFiles);
    binSize = 5; % seconds
    numBins = 180; % 15 minutes with 5 sec bins
    samplingRate = 30; % Hz
    samplesPerBin = binSize*samplingRate;
    for bb = 1:size(procDataFileIDs,1)
        procDataFileID = procDataFileIDs(bb,:);
        load(procDataFileID,'-mat')
        [~,~,fileID] = GetFileInfo_Turner2022(procDataFileID);
        if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
            for dd = 1:length(ScoringResults.fileIDs)
                if strcmp(fileID,ScoringResults.fileIDs{dd,1}) == true
                    allCatLabels = cat(1,allCatLabels,ScoringResults.labels{dd,1});
                end
            end
            for cc = 1:numBins
                if cc == 1
                    diameterBinSamples = ProcData.data.Pupil.zDiameter(1:samplesPerBin);
                else
                    diameterBinSamples = ProcData.data.Pupil.zDiameter((cc - 1)*samplesPerBin + 1:cc*samplesPerBin);
                end
                diameterAllCatMeans = cat(1,diameterAllCatMeans,mean(diameterBinSamples,'omitnan'));
            end
        end
    end
end
% put each mean and scoring label into a cell
minDiameter = floor(min(diameterAllCatMeans) - 0.1);
maxDiameter = ceil(max(diameterAllCatMeans) + 0.1);
stepSize = 0.1;
awakeBins = minDiameter:stepSize:maxDiameter;
cutDown = -8;
cutUp = 6.5;
probBinLabels = cell(length(minDiameter:stepSize:maxDiameter),1);
probBinMeans = cell(length(minDiameter:stepSize:maxDiameter),1);
discBins = discretize(diameterAllCatMeans,awakeBins);
for dd = 1:length(discBins)
    probBinLabels{discBins(dd),1} = cat(1,probBinLabels{discBins(dd),1},{allCatLabels(dd,1)});
    probBinMeans{discBins(dd),1} = cat(1,probBinMeans{discBins(dd),1},{diameterAllCatMeans(dd,1)});
end
% condense the left edges of the histogram bins to -35:1:120
cutDownLabels = {};
cutDownStart = find(awakeBins == cutDown);
for ee = 1:cutDownStart
    for qq = 1:length(probBinLabels{ee,1})
        cutDownLabels = cat(1,cutDownLabels,probBinLabels{ee,1}{qq,1});
    end
end
% condense the right edges of the histogram to -35:1:120
cutUpLabels = [];
cutUpStart = find(awakeBins == cutUp);
for ff = cutUpStart:length(probBinLabels)
    for qq = 1:length(probBinLabels{ff,1})
        cutUpLabels = cat(1,cutUpLabels,probBinLabels{ff,1}{qq,1});
    end
end
% reconstruct array of labels based on new edges
finCatLabels = cat(1,{cutDownLabels},probBinLabels(cutDownStart + 1:cutUpStart - 1),{cutUpLabels});
% strcmp the bins and if the bin is asleep (NREM/REM) set to 0, else set 1
for gg = 1:length(finCatLabels)
    for hh = 1:length(finCatLabels{gg,1})
        if strcmp(finCatLabels{gg,1}{hh,1},'Not Sleep') == true
            awakeProbEvents{gg,1}(hh,1) = 1;
        else
            awakeProbEvents{gg,1}(hh,1) = 0;
        end
    end
end
% strcmp the bins and if the bin is not in NREM (Awake/REM) set to 0, else set 1
for gg = 1:length(finCatLabels)
    for hh = 1:length(finCatLabels{gg,1})
        if strcmp(finCatLabels{gg,1}{hh,1},'NREM Sleep') == true
            nremProbEvents{gg,1}(hh,1) = 1;
        else
            nremProbEvents{gg,1}(hh,1) = 0;
        end
    end
end
% strcmp the bins and if the bin is not in REM (Awake/NREM) set to 0, else set 1
for gg = 1:length(finCatLabels)
    for hh = 1:length(finCatLabels{gg,1})
        if strcmp(finCatLabels{gg,1}{hh,1},'REM Sleep') == true
            remProbEvents{gg,1}(hh,1) = 1;
        else
            remProbEvents{gg,1}(hh,1) = 0;
        end
    end
end
% strcmp the bins and if the bin is not in REM (Awake/NREM) set to 0, else set 1
for gg = 1:length(finCatLabels)
    for hh = 1:length(finCatLabels{gg,1})
        if strcmp(finCatLabels{gg,1}{hh,1},'NREM Sleep') == true || strcmp(finCatLabels{gg,1}{hh,1},'REM Sleep') == true
            asleepProbEvents{gg,1}(hh,1) = 1;
        else
            asleepProbEvents{gg,1}(hh,1) = 0;
        end
    end
end
% take probability of each bin
for ii = 1:length(awakeProbEvents)
    awakeProbPerc(ii,1) = sum(awakeProbEvents{ii,1})/length(awakeProbEvents{ii,1})*100;
    nremProbPerc(ii,1) = sum(nremProbEvents{ii,1})/length(nremProbEvents{ii,1})*100;
    remProbPerc(ii,1) = sum(remProbEvents{ii,1})/length(remProbEvents{ii,1})*100;
    asleepProbPerc(ii,1) = sum(asleepProbEvents{ii,1})/length(asleepProbEvents{ii,1})*100;
end
% save results
Results_SleepProbability.diameterCatMeans = diameterAllCatMeans;
Results_SleepProbability.awakeProbPerc = awakeProbPerc;
Results_SleepProbability.nremProbPerc = nremProbPerc;
Results_SleepProbability.remProbPerc = remProbPerc;
Results_SleepProbability.asleepProbPerc = asleepProbPerc;
% save data
cd([rootFolder delim])
save('Results_SleepProbability.mat','Results_SleepProbability')

end
