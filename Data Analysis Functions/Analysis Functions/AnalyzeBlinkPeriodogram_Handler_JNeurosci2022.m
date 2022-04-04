function [] = AnalyzeBlinkPeriodogram_Pupil_Handler(rootFolder,delim,runFromStart)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose:
%________________________________________________________________________________________________________________________

% create or load results structure
if runFromStart == true
    Results_BlinkPeriodogram = [];
elseif runFromStart == false
    % load existing results structure, if it exists
    if exist('Results_BlinkPeriodogram.mat','file') == 2
        load('Results_BlinkPeriodogram.mat','-mat')
    else
        Results_BlinkPeriodogram = [];
    end
end
% determine waitbar length
waitBarLength = 0;
folderList = dir('Data');
folderList = folderList(~startsWith({folderList.name}, '.'));
animalIDs = {folderList.name};
waitBarLength = waitBarLength + length(animalIDs);
% run analysis for each animal in the group
aa = 1;
multiWaitbar('Analyzing blinking Lomb-Scargle periodogram',0,'Color','P'); pause(0.25);
for bb = 1:length(animalIDs)
    if isfield(Results_BlinkPeriodogram,(animalIDs{1,bb})) == false
        [Results_BlinkPeriodogram] = AnalyzeBlinkPeriodogram_Pupil(animalIDs{1,bb},rootFolder,delim,Results_BlinkPeriodogram);
    end
    multiWaitbar('Analyzing blinking Lomb-Scargle periodogram','Value',aa/waitBarLength);
    aa = aa + 1;
end

if isfield(Results_BlinkPeriodogram,'results') == false  
    %% pre-allocate data structure
    data.f1 = []; data.S = []; data.blinkArray = [];
    % cd through each animal's directory and extract the appropriate analysis results
    for aa = 1:length(animalIDs)
        animalID = animalIDs{aa,1};
        data.blinkArray = cat(2,data.blinkArray,Results_BlinkPeriodogram.(animalID).blinkArray);
        data.S = cat(2,data.S,Results_BlinkPeriodogram.(animalID).S);
        data.f1 = cat(1,data.f1,Results_BlinkPeriodogram.(animalID).f);
    end
    data.meanS = mean(data.S,2);
    data.meanF1 = mean(data.f1,1);
    %% mean/std
    [data.pxx,data.f2] = plomb(data.blinkArray,2);
    bb = 1; pxx2 = [];
    for aa = 1:length(animalIDs)
        animalID = animalIDs{aa,1};
        avgLen = size(Results_BlinkPeriodogram.(animalID).blinkArray,2);
        if bb == 1
            pxx2(:,aa) = mean(data.pxx(:,bb:bb + avgLen),2);
        else
            pxx2(:,aa) = mean(data.pxx(:,bb + 1:bb + avgLen - 1),2);
        end
        bb = bb + avgLen;
    end
    Results_BlinkPeriodogram.results.f = data.f2;
    Results_BlinkPeriodogram.results.pxx = pxx2;
    save('Results_BlinkPeriodogram.mat','Results_BlinkPeriodogram')
end

end
