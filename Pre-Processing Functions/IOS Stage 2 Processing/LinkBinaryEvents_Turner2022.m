function [linkedWF] = LinkBinaryEvents_Turner2022(binWF,dCrit)
%________________________________________________________________________________________________________________________
% Edited by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%
% Purpose: Link binary events that occur within a certain amount of time.
%________________________________________________________________________________________________________________________

% identify edges, control for trial start/stop
dBinWF = diff(gt(binWF,0));
upInd = find(dBinWF == 1);
downInd = find(dBinWF == -1);
if binWF(end) > 0
    downInd = [downInd,length(binWF)];
end
if binWF(1) > 0
    upInd = [1,upInd];
end
% link periods of bin_wf == 0 together if less than dCrit(1). calculate time between events
brkTimes = upInd(2:length(upInd)) - downInd(1:(length(downInd) - 1));
% identify times less than user-defined period
sub_dCritDowns = find(lt(brkTimes,dCrit(1)));
% link any identified breaks together
if isempty(sub_dCritDowns) == 0
    for d = 1:length(sub_dCritDowns)
        start = downInd(sub_dCritDowns(d));
        stop = upInd(sub_dCritDowns(d) + 1);
        binWF(start:stop) = 1;
    end
end
% link periods of bin_wf == 1 together if less than dCrit(2)
hitimes = downInd - upInd;
blips = find(lt(hitimes,dCrit(2)) == 1);
if isempty(blips) == 0
    for b = 1:length(blips)
        start = upInd(blips(b));
        stop = downInd(blips(b));
        binWF(start:stop) = 0;
    end
end
linkedWF = binWF;

end
