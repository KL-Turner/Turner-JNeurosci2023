function [figHandle,ax1,ax2,ax3,ax4,ax5,ax6] = GenerateSingleFigures_GCaMP_Turner2022(procDataFileID,RestingBaselines,saveFigs,hemoType,corticalRegion)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpose: Create a summary figure for a single n minute IOS trial
%________________________________________________________________________________________________________________________

% load file and gather information
load(procDataFileID)
[animalID,fileDate,fileID] = GetFileInfo_Turner2022(procDataFileID);
strDay = ConvertDate_Turner2022(fileDate);
% setup butterworth filter coefficients for a 1 Hz and 10 Hz lowpass based on the sampling rate
[z1,p1,k1] = butter(4,10/(ProcData.notes.dsFs/2),'low');
[sos1,g1] = zp2sos(z1,p1,k1);
[z2,p2,k2] = butter(4,1/(ProcData.notes.CBVCamSamplingRate/2),'low');
[sos2,g2] = zp2sos(z2,p2,k2);
% whisker angle
filteredWhiskerAngle = filtfilt(sos1,g1,ProcData.data.whiskerAngle);
binWhiskers = ProcData.data.binWhiskerAngle;
% force sensor
filtForceSensor = filtfilt(sos1,g1,ProcData.data.forceSensor);
binForce = ProcData.data.binForceSensor;
% emg
EMG = ProcData.data.EMG.emg;
% stimulations
LPadSol = ProcData.data.stimulations.LPadSol;
RPadSol = ProcData.data.stimulations.RPadSol;
AudSol = ProcData.data.stimulations.AudSol;
if strcmpi(corticalRegion,'somatosensory') == true
    % CBV data
    LH_HbT = ProcData.data.CBV_HbT.LH;
    filtLH_HbT = filtfilt(sos2,g2,LH_HbT);
    RH_HbT = ProcData.data.CBV_HbT.RH;
    filtRH_HbT = filtfilt(sos2,g2,RH_HbT);
    % GCaMP
    LH_GCaMP7s = ProcData.data.GCaMP7s.corLH;
    normLH_GCaMP7s = (LH_GCaMP7s - 1)*100;
    filtLH_GCaMP7s = filtfilt(sos2,g2,normLH_GCaMP7s);
    RH_GCaMP7s = ProcData.data.GCaMP7s.corRH;
    normRH_GCaMP7s = (RH_GCaMP7s - 1)*100;
    filtRH_GCaMP7s = filtfilt(sos2,g2,normRH_GCaMP7s);
    % Deoxy signal
    LH_deoxy = ProcData.data.Deoxy.LH;
    normLH_deoxy = ((LH_deoxy - RestingBaselines.manualSelection.Deoxy.LH.(strDay).mean)./RestingBaselines.manualSelection.Deoxy.LH.(strDay).mean)*100;
    filtLH_deoxy = filtfilt(sos2,g2,normLH_deoxy);
    RH_deoxy = ProcData.data.Deoxy.RH;
    normRH_deoxy = ((RH_deoxy - RestingBaselines.manualSelection.Deoxy.RH.(strDay).mean)./RestingBaselines.manualSelection.Deoxy.RH.(strDay).mean)*100;
    filtRH_deoxy = filtfilt(sos2,g2,normRH_deoxy);
