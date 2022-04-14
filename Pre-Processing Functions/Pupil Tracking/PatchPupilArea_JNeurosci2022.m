function [] = PatchPupilArea_JNeurosci2022(procDataFileID)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: The pupil camera occasionally drops packets of frames. We can calculate the difference in the number
%          of expected frames as well as the indeces that LabVIEW found the packets lost.
%________________________________________________________________________________________________________________________

load(procDataFileID)
if isfield(ProcData.data.Pupil,'pupilPatch') == false
    [animalID,~,fileID] = GetFileInfo_JNeurosci2022(procDataFileID);
    % expected number of frames based on trial duration and sampling rate
    expectedSamples = ProcData.notes.trialDuration_sec*ProcData.notes.pupilCamSamplingRate;
    droppedFrameIndex = str2num(ProcData.notes.droppedPupilCamFrameIndex); %#ok<ST2NM>
    sampleDiff = expectedSamples - length(ProcData.data.Pupil.pupilArea);
    framesPerIndex = ceil(sampleDiff/length(droppedFrameIndex));
    blinks = ProcData.data.Pupil.blinkInds;
    %% patch NaN values
    pupilArea = ProcData.data.Pupil.pupilArea;
    nanLogical = isnan(pupilArea);
    nanIndex = find(nanLogical == 1);
    if sum(nanLogical) > 1 && sum(nanLogical) < 1000
        while sum(nanLogical) >= 1
            pupilArea = fillmissing(pupilArea,'movmedian',3);
            nanLogical = isnan(pupilArea);
        end
        % check length of missing data. If there's periods > than 1 second of continuous NaN then mark the file as bad
        testPatch = fillmissing(ProcData.data.Pupil.pupilArea,'movmedian',31);
        if sum(isnan(testPatch)) > 1
            ProcData.data.Pupil.diameterCheck = 'n';
            ProcData.data.Pupil.diameterCheckComplete = 'y';
        else
            nanFigure = figure;
            plot((1:length(pupilArea))./ProcData.notes.pupilCamSamplingRate,pupilArea,'k');
            hold on
            for aa = 1:length(nanIndex)
                x1 = xline(nanIndex(1,aa)/ProcData.notes.pupilCamSamplingRate,'r');
            end
            if isempty(droppedFrameIndex) == false
                for bb = 1:length(droppedFrameIndex)
                    x2 = xline(droppedFrameIndex(1,bb)/ProcData.notes.pupilCamSamplingRate,'g');
                end
                legend([x1,x2],'NaNs','Dropped frames')
            end
            title([animalID ' ' strrep(fileID,'_',' ')])
            legend(x1,'NaNs')
            xlabel('Time (sec)')
            ylabel('Pupil area (pixels')
            axis tight
            % save the file to directory.
            [pathstr,~,~] = fileparts(cd);
            dirpath = [pathstr '/Figures/Pupil Data Patching/'];
            if ~exist(dirpath,'dir')
                mkdir(dirpath);
            end
            savefig(nanFigure,[dirpath animalID '_' fileID '_PupilPatch'])
            close(nanFigure)
        end
    end
    %% patch missing frames now that NaN are gone
    if ~isempty(droppedFrameIndex)
        addedFrames = 0;
        % each dropped index
        for cc = 1:length(droppedFrameIndex)
            % for the first event, it's okay to start at the actual index
            if cc == 1
                leftEdge = droppedFrameIndex(1,cc);
            else
                % for all other dropped frames after the first, we need to correct for the fact that index is shifted right.
                leftEdge = droppedFrameIndex(1,cc) + ((cc - 1)*framesPerIndex);
            end
            % set the edges for the interpolation points. we want n number of samples between the two points,vthe left and
            % right edge values. This equates to having a 1/(dropped frames + 1) step size between the edges.
            rightEdge = leftEdge + 1;
            patchFrameInds = leftEdge:(1/(framesPerIndex + 1)):rightEdge;
            % concatenate the original data for the first index, then the new patched data for all subsequent
            % indeces. Take the values from 1:left edge, add in the new frames, then right edge to end.
            if cc == 1
                patchFrameVals = interp1(1:length(pupilArea),pupilArea,patchFrameInds); % linear interp
                snipPatchFrameVals = patchFrameVals(2:end - 1);
                try
                    patchedPupilArea = horzcat(pupilArea(1:leftEdge),snipPatchFrameVals,pupilArea(rightEdge:end));
                catch
                    patchedPupilArea = horzcat(pupilArea(1:end),snipPatchFrameVals);
                end
            else
                patchFrameVals = interp1(1:length(patchedPupilArea),patchedPupilArea,patchFrameInds); % linear interp
                snipPatchFrameVals = patchFrameVals(2:end - 1);
                patchedPupilArea = horzcat(patchedPupilArea(1:leftEdge),snipPatchFrameVals,patchedPupilArea(rightEdge:end));
            end
            addedFrames = addedFrames + length(snipPatchFrameVals);
            addedFrameIndex(1,cc) = addedFrames;
            if cc == 1
                for qq = 1:length(blinks)
                    if leftEdge < blinks(1,qq)
                        shiftedBlinks(1,qq) = blinks(1,qq) + addedFrames;
                    else
                        shiftedBlinks(1,qq) = blinks(1,qq);
                    end
                end
            else
                for qq = 1:length(blinks)
                    if leftEdge < blinks(1,qq)
                        shiftedBlinks(1,qq) = shiftedBlinks(1,qq) + addedFrames;
                    else
                        shiftedBlinks(1,qq) = shiftedBlinks(1,qq);
                    end
                end
            end
        end
        % due to rounding up on the number of dropped frames per index, we have a few extra frames. Snip them off.
        patchedPupilArea = patchedPupilArea(1:expectedSamples);
        if isempty(blinks) == false
            ProcData.data.Pupil.shiftedBlinks = shiftedBlinks;
            ProcData.data.Pupil.addedFrameIndex = addedFrameIndex;
        end
    else
        patchedPupilArea = pupilArea(1:expectedSamples);
    end
    ProcData.data.Pupil.pupilArea = patchedPupilArea;
    ProcData.data.Pupil.pupilPatch = 'y';
    save(procDataFileID,'ProcData')
end

end
