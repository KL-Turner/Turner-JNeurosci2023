function [] = ConvertPupilAreaToDiameter_JNeurosci2022(procDataFileID)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Manually check pupil diameter
%________________________________________________________________________________________________________________________

load(procDataFileID);
pupilArea = ProcData.data.Pupil.pupilArea;
diameter = sqrt(pupilArea./pi)*2;
ProcData.data.Pupil.diameter = diameter;
ProcData.data.Pupil.mmPerPixel = 0.018;
ProcData.data.Pupil.mmDiameter = diameter.*ProcData.data.Pupil.mmPerPixel;
ProcData.data.Pupil.mmArea = pupilArea.*(ProcData.data.Pupil.mmPerPixel^2);
save(procDataFileID,'ProcData')

end