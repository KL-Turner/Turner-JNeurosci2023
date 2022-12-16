function [predictions] = FilterIndexREM_JNeurosci2022(predictions,dataLength)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Patch REM event index for unlogical scores
%________________________________________________________________________________________________________________________

% apply a logical patch on the REM events
REMindex = strcmp(predictions,'REM Sleep');
numFiles = length(predictions)/dataLength;
reshapedREMindex = reshape(REMindex,dataLength,numFiles);
patchedREMindex = [];
% patch missing REM indeces due to theta band falling off
for c = 1:size(reshapedREMindex,2)
    remArray = reshapedREMindex(:,c);
    patchedREMarray = LinkBinaryEvents_JNeurosci2022(remArray',[5,0]);
    patchedREMindex = vertcat(patchedREMindex,patchedREMarray'); %#ok<*AGROW>
end
% change labels for each event
for d = 1:length(predictions)
    if patchedREMindex(d,1) == 1
        predictions{d,1} = 'REM Sleep';
    end
end

end