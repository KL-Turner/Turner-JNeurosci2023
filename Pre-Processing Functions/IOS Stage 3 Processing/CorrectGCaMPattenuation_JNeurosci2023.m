function [] = CorrectGCaMPattenuation_JNeurosci2023(procDataFileIDs,RestingBaselines)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Converts reflectance values to changes in total hemoglobin using absorbance curves of hardware
%________________________________________________________________________________________________________________________

for aa = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(aa,:);
    load(procDataFileID)
    [~,fileDate,~] = GetFileInfo_JNeurosci2023(procDataFileID);
    strDay = ConvertDate_JNeurosci2023(fileDate);
    LH_scale = RestingBaselines.manualSelection.CBV.LH.(strDay).mean/RestingBaselines.manualSelection.GCaMP7s.LH.(strDay).mean;
    RH_scale = RestingBaselines.manualSelection.CBV.RH.(strDay).mean/RestingBaselines.manualSelection.GCaMP7s.RH.(strDay).mean;
    ProcData.data.GCaMP7s.corLH = (ProcData.data.GCaMP7s.LH./ProcData.data.CBV.LH)*LH_scale;
    ProcData.data.GCaMP7s.corRH = (ProcData.data.GCaMP7s.RH./ProcData.data.CBV.RH)*RH_scale;
    save(procDataFileID,'ProcData')
end

end