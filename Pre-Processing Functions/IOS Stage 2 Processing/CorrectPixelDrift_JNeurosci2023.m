function [] = CorrectPixelDrift_JNeurosci2023(procDataFileIDs)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Determine the slow exponential drift for each day of imaging and correct the drift if desired. The slow
%          drift is caused by the CCD sensor's sensitivity changing as the camera heats up over multiple hours.
%________________________________________________________________________________________________________________________

% establish the number of unique days based on file IDs
[animalIDs,fileDates,~] = GetFileInfo_JNeurosci2023(procDataFileIDs);
animalID = animalIDs(1,:);
[uniqueDays,~,DayID] = GetUniqueDays_JNeurosci2023(fileDates);
firstsFileOfDay = cell(1,length(uniqueDays));
for a = 1:length(uniqueDays)
    FileInd = DayID == a;
    dayFilenames = procDataFileIDs(FileInd,:);
    firstsFileOfDay(a) = {dayFilenames(1,:)};
end
% go through each day and concate the data to observe slow drift
for b = 1:length(firstsFileOfDay)
    indDayProcDataFileList = {};
    catBarrelsData = [];
    catCementData = [];
    fileName = firstsFileOfDay{1,b};
    [~,fileDate,~] = GetFileInfo_JNeurosci2023(fileName);
    strDay = ConvertDate_JNeurosci2023(fileDate);
    p = 1;
    for c = 1:size(procDataFileIDs,1)
        procDataFileID = procDataFileIDs(c,:);
        if strfind(procDataFileID,fileDate) >= 1
            indDayProcDataFileList{p,1} = procDataFileID; %#ok<AGROW>
            p = p + 1;
        end
    end
    % load the processed CBV/cement data from each file and concat it into one array
    for d = 1:length(indDayProcDataFileList)
        indDayProcDataFile = indDayProcDataFileList{d,1};
        load(indDayProcDataFile)
        samplingRate = ProcData.notes.CBVCamSamplingRate;
        trialDuration = ProcData.notes.trialDuration_sec;
        barrelsData = ProcData.data.CBV.Barrels;
        cementData = ProcData.data.CBV.Cement;
        catBarrelsData = horzcat(catBarrelsData,barrelsData); %#ok<AGROW>
        catCementData = horzcat(catCementData,cementData); %#ok<AGROW>
    end
    % establish whether a slow exponential trend exists for the data
    [B,A] = butter(3,0.01/(samplingRate/2),'low');
    filtCatCementData = filtfilt(B,A,catCementData);
    x = ((1:length(filtCatCementData))/samplingRate)';
    % create a weight vector for the trend
    cementWeightVec = ones(1,length(x));
    cementSecondHalfMean = mean(filtCatCementData(floor(length(filtCatCementData/2)):end));
    for t = 1:length(cementWeightVec)
        if filtCatCementData(t) > cementSecondHalfMean
            cementWeightVec(t) = 10;
        end
    end
    % compare weighted models
    Cement_modelFit = fit(x,filtCatCementData','exp2','Weight',cementWeightVec);
    Cement_modelFit_Y = Cement_modelFit(x);
    Cement_modelFit_norm = (Cement_modelFit_Y - min(Cement_modelFit_Y))./min(Cement_modelFit_Y);
    Cement_modelFit_flip = 1 - Cement_modelFit_norm;
    % apply exponential correction to original data
    adjCatBarrelsData = catBarrelsData.*Cement_modelFit_flip';
    rsAdjCatBarrelsData = reshape(adjCatBarrelsData,[samplingRate*trialDuration,length(indDayProcDataFileList)]);
    % comparison showing original LH data and the corrected data
    fixPixels = figure;
    subplot(2,2,1)
    plot(x,catBarrelsData,'k')
    title('Barrels original data')
    xlabel('Time (sec)')
    ylabel('12-bit pixel val')
    axis tight
    subplot(2,2,2)
    plot(x,filtCatCementData,'k')
    hold on
    plot(x,Cement_modelFit_Y,'r')
    title('Cement drift fit')
    xlabel('Time (sec)')
    ylabel('12-bit pixel val')
    legend('cement data','exp fit')
    axis tight
    subplot(2,2,3)
    plot(x,Cement_modelFit_flip,'r')
    title('Correction profile')
    xlabel('Time (sec)')
    ylabel('Normalized val')
    axis tight
    subplot(2,2,4)
    plot(x,catBarrelsData,'k')
    hold on
    plot(x,adjCatBarrelsData,'r')
    title('Corrected data')
    xlabel('Time (sec)')
    ylabel('12-bit pixel val')
    legend('original','corrected')
    axis tight
    % determine which correction profile to use for LH data
    correctionDecision = 'n';
    while strcmp(correctionDecision,'n') == true
        drawnow
        applyCorrection = input(['Apply correction profile to ' strDay ' pixel values? (y/n): '],'s'); disp(' ')
        if strcmp(applyCorrection,'y') == true || strcmp(applyCorrection,'n') == true
            correctionDecision = 'y';
        else
            disp('Invalid input. Must be ''y'', ''n'''); disp(' ')
        end
    end
    sgtitle([animalID ' ' strDay ' pixel correction applied: ' applyCorrection])
    savefig(fixPixels,[animalID '_' strDay '_PixelDriftCorrection']);
    close(fixPixels)
    % apply corrected data to each file from reshaped matrix
    for d = 1:length(indDayProcDataFileList)
        indDayProcDataFile = indDayProcDataFileList{d,1};
        load(indDayProcDataFile)
        % pixel correction
        if strcmp(applyCorrection,'n') == true
            ProcData.data.CBV.adjBarrels = ProcData.data.CBV.Barrels;
        elseif strcmp(applyCorrection,'y') == true
            ProcData.data.CBV.adjBarrels = rsAdjCatBarrelsData(:,d)';
        end
        disp(['Saving pixel corrections to ' strDay ' ProcData file ' num2str(d) ' of ' num2str(length(indDayProcDataFileList))]); disp(' ')
        save(indDayProcDataFile,'ProcData')
    end
end

end
