function [SleepData] = CreateSleepData_JNeurosci2022(startingDirectory,trainingDirectory,baselineDirectory,NREMsleepTime,REMsleepTime,modelName,SleepData)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% Ph.D. Candidate, Department of Bioengineering
% The Pennsylvania State University
%________________________________________________________________________________________________________________________
%
%   Purpose: This function uses the sleep logicals in each ProcData file to find periods where there are 60 seconds of 
%            consecutive ones within the sleep logical (12 or more). If a ProcData file's sleep logical contains one or
%            more of these 60 second periods, each of those bins is gathered from the data and put into the SleepEventData.mat
%            struct along with the file's name. 
%________________________________________________________________________________________________________________________
%
%   Inputs: The function loops through each ProcData file within the current folder - no inputs to the function itself
%           This was done as it was easier to add to the SleepEventData struct instead of loading it and then adding to it
%           with each ProcData loop.
%
%   Outputs: SleepEventData.mat struct
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

%% BLOCK PURPOSE: Create sleep scored data structure.
% Identify sleep epochs and place in SleepEventData.mat structure
sleepBins = NREMsleepTime/5;
for a = 1:size(procDataFileIDs, 1)           % Loop through the list of ProcData files
    procDataFileID = procDataFileIDs(a, :);    % Pull character string associated with the current file
    load(procDataFileID);                             % Load in procDataFile associated with character string
    [~,~,fileID] = GetFileInfo_JNeurosci2022(procDataFileID);     % Gather file info
    
    clear LH_deltaPower RH_deltaPower LH_thetaPower RH_thetaPower LH_alphaPower RH_alphaPower LH_betaPower RH_betaPower LH_gammaPower RH_gammaPower LH_muaPower RH_muaPower Hip_deltaPower Hip_thetaPower Hip_alphaPower Hip_betaPower Hip_gammaPower Hip_muaPower
    clear LH_specDeltaPower RH_specDeltaPower LH_specThetaPower RH_specThetaPower LH_specAlphaPower RH_specAlphaPower LH_specBetaPower RH_specBetaPower LH_specGammaPower RH_specGammaPower Hip_specDeltaPower Hip_specThetaPower Hip_specAlphaPower Hip_specBetaPower Hip_specGammaPower
    clear LH_CBV RH_CBV LH_ElectrodeCBV RH_ElectrodeCBV LH_hbtCBV RH_hbtCBV LH_ElectrodehbtCBV RH_ElectrodehbtCBV BinTimes WhiskerAcceleration HeartRate DopplerFlow
    
    clear cellLH_DeltaPower cellRH_DeltaPower cellLH_ThetaPower cellRH_ThetaPower cellLH_AlphaPower cellRH_AlphaPower cellLH_BetaPower cellRH_BetaPower cellLH_GammaPower cellRH_GammaPower cellLH_MUAPower cellRH_MUAPower cellHip_DeltaPower cellHip_ThetaPower cellHip_AlphaPower cellHip_BetaPower cellHip_GammaPower cellHip_MUAPower
    clear cellLH_specDeltaPower cellRH_specDeltaPower cellLH_specThetaPower cellRH_specThetaPower cellLH_specAlphaPower cellRH_specAlphaPower cellLH_specBetaPower cellRH_specBetaPower cellLH_specGammaPower cellRH_specGammaPower cellHip_specDeltaPower cellHip_specThetaPower cellHip_specAlphaPower cellHip_specBetaPower cellHip_specGammaPower
    clear cellLH_CBV cellRH_CBV cellLH_ElectrodeCBV cellRH_ElectrodeCBV cellLH_hbtCBV cellRH_hbtCBV cellLH_ElectrodehbtCBV cellRH_ElectrodehbtCBV cellBinTimes cellWhiskerAcceleration cellHeartRate cellDopplerFlow
    
    clear mat2CellLH_DeltaPower mat2CellRH_DeltaPower mat2CellLH_ThetaPower mat2CellRH_ThetaPower mat2CellLH_AlphaPower mat2CellRH_AlphaPower mat2CellLH_BetaPower mat2CellRH_BetaPower mat2CellLH_GammaPower mat2CellRH_GammaPower mat2CellLH_MUAPower mat2CellRH_MUAPower mat2CellHip_DeltaPower mat2CellHip_ThetaPower mat2CellHip_AlphaPower mat2CellHip_BetaPower mat2CellHip_GammaPower mat2CellHip_MUAPower
    clear mat2CellLH_specDeltaPower mat2CellRH_specDeltaPower mat2CellLH_specThetaPower mat2CellRH_specThetaPower mat2CellLH_specAlphaPower mat2CellRH_specAlphaPower mat2CellLH_specBetaPower mat2CellRH_specBetaPower mat2CellLH_specGammaPower mat2CellRH_specGammaPower mat2CellHip_specDeltaPower mat2CellHip_specThetaPower mat2CellHip_specAlphaPower mat2CellHip_specBetaPower mat2CellHip_specGammaPower
    clear mat2CellLH_CBV mat2CellRH_CBV mat2CellLH_ElectrodeCBV mat2CellRH_ElectrodeCBV mat2CellLH_hbtCBV mat2CellRH_hbtCBV mat2CellLH_ElectrodehbtCBV mat2CellRH_ElectrodehbtCBV mat2CellBinTimes mat2CellWhiskerAcceleration mat2CellHeartRate mat2CellDopplerFlow
    
    clear matLH_DeltaPower matRH_DeltaPower matLH_ThetaPower matRH_ThetaPower matLH_AlphaPower matRH_AlphaPower matLH_BetaPower matRH_BetaPower matLH_GammaPower matRH_GammaPower matLH_MUAPower matRH_MUAPower matHip_DeltaPower matHip_ThetaPower matHip_AlphaPower matHip_BetaPower matHip_GammaPower matHip_MUAPower
    clear matLH_specDeltaPower matRH_specDeltaPower matLH_specThetaPower matRH_specThetaPower matLH_specAlphaPower matRH_specAlphaPower matLH_specBetaPower matRH_specBetaPower matLH_specGammaPower matRH_specGammaPower matHip_specDeltaPower matHip_specThetaPower matHip_specAlphaPower matHip_specBetaPower matHip_specGammaPower
    clear matLH_CBV matRH_CBV matLH_ElectrodeCBV matRH_ElectrodeCBV matLH_hbtCBV matRH_hbtCBV matLH_ElectrodehbtCBV matRH_ElectrodehbtCBV matBinTimes matWhiskerAcceleration matHeartRate matDopplerFlow
    
    nremLogical = ProcData.sleep.logicals.(modelName).nremLogical;    % Logical - ones denote potential sleep epoches (5 second bins)
    targetTime = ones(1, sleepBins);   % Target time
    sleepIndex = find(conv(nremLogical, targetTime) >= sleepBins) - (sleepBins - 1);   % Find the periods of time where there are at least 11 more
    % 5 second epochs following. This is not the full list.
    if isempty(sleepIndex)  % If sleepIndex is empty, skip this file
        % Skip file
    else
        sleepCriteria = (0:(sleepBins - 1));     % This will be used to fix the issue in sleepIndex
        fixedSleepIndex = unique(sleepIndex + sleepCriteria);   % sleep Index now has the proper time stamps from sleep logical
        for indexCount = 1:length(fixedSleepIndex)    % Loop through the length of sleep Index, and pull out associated data
            % filtered signal bands
            LH_deltaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.deltaBandPower{fixedSleepIndex(indexCount), 1}; %#ok<*AGROW>
            RH_deltaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.deltaBandPower{fixedSleepIndex(indexCount), 1};
            LH_thetaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.thetaBandPower{fixedSleepIndex(indexCount), 1};
            RH_thetaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.thetaBandPower{fixedSleepIndex(indexCount), 1};
            LH_alphaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.alphaBandPower{fixedSleepIndex(indexCount), 1};
            RH_alphaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.alphaBandPower{fixedSleepIndex(indexCount), 1};
            LH_betaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.betaBandPower{fixedSleepIndex(indexCount), 1};
            RH_betaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.betaBandPower{fixedSleepIndex(indexCount), 1};
            LH_gammaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.gammaBandPower{fixedSleepIndex(indexCount), 1};
            RH_gammaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.gammaBandPower{fixedSleepIndex(indexCount), 1};
            LH_muaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.muaPower{fixedSleepIndex(indexCount), 1};
            RH_muaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.muaPower{fixedSleepIndex(indexCount), 1};
            
            Hip_deltaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.deltaBandPower{fixedSleepIndex(indexCount), 1};
            Hip_thetaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.thetaBandPower{fixedSleepIndex(indexCount), 1};
            Hip_alphaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.alphaBandPower{fixedSleepIndex(indexCount), 1};
            Hip_betaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.betaBandPower{fixedSleepIndex(indexCount), 1};
            Hip_gammaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.gammaBandPower{fixedSleepIndex(indexCount), 1};
            Hip_muaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.muaPower{fixedSleepIndex(indexCount), 1};
            
            %             % filtered spectrogram bands
            %             LH_specDeltaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.specDeltaBandPower{fixedSleepIndex(indexCount), 1};
            %             RH_specDeltaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.specDeltaBandPower{fixedSleepIndex(indexCount), 1};
            %             LH_specThetaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.specThetaBandPower{fixedSleepIndex(indexCount), 1};
            %             RH_specThetaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.specThetaBandPower{fixedSleepIndex(indexCount), 1};
            %             LH_specAlphaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.specAlphaBandPower{fixedSleepIndex(indexCount), 1};
            %             RH_specAlphaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.specAlphaBandPower{fixedSleepIndex(indexCount), 1};
            %             LH_specBetaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.specBetaBandPower{fixedSleepIndex(indexCount), 1};
            %             RH_specBetaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.specBetaBandPower{fixedSleepIndex(indexCount), 1};
            %             LH_specGammaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.specGammaBandPower{fixedSleepIndex(indexCount), 1};
            %             RH_specGammaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.specGammaBandPower{fixedSleepIndex(indexCount), 1};
            %
            %             Hip_specDeltaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.specDeltaBandPower{fixedSleepIndex(indexCount), 1};
            %             Hip_specThetaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.specThetaBandPower{fixedSleepIndex(indexCount), 1};
            %             Hip_specAlphaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.specAlphaBandPower{fixedSleepIndex(indexCount), 1};
            %             Hip_specBetaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.specBetaBandPower{fixedSleepIndex(indexCount), 1};
            %             Hip_specGammaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.specGammaBandPower{fixedSleepIndex(indexCount), 1};
            %
            % CBV
            LH_CBV{indexCount, 1} = ProcData.sleep.parameters.CBV.LH{fixedSleepIndex(indexCount), 1};
            RH_CBV{indexCount, 1} = ProcData.sleep.parameters.CBV.RH{fixedSleepIndex(indexCount), 1};
            
            LH_hbtCBV{indexCount, 1} = ProcData.sleep.parameters.CBV.hbtLH{fixedSleepIndex(indexCount), 1};
            RH_hbtCBV{indexCount, 1} = ProcData.sleep.parameters.CBV.hbtRH{fixedSleepIndex(indexCount), 1};
            
            WhiskerAcceleration{indexCount, 1} = ProcData.sleep.parameters.whiskerAcceleration{fixedSleepIndex(indexCount), 1};
            HeartRate{indexCount, 1} = ProcData.sleep.parameters.heartRate{fixedSleepIndex(indexCount), 1};
            DopplerFlow{indexCount,1} = ProcData.sleep.parameters.flow{fixedSleepIndex(indexCount),1};
            BinTimes{indexCount, 1} = 5*fixedSleepIndex(indexCount);
        end
        
        indexBreaks = find(fixedSleepIndex(2:end) - fixedSleepIndex(1:end - 1) > 1);    % Find if there are numerous sleep periods
        
        if isempty(indexBreaks)   % If there is only one period of sleep in this file and not multiple
            % filtered signal bands
            matLH_DeltaPower = cell2mat(LH_deltaPower);
            arrayLH_DeltaPower = reshape(matLH_DeltaPower', [1, size(matLH_DeltaPower, 2)*size(matLH_DeltaPower, 1)]);
            cellLH_DeltaPower = {arrayLH_DeltaPower};
            
            matRH_DeltaPower = cell2mat(RH_deltaPower);
            arrayRH_DeltaPower = reshape(matRH_DeltaPower', [1, size(matRH_DeltaPower, 2)*size(matRH_DeltaPower, 1)]);
            cellRH_DeltaPower = {arrayRH_DeltaPower};
            
            matLH_ThetaPower = cell2mat(LH_thetaPower);
            arrayLH_ThetaPower = reshape(matLH_ThetaPower', [1, size(matLH_ThetaPower, 2)*size(matLH_ThetaPower, 1)]);
            cellLH_ThetaPower = {arrayLH_ThetaPower};
            
            matRH_ThetaPower = cell2mat(RH_thetaPower);
            arrayRH_ThetaPower = reshape(matRH_ThetaPower', [1, size(matRH_ThetaPower, 2)*size(matRH_ThetaPower, 1)]);
            cellRH_ThetaPower = {arrayRH_ThetaPower};
            
            matLH_AlphaPower = cell2mat(LH_alphaPower);
            arrayLH_AlphaPower = reshape(matLH_AlphaPower', [1, size(matLH_AlphaPower, 2)*size(matLH_AlphaPower, 1)]);
            cellLH_AlphaPower = {arrayLH_AlphaPower};
            
            matRH_AlphaPower = cell2mat(RH_alphaPower);
            arrayRH_AlphaPower = reshape(matRH_AlphaPower', [1, size(matRH_AlphaPower, 2)*size(matRH_AlphaPower, 1)]);
            cellRH_AlphaPower = {arrayRH_AlphaPower};
            
            matLH_BetaPower = cell2mat(LH_betaPower);
            arrayLH_BetaPower = reshape(matLH_BetaPower', [1, size(matLH_BetaPower, 2)*size(matLH_BetaPower, 1)]);
            cellLH_BetaPower = {arrayLH_BetaPower};
            
            matRH_BetaPower = cell2mat(RH_betaPower);
            arrayRH_BetaPower = reshape(matRH_BetaPower', [1, size(matRH_BetaPower, 2)*size(matRH_BetaPower, 1)]);
            cellRH_BetaPower = {arrayRH_BetaPower};
            
            matLH_GammaPower = cell2mat(LH_gammaPower);
            arrayLH_GammaPower = reshape(matLH_GammaPower', [1, size(matLH_GammaPower, 2)*size(matLH_GammaPower, 1)]);
            cellLH_GammaPower = {arrayLH_GammaPower};
            
            matRH_GammaPower = cell2mat(RH_gammaPower);
            arrayRH_GammaPower = reshape(matRH_GammaPower', [1, size(matRH_GammaPower, 2)*size(matRH_GammaPower, 1)]);
            cellRH_GammaPower = {arrayRH_GammaPower};
            
            matLH_MUAPower = cell2mat(LH_muaPower);
            arrayLH_MUAPower = reshape(matLH_MUAPower', [1, size(matLH_MUAPower, 2)*size(matLH_MUAPower, 1)]);
            cellLH_MUAPower = {arrayLH_MUAPower};
            
            matRH_MUAPower = cell2mat(RH_muaPower);
            arrayRH_MUAPower = reshape(matRH_MUAPower', [1, size(matRH_MUAPower, 2)*size(matRH_MUAPower, 1)]);
            cellRH_MUAPower = {arrayRH_MUAPower};
            
            matHip_DeltaPower = cell2mat(Hip_deltaPower);
            arrayHip_DeltaPower = reshape(matHip_DeltaPower', [1, size(matHip_DeltaPower, 2)*size(matHip_DeltaPower, 1)]);
            cellHip_DeltaPower = {arrayHip_DeltaPower};
            
            matHip_ThetaPower = cell2mat(Hip_thetaPower);
            arrayHip_ThetaPower = reshape(matHip_ThetaPower', [1, size(matHip_ThetaPower, 2)*size(matHip_ThetaPower, 1)]);
            cellHip_ThetaPower = {arrayHip_ThetaPower};
            
            matHip_AlphaPower = cell2mat(Hip_alphaPower);
            arrayHip_AlphaPower = reshape(matHip_AlphaPower', [1, size(matHip_AlphaPower, 2)*size(matHip_AlphaPower, 1)]);
            cellHip_AlphaPower = {arrayHip_AlphaPower};
            
            matHip_BetaPower = cell2mat(Hip_betaPower);
            arrayHip_BetaPower = reshape(matHip_BetaPower', [1, size(matHip_BetaPower, 2)*size(matHip_BetaPower, 1)]);
            cellHip_BetaPower = {arrayHip_BetaPower};
            
            matHip_GammaPower = cell2mat(Hip_gammaPower);
            arrayHip_GammaPower = reshape(matHip_GammaPower', [1, size(matHip_GammaPower, 2)*size(matHip_GammaPower, 1)]);
            cellHip_GammaPower = {arrayHip_GammaPower};
            
            matHip_MUAPower = cell2mat(Hip_muaPower);
            arrayHip_MUAPower = reshape(matHip_MUAPower', [1, size(matHip_MUAPower, 2)*size(matHip_MUAPower, 1)]);
            cellHip_MUAPower = {arrayHip_MUAPower};
            
            %             % filtered spectrogram bands
            %             matLH_specDeltaPower = cell2mat(str2double(LH_specDeltaPower));
            %             arrayLH_specDeltaPower = reshape(matLH_specDeltaPower', [1, size(matLH_specDeltaPower, 2)*size(matLH_specDeltaPower, 1)]);
            %             cellLH_specDeltaPower = {arrayLH_specDeltaPower};
            %
            %             matRH_specDeltaPower = cell2mat(RH_specDeltaPower);
            %             arrayRH_specDeltaPower = reshape(matRH_specDeltaPower', [1, size(matRH_specDeltaPower, 2)*size(matRH_specDeltaPower, 1)]);
            %             cellRH_specDeltaPower = {arrayRH_specDeltaPower};
            %
            %             matLH_specThetaPower = cell2mat(LH_specThetaPower);
            %             arrayLH_specThetaPower = reshape(matLH_specThetaPower', [1, size(matLH_specThetaPower, 2)*size(matLH_specThetaPower, 1)]);
            %             cellLH_specThetaPower = {arrayLH_specThetaPower};
            %
            %             matRH_specThetaPower = cell2mat(RH_specThetaPower);
            %             arrayRH_specThetaPower = reshape(matRH_specThetaPower', [1, size(matRH_specThetaPower, 2)*size(matRH_specThetaPower, 1)]);
            %             cellRH_specThetaPower = {arrayRH_specThetaPower};
            %
            %             matLH_specAlphaPower = cell2mat(LH_specAlphaPower);
            %             arrayLH_specAlphaPower = reshape(matLH_specAlphaPower', [1, size(matLH_specAlphaPower, 2)*size(matLH_specAlphaPower, 1)]);
            %             cellLH_specAlphaPower = {arrayLH_specAlphaPower};
            %
            %             matRH_specAlphaPower = cell2mat(RH_specAlphaPower);
            %             arrayRH_specAlphaPower = reshape(matRH_specAlphaPower', [1, size(matRH_specAlphaPower, 2)*size(matRH_specAlphaPower, 1)]);
            %             cellRH_specAlphaPower = {arrayRH_specAlphaPower};
            %
            %             matLH_specBetaPower = cell2mat(LH_specBetaPower);
            %             arrayLH_specBetaPower = reshape(matLH_specBetaPower', [1, size(matLH_specBetaPower, 2)*size(matLH_specBetaPower, 1)]);
            %             cellLH_specBetaPower = {arrayLH_specBetaPower};
            %
            %             matRH_specBetaPower = cell2mat(RH_specBetaPower);
            %             arrayRH_specBetaPower = reshape(matRH_specBetaPower', [1, size(matRH_specBetaPower, 2)*size(matRH_specBetaPower, 1)]);
            %             cellRH_specBetaPower = {arrayRH_specBetaPower};
            %
            %             matLH_specGammaPower = cell2mat(LH_specGammaPower);
            %             arrayLH_specGammaPower = reshape(matLH_specGammaPower', [1, size(matLH_specGammaPower, 2)*size(matLH_specGammaPower, 1)]);
            %             cellLH_specGammaPower = {arrayLH_specGammaPower};
            %
            %             matRH_specGammaPower = cell2mat(RH_specGammaPower);
            %             arrayRH_specGammaPower = reshape(matRH_specGammaPower', [1, size(matRH_specGammaPower, 2)*size(matRH_specGammaPower, 1)]);
            %             cellRH_specGammaPower = {arrayRH_specGammaPower};
            %
            %             matHip_specDeltaPower = cell2mat(Hip_specDeltaPower);
            %             arrayHip_specDeltaPower = reshape(matHip_specDeltaPower', [1, size(matHip_specDeltaPower, 2)*size(matHip_specDeltaPower, 1)]);
            %             cellHip_specDeltaPower = {arrayHip_specDeltaPower};
            %
            %             matHip_specThetaPower = cell2mat(Hip_specThetaPower);
            %             arrayHip_specThetaPower = reshape(matHip_specThetaPower', [1, size(matHip_specThetaPower, 2)*size(matHip_specThetaPower, 1)]);
            %             cellHip_specThetaPower = {arrayHip_specThetaPower};
            %
            %             matHip_specAlphaPower = cell2mat(Hip_specAlphaPower);
            %             arrayHip_specAlphaPower = reshape(matHip_specAlphaPower', [1, size(matHip_specAlphaPower, 2)*size(matHip_specAlphaPower, 1)]);
            %             cellHip_specAlphaPower = {arrayHip_specAlphaPower};
            %
            %             matHip_specBetaPower = cell2mat(Hip_specBetaPower);
            %             arrayHip_specBetaPower = reshape(matHip_specBetaPower', [1, size(matHip_specBetaPower, 2)*size(matHip_specBetaPower, 1)]);
            %             cellHip_specBetaPower = {arrayHip_specBetaPower};
            %
            %             matHip_specGammaPower = cell2mat(Hip_specGammaPower);
            %             arrayHip_specGammaPower = reshape(matHip_specGammaPower', [1, size(matHip_specGammaPower, 2)*size(matHip_specGammaPower, 1)]);
            %             cellHip_specGammaPower = {arrayHip_specGammaPower};
            
            % whisker acceleration
            for x = 1:length(WhiskerAcceleration)
                targetPoints = size(WhiskerAcceleration{1, 1}, 2);
                if size(WhiskerAcceleration{x, 1}, 2) ~= targetPoints
                    maxLength = size(WhiskerAcceleration{x, 1}, 2);
                    difference = targetPoints - size(WhiskerAcceleration{x, 1}, 2);
                    for y = 1:difference
                        WhiskerAcceleration{x, 1}(maxLength + y) = 0;
                    end
                end
            end
            
            matWhiskerAcceleration = cell2mat(WhiskerAcceleration);
            arrayWhiskerAcceleration = reshape(matWhiskerAcceleration', [1, size(matWhiskerAcceleration, 2)*size(matWhiskerAcceleration, 1)]);
            cellWhiskerAcceleration = {arrayWhiskerAcceleration};
            
            for x = 1:length(HeartRate)
                targetPoints = size(HeartRate{1, 1}, 2);
                if size(HeartRate{x, 1}, 2) ~= targetPoints
                    maxLength = size(HeartRate{x, 1}, 2);
                    difference = targetPoints - size(HeartRate{x, 1}, 2);
                    for y = 1:difference
                        HeartRate{x, 1}(maxLength + y) = mean(HeartRate{x, 1});
                    end
                end
            end
            
            matHeartRate = cell2mat(HeartRate);
            arrayHeartRate = reshape(matHeartRate', [1, size(matHeartRate, 2)*size(matHeartRate, 1)]);
            cellHeartRate = {arrayHeartRate};
            
            % CBV
            matLH_CBV = cell2mat(LH_CBV);
            arrayLH_CBV = reshape(matLH_CBV', [1, size(matLH_CBV, 2)*size(matLH_CBV, 1)]);
            cellLH_CBV = {arrayLH_CBV};
            
            matRH_CBV = cell2mat(RH_CBV);
            arrayRH_CBV = reshape(matRH_CBV', [1, size(matRH_CBV, 2)*size(matRH_CBV, 1)]);
            cellRH_CBV = {arrayRH_CBV};
            
            % hbt cbv
            matLH_hbtCBV = cell2mat(LH_hbtCBV);
            arrayLH_hbtCBV = reshape(matLH_hbtCBV', [1, size(matLH_hbtCBV, 2)*size(matLH_hbtCBV, 1)]);
            cellLH_hbtCBV = {arrayLH_hbtCBV};
            
            matRH_hbtCBV = cell2mat(RH_hbtCBV);
            arrayRH_hbtCBV = reshape(matRH_hbtCBV', [1, size(matRH_hbtCBV, 2)*size(matRH_hbtCBV, 1)]);
            cellRH_hbtCBV = {arrayRH_hbtCBV};
            
            % Doppler flow
            matDopplerFlow = cell2mat(DopplerFlow);
            arrayDopplerFlow = reshape(matDopplerFlow', [1, size(matDopplerFlow, 2)*size(matDopplerFlow, 1)]);
            cellDopplerFlow = {arrayDopplerFlow};
            
            % bin times
            matBinTimes = cell2mat(BinTimes);
            arrayBinTimes = reshape(matBinTimes', [1, size(matBinTimes, 2)*size(matBinTimes, 1)]);
            cellBinTimes = {arrayBinTimes};
        else
            count = length(fixedSleepIndex);
            holdIndex = zeros(1, (length(indexBreaks) + 1));
            
            for indexCounter = 1:length(indexBreaks) + 1
                if indexCounter == 1
                    holdIndex(indexCounter) = indexBreaks(indexCounter);
                elseif indexCounter == length(indexBreaks) + 1
                    holdIndex(indexCounter) = count - indexBreaks(indexCounter - 1);
                else
                    holdIndex(indexCounter)= indexBreaks(indexCounter) - indexBreaks(indexCounter - 1);
                end
            end
            
            splitCounter = 1:length(LH_deltaPower);
            convertedMat2Cell = mat2cell(splitCounter', holdIndex);
            
            for matCounter = 1:length(convertedMat2Cell)
                mat2CellLH_DeltaPower{matCounter, 1} = LH_deltaPower(convertedMat2Cell{matCounter, 1});
                mat2CellRH_DeltaPower{matCounter, 1} = RH_deltaPower(convertedMat2Cell{matCounter, 1});
                mat2CellLH_ThetaPower{matCounter, 1} = LH_thetaPower(convertedMat2Cell{matCounter, 1});
                mat2CellRH_ThetaPower{matCounter, 1} = RH_thetaPower(convertedMat2Cell{matCounter, 1});
                mat2CellLH_AlphaPower{matCounter, 1} = LH_alphaPower(convertedMat2Cell{matCounter, 1});
                mat2CellRH_AlphaPower{matCounter, 1} = RH_alphaPower(convertedMat2Cell{matCounter, 1});
                mat2CellLH_BetaPower{matCounter, 1} = LH_betaPower(convertedMat2Cell{matCounter, 1});
                mat2CellRH_BetaPower{matCounter, 1} = RH_betaPower(convertedMat2Cell{matCounter, 1});
                mat2CellLH_GammaPower{matCounter, 1} = LH_gammaPower(convertedMat2Cell{matCounter, 1});
                mat2CellRH_GammaPower{matCounter, 1} = RH_gammaPower(convertedMat2Cell{matCounter, 1});
                mat2CellLH_MUAPower{matCounter, 1} = LH_muaPower(convertedMat2Cell{matCounter, 1});
                mat2CellRH_MUAPower{matCounter, 1} = RH_muaPower(convertedMat2Cell{matCounter, 1});
                
                mat2CellHip_DeltaPower{matCounter, 1} = Hip_deltaPower(convertedMat2Cell{matCounter, 1});
                mat2CellHip_ThetaPower{matCounter, 1} = Hip_thetaPower(convertedMat2Cell{matCounter, 1});
                mat2CellHip_AlphaPower{matCounter, 1} = Hip_alphaPower(convertedMat2Cell{matCounter, 1});
                mat2CellHip_BetaPower{matCounter, 1} = Hip_betaPower(convertedMat2Cell{matCounter, 1});
                mat2CellHip_GammaPower{matCounter, 1} = Hip_gammaPower(convertedMat2Cell{matCounter, 1});
                mat2CellHip_MUAPower{matCounter, 1} = Hip_muaPower(convertedMat2Cell{matCounter, 1});
                
                %                 mat2CellLH_specDeltaPower{matCounter, 1} = LH_specDeltaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellRH_specDeltaPower{matCounter, 1} = RH_specDeltaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellLH_specThetaPower{matCounter, 1} = LH_specThetaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellRH_specThetaPower{matCounter, 1} = RH_specThetaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellLH_specAlphaPower{matCounter, 1} = LH_specAlphaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellRH_specAlphaPower{matCounter, 1} = RH_specAlphaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellLH_specBetaPower{matCounter, 1} = LH_specBetaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellRH_specBetaPower{matCounter, 1} = RH_specBetaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellLH_specGammaPower{matCounter, 1} = LH_specGammaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellRH_specGammaPower{matCounter, 1} = RH_specGammaPower(convertedMat2Cell{matCounter, 1});
                %
                %                 mat2CellHip_specDeltaPower{matCounter, 1} = Hip_specDeltaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellHip_specThetaPower{matCounter, 1} = Hip_specThetaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellHip_specAlphaPower{matCounter, 1} = Hip_specAlphaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellHip_specBetaPower{matCounter, 1} = Hip_specBetaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellHip_specGammaPower{matCounter, 1} = Hip_specGammaPower(convertedMat2Cell{matCounter, 1});
                
                mat2CellLH_CBV{matCounter, 1} = LH_CBV(convertedMat2Cell{matCounter, 1});
                mat2CellRH_CBV{matCounter, 1} = RH_CBV(convertedMat2Cell{matCounter, 1});
                
                mat2CellLH_hbtCBV{matCounter, 1} = LH_hbtCBV(convertedMat2Cell{matCounter, 1});
                mat2CellRH_hbtCBV{matCounter, 1} = RH_hbtCBV(convertedMat2Cell{matCounter, 1});
                
                mat2CellWhiskerAcceleration{matCounter, 1} = WhiskerAcceleration(convertedMat2Cell{matCounter, 1});
                mat2CellHeartRate{matCounter, 1} = HeartRate(convertedMat2Cell{matCounter, 1});
                mat2CellDopplerFlow{matCounter, 1} = DopplerFlow(convertedMat2Cell{matCounter, 1});
                mat2CellBinTimes{matCounter, 1} = BinTimes(convertedMat2Cell{matCounter, 1});
            end
            
            for cellCounter = 1:length(mat2CellLH_DeltaPower)
                matLH_DeltaPower = cell2mat(mat2CellLH_DeltaPower{cellCounter, 1});
                arrayLH_DeltaPower = reshape(matLH_DeltaPower', [1, size(matLH_DeltaPower, 2)*size(matLH_DeltaPower, 1)]);
                cellLH_DeltaPower{cellCounter, 1} = arrayLH_DeltaPower;
                
                matRH_DeltaPower = cell2mat(mat2CellRH_DeltaPower{cellCounter, 1});
                arrayRH_DeltaPower = reshape(matRH_DeltaPower', [1, size(matRH_DeltaPower, 2)*size(matRH_DeltaPower, 1)]);
                cellRH_DeltaPower{cellCounter, 1} = arrayRH_DeltaPower;
                
                matLH_ThetaPower = cell2mat(mat2CellLH_ThetaPower{cellCounter, 1});
                arrayLH_ThetaPower = reshape(matLH_ThetaPower', [1, size(matLH_ThetaPower, 2)*size(matLH_ThetaPower, 1)]);
                cellLH_ThetaPower{cellCounter, 1} = arrayLH_ThetaPower;
                
                matRH_ThetaPower = cell2mat(mat2CellRH_ThetaPower{cellCounter, 1});
                arrayRH_ThetaPower = reshape(matRH_ThetaPower', [1, size(matRH_ThetaPower, 2)*size(matRH_ThetaPower, 1)]);
                cellRH_ThetaPower{cellCounter, 1} = arrayRH_ThetaPower;
                
                matLH_AlphaPower = cell2mat(mat2CellLH_AlphaPower{cellCounter, 1});
                arrayLH_AlphaPower = reshape(matLH_AlphaPower', [1, size(matLH_AlphaPower, 2)*size(matLH_AlphaPower, 1)]);
                cellLH_AlphaPower{cellCounter, 1} = arrayLH_AlphaPower;
                
                matRH_AlphaPower = cell2mat(mat2CellRH_AlphaPower{cellCounter, 1});
                arrayRH_AlphaPower = reshape(matRH_AlphaPower', [1, size(matRH_AlphaPower, 2)*size(matRH_AlphaPower, 1)]);
                cellRH_AlphaPower{cellCounter, 1} = arrayRH_AlphaPower;
                
                matLH_BetaPower = cell2mat(mat2CellLH_BetaPower{cellCounter, 1});
                arrayLH_BetaPower = reshape(matLH_BetaPower', [1, size(matLH_BetaPower, 2)*size(matLH_BetaPower, 1)]);
                cellLH_BetaPower{cellCounter, 1} = arrayLH_BetaPower;
                
                matRH_BetaPower = cell2mat(mat2CellRH_BetaPower{cellCounter, 1});
                arrayRH_BetaPower = reshape(matRH_BetaPower', [1, size(matRH_BetaPower, 2)*size(matRH_BetaPower, 1)]);
                cellRH_BetaPower{cellCounter, 1} = arrayRH_BetaPower;
                
                matLH_GammaPower = cell2mat(mat2CellLH_GammaPower{cellCounter, 1});
                arrayLH_GammaPower = reshape(matLH_GammaPower', [1, size(matLH_GammaPower, 2)*size(matLH_GammaPower, 1)]);
                cellLH_GammaPower{cellCounter, 1} = arrayLH_GammaPower;
                
                matRH_GammaPower = cell2mat(mat2CellRH_GammaPower{cellCounter, 1});
                arrayRH_GammaPower = reshape(matRH_GammaPower', [1, size(matRH_GammaPower, 2)*size(matRH_GammaPower, 1)]);
                cellRH_GammaPower{cellCounter, 1} = arrayRH_GammaPower;
                
                matLH_MUAPower = cell2mat(mat2CellLH_MUAPower{cellCounter, 1});
                arrayLH_MUAPower = reshape(matLH_MUAPower', [1, size(matLH_MUAPower, 2)*size(matLH_MUAPower, 1)]);
                cellLH_MUAPower{cellCounter, 1} = arrayLH_MUAPower;
                
                matRH_MUAPower = cell2mat(mat2CellRH_MUAPower{cellCounter, 1});
                arrayRH_MUAPower = reshape(matRH_MUAPower', [1, size(matRH_MUAPower, 2)*size(matRH_MUAPower, 1)]);
                cellRH_MUAPower{cellCounter, 1} = arrayRH_MUAPower;
                
                matHip_DeltaPower = cell2mat(mat2CellHip_DeltaPower{cellCounter, 1});
                arrayHip_DeltaPower = reshape(matHip_DeltaPower', [1, size(matHip_DeltaPower, 2)*size(matHip_DeltaPower, 1)]);
                cellHip_DeltaPower{cellCounter, 1} = arrayHip_DeltaPower;
                
                matHip_ThetaPower = cell2mat(mat2CellHip_ThetaPower{cellCounter, 1});
                arrayHip_ThetaPower = reshape(matHip_ThetaPower', [1, size(matHip_ThetaPower, 2)*size(matHip_ThetaPower, 1)]);
                cellHip_ThetaPower{cellCounter, 1} = arrayHip_ThetaPower;
                
                matHip_AlphaPower = cell2mat(mat2CellHip_AlphaPower{cellCounter, 1});
                arrayHip_AlphaPower = reshape(matHip_AlphaPower', [1, size(matHip_AlphaPower, 2)*size(matHip_AlphaPower, 1)]);
                cellHip_AlphaPower{cellCounter, 1} = arrayHip_AlphaPower;
                
                matHip_BetaPower = cell2mat(mat2CellHip_BetaPower{cellCounter, 1});
                arrayHip_BetaPower = reshape(matHip_BetaPower', [1, size(matHip_BetaPower, 2)*size(matHip_BetaPower, 1)]);
                cellHip_BetaPower{cellCounter, 1} = arrayHip_BetaPower;
                
                matHip_GammaPower = cell2mat(mat2CellHip_GammaPower{cellCounter, 1});
                arrayHip_GammaPower = reshape(matHip_GammaPower', [1, size(matHip_GammaPower, 2)*size(matHip_GammaPower, 1)]);
                cellHip_GammaPower{cellCounter, 1} = arrayHip_GammaPower;
                
                matHip_MUAPower = cell2mat(mat2CellHip_MUAPower{cellCounter, 1});
                arrayHip_MUAPower = reshape(matHip_MUAPower', [1, size(matHip_MUAPower, 2)*size(matHip_MUAPower, 1)]);
                cellHip_MUAPower{cellCounter, 1} = arrayHip_MUAPower;
                
                %                 matLH_specDeltaPower = cell2mat(mat2CellLH_specDeltaPower{cellCounter, 1});
                %                 arrayLH_specDeltaPower = reshape(matLH_specDeltaPower', [1, size(matLH_specDeltaPower, 2)*size(matLH_specDeltaPower, 1)]);
                %                 cellLH_specDeltaPower{cellCounter, 1} = arrayLH_specDeltaPower;
                %
                %                 matRH_specDeltaPower = cell2mat(mat2CellRH_specDeltaPower{cellCounter, 1});
                %                 arrayRH_specDeltaPower = reshape(matRH_specDeltaPower', [1, size(matRH_specDeltaPower, 2)*size(matRH_specDeltaPower, 1)]);
                %                 cellRH_specDeltaPower{cellCounter, 1} = arrayRH_specDeltaPower;
                %
                %                 matLH_specThetaPower = cell2mat(mat2CellLH_specThetaPower{cellCounter, 1});
                %                 arrayLH_specThetaPower = reshape(matLH_specThetaPower', [1, size(matLH_specThetaPower, 2)*size(matLH_specThetaPower, 1)]);
                %                 cellLH_specThetaPower{cellCounter, 1} = arrayLH_specThetaPower;
                %
                %                 matRH_specThetaPower = cell2mat(mat2CellRH_specThetaPower{cellCounter, 1});
                %                 arrayRH_specThetaPower = reshape(matRH_specThetaPower', [1, size(matRH_specThetaPower, 2)*size(matRH_specThetaPower, 1)]);
                %                 cellRH_specThetaPower{cellCounter, 1} = arrayRH_specThetaPower;
                %
                %                 matLH_specAlphaPower = cell2mat(mat2CellLH_specAlphaPower{cellCounter, 1});
                %                 arrayLH_specAlphaPower = reshape(matLH_specAlphaPower', [1, size(matLH_specAlphaPower, 2)*size(matLH_specAlphaPower, 1)]);
                %                 cellLH_specAlphaPower{cellCounter, 1} = arrayLH_specAlphaPower;
                %
                %                 matRH_specAlphaPower = cell2mat(mat2CellRH_specAlphaPower{cellCounter, 1});
                %                 arrayRH_specAlphaPower = reshape(matRH_specAlphaPower', [1, size(matRH_specAlphaPower, 2)*size(matRH_specAlphaPower, 1)]);
                %                 cellRH_specAlphaPower{cellCounter, 1} = arrayRH_specAlphaPower;
                %
                %                 matLH_specBetaPower = cell2mat(mat2CellLH_specBetaPower{cellCounter, 1});
                %                 arrayLH_specBetaPower = reshape(matLH_specBetaPower', [1, size(matLH_specBetaPower, 2)*size(matLH_specBetaPower, 1)]);
                %                 cellLH_specBetaPower{cellCounter, 1} = arrayLH_specBetaPower;
                %
                %                 matRH_specBetaPower = cell2mat(mat2CellRH_specBetaPower{cellCounter, 1});
                %                 arrayRH_specBetaPower = reshape(matRH_specBetaPower', [1, size(matRH_specBetaPower, 2)*size(matRH_specBetaPower, 1)]);
                %                 cellRH_specBetaPower{cellCounter, 1} = arrayRH_specBetaPower;
                %
                %                 matLH_specGammaPower = cell2mat(mat2CellLH_specGammaPower{cellCounter, 1});
                %                 arrayLH_specGammaPower = reshape(matLH_specGammaPower', [1, size(matLH_specGammaPower, 2)*size(matLH_specGammaPower, 1)]);
                %                 cellLH_specGammaPower{cellCounter, 1} = arrayLH_specGammaPower;
                %
                %                 matRH_specGammaPower = cell2mat(mat2CellRH_specGammaPower{cellCounter, 1});
                %                 arrayRH_specGammaPower = reshape(matRH_specGammaPower', [1, size(matRH_specGammaPower, 2)*size(matRH_specGammaPower, 1)]);
                %                 cellRH_specGammaPower{cellCounter, 1} = arrayRH_specGammaPower;
                %
                %                 matHip_specDeltaPower = cell2mat(mat2CellHip_specDeltaPower{cellCounter, 1});
                %                 arrayHip_specDeltaPower = reshape(matHip_specDeltaPower', [1, size(matHip_specDeltaPower, 2)*size(matHip_specDeltaPower, 1)]);
                %                 cellHip_specDeltaPower{cellCounter, 1} = arrayHip_specDeltaPower;
                %
                %                 matHip_specThetaPower = cell2mat(mat2CellHip_specThetaPower{cellCounter, 1});
                %                 arrayHip_specThetaPower = reshape(matHip_specThetaPower', [1, size(matHip_specThetaPower, 2)*size(matHip_specThetaPower, 1)]);
                %                 cellHip_specThetaPower{cellCounter, 1} = arrayHip_specThetaPower;
                %
                %                 matHip_specAlphaPower = cell2mat(mat2CellHip_specAlphaPower{cellCounter, 1});
                %                 arrayHip_specAlphaPower = reshape(matHip_specAlphaPower', [1, size(matHip_specAlphaPower, 2)*size(matHip_specAlphaPower, 1)]);
                %                 cellHip_specAlphaPower{cellCounter, 1} = arrayHip_specAlphaPower;
                %
                %                 matHip_specBetaPower = cell2mat(mat2CellHip_specBetaPower{cellCounter, 1});
                %                 arrayHip_specBetaPower = reshape(matHip_specBetaPower', [1, size(matHip_specBetaPower, 2)*size(matHip_specBetaPower, 1)]);
                %                 cellHip_specBetaPower{cellCounter, 1} = arrayHip_specBetaPower;
                %
                %                 matHip_specGammaPower = cell2mat(mat2CellHip_specGammaPower{cellCounter, 1});
                %                 arrayHip_specGammaPower = reshape(matHip_specGammaPower', [1, size(matHip_specGammaPower, 2)*size(matHip_specGammaPower, 1)]);
                %                 cellHip_specGammaPower{cellCounter, 1} = arrayHip_specGammaPower;
                
                matLH_CBV = cell2mat(mat2CellLH_CBV{cellCounter, 1});
                arrayLH_CBV = reshape(matLH_CBV', [1, size(matLH_CBV, 2)*size(matLH_CBV, 1)]);
                cellLH_CBV{cellCounter, 1} = arrayLH_CBV;
                
                matRH_CBV = cell2mat(mat2CellRH_CBV{cellCounter, 1});
                arrayRH_CBV = reshape(matRH_CBV', [1, size(matRH_CBV, 2)*size(matRH_CBV, 1)]);
                cellRH_CBV{cellCounter, 1} = arrayRH_CBV;
                
                matLH_hbtCBV = cell2mat(mat2CellLH_hbtCBV{cellCounter, 1});
                arrayLH_hbtCBV = reshape(matLH_hbtCBV', [1, size(matLH_hbtCBV, 2)*size(matLH_hbtCBV, 1)]);
                cellLH_hbtCBV{cellCounter, 1} = arrayLH_hbtCBV;
                
                matRH_hbtCBV = cell2mat(mat2CellRH_hbtCBV{cellCounter, 1});
                arrayRH_hbtCBV = reshape(matRH_hbtCBV', [1, size(matRH_hbtCBV, 2)*size(matRH_hbtCBV, 1)]);
                cellRH_hbtCBV{cellCounter, 1} = arrayRH_hbtCBV;
                
                for x = 1:size(mat2CellWhiskerAcceleration{cellCounter, 1}, 1)
                    targetPoints = size(mat2CellWhiskerAcceleration{cellCounter, 1}{1, 1}, 2);
                    if size(mat2CellWhiskerAcceleration{cellCounter, 1}{x, 1}, 2) ~= targetPoints
                        maxLength = size(mat2CellWhiskerAcceleration{cellCounter, 1}{x, 1}, 2);
                        difference = targetPoints - size(mat2CellWhiskerAcceleration{cellCounter, 1}{x, 1}, 2);
                        for y = 1:difference
                            mat2CellWhiskerAcceleration{cellCounter, 1}{x, 1}(maxLength + y) = 0;
                        end
                    end
                end
                
                matWhiskerAcceleration = cell2mat(mat2CellWhiskerAcceleration{cellCounter, 1});
                arrayWhiskerAcceleration = reshape(matWhiskerAcceleration', [1, size(matWhiskerAcceleration, 2)*size(matWhiskerAcceleration, 1)]);
                cellWhiskerAcceleration{cellCounter, 1} = arrayWhiskerAcceleration;
                
                for x = 1:size(mat2CellHeartRate{cellCounter, 1}, 1)
                    targetPoints = size(mat2CellHeartRate{cellCounter, 1}{1, 1}, 2);
                    if size(mat2CellHeartRate{cellCounter, 1}{x, 1}, 2) ~= targetPoints
                        maxLength = size(mat2CellHeartRate{cellCounter, 1}{x, 1}, 2);
                        difference = targetPoints - size(mat2CellHeartRate{cellCounter, 1}{x, 1}, 2);
                        for y = 1:difference
                            mat2CellHeartRate{cellCounter, 1}{x, 1}(maxLength + y) = mean(mat2CellHeartRate{cellCounter, 1}{x, 1});
                        end
                    end
                end
                
                matHeartRate = cell2mat(mat2CellHeartRate{cellCounter, 1});
                arrayHeartRate = reshape(matHeartRate', [1, size(matHeartRate, 2)*size(matHeartRate, 1)]);
                cellHeartRate{cellCounter, 1} = arrayHeartRate;
                
                matDopplerFlow = cell2mat(mat2CellDopplerFlow{cellCounter, 1});
                arrayDopplerFlow = reshape(matDopplerFlow', [1, size(matDopplerFlow, 2)*size(matDopplerFlow, 1)]);
                cellDopplerFlow{cellCounter, 1} = arrayDopplerFlow;
                
                matBinTimes = cell2mat(mat2CellBinTimes{cellCounter, 1});
                arrayBinTimes = reshape(matBinTimes', [1, size(matBinTimes, 2)*size(matBinTimes, 1)]);
                cellBinTimes{cellCounter, 1} = arrayBinTimes;
            end
        end
        
        %% BLOCK PURPOSE: Save the data in the SleepEventData struct
        if isfield(SleepData,(modelName)) == false  % If the structure is empty, we need a special case to format the struct properly
            for cellLength = 1:size(cellLH_DeltaPower, 2)   % Loop through however many sleep epochs this file has
                SleepData.(modelName).NREM.data.cortical_LH.deltaBandPower{cellLength, 1} = cellLH_DeltaPower{1, 1};
                SleepData.(modelName).NREM.data.cortical_RH.deltaBandPower{cellLength, 1} = cellRH_DeltaPower{1, 1};
                SleepData.(modelName).NREM.data.cortical_LH.thetaBandPower{cellLength, 1} = cellLH_ThetaPower{1, 1};
                SleepData.(modelName).NREM.data.cortical_RH.thetaBandPower{cellLength, 1} = cellRH_ThetaPower{1, 1};
                SleepData.(modelName).NREM.data.cortical_LH.alphaBandPower{cellLength, 1} = cellLH_AlphaPower{1, 1};
                SleepData.(modelName).NREM.data.cortical_RH.alphaBandPower{cellLength, 1} = cellRH_AlphaPower{1, 1};
                SleepData.(modelName).NREM.data.cortical_LH.betaBandPower{cellLength, 1} = cellLH_BetaPower{1, 1};
                SleepData.(modelName).NREM.data.cortical_RH.betaBandPower{cellLength, 1} = cellRH_BetaPower{1, 1};
                SleepData.(modelName).NREM.data.cortical_LH.gammaBandPower{cellLength, 1} = cellLH_GammaPower{1, 1};
                SleepData.(modelName).NREM.data.cortical_RH.gammaBandPower{cellLength, 1} = cellRH_GammaPower{1, 1};
                SleepData.(modelName).NREM.data.cortical_LH.muaPower{cellLength, 1} = cellLH_MUAPower{1, 1};
                SleepData.(modelName).NREM.data.cortical_RH.muaPower{cellLength, 1} = cellRH_MUAPower{1, 1};
                
                SleepData.(modelName).NREM.data.hippocampus.deltaBandPower{cellLength, 1} = cellHip_DeltaPower{1, 1};
                SleepData.(modelName).NREM.data.hippocampus.thetaBandPower{cellLength, 1} = cellHip_ThetaPower{1, 1};
                SleepData.(modelName).NREM.data.hippocampus.alphaBandPower{cellLength, 1} = cellHip_AlphaPower{1, 1};
                SleepData.(modelName).NREM.data.hippocampus.betaBandPower{cellLength, 1} = cellHip_BetaPower{1, 1};
                SleepData.(modelName).NREM.data.hippocampus.gammaBandPower{cellLength, 1} = cellHip_GammaPower{1, 1};
                SleepData.(modelName).NREM.data.hippocampus.muaPower{cellLength, 1} = cellHip_MUAPower{1, 1};
                
                %                 SleepData.(modelName).NREM.data.cortical_LH.specDeltaBandPower{cellLength, 1} = cellLH_specDeltaPower{1, 1};
                %                 SleepData.(modelName).NREM.data.cortical_RH.specDeltaBandPower{cellLength, 1} = cellRH_specDeltaPower{1, 1};
                %                 SleepData.(modelName).NREM.data.cortical_LH.specThetaBandPower{cellLength, 1} = cellLH_specThetaPower{1, 1};
                %                 SleepData.(modelName).NREM.data.cortical_RH.specThetaBandPower{cellLength, 1} = cellRH_specThetaPower{1, 1};
                %                 SleepData.(modelName).NREM.data.cortical_LH.specAlphaBandPower{cellLength, 1} = cellLH_specAlphaPower{1, 1};
                %                 SleepData.(modelName).NREM.data.cortical_RH.specAlphaBandPower{cellLength, 1} = cellRH_specAlphaPower{1, 1};
                %                 SleepData.(modelName).NREM.data.cortical_LH.specBetaBandPower{cellLength, 1} = cellLH_specBetaPower{1, 1};
                %                 SleepData.(modelName).NREM.data.cortical_RH.specBetaBandPower{cellLength, 1} = cellRH_specBetaPower{1, 1};
                %                 SleepData.(modelName).NREM.data.cortical_LH.specGammaBandPower{cellLength, 1} = cellLH_specGammaPower{1, 1};
                %                 SleepData.(modelName).NREM.data.cortical_RH.specGammaBandPower{cellLength, 1} = cellRH_specGammaPower{1, 1};
                %
                %                 SleepData.(modelName).NREM.data.hippocampus.specDeltaBandPower{cellLength, 1} = cellHip_specDeltaPower{1, 1};
                %                 SleepData.(modelName).NREM.data.hippocampus.specThetaBandPower{cellLength, 1} = cellHip_specThetaPower{1, 1};
                %                 SleepData.(modelName).NREM.data.hippocampus.specAlphaBandPower{cellLength, 1} = cellHip_specAlphaPower{1, 1};
                %                 SleepData.(modelName).NREM.data.hippocampus.specBetaBandPower{cellLength, 1} = cellHip_specBetaPower{1, 1};
                %                 SleepData.(modelName).NREM.data.hippocampus.specGammaBandPower{cellLength, 1} = cellHip_specGammaPower{1, 1};
                
                SleepData.(modelName).NREM.data.CBV.LH{cellLength, 1} = cellLH_CBV{1, 1};
                SleepData.(modelName).NREM.data.CBV.RH{cellLength, 1} = cellRH_CBV{1, 1};
                
                SleepData.(modelName).NREM.data.CBV_HbT.LH{cellLength, 1} = cellLH_hbtCBV{1, 1};
                SleepData.(modelName).NREM.data.CBV_HbT.RH{cellLength, 1} = cellRH_hbtCBV{1, 1};
                
                SleepData.(modelName).NREM.data.WhiskerAcceleration{cellLength, 1} = cellWhiskerAcceleration{1, 1};
                SleepData.(modelName).NREM.data.HeartRate{cellLength, 1} = cellHeartRate{1, 1};
                SleepData.(modelName).NREM.data.DopplerFlow{cellLength, 1} = cellDopplerFlow{1, 1};
                SleepData.(modelName).NREM.FileIDs{cellLength, 1} = fileID;
                SleepData.(modelName).NREM.BinTimes{cellLength, 1} = cellBinTimes{1, 1};
            end
        else    % If the struct is not empty, add each new iteration after previous data
            for cellLength = 1:size(cellLH_DeltaPower, 1)   % Loop through however many sleep epochs this file has
                SleepData.(modelName).NREM.data.cortical_LH.deltaBandPower{size(SleepData.(modelName).NREM.data.cortical_LH.deltaBandPower, 1) + 1, 1} = cellLH_DeltaPower{cellLength, 1};
                SleepData.(modelName).NREM.data.cortical_RH.deltaBandPower{size(SleepData.(modelName).NREM.data.cortical_RH.deltaBandPower, 1) + 1, 1} = cellRH_DeltaPower{cellLength, 1};
                SleepData.(modelName).NREM.data.cortical_LH.thetaBandPower{size(SleepData.(modelName).NREM.data.cortical_LH.thetaBandPower, 1) + 1, 1} = cellLH_ThetaPower{cellLength, 1};
                SleepData.(modelName).NREM.data.cortical_RH.thetaBandPower{size(SleepData.(modelName).NREM.data.cortical_RH.thetaBandPower, 1) + 1, 1} = cellRH_ThetaPower{cellLength, 1};
                SleepData.(modelName).NREM.data.cortical_LH.alphaBandPower{size(SleepData.(modelName).NREM.data.cortical_LH.alphaBandPower, 1) + 1, 1} = cellLH_AlphaPower{cellLength, 1};
                SleepData.(modelName).NREM.data.cortical_RH.alphaBandPower{size(SleepData.(modelName).NREM.data.cortical_RH.alphaBandPower, 1) + 1, 1} = cellRH_AlphaPower{cellLength, 1};
                SleepData.(modelName).NREM.data.cortical_LH.betaBandPower{size(SleepData.(modelName).NREM.data.cortical_LH.betaBandPower, 1) + 1, 1} = cellLH_BetaPower{cellLength, 1};
                SleepData.(modelName).NREM.data.cortical_RH.betaBandPower{size(SleepData.(modelName).NREM.data.cortical_RH.betaBandPower, 1) + 1, 1} = cellRH_BetaPower{cellLength, 1};
                SleepData.(modelName).NREM.data.cortical_LH.gammaBandPower{size(SleepData.(modelName).NREM.data.cortical_LH.gammaBandPower, 1) + 1, 1} = cellLH_GammaPower{cellLength, 1};
                SleepData.(modelName).NREM.data.cortical_RH.gammaBandPower{size(SleepData.(modelName).NREM.data.cortical_RH.gammaBandPower, 1) + 1, 1} = cellRH_GammaPower{cellLength, 1};
                SleepData.(modelName).NREM.data.cortical_LH.muaPower{size(SleepData.(modelName).NREM.data.cortical_LH.muaPower, 1) + 1, 1} = cellLH_MUAPower{cellLength, 1};
                SleepData.(modelName).NREM.data.cortical_RH.muaPower{size(SleepData.(modelName).NREM.data.cortical_RH.muaPower, 1) + 1, 1} = cellRH_MUAPower{cellLength, 1};
                
                SleepData.(modelName).NREM.data.hippocampus.deltaBandPower{size(SleepData.(modelName).NREM.data.hippocampus.deltaBandPower, 1) + 1, 1} = cellHip_DeltaPower{cellLength, 1};
                SleepData.(modelName).NREM.data.hippocampus.thetaBandPower{size(SleepData.(modelName).NREM.data.hippocampus.thetaBandPower, 1) + 1, 1} = cellHip_ThetaPower{cellLength, 1};
                SleepData.(modelName).NREM.data.hippocampus.alphaBandPower{size(SleepData.(modelName).NREM.data.hippocampus.alphaBandPower, 1) + 1, 1} = cellHip_AlphaPower{cellLength, 1};
                SleepData.(modelName).NREM.data.hippocampus.betaBandPower{size(SleepData.(modelName).NREM.data.hippocampus.betaBandPower, 1) + 1, 1} = cellHip_BetaPower{cellLength, 1};
                SleepData.(modelName).NREM.data.hippocampus.gammaBandPower{size(SleepData.(modelName).NREM.data.hippocampus.gammaBandPower, 1) + 1, 1} = cellHip_GammaPower{cellLength, 1};
                SleepData.(modelName).NREM.data.hippocampus.muaPower{size(SleepData.(modelName).NREM.data.hippocampus.muaPower, 1) + 1, 1} = cellHip_MUAPower{cellLength, 1};
                
                %                 SleepData.(modelName).NREM.data.cortical_LH.specDeltaBandPower{size(SleepData.(modelName).NREM.data.cortical_LH.specDeltaBandPower, 1) + 1, 1} = cellLH_specDeltaPower{cellLength, 1};
                %                 SleepData.(modelName).NREM.data.cortical_RH.specDeltaBandPower{size(SleepData.(modelName).NREM.data.cortical_RH.specDeltaBandPower, 1) + 1, 1} = cellRH_specDeltaPower{cellLength, 1};
                %                 SleepData.(modelName).NREM.data.cortical_LH.specThetaBandPower{size(SleepData.(modelName).NREM.data.cortical_LH.specThetaBandPower, 1) + 1, 1} = cellLH_specThetaPower{cellLength, 1};
                %                 SleepData.(modelName).NREM.data.cortical_RH.specThetaBandPower{size(SleepData.(modelName).NREM.data.cortical_RH.specThetaBandPower, 1) + 1, 1} = cellRH_specThetaPower{cellLength, 1};
                %                 SleepData.(modelName).NREM.data.cortical_LH.specAlphaBandPower{size(SleepData.(modelName).NREM.data.cortical_LH.specAlphaBandPower, 1) + 1, 1} = cellLH_specAlphaPower{cellLength, 1};
                %                 SleepData.(modelName).NREM.data.cortical_RH.specAlphaBandPower{size(SleepData.(modelName).NREM.data.cortical_RH.specAlphaBandPower, 1) + 1, 1} = cellRH_specAlphaPower{cellLength, 1};
                %                 SleepData.(modelName).NREM.data.cortical_LH.specBetaBandPower{size(SleepData.(modelName).NREM.data.cortical_LH.specBetaBandPower, 1) + 1, 1} = cellLH_specBetaPower{cellLength, 1};
                %                 SleepData.(modelName).NREM.data.cortical_RH.specBetaBandPower{size(SleepData.(modelName).NREM.data.cortical_RH.specBetaBandPower, 1) + 1, 1} = cellRH_specBetaPower{cellLength, 1};
                %                 SleepData.(modelName).NREM.data.cortical_LH.specGammaBandPower{size(SleepData.(modelName).NREM.data.cortical_LH.specGammaBandPower, 1) + 1, 1} = cellLH_specGammaPower{cellLength, 1};
                %                 SleepData.(modelName).NREM.data.cortical_RH.specGammaBandPower{size(SleepData.(modelName).NREM.data.cortical_RH.specGammaBandPower, 1) + 1, 1} = cellRH_specGammaPower{cellLength, 1};
                %
                %                 SleepData.(modelName).NREM.data.hippocampus.specDeltaBandPower{size(SleepData.(modelName).NREM.data.hippocampus.specDeltaBandPower, 1) + 1, 1} = cellHip_specDeltaPower{cellLength, 1};
                %                 SleepData.(modelName).NREM.data.hippocampus.specThetaBandPower{size(SleepData.(modelName).NREM.data.hippocampus.specThetaBandPower, 1) + 1, 1} = cellHip_specThetaPower{cellLength, 1};
                %                 SleepData.(modelName).NREM.data.hippocampus.specAlphaBandPower{size(SleepData.(modelName).NREM.data.hippocampus.specAlphaBandPower, 1) + 1, 1} = cellHip_specAlphaPower{cellLength, 1};
                %                 SleepData.(modelName).NREM.data.hippocampus.specBetaBandPower{size(SleepData.(modelName).NREM.data.hippocampus.specBetaBandPower, 1) + 1, 1} = cellHip_specBetaPower{cellLength, 1};
                %                 SleepData.(modelName).NREM.data.hippocampus.specGammaBandPower{size(SleepData.(modelName).NREM.data.hippocampus.specGammaBandPower, 1) + 1, 1} = cellHip_specGammaPower{cellLength, 1};
                %
                SleepData.(modelName).NREM.data.CBV.LH{size(SleepData.(modelName).NREM.data.CBV.LH, 1) + 1, 1} = cellLH_CBV{cellLength, 1};
                SleepData.(modelName).NREM.data.CBV.RH{size(SleepData.(modelName).NREM.data.CBV.RH, 1) + 1, 1} = cellRH_CBV{cellLength, 1};
                
                SleepData.(modelName).NREM.data.CBV_HbT.LH{size(SleepData.(modelName).NREM.data.CBV_HbT.LH, 1) + 1, 1} = cellLH_hbtCBV{cellLength, 1};
                SleepData.(modelName).NREM.data.CBV_HbT.RH{size(SleepData.(modelName).NREM.data.CBV_HbT.RH, 1) + 1, 1} = cellRH_hbtCBV{cellLength, 1};
                
                SleepData.(modelName).NREM.data.WhiskerAcceleration{size(SleepData.(modelName).NREM.data.WhiskerAcceleration, 1) + 1, 1} = cellWhiskerAcceleration{cellLength, 1};
                SleepData.(modelName).NREM.data.HeartRate{size(SleepData.(modelName).NREM.data.HeartRate, 1) + 1, 1} = cellHeartRate{cellLength, 1};
                SleepData.(modelName).NREM.data.DopplerFlow{size(SleepData.(modelName).NREM.data.DopplerFlow, 1) + 1, 1} = cellDopplerFlow{cellLength, 1};
                SleepData.(modelName).NREM.FileIDs{size(SleepData.(modelName).NREM.FileIDs, 1) + 1, 1} = fileID;
                SleepData.(modelName).NREM.BinTimes{size(SleepData.(modelName).NREM.BinTimes, 1) + 1, 1} = cellBinTimes{cellLength, 1};
            end
        end
    end
    
    disp(['Adding NREM sleeping epochs from ProcData file ' num2str(a) ' of ' num2str(size(procDataFileIDs, 1)) '...']); disp(' ')
end

%% REM
sleepBins = REMsleepTime/5;
for a = 1:size(procDataFileIDs, 1)           % Loop through the list of ProcData files
    procDataFileID = procDataFileIDs(a, :);    % Pull character string associated with the current file
    load(procDataFileID);                             % Load in procDataFile associated with character string
    [~,~,fileID] = GetFileInfo_JNeurosci2022(procDataFileID);     % Gather file info
    
    clear LH_deltaPower RH_deltaPower LH_thetaPower RH_thetaPower LH_alphaPower RH_alphaPower LH_betaPower RH_betaPower LH_gammaPower RH_gammaPower LH_muaPower RH_muaPower Hip_deltaPower Hip_thetaPower Hip_alphaPower Hip_betaPower Hip_gammaPower Hip_muaPower
    clear LH_specDeltaPower RH_specDeltaPower LH_specThetaPower RH_specThetaPower LH_specAlphaPower RH_specAlphaPower LH_specBetaPower RH_specBetaPower LH_specGammaPower RH_specGammaPower Hip_specDeltaPower Hip_specThetaPower Hip_specAlphaPower Hip_specBetaPower Hip_specGammaPower
    clear LH_CBV RH_CBV LH_ElectrodeCBV RH_ElectrodeCBV LH_hbtCBV RH_hbtCBV LH_ElectrodehbtCBV RH_ElectrodehbtCBV BinTimes WhiskerAcceleration HeartRate DopplerFlow
    
    clear cellLH_DeltaPower cellRH_DeltaPower cellLH_ThetaPower cellRH_ThetaPower cellLH_AlphaPower cellRH_AlphaPower cellLH_BetaPower cellRH_BetaPower cellLH_GammaPower cellRH_GammaPower cellLH_MUAPower cellRH_MUAPower cellHip_DeltaPower cellHip_ThetaPower cellHip_AlphaPower cellHip_BetaPower cellHip_GammaPower cellHip_MUAPower
    clear cellLH_specDeltaPower cellRH_specDeltaPower cellLH_specThetaPower cellRH_specThetaPower cellLH_specAlphaPower cellRH_specAlphaPower cellLH_specBetaPower cellRH_specBetaPower cellLH_specGammaPower cellRH_specGammaPower cellHip_specDeltaPower cellHip_specThetaPower cellHip_specAlphaPower cellHip_specBetaPower cellHip_specGammaPower
    clear cellLH_CBV cellRH_CBV cellLH_ElectrodeCBV cellRH_ElectrodeCBV cellLH_hbtCBV cellRH_hbtCBV cellLH_ElectrodehbtCBV cellRH_ElectrodehbtCBV cellBinTimes cellWhiskerAcceleration cellHeartRate cellDopplerFlow
    
    clear mat2CellLH_DeltaPower mat2CellRH_DeltaPower mat2CellLH_ThetaPower mat2CellRH_ThetaPower mat2CellLH_AlphaPower mat2CellRH_AlphaPower mat2CellLH_BetaPower mat2CellRH_BetaPower mat2CellLH_GammaPower mat2CellRH_GammaPower mat2CellLH_MUAPower mat2CellRH_MUAPower mat2CellHip_DeltaPower mat2CellHip_ThetaPower mat2CellHip_AlphaPower mat2CellHip_BetaPower mat2CellHip_GammaPower mat2CellHip_MUAPower
    clear mat2CellLH_specDeltaPower mat2CellRH_specDeltaPower mat2CellLH_specThetaPower mat2CellRH_specThetaPower mat2CellLH_specAlphaPower mat2CellRH_specAlphaPower mat2CellLH_specBetaPower mat2CellRH_specBetaPower mat2CellLH_specGammaPower mat2CellRH_specGammaPower mat2CellHip_specDeltaPower mat2CellHip_specThetaPower mat2CellHip_specAlphaPower mat2CellHip_specBetaPower mat2CellHip_specGammaPower
    clear mat2CellLH_CBV mat2CellRH_CBV mat2CellLH_ElectrodeCBV mat2CellRH_ElectrodeCBV mat2CellLH_hbtCBV mat2CellRH_hbtCBV mat2CellLH_ElectrodehbtCBV mat2CellRH_ElectrodehbtCBV mat2CellBinTimes mat2CellWhiskerAcceleration mat2CellHeartRate mat2CellDopplerFlow
    
    clear matLH_DeltaPower matRH_DeltaPower matLH_ThetaPower matRH_ThetaPower matLH_AlphaPower matRH_AlphaPower matLH_BetaPower matRH_BetaPower matLH_GammaPower matRH_GammaPower matLH_MUAPower matRH_MUAPower matHip_DeltaPower matHip_ThetaPower matHip_AlphaPower matHip_BetaPower matHip_GammaPower matHip_MUAPower
    clear matLH_specDeltaPower matRH_specDeltaPower matLH_specThetaPower matRH_specThetaPower matLH_specAlphaPower matRH_specAlphaPower matLH_specBetaPower matRH_specBetaPower matLH_specGammaPower matRH_specGammaPower matHip_specDeltaPower matHip_specThetaPower matHip_specAlphaPower matHip_specBetaPower matHip_specGammaPower
    clear matLH_CBV matRH_CBV matLH_ElectrodeCBV matRH_ElectrodeCBV matLH_hbtCBV matRH_hbtCBV matLH_ElectrodehbtCBV matRH_ElectrodehbtCBV matBinTimes matWhiskerAcceleration matHeartRate matDopplerFlow
    
    remLogical = ProcData.sleep.logicals.(modelName).remLogical;    % Logical - ones denote potential sleep epoches (5 second bins)
    targetTime = ones(1, sleepBins);   % Target time
    sleepIndex = find(conv(remLogical, targetTime) >= sleepBins) - (sleepBins - 1);   % Find the periods of time where there are at least 11 more
    % 5 second epochs following. This is not the full list.
    if isempty(sleepIndex)  % If sleepIndex is empty, skip this file
        % Skip file
    else
        sleepCriteria = (0:(sleepBins - 1));     % This will be used to fix the issue in sleepIndex
        fixedSleepIndex = unique(sleepIndex + sleepCriteria);   % sleep Index now has the proper time stamps from sleep logical
        for indexCount = 1:length(fixedSleepIndex)    % Loop through the length of sleep Index, and pull out associated data
            % filtered signal bands
            LH_deltaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.deltaBandPower{fixedSleepIndex(indexCount), 1};
            RH_deltaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.deltaBandPower{fixedSleepIndex(indexCount), 1};
            LH_thetaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.thetaBandPower{fixedSleepIndex(indexCount), 1};
            RH_thetaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.thetaBandPower{fixedSleepIndex(indexCount), 1};
            LH_alphaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.alphaBandPower{fixedSleepIndex(indexCount), 1};
            RH_alphaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.alphaBandPower{fixedSleepIndex(indexCount), 1};
            LH_betaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.betaBandPower{fixedSleepIndex(indexCount), 1};
            RH_betaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.betaBandPower{fixedSleepIndex(indexCount), 1};
            LH_gammaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.gammaBandPower{fixedSleepIndex(indexCount), 1};
            RH_gammaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.gammaBandPower{fixedSleepIndex(indexCount), 1};
            LH_muaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.muaPower{fixedSleepIndex(indexCount), 1};
            RH_muaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.muaPower{fixedSleepIndex(indexCount), 1};
            
            Hip_deltaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.deltaBandPower{fixedSleepIndex(indexCount), 1};
            Hip_thetaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.thetaBandPower{fixedSleepIndex(indexCount), 1};
            Hip_alphaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.alphaBandPower{fixedSleepIndex(indexCount), 1};
            Hip_betaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.betaBandPower{fixedSleepIndex(indexCount), 1};
            Hip_gammaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.gammaBandPower{fixedSleepIndex(indexCount), 1};
            Hip_muaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.muaPower{fixedSleepIndex(indexCount), 1};
            
            % filtered spectrogram bands
            %             LH_specDeltaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.specDeltaBandPower{fixedSleepIndex(indexCount), 1};
            %             RH_specDeltaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.specDeltaBandPower{fixedSleepIndex(indexCount), 1};
            %             LH_specThetaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.specThetaBandPower{fixedSleepIndex(indexCount), 1};
            %             RH_specThetaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.specThetaBandPower{fixedSleepIndex(indexCount), 1};
            %             LH_specAlphaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.specAlphaBandPower{fixedSleepIndex(indexCount), 1};
            %             RH_specAlphaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.specAlphaBandPower{fixedSleepIndex(indexCount), 1};
            %             LH_specBetaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.specBetaBandPower{fixedSleepIndex(indexCount), 1};
            %             RH_specBetaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.specBetaBandPower{fixedSleepIndex(indexCount), 1};
            %             LH_specGammaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_LH.specGammaBandPower{fixedSleepIndex(indexCount), 1};
            %             RH_specGammaPower{indexCount, 1} = ProcData.sleep.parameters.cortical_RH.specGammaBandPower{fixedSleepIndex(indexCount), 1};
            %
            %             Hip_specDeltaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.specDeltaBandPower{fixedSleepIndex(indexCount), 1};
            %             Hip_specThetaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.specThetaBandPower{fixedSleepIndex(indexCount), 1};
            %             Hip_specAlphaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.specAlphaBandPower{fixedSleepIndex(indexCount), 1};
            %             Hip_specBetaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.specBetaBandPower{fixedSleepIndex(indexCount), 1};
            %             Hip_specGammaPower{indexCount, 1} = ProcData.sleep.parameters.hippocampus.specGammaBandPower{fixedSleepIndex(indexCount), 1};
            
            % CBV
            LH_CBV{indexCount, 1} = ProcData.sleep.parameters.CBV.LH{fixedSleepIndex(indexCount), 1};
            RH_CBV{indexCount, 1} = ProcData.sleep.parameters.CBV.RH{fixedSleepIndex(indexCount), 1};
            
            LH_hbtCBV{indexCount, 1} = ProcData.sleep.parameters.CBV.hbtLH{fixedSleepIndex(indexCount), 1};
            RH_hbtCBV{indexCount, 1} = ProcData.sleep.parameters.CBV.hbtRH{fixedSleepIndex(indexCount), 1};
            
            WhiskerAcceleration{indexCount, 1} = ProcData.sleep.parameters.whiskerAcceleration{fixedSleepIndex(indexCount), 1};
            HeartRate{indexCount, 1} = ProcData.sleep.parameters.heartRate{fixedSleepIndex(indexCount), 1};
            DopplerFlow{indexCount, 1} = ProcData.sleep.parameters.flow{fixedSleepIndex(indexCount), 1};
            BinTimes{indexCount, 1} = 5*fixedSleepIndex(indexCount);
        end
        
        indexBreaks = find(fixedSleepIndex(2:end) - fixedSleepIndex(1:end - 1) > 1);    % Find if there are numerous sleep periods
        
        if isempty(indexBreaks)   % If there is only one period of sleep in this file and not multiple
            % filtered signal bands
            matLH_DeltaPower = cell2mat(LH_deltaPower);
            arrayLH_DeltaPower = reshape(matLH_DeltaPower', [1, size(matLH_DeltaPower, 2)*size(matLH_DeltaPower, 1)]);
            cellLH_DeltaPower = {arrayLH_DeltaPower};
            
            matRH_DeltaPower = cell2mat(RH_deltaPower);
            arrayRH_DeltaPower = reshape(matRH_DeltaPower', [1, size(matRH_DeltaPower, 2)*size(matRH_DeltaPower, 1)]);
            cellRH_DeltaPower = {arrayRH_DeltaPower};
            
            matLH_ThetaPower = cell2mat(LH_thetaPower);
            arrayLH_ThetaPower = reshape(matLH_ThetaPower', [1, size(matLH_ThetaPower, 2)*size(matLH_ThetaPower, 1)]);
            cellLH_ThetaPower = {arrayLH_ThetaPower};
            
            matRH_ThetaPower = cell2mat(RH_thetaPower);
            arrayRH_ThetaPower = reshape(matRH_ThetaPower', [1, size(matRH_ThetaPower, 2)*size(matRH_ThetaPower, 1)]);
            cellRH_ThetaPower = {arrayRH_ThetaPower};
            
            matLH_AlphaPower = cell2mat(LH_alphaPower);
            arrayLH_AlphaPower = reshape(matLH_AlphaPower', [1, size(matLH_AlphaPower, 2)*size(matLH_AlphaPower, 1)]);
            cellLH_AlphaPower = {arrayLH_AlphaPower};
            
            matRH_AlphaPower = cell2mat(RH_alphaPower);
            arrayRH_AlphaPower = reshape(matRH_AlphaPower', [1, size(matRH_AlphaPower, 2)*size(matRH_AlphaPower, 1)]);
            cellRH_AlphaPower = {arrayRH_AlphaPower};
            
            matLH_BetaPower = cell2mat(LH_betaPower);
            arrayLH_BetaPower = reshape(matLH_BetaPower', [1, size(matLH_BetaPower, 2)*size(matLH_BetaPower, 1)]);
            cellLH_BetaPower = {arrayLH_BetaPower};
            
            matRH_BetaPower = cell2mat(RH_betaPower);
            arrayRH_BetaPower = reshape(matRH_BetaPower', [1, size(matRH_BetaPower, 2)*size(matRH_BetaPower, 1)]);
            cellRH_BetaPower = {arrayRH_BetaPower};
            
            matLH_GammaPower = cell2mat(LH_gammaPower);
            arrayLH_GammaPower = reshape(matLH_GammaPower', [1, size(matLH_GammaPower, 2)*size(matLH_GammaPower, 1)]);
            cellLH_GammaPower = {arrayLH_GammaPower};
            
            matRH_GammaPower = cell2mat(RH_gammaPower);
            arrayRH_GammaPower = reshape(matRH_GammaPower', [1, size(matRH_GammaPower, 2)*size(matRH_GammaPower, 1)]);
            cellRH_GammaPower = {arrayRH_GammaPower};
            
            matLH_MUAPower = cell2mat(LH_muaPower);
            arrayLH_MUAPower = reshape(matLH_MUAPower', [1, size(matLH_MUAPower, 2)*size(matLH_MUAPower, 1)]);
            cellLH_MUAPower = {arrayLH_MUAPower};
            
            matRH_MUAPower = cell2mat(RH_muaPower);
            arrayRH_MUAPower = reshape(matRH_MUAPower', [1, size(matRH_MUAPower, 2)*size(matRH_MUAPower, 1)]);
            cellRH_MUAPower = {arrayRH_MUAPower};
            
            matHip_DeltaPower = cell2mat(Hip_deltaPower);
            arrayHip_DeltaPower = reshape(matHip_DeltaPower', [1, size(matHip_DeltaPower, 2)*size(matHip_DeltaPower, 1)]);
            cellHip_DeltaPower = {arrayHip_DeltaPower};
            
            matHip_ThetaPower = cell2mat(Hip_thetaPower);
            arrayHip_ThetaPower = reshape(matHip_ThetaPower', [1, size(matHip_ThetaPower, 2)*size(matHip_ThetaPower, 1)]);
            cellHip_ThetaPower = {arrayHip_ThetaPower};
            
            matHip_AlphaPower = cell2mat(Hip_alphaPower);
            arrayHip_AlphaPower = reshape(matHip_AlphaPower', [1, size(matHip_AlphaPower, 2)*size(matHip_AlphaPower, 1)]);
            cellHip_AlphaPower = {arrayHip_AlphaPower};
            
            matHip_BetaPower = cell2mat(Hip_betaPower);
            arrayHip_BetaPower = reshape(matHip_BetaPower', [1, size(matHip_BetaPower, 2)*size(matHip_BetaPower, 1)]);
            cellHip_BetaPower = {arrayHip_BetaPower};
            
            matHip_GammaPower = cell2mat(Hip_gammaPower);
            arrayHip_GammaPower = reshape(matHip_GammaPower', [1, size(matHip_GammaPower, 2)*size(matHip_GammaPower, 1)]);
            cellHip_GammaPower = {arrayHip_GammaPower};
            
            matHip_MUAPower = cell2mat(Hip_muaPower);
            arrayHip_MUAPower = reshape(matHip_MUAPower', [1, size(matHip_MUAPower, 2)*size(matHip_MUAPower, 1)]);
            cellHip_MUAPower = {arrayHip_MUAPower};
            
            %             % filtered spectrogram bands
            %             matLH_specDeltaPower = cell2mat(LH_specDeltaPower);
            %             arrayLH_specDeltaPower = reshape(matLH_specDeltaPower', [1, size(matLH_specDeltaPower, 2)*size(matLH_specDeltaPower, 1)]);
            %             cellLH_specDeltaPower = {arrayLH_specDeltaPower};
            %
            %             matRH_specDeltaPower = cell2mat(RH_specDeltaPower);
            %             arrayRH_specDeltaPower = reshape(matRH_specDeltaPower', [1, size(matRH_specDeltaPower, 2)*size(matRH_specDeltaPower, 1)]);
            %             cellRH_specDeltaPower = {arrayRH_specDeltaPower};
            %
            %             matLH_specThetaPower = cell2mat(LH_specThetaPower);
            %             arrayLH_specThetaPower = reshape(matLH_specThetaPower', [1, size(matLH_specThetaPower, 2)*size(matLH_specThetaPower, 1)]);
            %             cellLH_specThetaPower = {arrayLH_specThetaPower};
            %
            %             matRH_specThetaPower = cell2mat(RH_specThetaPower);
            %             arrayRH_specThetaPower = reshape(matRH_specThetaPower', [1, size(matRH_specThetaPower, 2)*size(matRH_specThetaPower, 1)]);
            %             cellRH_specThetaPower = {arrayRH_specThetaPower};
            %
            %             matLH_specAlphaPower = cell2mat(LH_specAlphaPower);
            %             arrayLH_specAlphaPower = reshape(matLH_specAlphaPower', [1, size(matLH_specAlphaPower, 2)*size(matLH_specAlphaPower, 1)]);
            %             cellLH_specAlphaPower = {arrayLH_specAlphaPower};
            %
            %             matRH_specAlphaPower = cell2mat(RH_specAlphaPower);
            %             arrayRH_specAlphaPower = reshape(matRH_specAlphaPower', [1, size(matRH_specAlphaPower, 2)*size(matRH_specAlphaPower, 1)]);
            %             cellRH_specAlphaPower = {arrayRH_specAlphaPower};
            %
            %             matLH_specBetaPower = cell2mat(LH_specBetaPower);
            %             arrayLH_specBetaPower = reshape(matLH_specBetaPower', [1, size(matLH_specBetaPower, 2)*size(matLH_specBetaPower, 1)]);
            %             cellLH_specBetaPower = {arrayLH_specBetaPower};
            %
            %             matRH_specBetaPower = cell2mat(RH_specBetaPower);
            %             arrayRH_specBetaPower = reshape(matRH_specBetaPower', [1, size(matRH_specBetaPower, 2)*size(matRH_specBetaPower, 1)]);
            %             cellRH_specBetaPower = {arrayRH_specBetaPower};
            %
            %             matLH_specGammaPower = cell2mat(LH_specGammaPower);
            %             arrayLH_specGammaPower = reshape(matLH_specGammaPower', [1, size(matLH_specGammaPower, 2)*size(matLH_specGammaPower, 1)]);
            %             cellLH_specGammaPower = {arrayLH_specGammaPower};
            %
            %             matRH_specGammaPower = cell2mat(RH_specGammaPower);
            %             arrayRH_specGammaPower = reshape(matRH_specGammaPower', [1, size(matRH_specGammaPower, 2)*size(matRH_specGammaPower, 1)]);
            %             cellRH_specGammaPower = {arrayRH_specGammaPower};
            %
            %             matHip_specDeltaPower = cell2mat(Hip_specDeltaPower);
            %             arrayHip_specDeltaPower = reshape(matHip_specDeltaPower', [1, size(matHip_specDeltaPower, 2)*size(matHip_specDeltaPower, 1)]);
            %             cellHip_specDeltaPower = {arrayHip_specDeltaPower};
            %
            %             matHip_specThetaPower = cell2mat(Hip_specThetaPower);
            %             arrayHip_specThetaPower = reshape(matHip_specThetaPower', [1, size(matHip_specThetaPower, 2)*size(matHip_specThetaPower, 1)]);
            %             cellHip_specThetaPower = {arrayHip_specThetaPower};
            %
            %             matHip_specAlphaPower = cell2mat(Hip_specAlphaPower);
            %             arrayHip_specAlphaPower = reshape(matHip_specAlphaPower', [1, size(matHip_specAlphaPower, 2)*size(matHip_specAlphaPower, 1)]);
            %             cellHip_specAlphaPower = {arrayHip_specAlphaPower};
            %
            %             matHip_specBetaPower = cell2mat(Hip_specBetaPower);
            %             arrayHip_specBetaPower = reshape(matHip_specBetaPower', [1, size(matHip_specBetaPower, 2)*size(matHip_specBetaPower, 1)]);
            %             cellHip_specBetaPower = {arrayHip_specBetaPower};
            %
            %             matHip_specGammaPower = cell2mat(Hip_specGammaPower);
            %             arrayHip_specGammaPower = reshape(matHip_specGammaPower', [1, size(matHip_specGammaPower, 2)*size(matHip_specGammaPower, 1)]);
            %             cellHip_specGammaPower = {arrayHip_specGammaPower};
            %
            % whisker acceleration
            for x = 1:length(WhiskerAcceleration)
                targetPoints = size(WhiskerAcceleration{1, 1}, 2);
                if size(WhiskerAcceleration{x, 1}, 2) ~= targetPoints
                    maxLength = size(WhiskerAcceleration{x, 1}, 2);
                    difference = targetPoints - size(WhiskerAcceleration{x, 1}, 2);
                    for y = 1:difference
                        WhiskerAcceleration{x, 1}(maxLength + y) = 0;
                    end
                end
            end
            
            matWhiskerAcceleration = cell2mat(WhiskerAcceleration);
            arrayWhiskerAcceleration = reshape(matWhiskerAcceleration', [1, size(matWhiskerAcceleration, 2)*size(matWhiskerAcceleration, 1)]);
            cellWhiskerAcceleration = {arrayWhiskerAcceleration};
            
            for x = 1:length(HeartRate)
                targetPoints = size(HeartRate{1, 1}, 2);
                if size(HeartRate{x, 1}, 2) ~= targetPoints
                    maxLength = size(HeartRate{x, 1}, 2);
                    difference = targetPoints - size(HeartRate{x, 1}, 2);
                    for y = 1:difference
                        HeartRate{x, 1}(maxLength + y) = mean(HeartRate{x, 1});
                    end
                end
            end
            
            matHeartRate = cell2mat(HeartRate);
            arrayHeartRate = reshape(matHeartRate', [1, size(matHeartRate, 2)*size(matHeartRate, 1)]);
            cellHeartRate = {arrayHeartRate};
            
            % CBV
            matLH_CBV = cell2mat(LH_CBV);
            arrayLH_CBV = reshape(matLH_CBV', [1, size(matLH_CBV, 2)*size(matLH_CBV, 1)]);
            cellLH_CBV = {arrayLH_CBV};
            
            matRH_CBV = cell2mat(RH_CBV);
            arrayRH_CBV = reshape(matRH_CBV', [1, size(matRH_CBV, 2)*size(matRH_CBV, 1)]);
            cellRH_CBV = {arrayRH_CBV};
            
            % hbt cbv
            matLH_hbtCBV = cell2mat(LH_hbtCBV);
            arrayLH_hbtCBV = reshape(matLH_hbtCBV', [1, size(matLH_hbtCBV, 2)*size(matLH_hbtCBV, 1)]);
            cellLH_hbtCBV = {arrayLH_hbtCBV};
            
            matRH_hbtCBV = cell2mat(RH_hbtCBV);
            arrayRH_hbtCBV = reshape(matRH_hbtCBV', [1, size(matRH_hbtCBV, 2)*size(matRH_hbtCBV, 1)]);
            cellRH_hbtCBV = {arrayRH_hbtCBV};
            
            matDopplerFlow = cell2mat(DopplerFlow);
            arrayDopplerFlow = reshape(matDopplerFlow', [1, size(matDopplerFlow, 2)*size(matDopplerFlow, 1)]);
            cellDopplerFlow = {arrayDopplerFlow};
            
            matBinTimes = cell2mat(BinTimes);
            arrayBinTimes = reshape(matBinTimes', [1, size(matBinTimes, 2)*size(matBinTimes, 1)]);
            cellBinTimes = {arrayBinTimes};
        else
            count = length(fixedSleepIndex);
            holdIndex = zeros(1, (length(indexBreaks) + 1));
            
            for indexCounter = 1:length(indexBreaks) + 1
                if indexCounter == 1
                    holdIndex(indexCounter) = indexBreaks(indexCounter);
                elseif indexCounter == length(indexBreaks) + 1
                    holdIndex(indexCounter) = count - indexBreaks(indexCounter - 1);
                else
                    holdIndex(indexCounter)= indexBreaks(indexCounter) - indexBreaks(indexCounter - 1);
                end
            end
            
            splitCounter = 1:length(LH_deltaPower);
            convertedMat2Cell = mat2cell(splitCounter', holdIndex);
            
            for matCounter = 1:length(convertedMat2Cell)
                mat2CellLH_DeltaPower{matCounter, 1} = LH_deltaPower(convertedMat2Cell{matCounter, 1});
                mat2CellRH_DeltaPower{matCounter, 1} = RH_deltaPower(convertedMat2Cell{matCounter, 1});
                mat2CellLH_ThetaPower{matCounter, 1} = LH_thetaPower(convertedMat2Cell{matCounter, 1});
                mat2CellRH_ThetaPower{matCounter, 1} = RH_thetaPower(convertedMat2Cell{matCounter, 1});
                mat2CellLH_AlphaPower{matCounter, 1} = LH_alphaPower(convertedMat2Cell{matCounter, 1});
                mat2CellRH_AlphaPower{matCounter, 1} = RH_alphaPower(convertedMat2Cell{matCounter, 1});
                mat2CellLH_BetaPower{matCounter, 1} = LH_betaPower(convertedMat2Cell{matCounter, 1});
                mat2CellRH_BetaPower{matCounter, 1} = RH_betaPower(convertedMat2Cell{matCounter, 1});
                mat2CellLH_GammaPower{matCounter, 1} = LH_gammaPower(convertedMat2Cell{matCounter, 1});
                mat2CellRH_GammaPower{matCounter, 1} = RH_gammaPower(convertedMat2Cell{matCounter, 1});
                mat2CellLH_MUAPower{matCounter, 1} = LH_muaPower(convertedMat2Cell{matCounter, 1});
                mat2CellRH_MUAPower{matCounter, 1} = RH_muaPower(convertedMat2Cell{matCounter, 1});
                
                mat2CellHip_DeltaPower{matCounter, 1} = Hip_deltaPower(convertedMat2Cell{matCounter, 1});
                mat2CellHip_ThetaPower{matCounter, 1} = Hip_thetaPower(convertedMat2Cell{matCounter, 1});
                mat2CellHip_AlphaPower{matCounter, 1} = Hip_alphaPower(convertedMat2Cell{matCounter, 1});
                mat2CellHip_BetaPower{matCounter, 1} = Hip_betaPower(convertedMat2Cell{matCounter, 1});
                mat2CellHip_GammaPower{matCounter, 1} = Hip_gammaPower(convertedMat2Cell{matCounter, 1});
                mat2CellHip_MUAPower{matCounter, 1} = Hip_muaPower(convertedMat2Cell{matCounter, 1});
                
                %                 mat2CellLH_specDeltaPower{matCounter, 1} = LH_specDeltaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellRH_specDeltaPower{matCounter, 1} = RH_specDeltaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellLH_specThetaPower{matCounter, 1} = LH_specThetaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellRH_specThetaPower{matCounter, 1} = RH_specThetaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellLH_specAlphaPower{matCounter, 1} = LH_specAlphaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellRH_specAlphaPower{matCounter, 1} = RH_specAlphaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellLH_specBetaPower{matCounter, 1} = LH_specBetaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellRH_specBetaPower{matCounter, 1} = RH_specBetaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellLH_specGammaPower{matCounter, 1} = LH_specGammaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellRH_specGammaPower{matCounter, 1} = RH_specGammaPower(convertedMat2Cell{matCounter, 1});
                %
                %                 mat2CellHip_specDeltaPower{matCounter, 1} = Hip_specDeltaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellHip_specThetaPower{matCounter, 1} = Hip_specThetaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellHip_specAlphaPower{matCounter, 1} = Hip_specAlphaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellHip_specBetaPower{matCounter, 1} = Hip_specBetaPower(convertedMat2Cell{matCounter, 1});
                %                 mat2CellHip_specGammaPower{matCounter, 1} = Hip_specGammaPower(convertedMat2Cell{matCounter, 1});
                %
                mat2CellLH_CBV{matCounter, 1} = LH_CBV(convertedMat2Cell{matCounter, 1});
                mat2CellRH_CBV{matCounter, 1} = RH_CBV(convertedMat2Cell{matCounter, 1});
                
                mat2CellLH_hbtCBV{matCounter, 1} = LH_hbtCBV(convertedMat2Cell{matCounter, 1});
                mat2CellRH_hbtCBV{matCounter, 1} = RH_hbtCBV(convertedMat2Cell{matCounter, 1});
                
                mat2CellWhiskerAcceleration{matCounter, 1} = WhiskerAcceleration(convertedMat2Cell{matCounter, 1});
                mat2CellHeartRate{matCounter, 1} = HeartRate(convertedMat2Cell{matCounter, 1});
                mat2CellDopplerFlow{matCounter, 1} = DopplerFlow(convertedMat2Cell{matCounter, 1});
                mat2CellBinTimes{matCounter, 1} = BinTimes(convertedMat2Cell{matCounter, 1});
            end
            
            for cellCounter = 1:length(mat2CellLH_DeltaPower)
                matLH_DeltaPower = cell2mat(mat2CellLH_DeltaPower{cellCounter, 1});
                arrayLH_DeltaPower = reshape(matLH_DeltaPower', [1, size(matLH_DeltaPower, 2)*size(matLH_DeltaPower, 1)]);
                cellLH_DeltaPower{cellCounter, 1} = arrayLH_DeltaPower;
                
                matRH_DeltaPower = cell2mat(mat2CellRH_DeltaPower{cellCounter, 1});
                arrayRH_DeltaPower = reshape(matRH_DeltaPower', [1, size(matRH_DeltaPower, 2)*size(matRH_DeltaPower, 1)]);
                cellRH_DeltaPower{cellCounter, 1} = arrayRH_DeltaPower;
                
                matLH_ThetaPower = cell2mat(mat2CellLH_ThetaPower{cellCounter, 1});
                arrayLH_ThetaPower = reshape(matLH_ThetaPower', [1, size(matLH_ThetaPower, 2)*size(matLH_ThetaPower, 1)]);
                cellLH_ThetaPower{cellCounter, 1} = arrayLH_ThetaPower;
                
                matRH_ThetaPower = cell2mat(mat2CellRH_ThetaPower{cellCounter, 1});
                arrayRH_ThetaPower = reshape(matRH_ThetaPower', [1, size(matRH_ThetaPower, 2)*size(matRH_ThetaPower, 1)]);
                cellRH_ThetaPower{cellCounter, 1} = arrayRH_ThetaPower;
                
                matLH_AlphaPower = cell2mat(mat2CellLH_AlphaPower{cellCounter, 1});
                arrayLH_AlphaPower = reshape(matLH_AlphaPower', [1, size(matLH_AlphaPower, 2)*size(matLH_AlphaPower, 1)]);
                cellLH_AlphaPower{cellCounter, 1} = arrayLH_AlphaPower;
                
                matRH_AlphaPower = cell2mat(mat2CellRH_AlphaPower{cellCounter, 1});
                arrayRH_AlphaPower = reshape(matRH_AlphaPower', [1, size(matRH_AlphaPower, 2)*size(matRH_AlphaPower, 1)]);
                cellRH_AlphaPower{cellCounter, 1} = arrayRH_AlphaPower;
                
                matLH_BetaPower = cell2mat(mat2CellLH_BetaPower{cellCounter, 1});
                arrayLH_BetaPower = reshape(matLH_BetaPower', [1, size(matLH_BetaPower, 2)*size(matLH_BetaPower, 1)]);
                cellLH_BetaPower{cellCounter, 1} = arrayLH_BetaPower;
                
                matRH_BetaPower = cell2mat(mat2CellRH_BetaPower{cellCounter, 1});
                arrayRH_BetaPower = reshape(matRH_BetaPower', [1, size(matRH_BetaPower, 2)*size(matRH_BetaPower, 1)]);
                cellRH_BetaPower{cellCounter, 1} = arrayRH_BetaPower;
                
                matLH_GammaPower = cell2mat(mat2CellLH_GammaPower{cellCounter, 1});
                arrayLH_GammaPower = reshape(matLH_GammaPower', [1, size(matLH_GammaPower, 2)*size(matLH_GammaPower, 1)]);
                cellLH_GammaPower{cellCounter, 1} = arrayLH_GammaPower;
                
                matRH_GammaPower = cell2mat(mat2CellRH_GammaPower{cellCounter, 1});
                arrayRH_GammaPower = reshape(matRH_GammaPower', [1, size(matRH_GammaPower, 2)*size(matRH_GammaPower, 1)]);
                cellRH_GammaPower{cellCounter, 1} = arrayRH_GammaPower;
                
                matLH_MUAPower = cell2mat(mat2CellLH_MUAPower{cellCounter, 1});
                arrayLH_MUAPower = reshape(matLH_MUAPower', [1, size(matLH_MUAPower, 2)*size(matLH_MUAPower, 1)]);
                cellLH_MUAPower{cellCounter, 1} = arrayLH_MUAPower;
                
                matRH_MUAPower = cell2mat(mat2CellRH_MUAPower{cellCounter, 1});
                arrayRH_MUAPower = reshape(matRH_MUAPower', [1, size(matRH_MUAPower, 2)*size(matRH_MUAPower, 1)]);
                cellRH_MUAPower{cellCounter, 1} = arrayRH_MUAPower;
                
                matHip_DeltaPower = cell2mat(mat2CellHip_DeltaPower{cellCounter, 1});
                arrayHip_DeltaPower = reshape(matHip_DeltaPower', [1, size(matHip_DeltaPower, 2)*size(matHip_DeltaPower, 1)]);
                cellHip_DeltaPower{cellCounter, 1} = arrayHip_DeltaPower;
                
                matHip_ThetaPower = cell2mat(mat2CellHip_ThetaPower{cellCounter, 1});
                arrayHip_ThetaPower = reshape(matHip_ThetaPower', [1, size(matHip_ThetaPower, 2)*size(matHip_ThetaPower, 1)]);
                cellHip_ThetaPower{cellCounter, 1} = arrayHip_ThetaPower;
                
                matHip_AlphaPower = cell2mat(mat2CellHip_AlphaPower{cellCounter, 1});
                arrayHip_AlphaPower = reshape(matHip_AlphaPower', [1, size(matHip_AlphaPower, 2)*size(matHip_AlphaPower, 1)]);
                cellHip_AlphaPower{cellCounter, 1} = arrayHip_AlphaPower;
                
                matHip_BetaPower = cell2mat(mat2CellHip_BetaPower{cellCounter, 1});
                arrayHip_BetaPower = reshape(matHip_BetaPower', [1, size(matHip_BetaPower, 2)*size(matHip_BetaPower, 1)]);
                cellHip_BetaPower{cellCounter, 1} = arrayHip_BetaPower;
                
                matHip_GammaPower = cell2mat(mat2CellHip_GammaPower{cellCounter, 1});
                arrayHip_GammaPower = reshape(matHip_GammaPower', [1, size(matHip_GammaPower, 2)*size(matHip_GammaPower, 1)]);
                cellHip_GammaPower{cellCounter, 1} = arrayHip_GammaPower;
                
                matHip_MUAPower = cell2mat(mat2CellHip_MUAPower{cellCounter, 1});
                arrayHip_MUAPower = reshape(matHip_MUAPower', [1, size(matHip_MUAPower, 2)*size(matHip_MUAPower, 1)]);
                cellHip_MUAPower{cellCounter, 1} = arrayHip_MUAPower;
                
                %                 matLH_specDeltaPower = cell2mat(mat2CellLH_specDeltaPower{cellCounter, 1});
                %                 arrayLH_specDeltaPower = reshape(matLH_specDeltaPower', [1, size(matLH_specDeltaPower, 2)*size(matLH_specDeltaPower, 1)]);
                %                 cellLH_specDeltaPower{cellCounter, 1} = arrayLH_specDeltaPower;
                %
                %                 matRH_specDeltaPower = cell2mat(mat2CellRH_specDeltaPower{cellCounter, 1});
                %                 arrayRH_specDeltaPower = reshape(matRH_specDeltaPower', [1, size(matRH_specDeltaPower, 2)*size(matRH_specDeltaPower, 1)]);
                %                 cellRH_specDeltaPower{cellCounter, 1} = arrayRH_specDeltaPower;
                %
                %                 matLH_specThetaPower = cell2mat(mat2CellLH_specThetaPower{cellCounter, 1});
                %                 arrayLH_specThetaPower = reshape(matLH_specThetaPower', [1, size(matLH_specThetaPower, 2)*size(matLH_specThetaPower, 1)]);
                %                 cellLH_specThetaPower{cellCounter, 1} = arrayLH_specThetaPower;
                %
                %                 matRH_specThetaPower = cell2mat(mat2CellRH_specThetaPower{cellCounter, 1});
                %                 arrayRH_specThetaPower = reshape(matRH_specThetaPower', [1, size(matRH_specThetaPower, 2)*size(matRH_specThetaPower, 1)]);
                %                 cellRH_specThetaPower{cellCounter, 1} = arrayRH_specThetaPower;
                %
                %                 matLH_specAlphaPower = cell2mat(mat2CellLH_specAlphaPower{cellCounter, 1});
                %                 arrayLH_specAlphaPower = reshape(matLH_specAlphaPower', [1, size(matLH_specAlphaPower, 2)*size(matLH_specAlphaPower, 1)]);
                %                 cellLH_specAlphaPower{cellCounter, 1} = arrayLH_specAlphaPower;
                %
                %                 matRH_specAlphaPower = cell2mat(mat2CellRH_specAlphaPower{cellCounter, 1});
                %                 arrayRH_specAlphaPower = reshape(matRH_specAlphaPower', [1, size(matRH_specAlphaPower, 2)*size(matRH_specAlphaPower, 1)]);
                %                 cellRH_specAlphaPower{cellCounter, 1} = arrayRH_specAlphaPower;
                %
                %                 matLH_specBetaPower = cell2mat(mat2CellLH_specBetaPower{cellCounter, 1});
                %                 arrayLH_specBetaPower = reshape(matLH_specBetaPower', [1, size(matLH_specBetaPower, 2)*size(matLH_specBetaPower, 1)]);
                %                 cellLH_specBetaPower{cellCounter, 1} = arrayLH_specBetaPower;
                %
                %                 matRH_specBetaPower = cell2mat(mat2CellRH_specBetaPower{cellCounter, 1});
                %                 arrayRH_specBetaPower = reshape(matRH_specBetaPower', [1, size(matRH_specBetaPower, 2)*size(matRH_specBetaPower, 1)]);
                %                 cellRH_specBetaPower{cellCounter, 1} = arrayRH_specBetaPower;
                %
                %                 matLH_specGammaPower = cell2mat(mat2CellLH_specGammaPower{cellCounter, 1});
                %                 arrayLH_specGammaPower = reshape(matLH_specGammaPower', [1, size(matLH_specGammaPower, 2)*size(matLH_specGammaPower, 1)]);
                %                 cellLH_specGammaPower{cellCounter, 1} = arrayLH_specGammaPower;
                %
                %                 matRH_specGammaPower = cell2mat(mat2CellRH_specGammaPower{cellCounter, 1});
                %                 arrayRH_specGammaPower = reshape(matRH_specGammaPower', [1, size(matRH_specGammaPower, 2)*size(matRH_specGammaPower, 1)]);
                %                 cellRH_specGammaPower{cellCounter, 1} = arrayRH_specGammaPower;
                %
                %                 matHip_specDeltaPower = cell2mat(mat2CellHip_specDeltaPower{cellCounter, 1});
                %                 arrayHip_specDeltaPower = reshape(matHip_specDeltaPower', [1, size(matHip_specDeltaPower, 2)*size(matHip_specDeltaPower, 1)]);
                %                 cellHip_specDeltaPower{cellCounter, 1} = arrayHip_specDeltaPower;
                %
                %                 matHip_specThetaPower = cell2mat(mat2CellHip_specThetaPower{cellCounter, 1});
                %                 arrayHip_specThetaPower = reshape(matHip_specThetaPower', [1, size(matHip_specThetaPower, 2)*size(matHip_specThetaPower, 1)]);
                %                 cellHip_specThetaPower{cellCounter, 1} = arrayHip_specThetaPower;
                %
                %                 matHip_specAlphaPower = cell2mat(mat2CellHip_specAlphaPower{cellCounter, 1});
                %                 arrayHip_specAlphaPower = reshape(matHip_specAlphaPower', [1, size(matHip_specAlphaPower, 2)*size(matHip_specAlphaPower, 1)]);
                %                 cellHip_specAlphaPower{cellCounter, 1} = arrayHip_specAlphaPower;
                %
                %                 matHip_specBetaPower = cell2mat(mat2CellHip_specBetaPower{cellCounter, 1});
                %                 arrayHip_specBetaPower = reshape(matHip_specBetaPower', [1, size(matHip_specBetaPower, 2)*size(matHip_specBetaPower, 1)]);
                %                 cellHip_specBetaPower{cellCounter, 1} = arrayHip_specBetaPower;
                %
                %                 matHip_specGammaPower = cell2mat(mat2CellHip_specGammaPower{cellCounter, 1});
                %                 arrayHip_specGammaPower = reshape(matHip_specGammaPower', [1, size(matHip_specGammaPower, 2)*size(matHip_specGammaPower, 1)]);
                %                 cellHip_specGammaPower{cellCounter, 1} = arrayHip_specGammaPower;
                %
                matLH_CBV = cell2mat(mat2CellLH_CBV{cellCounter, 1});
                arrayLH_CBV = reshape(matLH_CBV', [1, size(matLH_CBV, 2)*size(matLH_CBV, 1)]);
                cellLH_CBV{cellCounter, 1} = arrayLH_CBV;
                
                matRH_CBV = cell2mat(mat2CellRH_CBV{cellCounter, 1});
                arrayRH_CBV = reshape(matRH_CBV', [1, size(matRH_CBV, 2)*size(matRH_CBV, 1)]);
                cellRH_CBV{cellCounter, 1} = arrayRH_CBV;
                
                matLH_hbtCBV = cell2mat(mat2CellLH_hbtCBV{cellCounter, 1});
                arrayLH_hbtCBV = reshape(matLH_hbtCBV', [1, size(matLH_hbtCBV, 2)*size(matLH_hbtCBV, 1)]);
                cellLH_hbtCBV{cellCounter, 1} = arrayLH_hbtCBV;
                
                matRH_hbtCBV = cell2mat(mat2CellRH_hbtCBV{cellCounter, 1});
                arrayRH_hbtCBV = reshape(matRH_hbtCBV', [1, size(matRH_hbtCBV, 2)*size(matRH_hbtCBV, 1)]);
                cellRH_hbtCBV{cellCounter, 1} = arrayRH_hbtCBV;
                
                for x = 1:size(mat2CellWhiskerAcceleration{cellCounter, 1}, 1)
                    targetPoints = size(mat2CellWhiskerAcceleration{cellCounter, 1}{1, 1}, 2);
                    if size(mat2CellWhiskerAcceleration{cellCounter, 1}{x, 1}, 2) ~= targetPoints
                        maxLength = size(mat2CellWhiskerAcceleration{cellCounter, 1}{x, 1}, 2);
                        difference = targetPoints - size(mat2CellWhiskerAcceleration{cellCounter, 1}{x, 1}, 2);
                        for y = 1:difference
                            mat2CellWhiskerAcceleration{cellCounter, 1}{x, 1}(maxLength + y) = 0;
                        end
                    end
                end
                
                matWhiskerAcceleration = cell2mat(mat2CellWhiskerAcceleration{cellCounter, 1});
                arrayWhiskerAcceleration = reshape(matWhiskerAcceleration', [1, size(matWhiskerAcceleration, 2)*size(matWhiskerAcceleration, 1)]);
                cellWhiskerAcceleration{cellCounter, 1} = arrayWhiskerAcceleration;
                
                for x = 1:size(mat2CellHeartRate{cellCounter, 1}, 1)
                    targetPoints = size(mat2CellHeartRate{cellCounter, 1}{1, 1}, 2);
                    if size(mat2CellHeartRate{cellCounter, 1}{x, 1}, 2) ~= targetPoints
                        maxLength = size(mat2CellHeartRate{cellCounter, 1}{x, 1}, 2);
                        difference = targetPoints - size(mat2CellHeartRate{cellCounter, 1}{x, 1}, 2);
                        for y = 1:difference
                            mat2CellHeartRate{cellCounter, 1}{x, 1}(maxLength + y) = mean(mat2CellHeartRate{cellCounter, 1}{x, 1});
                        end
                    end
                end
                
                matHeartRate = cell2mat(mat2CellHeartRate{cellCounter, 1});
                arrayHeartRate = reshape(matHeartRate', [1, size(matHeartRate, 2)*size(matHeartRate, 1)]);
                cellHeartRate{cellCounter, 1} = arrayHeartRate;
                
                matDopplerFlow = cell2mat(mat2CellDopplerFlow{cellCounter, 1});
                arrayDopplerFlow = reshape(matDopplerFlow', [1, size(matDopplerFlow, 2)*size(matDopplerFlow, 1)]);
                cellDopplerFlow{cellCounter, 1} = arrayDopplerFlow;
                
                matBinTimes = cell2mat(mat2CellBinTimes{cellCounter, 1});
                arrayBinTimes = reshape(matBinTimes', [1, size(matBinTimes, 2)*size(matBinTimes, 1)]);
                cellBinTimes{cellCounter, 1} = arrayBinTimes;
            end
        end
        
        %% BLOCK PURPOSE: Save the data in the SleepEventData struct
        if isfield(SleepData.(modelName),'REM') == false % If the structure is empty, we need a special case to format the struct properly
            for cellLength = 1:size(cellLH_DeltaPower, 2)   % Loop through however many sleep epochs this file has
                SleepData.(modelName).REM.data.cortical_LH.deltaBandPower{cellLength, 1} = cellLH_DeltaPower{1, 1};
                SleepData.(modelName).REM.data.cortical_RH.deltaBandPower{cellLength, 1} = cellRH_DeltaPower{1, 1};
                SleepData.(modelName).REM.data.cortical_LH.thetaBandPower{cellLength, 1} = cellLH_ThetaPower{1, 1};
                SleepData.(modelName).REM.data.cortical_RH.thetaBandPower{cellLength, 1} = cellRH_ThetaPower{1, 1};
                SleepData.(modelName).REM.data.cortical_LH.alphaBandPower{cellLength, 1} = cellLH_AlphaPower{1, 1};
                SleepData.(modelName).REM.data.cortical_RH.alphaBandPower{cellLength, 1} = cellRH_AlphaPower{1, 1};
                SleepData.(modelName).REM.data.cortical_LH.betaBandPower{cellLength, 1} = cellLH_BetaPower{1, 1};
                SleepData.(modelName).REM.data.cortical_RH.betaBandPower{cellLength, 1} = cellRH_BetaPower{1, 1};
                SleepData.(modelName).REM.data.cortical_LH.gammaBandPower{cellLength, 1} = cellLH_GammaPower{1, 1};
                SleepData.(modelName).REM.data.cortical_RH.gammaBandPower{cellLength, 1} = cellRH_GammaPower{1, 1};
                SleepData.(modelName).REM.data.cortical_LH.muaPower{cellLength, 1} = cellLH_MUAPower{1, 1};
                SleepData.(modelName).REM.data.cortical_RH.muaPower{cellLength, 1} = cellRH_MUAPower{1, 1};
                
                SleepData.(modelName).REM.data.hippocampus.deltaBandPower{cellLength, 1} = cellHip_DeltaPower{1, 1};
                SleepData.(modelName).REM.data.hippocampus.thetaBandPower{cellLength, 1} = cellHip_ThetaPower{1, 1};
                SleepData.(modelName).REM.data.hippocampus.alphaBandPower{cellLength, 1} = cellHip_AlphaPower{1, 1};
                SleepData.(modelName).REM.data.hippocampus.betaBandPower{cellLength, 1} = cellHip_BetaPower{1, 1};
                SleepData.(modelName).REM.data.hippocampus.gammaBandPower{cellLength, 1} = cellHip_GammaPower{1, 1};
                SleepData.(modelName).REM.data.hippocampus.muaPower{cellLength, 1} = cellHip_MUAPower{1, 1};
                %
                %                 SleepData.(modelName).REM.data.cortical_LH.specDeltaBandPower{cellLength, 1} = cellLH_specDeltaPower{1, 1};
                %                 SleepData.(modelName).REM.data.cortical_RH.specDeltaBandPower{cellLength, 1} = cellRH_specDeltaPower{1, 1};
                %                 SleepData.(modelName).REM.data.cortical_LH.specThetaBandPower{cellLength, 1} = cellLH_specThetaPower{1, 1};
                %                 SleepData.(modelName).REM.data.cortical_RH.specThetaBandPower{cellLength, 1} = cellRH_specThetaPower{1, 1};
                %                 SleepData.(modelName).REM.data.cortical_LH.specAlphaBandPower{cellLength, 1} = cellLH_specAlphaPower{1, 1};
                %                 SleepData.(modelName).REM.data.cortical_RH.specAlphaBandPower{cellLength, 1} = cellRH_specAlphaPower{1, 1};
                %                 SleepData.(modelName).REM.data.cortical_LH.specBetaBandPower{cellLength, 1} = cellLH_specBetaPower{1, 1};
                %                 SleepData.(modelName).REM.data.cortical_RH.specBetaBandPower{cellLength, 1} = cellRH_specBetaPower{1, 1};
                %                 SleepData.(modelName).REM.data.cortical_LH.specGammaBandPower{cellLength, 1} = cellLH_specGammaPower{1, 1};
                %                 SleepData.(modelName).REM.data.cortical_RH.specGammaBandPower{cellLength, 1} = cellRH_specGammaPower{1, 1};
                %
                %                 SleepData.(modelName).REM.data.hippocampus.specDeltaBandPower{cellLength, 1} = cellHip_specDeltaPower{1, 1};
                %                 SleepData.(modelName).REM.data.hippocampus.specThetaBandPower{cellLength, 1} = cellHip_specThetaPower{1, 1};
                %                 SleepData.(modelName).REM.data.hippocampus.specAlphaBandPower{cellLength, 1} = cellHip_specAlphaPower{1, 1};
                %                 SleepData.(modelName).REM.data.hippocampus.specBetaBandPower{cellLength, 1} = cellHip_specBetaPower{1, 1};
                %                 SleepData.(modelName).REM.data.hippocampus.specGammaBandPower{cellLength, 1} = cellHip_specGammaPower{1, 1};
                %
                SleepData.(modelName).REM.data.CBV.LH{cellLength, 1} = cellLH_CBV{1, 1};
                SleepData.(modelName).REM.data.CBV.RH{cellLength, 1} = cellRH_CBV{1, 1};
                
                SleepData.(modelName).REM.data.CBV_HbT.LH{cellLength, 1} = cellLH_hbtCBV{1, 1};
                SleepData.(modelName).REM.data.CBV_HbT.RH{cellLength, 1} = cellRH_hbtCBV{1, 1};
                
                SleepData.(modelName).REM.data.WhiskerAcceleration{cellLength, 1} = cellWhiskerAcceleration{1, 1};
                SleepData.(modelName).REM.data.HeartRate{cellLength, 1} = cellHeartRate{1, 1};
                SleepData.(modelName).REM.data.DopplerFlow{cellLength, 1} = cellDopplerFlow{1, 1};
                SleepData.(modelName).REM.FileIDs{cellLength, 1} = fileID;
                SleepData.(modelName).REM.BinTimes{cellLength, 1} = cellBinTimes{1, 1};
            end
        else    % If the struct is not empty, add each new iteration after previous data
            for cellLength = 1:size(cellLH_DeltaPower, 1)   % Loop through however many sleep epochs this file has
                SleepData.(modelName).REM.data.cortical_LH.deltaBandPower{size(SleepData.(modelName).REM.data.cortical_LH.deltaBandPower, 1) + 1, 1} = cellLH_DeltaPower{cellLength, 1};
                SleepData.(modelName).REM.data.cortical_RH.deltaBandPower{size(SleepData.(modelName).REM.data.cortical_RH.deltaBandPower, 1) + 1, 1} = cellRH_DeltaPower{cellLength, 1};
                SleepData.(modelName).REM.data.cortical_LH.thetaBandPower{size(SleepData.(modelName).REM.data.cortical_LH.thetaBandPower, 1) + 1, 1} = cellLH_ThetaPower{cellLength, 1};
                SleepData.(modelName).REM.data.cortical_RH.thetaBandPower{size(SleepData.(modelName).REM.data.cortical_RH.thetaBandPower, 1) + 1, 1} = cellRH_ThetaPower{cellLength, 1};
                SleepData.(modelName).REM.data.cortical_LH.alphaBandPower{size(SleepData.(modelName).REM.data.cortical_LH.alphaBandPower, 1) + 1, 1} = cellLH_AlphaPower{cellLength, 1};
                SleepData.(modelName).REM.data.cortical_RH.alphaBandPower{size(SleepData.(modelName).REM.data.cortical_RH.alphaBandPower, 1) + 1, 1} = cellRH_AlphaPower{cellLength, 1};
                SleepData.(modelName).REM.data.cortical_LH.betaBandPower{size(SleepData.(modelName).REM.data.cortical_LH.betaBandPower, 1) + 1, 1} = cellLH_BetaPower{cellLength, 1};
                SleepData.(modelName).REM.data.cortical_RH.betaBandPower{size(SleepData.(modelName).REM.data.cortical_RH.betaBandPower, 1) + 1, 1} = cellRH_BetaPower{cellLength, 1};
                SleepData.(modelName).REM.data.cortical_LH.gammaBandPower{size(SleepData.(modelName).REM.data.cortical_LH.gammaBandPower, 1) + 1, 1} = cellLH_GammaPower{cellLength, 1};
                SleepData.(modelName).REM.data.cortical_RH.gammaBandPower{size(SleepData.(modelName).REM.data.cortical_RH.gammaBandPower, 1) + 1, 1} = cellRH_GammaPower{cellLength, 1};
                SleepData.(modelName).REM.data.cortical_LH.muaPower{size(SleepData.(modelName).REM.data.cortical_LH.muaPower, 1) + 1, 1} = cellLH_MUAPower{cellLength, 1};
                SleepData.(modelName).REM.data.cortical_RH.muaPower{size(SleepData.(modelName).REM.data.cortical_RH.muaPower, 1) + 1, 1} = cellRH_MUAPower{cellLength, 1};
                
                SleepData.(modelName).REM.data.hippocampus.deltaBandPower{size(SleepData.(modelName).REM.data.hippocampus.deltaBandPower, 1) + 1, 1} = cellHip_DeltaPower{cellLength, 1};
                SleepData.(modelName).REM.data.hippocampus.thetaBandPower{size(SleepData.(modelName).REM.data.hippocampus.thetaBandPower, 1) + 1, 1} = cellHip_ThetaPower{cellLength, 1};
                SleepData.(modelName).REM.data.hippocampus.alphaBandPower{size(SleepData.(modelName).REM.data.hippocampus.alphaBandPower, 1) + 1, 1} = cellHip_AlphaPower{cellLength, 1};
                SleepData.(modelName).REM.data.hippocampus.betaBandPower{size(SleepData.(modelName).REM.data.hippocampus.betaBandPower, 1) + 1, 1} = cellHip_BetaPower{cellLength, 1};
                SleepData.(modelName).REM.data.hippocampus.gammaBandPower{size(SleepData.(modelName).REM.data.hippocampus.gammaBandPower, 1) + 1, 1} = cellHip_GammaPower{cellLength, 1};
                SleepData.(modelName).REM.data.hippocampus.muaPower{size(SleepData.(modelName).REM.data.hippocampus.muaPower, 1) + 1, 1} = cellHip_MUAPower{cellLength, 1};
                
                %                 SleepData.(modelName).REM.data.cortical_LH.specDeltaBandPower{size(SleepData.(modelName).REM.data.cortical_LH.specDeltaBandPower, 1) + 1, 1} = cellLH_specDeltaPower{cellLength, 1};
                %                 SleepData.(modelName).REM.data.cortical_RH.specDeltaBandPower{size(SleepData.(modelName).REM.data.cortical_RH.specDeltaBandPower, 1) + 1, 1} = cellRH_specDeltaPower{cellLength, 1};
                %                 SleepData.(modelName).REM.data.cortical_LH.specThetaBandPower{size(SleepData.(modelName).REM.data.cortical_LH.specThetaBandPower, 1) + 1, 1} = cellLH_specThetaPower{cellLength, 1};
                %                 SleepData.(modelName).REM.data.cortical_RH.specThetaBandPower{size(SleepData.(modelName).REM.data.cortical_RH.specThetaBandPower, 1) + 1, 1} = cellRH_specThetaPower{cellLength, 1};
                %                 SleepData.(modelName).REM.data.cortical_LH.specAlphaBandPower{size(SleepData.(modelName).REM.data.cortical_LH.specAlphaBandPower, 1) + 1, 1} = cellLH_specAlphaPower{cellLength, 1};
                %                 SleepData.(modelName).REM.data.cortical_RH.specAlphaBandPower{size(SleepData.(modelName).REM.data.cortical_RH.specAlphaBandPower, 1) + 1, 1} = cellRH_specAlphaPower{cellLength, 1};
                %                 SleepData.(modelName).REM.data.cortical_LH.specBetaBandPower{size(SleepData.(modelName).REM.data.cortical_LH.specBetaBandPower, 1) + 1, 1} = cellLH_specBetaPower{cellLength, 1};
                %                 SleepData.(modelName).REM.data.cortical_RH.specBetaBandPower{size(SleepData.(modelName).REM.data.cortical_RH.specBetaBandPower, 1) + 1, 1} = cellRH_specBetaPower{cellLength, 1};
                %                 SleepData.(modelName).REM.data.cortical_LH.specGammaBandPower{size(SleepData.(modelName).REM.data.cortical_LH.specGammaBandPower, 1) + 1, 1} = cellLH_specGammaPower{cellLength, 1};
                %                 SleepData.(modelName).REM.data.cortical_RH.specGammaBandPower{size(SleepData.(modelName).REM.data.cortical_RH.specGammaBandPower, 1) + 1, 1} = cellRH_specGammaPower{cellLength, 1};
                %
                %                 SleepData.(modelName).REM.data.hippocampus.specDeltaBandPower{size(SleepData.(modelName).REM.data.hippocampus.specDeltaBandPower, 1) + 1, 1} = cellHip_specDeltaPower{cellLength, 1};
                %                 SleepData.(modelName).REM.data.hippocampus.specThetaBandPower{size(SleepData.(modelName).REM.data.hippocampus.specThetaBandPower, 1) + 1, 1} = cellHip_specThetaPower{cellLength, 1};
                %                 SleepData.(modelName).REM.data.hippocampus.specAlphaBandPower{size(SleepData.(modelName).REM.data.hippocampus.specAlphaBandPower, 1) + 1, 1} = cellHip_specAlphaPower{cellLength, 1};
                %                 SleepData.(modelName).REM.data.hippocampus.specBetaBandPower{size(SleepData.(modelName).REM.data.hippocampus.specBetaBandPower, 1) + 1, 1} = cellHip_specBetaPower{cellLength, 1};
                %                 SleepData.(modelName).REM.data.hippocampus.specGammaBandPower{size(SleepData.(modelName).REM.data.hippocampus.specGammaBandPower, 1) + 1, 1} = cellHip_specGammaPower{cellLength, 1};
                %
                SleepData.(modelName).REM.data.CBV.LH{size(SleepData.(modelName).REM.data.CBV.LH, 1) + 1, 1} = cellLH_CBV{cellLength, 1};
                SleepData.(modelName).REM.data.CBV.RH{size(SleepData.(modelName).REM.data.CBV.RH, 1) + 1, 1} = cellRH_CBV{cellLength, 1};
                
                SleepData.(modelName).REM.data.CBV_HbT.LH{size(SleepData.(modelName).REM.data.CBV_HbT.LH, 1) + 1, 1} = cellLH_hbtCBV{cellLength, 1};
                SleepData.(modelName).REM.data.CBV_HbT.RH{size(SleepData.(modelName).REM.data.CBV_HbT.RH, 1) + 1, 1} = cellRH_hbtCBV{cellLength, 1};
                
                SleepData.(modelName).REM.data.WhiskerAcceleration{size(SleepData.(modelName).REM.data.WhiskerAcceleration, 1) + 1, 1} = cellWhiskerAcceleration{cellLength, 1};
                SleepData.(modelName).REM.data.HeartRate{size(SleepData.(modelName).REM.data.HeartRate, 1) + 1, 1} = cellHeartRate{cellLength, 1};
                SleepData.(modelName).REM.data.DopplerFlow{size(SleepData.(modelName).REM.data.DopplerFlow, 1) + 1, 1} = cellDopplerFlow{cellLength, 1};
                SleepData.(modelName).REM.FileIDs{size(SleepData.(modelName).REM.FileIDs, 1) + 1, 1} = fileID;
                SleepData.(modelName).REM.BinTimes{size(SleepData.(modelName).REM.BinTimes, 1) + 1, 1} = cellBinTimes{cellLength, 1};
            end
        end
    end
    disp(['Adding REM sleeping epochs from ProcData file ' num2str(a) ' of ' num2str(size(procDataFileIDs, 1)) '...']); disp(' ')
end
disp([modelName ' model data added to SleepData structure.']); disp(' ')
cd(startingDirectory)

end
