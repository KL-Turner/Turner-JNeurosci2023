function [procNeuro,neuroFs] = ProcessNeuro_JNeurosci2022(RawData,expectedLength,neurType,neuralFieldName)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%________________________________________________________________________________________________________________________
%
%   Purpose: Bandpass filter the desired neural band.
%________________________________________________________________________________________________________________________

% Thresholds and Neurtype switch
trimmedNeuro = RawData.data.(neuralFieldName)(1:min(expectedLength,length(RawData.data.(neuralFieldName))));
analogFs = RawData.notes.analogSamplingRate;
switch neurType
    case 'MUA'
        fpass = [300,3000];
    case 'Gam'
        fpass = [30,100];
    case 'Beta'
        fpass = [13,30];
    case 'Alpha'
        fpass = [10,13];
    case 'Theta'
        fpass = [4,10];
    case 'Delta'
        fpass = [1,4];
end

% CALCULATE NEURAL POWER
if ismember(neurType,[{'MUA'},{'Gam'},{'Beta'},{'Alpha'},{'Theta'},{'Delta'}])
    disp(['ProcessNeuro.m: Processing ' neuralFieldName ' ' neurType]); disp(' ')
    neuroFs = 30;
    [z1,p1,k1] = butter(3,fpass/(analogFs/2));
    [sos1,g1] = zp2sos(z1,p1,k1);
    filtNeuro = filtfilt(sos1,g1,trimmedNeuro - mean(trimmedNeuro));
    [z2,p2,k2] = butter(3,10/(analogFs/2),'low');
    [sos2,g2] = zp2sos(z2,p2,k2);
    smoothPower = filtfilt(sos2,g2,filtNeuro.^2);
    procNeuro = max(resample(smoothPower,neuroFs,analogFs),0);
end

end

