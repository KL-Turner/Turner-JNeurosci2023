function [dayInds,dayLogic] = GetDayInds_JNeurosci2023(DateList,Ind_Day)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%
% Purpose: Gets the indeces of each unique day in a file list
%________________________________________________________________________________________________________________________

% process the list for format
% transpose into row vector if needed
if size(DateList,1)>size(DateList,2)
    temp = DateList';
    DateList = temp;
    clear temp;
end
% convert from cell if needed
if iscell(DateList)
    temp = reshape(cell2mat(DateList),length(DateList{1}),length(DateList))';
    DateList = temp;
end
filebreaks = strfind(DateList(1,:),'_');
if isempty(filebreaks)
    AllDates = DateList;
elseif or(length(filebreaks) == 3,length(filebreaks) == 4)
    AllDates = DateList(:,1:filebreaks(1) - 1);
elseif length(filebreaks) == 6
    date_ind = filebreaks(2) + 1:filebreaks(3) - 1;
    AllDates = DateList(:,date_ind);
else
    error('Format of the list of dates not recognized...')
end
% convert the fileid list into a searchable form
listdays = mat2cell(AllDates,ones(1,size(AllDates,1)));
% search for matching inds
dayLogic = strcmp(listdays,Ind_Day);
dayInds = find(dayLogic);

end
