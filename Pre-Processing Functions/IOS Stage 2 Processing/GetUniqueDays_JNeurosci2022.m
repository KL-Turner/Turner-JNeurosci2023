function [uniqueDays,dayIndex,dayID] = GetUniqueDays_JNeurosci2022(dateList)
%________________________________________________________________________________________________________________________
% Edited by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%________________________________________________________________________________________________________________________
%
%   Purpse: Takes a list of fileDates and determines how many unique individual days there are. 
%________________________________________________________________________________________________________________________

if iscellstr(dateList) %#ok<ISCLSTR>
    temp = cell2mat(dateList);
    dateList = temp;
end
filebreaks = strfind(dateList(1,:),'_');
if isempty(filebreaks)
    allDates = dateList;
elseif or(length(filebreaks) == 3,length(filebreaks) == 4)
    allDates = dateList(:,1:filebreaks(1)-1);
elseif length(filebreaks) == 6
    dateInd = filebreaks(2) + 1:filebreaks(3) - 1;
    allDates = dateList(:,dateInd);
else
    error('Format of the list of dates not recognized...')
end
allDays = mat2cell(allDates,ones(1,size(allDates,1)));
[uniqueDays,dayIndex,dayID] = unique(allDays);

end
