function [ok] = CheckForThreshold_JNeurosci2023(sfield,animal)
%________________________________________________________________________________________________________________________
% Edited by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%
% Purpose: Check to see if a threshold has already been created for a given field in a given day.
%________________________________________________________________________________________________________________________

% navigate to Shared Variables folder
disp(['CheckForThreshold.m: Checking for Threshold field: ' sfield '...']); disp(' ')
% begin Check
ok = 0;
if exist([animal '_Thresholds.mat'],'file') == 2
    load([animal '_Thresholds.mat']);
    if isfield(Thresholds, sfield)
        ok = 1;
        disp(['CheckForThreshold.m: Threshold: ' sfield ' found.']); disp(' ')
    else
        disp(['CheckForThreshold.m: Threshold: ' sfield ' not found.']); disp(' ')
    end
end

end
