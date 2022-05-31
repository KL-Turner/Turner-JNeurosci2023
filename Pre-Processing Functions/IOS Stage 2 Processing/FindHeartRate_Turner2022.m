function [Sr,tr,fr,HR] = FindHeartRate_Turner2022(r,Fr)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Qingguang Zhang
%
% Purpose: Run spectral analysis on CBV signal to extract heart rate
%________________________________________________________________________________________________________________________

% mean subtract to remove slow drift
r = r - mean(r);
% [time band width, number of tapers]
tapers_r = [2,3];
movingwin_r = [3.33,1];
% Frame rate
params_r.Fs = Fr;
params_r.fpass = [5,15];
params_r.tapers = tapers_r;
[Sr,tr,fr] = mtspecgramc(r,movingwin_r,params_r);
% Sr: spectrum; tr: time; fr: frequency
% largest elements along the frequency direction
[~,ridx] = max(Sr,[],2);
HR = fr(ridx); % heart rate, in Hz

end
