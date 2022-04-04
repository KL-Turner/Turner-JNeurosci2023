function [Results_PupilModelCoherence] = AnalyzePupilModelCoherence_Pupil(animalID,Results_PupilModelCoherence)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Analyze the cross-correlation between neural activity/hemodynamics and pupil measurements
%________________________________________________________________________________________________________________________

% load in relevent data structures
load('Results_PhysioSleepModel.mat')
predPhysioLabels = Results_PhysioSleepModel.(animalID).SVM.testXlabels;
actualPhysioLabels = Results_PhysioSleepModel.(animalID).SVM.testYlabels;
load('Results_PupilSleepModel.mat')
predPupilLabels = Results_PupilSleepModel.(animalID).SVM.testXlabels;
actualPupilLabels = Results_PupilSleepModel.(animalID).SVM.testYlabels;
% compare predicted vs. actual physiological model labels
predPhysioLogical = zeros(length(predPhysioLabels),1);
actualPhysioLogical = zeros(length(actualPhysioLabels),1);
for aa = 1:length(predPhysioLabels)
    % predicted
    if strcmp(predPhysioLabels{aa,1},'Awake') == true
        predPhysioLogical(aa,1) = 1;
    elseif strcmp(predPhysioLabels{aa,1},'Asleep') == true
        predPhysioLogical(aa,1) = 0;
    end
    % actual
    if strcmp(actualPhysioLabels{aa,1},'Awake') == true
        actualPhysioLogical(aa,1) = 1;
    elseif strcmp(actualPhysioLabels{aa,1},'Asleep') == true
        actualPhysioLogical(aa,1) = 0;
    end
end
matPredPhysio = reshape(predPhysioLogical,[180,length(predPhysioLogical)/180]);
matPredPhysio = detrend(matPredPhysio,'constant');
matActPhysio = reshape(actualPhysioLogical,[180,length(actualPhysioLogical)/180]);
matActPhysio = detrend(matActPhysio,'constant');
% compare predicted vs. actual pupil model labels
predPupilLogical = zeros(length(predPupilLabels),1);
actualPupilLogical = zeros(length(actualPupilLabels),1);
for aa = 1:length(predPupilLabels)
    % predicted
    if strcmp(predPupilLabels{aa,1},'Awake') == true
        predPupilLogical(aa,1) = 1;
    elseif strcmp(predPupilLabels{aa,1},'Asleep') == true
        predPupilLogical(aa,1) = 0;
    end
    % actual
    if strcmp(actualPupilLabels{aa,1},'Awake') == true
        actualPupilLogical(aa,1) = 1;
    elseif strcmp(actualPupilLabels{aa,1},'Asleep') == true
        actualPupilLogical(aa,1) = 0;
    end
end
matPredPupil = reshape(predPupilLogical,[180,length(predPupilLogical)/180]);
matPredPupil = detrend(matPredPupil,'constant');
matActPupil = reshape(actualPupilLogical,[180,length(actualPupilLogical)/180]);
matActPupil = detrend(matActPupil,'constant');
% parameters for coherencyc - information available in function
params.tapers = [10,19]; % Tapers [n, 2n - 1]
params.pad = 1;
params.Fs = 0.2;
params.fpass = [1/100,1/10]; % Pass band [0, nyquist]
params.trialave = 1;
params.err = [2,0.05];
% calculate the coherence between desired signals
[C_physio,~,~,~,~,f_physio,confC_physio,~,cErr_physio] = coherencyc_eLife2020(matPredPhysio,matActPhysio,params);
% save results
Results_PupilModelCoherence.(animalID).Physio.C = C_physio;
Results_PupilModelCoherence.(animalID).Physio.f = f_physio;
Results_PupilModelCoherence.(animalID).Physio.confC = confC_physio;
Results_PupilModelCoherence.(animalID).Physio.cErr = cErr_physio;
% save data
% calculate the coherence between desired signals
[C_pupil,~,~,~,~,f_pupil,confC_pupil,~,cErr_pupil] = coherencyc_eLife2020(matPredPupil,matActPupil,params);
% save results
Results_PupilModelCoherence.(animalID).Pupil.C = C_pupil;
Results_PupilModelCoherence.(animalID).Pupil.f = f_pupil;
Results_PupilModelCoherence.(animalID).Pupil.confC = confC_pupil;
Results_PupilModelCoherence.(animalID).Pupil.cErr = cErr_pupil;
% save data
save('Results_PupilModelCoherence.mat','Results_PupilModelCoherence')

end
