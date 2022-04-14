function [] = UpdateTotalHemoglobin_JNeurosci2022(procDataFileIDs,RestingBaselines,baselineType,imagingType,ledColor)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Converts reflectance values to changes in total hemoglobin using absorbance curves of hardware
%________________________________________________________________________________________________________________________

if strcmpi(ledColor,'green') == true
    ledType = 'M530L3';
    bandfilterType = 'FB530-10';
    cutfilterType = 'MF525-39';
elseif strcmpi(ledColor,'lime') == true
    ledType = 'M565L3';
    bandfilterType = 'FB570-10';
    cutfilterType = 'EO65160';
end
conv2um = 1e6;
[~,~,weightedcoeffHbT] = GetHbcoeffs_JNeurosci2022(ledType,bandfilterType,cutfilterType);
for a = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(a,:);
    disp(['Adding changes in total hemoglobin to ProcData file (' num2str(a) '/' num2str(size(procDataFileIDs,1)) ')...']); disp(' ')
    load(procDataFileID)
    [~,fileDate,~] = GetFileInfo_JNeurosci2022(procDataFileID);
    strDay = ConvertDate_JNeurosci2022(fileDate);
    if strcmp(imagingType,'bilateral') == true || strcmp(imagingType,'gcamp') == true
        cbvFields = {'LH','adjLH','RH','adjRH'};
    elseif strcmp(imagingType,'single') == true
        cbvFields = {'Barrels','adjBarrels'};
    end
    for b = 1:length(cbvFields)
        cbvField = cbvFields{1,b};
        ProcData.data.CBV_HbT.(cbvField) = (log(ProcData.data.CBV.(cbvField)/RestingBaselines.(baselineType).CBV.(cbvField).(strDay).mean))*weightedcoeffHbT*conv2um;
    end
    save(procDataFileID,'ProcData')
end

end
