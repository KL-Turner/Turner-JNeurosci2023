function [] = AddSleepParameters_JNeurosci2022(procDataFileIDs,RestingBaselines,baselineType)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: Organize data into appropriate bins for sleep scoring characterization
%________________________________________________________________________________________________________________________

for a = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(a,:);
    disp(['Adding sleep scoring parameters to ' procDataFileID '... (' num2str(a) '/' num2str(size(procDataFileIDs,1)) ')']); disp(' ')
    [~, fileDate, ~] = GetFileInfo_JNeurosci2022(procDataFileID);
    strDay = ConvertDate_JNeurosci2022(fileDate);
    load(procDataFileID)
    specDataFileID = [procDataFileID(1:end-12) 'SpecDataA.mat'];
    load(specDataFileID)
    %% BLOCK PURPOSE: Create folder for the Neural data of each electrode
    % hippocampal delta
    hippDelta = ProcData.data.hippocampus.deltaBandPower;
    hippBaselineDelta = RestingBaselines.(baselineType).hippocampus.deltaBandPower.(strDay).mean;
    hippDeltaNeuro = (hippDelta - hippBaselineDelta)/hippBaselineDelta; 
    % cortical delta
    LH_Delta = ProcData.data.cortical_LH.deltaBandPower;
    RH_Delta = ProcData.data.cortical_RH.deltaBandPower;
    LH_baselineDelta = RestingBaselines.(baselineType).cortical_LH.deltaBandPower.(strDay).mean;
    RH_baselineDelta = RestingBaselines.(baselineType).cortical_RH.deltaBandPower.(strDay).mean;
    LH_DeltaNeuro = (LH_Delta-LH_baselineDelta)/LH_baselineDelta;
    RH_DeltaNeuro = (RH_Delta-RH_baselineDelta)/RH_baselineDelta;  
    % hippocampal theta
    hippTheta = ProcData.data.hippocampus.thetaBandPower;
    hippBaselineTheta = RestingBaselines.(baselineType).hippocampus.thetaBandPower.(strDay).mean;
    hippThetaNeuro = (hippTheta-hippBaselineTheta)/hippBaselineTheta; 
    % cortical theta
    LH_Theta = ProcData.data.cortical_LH.thetaBandPower;
    RH_Theta = ProcData.data.cortical_RH.thetaBandPower;
    LH_baselineTheta = RestingBaselines.(baselineType).cortical_LH.thetaBandPower.(strDay).mean;
    RH_baselineTheta = RestingBaselines.(baselineType).cortical_LH.thetaBandPower.(strDay).mean;
    LH_ThetaNeuro = (LH_Theta-LH_baselineTheta)/LH_baselineTheta;
    RH_ThetaNeuro = (RH_Theta-RH_baselineTheta)/RH_baselineTheta;
    % hippocampal alpha
    hippAlpha = ProcData.data.hippocampus.alphaBandPower;
    hippBaselineAlpha = RestingBaselines.(baselineType).hippocampus.alphaBandPower.(strDay).mean;
    hippAlphaNeuro = (hippAlpha-hippBaselineAlpha)/hippBaselineAlpha;  
    % cortical alpha
    LH_Alpha = ProcData.data.cortical_LH.alphaBandPower;
    RH_Alpha = ProcData.data.cortical_RH.alphaBandPower;
    LH_baselineAlpha = RestingBaselines.(baselineType).cortical_LH.alphaBandPower.(strDay).mean;
    RH_baselineAlpha = RestingBaselines.(baselineType).cortical_LH.alphaBandPower.(strDay).mean;
    LH_AlphaNeuro = (LH_Alpha-LH_baselineAlpha)/LH_baselineAlpha;
    RH_AlphaNeuro = (RH_Alpha-RH_baselineAlpha)/RH_baselineAlpha;   
    % hippocampal beta
    hippBeta = ProcData.data.hippocampus.betaBandPower;
    hippBaselineBeta = RestingBaselines.(baselineType).hippocampus.betaBandPower.(strDay).mean;
    hippBetaNeuro = (hippBeta-hippBaselineBeta)/hippBaselineBeta;  
    % cortical beta
    LH_Beta = ProcData.data.cortical_LH.betaBandPower;
    RH_Beta = ProcData.data.cortical_RH.betaBandPower;
    LH_baselineBeta = RestingBaselines.(baselineType).cortical_LH.betaBandPower.(strDay).mean;
    RH_baselineBeta = RestingBaselines.(baselineType).cortical_LH.betaBandPower.(strDay).mean;
    LH_BetaNeuro = (LH_Beta-LH_baselineBeta)/LH_baselineBeta;
    RH_BetaNeuro = (RH_Beta-RH_baselineBeta)/RH_baselineBeta;
    % hippocampal gamma
    hippGamma = ProcData.data.hippocampus.gammaBandPower;
    hippBaselineGamma = RestingBaselines.(baselineType).hippocampus.gammaBandPower.(strDay).mean;
    hippGammaNeuro = (hippGamma-hippBaselineGamma)/hippBaselineGamma;
    % cortical gamma
    LH_Gamma = ProcData.data.cortical_LH.gammaBandPower;
    RH_Gamma = ProcData.data.cortical_RH.gammaBandPower;
    LH_baselineGamma = RestingBaselines.(baselineType).cortical_LH.gammaBandPower.(strDay).mean;
    RH_baselineGamma = RestingBaselines.(baselineType).cortical_LH.gammaBandPower.(strDay).mean;
    LH_GammaNeuro = (LH_Gamma-LH_baselineGamma)/LH_baselineGamma;
    RH_GammaNeuro = (RH_Gamma-RH_baselineGamma)/RH_baselineGamma;
    % hippocampal MUA
    hippMUA = ProcData.data.hippocampus.muaPower;
    hippBaselineMUA = RestingBaselines.(baselineType).hippocampus.muaPower.(strDay).mean;
    hippMUANeuro = (hippMUA-hippBaselineMUA)/hippBaselineMUA;
    % cortical MUA
    LH_MUA = ProcData.data.cortical_LH.muaPower;
    RH_MUA = ProcData.data.cortical_RH.muaPower;
    LH_baselineMUA = RestingBaselines.(baselineType).cortical_LH.muaPower.(strDay).mean;
    RH_baselineMUA = RestingBaselines.(baselineType).cortical_LH.muaPower.(strDay).mean;
    LH_MUANeuro = (LH_MUA-LH_baselineMUA)/LH_baselineMUA;
    RH_MUANeuro = (RH_MUA-RH_baselineMUA)/RH_baselineMUA;
    % Divide the neural signals into five second bins and put them in a cell array
    hipptempDeltaStruct = cell(180,1);
    hipptempThetaStruct = cell(180,1);
    hipptempAlphaStruct = cell(180,1);
    hipptempBetaStruct = cell(180,1);
    hipptempGammaStruct = cell(180,1);
    hipptempMUAStruct = cell(180,1);
    LH_tempDeltaStruct = cell(180,1);
    RH_tempDeltaStruct = cell(180,1);
    LH_tempThetaStruct = cell(180,1);
    RH_tempThetaStruct = cell(180,1);
    LH_tempAlphaStruct = cell(180,1);
    RH_tempAlphaStruct = cell(180,1);
    LH_tempBetaStruct = cell(180,1);
    RH_tempBetaStruct = cell(180,1);
    LH_tempGammaStruct = cell(180,1);
    RH_tempGammaStruct = cell(180,1);
    LH_tempMUAStruct = cell(180,1);
    RH_tempMUAStruct = cell(180,1);
    % loop through all samples across the 15 minutes in 5 second bins (180 total)
    for b = 1:180
        if b == 1
            % hippocampal
            hipptempDeltaStruct(b,1) = {hippDeltaNeuro(b:150)};
            hipptempThetaStruct(b,1) = {hippThetaNeuro(b:150)};
            hipptempAlphaStruct(b,1) = {hippAlphaNeuro(b:150)};
            hipptempBetaStruct(b,1) = {hippBetaNeuro(b:150)};
            hipptempGammaStruct(b,1) = {hippGammaNeuro(b:150)};
            hipptempMUAStruct(b,1) = {hippMUANeuro(b:150)};
            % cortical
            LH_tempDeltaStruct(b,1) = {LH_DeltaNeuro(b:150)};
            RH_tempDeltaStruct(b,1) = {RH_DeltaNeuro(b:150)};
            LH_tempThetaStruct(b,1) = {LH_ThetaNeuro(b:150)};
            RH_tempThetaStruct(b,1) = {RH_ThetaNeuro(b:150)};
            LH_tempAlphaStruct(b,1) = {LH_AlphaNeuro(b:150)};
            RH_tempAlphaStruct(b,1) = {RH_AlphaNeuro(b:150)};
            LH_tempBetaStruct(b,1) = {LH_BetaNeuro(b:150)};
            RH_tempBetaStruct(b,1) = {RH_BetaNeuro(b:150)};
            LH_tempGammaStruct(b,1) = {LH_GammaNeuro(b:150)};
            RH_tempGammaStruct(b,1) = {RH_GammaNeuro(b:150)};
            LH_tempMUAStruct(b,1) = {LH_MUANeuro(b:150)};
            RH_tempMUAStruct(b,1) = {RH_MUANeuro(b:150)};
        elseif b == 180
            % hippocampal
            hipptempDeltaStruct(b,1) = {hippDeltaNeuro((((150*(b - 1)) + 1)):end)};
            hipptempThetaStruct(b,1) = {hippThetaNeuro((((150*(b - 1)) + 1)):end)};
            hipptempAlphaStruct(b,1) = {hippAlphaNeuro((((150*(b - 1)) + 1)):end)};
            hipptempBetaStruct(b,1) = {hippBetaNeuro((((150*(b - 1)) + 1)):end)};
            hipptempGammaStruct(b,1) = {hippGammaNeuro((((150*(b - 1)) + 1)):end)};
            hipptempMUAStruct(b,1) = {hippMUANeuro((((150*(b - 1)) + 1)):end)};
            % cortical
            LH_tempDeltaStruct(b,1) = {LH_DeltaNeuro((((150*(b - 1)) + 1)):end)};
            RH_tempDeltaStruct(b,1) = {RH_DeltaNeuro((((150*(b - 1)) + 1)):end)};
            LH_tempThetaStruct(b,1) = {LH_ThetaNeuro((((150*(b - 1)) + 1)):end)};
            RH_tempThetaStruct(b,1) = {RH_ThetaNeuro((((150*(b - 1)) + 1)):end)};
            LH_tempAlphaStruct(b,1) = {LH_AlphaNeuro((((150*(b - 1)) + 1)):end)};
            RH_tempAlphaStruct(b,1) = {RH_AlphaNeuro((((150*(b - 1)) + 1)):end)};
            LH_tempBetaStruct(b,1) = {LH_BetaNeuro((((150*(b - 1)) + 1)):end)};
            RH_tempBetaStruct(b,1) = {RH_BetaNeuro((((150*(b - 1)) + 1)):end)};
            LH_tempGammaStruct(b,1) = {LH_GammaNeuro((((150*(b - 1)) + 1)):end)};
            RH_tempGammaStruct(b,1) = {RH_GammaNeuro((((150*(b - 1)) + 1)):end)};
            LH_tempMUAStruct(b,1) = {LH_MUANeuro((((150*(b - 1)) + 1)):end)};
            RH_tempMUAStruct(b,1) = {RH_MUANeuro((((150*(b - 1)) + 1)):end)};
        else
            % hippocampal
            hipptempDeltaStruct(b,1) = {hippDeltaNeuro((((150*(b - 1)) + 1)):(150*b))};
            hipptempThetaStruct(b,1) = {hippThetaNeuro((((150*(b - 1)) + 1)):(150*b))};
            hipptempAlphaStruct(b,1) = {hippAlphaNeuro((((150*(b - 1)) + 1)):(150*b))};
            hipptempBetaStruct(b,1) = {hippBetaNeuro((((150*(b - 1)) + 1)):(150*b))};
            hipptempGammaStruct(b,1) = {hippGammaNeuro((((150*(b - 1)) + 1)):(150*b))};
            hipptempMUAStruct(b,1) = {hippMUANeuro((((150*(b - 1)) + 1)):(150*b))};
            % cortical
            LH_tempDeltaStruct(b,1) = {LH_DeltaNeuro((((150*(b - 1)) + 1)):(150*b))};
            RH_tempDeltaStruct(b,1) = {RH_DeltaNeuro((((150*(b - 1)) + 1)):(150*b))};
            LH_tempThetaStruct(b,1) = {LH_ThetaNeuro((((150*(b - 1)) + 1)):(150*b))};
            RH_tempThetaStruct(b,1) = {RH_ThetaNeuro((((150*(b - 1)) + 1)):(150*b))};
            LH_tempAlphaStruct(b,1) = {LH_AlphaNeuro((((150*(b - 1)) + 1)):(150*b))};
            RH_tempAlphaStruct(b,1) = {RH_AlphaNeuro((((150*(b - 1)) + 1)):(150*b))};
            LH_tempBetaStruct(b,1) = {LH_BetaNeuro((((150*(b - 1)) + 1)):(150*b))};
            RH_tempBetaStruct(b,1) = {RH_BetaNeuro((((150*(b - 1)) + 1)):(150*b))};
            LH_tempGammaStruct(b,1) = {LH_GammaNeuro((((150*(b - 1)) + 1)):(150*b))};
            RH_tempGammaStruct(b,1) = {RH_GammaNeuro((((150*(b - 1)) + 1)):(150*b))};
            LH_tempMUAStruct(b,1) = {LH_MUANeuro((((150*(b - 1)) + 1)):(150*b))};
            RH_tempMUAStruct(b,1) = {RH_MUANeuro((((150*(b - 1)) + 1)):(150*b))};
        end
    end
    % save hippocampal data under ProcData file
    ProcData.sleep.parameters.hippocampus.deltaBandPower = hipptempDeltaStruct;
    ProcData.sleep.parameters.hippocampus.thetaBandPower = hipptempThetaStruct;
    ProcData.sleep.parameters.hippocampus.alphaBandPower = hipptempThetaStruct;
    ProcData.sleep.parameters.hippocampus.betaBandPower = hipptempBetaStruct;
    ProcData.sleep.parameters.hippocampus.gammaBandPower = hipptempGammaStruct;
    ProcData.sleep.parameters.hippocampus.muaPower = hipptempMUAStruct;
    % save cortical data under ProcData file
    ProcData.sleep.parameters.cortical_LH.deltaBandPower = LH_tempDeltaStruct;
    ProcData.sleep.parameters.cortical_RH.deltaBandPower = RH_tempDeltaStruct;
    ProcData.sleep.parameters.cortical_LH.thetaBandPower = LH_tempThetaStruct;
    ProcData.sleep.parameters.cortical_RH.thetaBandPower = RH_tempThetaStruct;
    ProcData.sleep.parameters.cortical_LH.alphaBandPower = LH_tempAlphaStruct;
    ProcData.sleep.parameters.cortical_RH.alphaBandPower = RH_tempAlphaStruct;
    ProcData.sleep.parameters.cortical_LH.betaBandPower = LH_tempBetaStruct;
    ProcData.sleep.parameters.cortical_RH.betaBandPower = RH_tempBetaStruct;
    ProcData.sleep.parameters.cortical_LH.gammaBandPower = LH_tempGammaStruct;
    ProcData.sleep.parameters.cortical_RH.gammaBandPower = RH_tempGammaStruct;
    ProcData.sleep.parameters.cortical_LH.muaPower = LH_tempMUAStruct;
    ProcData.sleep.parameters.cortical_RH.muaPower = RH_tempMUAStruct;
    
    %% BLOCK PURPOSE: Create folder for the Neural spectrogram data of each electrode
    trialDuration_sec = 900;   % sec
    offset = 2.5;   % sec
    binWidth = 5;   % sec
    T = round(SpecData.cortical_LH.T,1);
    F = SpecData.cortical_LH.F;
    specLH = SpecData.cortical_LH.normS;
    specRH = SpecData.cortical_RH.normS;
    specHip = SpecData.hippocampus.normS;
    freqFloor = floor(F);
    % delta
    deltaLow = freqFloor == 1;
    deltaHigh = freqFloor == 4;
    deltaLowStart = find(deltaLow,1,'first');
    deltaLowEnd = find(deltaHigh,1,'last');
    deltaSpecHip = specHip(deltaLowStart:deltaLowEnd,:);
    deltaSpecLH = specLH(deltaLowStart:deltaLowEnd,:);
    deltaSpecRH = specRH(deltaLowStart:deltaLowEnd,:);
    meanDeltaSpecHip = mean(deltaSpecHip,1);
    meanDeltaSpecLH = mean(deltaSpecLH,1);
    meanDeltaSpecRH = mean(deltaSpecRH,1);
    % theta
    thetaLow = freqFloor == 4;
    thetaHigh = freqFloor == 10;
    thetaLowStart = find(thetaLow,1,'first');
    thetaLowEnd = find(thetaHigh,1,'last');
    thetaSpecHip = specHip(thetaLowStart:thetaLowEnd,:);
    thetaSpecLH = specLH(thetaLowStart:thetaLowEnd,:);
    thetaSpecRH = specRH(thetaLowStart:thetaLowEnd,:);
    meanThetaSpecHip = mean(thetaSpecHip,1);
    meanThetaSpecLH = mean(thetaSpecLH,1);
    meanThetaSpecRH = mean(thetaSpecRH,1);
    % alpha
    alphaLow = freqFloor == 10;
    alphaHigh = freqFloor == 13;
    alphaLowStart = find(alphaLow,1,'first');
    alphaLowEnd = find(alphaHigh,1,'last');
    alphaSpecHip = specHip(alphaLowStart:alphaLowEnd,:);
    alphaSpecLH = specLH(alphaLowStart:alphaLowEnd,:);
    alphaSpecRH = specRH(alphaLowStart:alphaLowEnd,:);
    meanAlphaSpecHip = mean(alphaSpecHip,1);
    meanAlphaSpecLH = mean(alphaSpecLH,1);
    meanAlphaSpecRH = mean(alphaSpecRH,1);
    % beta
    betaLow = freqFloor == 13;
    betaHigh = freqFloor == 30;
    betaLowStart = find(betaLow,1,'first');
    betaLowEnd = find(betaHigh,1,'last');
    betaSpecHip = specHip(betaLowStart:betaLowEnd,:);
    betaSpecLH = specLH(betaLowStart:betaLowEnd,:);
    betaSpecRH = specRH(betaLowStart:betaLowEnd,:);
    meanBetaSpecHip = mean(betaSpecHip,1);
    meanBetaSpecLH = mean(betaSpecLH,1);
    meanBetaSpecRH = mean(betaSpecRH,1);
    % gamma
    gammaLow = freqFloor == 30;
    gammaHigh = freqFloor == 99;
    gammaLowStart = find(gammaLow,1,'first');
    gammaLowEnd = find(gammaHigh,1,'last');
    gammaSpecHip = specHip(gammaLowStart:gammaLowEnd,:);
    gammaSpecLH = specLH(gammaLowStart:gammaLowEnd,:);
    gammaSpecRH = specRH(gammaLowStart:gammaLowEnd,:);
    meanGammaSpecHip = mean(gammaSpecHip,1);
    meanGammaSpecRH = mean(gammaSpecRH,1);
    meanGammaSpecLH = mean(gammaSpecLH,1);
    % Divide the neural signals into five second bins and put them in a cell array
    hipptempDeltaSpecStruct = cell(180,1);
    hipptempThetaSpecStruct = cell(180,1);
    hipptempAlphaSpecStruct = cell(180,1);
    hipptempBetaSpecStruct = cell(180,1);
    hipptempGammaSpecStruct = cell(180,1);
    LH_tempDeltaSpecStruct = cell(180,1);
    RH_tempDeltaSpecStruct = cell(180,1);
    LH_tempThetaSpecStruct = cell(180,1);
    RH_tempThetaSpecStruct = cell(180,1);
    LH_tempAlphaSpecStruct = cell(180,1);
    RH_tempAlphaSpecStruct = cell(180,1);
    LH_tempBetaSpecStruct = cell(180,1);
    RH_tempBetaSpecStruct = cell(180,1);
    LH_tempGammaSpecStruct = cell(180,1);
    RH_tempGammaSpecStruct = cell(180,1);
    % loop through all samples across the 15 minutes in 5 second bins (180 total)
    for c = 1:180
        if c == 1
            startTime = offset;
            startTime_index = find(T == startTime);
            endTime = 5;
            [~,endTime_index] = min(abs(T - endTime));
            % hippocampal
            hipptempDeltaSpecStruct{c,1} = {meanDeltaSpecHip(startTime_index:endTime_index)};
            hipptempThetaSpecStruct{c,1} = {meanThetaSpecHip(startTime_index:endTime_index)};
            hipptempAlphaSpecStruct{c,1} = {meanAlphaSpecHip(startTime_index:endTime_index)};
            hipptempBetaSpecStruct{c,1} = {meanBetaSpecHip(startTime_index:endTime_index)};
            hipptempGammaSpecStruct{c,1} = {meanGammaSpecHip(startTime_index:endTime_index)};
            % cortical
            LH_tempDeltaSpecStruct{c,1} = {meanDeltaSpecLH(startTime_index:endTime_index)};
            RH_tempDeltaSpecStruct{c,1} = {meanDeltaSpecRH(startTime_index:endTime_index)};
            LH_tempThetaSpecStruct{c,1} = {meanThetaSpecLH(startTime_index:endTime_index)};
            RH_tempThetaSpecStruct{c,1} = {meanThetaSpecRH(startTime_index:endTime_index)};
            LH_tempAlphaSpecStruct{c,1} = {meanAlphaSpecLH(startTime_index:endTime_index)};
            RH_tempAlphaSpecStruct{c,1} = {meanAlphaSpecRH(startTime_index:endTime_index)};
            LH_tempBetaSpecStruct{c,1} = {meanBetaSpecLH(startTime_index:endTime_index)};
            RH_tempBetaSpecStruct{c,1} = {meanBetaSpecRH(startTime_index:endTime_index)};
            LH_tempGammaSpecStruct{c,1} = {meanGammaSpecLH(startTime_index:endTime_index)};
            RH_tempGammaSpecStruct{c,1} = {meanGammaSpecRH(startTime_index:endTime_index)};
        elseif c == 180
            startTime = trialDuration_sec - 5;
            [~,startTime_index] = min(abs(T - startTime));
            endTime = trialDuration_sec - offset;
            [~,endTime_index] = min(abs(T - endTime));
            % hippocampal
            hipptempDeltaSpecStruct{c,1} = {meanDeltaSpecHip(startTime_index:endTime_index)};
            hipptempThetaSpecStruct{c,1} = {meanThetaSpecHip(startTime_index:endTime_index)};
            hipptempAlphaSpecStruct{c,1} = {meanAlphaSpecHip(startTime_index:endTime_index)};
            hipptempBetaSpecStruct{c,1} = {meanBetaSpecHip(startTime_index:endTime_index)};
            hipptempGammaSpecStruct{c,1} = {meanGammaSpecHip(startTime_index:endTime_index)};
            % cortical
            LH_tempDeltaSpecStruct{c,1} = {meanDeltaSpecLH(startTime_index:endTime_index)};
            RH_tempDeltaSpecStruct{c,1} = {meanDeltaSpecRH(startTime_index:endTime_index)};
            LH_tempThetaSpecStruct{c,1} = {meanThetaSpecLH(startTime_index:endTime_index)};
            RH_tempThetaSpecStruct{c,1} = {meanThetaSpecRH(startTime_index:endTime_index)};
            LH_tempAlphaSpecStruct{c,1} = {meanAlphaSpecLH(startTime_index:endTime_index)};
            RH_tempAlphaSpecStruct{c,1} = {meanAlphaSpecRH(startTime_index:endTime_index)};
            LH_tempBetaSpecStruct{c,1} = {meanBetaSpecLH(startTime_index:endTime_index)};
            RH_tempBetaSpecStruct{c,1} = {meanBetaSpecRH(startTime_index:endTime_index)};
            LH_tempGammaSpecStruct{c,1} = {meanGammaSpecLH(startTime_index:endTime_index)};
            RH_tempGammaSpecStruct{c,1} = {meanGammaSpecRH(startTime_index:endTime_index)};
        else
            startTime = binWidth*(c - 1);
            [~,startTime_index] = min(abs(T - startTime));
            endTime = binWidth*c;
            [~,endTime_index] = min(abs(T - endTime));
            % hippocampal
            hipptempDeltaSpecStruct{c,1} = {meanDeltaSpecHip(startTime_index + 1:endTime_index + 1)};
            hipptempThetaSpecStruct{c,1} = {meanThetaSpecHip(startTime_index + 1:endTime_index + 1)};
            hipptempAlphaSpecStruct{c,1} = {meanAlphaSpecHip(startTime_index + 1:endTime_index + 1)};
            hipptempBetaSpecStruct{c,1} = {meanBetaSpecHip(startTime_index + 1:endTime_index + 1)};
            hipptempGammaSpecStruct{c,1} = {meanGammaSpecHip(startTime_index + 1:endTime_index + 1)};
            % cortical
            LH_tempDeltaSpecStruct{c,1} = {meanDeltaSpecLH(startTime_index + 1:endTime_index + 1)};
            RH_tempDeltaSpecStruct{c,1} = {meanDeltaSpecRH(startTime_index + 1:endTime_index + 1)};
            LH_tempThetaSpecStruct{c,1} = {meanThetaSpecLH(startTime_index + 1:endTime_index + 1)};
            RH_tempThetaSpecStruct{c,1} = {meanThetaSpecRH(startTime_index + 1:endTime_index + 1)};
            LH_tempAlphaSpecStruct{c,1} = {meanAlphaSpecLH(startTime_index + 1:endTime_index + 1)};
            RH_tempAlphaSpecStruct{c,1} = {meanAlphaSpecRH(startTime_index + 1:endTime_index + 1)};
            LH_tempBetaSpecStruct{c,1} = {meanBetaSpecLH(startTime_index + 1:endTime_index + 1)};
            RH_tempBetaSpecStruct{c,1} = {meanBetaSpecRH(startTime_index + 1:endTime_index + 1)};
            LH_tempGammaSpecStruct{c,1} = {meanGammaSpecLH(startTime_index + 1:endTime_index + 1)};
            RH_tempGammaSpecStruct{c,1} = {meanGammaSpecRH(startTime_index + 1:endTime_index + 1)};
        end
    end
    % save hippocampal data under ProcData file
    ProcData.sleep.parameters.hippocampus.specDeltaBandPower = hipptempDeltaSpecStruct;
    ProcData.sleep.parameters.hippocampus.specThetaBandPower = hipptempThetaSpecStruct;
    ProcData.sleep.parameters.hippocampus.specAlphaBandPower = hipptempAlphaSpecStruct;
    ProcData.sleep.parameters.hippocampus.specBetaBandPower = hipptempBetaSpecStruct;
    ProcData.sleep.parameters.hippocampus.specGammaBandPower = hipptempGammaSpecStruct;
    % save cortical data under ProcData file
    ProcData.sleep.parameters.cortical_LH.specDeltaBandPower = LH_tempDeltaSpecStruct;
    ProcData.sleep.parameters.cortical_RH.specDeltaBandPower = RH_tempDeltaSpecStruct;
    ProcData.sleep.parameters.cortical_LH.specThetaBandPower = LH_tempThetaSpecStruct;
    ProcData.sleep.parameters.cortical_RH.specThetaBandPower = RH_tempThetaSpecStruct;
    ProcData.sleep.parameters.cortical_LH.specAlphaBandPower = LH_tempAlphaSpecStruct;
    ProcData.sleep.parameters.cortical_RH.specAlphaBandPower = RH_tempAlphaSpecStruct;
    ProcData.sleep.parameters.cortical_LH.specBetaBandPower = LH_tempBetaSpecStruct;
    ProcData.sleep.parameters.cortical_RH.specBetaBandPower = RH_tempBetaSpecStruct;
    ProcData.sleep.parameters.cortical_LH.specGammaBandPower = LH_tempGammaSpecStruct;
    ProcData.sleep.parameters.cortical_RH.specGammaBandPower = RH_tempGammaSpecStruct;
    
    %% BLOCK PURPOSE: Create folder for binarized whisking and binarized force sensor
    binWhiskerAngle = ProcData.data.binWhiskerAngle;
    binForceSensor = ProcData.data.binForceSensor;
    whiskerAngle = ProcData.data.whiskerAngle;
    whiskerAcceleration = diff(whiskerAngle,2);
    % Find the number of whiskerBins due to frame drops.
    whiskerBinNumber = 180;
    % Divide the signal into five second bins and put them in a cell array
    tempWhiskerStruct = cell(whiskerBinNumber,1);
    tempWhiskerAccelStruct = cell(whiskerBinNumber,1);
    tempBinWhiskerStruct = cell(whiskerBinNumber,1);
    tempForceStruct = cell(whiskerBinNumber,1);
    for whiskerBins = 1:whiskerBinNumber
        if whiskerBins == 1
            tempWhiskerStruct(whiskerBins, 1) = {whiskerAngle(whiskerBins:150)};
            tempWhiskerAccelStruct(whiskerBins, 1) = {whiskerAcceleration(whiskerBins:150)};
            tempBinWhiskerStruct(whiskerBins, 1) = {binWhiskerAngle(whiskerBins:150)};
            tempForceStruct(whiskerBins, 1) = {binForceSensor(whiskerBins:150)};
        elseif whiskerBins == whiskerBinNumber
            tempWhiskerStruct(whiskerBins, 1) = {whiskerAngle((((150*(whiskerBins-1)) + 1)):end)};
            tempWhiskerAccelStruct(whiskerBins, 1) = {whiskerAcceleration((((150*(whiskerBins-1)) + 1)):end)};
            tempBinWhiskerStruct(whiskerBins, 1) = {binWhiskerAngle((((150*(whiskerBins-1)) + 1)):end)};
            tempForceStruct(whiskerBins, 1) = {binForceSensor((((150*(whiskerBins-1)) + 1)):end)};
        else
            tempWhiskerStruct(whiskerBins, 1) = {whiskerAngle((((150*(whiskerBins-1)) + 1)):(150*whiskerBins))};
            tempWhiskerAccelStruct(whiskerBins, 1) = {whiskerAcceleration((((150*(whiskerBins-1)) + 1)):(150*whiskerBins))};
            tempBinWhiskerStruct(whiskerBins, 1) = {binWhiskerAngle((((150*(whiskerBins-1)) + 1)):(150*whiskerBins))};
            tempForceStruct(whiskerBins, 1) = {binForceSensor((((150*(whiskerBins-1)) + 1)):(150*whiskerBins))};
        end
    end
    % save whisker and force sensor data under ProcData file
    ProcData.sleep.parameters.whiskerAngle = tempWhiskerStruct;
    ProcData.sleep.parameters.whiskerAcceleration = tempWhiskerAccelStruct;
    ProcData.sleep.parameters.binWhiskerAngle = tempBinWhiskerStruct;
    ProcData.sleep.parameters.binForceSensor = tempForceStruct;
    
    %% Create folder for the EMG
    EMG = ProcData.data.EMG.emg;
    normEMG = EMG - RestingBaselines.(baselineType).EMG.emg.(strDay).mean;  
    tempEMGStruct = cell(180,1);
    for EMGBins = 1:180
        if EMGBins == 1
            tempEMGStruct(EMGBins,1) = {normEMG(EMGBins:150)};
        else
            tempEMGStruct(EMGBins,1) = {normEMG((((150*(EMGBins-1)) + 1)):(150*EMGBins))};
        end
    end
    % save EMG data under ProcData file
    ProcData.sleep.parameters.EMG = tempEMGStruct;
    
    %% Create folder for the doppler flow
    if isfield(ProcData.data,'flow') == true
        Flow = ProcData.data.flow.data;
    else
        Flow = NaN*ProcData.data.EMG.emg;
    end
    try
        normFlow = (Flow - RestingBaselines.(baselineType).flow.data.(strDay).mean)/RestingBaselines.(baselineType).flow.data.(strDay).mean;
    catch
        normFlow = Flow;
    end
    tempFlowStruct = cell(180,1);
    for FlowBins = 1:180
        if FlowBins == 1
            tempFlowStruct(FlowBins,1) = {normFlow(FlowBins:150)};
        else
            try
                tempFlowStruct(FlowBins,1) = {normFlow((((150*(FlowBins-1)) + 1)):(150*FlowBins))};
            catch
                tempFlowStruct(FlowBins,1) = {normFlow((((150*(FlowBins-1)) + 1)):end)};
            end
        end
    end
    % save doppler flow data under ProcData file
    ProcData.sleep.parameters.flow = tempFlowStruct;
    
    %% BLOCK PURPOSE: Create folder for the Heart Rate
    % Find the heart rate from the current ProcData file
    HeartRate = ProcData.data.heartRate;
    % Divide the signal into five second bins and put them in a cell array
    tempHRStruct = cell(180,1);
    for HRBins = 1:180
        if HRBins == 1
            tempHRStruct(HRBins,1) = {HeartRate(HRBins:5)};  % Samples 1 to 5
        else
            tempHRStruct(HRBins,1) = {HeartRate((((5*(HRBins-1)) + 1)):(5*HRBins))};  % Samples 6 to 10, etc...
        end
    end
    % save heart rate data under ProcData file
    ProcData.sleep.parameters.heartRate = tempHRStruct;   % Place the data in the ProcData struct to later be saved
    
    %% BLOCK PURPOSE: Create folder for the left and right CBV data
    CBVfs = ProcData.notes.CBVCamSamplingRate;
    timeBin = 5;
    LH_CBV = ProcData.data.CBV.adjLH;
    RH_CBV = ProcData.data.CBV.adjRH;  
    LH_NormCBV = (LH_CBV-RestingBaselines.(baselineType).CBV.adjLH.(strDay).mean)/RestingBaselines.(baselineType).CBV.adjLH.(strDay).mean;
    RH_NormCBV = (RH_CBV-RestingBaselines.(baselineType).CBV.adjRH.(strDay).mean)/RestingBaselines.(baselineType).CBV.adjRH.(strDay).mean;        
    LH_HbT = ProcData.data.CBV_HbT.adjLH;
    RH_HbT = ProcData.data.CBV_HbT.adjRH;  
    LH_tempCBVStruct = cell(180,1);
    RH_tempCBVStruct = cell(180,1);
    hbtLH_tempCBVStruct = cell(180,1);
    hbtRH_tempCBVStruct = cell(180,1);
    for CBVBins = 1:180
        if CBVBins == 1
            LH_tempCBVStruct(CBVBins,1) = {LH_NormCBV(CBVBins:CBVfs*timeBin)};  % Samples 1 to 150
            RH_tempCBVStruct(CBVBins,1) = {RH_NormCBV(CBVBins:CBVfs*timeBin)};
            hbtLH_tempCBVStruct(CBVBins,1) = {LH_HbT(CBVBins:CBVfs*timeBin)};  % Samples 1 to 150
            hbtRH_tempCBVStruct(CBVBins,1) = {RH_HbT(CBVBins:CBVfs*timeBin)};
        else
            LH_tempCBVStruct(CBVBins,1) = {LH_NormCBV((((CBVfs*timeBin*(CBVBins - 1)) + 1)):(CBVfs*timeBin*CBVBins))};  % Samples 151 to 300, etc...
            RH_tempCBVStruct(CBVBins,1) = {RH_NormCBV((((CBVfs*timeBin*(CBVBins - 1)) + 1)):(CBVfs*timeBin*CBVBins))};
            hbtLH_tempCBVStruct(CBVBins,1) = {LH_HbT((((CBVfs*timeBin*(CBVBins - 1)) + 1)):(CBVfs*timeBin*CBVBins))};  % Samples 151 to 300, etc...
            hbtRH_tempCBVStruct(CBVBins,1) = {RH_HbT((((CBVfs*timeBin*(CBVBins - 1)) + 1)):(CBVfs*timeBin*CBVBins))};
        end
    end
    % save hemodynamic data under ProcData file
    ProcData.sleep.parameters.CBV.LH = LH_tempCBVStruct;
    ProcData.sleep.parameters.CBV.RH = RH_tempCBVStruct;
    ProcData.sleep.parameters.CBV.hbtLH = hbtLH_tempCBVStruct;
    ProcData.sleep.parameters.CBV.hbtRH = hbtRH_tempCBVStruct;
    save(procDataFileID,'ProcData');
end

end
