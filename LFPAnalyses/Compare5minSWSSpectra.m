function Compare5minSWSSpectra(basepath,basename,ep1)
% function Compare5minSWSSpectra(basepath,basename)
% Loads lfp, converts to mV, then computes power spectra of Wake, REM, SWS
% and first5min and last5min SWS in sleep epochs.
% Brendon Watson 2015

%% Parameter setting
minfreq = 0.05;%lower end of range of frequencies to analyze
maxfreq = 150;%upper end of range of frequencies to analyze
% numfftfreqs = 2048;%number of frequencies to sample in the above range
% itype = 'pchip';%use cubic spline interpolation to get the above-specified numfftfreqs points
%                  % good alternate could be 'linear'

%% get basic info about this recording
if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end
if ~exist('ep1','var')
    ep1 = '5minsws';
end
if ~exist('plotting','var')
    plotting = 0;
end

bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
Par = bmd.Par;
goodeegchannel = bmd.goodeegchannel;
ints = load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']));

eeglfppath = findsessioneeglfpfile(basepath,basename);
fs = Par.lfpSampleRate;

%% Load and sub-section LFP
lfp = LoadBinary(eeglfppath,'nChannels',Par.nChannels,'channels',goodeegchannel);
% lfp = lfp*bmd.voltsperunit*1000;
tlfp = tsd((1:length(lfp))/fs*10000,double(lfp)*bmd.voltsperunit*1000);%make tsd version of this so it can be restricted

wlfpt = Restrict(tlfp,ints.WakeInts);%get wake lfp
rlfpt = Restrict(tlfp,ints.REMInts);%get rem lfp
slfpt = Restrict(tlfp,ints.SWSPacketInts);%get full sws lfp

% get specific sleep-related intervals
[eps1,eps2] = PrePostIntervalTimes(ints.WakeSleep,ints,ep1);
for a = 1:length(eps1)
    tpre = Restrict(tlfp,eps1{a});%get lfp from first 5min sws only... judged that it's OK to combine acros WSEpisodes so no loop...
    tpost = Restrict(tlfp,eps2{a});%get lfp from lasst 5min sws only... also cateps can be ignored given how Restrict works
    if a == 1;
        pre = tpre;
        post = tpost;
    else
        pre = cat(pre,tpre);
        post = cat(post,tpost);
    end
end

%%
wlfp = cat(2,Range(wlfpt,'s'),Data(wlfpt));
[wspect,standardFs] = MTSpectrum(wlfp,'range',[minfreq maxfreq],'window',5);
slfp = cat(2,Range(slfpt,'s'),Data(slfpt));
[sspect,standardFs] = MTSpectrum(slfp,'range',[minfreq maxfreq],'window',5);
try
    rlfp = cat(2,Range(rlfpt,'s'),Data(rlfpt));
    [rspect,standardFs] = MTSpectrum(rlfp,'range',[minfreq maxfreq],'window',5);
catch
   rspect = nan(size(sspect)); 
end
prelfp = cat(2,Range(pre,'s'),Data(pre));
[prespect,standardFs] = MTSpectrum(prelfp,'range',[minfreq maxfreq],'window',5);
postlfp = cat(2,Range(post,'s'),Data(post));
[postspect,standardFs] = MTSpectrum(postlfp,'range',[minfreq maxfreq],'window',5);

%% Plot
if plotting
    h=figure;
    loglog(standardFs,wspect,'k');
    hold on;
    loglog(standardFs,rspect,'color',[.5 .5 .5]);
    loglog(standardFs,sspect,'b');
    loglog(standardFs,prespect,'c');
    loglog(standardFs,postspect,'m');
    set(gca,'xlim',[minfreq maxfreq])
    set(findobj('parent',gca,'type','line'),'linewidth',2)
    legend({'Wake';'REM';'AllSWS';'First5minSWS';'Last5minSWS'})
    set(h,'name','FirstLast5minSWSPowerSpectra')
    MakeDirSaveFigsThereAs(fullfile(basepath,'Spectra'),h,'fig');
    MakeDirSaveFigsThereAs(fullfile(basepath,'Spectra'),h,'png');
