function [] = zScorePupilData_JNeurosci2022(procDataFileID,RestingBaselines)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Manually check pupil diameter
%________________________________________________________________________________________________________________________

load(procDataFileID);
% if isfield(ProcData.data.Pupil,'zDiameter') == false %#ok<NODEF>
[~,fileDate,~] = GetFileInfo_JNeurosci2022(procDataFileID);
% if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
strDay = ConvertDate_JNeurosci2022(fileDate);
try
    areaMean = RestingBaselines.manualSelection.Pupil.mmArea.(strDay).mean;
    areaStd = RestingBaselines.manualSelection.Pupil.mmArea.(strDay).std;
    diameterMean = RestingBaselines.manualSelection.Pupil.mmDiameter.(strDay).mean;
    diameterStd = RestingBaselines.manualSelection.Pupil.mmDiameter.(strDay).std;
    pupilArea = ProcData.data.Pupil.mmArea;
    diameter = ProcData.data.Pupil.mmDiameter;
    ProcData.data.Pupil.zArea = (pupilArea - areaMean)./areaStd;
    ProcData.data.Pupil.zDiameter = (diameter - diameterMean)./diameterStd;
catch
    ProcData.data.Pupil.diameterCheck = 'n';
end
save(procDataFileID,'ProcData')
% end
% end

end
