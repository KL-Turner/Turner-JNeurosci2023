function [] = CreateTrialSpectrograms_JNeurosci2023(rawDataFiles,neuralDataTypes)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Analyzes the raw neural data from each RawData.mat file and calculates two different spectrograms.
%________________________________________________________________________________________________________________________

for aa = 1:size(rawDataFiles,1)
    rawDataFile = rawDataFiles(aa,:);
    clear RawData
    [animalID,~,fileID] = GetFileInfo_JNeurosci2023(rawDataFile);
    specDataFileIDA = [animalID '_' fileID '_SpecDataA.mat'];
    specDataFileIDB = [animalID '_' fileID '_SpecDataB.mat'];
    specDataFileIDC = [animalID '_' fileID '_SpecDataC.mat'];
    % 5 second spectrograms with 1/5 second step size
    if ~exist(specDataFileIDA,'file') == true
        SpecData = [];
        if exist('RawData','file') == false
            load(rawDataFile);
            duration = RawData.notes.trialDuration_sec;
            analogFs = RawData.notes.analogSamplingRate;
            expectedLength = duration*analogFs;
        end
        disp(['Creating spectrogram (A) for file ID: (' num2str(aa) '/' num2str(size(rawDataFiles,1)) ')']); disp(' ')
        for bb = 1:length(neuralDataTypes)
            neuralDataType = neuralDataTypes{1,bb};
            try
                rawNeuro = detrend(RawData.data.(neuralDataType)(1:expectedLength),'constant');
            catch
                sampleDiff = expectedLength - length(RawData.data.(neuralDataType));
                rawNeuro = detrend(horzcat(RawData.data.(neuralDataType),RawData.data.(neuralDataType)(end)*ones(1,sampleDiff)),'constant');
            end
            % 60 Hz notch filter
            %  w0 = 60/(analogFs/2);
            %  bw = w0/35;
            %  [num,den] = iirnotch(w0,bw);
            %  rawNeuro2 = filtfilt(num,den,rawNeuro);
            % Spectrogram parameters
            params.tapers = [5,9];
            params.Fs = analogFs;
            params.fpass = [1,100];
            movingwin = [5,1/5];
            % analyze each spectrogram based on parameters
            disp(['Creating ' neuralDataType ' spectrogram for file number ' num2str(aa) ' of ' num2str(size(rawDataFiles,1)) '...']); disp(' ')
            [S,T,F] = mtspecgramc(rawNeuro,movingwin,params);
            % save data ins tructure
            SpecData.(neuralDataType).S = S';
            SpecData.(neuralDataType).T = T;
            SpecData.(neuralDataType).F = F;
            SpecData.(neuralDataType).params = params;
            SpecData.(neuralDataType).movingwin = movingwin;
            save(specDataFileIDA,'SpecData');
        end
        save(specDataFileIDA,'SpecData');
    else
        disp(['Spectrogram (A) for file ID: (' num2str(aa) '/' num2str(size(rawDataFiles,1)) ') already exists.']); disp(' ')
    end
    % 1 second spectrograms with 1/10 Hz step size
    if ~exist(specDataFileIDB,'file') == true
        SpecData = [];
        if exist('RawData','file') == false
            load(rawDataFile);
            duration = RawData.notes.trialDuration_sec;
            analogFs = RawData.notes.analogSamplingRate;
            expectedLength = duration*analogFs;
        end
        disp(['Creating spectrogram (B) for file ID: (' num2str(aa) '/' num2str(size(rawDataFiles,1)) ')']); disp(' ')
        for cc = 1:length(neuralDataTypes)
            neuralDataType = neuralDataTypes{1,cc};
            try
                rawNeuro = detrend(RawData.data.(neuralDataType)(1:expectedLength),'constant');
            catch
                sampleDiff = expectedLength - length(RawData.data.(neuralDataType));
                rawNeuro = detrend(horzcat(RawData.data.(neuralDataType),RawData.data.(neuralDataType)(end)*ones(1,sampleDiff)),'constant');
            end
            % 60 Hz notch filter
            %  w0 = 60/(analogFs/2);
            %  bw = w0/35;
            %  [num,den] = iirnotch(w0,bw);
            %  rawNeuro2 = filtfilt(num,den,rawNeuro);
            % Spectrogram parameters
            params.tapers = [1,1];
            params.Fs = analogFs;
            params.fpass = [1,100];
            movingwin = [1,1/10];
            % analyze each spectrogram based on parameters
            disp(['Creating ' neuralDataType ' spectrogram for file number ' num2str(aa) ' of ' num2str(size(rawDataFiles,1)) '...']); disp(' ')
            [S,T,F] = mtspecgramc(rawNeuro,movingwin,params);
            % save data ins tructure
            SpecData.(neuralDataType).S = S';
            SpecData.(neuralDataType).T = T;
            SpecData.(neuralDataType).F = F;
            SpecData.(neuralDataType).params = params;
            SpecData.(neuralDataType).movingwin = movingwin;
        end
        save(specDataFileIDB,'SpecData');
    else
        disp(['Spectrogram (B) for file ID: (' num2str(aa) '/' num2str(size(rawDataFiles,1)) ') already exists.']); disp(' ')
    end
    % 1 second spectrograms with 1/30 Hz step size
    if ~exist(specDataFileIDC,'file') == true
        SpecData = [];
        if exist('RawData','file') == false
            load(rawDataFile);
            duration = RawData.notes.trialDuration_sec;
            analogFs = RawData.notes.analogSamplingRate;
            expectedLength = duration*analogFs;
        end
        disp(['Creating spectrogram (C) for file ID: (' num2str(aa) '/' num2str(size(rawDataFiles,1)) ')']); disp(' ')
        for dd = 1:length(neuralDataTypes)
            neuralDataType = neuralDataTypes{1,dd};
            try
                rawNeuro = detrend(RawData.data.(neuralDataType)(1:expectedLength),'constant');
            catch
                sampleDiff = expectedLength - length(RawData.data.(neuralDataType));
                rawNeuro = detrend(horzcat(RawData.data.(neuralDataType),RawData.data.(neuralDataType)(end)*ones(1,sampleDiff)),'constant');
            end
            % 60 Hz notch filter
            %  w0 = 60/(analogFs/2);
            %  bw = w0/35;
            %  [num,den] = iirnotch(w0,bw);
            %  rawNeuro2 = filtfilt(num,den,rawNeuro);
            % Spectrogram parameters
            params.tapers = [5,9];
            params.Fs = analogFs;
            params.fpass = [1,100];
            movingwin = [1,1/30];
            % analyze each spectrogram based on parameters
            disp(['Creating ' neuralDataType ' spectrogram for file number ' num2str(aa) ' of ' num2str(size(rawDataFiles,1)) '...']); disp(' ')
            [S,T,F] = mtspecgramc(rawNeuro,movingwin,params);
            % save data ins tructure
            SpecData.(neuralDataType).S = S';
            SpecData.(neuralDataType).T = T;
            SpecData.(neuralDataType).F = F;
            SpecData.(neuralDataType).params = params;
            SpecData.(neuralDataType).movingwin = movingwin;
        end
        save(specDataFileIDC,'SpecData');
    else
        disp(['Spectrogram (C) for file ID: (' num2str(aa) '/' num2str(size(rawDataFiles,1)) ') already exists.']); disp(' ')
    end
end

end
