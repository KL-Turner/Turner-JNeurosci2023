function [day_inds,day_logic] = GetDayInds_JNeurosci2022(DateList,Ind_Day)
%___________________________________________________________________________________________________
% Edited by Kevin L. Turner 
% Ph.D. Candidate, Department of Bioengineering 
% The Pennsylvania State University
%
% Originally written by Aaron T. Winder
%________________________________________________________________________________________________________________________
%
%   Purpose: Gets the indeces of each unique day in a file list
%________________________________________________________________________________________________________________________

% Process the list for format
% Tramspose into row vector if needed
if size(DateList,1)>size(DateList,2)
    temp = DateList';
    DateList = temp;
    clear temp;
end
% Convert from cell if needed
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
% Convert the fileid list into a searchable form
listdays = mat2cell(AllDates,ones(1,size(AllDates,1)));
% Search for matching inds
day_logic = strcmp(listdays,Ind_Day);
day_inds = find(day_logic);

end
