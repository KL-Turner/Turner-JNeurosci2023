function [fname] = IdentifyStructureSubfield_Turner2022(Structure,field)
%________________________________________________________________________________________________________________________
% Edited by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%
% Purpose: Finds a the subfield of a structure that contains the requested field.
%________________________________________________________________________________________________________________________

fnames = fieldnames(Structure);
fname = [];
for fn = 1:length(fnames)
    if isfield(Structure.(fnames{fn}),field)
        fname = fnames{fn};
    end
end

end