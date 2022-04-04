function [Results_StimulusBlinks] = AnalyzeStimulusBlinks_Pupil(animalID,rootFolder,delim,Results_StimulusBlinks)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose:
%________________________________________________________________________________________________________________________

%% only run analysis for valid animal IDs
dataLocation = [rootFolder delim 'Data' delim animalID delim 'Bilateral Imaging'];
cd(dataLocation)
% procdata file IDs
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
data.stimIndex = [];
data.blinkIndex = {};
stimNum = [];
stimDenom = [];
whiskCat = [];
zz = 1;
for aa = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(aa,:);
    load(procDataFileID)
    samplingRate = ProcData.notes.dsFs;
    try
        solenoids = ProcData.data.solenoids.LPadSol;
    catch
        solenoids = ProcData.data.stimulations.LPadSol;
    end
    if isempty(solenoids) == false
        if strcmp(ProcData.data.Pupil.frameCheck,'y') == true
            if isfield(ProcData.data.Pupil,'shiftedBlinks') == true
                blinks = ProcData.data.Pupil.shiftedBlinks;
            elseif isempty(ProcData.data.Pupil.blinkInds) == false
                blinks = ProcData.data.Pupil.blinkInds;
            else
                blinks = [];
            end
            bb = 1;
            verifiedBlinks = [];
            for cc = 1:length(blinks)
                if strcmp(ProcData.data.Pupil.blinkCheck{1,cc},'y') == true
                    verifiedBlinks(1,bb) = blinks(1,cc);
                    bb = bb + 1;
                end
            end
            % stimulation times
            try
                stimTimes = cat(2,ProcData.data.stimulations.LPadSol,ProcData.data.stimulations.RPadSol);
                stimSamples = sort(round(stimTimes)*samplingRate,'ascend');
            catch
                stimTimes = cat(2,ProcData.data.solenoids.LPadSol,ProcData.data.solenoids.RPadSol);
                stimSamples = sort(round(stimTimes)*samplingRate,'ascend');
            end        
            linkThresh = 0.5;   % seconds, Link events < 0.5 seconds apart
            breakThresh = 0;   % seconds changed by atw on 2/6/18 from 0.07
            binWhiskerAngle = [0,ProcData.data.binWhiskerAngle,0];
            binWhiskers = binWhiskerAngle;
%             binWhiskers = LinkBinaryEvents_IOS(gt(binWhiskerAngle,0),[linkThresh breakThresh]*30);          
            for tt = 1:length(stimSamples)
                stimSample = stimSamples(1,tt);
                blinkGroup = [];
                for pp = 1:length(verifiedBlinks)
                    verifiedBlink = verifiedBlinks(1,pp);
                    if verifiedBlink >= stimSample && verifiedBlink <= stimSample + samplingRate*5
                        blinkGroup = cat(1,blinkGroup,verifiedBlink);
                    end
                end
                if isempty(blinkGroup) == false
                    data.stimIndex(zz,1) = stimSample;
                    data.blinkIndex{zz,1} = blinkGroup;
                    zz = zz + 1;
                end   
            end
            qq = 1;
            stimBlinks = [];
            for xx = 1:length(verifiedBlinks)
                blinkSample = verifiedBlinks(1,xx);
                sampleCheck = false;
                for yy = 1:length(stimSamples)
                    stimSample = stimSamples(1,yy);
                    if blinkSample >= stimSample && blinkSample <= stimSample + samplingRate*5
                        sampleCheck = true;
                    end
                end
                if sampleCheck == true
                    stimBlinks(1,qq) = blinkSample;
                    qq = qq + 1;
                end
            end
            % condense blinks
            condensedBlinkTimes = [];
            stimMat = [];
            whiskSum = [];
            if isempty(stimBlinks) == false
                cc = 1;
                for bb = 1:length(stimBlinks)
                    if bb == 1
                        condensedBlinkTimes(1,bb) = stimBlinks(1,bb);
                        cc = cc + 1;
                    else
                        timeDifference = stimBlinks(1,bb) - stimBlinks(1,bb - 1);
                        if timeDifference > 30
                            condensedBlinkTimes(1,cc) = stimBlinks(1,bb);
                            cc = cc + 1;
                        end
                    end
                end
                % extract blink triggered data
                stimMat = zeros(1,length(stimSamples));
                whiskSum = [];
                xkd = 1;
                for dd = 1:length(stimSamples)
                    stimSample = stimSamples(1,dd);
                    for qq = 1:length(condensedBlinkTimes)
                        blink = condensedBlinkTimes(1,qq);
                        if blink >= stimSample && blink <= (stimSample + 5*samplingRate)
                            if stimMat(1,dd) == 0
                                stimMat(1,dd) = 1;
                                whiskSum(1,xkd) = sum(binWhiskers((blink - samplingRate):(blink + samplingRate)));
                                xkd = xkd + 1;
                            end
                        end
                    end
                end
            end
            try
                stimNum = cat(1,stimNum,sum(stimMat));
                whiskCat = cat(2,whiskCat,whiskSum);
                stimDenom = cat(1,stimDenom,length(stimSamples));
            catch
                stimNum = cat(1,stimNum,0);
                stimDenom = cat(1,stimDenom,length(stimSamples));
            end
        end
    end
