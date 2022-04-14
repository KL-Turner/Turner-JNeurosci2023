function [] = CheckPupilDiameter_JNeurosci2022(procDataFileID)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Manually check pupil diameter
%________________________________________________________________________________________________________________________

load(procDataFileID)
if strcmpi(ProcData.data.Pupil.frameCheck,'y') == true %#ok<*NODEF>
    if isfield(ProcData.data.Pupil,'newDiameterCheck') == false
        if strcmp(ProcData.data.Pupil.diameterCheck,'n') == true
            % request user input for this file
            check = false;
            samplingRate = 30;
            while check == false
                diameterCheck = figure('units','normalized','outerposition',[0 .25 1 0.75]);
                sgtitle(strrep(procDataFileID,'_',' '))
                subplot(3,6,[1,7,13])
                imagesc(ProcData.data.Pupil.firstFrame)
                title(['Previous file choice: ' ProcData.data.Pupil.diameterCheck]);
                colormap gray
                axis image
                axis off
                subplot(3,6,2:6)
                try
                    p1 = plot((1:length(ProcData.data.Pupil.originalPupilArea))/samplingRate,ProcData.data.Pupil.originalPupilArea,'k','LineWidth',1);
                    hold on
                    s1 = scatter(ProcData.data.Pupil.originalBlinkInds/samplingRate,ones(length(ProcData.data.Pupil.originalBlinkInds),1)*max(ProcData.data.Pupil.originalPupilArea),'MarkerEdgeColor','b');
                    title('Original pupil area')
                    xlabel('Time (sec)');
                    ylabel('Area (pixels)');
                    legend([p1,s1],'pupil area','blinks')
                    set(gca,'box','off')
                    axis tight
                catch
                    % don't plot
                end
                subplot(3,6,8:12)
                plot((1:length(ProcData.data.Pupil.pupilArea))/samplingRate,ProcData.data.Pupil.pupilArea,'k','LineWidth',1);
                hold on
                scatter(ProcData.data.Pupil.blinkInds/samplingRate,ones(length(ProcData.data.Pupil.blinkInds),1)*max(ProcData.data.Pupil.pupilArea),'MarkerEdgeColor','b');
                title('Updated pupil area');
                xlabel('Time (sec)');
                ylabel('Area (pixels)');
                set(gca,'box','off')
                axis tight
                subplot(3,6,14:18)
                [z,p,k] = butter(4,1/(samplingRate/2),'low');
                [sos,g] = zp2sos(z,p,k);
                try
                    plot((1:length(ProcData.data.Pupil.pupilArea))/samplingRate,filtfilt(sos,g,ProcData.data.Pupil.pupilArea),'k','LineWidth',1);
                catch
                    plot((1:length(ProcData.data.Pupil.pupilArea))/samplingRate,ProcData.data.Pupil.pupilArea,'k','LineWidth',1);
                end
                hold on
                scatter(ProcData.data.Pupil.blinkInds/samplingRate,ones(length(ProcData.data.Pupil.blinkInds),1)*max(ProcData.data.Pupil.pupilArea),'MarkerEdgeColor','b');
                title('Filt pupil area');
                xlabel('Time (sec)');
                ylabel('Area (pixels)');
                set(gca,'box','off')
                axis tight
                keepDiameter = input('Is this an accurate pupil tracking diameter? (y/n): ','s'); disp(' ')
                close(diameterCheck)
                if strcmp(keepDiameter,'y') == true || strcmp(keepDiameter,'n') == true
                    ProcData.data.Pupil.diameterCheck = keepDiameter;
                    check = true;
                end
            end
            ProcData.data.Pupil.diameterCheckComplete = 'y';
            ProcData.data.Pupil.newDiameterCheck = 'y';
            save(procDataFileID,'ProcData')
        else
            ProcData.data.Pupil.diameterCheckComplete = 'y';
            ProcData.data.Pupil.newDiameterCheck = 'y';
            save(procDataFileID,'ProcData')
        end
    end
elseif strcmp(ProcData.data.Pupil.frameCheck,'n') == true
    ProcData.data.Pupil.diameterCheck = 'n';
    ProcData.data.Pupil.newDiameterCheck = 'y';
    ProcData.data.Pupil.diameterCheckComplete = 'y';
    save(procDataFileID,'ProcData')
end

end