elseif strcmpi(corticalRegion,'frontal') == true
    % CBV data
    LH_HbT = ProcData.data.CBV_HbT.frontalLH;
    filtLH_HbT = filtfilt(sos2,g2,LH_HbT);
    RH_HbT = ProcData.data.CBV_HbT.frontalRH;
    filtRH_HbT = filtfilt(sos2,g2,RH_HbT);
    % GCaMP
    LH_GCaMP7s = ProcData.data.GCaMP7s.corFrontalLH;
    normLH_GCaMP7s = (LH_GCaMP7s - 1)*100;
    filtLH_GCaMP7s = filtfilt(sos2,g2,normLH_GCaMP7s);
    RH_GCaMP7s = ProcData.data.GCaMP7s.corFrontalRH;
    normRH_GCaMP7s = (RH_GCaMP7s - 1)*100;
    filtRH_GCaMP7s = filtfilt(sos2,g2,normRH_GCaMP7s);
    % Deoxy signal
    LH_deoxy = ProcData.data.Deoxy.frontalLH;
    normLH_deoxy = ((LH_deoxy - RestingBaselines.manualSelection.Deoxy.frontalLH.(strDay).mean)./RestingBaselines.manualSelection.Deoxy.frontalLH.(strDay).mean)*100;
    filtLH_deoxy = filtfilt(sos2,g2,normLH_deoxy);
    RH_deoxy = ProcData.data.Deoxy.frontalRH;
    normRH_deoxy = ((RH_deoxy - RestingBaselines.manualSelection.Deoxy.frontalRH.(strDay).mean)./RestingBaselines.manualSelection.Deoxy.frontalRH.(strDay).mean)*100;
    filtRH_deoxy = filtfilt(sos2,g2,normRH_deoxy);
end
% cortical and hippocampal spectrograms
specDataFile = [animalID '_' fileID '_SpecDataA.mat'];
load(specDataFile,'-mat');
cortical_RHnormS = SpecData.cortical_RH.normS.*100;
hippocampusNormS = SpecData.hippocampus.normS.*100;
T = SpecData.cortical_LH.T;
F = SpecData.cortical_LH.F;
% Yvals for behavior Indices
if max(filtLH_HbT) >= max(filtRH_HbT)
    whisking_Yvals = 1.10*max(filtLH_HbT)*ones(size(binWhiskers));
    force_Yvals = 1.20*max(filtLH_HbT)*ones(size(binForce));
    LPad_Yvals = 1.50*max(filtLH_HbT)*ones(size(LPadSol));
    RPad_Yvals = 1.50*max(filtLH_HbT)*ones(size(RPadSol));
    Aud_Yvals = 1.50*max(filtLH_HbT)*ones(size(AudSol));
else
    whisking_Yvals = 1.10*max(filtRH_HbT)*ones(size(binWhiskers));
    force_Yvals = 1.20*max(filtRH_HbT)*ones(size(binForce));
    LPad_Yvals = 1.50*max(filtRH_HbT)*ones(size(LPadSol));
    RPad_Yvals = 1.50*max(filtRH_HbT)*ones(size(RPadSol));
    Aud_Yvals = 1.50*max(filtRH_HbT)*ones(size(AudSol));
end
forceInds = binForce.*force_Yvals;
whiskInds = binWhiskers.*whisking_Yvals;
% set force indeces
for x = 1:length(forceInds)
    if forceInds(1,x) == 0
        forceInds(1,x) = NaN;
    end
end
% set whisk indeces
for x = 1:length(whiskInds)
    if whiskInds(1,x) == 0
        whiskInds(1,x) = NaN;
    end
