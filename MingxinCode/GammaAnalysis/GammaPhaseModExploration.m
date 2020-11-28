function GammaPhaseModExploration
freqlist= unique(round(2.^(log2(1):1/12:log2(625))));
samplingRate = 1250;
xt = [1 2 4 7 10 20 40 70 100 200 400 700];
folders = dir;
for ii = 1:length(folders); % [23 33:35];
    % for ii = [1:15,17,19:27] % smaller recordings
    basepath = folders(ii).name;
    [~,basename] = fileparts(basepath);
    if exist(fullfile(basepath,[basename '_SpikePhasesAndPowerStateIdx.mat']),'file')
%         display(basename);
%         load(fullfile(basepath,[basename '_SpikePhasesAndPowerStateIdx.mat']),'spkPowerState');
%         for jj = 1:size(spkPowerState,1)
%             for kk = 1:size(spkPowerState,2)
%                 SpkCounts(jj,kk,1) = sum(spkPowerState{jj,kk}==1); % WAKE high
%                 SpkCounts(jj,kk,2) = sum(spkPowerState{jj,kk}==2); % MA high 
%                 SpkCounts(jj,kk,3) = sum(spkPowerState{jj,kk}==3); % NREM high
%                 SpkCounts(jj,kk,4) = sum(spkPowerState{jj,kk}==5); % REM high
%                 SpkCounts(jj,kk,5) = sum(spkPowerState{jj,kk}==-1); % WAKE low
%                 SpkCounts(jj,kk,6) = sum(spkPowerState{jj,kk}==-2); % MA low
%                 SpkCounts(jj,kk,7) = sum(spkPowerState{jj,kk}==-3); % NREM low
%                 SpkCounts(jj,kk,8) = sum(spkPowerState{jj,kk}==-5); % MA low
%             end
%         end
%         %%
%         figure;
%         subplot(4,2,1);
%         plot(log10(freqlist),mean(SpkCounts(:,:,1))');
%         ylabel('WAKE');
%         title('High Power');
%         subplot(4,2,2);
%         plot(log10(freqlist),mean(SpkCounts(:,:,5))');
%         title('Low Power');
%         
%         subplot(4,2,3);
%         plot(log10(freqlist),mean(SpkCounts(:,:,3))');
%         ylabel('NREM');
%         subplot(4,2,4);
%         plot(log10(freqlist),mean(SpkCounts(:,:,7))');
%         
%         subplot(4,2,5);
%         plot(log10(freqlist),mean(SpkCounts(:,:,4))');
%         ylabel('REM');
%         subplot(4,2,6);
%         plot(log10(freqlist),mean(SpkCounts(:,:,8))');
%         
%         subplot(4,2,7);
%         plot(log10(freqlist),mean(SpkCounts(:,:,2))');
%         ylabel('MA');
%         subplot(4,2,8);
%         plot(log10(freqlist),mean(SpkCounts(:,:,6))');
        %%
        load(fullfile(basepath,[basename '_NeighborZScoreIntervals.mat']),'AboveInt','BelowInt');
        for jj = 1:length(freqlist)
            AboveTime(jj) = sum(AboveInt{2,jj,2}(:,2)-AboveInt{2,jj,2}(:,1))/samplingRate;
            BelowTime(jj) = sum(BelowInt{2,jj,2}(:,2)-BelowInt{2,jj,2}(:,1))/samplingRate;
        end
        figure;
        plot(log10(freqlist),[AboveTime;BelowTime]);
        set(gca,'XTick',log10(xt),'XTickLabel',xt,'XTickLabelRotation',45);
        legend({'High Power';'Low Power '});
    end
end


end