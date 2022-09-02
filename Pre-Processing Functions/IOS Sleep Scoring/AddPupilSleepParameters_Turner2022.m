function [] = AddPupilSleepParameters_Turner2022(procDataFileIDs,RestingBaselines)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Organize data into appropriate bins for sleep scoring characterization
%________________________________________________________________________________________________________________________

for a = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(a,:);
    load(procDataFileID)
    [~,~,fileDate] = GetFileInfo_Turner2022(procDataFileID);
    strDay = ConvertDate_Turner2022(fileDate);
    % only apply to files with accurate diameter tracking
    if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
        % create fields for the data
        dataTypes = {'pupilArea','diameter','mmArea','mmDiameter','zArea','zDiameter','eyeMotion','centroidX','centroidY','whiskerMotion'};
        for aa = 1:length(dataTypes)
            dataType = dataTypes{1,aa};
            samplingRate = ProcData.notes.dsFs;
            [z,p,k] = butter(4,1/(samplingRate/2),'low');
            [sos,g] = zp2sos(z,p,k);
            if strcmp(dataType,'eyeMotion') == true
                [z,p,k] = butter(4,10/(samplingRate/2),'low');
                [sos,g] = zp2sos(z,p,k);
                try
                    centroidX = filtfilt(sos,g,ProcData.data.Pupil.patchCentroidX - RestingBaselines.manualSelection.Pupil.patchCentroidX.(strDay).mean);
                    centroidY = filtfilt(sos,g,ProcData.data.Pupil.patchCentroidY - RestingBaselines.manualSelection.Pupil.patchCentroidY.(strDay).mean);
                catch
                    centroidX = ProcData.data.Pupil.patchCentroidX - RestingBaselines.manualSelection.Pupil.patchCentroidX.(strDay).mean;
                    centroidY = ProcData.data.Pupil.patchCentroidY - RestingBaselines.manualSelection.Pupil.patchCentroidY.(strDay).mean;
                end
                for dd = 1:length(centroidX)
                    if dd == 1
                        distanceTraveled(1,dd) = 0;
                    else
                        xPt = [centroidX(1,dd - 1),centroidY(1,dd - 1)];
                        yPt = [centroidX(1,dd),centroidY(1,dd)];
                        distanceTraveled(1,dd) = pdist([xPt;yPt],'euclidean');
                    end
                end
                data.(dataType).data = distanceTraveled*ProcData.data.Pupil.mmPerPixel;
            elseif strcmp(dataType,'centroidX') == true
                try
                    data.(dataType).data = filtfilt(sos,g,ProcData.data.Pupil.patchCentroidX - RestingBaselines.manualSelection.Pupil.patchCentroidX.(strDay).mean);
                catch
                    data.(dataType).data = ProcData.data.Pupil.patchCentroidX - RestingBaselines.manualSelection.Pupil.patchCentroidX.(strDay).mean;
                end
            elseif strcmp(dataType,'centroidY') == true
                try
                    data.(dataType).data = filtfilt(sos,g,ProcData.data.Pupil.patchCentroidY - RestingBaselines.manualSelection.Pupil.patchCentroidY.(strDay).mean);
                catch
                    data.(dataType).data = ProcData.data.Pupil.patchCentroidY - RestingBaselines.manualSelection.Pupil.patchCentroidY.(strDay).mean;
                end
            elseif strcmp(dataType,'whiskerMotion')
                data.(dataType).data = ProcData.data.whiskerAngle.^2;
            else
                try
                    data.(dataType).data = filtfilt(sos,g,ProcData.data.Pupil.(dataType));
                catch
                    data.(dataType).data = ProcData.data.Pupil.(dataType);
                end
            end
            data.(dataType).struct = cell(180,1);
            % loop through all samples across the 15 minutes in 5 second bins (180 total)
            for b = 1:180
                if b == 1
                    data.(dataType).struct(b,1) = {data.(dataType).data(b:150)};
                elseif b == 180
                    data.(dataType).struct(b,1) = {data.(dataType).data((((150*(b - 1)) + 1)):end)};
                else
                    data.(dataType).struct(b,1) = {data.(dataType).data((((150*(b - 1)) + 1)):(150*b))};
                end
            end
            ProcData.sleep.parameters.Pupil.(dataType) = data.(dataType).struct;
        end
    end
    % save data under ProcData file
    save(procDataFileID,'ProcData');
end

end

