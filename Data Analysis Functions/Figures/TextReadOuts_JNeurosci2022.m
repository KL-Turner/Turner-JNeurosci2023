function [] = TextReadOuts_JNeurosci2022()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose:
%________________________________________________________________________________________________________________________
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpose:
%________________________________________________________________________________________________________________________

%% load data
dataStructure = 'Results_PupilThreshold.mat';
load(dataStructure)
animalIDs = fieldnames(Results_PupilThreshold);
indStDev = [];
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    indStDev = cat(1,indStDev,mean(Results_PupilThreshold.(animalID).thresholdStDev));
end
meanStDev = mean(indStDev,1);
stdDevStDev = std(indStDev,0,1);
disp(['Pupil threshold: ' num2str(meanStDev) ' +/- ' num2str(stdDevStDev) ' StDev from mean']); disp(' ')
%%

end
