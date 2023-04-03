function [] = CreateTrainingDataSet_JNeurosci2023(procDataFileIDs,RestingBaselines,baselineType)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Go through each file and train a data set for the model or for model validation
%________________________________________________________________________________________________________________________

for a = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(a,:);
    modelDataFileID = [procDataFileID(1:end-12) 'ModelData.mat'];
    trainingDataFileID = [procDataFileID(1:end-12) 'TrainingData.mat'];
    if ~exist(trainingDataFileID,'file')
        disp(['Loading ' procDataFileID ' for manual sleep scoring.' ]); disp(' ')
        load(procDataFileID)
        load(modelDataFileID)
        saveFigs = 'n';
        imagingType = 'bilateral';
        hemoType = 'HbT';
        [figHandle,~,~,ax3,~,~,~] = GenerateSingleFigures_JNeurosci2023(procDataFileID,RestingBaselines,baselineType,saveFigs,imagingType,hemoType);
        trialDuration = ProcData.notes.trialDuration_sec;
        numBins = trialDuration/5;
        behavioralState = cell(180,1);
        for b = 1:numBins
            global buttonState %#ok<TLEV>
            buttonState = 0;
            xStartVal = (b*5) - 4;
            xEndVal = b*5;
            xInds = xStartVal:1:xEndVal;
            figHandle = gcf;
            subplot(ax3)
            hold on
            leftEdge3 = xline(xInds(1),'color',colors('electric purple'),'LineWidth',2);
            rightEdge3 = xline(xInds(5),'color',colors('electric purple'),'LineWidth',2);
            if b == 1 % b <= 60
                xlim([1,300])
            elseif b == 61 % b >= 61 && b <= 120
                xlim([300,600])
            elseif b == 121 % b >= 121 && b <= 180
                xlim([600,900])
            end
            [updatedGUI] = SelectBehavioralStateGUI_JNeurosci2023;
            while buttonState == 0
                drawnow()
                if buttonState == 1
                    guiResults = guidata(updatedGUI);
                    if guiResults.togglebutton1.Value == true
                        behavioralState{b,1} = 'Not Sleep';
                    elseif guiResults.togglebutton2.Value == true
                        behavioralState{b,1} = 'NREM Sleep';
                    elseif guiResults.togglebutton3.Value == true
                        behavioralState{b,1} = 'REM Sleep';
                    else
                        disp('No button pressed'); disp(' ')
                        keyboard
                    end
                    close(updatedGUI)
                    break;
                end
                ...
            end
            delete(leftEdge3)
            delete(rightEdge3)
        end
        close(figHandle)
        paramsTable.behavState = behavioralState;
        trainingTable = paramsTable;
        save(trainingDataFileID, 'trainingTable')
    else
        disp([trainingDataFileID ' already exists. Continuing...']); disp(' ')
    end
end

end
