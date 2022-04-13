function [] = CreateModelDataSet_JNeurosci2022(procDataFileIDs)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Arrange data into a table of most-relevant parameters for model training/classification
%________________________________________________________________________________________________________________________

for a = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(a,:);
    modelDataSetID = [procDataFileID(1:end - 12) 'ModelData.mat'];
    load(procDataFileID)
    % create table to send into model
    variableNames = {'maxCortDelta','maxCortBeta','maxCortGamma','maxHippTheta','numWhiskEvents','avgEMG','avgHeartRate'};
    % pre-allocation
    maxCortDeltaColumn = zeros(180,1);
    maxCortBetaColumn = zeros(180,1);
    maxCortGammaColumn = zeros(180,1);
    maxHippThetaColumn = zeros(180,1);
    numWhiskEventsColumn = zeros(180,1);
    numForceEventsColumn = zeros(180,1);
    medEMGColumn = zeros(180,1);
    avgHeartRateColumn = zeros(180,1);
    % extract relevant parameters from each epoch
    for b = 1:length(maxCortDeltaColumn)
        % cortical delta
        maxLHcortDelta = mean(cell2mat(ProcData.sleep.parameters.cortical_LH.specDeltaBandPower{b,1}));
        maxRHcortDelta = mean(cell2mat(ProcData.sleep.parameters.cortical_RH.specDeltaBandPower{b,1}));
        if maxLHcortDelta >= maxRHcortDelta
            maxCortDeltaColumn(b,1) = maxLHcortDelta;
        else
            maxCortDeltaColumn(b,1) = maxRHcortDelta;
        end
        % cortical beta
        maxLHcortBeta = mean(cell2mat(ProcData.sleep.parameters.cortical_LH.specBetaBandPower{b,1}));
        maxRHcortBeta = mean(cell2mat(ProcData.sleep.parameters.cortical_RH.specBetaBandPower{b,1}));
        if maxLHcortBeta >= maxRHcortBeta
            maxCortBetaColumn(b,1) = maxLHcortBeta;
        else
            maxCortBetaColumn(b,1) = maxRHcortBeta;
        end
        % cortical gamma
        maxLHcortGamma = mean(cell2mat(ProcData.sleep.parameters.cortical_LH.specGammaBandPower{b,1}));
        maxRHcortGamma = mean(cell2mat(ProcData.sleep.parameters.cortical_RH.specGammaBandPower{b,1}));
        if maxLHcortGamma >= maxRHcortGamma
            maxCortGammaColumn(b,1) = maxLHcortGamma;
        else
            maxCortGammaColumn(b,1) = maxRHcortGamma;
        end
        % hippocampal theta
        maxHippThetaColumn(b,1) = mean(cell2mat(ProcData.sleep.parameters.hippocampus.specThetaBandPower{b,1}));
        % number of binarized whisking events
        numWhiskEventsColumn(b,1) = sum(ProcData.sleep.parameters.binWhiskerAngle{b,1});
        % number of binarized force sensor events
        numForceEventsColumn(b,1) = sum(ProcData.sleep.parameters.binForceSensor{b,1});
        % average of the log of the EMG profile
        EMG = ProcData.sleep.parameters.EMG{b,1};
        medEMGColumn(b,1) = median(EMG);
        % average heart rate
        avgHeartRateColumn(b,1) = round(mean(ProcData.sleep.parameters.heartRate{b,1}),1);
    end
    % create table
    paramsTable = table(maxCortDeltaColumn,maxCortBetaColumn,maxCortGammaColumn,maxHippThetaColumn,numWhiskEventsColumn,medEMGColumn,avgHeartRateColumn,'VariableNames',variableNames);
    save(modelDataSetID,'paramsTable')
end

end
