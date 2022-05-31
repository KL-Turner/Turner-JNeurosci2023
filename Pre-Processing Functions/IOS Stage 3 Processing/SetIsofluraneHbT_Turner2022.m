function [] = SetIsofluraneHbT_Turner2022()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Converts reflectance values to changes in total hemoglobin using absorbance curves of hardware
%________________________________________________________________________________________________________________________

close all
ledType = 'M565L3';
bandfilterType = 'FB570-10';
cutfilterType = 'EO65160';
conv2um = 1e6;
[~,~,weightedcoeffHbT] = getHbcoeffs_Turner2022(ledType,bandfilterType,cutfilterType);
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileID = char(procDataFiles);
load(procDataFileID)
[animalID,~,fileID] = GetFileInfo_Turner2022(procDataFileID);
% setup butterworth filter coefficients for a 1 Hz and 10 Hz lowpass based on the sampling rate
[z1,p1,k1] = butter(4,10/(ProcData.notes.dsFs/2),'low');
[sos1,g1] = zp2sos(z1,p1,k1);
[z2,p2,k2] = butter(4,1/(ProcData.notes.dsFs/2),'low');
[sos2,g2] = zp2sos(z2,p2,k2);
% whisker angle
filteredWhiskerAngle = filtfilt(sos1,g1,ProcData.data.whiskerAngle);
binWhiskers = ProcData.data.binWhiskerAngle;
% force sensor
filtForceSensor = filtfilt(sos1,g1,ProcData.data.forceSensor);
binForce = ProcData.data.binForceSensor;
% EMG
EMG = ProcData.data.EMG.emg;
% heart rate
heartRate = ProcData.data.heartRate;
% stimulations
LPadSol = ProcData.data.stimulations.LPadSol;
RPadSol = ProcData.data.stimulations.RPadSol;
AudSol = ProcData.data.stimulations.AudSol;
% CBV data
LH_CBV = ProcData.data.CBV.adjLH;
normLH_CBV = (LH_CBV - mean(LH_CBV))./mean(LH_CBV);
filtLH_CBV = (filtfilt(sos2,g2,normLH_CBV))*100;
RH_CBV = ProcData.data.CBV.adjRH;
normRH_CBV = (RH_CBV - mean(RH_CBV))./mean(RH_CBV);
filtRH_CBV = (filtfilt(sos2,g2,normRH_CBV))*100;
% cortical and hippocampal spectrograms
specDataFile = [animalID '_' fileID '_SpecDataA.mat'];
load(specDataFile,'-mat');
cortical_LHnormS = SpecData.cortical_LH.normS.*100;
cortical_RHnormS = SpecData.cortical_RH.normS.*100;
hippocampusNormS = SpecData.hippocampus.normS.*100;
T = SpecData.cortical_LH.T;
F = SpecData.cortical_LH.F;
% Yvals for behavior Indices
if max(filtLH_CBV) >= max(filtRH_CBV)
    whisking_Yvals = 1.10*max(filtLH_CBV)*ones(size(binWhiskers));
    force_Yvals = 1.20*max(filtLH_CBV)*ones(size(binForce));
    LPad_Yvals = 1.30*max(filtLH_CBV)*ones(size(LPadSol));
    RPad_Yvals = 1.30*max(filtLH_CBV)*ones(size(RPadSol));
    Aud_Yvals = 1.30*max(filtLH_CBV)*ones(size(AudSol));
else
    whisking_Yvals = 1.10*max(filtRH_CBV)*ones(size(binWhiskers));
    force_Yvals = 1.20*max(filtRH_CBV)*ones(size(binForce));
    LPad_Yvals = 1.30*max(filtRH_CBV)*ones(size(LPadSol));
    RPad_Yvals = 1.30*max(filtRH_CBV)*ones(size(RPadSol));
    Aud_Yvals = 1.30*max(filtRH_CBV)*ones(size(AudSol));
end
whiskInds = binWhiskers.*whisking_Yvals;
forceInds = binForce.*force_Yvals;
for x = 1:length(whiskInds)
    % set whisk indeces
    if whiskInds(1,x) == 0
        whiskInds(1,x) = NaN;
    end
    % set force indeces
    if forceInds(1,x) == 0
        forceInds(1,x) = NaN;
    end