end
% figure
figHandle = figure;
% force sensor and EMG
ax1 = subplot(7,1,1);
fileID2 = strrep(fileID,'_',' ');
p1 = plot((1:length(filtForceSensor))/ProcData.notes.dsFs,filtForceSensor,'color',colors('electric purple'),'LineWidth',1);
title([animalID ' IOS behavioral characterization and CBV dynamics for ' fileID2 ' ' corticalRegion])
ylabel('Force Sensor (Volts)')
xlim([0,ProcData.notes.trialDuration_sec])
yyaxis right
p2 = plot((1:length(EMG))/ProcData.notes.dsFs,EMG,'color',colors('dark pink'),'LineWidth',1);
ylabel('EMG (Volts^2)')
xlim([0,ProcData.notes.trialDuration_sec])
legend([p1,p2],'force sensor','EMG')
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
axis tight
% Whisker angle and heart rate
ax2 = subplot(7,1,2);
plot((1:length(filteredWhiskerAngle))/ProcData.notes.dsFs,-filteredWhiskerAngle,'color',colors('smoky black'),'LineWidth',1);
ylabel('Angle (deg)')
xlim([0,ProcData.notes.trialDuration_sec])
ylim([-20,60])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
axis tight
% CBV and behavioral indeces
ax3 = subplot(7,1,3);
s1 = scatter((1:length(binForce))/ProcData.notes.dsFs,forceInds,'.','MarkerEdgeColor',colors('electric purple'));
hold on
s2 = scatter((1:length(binWhiskers))/ProcData.notes.dsFs,whiskInds,'.','MarkerEdgeColor',colors('smoky black'));
s3 = scatter(LPadSol,LPad_Yvals,'v','MarkerEdgeColor','k','MarkerFaceColor','c');
s4 = scatter(RPadSol,RPad_Yvals,'v','MarkerEdgeColor','k','MarkerFaceColor','m');
s5 = scatter(AudSol,Aud_Yvals,'v','MarkerEdgeColor','k','MarkerFaceColor','g');
p5 = plot((1:length(filtLH_HbT))/ProcData.notes.CBVCamSamplingRate,filtLH_HbT,'color',colors('dark candy apple red'),'LineWidth',1);
p6 = plot((1:length(filtRH_HbT))/ProcData.notes.CBVCamSamplingRate,filtRH_HbT,'color',colors('sapphire'),'LineWidth',1);
ylabel('\DeltaHbT')
legend([p5,p6,s1,s2,s3,s4,s5],'LH HbT','RH HbT','movement','whisking',',LPad sol','RPad sol','Aud sol')
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
axis tight
% GCaMP and behavioral indeces
ax4 = subplot(7,1,4);
p7 = plot((1:length(filtLH_GCaMP7s))/ProcData.notes.CBVCamSamplingRate,filtLH_GCaMP7s,'color',colors('violet'),'LineWidth',1);
hold on
p8 = plot((1:length(filtRH_GCaMP7s))/ProcData.notes.CBVCamSamplingRate,filtRH_GCaMP7s,'color',colors('vegas gold'),'LineWidth',1);
ylabel('GCaMP7s \DeltaF/F (%)')
legend([p7,p8],'LH GCaMP7s','RH GCaMP7s')
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
axis tight
% GCaMP and behavioral indeces
ax5 = subplot(7,1,5);
p9 = plot((1:length(filtLH_deoxy))/ProcData.notes.CBVCamSamplingRate,filtLH_deoxy,'color',colors('north texas green'),'LineWidth',1);
hold on
p10 = plot((1:length(filtRH_deoxy))/ProcData.notes.CBVCamSamplingRate,filtRH_deoxy,'color',colors('deep carrot orange'),'LineWidth',1);
ylabel('Deoxy \DeltaF/F (%)')
legend([p9,p10],'LH deoxy','RH deoxy')
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
axis tight
% Right cortical electrode spectrogram
ax6 = subplot(7,1,6);
Semilog_ImageSC(T,F,cortical_RHnormS,'y')
axis xy
c6 = colorbar;
ylabel(c6,'\DeltaP/P (%)')
caxis([-100,100])
ylabel('Frequency (Hz)')
set(gca,'Yticklabel','10^1')
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
yyaxis right
ylabel('Right cortical LFP')
set(gca,'Yticklabel',[])
% Hippocampal electrode spectrogram
ax7 = subplot(7,1,7);
Semilog_ImageSC(T,F,hippocampusNormS,'y')
c7 = colorbar;
ylabel(c7,'\DeltaP/P (%)')
caxis([-100,100])
xlabel('Time (sec)')
ylabel('Frequency (Hz)')
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'box','off')
yyaxis right
ylabel('Hippocampal LFP')
set(gca,'Yticklabel',[])
% Axes properties
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6],'x')
ax1Pos = get(ax1,'position');
ax6Pos = get(ax6,'position');
ax7Pos = get(ax7,'position');
ax6Pos(3:4) = ax1Pos(3:4);
ax7Pos(3:4) = ax1Pos(3:4);
set(ax6,'position',ax6Pos);
set(ax7,'position',ax7Pos);
% save the file to directory.
if strcmp(saveFigs,'y') == true
    [pathstr,~,~] = fileparts(cd);
    dirpath = [pathstr '/Figures/Single Trial Figures/'];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(figHandle,[dirpath animalID '_' fileID '_' hemoType '_SingleTrialFig']);
end

end
