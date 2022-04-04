function [clearvars] = zap()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: shorthand to clear, clc, close all
%________________________________________________________________________________________________________________________
%
%   Inputs: none, just type zap into the command window
%
%   Outputs: zap clears workspace, clears command window, closes all figures
%
%   Last Revised: March 9th, 2019
%________________________________________________________________________________________________________________________

evalin('base','clear')
clc
close all

end