end
%% Figure
figHandle = figure;
% force sensor and EMG
ax1 = subplot(6,1,1);
fileID2 = strrep(fileID,'_',' ');
plot((1:length(filtForceSensor))/ProcData.notes.dsFs,filtForceSensor,'color',colors('sapphire'),'LineWidth',1)
title([animalID ' IOS behavioral characterization and CBV dynamics for ' fileID2])
ylabel('Force Sensor (Volts)')
xlim([0,ProcData.notes.trialDuration_sec])
yyaxis right
plot((1:length(EMG))/ProcData.notes.dsFs,EMG,'color',colors('deep carrot orange'),'LineWidth',1)
ylabel('EMG (Volts^2)')
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
axis tight
% whisker angle and heart rate
ax2 = subplot(6,1,2);
plot((1:length(filteredWhiskerAngle))/ProcData.notes.dsFs,-filteredWhiskerAngle,'color',colors('blue-green'),'LineWidth',1)
ylabel('Angle (deg)')
xlim([0,ProcData.notes.trialDuration_sec])
ylim([-20,60])
yyaxis right
plot((1:length(heartRate)),heartRate,'color',colors('dark sea green'),'LineWidth',1)
ylabel('Heart Rate (Hz)')
ylim([6,15])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
axis tight
% CBV and behavioral indeces
ax3 = subplot(6,1,3);
plot((1:length(filtLH_CBV))/ProcData.notes.CBVCamSamplingRate,filtLH_CBV,'color',colors('dark candy apple red'),'LineWidth',1)
hold on
plot((1:length(filtRH_CBV))/ProcData.notes.CBVCamSamplingRate,filtRH_CBV,'color',colors('rich black'),'LineWidth',1)
ylabel('\DeltaR/R (%)')
scatter((1:length(binForce))/ProcData.notes.dsFs,forceInds,'.','MarkerEdgeColor',colors('sapphire'));
scatter((1:length(binWhiskers))/ProcData.notes.dsFs,whiskInds,'.','MarkerEdgeColor',colors('blue-green'));
scatter(LPadSol,LPad_Yvals,'v','MarkerEdgeColor','k','MarkerFaceColor','c');
scatter(RPadSol,RPad_Yvals,'v','MarkerEdgeColor','k','MarkerFaceColor','m');
scatter(AudSol,Aud_Yvals,'v','MarkerEdgeColor','k','MarkerFaceColor','g');
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
axis tight
% left cortical electrode spectrogram
ax4 = subplot(6,1,4);
Semilog_ImageSC(T,F,cortical_LHnormS,'y')
axis xy
c4 = colorbar;
ylabel(c4,'\DeltaP/P (%)')
caxis([-100,100])
ylabel('Freq (Hz)')
set(gca,'Yticklabel','10^1')
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
yyaxis right
ylabel('Left cortical LFP')
set(gca,'Yticklabel',[])
% right cortical electrode spectrogram
ax5 = subplot(6,1,5);
Semilog_ImageSC(T,F,cortical_RHnormS,'y')
axis xy
c5 = colorbar;
ylabel(c5,'\DeltaP/P (%)')
caxis([-100,100])
ylabel('Freq (Hz)')
set(gca,'Yticklabel','10^1')
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
yyaxis right
ylabel('Right cortical LFP')
set(gca,'Yticklabel',[])
% hippocampal electrode spectrogram
ax6 = subplot(6,1,6);
Semilog_ImageSC(T,F,hippocampusNormS,'y')
c6 = colorbar;
ylabel(c6,'\DeltaP/P (%)')
caxis([-100,100])
xlabel('Time (s)')
ylabel('Freq (Hz)')
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'box','off')
yyaxis right
ylabel('Hippocampal LFP')
set(gca,'Yticklabel',[])
% axes properties
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6],'x')
ax1Pos = get(ax1,'position');
ax4Pos = get(ax4,'position');
ax5Pos = get(ax5,'position');
ax6Pos = get(ax6,'position');
ax4Pos(3:4) = ax1Pos(3:4);
ax5Pos(3:4) = ax1Pos(3:4);
ax6Pos(3:4) = ax1Pos(3:4);
set(ax4,'position',ax4Pos);
set(ax5,'position',ax5Pos);
set(ax6,'position',ax6Pos);
%% set awake period
startTime = input('Enter awake start time (s): '); disp(' ')
endTime = input('Enter awake end time (s): '); disp(' ')
close(figHandle)
if startTime == 0
    startTime = 1;
