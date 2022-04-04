function [] = ButtonSelect_JNeurosci2022()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Change global variable buttonState to true to begin analysis.
%________________________________________________________________________________________________________________________
%
%   Inputs: None. This function is called via a GUI's buttonState callback.
%
%   Outputs: Changes buttonState to true.
%
%   Last Revised: March 8th, 2019
%________________________________________________________________________________________________________________________

    global buttonState
    buttonState = 1;
end
