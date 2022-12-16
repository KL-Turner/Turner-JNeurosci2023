function [FiltArray] = FilterEvents_JNeurosci2022(DataStruct,Criteria)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%
% Purpose: Filters a data structure according to a set of user-defined criteria.
%________________________________________________________________________________________________________________________

FName = Criteria.Fieldname;
Comp = Criteria.Comparison;
Val = Criteria.Value;
if length(FName)~=length(Comp)
    error(' ')
elseif length(FName)~=length(Val)
    error(' ')
end
FiltArray = true(size(DataStruct.data,1),1);
for FN = 1:length(FName)
    if ~isfield(DataStruct,FName{FN})
        error('Criteria field not found')
    end
    switch Comp{FN}
        case 'gt'
            if iscell(DataStruct.(FName{FN}))
                if ischar(DataStruct.(FName{FN}){1})
                    error(' ')
                else
                    IndFilt = false(size(FiltArray));
                    for c = 1:length(DataStruct.(FName{FN}))
                        IndFilt(c) = all(gt(DataStruct.(FName{FN}){c},Val{FN}));
                    end
                end
            else
                IndFilt = gt(DataStruct.(FName{FN}),Val{FN});
            end
        case 'lt'
             if iscell(DataStruct.(FName{FN}))
                if ischar(DataStruct.(FName{FN}){1})
                    error(' ')
                else
                    IndFilt = false(size(FiltArray));
                    for c = 1:length(DataStruct.(FName{FN}))
                        IndFilt(c) = all(lt(DataStruct.(FName{FN}){c},Val{FN}));
                    end
                end
            else
                IndFilt = lt(DataStruct.(FName{FN}),Val{FN});
            end
        case 'equal'
            if iscell(DataStruct.(FName{FN}))
                IndFilt = strcmp(DataStruct.(FName{FN}),Val{FN});
            else
                IndFilt = DataStruct.(FName{FN}) == Val{FN};
            end
        otherwise
            error(' ')
    end
    FiltArray = and(FiltArray,IndFilt);
end

end