end
LH_baseline = mean(LH_CBV(startTime*ProcData.notes.dsFs:endTime*ProcData.notes.dsFs));
RH_baseline = mean(RH_CBV(startTime*ProcData.notes.dsFs:endTime*ProcData.notes.dsFs));
% reflectance
reflNormLH_CBV = (LH_CBV - LH_baseline)./LH_baseline;
ProcData.data.CBV.normAdjLH = reflNormLH_CBV;
reflFiltLH_CBV = (filtfilt(sos2,g2,reflNormLH_CBV))*100;
ProcData.data.CBV_HbT.adjLH = (log(ProcData.data.CBV.adjLH/LH_baseline))*weightedcoeffHbT*conv2um;
reflNormRH_CBV = (RH_CBV - RH_baseline)./RH_baseline;
ProcData.data.CBV.normAdjRH = reflNormRH_CBV;
reflFiltRH_CBV = (filtfilt(sos2,g2,reflNormRH_CBV))*100;
ProcData.data.CBV_HbT.adjRH = (log(ProcData.data.CBV.adjRH/RH_baseline))*weightedcoeffHbT*conv2um;
save(procDataFileID,'ProcData')
%% new reflectance figure
% Yvals for behavior Indices
if max(reflFiltLH_CBV) >= max(reflFiltRH_CBV)
    whisking_Yvals = 1.10*max(reflFiltLH_CBV)*ones(size(binWhiskers));
    force_Yvals = 1.20*max(reflFiltLH_CBV)*ones(size(binForce));
    LPad_Yvals = 1.30*max(reflFiltLH_CBV)*ones(size(LPadSol));
    RPad_Yvals = 1.30*max(reflFiltLH_CBV)*ones(size(RPadSol));
    Aud_Yvals = 1.30*max(reflFiltLH_CBV)*ones(size(AudSol));
else
    whisking_Yvals = 1.10*max(reflFiltRH_CBV)*ones(size(binWhiskers));
    force_Yvals = 1.20*max(reflFiltRH_CBV)*ones(size(binForce));
    LPad_Yvals = 1.30*max(reflFiltRH_CBV)*ones(size(LPadSol));
    RPad_Yvals = 1.30*max(reflFiltRH_CBV)*ones(size(RPadSol));
    Aud_Yvals = 1.30*max(reflFiltRH_CBV)*ones(size(AudSol));
end
whiskInds = binWhiskers.*whisking_Yvals;
forceInds = binForce.*force_Yvals;
for x = 1:length(whiskInds)
    % set whisk indeces
    if whiskInds(1,x) == 0
        whiskInds(1,x) = NaN;
    end
    % set force indeces
    if forceInds(1,x) == 0
        forceInds(1,x) = NaN;
    end
