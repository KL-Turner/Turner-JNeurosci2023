function [] = AddSleepParameters_Turner2022(procDataFileIDs,RestingBaselines,baselineType)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Organize data into appropriate bins for sleep scoring characterization
%________________________________________________________________________________________________________________________

for aa = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(aa,:);
    [~,fileDate,~] = GetFileInfo_Turner2022(procDataFileID);
    strDay = ConvertDate_Turner2022(fileDate);
    load(procDataFileID)
    specDataFileID = [procDataFileID(1:end-12) 'SpecDataA.mat'];
    load(specDataFileID)
    % create folder for the neural data of each electrode
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
    % divide the neural signals into five second bins and put them in a cell array
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
    for bb = 1:180
        if bb == 1
            % hippocampal
            hipptempDeltaStruct(bb,1) = {hippDeltaNeuro(bb:150)};
            hipptempThetaStruct(bb,1) = {hippThetaNeuro(bb:150)};
            hipptempAlphaStruct(bb,1) = {hippAlphaNeuro(bb:150)};
            hipptempBetaStruct(bb,1) = {hippBetaNeuro(bb:150)};
            hipptempGammaStruct(bb,1) = {hippGammaNeuro(bb:150)};
            hipptempMUAStruct(bb,1) = {hippMUANeuro(bb:150)};
            % cortical
            LH_tempDeltaStruct(bb,1) = {LH_DeltaNeuro(bb:150)};
            RH_tempDeltaStruct(bb,1) = {RH_DeltaNeuro(bb:150)};
            LH_tempThetaStruct(bb,1) = {LH_ThetaNeuro(bb:150)};
            RH_tempThetaStruct(bb,1) = {RH_ThetaNeuro(bb:150)};
            LH_tempAlphaStruct(bb,1) = {LH_AlphaNeuro(bb:150)};
            RH_tempAlphaStruct(bb,1) = {RH_AlphaNeuro(bb:150)};
            LH_tempBetaStruct(bb,1) = {LH_BetaNeuro(bb:150)};
            RH_tempBetaStruct(bb,1) = {RH_BetaNeuro(bb:150)};
            LH_tempGammaStruct(bb,1) = {LH_GammaNeuro(bb:150)};
            RH_tempGammaStruct(bb,1) = {RH_GammaNeuro(bb:150)};
            LH_tempMUAStruct(bb,1) = {LH_MUANeuro(bb:150)};
            RH_tempMUAStruct(bb,1) = {RH_MUANeuro(bb:150)};
        elseif bb == 180
            % hippocampal
            hipptempDeltaStruct(bb,1) = {hippDeltaNeuro((((150*(bb - 1)) + 1)):end)};
            hipptempThetaStruct(bb,1) = {hippThetaNeuro((((150*(bb - 1)) + 1)):end)};
            hipptempAlphaStruct(bb,1) = {hippAlphaNeuro((((150*(bb - 1)) + 1)):end)};
            hipptempBetaStruct(bb,1) = {hippBetaNeuro((((150*(bb - 1)) + 1)):end)};
            hipptempGammaStruct(bb,1) = {hippGammaNeuro((((150*(bb - 1)) + 1)):end)};
            hipptempMUAStruct(bb,1) = {hippMUANeuro((((150*(bb - 1)) + 1)):end)};
            % cortical
            LH_tempDeltaStruct(bb,1) = {LH_DeltaNeuro((((150*(bb - 1)) + 1)):end)};
            RH_tempDeltaStruct(bb,1) = {RH_DeltaNeuro((((150*(bb - 1)) + 1)):end)};
            LH_tempThetaStruct(bb,1) = {LH_ThetaNeuro((((150*(bb - 1)) + 1)):end)};
            RH_tempThetaStruct(bb,1) = {RH_ThetaNeuro((((150*(bb - 1)) + 1)):end)};
            LH_tempAlphaStruct(bb,1) = {LH_AlphaNeuro((((150*(bb - 1)) + 1)):end)};
            RH_tempAlphaStruct(bb,1) = {RH_AlphaNeuro((((150*(bb - 1)) + 1)):end)};
            LH_tempBetaStruct(bb,1) = {LH_BetaNeuro((((150*(bb - 1)) + 1)):end)};
            RH_tempBetaStruct(bb,1) = {RH_BetaNeuro((((150*(bb - 1)) + 1)):end)};
            LH_tempGammaStruct(bb,1) = {LH_GammaNeuro((((150*(bb - 1)) + 1)):end)};
            RH_tempGammaStruct(bb,1) = {RH_GammaNeuro((((150*(bb - 1)) + 1)):end)};
            LH_tempMUAStruct(bb,1) = {LH_MUANeuro((((150*(bb - 1)) + 1)):end)};
            RH_tempMUAStruct(bb,1) = {RH_MUANeuro((((150*(bb - 1)) + 1)):end)};
        else
            % hippocampal
            hipptempDeltaStruct(bb,1) = {hippDeltaNeuro((((150*(bb - 1)) + 1)):(150*bb))};
            hipptempThetaStruct(bb,1) = {hippThetaNeuro((((150*(bb - 1)) + 1)):(150*bb))};
            hipptempAlphaStruct(bb,1) = {hippAlphaNeuro((((150*(bb - 1)) + 1)):(150*bb))};
            hipptempBetaStruct(bb,1) = {hippBetaNeuro((((150*(bb - 1)) + 1)):(150*bb))};
            hipptempGammaStruct(bb,1) = {hippGammaNeuro((((150*(bb - 1)) + 1)):(150*bb))};
            hipptempMUAStruct(bb,1) = {hippMUANeuro((((150*(bb - 1)) + 1)):(150*bb))};
            % cortical
            LH_tempDeltaStruct(bb,1) = {LH_DeltaNeuro((((150*(bb - 1)) + 1)):(150*bb))};
            RH_tempDeltaStruct(bb,1) = {RH_DeltaNeuro((((150*(bb - 1)) + 1)):(150*bb))};
            LH_tempThetaStruct(bb,1) = {LH_ThetaNeuro((((150*(bb - 1)) + 1)):(150*bb))};
            RH_tempThetaStruct(bb,1) = {RH_ThetaNeuro((((150*(bb - 1)) + 1)):(150*bb))};
            LH_tempAlphaStruct(bb,1) = {LH_AlphaNeuro((((150*(bb - 1)) + 1)):(150*bb))};
            RH_tempAlphaStruct(bb,1) = {RH_AlphaNeuro((((150*(bb - 1)) + 1)):(150*bb))};
            LH_tempBetaStruct(bb,1) = {LH_BetaNeuro((((150*(bb - 1)) + 1)):(150*bb))};
            RH_tempBetaStruct(bb,1) = {RH_BetaNeuro((((150*(bb - 1)) + 1)):(150*bb))};
            LH_tempGammaStruct(bb,1) = {LH_GammaNeuro((((150*(bb - 1)) + 1)):(150*bb))};
            RH_tempGammaStruct(bb,1) = {RH_GammaNeuro((((150*(bb - 1)) + 1)):(150*bb))};
            LH_tempMUAStruct(bb,1) = {LH_MUANeuro((((150*(bb - 1)) + 1)):(150*bb))};
            RH_tempMUAStruct(bb,1) = {RH_MUANeuro((((150*(bb - 1)) + 1)):(150*bb))};
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
    % create folder for the neural spectrogram data of each electrode
    trialDuration_sec = 900; % sec
    offset = 2.5; % sec
    binWidth = 5; % sec
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
    % divide the neural signals into five second bins and put them in a cell array
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
    for cc = 1:180
        if cc == 1
            startTime = offset;
            startTime_index = find(T == startTime);
            endTime = 5;
            [~,endTime_index] = min(abs(T - endTime));
            % hippocampal
            hipptempDeltaSpecStruct{cc,1} = {meanDeltaSpecHip(startTime_index:endTime_index)};
            hipptempThetaSpecStruct{cc,1} = {meanThetaSpecHip(startTime_index:endTime_index)};
            hipptempAlphaSpecStruct{cc,1} = {meanAlphaSpecHip(startTime_index:endTime_index)};
            hipptempBetaSpecStruct{cc,1} = {meanBetaSpecHip(startTime_index:endTime_index)};
            hipptempGammaSpecStruct{cc,1} = {meanGammaSpecHip(startTime_index:endTime_index)};
            % cortical
            LH_tempDeltaSpecStruct{cc,1} = {meanDeltaSpecLH(startTime_index:endTime_index)};
            RH_tempDeltaSpecStruct{cc,1} = {meanDeltaSpecRH(startTime_index:endTime_index)};
            LH_tempThetaSpecStruct{cc,1} = {meanThetaSpecLH(startTime_index:endTime_index)};
            RH_tempThetaSpecStruct{cc,1} = {meanThetaSpecRH(startTime_index:endTime_index)};
            LH_tempAlphaSpecStruct{cc,1} = {meanAlphaSpecLH(startTime_index:endTime_index)};
            RH_tempAlphaSpecStruct{cc,1} = {meanAlphaSpecRH(startTime_index:endTime_index)};
            LH_tempBetaSpecStruct{cc,1} = {meanBetaSpecLH(startTime_index:endTime_index)};
            RH_tempBetaSpecStruct{cc,1} = {meanBetaSpecRH(startTime_index:endTime_index)};
            LH_tempGammaSpecStruct{cc,1} = {meanGammaSpecLH(startTime_index:endTime_index)};
            RH_tempGammaSpecStruct{cc,1} = {meanGammaSpecRH(startTime_index:endTime_index)};
        elseif cc == 180
            startTime = trialDuration_sec - 5;
            [~,startTime_index] = min(abs(T - startTime));
            endTime = trialDuration_sec - offset;
            [~,endTime_index] = min(abs(T - endTime));
            % hippocampal
            hipptempDeltaSpecStruct{cc,1} = {meanDeltaSpecHip(startTime_index:endTime_index)};
            hipptempThetaSpecStruct{cc,1} = {meanThetaSpecHip(startTime_index:endTime_index)};
            hipptempAlphaSpecStruct{cc,1} = {meanAlphaSpecHip(startTime_index:endTime_index)};
            hipptempBetaSpecStruct{cc,1} = {meanBetaSpecHip(startTime_index:endTime_index)};
            hipptempGammaSpecStruct{cc,1} = {meanGammaSpecHip(startTime_index:endTime_index)};
            % cortical
            LH_tempDeltaSpecStruct{cc,1} = {meanDeltaSpecLH(startTime_index:endTime_index)};
            RH_tempDeltaSpecStruct{cc,1} = {meanDeltaSpecRH(startTime_index:endTime_index)};
            LH_tempThetaSpecStruct{cc,1} = {meanThetaSpecLH(startTime_index:endTime_index)};
            RH_tempThetaSpecStruct{cc,1} = {meanThetaSpecRH(startTime_index:endTime_index)};
            LH_tempAlphaSpecStruct{cc,1} = {meanAlphaSpecLH(startTime_index:endTime_index)};
            RH_tempAlphaSpecStruct{cc,1} = {meanAlphaSpecRH(startTime_index:endTime_index)};
            LH_tempBetaSpecStruct{cc,1} = {meanBetaSpecLH(startTime_index:endTime_index)};
            RH_tempBetaSpecStruct{cc,1} = {meanBetaSpecRH(startTime_index:endTime_index)};
            LH_tempGammaSpecStruct{cc,1} = {meanGammaSpecLH(startTime_index:endTime_index)};
            RH_tempGammaSpecStruct{cc,1} = {meanGammaSpecRH(startTime_index:endTime_index)};
        else
            startTime = binWidth*(cc - 1);
            [~,startTime_index] = min(abs(T - startTime));
            endTime = binWidth*cc;
            [~,endTime_index] = min(abs(T - endTime));
            % hippocampal
            hipptempDeltaSpecStruct{cc,1} = {meanDeltaSpecHip(startTime_index + 1:endTime_index + 1)};
            hipptempThetaSpecStruct{cc,1} = {meanThetaSpecHip(startTime_index + 1:endTime_index + 1)};
            hipptempAlphaSpecStruct{cc,1} = {meanAlphaSpecHip(startTime_index + 1:endTime_index + 1)};
            hipptempBetaSpecStruct{cc,1} = {meanBetaSpecHip(startTime_index + 1:endTime_index + 1)};
            hipptempGammaSpecStruct{cc,1} = {meanGammaSpecHip(startTime_index + 1:endTime_index + 1)};
            % cortical
            LH_tempDeltaSpecStruct{cc,1} = {meanDeltaSpecLH(startTime_index + 1:endTime_index + 1)};
            RH_tempDeltaSpecStruct{cc,1} = {meanDeltaSpecRH(startTime_index + 1:endTime_index + 1)};
            LH_tempThetaSpecStruct{cc,1} = {meanThetaSpecLH(startTime_index + 1:endTime_index + 1)};
            RH_tempThetaSpecStruct{cc,1} = {meanThetaSpecRH(startTime_index + 1:endTime_index + 1)};
            LH_tempAlphaSpecStruct{cc,1} = {meanAlphaSpecLH(startTime_index + 1:endTime_index + 1)};
            RH_tempAlphaSpecStruct{cc,1} = {meanAlphaSpecRH(startTime_index + 1:endTime_index + 1)};
            LH_tempBetaSpecStruct{cc,1} = {meanBetaSpecLH(startTime_index + 1:endTime_index + 1)};
            RH_tempBetaSpecStruct{cc,1} = {meanBetaSpecRH(startTime_index + 1:endTime_index + 1)};
            LH_tempGammaSpecStruct{cc,1} = {meanGammaSpecLH(startTime_index + 1:endTime_index + 1)};
            RH_tempGammaSpecStruct{cc,1} = {meanGammaSpecRH(startTime_index + 1:endTime_index + 1)};
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
    % create folder for binarized whisking and binarized force sensor
    binWhiskerAngle = ProcData.data.binWhiskerAngle;
    binForceSensor = ProcData.data.binForceSensor;
    whiskerAngle = ProcData.data.whiskerAngle;
    whiskerAcceleration = diff(whiskerAngle,2);
    % find the number of whisker bins due to frame drops.
    whiskerBinNumber = 180;
    % divide the signal into five second bins and put them in a cell array
    tempWhiskerStruct = cell(whiskerBinNumber,1);
    tempWhiskerAccelStruct = cell(whiskerBinNumber,1);
    tempBinWhiskerStruct = cell(whiskerBinNumber,1);
    tempForceStruct = cell(whiskerBinNumber,1);
    for dd = 1:whiskerBinNumber
        if dd == 1
            tempWhiskerStruct(dd,1) = {whiskerAngle(dd:150)};
            tempWhiskerAccelStruct(dd,1) = {whiskerAcceleration(dd:150)};
            tempBinWhiskerStruct(dd,1) = {binWhiskerAngle(dd:150)};
            tempForceStruct(dd,1) = {binForceSensor(dd:150)};
        elseif dd == whiskerBinNumber
            tempWhiskerStruct(dd,1) = {whiskerAngle((((150*(dd - 1)) + 1)):end)};
            tempWhiskerAccelStruct(dd,1) = {whiskerAcceleration((((150*(dd - 1)) + 1)):end)};
            tempBinWhiskerStruct(dd,1) = {binWhiskerAngle((((150*(dd - 1)) + 1)):end)};
            tempForceStruct(dd,1) = {binForceSensor((((150*(dd - 1)) + 1)):end)};
        else
            tempWhiskerStruct(dd,1) = {whiskerAngle((((150*(dd - 1)) + 1)):(150*dd))};
            tempWhiskerAccelStruct(dd,1) = {whiskerAcceleration((((150*(dd - 1)) + 1)):(150*dd))};
            tempBinWhiskerStruct(dd,1) = {binWhiskerAngle((((150*(dd - 1)) + 1)):(150*dd))};
            tempForceStruct(dd,1) = {binForceSensor((((150*(dd - 1)) + 1)):(150*dd))};
        end
    end
    % save whisker and force sensor data under ProcData file
    ProcData.sleep.parameters.whiskerAngle = tempWhiskerStruct;
    ProcData.sleep.parameters.whiskerAcceleration = tempWhiskerAccelStruct;
    ProcData.sleep.parameters.binWhiskerAngle = tempBinWhiskerStruct;
    ProcData.sleep.parameters.binForceSensor = tempForceStruct;
    % create folder for the EMG
    EMG = ProcData.data.EMG.emg;
    normEMG = EMG - RestingBaselines.(baselineType).EMG.emg.(strDay).mean;
    tempEMGStruct = cell(180,1);
    for ee = 1:180
        if ee == 1
            tempEMGStruct(ee,1) = {normEMG(ee:150)};
        else
            tempEMGStruct(ee,1) = {normEMG((((150*(ee - 1)) + 1)):(150*ee))};
        end
    end
    % save EMG data under ProcData file
    ProcData.sleep.parameters.EMG = tempEMGStruct;
    % create folder for the doppler flow
    if isfield(ProcData.data,'flow') == true
        Flow = ProcData.data.flow.data;
    else
        Flow = NaN*ProcData.data.EMG.emg;
    end
    % try for baseline normalization if it exists
    try
        normFlow = (Flow - RestingBaselines.(baselineType).flow.data.(strDay).mean)/RestingBaselines.(baselineType).flow.data.(strDay).mean;
    catch
        normFlow = Flow;
    end
    tempFlowStruct = cell(180,1);
    for ff = 1:180
        if ff == 1
            tempFlowStruct(ff,1) = {normFlow(ff:150)};
        else
            try
                tempFlowStruct(ff,1) = {normFlow((((150*(ff-1)) + 1)):(150*ff))};
            catch
                tempFlowStruct(ff,1) = {normFlow((((150*(ff-1)) + 1)):end)};
            end
        end
    end
    % save doppler flow data under ProcData file
    ProcData.sleep.parameters.flow = tempFlowStruct;
    % create folder for the Heart Rate
    % find the heart rate from the current ProcData file
    heartRate = ProcData.data.heartRate;
    % divide the signal into five second bins and put them in a cell array
    tempHRStruct = cell(180,1);
    for gg = 1:180
        if gg == 1
            tempHRStruct(gg,1) = {heartRate(gg:5)};
        else
            tempHRStruct(gg,1) = {heartRate((((5*(gg-1)) + 1)):(5*gg))};
        end
    end
    % save heart rate data under ProcData file
    ProcData.sleep.parameters.heartRate = tempHRStruct;
    % create folder for the left and right CBV data
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
    for hh = 1:180
        if hh == 1
            LH_tempCBVStruct(hh,1) = {LH_NormCBV(hh:CBVfs*timeBin)};
            RH_tempCBVStruct(hh,1) = {RH_NormCBV(hh:CBVfs*timeBin)};
            hbtLH_tempCBVStruct(hh,1) = {LH_HbT(hh:CBVfs*timeBin)};
            hbtRH_tempCBVStruct(hh,1) = {RH_HbT(hh:CBVfs*timeBin)};
        else
            LH_tempCBVStruct(hh,1) = {LH_NormCBV((((CBVfs*timeBin*(hh - 1)) + 1)):(CBVfs*timeBin*hh))};
            RH_tempCBVStruct(hh,1) = {RH_NormCBV((((CBVfs*timeBin*(hh - 1)) + 1)):(CBVfs*timeBin*hh))};
            hbtLH_tempCBVStruct(hh,1) = {LH_HbT((((CBVfs*timeBin*(hh - 1)) + 1)):(CBVfs*timeBin*hh))};
            hbtRH_tempCBVStruct(hh,1) = {RH_HbT((((CBVfs*timeBin*(hh - 1)) + 1)):(CBVfs*timeBin*hh))};
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
