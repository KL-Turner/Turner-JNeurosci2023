function [fileDateTime] = ConvertDateTime_JNeurosci2022(fileInfo)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%________________________________________________________________________________________________________________________

year = ['20' fileInfo(1:2)];
dateMonth = ConvertDate_IOS_eLife2020(fileInfo(1:6));
month = dateMonth(1:3);
date = dateMonth(4:5);
hours = fileInfo(8:9);
minutes = fileInfo(11:12);
seconds = fileInfo(14:15);
fileDateTime = [date '-' month '-' year ' ' hours ':' minutes ':' seconds];

end
