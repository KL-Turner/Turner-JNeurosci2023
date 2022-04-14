function [] = CheckNeuralMotionArtifacts_JNeurosci2022(procDataFileIDs,RestingBaselines,baselineType,imagingType,hemoType)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Check each file's LFP for motion artifacts
%________________________________________________________________________________________________________________________

for aa = 1:size(procDataFileIDs,1)
    procDataFileID = procDataFileIDs(aa,:);
    load(procDataFileID);
    if isfield(ProcData.notes,'motionArtifact') == false
        [animalID,fileDate,fileID] = GetFileInfo_JNeurosci2022(procDataFileID);
        strDay = ConvertDate_JNeurosci2022(fileDate);
        specDataFileID = [animalID '_' fileID '_SpecDataA.mat'];
        load(specDataFileID);
        F = round(SpecData.cortical_LH.F,1);
        deltaHighIndex = find(F == 4);
        LH_deltaPower = mean(SpecData.cortical_LH.normS(1:deltaHighIndex,:),1);
        RH_deltaPower = mean(SpecData.cortical_RH.normS(1:deltaHighIndex,:),1);
        LH_deltaZ = zscore(LH_deltaPower);
        RH_deltaZ = zscore(RH_deltaPower);
        LH_motionZ = find(LH_deltaZ > 5);
        RH_motionZ = find(RH_deltaZ > 5);
        if isempty(LH_motionZ) == false || isempty(RH_motionZ) == false
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
            OptoLED = ProcData.data.stimulations.OptoLED;
            % CBV data
            if strcmp(imagingType,'bilateral') == true
                if strcmp(hemoType,'reflectance') == true
                    LH_CBV = ProcData.data.CBV.adjLH;
                    normLH_CBV = (LH_CBV - RestingBaselines.(baselineType).CBV.adjLH.(strDay))./(RestingBaselines.(baselineType).CBV.adjLH.(strDay));
                    filtLH_CBV = (filtfilt(sos2,g2,normLH_CBV))*100;
                    RH_CBV = ProcData.data.CBV.adjRH;
                    normRH_CBV = (RH_CBV - RestingBaselines.(baselineType).CBV.adjRH.(strDay))./(RestingBaselines.(baselineType).CBV.adjRH.(strDay));
                    filtRH_CBV = (filtfilt(sos2,g2,normRH_CBV))*100;
                elseif strcmp(hemoType,'HbT') == true
                    LH_HbT = ProcData.data.CBV_HbT.adjLH;
                    filtLH_HbT = filtfilt(sos2,g2,LH_HbT);
                    RH_HbT = ProcData.data.CBV_HbT.adjRH;
                    filtRH_HbT = filtfilt(sos2,g2,RH_HbT);
                end
            elseif strcmp(imagingType,'single') == true
                if strcmp(hemoType,'reflectance') == true
                    barrels_CBV = ProcData.data.CBV.adjBarrels;
                    normBarrels_CBV = (barrels_CBV - RestingBaselines.(baselineType).CBV.adjBarrels.(strDay))./(RestingBaselines.(baselineType).CBV.adjBarrels.(strDay));
                    filtBarrels_CBV = (filtfilt(sos2,g2,normBarrels_CBV))*100;
                elseif strcmp(hemoType,'HbT') == true
                    barrels_HbT = ProcData.data.CBV_HbT.adjBarrels;
                    filtBarrels_HbT = filtfilt(sos2,g2,barrels_HbT);
                end
            end
            % cortical and hippocampal spectrograms
            cortical_LHnormS = SpecData.cortical_LH.normS.*100;
            cortical_RHnormS = SpecData.cortical_RH.normS.*100;
            hippocampusNormS = SpecData.hippocampus.normS.*100;
            T = SpecData.cortical_LH.T;
            F = SpecData.cortical_LH.F;
            % Yvals for behavior Indices
            if strcmp(imagingType,'bilateral') == true
                if strcmp(hemoType,'reflectance') == true
                    if max(filtLH_CBV) >= max(filtRH_CBV)
                        whisking_Yvals = 1.10*max(filtLH_CBV)*ones(size(binWhiskers));
                        force_Yvals = 1.20*max(filtLH_CBV)*ones(size(binForce));
                        LPad_Yvals = 1.30*max(filtLH_CBV)*ones(size(LPadSol));
                        RPad_Yvals = 1.30*max(filtLH_CBV)*ones(size(RPadSol));
                        Aud_Yvals = 1.30*max(filtLH_CBV)*ones(size(AudSol));
                        Opto_Yvals = 1.30*max(filtLH_CBV)*ones(size(OptoLED));
                    else
                        whisking_Yvals = 1.10*max(filtRH_CBV)*ones(size(binWhiskers));
                        force_Yvals = 1.20*max(filtRH_CBV)*ones(size(binForce));
                        LPad_Yvals = 1.30*max(filtRH_CBV)*ones(size(LPadSol));
                        RPad_Yvals = 1.30*max(filtRH_CBV)*ones(size(RPadSol));
                        Aud_Yvals = 1.30*max(filtRH_CBV)*ones(size(AudSol));
                        Opto_Yvals = 1.30*max(filtRH_CBV)*ones(size(OptoLED));
                    end
                elseif strcmp(hemoType,'HbT') == true
                    if max(filtLH_HbT) >= max(filtRH_HbT)
                        whisking_Yvals = 1.10*max(filtLH_HbT)*ones(size(binWhiskers));
                        force_Yvals = 1.20*max(filtLH_HbT)*ones(size(binForce));
                        LPad_Yvals = 1.30*max(filtLH_HbT)*ones(size(LPadSol));
                        RPad_Yvals = 1.30*max(filtLH_HbT)*ones(size(RPadSol));
                        Aud_Yvals = 1.30*max(filtLH_HbT)*ones(size(AudSol));
                        Opto_Yvals = 1.30*max(filtLH_HbT)*ones(size(OptoLED));
                    else
                        whisking_Yvals = 1.10*max(filtRH_HbT)*ones(size(binWhiskers));
                        force_Yvals = 1.20*max(filtRH_HbT)*ones(size(binForce));
                        LPad_Yvals = 1.30*max(filtRH_HbT)*ones(size(LPadSol));
                        RPad_Yvals = 1.30*max(filtRH_HbT)*ones(size(RPadSol));
                        Aud_Yvals = 1.30*max(filtRH_HbT)*ones(size(AudSol));
                        Opto_Yvals = 1.30*max(filtRH_HbT)*ones(size(OptoLED));
                    end
                end
            elseif strcmp(imagingType,'single') == true
                if strcmp(hemoType,'reflectance') == true
                    whisking_Yvals = 1.10*max(filtBarrels_CBV)*ones(size(binWhiskers));
                    force_Yvals = 1.20*max(filtBarrels_CBV)*ones(size(binForce));
                    LPad_Yvals = 1.30*max(filtBarrels_CBV)*ones(size(LPadSol));
                    RPad_Yvals = 1.30*max(filtBarrels_CBV)*ones(size(RPadSol));
                    Aud_Yvals = 1.30*max(filtBarrels_CBV)*ones(size(AudSol));
                    Opto_Yvals = 1.30*max(filtBarrels_CBV)*ones(size(OptoLED));
                elseif strcmp(hemoType,'HbT') == true
                    whisking_Yvals = 1.10*max(filtBarrels_HbT)*ones(size(binWhiskers));
                    force_Yvals = 1.20*max(filtBarrels_HbT)*ones(size(binForce));
                    LPad_Yvals = 1.30*max(filtBarrels_HbT)*ones(size(LPadSol));
                    RPad_Yvals = 1.30*max(filtBarrels_HbT)*ones(size(RPadSol));
                    Aud_Yvals = 1.30*max(filtBarrels_HbT)*ones(size(AudSol));
                    Opto_Yvals = 1.30*max(filtBarrels_HbT)*ones(size(OptoLED));
                end
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
            % Figure
            figHandle = figure;
            % force sensor and EMG
            ax1 = subplot(6,1,1);
            fileID2 = strrep(fileID,'_',' ');
            p1 = plot((1:length(filtForceSensor))/ProcData.notes.dsFs,filtForceSensor,'color',colors('sapphire'),'LineWidth',1);
            title([animalID ' IOS behavioral characterization and CBV dynamics for ' fileID2])
            ylabel('Force Sensor (Volts)')
            xlim([0,ProcData.notes.trialDuration_sec])
            yyaxis right
            p2 = plot((1:length(EMG))/ProcData.notes.dsFs,EMG,'color',colors('deep carrot orange'),'LineWidth',1);
            ylabel('EMG (Volts^2)')
            xlim([0,ProcData.notes.trialDuration_sec])
            legend([p1,p2],'force sensor','EMG')
            set(gca,'TickLength',[0,0])
            set(gca,'Xticklabel',[])
            set(gca,'box','off')
            axis tight
            % whisker angle and heart rate
            ax2 = subplot(6,1,2);
            p3 = plot((1:length(filteredWhiskerAngle))/ProcData.notes.dsFs,-filteredWhiskerAngle,'color',colors('blue-green'),'LineWidth',1);
            ylabel('Angle (deg)')
            xlim([0,ProcData.notes.trialDuration_sec])
            ylim([-20,60])
            yyaxis right
            p4 = plot((1:length(heartRate)),heartRate,'color',colors('dark sea green'),'LineWidth',1);
            ylabel('Heart Rate (Hz)')
            ylim([6,15])
            legend([p3,p4],'whisker angle','heart rate')
            set(gca,'TickLength',[0,0])
            set(gca,'Xticklabel',[])
            set(gca,'box','off')
            axis tight
            % CBV and behavioral indeces
            ax3 = subplot(6,1,3);
            scatter((1:length(binForce))/ProcData.notes.dsFs,forceInds,'.','MarkerEdgeColor',colors('sapphire'));
            hold on
            scatter((1:length(binWhiskers))/ProcData.notes.dsFs,whiskInds,'.','MarkerEdgeColor',colors('blue-green'));
            scatter(LPadSol,LPad_Yvals,'v','MarkerEdgeColor','k','MarkerFaceColor','c');
            scatter(RPadSol,RPad_Yvals,'v','MarkerEdgeColor','k','MarkerFaceColor','m');
            scatter(AudSol,Aud_Yvals,'v','MarkerEdgeColor','k','MarkerFaceColor','g');
            scatter(OptoLED,Opto_Yvals,'v','MarkerEdgeColor','k','MarkerFaceColor','b');
            if strcmp(imagingType,'bilateral') == true
                if strcmp(hemoType,'reflectance') == true
                    plot((1:length(filtLH_CBV))/ProcData.notes.CBVCamSamplingRate,filtLH_CBV,'color',colors('dark candy apple red'),'LineWidth',1);
                    plot((1:length(filtRH_CBV))/ProcData.notes.CBVCamSamplingRate,filtRH_CBV,'color',colors('rich black'),'LineWidth',1);
                    ylabel('\DeltaR/R (%)')
                elseif strcmp(hemoType,'HbT') == true
                    plot((1:length(filtLH_HbT))/ProcData.notes.CBVCamSamplingRate,filtLH_HbT,'color',colors('dark candy apple red'),'LineWidth',1);
                    plot((1:length(filtRH_HbT))/ProcData.notes.CBVCamSamplingRate,filtRH_HbT,'color',colors('rich black'),'LineWidth',1);
                    ylabel('\DeltaHbT')
                end
            elseif strcmp(imagingType,'single') == true
                if strcmp(hemoType,'reflectance') == true
                    plot((1:length(filtBarrels_CBV))/ProcData.notes.CBVCamSamplingRate,filtBarrels_CBV,'color',colors('dark candy apple red'),'LineWidth',1);
                    ylabel('\DeltaR/R (%)')
                elseif strcmp(hemoType,'HbT') == true
                    plot((1:length(filtBarrels_HbT))/ProcData.notes.CBVCamSamplingRate,filtBarrels_HbT,'color',colors('dark candy apple red'),'LineWidth',1);
                    ylabel('\DeltaHbT')
                end
            end
            xlim([0,ProcData.notes.trialDuration_sec])
            set(gca,'TickLength',[0,0])
            set(gca,'Xticklabel',[])
            set(gca,'box','off')
            axis tight
            % left cortical electrode spectrogram
            ax4 = subplot(6,1,4);
            Semilog_ImageSC(T,F,cortical_LHnormS,'y')
            hold on
            scatter(LH_motionZ./5,ones(length(LH_motionZ),1).*105,'r')
            axis xy
            c4 = colorbar;
            ylabel(c4,'\DeltaP/P (%)')
            caxis([-100,100])
            ylabel('Frequency (Hz)')
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
            hold on
            scatter(RH_motionZ./5,ones(length(RH_motionZ),1).*105,'r')
            axis xy
            c5 = colorbar;
            ylabel(c5,'\DeltaP/P (%)')
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
            % hippocampal electrode spectrogram
            ax6 = subplot(6,1,6);
            Semilog_ImageSC(T,F,hippocampusNormS,'y')
            c6 = colorbar;
            ylabel(c6,'\DeltaP/P (%)')
            caxis([-100,100])
            xlabel('Time (sec)')
            ylabel('Frequency (Hz)')
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
            % save the file to directory.
            motionArtifact = input(['Does ' procDataFileID ' show clear motion artifacts? (y/n): '],'s'); disp(' ')
            if strcmp(motionArtifact,'y') == true
                [pathstr,~,~] = fileparts(cd);
                dirpath = [pathstr '/Figures/Motion Artifacts/'];
                if ~exist(dirpath,'dir')
                    mkdir(dirpath);
                end
                savefig(figHandle,[dirpath animalID '_' fileID '_' hemoType '_SingleTrialFig']);
                ProcData.notes.motionArtifact = true;
                save(procDataFileID,'ProcData')
                close(figHandle)
            else
                ProcData.notes.motionArtifact = false;
                save(procDataFileID,'ProcData')
                close(figHandle)
            end
        else
            ProcData.notes.motionArtifact = false;
            save(procDataFileID,'ProcData')
        end
    end
end

end

