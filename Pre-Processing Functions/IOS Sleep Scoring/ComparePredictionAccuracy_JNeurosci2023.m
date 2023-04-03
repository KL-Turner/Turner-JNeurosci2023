function [] = ComparePredictionAccuracy_JNeurosci2023()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Train several machine learning techniques on manually scored sleep data, and evaluate each model's accuracy
%________________________________________________________________________________________________________________________

% load in all the ConfusionData.mat structure
startingDirectory = cd;
confusionDataDirectory = [startingDirectory '\Figures\Confusion Matricies\'];
cd(confusionDataDirectory)
load('ConfusionData.mat','-mat')
% pull out confusion matrix values
modelNames = fieldnames(ConfusionData);
for aa = 1:length(modelNames)
    holdYlabels.(modelNames{aa,1}) = [];
    holdXlabels.(modelNames{aa,1}) = [];
    for bb = 1:length(ConfusionData.(modelNames{aa,1}).trainYlabels)
        holdYlabels.(modelNames{aa,1}) = vertcat(holdYlabels.(modelNames{aa,1}),ConfusionData.(modelNames{aa,1}).testYlabels{bb,1});
        holdXlabels.(modelNames{aa,1}) = vertcat(holdXlabels.(modelNames{aa,1}),ConfusionData.(modelNames{aa,1}).testXlabels{bb,1});
    end
end
% determine accuracy of the models
for cc = 1:length(modelNames)
    % confusion matrix
    confMat = figure;
    cm = confusionchart(holdYlabels.(modelNames{cc,1}),holdXlabels.(modelNames{cc,1}));
    cm.ColumnSummary = 'column-normalized';
    cm.RowSummary = 'row-normalized';
    cm.Title = [modelNames{cc,1} ' Classifier Confusion Matrix'];
    % pull data out of confusion matrix
    confVals = cm.NormalizedValues;
    totalScores = sum(confVals(:));
    modelAccuracy = (sum(confVals([1,5,9])/totalScores))*100;
    disp([modelNames{cc,1} ' model prediction accuracy: ' num2str(modelAccuracy) '%']); disp(' ')
    savefig(confMat,[modelNames{cc,1} '_JNeurosci2023_ConfusionMatrix']);
    close(confMat)
end
cd(startingDirectory)

end
