function [Results_PupilThreshold] = AnalyzePupilThreshold_Pupil(animalID,rootFolder,delim,Results_PupilThreshold)
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
% find and load RestingBaselines.mat struct
pupilDataFileStruct = dir('*_PupilData.mat');
pupilDataFile = {pupilDataFileStruct.name}';
pupilDataFileID = char(pupilDataFile);
load(pupilDataFileID,'-mat')
strDays = fieldnames(PupilData.Threshold);
firstFiles = PupilData.firstFileOfDay;
for aa = 1:length(strDays)
    firstFileOfDay = firstFiles(1,aa);
    load(char(firstFileOfDay),'-mat')
    firstFrame = ProcData.data.Pupil.firstFrame;
    eyeROI = ProcData.data.Pupil.eyeROI;
    roiImage = uint8(firstFrame); % convert double floating point data to unsignned 8bit integers
    workingImg = imcomplement(roiImage); % grab frame from image stack
    % model the distribution of pixel intensities as a gaussian to estimate/isolate the population of pupil pixels
    medFiltParams = [5,5]; % [x,y] dimensions for 2d median filter of images
    filtImg = medfilt2(workingImg,medFiltParams); % median filter image
    threshImg = uint8(double(filtImg).*eyeROI); % only look at pixel values in ROI
    [phat,~] = mle(reshape(threshImg(threshImg ~= 0),1,numel(threshImg(threshImg ~= 0))),'distribution','Normal');
    threshold = PupilData.Threshold.(strDays{aa,1});
    Results_PupilThreshold.(animalID).thresholdStDev(aa,1) = (threshold - phat(1))/phat(2);
end
% save data
cd([rootFolder delim])
save('Results_PupilThreshold.mat','Results_PupilThreshold')

end
