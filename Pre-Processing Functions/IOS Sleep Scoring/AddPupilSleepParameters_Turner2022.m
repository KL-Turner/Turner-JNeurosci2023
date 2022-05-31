function [] = AddPupilSleepParameters_Turner2022(procDataFileIDs)
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
    % only apply to files with accurate diameter tracking
    if strcmp(ProcData.data.Pupil.diameterCheck,'y') == true
        % create fields for the data
        dataTypes = {'pupilArea','diameter','mmArea','mmDiameter','zArea','zDiameter'};
        for aa = 1:length(dataTypes)
            dataType = dataTypes{1,aa};
            samplingRate = ProcData.notes.dsFs;
            [z,p,k] = butter(4,1/(samplingRate/2),'low');
            [sos,g] = zp2sos(z,p,k);
            try
                data.(dataType).data = filtfilt(sos,g,ProcData.data.Pupil.(dataType));
            catch
                data.(dataType).data = ProcData.data.Pupil.(dataType);
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
        % save data under ProcData file
        save(procDataFileID,'ProcData');
    end
end

end
