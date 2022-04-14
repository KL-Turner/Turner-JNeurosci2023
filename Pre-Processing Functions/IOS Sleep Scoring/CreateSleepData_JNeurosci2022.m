function [SleepData] = CreateSleepData_JNeurosci2022(startingDirectory,trainingDirectory,baselineDirectory,NREMsleepTime,REMsleepTime,modelName,SleepData)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: This function uses the sleep logicals in each ProcData file to find periods where there are 60 seconds of
%          consecutive ones within the sleep logical (12 or more). If a ProcData file's sleep logical contains one or
%          more of these 60 second periods,each of those bins is gathered from the data and put into the SleepEventData.mat
%          struct along with the file's name.
%________________________________________________________________________________________________________________________

if strcmp(modelName,'Manual') == false
    cd(baselineDirectory)
    % character list of all ProcData files
    procDataFileStruct = dir('*_ProcData.mat');
    procDataFiles = {procDataFileStruct.name}';
    procDataFileIDs = char(procDataFiles);
else
    cd(trainingDirectory)
    % character list of all ProcData files
    procDataFileStruct = dir('*_ProcData.mat');
    procDataFiles = {procDataFileStruct.name}';
    procDataFileIDs = char(procDataFiles);
end
% create NREM sleep scored data structure.
% identify sleep epochs and place in SleepEventData.mat structure
sleepBins = NREMsleepTime/5;
for aa = 1:size(procDataFileIDs,1) % loop through the list of ProcData files
    clearvars -except aa procDataFileIDs sleepBins NREMsleepTime REMsleepTime modelName SleepData startingDirectory
    procDataFileID = procDataFileIDs(aa,:); % pull character string associated with the current file
    load(procDataFileID); % load in procDataFile associated with character string
    [~,~,fileID] = GetFileInfo_JNeurosci2022(procDataFileID); % gather file info
    nremLogical = ProcData.sleep.logicals.(modelName).nremLogical; % logical - ones denote potential sleep epoches (5 second bins)
    targetTime = ones(1,sleepBins); % target time
    sleepIndex = find(conv(nremLogical,targetTime) >= sleepBins) - (sleepBins - 1); % find the periods of time where there are at least 11 more
    % 5 second epochs following. This is not the full list.
    if isempty(sleepIndex) % if sleepIndex is empty,skip this file
        % skip file
    else
        sleepCriteria = (0:(sleepBins - 1)); % this will be used to fix the issue in sleepIndex
        fixedSleepIndex = unique(sleepIndex + sleepCriteria); % sleep Index now has the proper time stamps from sleep logical
        for indexCount = 1:length(fixedSleepIndex) % loop through the length of sleep Index,and pull out associated data
            % cortex
            LH_deltaPower{indexCount,1} = ProcData.sleep.parameters.cortical_LH.deltaBandPower{fixedSleepIndex(indexCount),1};
            RH_deltaPower{indexCount,1} = ProcData.sleep.parameters.cortical_RH.deltaBandPower{fixedSleepIndex(indexCount),1};
            LH_thetaPower{indexCount,1} = ProcData.sleep.parameters.cortical_LH.thetaBandPower{fixedSleepIndex(indexCount),1};
            RH_thetaPower{indexCount,1} = ProcData.sleep.parameters.cortical_RH.thetaBandPower{fixedSleepIndex(indexCount),1};
            LH_alphaPower{indexCount,1} = ProcData.sleep.parameters.cortical_LH.alphaBandPower{fixedSleepIndex(indexCount),1};
            RH_alphaPower{indexCount,1} = ProcData.sleep.parameters.cortical_RH.alphaBandPower{fixedSleepIndex(indexCount),1};
            LH_betaPower{indexCount,1} = ProcData.sleep.parameters.cortical_LH.betaBandPower{fixedSleepIndex(indexCount),1};
            RH_betaPower{indexCount,1} = ProcData.sleep.parameters.cortical_RH.betaBandPower{fixedSleepIndex(indexCount),1};
            LH_gammaPower{indexCount,1} = ProcData.sleep.parameters.cortical_LH.gammaBandPower{fixedSleepIndex(indexCount),1};
            RH_gammaPower{indexCount,1} = ProcData.sleep.parameters.cortical_RH.gammaBandPower{fixedSleepIndex(indexCount),1};
            LH_muaPower{indexCount,1} = ProcData.sleep.parameters.cortical_LH.muaPower{fixedSleepIndex(indexCount),1};
            RH_muaPower{indexCount,1} = ProcData.sleep.parameters.cortical_RH.muaPower{fixedSleepIndex(indexCount),1};
            % hippocampus
            Hip_deltaPower{indexCount,1} = ProcData.sleep.parameters.hippocampus.deltaBandPower{fixedSleepIndex(indexCount),1};
            Hip_thetaPower{indexCount,1} = ProcData.sleep.parameters.hippocampus.thetaBandPower{fixedSleepIndex(indexCount),1};
            Hip_alphaPower{indexCount,1} = ProcData.sleep.parameters.hippocampus.alphaBandPower{fixedSleepIndex(indexCount),1};
            Hip_betaPower{indexCount,1} = ProcData.sleep.parameters.hippocampus.betaBandPower{fixedSleepIndex(indexCount),1};
            Hip_gammaPower{indexCount,1} = ProcData.sleep.parameters.hippocampus.gammaBandPower{fixedSleepIndex(indexCount),1};
            Hip_muaPower{indexCount,1} = ProcData.sleep.parameters.hippocampus.muaPower{fixedSleepIndex(indexCount),1};
            % CBV
            LH_CBV{indexCount,1} = ProcData.sleep.parameters.CBV.LH{fixedSleepIndex(indexCount),1};
            RH_CBV{indexCount,1} = ProcData.sleep.parameters.CBV.RH{fixedSleepIndex(indexCount),1};
            % HbT
            LH_hbtCBV{indexCount,1} = ProcData.sleep.parameters.CBV.hbtLH{fixedSleepIndex(indexCount),1};
            RH_hbtCBV{indexCount,1} = ProcData.sleep.parameters.CBV.hbtRH{fixedSleepIndex(indexCount),1};
            % whiskers, heart rate, LDF
            WhiskerAcceleration{indexCount,1} = ProcData.sleep.parameters.whiskerAcceleration{fixedSleepIndex(indexCount),1};
            HeartRate{indexCount,1} = ProcData.sleep.parameters.heartRate{fixedSleepIndex(indexCount),1};
            DopplerFlow{indexCount,1} = ProcData.sleep.parameters.flow{fixedSleepIndex(indexCount),1};
            BinTimes{indexCount,1} = 5*fixedSleepIndex(indexCount);
        end
        % find if there are numerous sleep periods
        indexBreaks = find(fixedSleepIndex(2:end) - fixedSleepIndex(1:end - 1) > 1);
        % if there is only one period of sleep in this file and not multiple
        if isempty(indexBreaks)
            % LH delta
            matLH_DeltaPower = cell2mat(LH_deltaPower);
            arrayLH_DeltaPower = reshape(matLH_DeltaPower',[1,size(matLH_DeltaPower,2)*size(matLH_DeltaPower,1)]);
            cellLH_DeltaPower = {arrayLH_DeltaPower};
            % RH delta
            matRH_DeltaPower = cell2mat(RH_deltaPower);
            arrayRH_DeltaPower = reshape(matRH_DeltaPower',[1,size(matRH_DeltaPower,2)*size(matRH_DeltaPower,1)]);
            cellRH_DeltaPower = {arrayRH_DeltaPower};
            % LH theta
            matLH_ThetaPower = cell2mat(LH_thetaPower);
            arrayLH_ThetaPower = reshape(matLH_ThetaPower',[1,size(matLH_ThetaPower,2)*size(matLH_ThetaPower,1)]);
            cellLH_ThetaPower = {arrayLH_ThetaPower};
            % RH theta
            matRH_ThetaPower = cell2mat(RH_thetaPower);
            arrayRH_ThetaPower = reshape(matRH_ThetaPower',[1,size(matRH_ThetaPower,2)*size(matRH_ThetaPower,1)]);
            cellRH_ThetaPower = {arrayRH_ThetaPower};
            % LH alpha
            matLH_AlphaPower = cell2mat(LH_alphaPower);
            arrayLH_AlphaPower = reshape(matLH_AlphaPower',[1,size(matLH_AlphaPower,2)*size(matLH_AlphaPower,1)]);
            cellLH_AlphaPower = {arrayLH_AlphaPower};
            % RH alpha
            matRH_AlphaPower = cell2mat(RH_alphaPower);
            arrayRH_AlphaPower = reshape(matRH_AlphaPower',[1,size(matRH_AlphaPower,2)*size(matRH_AlphaPower,1)]);
            cellRH_AlphaPower = {arrayRH_AlphaPower};
            % LH beta
            matLH_BetaPower = cell2mat(LH_betaPower);
            arrayLH_BetaPower = reshape(matLH_BetaPower',[1,size(matLH_BetaPower,2)*size(matLH_BetaPower,1)]);
            cellLH_BetaPower = {arrayLH_BetaPower};
            % RH beta
            matRH_BetaPower = cell2mat(RH_betaPower);
            arrayRH_BetaPower = reshape(matRH_BetaPower',[1,size(matRH_BetaPower,2)*size(matRH_BetaPower,1)]);
            cellRH_BetaPower = {arrayRH_BetaPower};
            % LH gamma
            matLH_GammaPower = cell2mat(LH_gammaPower);
            arrayLH_GammaPower = reshape(matLH_GammaPower',[1,size(matLH_GammaPower,2)*size(matLH_GammaPower,1)]);
            cellLH_GammaPower = {arrayLH_GammaPower};
            % RH gamma
            matRH_GammaPower = cell2mat(RH_gammaPower);
            arrayRH_GammaPower = reshape(matRH_GammaPower',[1,size(matRH_GammaPower,2)*size(matRH_GammaPower,1)]);
            cellRH_GammaPower = {arrayRH_GammaPower};
            % LH MUA
            matLH_MUAPower = cell2mat(LH_muaPower);
            arrayLH_MUAPower = reshape(matLH_MUAPower',[1,size(matLH_MUAPower,2)*size(matLH_MUAPower,1)]);
            cellLH_MUAPower = {arrayLH_MUAPower};
            % RH MUA
            matRH_MUAPower = cell2mat(RH_muaPower);
            arrayRH_MUAPower = reshape(matRH_MUAPower',[1,size(matRH_MUAPower,2)*size(matRH_MUAPower,1)]);
            cellRH_MUAPower = {arrayRH_MUAPower};
            % hip delta
            matHip_DeltaPower = cell2mat(Hip_deltaPower);
            arrayHip_DeltaPower = reshape(matHip_DeltaPower',[1,size(matHip_DeltaPower,2)*size(matHip_DeltaPower,1)]);
            cellHip_DeltaPower = {arrayHip_DeltaPower};
            % hip theta
            matHip_ThetaPower = cell2mat(Hip_thetaPower);
            arrayHip_ThetaPower = reshape(matHip_ThetaPower',[1,size(matHip_ThetaPower,2)*size(matHip_ThetaPower,1)]);
            cellHip_ThetaPower = {arrayHip_ThetaPower};
            % hip alpha
            matHip_AlphaPower = cell2mat(Hip_alphaPower);
            arrayHip_AlphaPower = reshape(matHip_AlphaPower',[1,size(matHip_AlphaPower,2)*size(matHip_AlphaPower,1)]);
            cellHip_AlphaPower = {arrayHip_AlphaPower};
            % hip beta
            matHip_BetaPower = cell2mat(Hip_betaPower);
            arrayHip_BetaPower = reshape(matHip_BetaPower',[1,size(matHip_BetaPower,2)*size(matHip_BetaPower,1)]);
            cellHip_BetaPower = {arrayHip_BetaPower};
            % hip gamma
            matHip_GammaPower = cell2mat(Hip_gammaPower);
            arrayHip_GammaPower = reshape(matHip_GammaPower',[1,size(matHip_GammaPower,2)*size(matHip_GammaPower,1)]);
            cellHip_GammaPower = {arrayHip_GammaPower};
            % hip MUA
            matHip_MUAPower = cell2mat(Hip_muaPower);
            arrayHip_MUAPower = reshape(matHip_MUAPower',[1,size(matHip_MUAPower,2)*size(matHip_MUAPower,1)]);
            cellHip_MUAPower = {arrayHip_MUAPower};
            % whisker acceleration
            for x = 1:length(WhiskerAcceleration)
                targetPoints = size(WhiskerAcceleration{1,1},2);
                if size(WhiskerAcceleration{x,1},2) ~= targetPoints
                    maxLength = size(WhiskerAcceleration{x,1},2);
                    difference = targetPoints - size(WhiskerAcceleration{x,1},2);
                    for y = 1:difference
                        WhiskerAcceleration{x,1}(maxLength + y) = 0;
                    end
                end
            end
            matWhiskerAcceleration = cell2mat(WhiskerAcceleration);
            arrayWhiskerAcceleration = reshape(matWhiskerAcceleration',[1,size(matWhiskerAcceleration,2)*size(matWhiskerAcceleration,1)]);
            cellWhiskerAcceleration = {arrayWhiskerAcceleration};
            % heart rate
            for x = 1:length(HeartRate)
                targetPoints = size(HeartRate{1,1},2);
                if size(HeartRate{x,1},2) ~= targetPoints
                    maxLength = size(HeartRate{x,1},2);
                    difference = targetPoints - size(HeartRate{x,1},2);
                    for y = 1:difference
                        HeartRate{x,1}(maxLength + y) = mean(HeartRate{x,1});
                    end
                end
            end
            matHeartRate = cell2mat(HeartRate);
            arrayHeartRate = reshape(matHeartRate',[1,size(matHeartRate,2)*size(matHeartRate,1)]);
            cellHeartRate = {arrayHeartRate};
            % LH CBV
            matLH_CBV = cell2mat(LH_CBV);
            arrayLH_CBV = reshape(matLH_CBV',[1,size(matLH_CBV,2)*size(matLH_CBV,1)]);
            cellLH_CBV = {arrayLH_CBV};
            % RH CBV
            matRH_CBV = cell2mat(RH_CBV);
            arrayRH_CBV = reshape(matRH_CBV',[1,size(matRH_CBV,2)*size(matRH_CBV,1)]);
            cellRH_CBV = {arrayRH_CBV};
            % LH HbT
            matLH_hbtCBV = cell2mat(LH_hbtCBV);
            arrayLH_hbtCBV = reshape(matLH_hbtCBV',[1,size(matLH_hbtCBV,2)*size(matLH_hbtCBV,1)]);
            cellLH_hbtCBV = {arrayLH_hbtCBV};
            % RH HbT
            matRH_hbtCBV = cell2mat(RH_hbtCBV);
            arrayRH_hbtCBV = reshape(matRH_hbtCBV',[1,size(matRH_hbtCBV,2)*size(matRH_hbtCBV,1)]);
            cellRH_hbtCBV = {arrayRH_hbtCBV};
            % LDF
            matDopplerFlow = cell2mat(DopplerFlow);
            arrayDopplerFlow = reshape(matDopplerFlow',[1,size(matDopplerFlow,2)*size(matDopplerFlow,1)]);
            cellDopplerFlow = {arrayDopplerFlow};
            % bin times
            matBinTimes = cell2mat(BinTimes);
            arrayBinTimes = reshape(matBinTimes',[1,size(matBinTimes,2)*size(matBinTimes,1)]);
            cellBinTimes = {arrayBinTimes};
        else
            count = length(fixedSleepIndex);
            holdIndex = zeros(1,(length(indexBreaks) + 1));
            for indexCounter = 1:length(indexBreaks) + 1
                if indexCounter == 1
                    holdIndex(indexCounter) = indexBreaks(indexCounter);
                elseif indexCounter == length(indexBreaks) + 1
                    holdIndex(indexCounter) = count - indexBreaks(indexCounter - 1);
                else
                    holdIndex(indexCounter)= indexBreaks(indexCounter) - indexBreaks(indexCounter - 1);
                end
            end
            % go through each matrix counter
            splitCounter = 1:length(LH_deltaPower);
            convertedMat2Cell = mat2cell(splitCounter',holdIndex);
            for matCounter = 1:length(convertedMat2Cell)
                % cortex
                mat2CellLH_DeltaPower{matCounter,1} = LH_deltaPower(convertedMat2Cell{matCounter,1});
                mat2CellRH_DeltaPower{matCounter,1} = RH_deltaPower(convertedMat2Cell{matCounter,1});
                mat2CellLH_ThetaPower{matCounter,1} = LH_thetaPower(convertedMat2Cell{matCounter,1});
                mat2CellRH_ThetaPower{matCounter,1} = RH_thetaPower(convertedMat2Cell{matCounter,1});
                mat2CellLH_AlphaPower{matCounter,1} = LH_alphaPower(convertedMat2Cell{matCounter,1});
                mat2CellRH_AlphaPower{matCounter,1} = RH_alphaPower(convertedMat2Cell{matCounter,1});
                mat2CellLH_BetaPower{matCounter,1} = LH_betaPower(convertedMat2Cell{matCounter,1});
                mat2CellRH_BetaPower{matCounter,1} = RH_betaPower(convertedMat2Cell{matCounter,1});
                mat2CellLH_GammaPower{matCounter,1} = LH_gammaPower(convertedMat2Cell{matCounter,1});
                mat2CellRH_GammaPower{matCounter,1} = RH_gammaPower(convertedMat2Cell{matCounter,1});
                mat2CellLH_MUAPower{matCounter,1} = LH_muaPower(convertedMat2Cell{matCounter,1});
                mat2CellRH_MUAPower{matCounter,1} = RH_muaPower(convertedMat2Cell{matCounter,1});
                % hippocampus
                mat2CellHip_DeltaPower{matCounter,1} = Hip_deltaPower(convertedMat2Cell{matCounter,1});
                mat2CellHip_ThetaPower{matCounter,1} = Hip_thetaPower(convertedMat2Cell{matCounter,1});
                mat2CellHip_AlphaPower{matCounter,1} = Hip_alphaPower(convertedMat2Cell{matCounter,1});
                mat2CellHip_BetaPower{matCounter,1} = Hip_betaPower(convertedMat2Cell{matCounter,1});
                mat2CellHip_GammaPower{matCounter,1} = Hip_gammaPower(convertedMat2Cell{matCounter,1});
                mat2CellHip_MUAPower{matCounter,1} = Hip_muaPower(convertedMat2Cell{matCounter,1});
                % CBV
                mat2CellLH_CBV{matCounter,1} = LH_CBV(convertedMat2Cell{matCounter,1});
                mat2CellRH_CBV{matCounter,1} = RH_CBV(convertedMat2Cell{matCounter,1});
                % HbT
                mat2CellLH_hbtCBV{matCounter,1} = LH_hbtCBV(convertedMat2Cell{matCounter,1});
                mat2CellRH_hbtCBV{matCounter,1} = RH_hbtCBV(convertedMat2Cell{matCounter,1});
                % whiskers, heart rate, LDF
                mat2CellWhiskerAcceleration{matCounter,1} = WhiskerAcceleration(convertedMat2Cell{matCounter,1});
                mat2CellHeartRate{matCounter,1} = HeartRate(convertedMat2Cell{matCounter,1});
                mat2CellDopplerFlow{matCounter,1} = DopplerFlow(convertedMat2Cell{matCounter,1});
                mat2CellBinTimes{matCounter,1} = BinTimes(convertedMat2Cell{matCounter,1});
            end
            % go through each cell counter
            for cellCounter = 1:length(mat2CellLH_DeltaPower)
                % LH delta
                matLH_DeltaPower = cell2mat(mat2CellLH_DeltaPower{cellCounter,1});
                arrayLH_DeltaPower = reshape(matLH_DeltaPower',[1,size(matLH_DeltaPower,2)*size(matLH_DeltaPower,1)]);
                cellLH_DeltaPower{cellCounter,1} = arrayLH_DeltaPower;
                % RH delta
                matRH_DeltaPower = cell2mat(mat2CellRH_DeltaPower{cellCounter,1});
                arrayRH_DeltaPower = reshape(matRH_DeltaPower',[1,size(matRH_DeltaPower,2)*size(matRH_DeltaPower,1)]);
                cellRH_DeltaPower{cellCounter,1} = arrayRH_DeltaPower;
                % LH theta
                matLH_ThetaPower = cell2mat(mat2CellLH_ThetaPower{cellCounter,1});
                arrayLH_ThetaPower = reshape(matLH_ThetaPower',[1,size(matLH_ThetaPower,2)*size(matLH_ThetaPower,1)]);
                cellLH_ThetaPower{cellCounter,1} = arrayLH_ThetaPower;
                % RH theta
                matRH_ThetaPower = cell2mat(mat2CellRH_ThetaPower{cellCounter,1});
                arrayRH_ThetaPower = reshape(matRH_ThetaPower',[1,size(matRH_ThetaPower,2)*size(matRH_ThetaPower,1)]);
                cellRH_ThetaPower{cellCounter,1} = arrayRH_ThetaPower;
                % LH alpha
                matLH_AlphaPower = cell2mat(mat2CellLH_AlphaPower{cellCounter,1});
                arrayLH_AlphaPower = reshape(matLH_AlphaPower',[1,size(matLH_AlphaPower,2)*size(matLH_AlphaPower,1)]);
                cellLH_AlphaPower{cellCounter,1} = arrayLH_AlphaPower;
                % RH alpha
                matRH_AlphaPower = cell2mat(mat2CellRH_AlphaPower{cellCounter,1});
                arrayRH_AlphaPower = reshape(matRH_AlphaPower',[1,size(matRH_AlphaPower,2)*size(matRH_AlphaPower,1)]);
                cellRH_AlphaPower{cellCounter,1} = arrayRH_AlphaPower;
                % LH beta
                matLH_BetaPower = cell2mat(mat2CellLH_BetaPower{cellCounter,1});
                arrayLH_BetaPower = reshape(matLH_BetaPower',[1,size(matLH_BetaPower,2)*size(matLH_BetaPower,1)]);
                cellLH_BetaPower{cellCounter,1} = arrayLH_BetaPower;
                % RH beta
                matRH_BetaPower = cell2mat(mat2CellRH_BetaPower{cellCounter,1});
                arrayRH_BetaPower = reshape(matRH_BetaPower',[1,size(matRH_BetaPower,2)*size(matRH_BetaPower,1)]);
                cellRH_BetaPower{cellCounter,1} = arrayRH_BetaPower;
                % LH gamma
                matLH_GammaPower = cell2mat(mat2CellLH_GammaPower{cellCounter,1});
                arrayLH_GammaPower = reshape(matLH_GammaPower',[1,size(matLH_GammaPower,2)*size(matLH_GammaPower,1)]);
                cellLH_GammaPower{cellCounter,1} = arrayLH_GammaPower;
                % RH gamma
                matRH_GammaPower = cell2mat(mat2CellRH_GammaPower{cellCounter,1});
                arrayRH_GammaPower = reshape(matRH_GammaPower',[1,size(matRH_GammaPower,2)*size(matRH_GammaPower,1)]);
                cellRH_GammaPower{cellCounter,1} = arrayRH_GammaPower;
                % LH MUA
                matLH_MUAPower = cell2mat(mat2CellLH_MUAPower{cellCounter,1});
                arrayLH_MUAPower = reshape(matLH_MUAPower',[1,size(matLH_MUAPower,2)*size(matLH_MUAPower,1)]);
                cellLH_MUAPower{cellCounter,1} = arrayLH_MUAPower;
                % RH MUA
                matRH_MUAPower = cell2mat(mat2CellRH_MUAPower{cellCounter,1});
                arrayRH_MUAPower = reshape(matRH_MUAPower',[1,size(matRH_MUAPower,2)*size(matRH_MUAPower,1)]);
                cellRH_MUAPower{cellCounter,1} = arrayRH_MUAPower;
                % hip delta
                matHip_DeltaPower = cell2mat(mat2CellHip_DeltaPower{cellCounter,1});
                arrayHip_DeltaPower = reshape(matHip_DeltaPower',[1,size(matHip_DeltaPower,2)*size(matHip_DeltaPower,1)]);
                cellHip_DeltaPower{cellCounter,1} = arrayHip_DeltaPower;
                % hip theta
                matHip_ThetaPower = cell2mat(mat2CellHip_ThetaPower{cellCounter,1});
                arrayHip_ThetaPower = reshape(matHip_ThetaPower',[1,size(matHip_ThetaPower,2)*size(matHip_ThetaPower,1)]);
                cellHip_ThetaPower{cellCounter,1} = arrayHip_ThetaPower;
                % hip alpha
                matHip_AlphaPower = cell2mat(mat2CellHip_AlphaPower{cellCounter,1});
                arrayHip_AlphaPower = reshape(matHip_AlphaPower',[1,size(matHip_AlphaPower,2)*size(matHip_AlphaPower,1)]);
                cellHip_AlphaPower{cellCounter,1} = arrayHip_AlphaPower;
                % hip beta
                matHip_BetaPower = cell2mat(mat2CellHip_BetaPower{cellCounter,1});
                arrayHip_BetaPower = reshape(matHip_BetaPower',[1,size(matHip_BetaPower,2)*size(matHip_BetaPower,1)]);
                cellHip_BetaPower{cellCounter,1} = arrayHip_BetaPower;
                % hip gamma
                matHip_GammaPower = cell2mat(mat2CellHip_GammaPower{cellCounter,1});
                arrayHip_GammaPower = reshape(matHip_GammaPower',[1,size(matHip_GammaPower,2)*size(matHip_GammaPower,1)]);
                cellHip_GammaPower{cellCounter,1} = arrayHip_GammaPower;
                % hip MUA
                matHip_MUAPower = cell2mat(mat2CellHip_MUAPower{cellCounter,1});
                arrayHip_MUAPower = reshape(matHip_MUAPower',[1,size(matHip_MUAPower,2)*size(matHip_MUAPower,1)]);
                cellHip_MUAPower{cellCounter,1} = arrayHip_MUAPower;
                % LH CBV
                matLH_CBV = cell2mat(mat2CellLH_CBV{cellCounter,1});
                arrayLH_CBV = reshape(matLH_CBV',[1,size(matLH_CBV,2)*size(matLH_CBV,1)]);
                cellLH_CBV{cellCounter,1} = arrayLH_CBV;
                % RH CBV
                matRH_CBV = cell2mat(mat2CellRH_CBV{cellCounter,1});
                arrayRH_CBV = reshape(matRH_CBV',[1,size(matRH_CBV,2)*size(matRH_CBV,1)]);
                cellRH_CBV{cellCounter,1} = arrayRH_CBV;
                % LH HbT
                matLH_hbtCBV = cell2mat(mat2CellLH_hbtCBV{cellCounter,1});
                arrayLH_hbtCBV = reshape(matLH_hbtCBV',[1,size(matLH_hbtCBV,2)*size(matLH_hbtCBV,1)]);
                cellLH_hbtCBV{cellCounter,1} = arrayLH_hbtCBV;
                % RH HbT
                matRH_hbtCBV = cell2mat(mat2CellRH_hbtCBV{cellCounter,1});
                arrayRH_hbtCBV = reshape(matRH_hbtCBV',[1,size(matRH_hbtCBV,2)*size(matRH_hbtCBV,1)]);
                cellRH_hbtCBV{cellCounter,1} = arrayRH_hbtCBV;
                % whisker acceleration
                for x = 1:size(mat2CellWhiskerAcceleration{cellCounter,1},1)
                    targetPoints = size(mat2CellWhiskerAcceleration{cellCounter,1}{1,1},2);
                    if size(mat2CellWhiskerAcceleration{cellCounter,1}{x,1},2) ~= targetPoints
                        maxLength = size(mat2CellWhiskerAcceleration{cellCounter,1}{x,1},2);
                        difference = targetPoints - size(mat2CellWhiskerAcceleration{cellCounter,1}{x,1},2);
                        for y = 1:difference
                            mat2CellWhiskerAcceleration{cellCounter,1}{x,1}(maxLength + y) = 0;
                        end
                    end
                end
                matWhiskerAcceleration = cell2mat(mat2CellWhiskerAcceleration{cellCounter,1});
                arrayWhiskerAcceleration = reshape(matWhiskerAcceleration',[1,size(matWhiskerAcceleration,2)*size(matWhiskerAcceleration,1)]);
                cellWhiskerAcceleration{cellCounter,1} = arrayWhiskerAcceleration;
                % heart rate
                for x = 1:size(mat2CellHeartRate{cellCounter,1},1)
                    targetPoints = size(mat2CellHeartRate{cellCounter,1}{1,1},2);
                    if size(mat2CellHeartRate{cellCounter,1}{x,1},2) ~= targetPoints
                        maxLength = size(mat2CellHeartRate{cellCounter,1}{x,1},2);
                        difference = targetPoints - size(mat2CellHeartRate{cellCounter,1}{x,1},2);
                        for y = 1:difference
                            mat2CellHeartRate{cellCounter,1}{x,1}(maxLength + y) = mean(mat2CellHeartRate{cellCounter,1}{x,1});
                        end
                    end
                end
                matHeartRate = cell2mat(mat2CellHeartRate{cellCounter,1});
                arrayHeartRate = reshape(matHeartRate',[1,size(matHeartRate,2)*size(matHeartRate,1)]);
                cellHeartRate{cellCounter,1} = arrayHeartRate;
                % LDF
                matDopplerFlow = cell2mat(mat2CellDopplerFlow{cellCounter,1});
                arrayDopplerFlow = reshape(matDopplerFlow',[1,size(matDopplerFlow,2)*size(matDopplerFlow,1)]);
                cellDopplerFlow{cellCounter,1} = arrayDopplerFlow;
                % bin times
                matBinTimes = cell2mat(mat2CellBinTimes{cellCounter,1});
                arrayBinTimes = reshape(matBinTimes',[1,size(matBinTimes,2)*size(matBinTimes,1)]);
                cellBinTimes{cellCounter,1} = arrayBinTimes;
            end
        end
        % save the data in the SleepEventData struct
        if isfield(SleepData,(modelName)) == false % if the structure is empty we need a special case to format the struct properly
            for cellLength = 1:size(cellLH_DeltaPower,2) % loop through however many sleep epochs this file has
                % cortex
                SleepData.(modelName).NREM.data.cortical_LH.deltaBandPower{cellLength,1} = cellLH_DeltaPower{1,1};
                SleepData.(modelName).NREM.data.cortical_RH.deltaBandPower{cellLength,1} = cellRH_DeltaPower{1,1};
                SleepData.(modelName).NREM.data.cortical_LH.thetaBandPower{cellLength,1} = cellLH_ThetaPower{1,1};
                SleepData.(modelName).NREM.data.cortical_RH.thetaBandPower{cellLength,1} = cellRH_ThetaPower{1,1};
                SleepData.(modelName).NREM.data.cortical_LH.alphaBandPower{cellLength,1} = cellLH_AlphaPower{1,1};
                SleepData.(modelName).NREM.data.cortical_RH.alphaBandPower{cellLength,1} = cellRH_AlphaPower{1,1};
                SleepData.(modelName).NREM.data.cortical_LH.betaBandPower{cellLength,1} = cellLH_BetaPower{1,1};
                SleepData.(modelName).NREM.data.cortical_RH.betaBandPower{cellLength,1} = cellRH_BetaPower{1,1};
                SleepData.(modelName).NREM.data.cortical_LH.gammaBandPower{cellLength,1} = cellLH_GammaPower{1,1};
                SleepData.(modelName).NREM.data.cortical_RH.gammaBandPower{cellLength,1} = cellRH_GammaPower{1,1};
                SleepData.(modelName).NREM.data.cortical_LH.muaPower{cellLength,1} = cellLH_MUAPower{1,1};
                SleepData.(modelName).NREM.data.cortical_RH.muaPower{cellLength,1} = cellRH_MUAPower{1,1};
                % hippocampus
                SleepData.(modelName).NREM.data.hippocampus.deltaBandPower{cellLength,1} = cellHip_DeltaPower{1,1};
                SleepData.(modelName).NREM.data.hippocampus.thetaBandPower{cellLength,1} = cellHip_ThetaPower{1,1};
                SleepData.(modelName).NREM.data.hippocampus.alphaBandPower{cellLength,1} = cellHip_AlphaPower{1,1};
                SleepData.(modelName).NREM.data.hippocampus.betaBandPower{cellLength,1} = cellHip_BetaPower{1,1};
                SleepData.(modelName).NREM.data.hippocampus.gammaBandPower{cellLength,1} = cellHip_GammaPower{1,1};
                SleepData.(modelName).NREM.data.hippocampus.muaPower{cellLength,1} = cellHip_MUAPower{1,1};
                % CBV
                SleepData.(modelName).NREM.data.CBV.LH{cellLength,1} = cellLH_CBV{1,1};
                SleepData.(modelName).NREM.data.CBV.RH{cellLength,1} = cellRH_CBV{1,1};
                % HbT
                SleepData.(modelName).NREM.data.CBV_HbT.LH{cellLength,1} = cellLH_hbtCBV{1,1};
                SleepData.(modelName).NREM.data.CBV_HbT.RH{cellLength,1} = cellRH_hbtCBV{1,1};
                % whiskers, heart rate, LDF
                SleepData.(modelName).NREM.data.WhiskerAcceleration{cellLength,1} = cellWhiskerAcceleration{1,1};
                SleepData.(modelName).NREM.data.HeartRate{cellLength,1} = cellHeartRate{1,1};
                SleepData.(modelName).NREM.data.DopplerFlow{cellLength,1} = cellDopplerFlow{1,1};
                SleepData.(modelName).NREM.FileIDs{cellLength,1} = fileID;
                SleepData.(modelName).NREM.BinTimes{cellLength,1} = cellBinTimes{1,1};
            end
        else % if the struct is not empty,add each new iteration after previous data
            for cellLength = 1:size(cellLH_DeltaPower,1) % loop through however many sleep epochs this file has
                % cortex
                SleepData.(modelName).NREM.data.cortical_LH.deltaBandPower{size(SleepData.(modelName).NREM.data.cortical_LH.deltaBandPower,1) + 1,1} = cellLH_DeltaPower{cellLength,1};
                SleepData.(modelName).NREM.data.cortical_RH.deltaBandPower{size(SleepData.(modelName).NREM.data.cortical_RH.deltaBandPower,1) + 1,1} = cellRH_DeltaPower{cellLength,1};
                SleepData.(modelName).NREM.data.cortical_LH.thetaBandPower{size(SleepData.(modelName).NREM.data.cortical_LH.thetaBandPower,1) + 1,1} = cellLH_ThetaPower{cellLength,1};
                SleepData.(modelName).NREM.data.cortical_RH.thetaBandPower{size(SleepData.(modelName).NREM.data.cortical_RH.thetaBandPower,1) + 1,1} = cellRH_ThetaPower{cellLength,1};
                SleepData.(modelName).NREM.data.cortical_LH.alphaBandPower{size(SleepData.(modelName).NREM.data.cortical_LH.alphaBandPower,1) + 1,1} = cellLH_AlphaPower{cellLength,1};
                SleepData.(modelName).NREM.data.cortical_RH.alphaBandPower{size(SleepData.(modelName).NREM.data.cortical_RH.alphaBandPower,1) + 1,1} = cellRH_AlphaPower{cellLength,1};
                SleepData.(modelName).NREM.data.cortical_LH.betaBandPower{size(SleepData.(modelName).NREM.data.cortical_LH.betaBandPower,1) + 1,1} = cellLH_BetaPower{cellLength,1};
                SleepData.(modelName).NREM.data.cortical_RH.betaBandPower{size(SleepData.(modelName).NREM.data.cortical_RH.betaBandPower,1) + 1,1} = cellRH_BetaPower{cellLength,1};
                SleepData.(modelName).NREM.data.cortical_LH.gammaBandPower{size(SleepData.(modelName).NREM.data.cortical_LH.gammaBandPower,1) + 1,1} = cellLH_GammaPower{cellLength,1};
                SleepData.(modelName).NREM.data.cortical_RH.gammaBandPower{size(SleepData.(modelName).NREM.data.cortical_RH.gammaBandPower,1) + 1,1} = cellRH_GammaPower{cellLength,1};
                SleepData.(modelName).NREM.data.cortical_LH.muaPower{size(SleepData.(modelName).NREM.data.cortical_LH.muaPower,1) + 1,1} = cellLH_MUAPower{cellLength,1};
                SleepData.(modelName).NREM.data.cortical_RH.muaPower{size(SleepData.(modelName).NREM.data.cortical_RH.muaPower,1) + 1,1} = cellRH_MUAPower{cellLength,1};
                % hippocampus
                SleepData.(modelName).NREM.data.hippocampus.deltaBandPower{size(SleepData.(modelName).NREM.data.hippocampus.deltaBandPower,1) + 1,1} = cellHip_DeltaPower{cellLength,1};
                SleepData.(modelName).NREM.data.hippocampus.thetaBandPower{size(SleepData.(modelName).NREM.data.hippocampus.thetaBandPower,1) + 1,1} = cellHip_ThetaPower{cellLength,1};
                SleepData.(modelName).NREM.data.hippocampus.alphaBandPower{size(SleepData.(modelName).NREM.data.hippocampus.alphaBandPower,1) + 1,1} = cellHip_AlphaPower{cellLength,1};
                SleepData.(modelName).NREM.data.hippocampus.betaBandPower{size(SleepData.(modelName).NREM.data.hippocampus.betaBandPower,1) + 1,1} = cellHip_BetaPower{cellLength,1};
                SleepData.(modelName).NREM.data.hippocampus.gammaBandPower{size(SleepData.(modelName).NREM.data.hippocampus.gammaBandPower,1) + 1,1} = cellHip_GammaPower{cellLength,1};
                SleepData.(modelName).NREM.data.hippocampus.muaPower{size(SleepData.(modelName).NREM.data.hippocampus.muaPower,1) + 1,1} = cellHip_MUAPower{cellLength,1};
                % CBV
                SleepData.(modelName).NREM.data.CBV.LH{size(SleepData.(modelName).NREM.data.CBV.LH,1) + 1,1} = cellLH_CBV{cellLength,1};
                SleepData.(modelName).NREM.data.CBV.RH{size(SleepData.(modelName).NREM.data.CBV.RH,1) + 1,1} = cellRH_CBV{cellLength,1};
                % HbT
                SleepData.(modelName).NREM.data.CBV_HbT.LH{size(SleepData.(modelName).NREM.data.CBV_HbT.LH,1) + 1,1} = cellLH_hbtCBV{cellLength,1};
                SleepData.(modelName).NREM.data.CBV_HbT.RH{size(SleepData.(modelName).NREM.data.CBV_HbT.RH,1) + 1,1} = cellRH_hbtCBV{cellLength,1};
                % whiskers, heart rate, LDF
                SleepData.(modelName).NREM.data.WhiskerAcceleration{size(SleepData.(modelName).NREM.data.WhiskerAcceleration,1) + 1,1} = cellWhiskerAcceleration{cellLength,1};
                SleepData.(modelName).NREM.data.HeartRate{size(SleepData.(modelName).NREM.data.HeartRate,1) + 1,1} = cellHeartRate{cellLength,1};
                SleepData.(modelName).NREM.data.DopplerFlow{size(SleepData.(modelName).NREM.data.DopplerFlow,1) + 1,1} = cellDopplerFlow{cellLength,1};
                SleepData.(modelName).NREM.FileIDs{size(SleepData.(modelName).NREM.FileIDs,1) + 1,1} = fileID;
                SleepData.(modelName).NREM.BinTimes{size(SleepData.(modelName).NREM.BinTimes,1) + 1,1} = cellBinTimes{cellLength,1};
            end
        end
    end
    disp(['Adding NREM sleeping epochs from ProcData file ' num2str(aa) ' of ' num2str(size(procDataFileIDs,1)) '...']); disp(' ')
end
% identify REM sleep epochs and place in SleepEventData.mat structure
sleepBins = REMsleepTime/5;
for aa = 1:size(procDataFileIDs,1) % loop through the list of ProcData files
    clearvars -except aa procDataFileIDs sleepBins NREMsleepTime REMsleepTime modelName SleepData startingDirectory
    procDataFileID = procDataFileIDs(aa,:); % pull character string associated with the current file
    load(procDataFileID); % load in procDataFile associated with character string
    [~,~,fileID] = GetFileInfo_JNeurosci2022(procDataFileID); % gather file info
    remLogical = ProcData.sleep.logicals.(modelName).remLogical; % logical - ones denote potential sleep epoches (5 second bins)
    targetTime = ones(1,sleepBins); % target time
    sleepIndex = find(conv(remLogical,targetTime) >= sleepBins) - (sleepBins - 1); % find the periods of time where there are at least 11 more
    % 5 second epochs following. This is not the full list.
    if isempty(sleepIndex) % if sleepIndex is empty,skip this file
        % skip file
    else
        sleepCriteria = (0:(sleepBins - 1)); % this will be used to fix the issue in sleepIndex
        fixedSleepIndex = unique(sleepIndex + sleepCriteria); % sleep Index now has the proper time stamps from sleep logical
        for indexCount = 1:length(fixedSleepIndex) % loop through the length of sleep Index,and pull out associated data
            % cortex
            LH_deltaPower{indexCount,1} = ProcData.sleep.parameters.cortical_LH.deltaBandPower{fixedSleepIndex(indexCount),1};
            RH_deltaPower{indexCount,1} = ProcData.sleep.parameters.cortical_RH.deltaBandPower{fixedSleepIndex(indexCount),1};
            LH_thetaPower{indexCount,1} = ProcData.sleep.parameters.cortical_LH.thetaBandPower{fixedSleepIndex(indexCount),1};
            RH_thetaPower{indexCount,1} = ProcData.sleep.parameters.cortical_RH.thetaBandPower{fixedSleepIndex(indexCount),1};
            LH_alphaPower{indexCount,1} = ProcData.sleep.parameters.cortical_LH.alphaBandPower{fixedSleepIndex(indexCount),1};
            RH_alphaPower{indexCount,1} = ProcData.sleep.parameters.cortical_RH.alphaBandPower{fixedSleepIndex(indexCount),1};
            LH_betaPower{indexCount,1} = ProcData.sleep.parameters.cortical_LH.betaBandPower{fixedSleepIndex(indexCount),1};
            RH_betaPower{indexCount,1} = ProcData.sleep.parameters.cortical_RH.betaBandPower{fixedSleepIndex(indexCount),1};
            LH_gammaPower{indexCount,1} = ProcData.sleep.parameters.cortical_LH.gammaBandPower{fixedSleepIndex(indexCount),1};
            RH_gammaPower{indexCount,1} = ProcData.sleep.parameters.cortical_RH.gammaBandPower{fixedSleepIndex(indexCount),1};
            LH_muaPower{indexCount,1} = ProcData.sleep.parameters.cortical_LH.muaPower{fixedSleepIndex(indexCount),1};
            RH_muaPower{indexCount,1} = ProcData.sleep.parameters.cortical_RH.muaPower{fixedSleepIndex(indexCount),1};
            % hippocampus
            Hip_deltaPower{indexCount,1} = ProcData.sleep.parameters.hippocampus.deltaBandPower{fixedSleepIndex(indexCount),1};
            Hip_thetaPower{indexCount,1} = ProcData.sleep.parameters.hippocampus.thetaBandPower{fixedSleepIndex(indexCount),1};
            Hip_alphaPower{indexCount,1} = ProcData.sleep.parameters.hippocampus.alphaBandPower{fixedSleepIndex(indexCount),1};
            Hip_betaPower{indexCount,1} = ProcData.sleep.parameters.hippocampus.betaBandPower{fixedSleepIndex(indexCount),1};
            Hip_gammaPower{indexCount,1} = ProcData.sleep.parameters.hippocampus.gammaBandPower{fixedSleepIndex(indexCount),1};
            Hip_muaPower{indexCount,1} = ProcData.sleep.parameters.hippocampus.muaPower{fixedSleepIndex(indexCount),1};
            % CBV
            LH_CBV{indexCount,1} = ProcData.sleep.parameters.CBV.LH{fixedSleepIndex(indexCount),1};
            RH_CBV{indexCount,1} = ProcData.sleep.parameters.CBV.RH{fixedSleepIndex(indexCount),1};
            % HbT
            LH_hbtCBV{indexCount,1} = ProcData.sleep.parameters.CBV.hbtLH{fixedSleepIndex(indexCount),1};
            RH_hbtCBV{indexCount,1} = ProcData.sleep.parameters.CBV.hbtRH{fixedSleepIndex(indexCount),1};
            % whiskers, heart rate, LDF
            WhiskerAcceleration{indexCount,1} = ProcData.sleep.parameters.whiskerAcceleration{fixedSleepIndex(indexCount),1};
            HeartRate{indexCount,1} = ProcData.sleep.parameters.heartRate{fixedSleepIndex(indexCount),1};
            DopplerFlow{indexCount,1} = ProcData.sleep.parameters.flow{fixedSleepIndex(indexCount),1};
            BinTimes{indexCount,1} = 5*fixedSleepIndex(indexCount);
        end
        % find if there are numerous sleep periods
        indexBreaks = find(fixedSleepIndex(2:end) - fixedSleepIndex(1:end - 1) > 1);
        % if there is only one period of sleep in this file and not multiple
        if isempty(indexBreaks)
            % LH delta
            matLH_DeltaPower = cell2mat(LH_deltaPower);
            arrayLH_DeltaPower = reshape(matLH_DeltaPower',[1,size(matLH_DeltaPower,2)*size(matLH_DeltaPower,1)]);
            cellLH_DeltaPower = {arrayLH_DeltaPower};
            % RH delta
            matRH_DeltaPower = cell2mat(RH_deltaPower);
            arrayRH_DeltaPower = reshape(matRH_DeltaPower',[1,size(matRH_DeltaPower,2)*size(matRH_DeltaPower,1)]);
            cellRH_DeltaPower = {arrayRH_DeltaPower};
            % LH theta
            matLH_ThetaPower = cell2mat(LH_thetaPower);
            arrayLH_ThetaPower = reshape(matLH_ThetaPower',[1,size(matLH_ThetaPower,2)*size(matLH_ThetaPower,1)]);
            cellLH_ThetaPower = {arrayLH_ThetaPower};
            % RH theta
            matRH_ThetaPower = cell2mat(RH_thetaPower);
            arrayRH_ThetaPower = reshape(matRH_ThetaPower',[1,size(matRH_ThetaPower,2)*size(matRH_ThetaPower,1)]);
            cellRH_ThetaPower = {arrayRH_ThetaPower};
            % LH alpha
            matLH_AlphaPower = cell2mat(LH_alphaPower);
            arrayLH_AlphaPower = reshape(matLH_AlphaPower',[1,size(matLH_AlphaPower,2)*size(matLH_AlphaPower,1)]);
            cellLH_AlphaPower = {arrayLH_AlphaPower};
            % RH alpha
            matRH_AlphaPower = cell2mat(RH_alphaPower);
            arrayRH_AlphaPower = reshape(matRH_AlphaPower',[1,size(matRH_AlphaPower,2)*size(matRH_AlphaPower,1)]);
            cellRH_AlphaPower = {arrayRH_AlphaPower};
            % LH beta
            matLH_BetaPower = cell2mat(LH_betaPower);
            arrayLH_BetaPower = reshape(matLH_BetaPower',[1,size(matLH_BetaPower,2)*size(matLH_BetaPower,1)]);
            cellLH_BetaPower = {arrayLH_BetaPower};
            % RH beta
            matRH_BetaPower = cell2mat(RH_betaPower);
            arrayRH_BetaPower = reshape(matRH_BetaPower',[1,size(matRH_BetaPower,2)*size(matRH_BetaPower,1)]);
            cellRH_BetaPower = {arrayRH_BetaPower};
            % LH gamma
            matLH_GammaPower = cell2mat(LH_gammaPower);
            arrayLH_GammaPower = reshape(matLH_GammaPower',[1,size(matLH_GammaPower,2)*size(matLH_GammaPower,1)]);
            cellLH_GammaPower = {arrayLH_GammaPower};
            % RH gamma
            matRH_GammaPower = cell2mat(RH_gammaPower);
            arrayRH_GammaPower = reshape(matRH_GammaPower',[1,size(matRH_GammaPower,2)*size(matRH_GammaPower,1)]);
            cellRH_GammaPower = {arrayRH_GammaPower};
            % LH MUA
            matLH_MUAPower = cell2mat(LH_muaPower);
            arrayLH_MUAPower = reshape(matLH_MUAPower',[1,size(matLH_MUAPower,2)*size(matLH_MUAPower,1)]);
            cellLH_MUAPower = {arrayLH_MUAPower};
            % RH MUA
            matRH_MUAPower = cell2mat(RH_muaPower);
            arrayRH_MUAPower = reshape(matRH_MUAPower',[1,size(matRH_MUAPower,2)*size(matRH_MUAPower,1)]);
            cellRH_MUAPower = {arrayRH_MUAPower};
            % hip delta
            matHip_DeltaPower = cell2mat(Hip_deltaPower);
            arrayHip_DeltaPower = reshape(matHip_DeltaPower',[1,size(matHip_DeltaPower,2)*size(matHip_DeltaPower,1)]);
            cellHip_DeltaPower = {arrayHip_DeltaPower};
            % hip theta
            matHip_ThetaPower = cell2mat(Hip_thetaPower);
            arrayHip_ThetaPower = reshape(matHip_ThetaPower',[1,size(matHip_ThetaPower,2)*size(matHip_ThetaPower,1)]);
            cellHip_ThetaPower = {arrayHip_ThetaPower};
            % hip alpha
            matHip_AlphaPower = cell2mat(Hip_alphaPower);
            arrayHip_AlphaPower = reshape(matHip_AlphaPower',[1,size(matHip_AlphaPower,2)*size(matHip_AlphaPower,1)]);
            cellHip_AlphaPower = {arrayHip_AlphaPower};
            % hip beta
            matHip_BetaPower = cell2mat(Hip_betaPower);
            arrayHip_BetaPower = reshape(matHip_BetaPower',[1,size(matHip_BetaPower,2)*size(matHip_BetaPower,1)]);
            cellHip_BetaPower = {arrayHip_BetaPower};
            % hip gamma
            matHip_GammaPower = cell2mat(Hip_gammaPower);
            arrayHip_GammaPower = reshape(matHip_GammaPower',[1,size(matHip_GammaPower,2)*size(matHip_GammaPower,1)]);
            cellHip_GammaPower = {arrayHip_GammaPower};
            % hip MUA
            matHip_MUAPower = cell2mat(Hip_muaPower);
            arrayHip_MUAPower = reshape(matHip_MUAPower',[1,size(matHip_MUAPower,2)*size(matHip_MUAPower,1)]);
            cellHip_MUAPower = {arrayHip_MUAPower};
            % whisker acceleration
            for x = 1:length(WhiskerAcceleration)
                targetPoints = size(WhiskerAcceleration{1,1},2);
                if size(WhiskerAcceleration{x,1},2) ~= targetPoints
                    maxLength = size(WhiskerAcceleration{x,1},2);
                    difference = targetPoints - size(WhiskerAcceleration{x,1},2);
                    for y = 1:difference
                        WhiskerAcceleration{x,1}(maxLength + y) = 0;
                    end
                end
            end
            matWhiskerAcceleration = cell2mat(WhiskerAcceleration);
            arrayWhiskerAcceleration = reshape(matWhiskerAcceleration',[1,size(matWhiskerAcceleration,2)*size(matWhiskerAcceleration,1)]);
            cellWhiskerAcceleration = {arrayWhiskerAcceleration};
            % heart rate
            for x = 1:length(HeartRate)
                targetPoints = size(HeartRate{1,1},2);
                if size(HeartRate{x,1},2) ~= targetPoints
                    maxLength = size(HeartRate{x,1},2);
                    difference = targetPoints - size(HeartRate{x,1},2);
                    for y = 1:difference
                        HeartRate{x,1}(maxLength + y) = mean(HeartRate{x,1});
                    end
                end
            end
            matHeartRate = cell2mat(HeartRate);
            arrayHeartRate = reshape(matHeartRate',[1,size(matHeartRate,2)*size(matHeartRate,1)]);
            cellHeartRate = {arrayHeartRate};
            % LH CBV
            matLH_CBV = cell2mat(LH_CBV);
            arrayLH_CBV = reshape(matLH_CBV',[1,size(matLH_CBV,2)*size(matLH_CBV,1)]);
            cellLH_CBV = {arrayLH_CBV};
            % RH CBV
            matRH_CBV = cell2mat(RH_CBV);
            arrayRH_CBV = reshape(matRH_CBV',[1,size(matRH_CBV,2)*size(matRH_CBV,1)]);
            cellRH_CBV = {arrayRH_CBV};
            % LH HbT
            matLH_hbtCBV = cell2mat(LH_hbtCBV);
            arrayLH_hbtCBV = reshape(matLH_hbtCBV',[1,size(matLH_hbtCBV,2)*size(matLH_hbtCBV,1)]);
            cellLH_hbtCBV = {arrayLH_hbtCBV};
            % RH HbT
            matRH_hbtCBV = cell2mat(RH_hbtCBV);
            arrayRH_hbtCBV = reshape(matRH_hbtCBV',[1,size(matRH_hbtCBV,2)*size(matRH_hbtCBV,1)]);
            cellRH_hbtCBV = {arrayRH_hbtCBV};
            % LDF
            matDopplerFlow = cell2mat(DopplerFlow);
            arrayDopplerFlow = reshape(matDopplerFlow',[1,size(matDopplerFlow,2)*size(matDopplerFlow,1)]);
            cellDopplerFlow = {arrayDopplerFlow};
            % bin times
            matBinTimes = cell2mat(BinTimes);
            arrayBinTimes = reshape(matBinTimes',[1,size(matBinTimes,2)*size(matBinTimes,1)]);
            cellBinTimes = {arrayBinTimes};
        else
            count = length(fixedSleepIndex);
            holdIndex = zeros(1,(length(indexBreaks) + 1));
            for indexCounter = 1:length(indexBreaks) + 1
                if indexCounter == 1
                    holdIndex(indexCounter) = indexBreaks(indexCounter);
                elseif indexCounter == length(indexBreaks) + 1
                    holdIndex(indexCounter) = count - indexBreaks(indexCounter - 1);
                else
                    holdIndex(indexCounter)= indexBreaks(indexCounter) - indexBreaks(indexCounter - 1);
                end
            end
            % go through each matrix counter
            splitCounter = 1:length(LH_deltaPower);
            convertedMat2Cell = mat2cell(splitCounter',holdIndex);
            for matCounter = 1:length(convertedMat2Cell)
                % cortex
                mat2CellLH_DeltaPower{matCounter,1} = LH_deltaPower(convertedMat2Cell{matCounter,1});
                mat2CellRH_DeltaPower{matCounter,1} = RH_deltaPower(convertedMat2Cell{matCounter,1});
                mat2CellLH_ThetaPower{matCounter,1} = LH_thetaPower(convertedMat2Cell{matCounter,1});
                mat2CellRH_ThetaPower{matCounter,1} = RH_thetaPower(convertedMat2Cell{matCounter,1});
                mat2CellLH_AlphaPower{matCounter,1} = LH_alphaPower(convertedMat2Cell{matCounter,1});
                mat2CellRH_AlphaPower{matCounter,1} = RH_alphaPower(convertedMat2Cell{matCounter,1});
                mat2CellLH_BetaPower{matCounter,1} = LH_betaPower(convertedMat2Cell{matCounter,1});
                mat2CellRH_BetaPower{matCounter,1} = RH_betaPower(convertedMat2Cell{matCounter,1});
                mat2CellLH_GammaPower{matCounter,1} = LH_gammaPower(convertedMat2Cell{matCounter,1});
                mat2CellRH_GammaPower{matCounter,1} = RH_gammaPower(convertedMat2Cell{matCounter,1});
                mat2CellLH_MUAPower{matCounter,1} = LH_muaPower(convertedMat2Cell{matCounter,1});
                mat2CellRH_MUAPower{matCounter,1} = RH_muaPower(convertedMat2Cell{matCounter,1});
                % hippocampus
                mat2CellHip_DeltaPower{matCounter,1} = Hip_deltaPower(convertedMat2Cell{matCounter,1});
                mat2CellHip_ThetaPower{matCounter,1} = Hip_thetaPower(convertedMat2Cell{matCounter,1});
                mat2CellHip_AlphaPower{matCounter,1} = Hip_alphaPower(convertedMat2Cell{matCounter,1});
                mat2CellHip_BetaPower{matCounter,1} = Hip_betaPower(convertedMat2Cell{matCounter,1});
                mat2CellHip_GammaPower{matCounter,1} = Hip_gammaPower(convertedMat2Cell{matCounter,1});
                mat2CellHip_MUAPower{matCounter,1} = Hip_muaPower(convertedMat2Cell{matCounter,1});
                % CBV
                mat2CellLH_CBV{matCounter,1} = LH_CBV(convertedMat2Cell{matCounter,1});
                mat2CellRH_CBV{matCounter,1} = RH_CBV(convertedMat2Cell{matCounter,1});
                % HbT
                mat2CellLH_hbtCBV{matCounter,1} = LH_hbtCBV(convertedMat2Cell{matCounter,1});
                mat2CellRH_hbtCBV{matCounter,1} = RH_hbtCBV(convertedMat2Cell{matCounter,1});
                % whiskers, heart rate, LDF
                mat2CellWhiskerAcceleration{matCounter,1} = WhiskerAcceleration(convertedMat2Cell{matCounter,1});
                mat2CellHeartRate{matCounter,1} = HeartRate(convertedMat2Cell{matCounter,1});
                mat2CellDopplerFlow{matCounter,1} = DopplerFlow(convertedMat2Cell{matCounter,1});
                mat2CellBinTimes{matCounter,1} = BinTimes(convertedMat2Cell{matCounter,1});
            end
            % go through each cell counter
            for cellCounter = 1:length(mat2CellLH_DeltaPower)
                % LH delta
                matLH_DeltaPower = cell2mat(mat2CellLH_DeltaPower{cellCounter,1});
                arrayLH_DeltaPower = reshape(matLH_DeltaPower',[1,size(matLH_DeltaPower,2)*size(matLH_DeltaPower,1)]);
                cellLH_DeltaPower{cellCounter,1} = arrayLH_DeltaPower;
                % RH delta
                matRH_DeltaPower = cell2mat(mat2CellRH_DeltaPower{cellCounter,1});
                arrayRH_DeltaPower = reshape(matRH_DeltaPower',[1,size(matRH_DeltaPower,2)*size(matRH_DeltaPower,1)]);
                cellRH_DeltaPower{cellCounter,1} = arrayRH_DeltaPower;
                % LH theta
                matLH_ThetaPower = cell2mat(mat2CellLH_ThetaPower{cellCounter,1});
                arrayLH_ThetaPower = reshape(matLH_ThetaPower',[1,size(matLH_ThetaPower,2)*size(matLH_ThetaPower,1)]);
                cellLH_ThetaPower{cellCounter,1} = arrayLH_ThetaPower;
                % RH theta
                matRH_ThetaPower = cell2mat(mat2CellRH_ThetaPower{cellCounter,1});
                arrayRH_ThetaPower = reshape(matRH_ThetaPower',[1,size(matRH_ThetaPower,2)*size(matRH_ThetaPower,1)]);
                cellRH_ThetaPower{cellCounter,1} = arrayRH_ThetaPower;
                % LH alpha
                matLH_AlphaPower = cell2mat(mat2CellLH_AlphaPower{cellCounter,1});
                arrayLH_AlphaPower = reshape(matLH_AlphaPower',[1,size(matLH_AlphaPower,2)*size(matLH_AlphaPower,1)]);
                cellLH_AlphaPower{cellCounter,1} = arrayLH_AlphaPower;
                % RH alpha
                matRH_AlphaPower = cell2mat(mat2CellRH_AlphaPower{cellCounter,1});
                arrayRH_AlphaPower = reshape(matRH_AlphaPower',[1,size(matRH_AlphaPower,2)*size(matRH_AlphaPower,1)]);
                cellRH_AlphaPower{cellCounter,1} = arrayRH_AlphaPower;
                % LH beta
                matLH_BetaPower = cell2mat(mat2CellLH_BetaPower{cellCounter,1});
                arrayLH_BetaPower = reshape(matLH_BetaPower',[1,size(matLH_BetaPower,2)*size(matLH_BetaPower,1)]);
                cellLH_BetaPower{cellCounter,1} = arrayLH_BetaPower;
                % RH beta
                matRH_BetaPower = cell2mat(mat2CellRH_BetaPower{cellCounter,1});
                arrayRH_BetaPower = reshape(matRH_BetaPower',[1,size(matRH_BetaPower,2)*size(matRH_BetaPower,1)]);
                cellRH_BetaPower{cellCounter,1} = arrayRH_BetaPower;
                % LH gamma
                matLH_GammaPower = cell2mat(mat2CellLH_GammaPower{cellCounter,1});
                arrayLH_GammaPower = reshape(matLH_GammaPower',[1,size(matLH_GammaPower,2)*size(matLH_GammaPower,1)]);
                cellLH_GammaPower{cellCounter,1} = arrayLH_GammaPower;
                % RH gamma
                matRH_GammaPower = cell2mat(mat2CellRH_GammaPower{cellCounter,1});
                arrayRH_GammaPower = reshape(matRH_GammaPower',[1,size(matRH_GammaPower,2)*size(matRH_GammaPower,1)]);
                cellRH_GammaPower{cellCounter,1} = arrayRH_GammaPower;
                % LH MUA
                matLH_MUAPower = cell2mat(mat2CellLH_MUAPower{cellCounter,1});
                arrayLH_MUAPower = reshape(matLH_MUAPower',[1,size(matLH_MUAPower,2)*size(matLH_MUAPower,1)]);
                cellLH_MUAPower{cellCounter,1} = arrayLH_MUAPower;
                % RH MUA
                matRH_MUAPower = cell2mat(mat2CellRH_MUAPower{cellCounter,1});
                arrayRH_MUAPower = reshape(matRH_MUAPower',[1,size(matRH_MUAPower,2)*size(matRH_MUAPower,1)]);
                cellRH_MUAPower{cellCounter,1} = arrayRH_MUAPower;
                % hip delta
                matHip_DeltaPower = cell2mat(mat2CellHip_DeltaPower{cellCounter,1});
                arrayHip_DeltaPower = reshape(matHip_DeltaPower',[1,size(matHip_DeltaPower,2)*size(matHip_DeltaPower,1)]);
                cellHip_DeltaPower{cellCounter,1} = arrayHip_DeltaPower;
                % hip theta
                matHip_ThetaPower = cell2mat(mat2CellHip_ThetaPower{cellCounter,1});
                arrayHip_ThetaPower = reshape(matHip_ThetaPower',[1,size(matHip_ThetaPower,2)*size(matHip_ThetaPower,1)]);
                cellHip_ThetaPower{cellCounter,1} = arrayHip_ThetaPower;
                % hip alpha
                matHip_AlphaPower = cell2mat(mat2CellHip_AlphaPower{cellCounter,1});
                arrayHip_AlphaPower = reshape(matHip_AlphaPower',[1,size(matHip_AlphaPower,2)*size(matHip_AlphaPower,1)]);
                cellHip_AlphaPower{cellCounter,1} = arrayHip_AlphaPower;
                % hip beta
                matHip_BetaPower = cell2mat(mat2CellHip_BetaPower{cellCounter,1});
                arrayHip_BetaPower = reshape(matHip_BetaPower',[1,size(matHip_BetaPower,2)*size(matHip_BetaPower,1)]);
                cellHip_BetaPower{cellCounter,1} = arrayHip_BetaPower;
                % hip gamma
                matHip_GammaPower = cell2mat(mat2CellHip_GammaPower{cellCounter,1});
                arrayHip_GammaPower = reshape(matHip_GammaPower',[1,size(matHip_GammaPower,2)*size(matHip_GammaPower,1)]);
                cellHip_GammaPower{cellCounter,1} = arrayHip_GammaPower;
                % hip MUA
                matHip_MUAPower = cell2mat(mat2CellHip_MUAPower{cellCounter,1});
                arrayHip_MUAPower = reshape(matHip_MUAPower',[1,size(matHip_MUAPower,2)*size(matHip_MUAPower,1)]);
                cellHip_MUAPower{cellCounter,1} = arrayHip_MUAPower;
                % LH CBV
                matLH_CBV = cell2mat(mat2CellLH_CBV{cellCounter,1});
                arrayLH_CBV = reshape(matLH_CBV',[1,size(matLH_CBV,2)*size(matLH_CBV,1)]);
                cellLH_CBV{cellCounter,1} = arrayLH_CBV;
                % RH CBV
                matRH_CBV = cell2mat(mat2CellRH_CBV{cellCounter,1});
                arrayRH_CBV = reshape(matRH_CBV',[1,size(matRH_CBV,2)*size(matRH_CBV,1)]);
                cellRH_CBV{cellCounter,1} = arrayRH_CBV;
                % LH HbT
                matLH_hbtCBV = cell2mat(mat2CellLH_hbtCBV{cellCounter,1});
                arrayLH_hbtCBV = reshape(matLH_hbtCBV',[1,size(matLH_hbtCBV,2)*size(matLH_hbtCBV,1)]);
                cellLH_hbtCBV{cellCounter,1} = arrayLH_hbtCBV;
                % RH HbT
                matRH_hbtCBV = cell2mat(mat2CellRH_hbtCBV{cellCounter,1});
                arrayRH_hbtCBV = reshape(matRH_hbtCBV',[1,size(matRH_hbtCBV,2)*size(matRH_hbtCBV,1)]);
                cellRH_hbtCBV{cellCounter,1} = arrayRH_hbtCBV;
                % whisker acceleration
                for x = 1:size(mat2CellWhiskerAcceleration{cellCounter,1},1)
                    targetPoints = size(mat2CellWhiskerAcceleration{cellCounter,1}{1,1},2);
                    if size(mat2CellWhiskerAcceleration{cellCounter,1}{x,1},2) ~= targetPoints
                        maxLength = size(mat2CellWhiskerAcceleration{cellCounter,1}{x,1},2);
                        difference = targetPoints - size(mat2CellWhiskerAcceleration{cellCounter,1}{x,1},2);
                        for y = 1:difference
                            mat2CellWhiskerAcceleration{cellCounter,1}{x,1}(maxLength + y) = 0;
                        end
                    end
                end
                matWhiskerAcceleration = cell2mat(mat2CellWhiskerAcceleration{cellCounter,1});
                arrayWhiskerAcceleration = reshape(matWhiskerAcceleration',[1,size(matWhiskerAcceleration,2)*size(matWhiskerAcceleration,1)]);
                cellWhiskerAcceleration{cellCounter,1} = arrayWhiskerAcceleration;
                % heart rate
                for x = 1:size(mat2CellHeartRate{cellCounter,1},1)
                    targetPoints = size(mat2CellHeartRate{cellCounter,1}{1,1},2);
                    if size(mat2CellHeartRate{cellCounter,1}{x,1},2) ~= targetPoints
                        maxLength = size(mat2CellHeartRate{cellCounter,1}{x,1},2);
                        difference = targetPoints - size(mat2CellHeartRate{cellCounter,1}{x,1},2);
                        for y = 1:difference
                            mat2CellHeartRate{cellCounter,1}{x,1}(maxLength + y) = mean(mat2CellHeartRate{cellCounter,1}{x,1});
                        end
                    end
                end
                matHeartRate = cell2mat(mat2CellHeartRate{cellCounter,1});
                arrayHeartRate = reshape(matHeartRate',[1,size(matHeartRate,2)*size(matHeartRate,1)]);
                cellHeartRate{cellCounter,1} = arrayHeartRate;
                % LDF
                matDopplerFlow = cell2mat(mat2CellDopplerFlow{cellCounter,1});
                arrayDopplerFlow = reshape(matDopplerFlow',[1,size(matDopplerFlow,2)*size(matDopplerFlow,1)]);
                cellDopplerFlow{cellCounter,1} = arrayDopplerFlow;
                % bin times
                matBinTimes = cell2mat(mat2CellBinTimes{cellCounter,1});
                arrayBinTimes = reshape(matBinTimes',[1,size(matBinTimes,2)*size(matBinTimes,1)]);
                cellBinTimes{cellCounter,1} = arrayBinTimes;
            end
        end
        % save the data in the SleepEventData struct
        if isfield(SleepData.(modelName),'REM') == false % if the structure is empty we need a special case to format the struct properly
            for cellLength = 1:size(cellLH_DeltaPower,2) % loop through however many sleep epochs this file has
                % cortex
                SleepData.(modelName).REM.data.cortical_LH.deltaBandPower{cellLength,1} = cellLH_DeltaPower{1,1};
                SleepData.(modelName).REM.data.cortical_RH.deltaBandPower{cellLength,1} = cellRH_DeltaPower{1,1};
                SleepData.(modelName).REM.data.cortical_LH.thetaBandPower{cellLength,1} = cellLH_ThetaPower{1,1};
                SleepData.(modelName).REM.data.cortical_RH.thetaBandPower{cellLength,1} = cellRH_ThetaPower{1,1};
                SleepData.(modelName).REM.data.cortical_LH.alphaBandPower{cellLength,1} = cellLH_AlphaPower{1,1};
                SleepData.(modelName).REM.data.cortical_RH.alphaBandPower{cellLength,1} = cellRH_AlphaPower{1,1};
                SleepData.(modelName).REM.data.cortical_LH.betaBandPower{cellLength,1} = cellLH_BetaPower{1,1};
                SleepData.(modelName).REM.data.cortical_RH.betaBandPower{cellLength,1} = cellRH_BetaPower{1,1};
                SleepData.(modelName).REM.data.cortical_LH.gammaBandPower{cellLength,1} = cellLH_GammaPower{1,1};
                SleepData.(modelName).REM.data.cortical_RH.gammaBandPower{cellLength,1} = cellRH_GammaPower{1,1};
                SleepData.(modelName).REM.data.cortical_LH.muaPower{cellLength,1} = cellLH_MUAPower{1,1};
                SleepData.(modelName).REM.data.cortical_RH.muaPower{cellLength,1} = cellRH_MUAPower{1,1};
                % hippocampus
                SleepData.(modelName).REM.data.hippocampus.deltaBandPower{cellLength,1} = cellHip_DeltaPower{1,1};
                SleepData.(modelName).REM.data.hippocampus.thetaBandPower{cellLength,1} = cellHip_ThetaPower{1,1};
                SleepData.(modelName).REM.data.hippocampus.alphaBandPower{cellLength,1} = cellHip_AlphaPower{1,1};
                SleepData.(modelName).REM.data.hippocampus.betaBandPower{cellLength,1} = cellHip_BetaPower{1,1};
                SleepData.(modelName).REM.data.hippocampus.gammaBandPower{cellLength,1} = cellHip_GammaPower{1,1};
                SleepData.(modelName).REM.data.hippocampus.muaPower{cellLength,1} = cellHip_MUAPower{1,1};
                % CBV
                SleepData.(modelName).REM.data.CBV.LH{cellLength,1} = cellLH_CBV{1,1};
                SleepData.(modelName).REM.data.CBV.RH{cellLength,1} = cellRH_CBV{1,1};
                % HbT
                SleepData.(modelName).REM.data.CBV_HbT.LH{cellLength,1} = cellLH_hbtCBV{1,1};
                SleepData.(modelName).REM.data.CBV_HbT.RH{cellLength,1} = cellRH_hbtCBV{1,1};
                % whiskers, heart rate, LDF
                SleepData.(modelName).REM.data.WhiskerAcceleration{cellLength,1} = cellWhiskerAcceleration{1,1};
                SleepData.(modelName).REM.data.HeartRate{cellLength,1} = cellHeartRate{1,1};
                SleepData.(modelName).REM.data.DopplerFlow{cellLength,1} = cellDopplerFlow{1,1};
                SleepData.(modelName).REM.FileIDs{cellLength,1} = fileID;
                SleepData.(modelName).REM.BinTimes{cellLength,1} = cellBinTimes{1,1};
            end
        else % if the struct is not empty,add each new iteration after previous data
            for cellLength = 1:size(cellLH_DeltaPower,1) % loop through however many sleep epochs this file has
                % cortex
                SleepData.(modelName).REM.data.cortical_LH.deltaBandPower{size(SleepData.(modelName).REM.data.cortical_LH.deltaBandPower,1) + 1,1} = cellLH_DeltaPower{cellLength,1};
                SleepData.(modelName).REM.data.cortical_RH.deltaBandPower{size(SleepData.(modelName).REM.data.cortical_RH.deltaBandPower,1) + 1,1} = cellRH_DeltaPower{cellLength,1};
                SleepData.(modelName).REM.data.cortical_LH.thetaBandPower{size(SleepData.(modelName).REM.data.cortical_LH.thetaBandPower,1) + 1,1} = cellLH_ThetaPower{cellLength,1};
                SleepData.(modelName).REM.data.cortical_RH.thetaBandPower{size(SleepData.(modelName).REM.data.cortical_RH.thetaBandPower,1) + 1,1} = cellRH_ThetaPower{cellLength,1};
                SleepData.(modelName).REM.data.cortical_LH.alphaBandPower{size(SleepData.(modelName).REM.data.cortical_LH.alphaBandPower,1) + 1,1} = cellLH_AlphaPower{cellLength,1};
                SleepData.(modelName).REM.data.cortical_RH.alphaBandPower{size(SleepData.(modelName).REM.data.cortical_RH.alphaBandPower,1) + 1,1} = cellRH_AlphaPower{cellLength,1};
                SleepData.(modelName).REM.data.cortical_LH.betaBandPower{size(SleepData.(modelName).REM.data.cortical_LH.betaBandPower,1) + 1,1} = cellLH_BetaPower{cellLength,1};
                SleepData.(modelName).REM.data.cortical_RH.betaBandPower{size(SleepData.(modelName).REM.data.cortical_RH.betaBandPower,1) + 1,1} = cellRH_BetaPower{cellLength,1};
                SleepData.(modelName).REM.data.cortical_LH.gammaBandPower{size(SleepData.(modelName).REM.data.cortical_LH.gammaBandPower,1) + 1,1} = cellLH_GammaPower{cellLength,1};
                SleepData.(modelName).REM.data.cortical_RH.gammaBandPower{size(SleepData.(modelName).REM.data.cortical_RH.gammaBandPower,1) + 1,1} = cellRH_GammaPower{cellLength,1};
                SleepData.(modelName).REM.data.cortical_LH.muaPower{size(SleepData.(modelName).REM.data.cortical_LH.muaPower,1) + 1,1} = cellLH_MUAPower{cellLength,1};
                SleepData.(modelName).REM.data.cortical_RH.muaPower{size(SleepData.(modelName).REM.data.cortical_RH.muaPower,1) + 1,1} = cellRH_MUAPower{cellLength,1};
                % hippocampus
                SleepData.(modelName).REM.data.hippocampus.deltaBandPower{size(SleepData.(modelName).REM.data.hippocampus.deltaBandPower,1) + 1,1} = cellHip_DeltaPower{cellLength,1};
                SleepData.(modelName).REM.data.hippocampus.thetaBandPower{size(SleepData.(modelName).REM.data.hippocampus.thetaBandPower,1) + 1,1} = cellHip_ThetaPower{cellLength,1};
                SleepData.(modelName).REM.data.hippocampus.alphaBandPower{size(SleepData.(modelName).REM.data.hippocampus.alphaBandPower,1) + 1,1} = cellHip_AlphaPower{cellLength,1};
                SleepData.(modelName).REM.data.hippocampus.betaBandPower{size(SleepData.(modelName).REM.data.hippocampus.betaBandPower,1) + 1,1} = cellHip_BetaPower{cellLength,1};
                SleepData.(modelName).REM.data.hippocampus.gammaBandPower{size(SleepData.(modelName).REM.data.hippocampus.gammaBandPower,1) + 1,1} = cellHip_GammaPower{cellLength,1};
                SleepData.(modelName).REM.data.hippocampus.muaPower{size(SleepData.(modelName).REM.data.hippocampus.muaPower,1) + 1,1} = cellHip_MUAPower{cellLength,1};
                % CBV
                SleepData.(modelName).REM.data.CBV.LH{size(SleepData.(modelName).REM.data.CBV.LH,1) + 1,1} = cellLH_CBV{cellLength,1};
                SleepData.(modelName).REM.data.CBV.RH{size(SleepData.(modelName).REM.data.CBV.RH,1) + 1,1} = cellRH_CBV{cellLength,1};
                % HbT
                SleepData.(modelName).REM.data.CBV_HbT.LH{size(SleepData.(modelName).REM.data.CBV_HbT.LH,1) + 1,1} = cellLH_hbtCBV{cellLength,1};
                SleepData.(modelName).REM.data.CBV_HbT.RH{size(SleepData.(modelName).REM.data.CBV_HbT.RH,1) + 1,1} = cellRH_hbtCBV{cellLength,1};
                % whiskers, heart rate, LDF
                SleepData.(modelName).REM.data.WhiskerAcceleration{size(SleepData.(modelName).REM.data.WhiskerAcceleration,1) + 1,1} = cellWhiskerAcceleration{cellLength,1};
                SleepData.(modelName).REM.data.HeartRate{size(SleepData.(modelName).REM.data.HeartRate,1) + 1,1} = cellHeartRate{cellLength,1};
                SleepData.(modelName).REM.data.DopplerFlow{size(SleepData.(modelName).REM.data.DopplerFlow,1) + 1,1} = cellDopplerFlow{cellLength,1};
                SleepData.(modelName).REM.FileIDs{size(SleepData.(modelName).REM.FileIDs,1) + 1,1} = fileID;
                SleepData.(modelName).REM.BinTimes{size(SleepData.(modelName).REM.BinTimes,1) + 1,1} = cellBinTimes{cellLength,1};
            end
        end
    end
    disp(['Adding REM sleeping epochs from ProcData file ' num2str(aa) ' of ' num2str(size(procDataFileIDs,1)) '...']); disp(' ')
end
% save structure
disp([modelName ' model data added to SleepData structure.']); disp(' ')
cd(startingDirectory)

end