end
%% Figure
figHandle = figure;
% force sensor and EMG
ax1 = subplot(6,1,1);
fileID2 = strrep(fileID,'_',' ');
plot((1:length(filtForceSensor))/ProcData.notes.dsFs,filtForceSensor,'color',colors('sapphire'),'LineWidth',1)
title([animalID ' IOS behavioral characterization and CBV dynamics for ' fileID2])
ylabel('Force Sensor (Volts)')
xlim([0,ProcData.notes.trialDuration_sec])
yyaxis right
plot((1:length(EMG))/ProcData.notes.dsFs,EMG,'color',colors('deep carrot orange'),'LineWidth',1)
ylabel('EMG (Volts^2)')
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
axis tight
% whisker angle and heart rate
ax2 = subplot(6,1,2);
plot((1:length(filteredWhiskerAngle))/ProcData.notes.dsFs,-filteredWhiskerAngle,'color',colors('blue-green'),'LineWidth',1)
ylabel('Angle (deg)')
xlim([0,ProcData.notes.trialDuration_sec])
ylim([-20,60])
yyaxis right
plot((1:length(heartRate)),heartRate,'color',colors('dark sea green'),'LineWidth',1)
ylabel('Heart Rate (Hz)')
ylim([6,15])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
axis tight
% CBV and behavioral indeces
ax3 = subplot(6,1,3);
plot((1:length(reflFiltLH_CBV))/ProcData.notes.CBVCamSamplingRate,reflFiltLH_CBV,'color',colors('dark candy apple red'),'LineWidth',1)
hold on
plot((1:length(reflFiltRH_CBV))/ProcData.notes.CBVCamSamplingRate,reflFiltRH_CBV,'color',colors('rich black'),'LineWidth',1)
ylabel('\DeltaR/R (%)')
scatter((1:length(binForce))/ProcData.notes.dsFs,forceInds,'.','MarkerEdgeColor',colors('sapphire'));
scatter((1:length(binWhiskers))/ProcData.notes.dsFs,whiskInds,'.','MarkerEdgeColor',colors('blue-green'));
scatter(LPadSol,LPad_Yvals,'v','MarkerEdgeColor','k','MarkerFaceColor','c');
scatter(RPadSol,RPad_Yvals,'v','MarkerEdgeColor','k','MarkerFaceColor','m');
scatter(AudSol,Aud_Yvals,'v','MarkerEdgeColor','k','MarkerFaceColor','g');
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
axis tight
% left cortical electrode spectrogram
ax4 = subplot(6,1,4);
Semilog_ImageSC(T,F,cortical_LHnormS,'y')
axis xy
c4 = colorbar;
ylabel(c4,'\DeltaP/P (%)')
caxis([-100,100])
ylabel('Freq (Hz)')
set(gca,'Yticklabel','10^1')
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
yyaxis right
ylabel('Left cortical LFP')
set(gca,'Yticklabel',[])
% right cortical electrode spectrogram
ax5 = subplot(6,1,5);
Semilog_ImageSC(T,F,cortical_RHnormS,'y')
axis xy
c5 = colorbar;
ylabel(c5,'\DeltaP/P (%)')
caxis([-100,100])
ylabel('Freq (Hz)')
set(gca,'Yticklabel','10^1')
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
yyaxis right
ylabel('Right cortical LFP')
set(gca,'Yticklabel',[])
% hippocampal electrode spectrogram
ax6 = subplot(6,1,6);
Semilog_ImageSC(T,F,hippocampusNormS,'y')
c6 = colorbar;
ylabel(c6,'\DeltaP/P (%)')
caxis([-100,100])
xlabel('Time (s)')
ylabel('Freq (Hz)')
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'box','off')
yyaxis right
ylabel('Hippocampal LFP')
set(gca,'Yticklabel',[])
% xes properties
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6],'x')
ax1Pos = get(ax1,'position');
ax4Pos = get(ax4,'position');
ax5Pos = get(ax5,'position');
ax6Pos = get(ax6,'position');
ax4Pos(3:4) = ax1Pos(3:4);
ax5Pos(3:4) = ax1Pos(3:4);
ax6Pos(3:4) = ax1Pos(3:4);
set(ax4,'position',ax4Pos);
set(ax5,'position',ax5Pos);
set(ax6,'position',ax6Pos);
savefig(figHandle,[animalID '_' fileID '_reflectance_SingleTrialFig']);
%% new HbT figure
% Yvals for behavior Indices
if max(ProcData.data.CBV_HbT.adjLH) >= max(ProcData.data.CBV_HbT.adjRH)
    whisking_Yvals = 1.10*max(ProcData.data.CBV_HbT.adjLH)*ones(size(binWhiskers));
    force_Yvals = 1.20*max(ProcData.data.CBV_HbT.adjLH)*ones(size(binForce));
    LPad_Yvals = 1.30*max(ProcData.data.CBV_HbT.adjLH)*ones(size(LPadSol));
    RPad_Yvals = 1.30*max(ProcData.data.CBV_HbT.adjLH)*ones(size(RPadSol));
    Aud_Yvals = 1.30*max(ProcData.data.CBV_HbT.adjLH)*ones(size(AudSol));
else
    whisking_Yvals = 1.10*max(ProcData.data.CBV_HbT.adjRH)*ones(size(binWhiskers));
    force_Yvals = 1.20*max(ProcData.data.CBV_HbT.adjRH)*ones(size(binForce));
    LPad_Yvals = 1.30*max(ProcData.data.CBV_HbT.adjRH)*ones(size(LPadSol));
    RPad_Yvals = 1.30*max(ProcData.data.CBV_HbT.adjRH)*ones(size(RPadSol));
    Aud_Yvals = 1.30*max(ProcData.data.CBV_HbT.adjRH)*ones(size(AudSol));
end
whiskInds = binWhiskers.*whisking_Yvals;
forceInds = binForce.*force_Yvals;
for x = 1:length(whiskInds)
    % set whisk indeces
    if whiskInds(1,x) == 0
        whiskInds(1,x) = NaN;
    end
    % set force indeces
    if forceInds(1,x) == 0
        forceInds(1,x) = NaN;
    end
