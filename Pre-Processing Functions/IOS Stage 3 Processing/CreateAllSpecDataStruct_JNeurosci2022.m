function [] = CreateAllSpecDataStruct_JNeurosci2022(animalID,neuralDataTypes)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpose: Combine spectrograms into a single file so it only has to be loaded one time in later analysis
%________________________________________________________________________________________________________________________

AllSpecStructFileIDA = [animalID '_AllSpecStructA.mat'];
AllSpecStructFileIDB = [animalID '_AllSpecStructB.mat'];
AllSpecStructFileIDC = [animalID '_AllSpecStructC.mat'];
% file list A
% if ~exist(AllSpecStructFileIDA) == true
    AllSpecData = [];
    % Character list of all SpecData files
    specDataFileStruct = dir('*_SpecDataA.mat');
    specDataFiles = {specDataFileStruct.name}';
    specDataFileIDs = char(specDataFiles);
    for aa = 1: size(specDataFileIDs,1)
        specDataFileID = specDataFileIDs(aa,:);
        disp(['Adding spectrogram data to full struct (A) for file number ' num2str(aa) ' of ' num2str(size(specDataFiles, 1)) '...']); disp(' ')
        load(specDataFileID)
        for bb = 1:length(neuralDataTypes)
            neuralDataType = neuralDataTypes{1,bb};
            AllSpecData.(neuralDataType).fileIDs{aa,1} = specDataFileID;
            AllSpecData.(neuralDataType).S{aa,1} =  SpecData.(neuralDataType).S;
            AllSpecData.(neuralDataType).normS{aa,1} = SpecData.(neuralDataType).normS;
            AllSpecData.(neuralDataType).T{aa,1} =  SpecData.(neuralDataType).T;
            AllSpecData.(neuralDataType).F{aa,1} =  SpecData.(neuralDataType).F;
            AllSpecData.(neuralDataType).params =  SpecData.(neuralDataType).params;
            AllSpecData.(neuralDataType).movingwin =  SpecData.(neuralDataType).movingwin;
        end
    end
    disp('Saving structure...'); disp(' ')
    save(AllSpecStructFileIDA,'AllSpecData','-v7.3')
% end
% file list B
% if ~exist(AllSpecStructFileIDB) == true
    AllSpecData = [];
    % Character list of all SpecData files
    specDataFileStruct = dir('*_SpecDataB.mat');
    specDataFiles = {specDataFileStruct.name}';
    specDataFileIDs = char(specDataFiles);
    for cc = 1: size(specDataFileIDs,1)
        specDataFileID = specDataFileIDs(cc,:);
        disp(['Adding spectrogram data to full struct (B) for file number ' num2str(cc) ' of ' num2str(size(specDataFiles, 1)) '...']); disp(' ')
        load(specDataFileID)
        for dd = 1:length(neuralDataTypes)
            neuralDataType = neuralDataTypes{1,dd};
            AllSpecData.(neuralDataType).fileIDs{cc,1} = specDataFileID;
            AllSpecData.(neuralDataType).S{cc,1} =  SpecData.(neuralDataType).S;
            AllSpecData.(neuralDataType).normS{cc,1} = SpecData.(neuralDataType).normS;
            AllSpecData.(neuralDataType).T{cc,1} =  SpecData.(neuralDataType).T;
            AllSpecData.(neuralDataType).F{cc,1} =  SpecData.(neuralDataType).F;
            AllSpecData.(neuralDataType).params =  SpecData.(neuralDataType).params;
            AllSpecData.(neuralDataType).movingwin =  SpecData.(neuralDataType).movingwin;
        end
    end
    disp('Saving structure...'); disp(' ')
    save(AllSpecStructFileIDB,'AllSpecData','-v7.3')
% end
% file list C
% if ~exist(AllSpecStructFileIDC) == true
    AllSpecData = [];
    % Character list of all SpecData files
    specDataFileStruct = dir('*_SpecDataC.mat');
    specDataFiles = {specDataFileStruct.name}';
    specDataFileIDs = char(specDataFiles);
    for ee = 1: size(specDataFileIDs,1)
        specDataFileID = specDataFileIDs(ee,:);
        disp(['Adding spectrogram data to full struct (C) for file number ' num2str(ee) ' of ' num2str(size(specDataFiles, 1)) '...']); disp(' ')
        load(specDataFileID)
        for ff = 1:length(neuralDataTypes)
            neuralDataType = neuralDataTypes{1,ff};
            AllSpecData.(neuralDataType).fileIDs{ee,1} = specDataFileID;
            AllSpecData.(neuralDataType).S{ee,1} =  SpecData.(neuralDataType).S;
            AllSpecData.(neuralDataType).normS{ee,1} = SpecData.(neuralDataType).normS;
            AllSpecData.(neuralDataType).T{ee,1} =  SpecData.(neuralDataType).T;
            AllSpecData.(neuralDataType).F{ee,1} =  SpecData.(neuralDataType).F;
            AllSpecData.(neuralDataType).params =  SpecData.(neuralDataType).params;
            AllSpecData.(neuralDataType).movingwin =  SpecData.(neuralDataType).movingwin;
        end
    end
    disp('Saving structure...'); disp(' ')
    save(AllSpecStructFileIDC,'AllSpecData','-v7.3')
% end

end