end

%% Save
SWS5MinSpectra = v2struct(minfreq,maxfreq,standardFs,...
    wspect,sspect,rspect,prespect,postspect);
MakeDirSaveVarThere(fullfile(basepath,'Spectra'),SWS5MinSpectra);


%% Older version getting spectra using pure spectral measurement, not averaging of subspectra... but too ram intensive
% %% Getting spectra
% params.Fs = fs;
% params.fpass = [minfreq maxfreq];
% 
% % commented out below is attempt to specify points without interpolation,
% % did not give consistent relative powers between different recordings
% % params.nfft = 2^16;
% % [wS,wf]=mtspectrumc_bw(Data(wlfpt),params);%spectrum from wake
% % [sS,sf]=mtspectrumc_bw(Data(slfpt),params);%spectrum from all sws
% % [rS,rf]=mtspectrumc_bw(Data(rlfpt),params);%spectrum from rem
% % [f5sS,f5sf]=mtspectrumc_bw(Data(f5slfpt),params);%spectrum from first 5min sws
% % [l5sS,l5sf]=mtspectrumc_bw(Data(l5slfpt),params);%spectrum from last 5min sws
% 
% [wS,wf]=mtspectrumc(Data(wlfpt),params);%spectrum from wake
% [sS,sf]=mtspectrumc(Data(slfpt),params);%spectrum from all sws
% [rS,rf]=mtspectrumc(Data(rlfpt),params);%spectrum from rem
% [f5sS,f5sf]=mtspectrumc(Data(f5mlfpt),params);%spectrum from first 5min sws
% [l5sS,l5sf]=mtspectrumc(Data(l5mlfpt),params);%spectrum from last 5min sws
% 
% %% use interpolation to get values at the same point for each recording (so can be combined/compared on a pointwise basis)
% standardFs = logspace(log10(minfreq),log10(maxfreq),numfftfreqs);%desired 
% intwS = interp1(wf,wS,standardFs,itype);%interp
% intsS = interp1(sf,sS,standardFs,itype);%interp
% intrS = interp1(rf,rS,standardFs,itype);%interp
% intf5sS = interp1(f5sf,f5sS,standardFs,itype);%interp
% intl5sS = interp1(l5sf,l5sS,standardFs,itype);%interp
% 
% %% Plot
% h=figure;
% loglog(standardFs,smooth(intwS,5),'k')
% hold on;
% loglog(standardFs,smooth(intrS,5),'color',[.5 .5 .5])
% loglog(standardFs,smooth(intsS,5),'b')
% loglog(standardFs,smooth(intf5sS,5),'c')
% loglog(standardFs,smooth(intl5sS,5),'m')
% set(gca,'xlim',[minfreq maxfreq])
% legend({'Wake';'REM';'AllSWS';'First5minSWS';'Last5minSWS'})
%
% SWS5MinSpectra = v2struct(minfreq,maxfreq,numfftfreqs,itype,...
%     wS,wf,sS,sf,rS,rf,f5sS,f5sf,l5sS,l5sf,...
%     standardFs,intwS,intrS,intsS,intf5sS,intl5sS);
% 
% set(h,'name','FirstLast5minSWSPowerSpectra')
% MakeDirSaveFigsThereAs(fullfile(basepath,'Spectra'),h,'fig');
% MakeDirSaveFigsThereAs(fullfile(basepath,'Spectra'),h,'png');
% 
% MakeDirSaveVarThere(fullfile(basepath,'Spectra'),SWS5MinSpectra);

%% Older code, not sure it works.
% h = spectrum.periodogram;  
% hpsd = psd(h,double(lfp),'Fs',1250);
% 
% figure;
% plot(hpsd.Frequencies,smooth(hpsd.Data,100))
% set(gca,'yscale','log')
% xlim([0 200])