end
% Figure
figHandle = figure;
% force sensor and EMG
ax1 = subplot(6,1,1);
fileID2 = strrep(fileID,'_',' ');
plot((1:length(filtForceSensor))/ProcData.notes.dsFs,filtForceSensor,'color',colors('sapphire'),'LineWidth',1)
title([animalID ' IOS behavioral characterization and CBV dynamics for ' fileID2])
ylabel('Force Sensor (Volts)')
xlim([0,ProcData.notes.trialDuration_sec])
yyaxis right
plot((1:length(EMG))/ProcData.notes.dsFs,EMG,'color',colors('deep carrot orange'),'LineWidth',1)
ylabel('EMG (Volts^2)')
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
axis tight
% whisker angle and heart rate
ax2 = subplot(6,1,2);
plot((1:length(filteredWhiskerAngle))/ProcData.notes.dsFs,-filteredWhiskerAngle,'color',colors('blue-green'),'LineWidth',1)
ylabel('Angle (deg)')
xlim([0,ProcData.notes.trialDuration_sec])
ylim([-20,60])
yyaxis right
plot((1:length(heartRate)),heartRate,'color',colors('dark sea green'),'LineWidth',1)
ylabel('Heart Rate (Hz)')
ylim([6,15])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
axis tight
% CBV and behavioral indeces
ax3 = subplot(6,1,3);
plot((1:length(ProcData.data.CBV_HbT.adjLH))/ProcData.notes.CBVCamSamplingRate,ProcData.data.CBV_HbT.adjLH,'color',colors('dark candy apple red'),'LineWidth',1)
hold on
plot((1:length(ProcData.data.CBV_HbT.adjRH))/ProcData.notes.CBVCamSamplingRate,ProcData.data.CBV_HbT.adjRH,'color',colors('rich black'),'LineWidth',1)
ylabel('\DeltaHbT (\muM)')
scatter((1:length(binForce))/ProcData.notes.dsFs,forceInds,'.','MarkerEdgeColor',colors('sapphire'));
scatter((1:length(binWhiskers))/ProcData.notes.dsFs,whiskInds,'.','MarkerEdgeColor',colors('blue-green'));
scatter(LPadSol,LPad_Yvals,'v','MarkerEdgeColor','k','MarkerFaceColor','c');
scatter(RPadSol,RPad_Yvals,'v','MarkerEdgeColor','k','MarkerFaceColor','m');
scatter(AudSol,Aud_Yvals,'v','MarkerEdgeColor','k','MarkerFaceColor','g');
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
axis tight
% left cortical electrode spectrogram
ax4 = subplot(6,1,4);
Semilog_ImageSC(T,F,cortical_LHnormS,'y')
axis xy
c4 = colorbar;
ylabel(c4,'\DeltaP/P (%)')
caxis([-100,100])
ylabel('Freq (Hz)')
set(gca,'Yticklabel','10^1')
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
yyaxis right
ylabel('Left cortical LFP')
set(gca,'Yticklabel',[])
% right cortical electrode spectrogram
ax5 = subplot(6,1,5);
Semilog_ImageSC(T,F,cortical_RHnormS,'y')
axis xy
c5 = colorbar;
ylabel(c5,'\DeltaP/P (%)')
caxis([-100,100])
ylabel('Freq (Hz)')
set(gca,'Yticklabel','10^1')
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
yyaxis right
ylabel('Right cortical LFP')
set(gca,'Yticklabel',[])
% hippocampal electrode spectrogram
ax6 = subplot(6,1,6);
Semilog_ImageSC(T,F,hippocampusNormS,'y')
c6 = colorbar;
ylabel(c6,'\DeltaP/P (%)')
caxis([-100,100])
xlabel('Time (s)')
ylabel('Freq (Hz)')
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'box','off')
yyaxis right
ylabel('Hippocampal LFP')
set(gca,'Yticklabel',[])
% axes properties
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6],'x')
ax1Pos = get(ax1,'position');
ax4Pos = get(ax4,'position');
ax5Pos = get(ax5,'position');
ax6Pos = get(ax6,'position');
ax4Pos(3:4) = ax1Pos(3:4);
ax5Pos(3:4) = ax1Pos(3:4);
ax6Pos(3:4) = ax1Pos(3:4);
set(ax4,'position',ax4Pos);
set(ax5,'position',ax5Pos);
set(ax6,'position',ax6Pos);
savefig(figHandle,[animalID '_' fileID '_HbT_SingleTrialFig']);

end