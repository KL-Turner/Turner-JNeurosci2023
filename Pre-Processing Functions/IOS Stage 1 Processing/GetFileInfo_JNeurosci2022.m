function [animalID,fileDate,fileID] = GetFileInfo_IOS(fileName)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%________________________________________________________________________________________________________________________
%
%   Purpose: Identify important aspects of a file name and output each individually.
%________________________________________________________________________________________________________________________

% Identify the extension
extInd = strfind(fileName(1,:),'.');
extension = fileName(1,extInd + 1:end);
% Identify the underscores
fileBreaks = strfind(fileName(1,:),'_');
switch extension
    case 'bin'
        animalID = [];
        fileDate = fileName(:,1:fileBreaks(1) - 1);
        fileID = fileName(:,1:fileBreaks(4) - 1);
    case 'mat'
        % Use the known format to parse
        animalID = fileName(:,1:fileBreaks(1) - 1);
        if numel(fileBreaks) > 3
            fileDate = fileName(:,fileBreaks(1) + 1:fileBreaks(2) - 1);
            fileID = fileName(:,fileBreaks(1) + 1:fileBreaks(5) - 1);
        else
            fileDate = [];
            fileID = [];
        end
end

end
