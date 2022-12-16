%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%y
% Purpose: patch major, minor, and centroid data same as area
%________________________________________________________________________________________________________________________

zap;
% character list of all ProcData files
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
for qq = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(qq,:);
    load(procDataFileID)
    if isfield(ProcData.data.Pupil,'accessoryPatch') == false
        disp(['Updating accessory pupil data types of file ' num2str(qq) '/' num2str(size(procDataFileIDs,1))]); disp(' ')
        [animalID,~,fileID] = GetFileInfo_JNeurosci2022(procDataFileID);
        % expected number of frames based on trial duration and sampling rate
        expectedSamples = ProcData.notes.trialDuration_sec*ProcData.notes.pupilCamSamplingRate;
        droppedFrameIndex = str2num(ProcData.notes.droppedPupilCamFrameIndex); %#ok<ST2NM>
        sampleDiff = expectedSamples - length(ProcData.data.Pupil.pupilMajor);
        framesPerIndex = ceil(sampleDiff/length(droppedFrameIndex));
        %% patch NaN values
        pupilMinorAxis = ProcData.data.Pupil.pupilMinor;
        pupilMajorAxis = ProcData.data.Pupil.pupilMajor;
        pupilCentroidX = ProcData.data.Pupil.pupilCentroid(:,1)';
        pupilCentroidY = ProcData.data.Pupil.pupilCentroid(:,2)';
        %% patch NaNs due to blinking
        blinkNaNs = isnan(pupilMajorAxis);
        [linkedBlinkIndex] = LinkBinaryEvents_JNeurosci2022(gt(blinkNaNs,0),[30,0]); % link greater than 1 second
        % identify edges for interpolation
        xx = 1;
        edgeFoundA = false;
        startEdgeA = [];
        endEdgeA = [];
        for aa = 1:length(linkedBlinkIndex)
            if edgeFoundA == false
                if linkedBlinkIndex(1,aa) == 1 && (aa < length(linkedBlinkIndex)) == true
                    startEdgeA(xx,1) = aa; %#ok<*SAGROW>
                    edgeFoundA = true;
                end
            elseif edgeFoundA == true
                if linkedBlinkIndex(1,aa) == 0
                    endEdgeA(xx,1) = aa;
                    edgeFoundA = false;
                    xx = xx + 1;
                elseif (length(linkedBlinkIndex) == aa) == true && (linkedBlinkIndex(1,aa) == 1) == true
                    endEdgeA(xx,1) = aa;
                end
            end
        end
        % fill from start:ending edges of rapid pupil fluctuations that weren't NaN
        for aa = 1:length(startEdgeA)
            try
                pupilMinorAxis(startEdgeA(aa,1) - 2:endEdgeA(aa,1) + 2) = NaN;
                pupilMajorAxis(startEdgeA(aa,1) - 2:endEdgeA(aa,1) + 2) = NaN;
                pupilCentroidX(startEdgeA(aa,1) - 2:endEdgeA(aa,1) + 2) = NaN;
                pupilCentroidY(startEdgeA(aa,1) - 2:endEdgeA(aa,1) + 2) = NaN;
                patchLength(aa,1) = (endEdgeA(aa,1) + 2) - (startEdgeA(aa,1) - 2);
            catch
                pupilMinorAxis(startEdgeA(aa,1):endEdgeA(aa,1)) = NaN;
                pupilMajorAxis(startEdgeA(aa,1):endEdgeA(aa,1)) = NaN;
                pupilCentroidX(startEdgeA(aa,1):endEdgeA(aa,1)) = NaN;
                pupilCentroidY(startEdgeA(aa,1):endEdgeA(aa,1)) = NaN;
                patchLength(aa,1) = endEdgeA(aa,1) - startEdgeA(aa,1);
            end
        end
        % patch NaN values with moving median filter
        try
            patchedMinorAxis = fillmissing(minorAxis,'movmedian',max(patchLength)*2);
            patchedMajorAxis = fillmissing(majorAxis,'movmedian',max(patchLength)*2);
            patchedCentroidX = fillmissing(pupilCentroidX,'movmedian',max(patchLength)*2);
            patchedCentroidY = fillmissing(pupilCentroidY,'movmedian',max(patchLength)*2);
        catch
            patchedMinorAxis = pupilMinorAxis;
            patchedMajorAxis = pupilMajorAxis;
            patchedCentroidX = pupilCentroidX;
            patchedCentroidY = pupilCentroidY;
        end
        %% patch sudden spikes
        diffArea = abs(diff(patchedMajorAxis));
        % threshold for interpolation
        threshold = 250;
        diffIndex = diffArea > threshold;
        [linkedDiffIndex] = LinkBinaryEvents_JNeurosci2022(gt(diffIndex,0),[30*2,0]);
        % identify edges for interpolation
        edgeFoundB = false;
        xx = 1;
        startEdgeB = [];
        endEdgeB = [];
        for aa = 1:length(linkedDiffIndex)
            if edgeFoundB == false
                if (linkedDiffIndex(1,aa) == 1) == true && (aa < length(linkedDiffIndex)) == true
                    startEdgeB(xx,1) = aa;
                    edgeFoundB = true;
                end
            elseif edgeFoundB == true
                if linkedDiffIndex(1,aa) == 0
                    endEdgeB(xx,1) = aa;
                    edgeFoundB = false;
                    xx = xx + 1;
                elseif (length(linkedDiffIndex) == aa) == true && (linkedDiffIndex(1,aa) == 1) == true && edgeFoundB == true
                    endEdgeB(xx,1) = aa;
                end
            end
        end
        % fill from start:ending edges of rapid pupil fluctuations that weren't NaN
        for aa = 1:length(startEdgeB)
            try
                patchedMinorAxis(startEdgeB(aa,1) - 2:endEdgeB(aa,1) + 2) = NaN;
                patchedMajorAxis(startEdgeB(aa,1) - 2:endEdgeB(aa,1) + 2) = NaN;
                patchedCentroidX(startEdgeB(aa,1) - 2:endEdgeB(aa,1) + 2) = NaN;
                patchedCentroidY(startEdgeB(aa,1) - 2:endEdgeB(aa,1) + 2) = NaN;
                patchLength = (endEdgeB(aa,1) + 2) - (startEdgeB(aa,1) - 2);
            catch
                patchedMinorAxis(startEdgeB(aa,1):endEdgeB(aa,1)) = NaN;
                patchedMajorAxis(startEdgeB(aa,1):endEdgeB(aa,1)) = NaN;
                patchedCentroidX(startEdgeB(aa,1):endEdgeB(aa,1)) = NaN;
                patchedCentroidY(startEdgeB(aa,1):endEdgeB(aa,1)) = NaN;
                patchLength = endEdgeB(aa,1) - startEdgeB(aa,1);
            end
            patchedMinorAxis = fillmissing(patchedMinorAxis,'movmedian',patchLength*2);
            patchedMajorAxis = fillmissing(patchedMajorAxis,'movmedian',patchLength*2);
            patchedCentroidX = fillmissing(patchedCentroidX,'movmedian',patchLength*2);
            patchedCentroidY = fillmissing(patchedCentroidY,'movmedian',patchLength*2);
        end
        pupilMinorAxis = patchedMinorAxis;
        pupilMajorAxis = patchedMajorAxis;
        pupilCentroidX = patchedCentroidX;
        pupilCentroidY = patchedCentroidY;
        nanLogical = isnan(pupilMajorAxis);
        nanIndex = find(nanLogical == 1);
        if sum(nanLogical) > 1 && sum(nanLogical) < 1000
            while sum(nanLogical) >= 1
                pupilMinorAxis = fillmissing(pupilMinorAxis,'movmedian',3);
                pupilMajorAxis = fillmissing(pupilMajorAxis,'movmedian',3);
                pupilCentroidX = fillmissing(pupilCentroidX,'movmedian',3);
                pupilCentroidY = fillmissing(pupilCentroidY,'movmedian',3);
                nanLogical = isnan(pupilMajorAxis);
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
                    patchFrameVals_minorAxis = interp1(1:length(pupilMinorAxis),pupilMinorAxis,patchFrameInds); % linear interp
                    patchFrameVals_majorAxis = interp1(1:length(pupilMajorAxis),pupilMajorAxis,patchFrameInds); % linear interp
                    patchFrameVals_centroidX = interp1(1:length(pupilCentroidX),pupilCentroidX,patchFrameInds); % linear interp
                    patchFrameVals_centroidY = interp1(1:length(pupilCentroidY),pupilCentroidY,patchFrameInds); % linear interp
                    snipPatchFrameVals_minorAxis = patchFrameVals_minorAxis(2:end - 1);
                    snipPatchFrameVals_majorAxis = patchFrameVals_majorAxis(2:end - 1);
                    snipPatchFrameVals_centroidX = patchFrameVals_centroidX(2:end - 1);
                    snipPatchFrameVals_centroidY = patchFrameVals_centroidY(2:end - 1);
                    try
                        patchedMinorAxis = horzcat(pupilMinorAxis(1:leftEdge),snipPatchFrameVals_minorAxis,pupilMinorAxis(rightEdge:end));
                        patchedMajorAxis = horzcat(pupilMajorAxis(1:leftEdge),snipPatchFrameVals_majorAxis,pupilMajorAxis(rightEdge:end));
                        patchedCentroidX = horzcat(pupilCentroidX(1:leftEdge),snipPatchFrameVals_centroidX,pupilCentroidX(rightEdge:end));
                        patchedCentroidY = horzcat(pupilCentroidY(1:leftEdge),snipPatchFrameVals_centroidY,pupilCentroidY(rightEdge:end));
                    catch
                        patchedMinorAxis = horzcat(pupilMinorAxis(1:end),snipPatchFrameVals_minorAxis);
                        patchedMajorAxis = horzcat(pupilMajorAxis(1:end),snipPatchFrameVals_majorAxis);
                        patchedCentroidX = horzcat(pupilCentroidX(1:end),snipPatchFrameVals_centroidX);
                        patchedCentroidY = horzcat(pupilCentroidY(1:end),snipPatchFrameVals_centroidY);
                    end
                else
                    patchFrameVals_minorAxis = interp1(1:length(patchedMinorAxis),patchedMinorAxis,patchFrameInds); % linear interp
                    patchFrameVals_majorAxis = interp1(1:length(patchedMajorAxis),patchedMajorAxis,patchFrameInds); % linear interp
                    patchFrameVals_centroidX = interp1(1:length(patchedCentroidX),patchedCentroidX,patchFrameInds); % linear interp
                    patchFrameVals_centroidY = interp1(1:length(patchedCentroidY),patchedCentroidY,patchFrameInds); % linear interp
                    snipPatchFrameVals_minorAxis = patchFrameVals_minorAxis(2:end - 1);
                    snipPatchFrameVals_majorAxis = patchFrameVals_majorAxis(2:end - 1);
                    snipPatchFrameVals_centroidX = patchFrameVals_centroidX(2:end - 1);
                    snipPatchFrameVals_centroidY = patchFrameVals_centroidY(2:end - 1);
                    patchedMinorAxis = horzcat(patchedMinorAxis(1:leftEdge),snipPatchFrameVals_minorAxis,patchedMinorAxis(rightEdge:end));
                    patchedMajorAxis = horzcat(patchedMajorAxis(1:leftEdge),snipPatchFrameVals_majorAxis,patchedMajorAxis(rightEdge:end));
                    patchedCentroidX = horzcat(patchedCentroidX(1:leftEdge),snipPatchFrameVals_centroidX,patchedCentroidX(rightEdge:end));
                    patchedCentroidY = horzcat(patchedCentroidY(1:leftEdge),snipPatchFrameVals_centroidY,patchedCentroidY(rightEdge:end));
                end
            end
            % due to rounding up on the number of dropped frames per index, we have a few extra frames. Snip them off.
            patchedMinorAxis = patchedMinorAxis(1:expectedSamples);
            patchedMajorAxis = patchedMajorAxis(1:expectedSamples);
            patchedCentroidX = patchedCentroidX(1:expectedSamples);
            patchedCentroidY = patchedCentroidY(1:expectedSamples);
        else
            patchedMinorAxis = pupilMinorAxis(1:expectedSamples);
            patchedMajorAxis = pupilMajorAxis(1:expectedSamples);
            patchedCentroidX = pupilCentroidX(1:expectedSamples);
            patchedCentroidY = pupilCentroidY(1:expectedSamples);
        end
        ProcData.data.Pupil.patchMinorAxis = patchedMinorAxis;
        ProcData.data.Pupil.patchMajorAxis = patchedMajorAxis;
        ProcData.data.Pupil.patchCentroidX = patchedCentroidX;
        ProcData.data.Pupil.patchCentroidY = patchedCentroidY;
        % save data
        ProcData.data.Pupil.accessoryPatch = 'y';
        save(procDataFileID,'ProcData')
    else
        disp(['Data types already updated for ' num2str(qq) '/' num2str(size(procDataFileIDs,1))]); disp(' ')
    end
end
