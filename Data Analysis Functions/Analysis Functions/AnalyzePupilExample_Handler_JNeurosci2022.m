function [] = AnalyzePupilExample_Pupil_Handler(rootFolder,delim,runFromStart)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: 
%________________________________________________________________________________________________________________________

% create or load results structure
if runFromStart == true
    Results_Example = [];
elseif runFromStart == false
    % load existing results structure, if it exists
    if exist('Results_Example.mat','file') == 2
        load('Results_Example.mat','-mat')
    else
        Results_Example = [];
    end
end
% run analysis for each animal in the group
if isempty(Results_Example) == true
    AnalyzePupilExample_Pupil(rootFolder,delim,Results_Example);
end

end
