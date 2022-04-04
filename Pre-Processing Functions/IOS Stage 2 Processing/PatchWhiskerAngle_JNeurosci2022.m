function [patchedWhiskerAngle] = PatchWhiskerAngle_JNeurosci2022(whiskerAngle,fs,expectedDuration_Sec,droppedFrameIndex)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: The whisker camera occasionally drops packets of frames. We can calculate the difference in the number
%            of expected frames as well as the indeces that LabVIEW found the packets lost. This is a rough fix, as
%            we are not sure the exact number of frames at each index, only the total number.
%________________________________________________________________________________________________________________________

expectedFrames = expectedDuration_Sec*fs;
droppedFrameIndex = str2num(droppedFrameIndex);
% loop through each dropped frame and fix the missing value
if ~isempty(droppedFrameIndex)
    for aa = 1:length(droppedFrameIndex)
        try
            % find the values on either side of the dropped frame index
            leftEdge = whiskerAngle(droppedFrameIndex(aa) - 1);
            rightEdge = whiskerAngle(droppedFrameIndex(aa));
            patchedFrame = (leftEdge + rightEdge)/2;
            whiskerAngle = horzcat(whiskerAngle(1:droppedFrameIndex(aa) - 1),patchedFrame,whiskerAngle(droppedFrameIndex(aa):end));
        catch
            % find the values on either side of the dropped frame index
            whiskerAngle = horzcat(whiskerAngle,ones(1,1)*mean(whiskerAngle)); %#ok<*AGROW>
        end
    end
end
trailingEdge = expectedFrames - length(whiskerAngle);
patchedWhiskerAngle = horzcat(whiskerAngle,ones(1,trailingEdge)*mean(whiskerAngle));
patchedWhiskerAngle = patchedWhiskerAngle(1:expectedFrames);
% due to rounding up on the number of dropped frames per index, we have a few extra frames. Snip them off.

end

