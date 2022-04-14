function [] = CheckForNaNs_JNeurosci2022(ProcData,imagingType)
%________________________________________________________________________________________________________________________
% Edited by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Check the most important CBV ROIs for any NaN values where the IOS camera glitched.
%________________________________________________________________________________________________________________________

% check ROI fields corresponding to the imaging type (single, bilateral hem)
ROInames = fieldnames(ProcData.data.CBV);
% go through each ROI and check each individual value
for b = 1:length(ROInames)
    nanCheck{b,1} = sum(isnan(ProcData.data.CBV.(ROInames{b,1}))); %#ok<AGROW>
end
% pause the program if an NaN is found. Will need to add an interpolation method here if NaN events are found and
% the specific file needs to be kept
for b = 1:length(nanCheck)
    if nanCheck{b,1} ~= 0
        disp('WARNING - NaNs found in CBV array'); disp(' ')
        keyboard
    end
end
if strcmpi(imagingType,'GCaMP') == true
    for b = 1:length(ROInames)
        gcampNanCheck{b,1} = sum(isnan(ProcData.data.GCaMP7s.(ROInames{b,1})));
    end
    for b = 1:length(ROInames)
        deoxyNanCheck{b,1} = sum(isnan(ProcData.data.Deoxy.(ROInames{b,1})));
    end
end
% pause the program if an NaN is found. Will need to add an interpolation method here if NaN events are found and
% the specific file needs to be kept
for b = 1:length(gcampNanCheck)
    if gcampNanCheck{b,1} ~= 0
        disp('WARNING - NaNs found in CBV array'); disp(' ')
        keyboard
    end
end
% pause the program if an NaN is found. Will need to add an interpolation method here if NaN events are found and
% the specific file needs to be kept
for b = 1:length(deoxyNanCheck)
    if deoxyNanCheck{b,1} ~= 0
        disp('WARNING - NaNs found in CBV array'); disp(' ')
        keyboard
    end
end

end