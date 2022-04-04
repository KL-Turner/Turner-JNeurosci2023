function [] = CreateModelDataSet_JNeurosci2022(procDataFileIDs)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: Arrange data into a table of most-relevant parameters for model training/classification
%________________________________________________________________________________________________________________________

for a = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(a,:);
    modelDataSetID = [procDataFileID(1:end - 12) 'ModelData.mat'];
    load(procDataFileID)
    %% Create table to send into model
    variableNames = {'maxCortDelta','maxCortBeta','maxCortGamma','maxHippTheta','numWhiskEvents','avgEMG','avgHeartRate'};
    % pre-allocation
    maxCortDelta_column = zeros(180,1);
    maxCortBeta_column = zeros(180,1);
    maxCortGamma_column = zeros(180,1);
    maxHippTheta_column = zeros(180,1);
    numWhiskEvents_column = zeros(180,1);
    numForceEvents_column = zeros(180,1);
    medEMG_column = zeros(180,1);
    avgHeartRate_column = zeros(180,1);
    % extract relevant parameters from each epoch
    for b = 1:length(maxCortDelta_column)
        % Cortical delta
        maxLHcortDelta = mean(cell2mat(ProcData.sleep.parameters.cortical_LH.specDeltaBandPower{b,1}));
        maxRHcortDelta = mean(cell2mat(ProcData.sleep.parameters.cortical_RH.specDeltaBandPower{b,1}));
        if maxLHcortDelta >= maxRHcortDelta
            maxCortDelta_column(b,1) = maxLHcortDelta;
        else
            maxCortDelta_column(b,1) = maxRHcortDelta;
        end
        % Cortical beta
        maxLHcortBeta = mean(cell2mat(ProcData.sleep.parameters.cortical_LH.specBetaBandPower{b,1}));
        maxRHcortBeta = mean(cell2mat(ProcData.sleep.parameters.cortical_RH.specBetaBandPower{b,1}));
        if maxLHcortBeta >= maxRHcortBeta
            maxCortBeta_column(b,1) = maxLHcortBeta;
        else
            maxCortBeta_column(b,1) = maxRHcortBeta;
        end
        % Cortical gamma
        maxLHcortGamma = mean(cell2mat(ProcData.sleep.parameters.cortical_LH.specGammaBandPower{b,1}));
        maxRHcortGamma = mean(cell2mat(ProcData.sleep.parameters.cortical_RH.specGammaBandPower{b,1}));
        if maxLHcortGamma >= maxRHcortGamma
            maxCortGamma_column(b,1) = maxLHcortGamma;
        else
            maxCortGamma_column(b,1) = maxRHcortGamma;
        end
        % Hippocampal theta
        maxHippTheta_column(b,1) = mean(cell2mat(ProcData.sleep.parameters.hippocampus.specThetaBandPower{b,1}));
        % number of binarized whisking events
        numWhiskEvents_column(b,1) = sum(ProcData.sleep.parameters.binWhiskerAngle{b,1});
        % number of binarized force sensor events
        numForceEvents_column(b,1) = sum(ProcData.sleep.parameters.binForceSensor{b,1});
        % average of the log of the EMG profile
        EMG = ProcData.sleep.parameters.EMG{b,1};
        medEMG_column(b,1) = median(EMG);
        % average heart rate
        avgHeartRate_column(b,1) = round(mean(ProcData.sleep.parameters.heartRate{b,1}),1);
    end
    % create table
    paramsTable = table(maxCortDelta_column,maxCortBeta_column,maxCortGamma_column,maxHippTheta_column,numWhiskEvents_column,medEMG_column,avgHeartRate_column,'VariableNames',variableNames);
    save(modelDataSetID,'paramsTable')
end

end