end
Results_StimulusBlinks.(animalID).stimPercentage = (sum(stimNum)/sum(stimDenom))*100;
Results_StimulusBlinks.(animalID).stimPercentageDuration = (mean(whiskCat)/30);
% blink location after stim
cc = 1; dd = 1; ee = 1; ff = 1; gg = 1; hh = 1; ii = 1; jj = 1; kk = 1; ll = 1; mm = 1;
for aa = 1:length(data.stimIndex)
    stimTime = data.stimIndex(aa,1);
    blinkIndex = data.blinkIndex{aa,1};
    for bb = 1:length(blinkIndex)
        blinkTime = blinkIndex(bb,1);
        mm = mm + 1;
        if blinkTime >= stimTime && blinkTime <= stimTime + 15
            cc = cc + 1;
        elseif blinkTime >= stimTime + 16 && blinkTime <= stimTime + 30
            dd = dd + 1;
        elseif blinkTime >= stimTime + 31 && blinkTime <= stimTime + 45
            ee = ee + 1;
        elseif blinkTime >= stimTime + 46 && blinkTime <= stimTime + 60
            ff = ff + 1;
        elseif blinkTime >= stimTime + 61 && blinkTime <= stimTime + 75
            gg = gg + 1;
        elseif blinkTime >= stimTime + 76 && blinkTime <= stimTime + 90
            hh = hh + 1;
        elseif blinkTime >= stimTime + 91 && blinkTime <= stimTime + 105
            ii = ii + 1;
        elseif blinkTime >= stimTime + 106 && blinkTime <= stimTime + 120
            jj = jj + 1;
        elseif blinkTime >= stimTime + 121 && blinkTime <= stimTime + 135
            kk = kk + 1;
        elseif blinkTime >= stimTime + 136 && blinkTime <= stimTime + 150
            ll = ll + 1;
        else
            keyboard
        end
    end
end
Results_StimulusBlinks.(animalID).binProbability = [cc/mm,dd/mm,ee/mm,ff/mm,gg/mm,hh/mm,ii/mm,jj/mm,kk/mm,ll/mm];
%%
% blink location after stim
cc = 1; dd = 1; ee = 1; ff = 1; gg = 1; hh = 1; ii = 1; jj = 1; kk = 1; ll = 1; mm = 1;
for aa = 1:length(data.stimIndex)
    stimTime = data.stimIndex(aa,1);
    blinkIndex = data.blinkIndex{aa,1};
    blinkTime = blinkIndex(1,1);
    mm = mm + 1;
    if blinkTime >= stimTime && blinkTime <= stimTime + 15
        cc = cc + 1;
    elseif blinkTime >= stimTime + 16 && blinkTime <= stimTime + 30
        dd = dd + 1;
    elseif blinkTime >= stimTime + 31 && blinkTime <= stimTime + 45
        ee = ee + 1;
    elseif blinkTime >= stimTime + 46 && blinkTime <= stimTime + 60
        ff = ff + 1;
    elseif blinkTime >= stimTime + 61 && blinkTime <= stimTime + 75
        gg = gg + 1;
    elseif blinkTime >= stimTime + 76 && blinkTime <= stimTime + 90
        hh = hh + 1;
    elseif blinkTime >= stimTime + 91 && blinkTime <= stimTime + 105
        ii = ii + 1;
    elseif blinkTime >= stimTime + 106 && blinkTime <= stimTime + 120
        jj = jj + 1;
    elseif blinkTime >= stimTime + 121 && blinkTime <= stimTime + 135
        kk = kk + 1;
    elseif blinkTime >= stimTime + 136 && blinkTime <= stimTime + 150
        ll = ll + 1;
    else
        keyboard
    end
end
Results_StimulusBlinks.(animalID).indBinProbability = [cc/mm,dd/mm,ee/mm,ff/mm,gg/mm,hh/mm,ii/mm,jj/mm,kk/mm,ll/mm];
% save data
cd([rootFolder delim])
save('Results_StimulusBlinks.mat','Results_StimulusBlinks')

end
