if ~exist('yusut', 'var')
hana = readmatrix('/analysis/Dayvihd/Moriarty/Field Potentials/Moriarty FP01.csv');
yusut = readmatrix('/analysis/Dayvihd/Moriarty/Field Potentials/Moriarty FP06.csv');
ilgop = readmatrix('/analysis/Dayvihd/Moriarty/Field Potentials/Moriarty FP07.csv');
yulhana = readmatrix('/analysis/Dayvihd/Moriarty/Field Potentials/Moriarty FP11.csv');
yulyudul = readmatrix('/analysis/Dayvihd/Moriarty/Field Potentials/Moriarty FP18.csv');
end

fs = 1000; % smapling rate
ints = makeints('Moriarty'); 
%hypno = MakeHypno(ints);

%% HANA
[hanaREMSub,~] = makeWinSpecs(ints.REMstate,hana,fs);
[hanaNREMSub,~] = makeWinSpecs(ints.NREMstate,hana,fs);
[hanaWAKESub,~] = makeWinSpecs(ints.WAKEstate,hana,fs);

[hanaREMbinnedSpec,hanaREMbinnedFreq] = makeSuperSpectrumFromWinSpecs(hanaREMSub,.25);
[hanaNREMbinnedSpec,hanaNREMbinnedFreq] = makeSuperSpectrumFromWinSpecs(hanaNREMSub,.25);
[hanaWAKEbinnedSpec,hanaWAKEbinnedFreq] = makeSuperSpectrumFromWinSpecs(hanaWAKESub,.25);

figure; plot(hanaREMbinnedFreq,hanaREMbinnedSpec); title('Hana REM');
figure; plot(hanaNREMbinnedFreq,hanaNREMbinnedSpec); title('Hana NREM');
figure; plot(hanaWAKEbinnedFreq,hanaWAKEbinnedSpec); title('Hana WAKE');

%% YUSUT
[yusutREMSub,~] = makeWinSpecs(ints.REMstate,yusut,fs);
[yusutNREMSub,~] = makeWinSpecs(ints.NREMstate,yusut,fs);
[yusutWAKESub,~] = makeWinSpecs(ints.WAKEstate,yusut,fs);

[yusutREMbinnedSpec,yusutREMbinnedFreq] = makeSuperSpectrumFromWinSpecs(yusutREMSub,.25);
[yusutNREMbinnedSpec,yusutNREMbinnedFreq] = makeSuperSpectrumFromWinSpecs(yusutNREMSub,.25);
[yusutWAKEbinnedSpec,yusutWAKEbinnedFreq] = makeSuperSpectrumFromWinSpecs(yusutWAKESub,.25);

figure; plot(yusutREMbinnedFreq,yusutREMbinnedSpec); title('Yusut REM');
figure; plot(yusutNREMbinnedFreq,yusutNREMbinnedSpec); title('Yusut NREM');
figure; plot(yusutWAKEbinnedFreq,yusutWAKEbinnedSpec); title('Yusut WAKE');


%% ILGOP
[ilgopREMSub,~] = makeWinSpecs(ints.REMstate,ilgop,fs);
[ilgopNREMSub,~] = makeWinSpecs(ints.NREMstate,ilgop,fs);
[ilgopWAKESub,~] = makeWinSpecs(ints.WAKEstate,ilgop,fs);

[ilgopREMbinnedSpec,ilgopREMbinnedFreq] = makeSuperSpectrumFromWinSpecs(ilgopREMSub,.25);
[ilgopNREMbinnedSpec,ilgopNREMbinnedFreq] = makeSuperSpectrumFromWinSpecs(ilgopNREMSub,.25);
[ilgopWAKEbinnedSpec,ilgopWAKEbinnedFreq] = makeSuperSpectrumFromWinSpecs(ilgopWAKESub,.25);

figure; plot(ilgopREMbinnedFreq,ilgopREMbinnedSpec); title('Ilgop REM');
figure; plot(ilgopNREMbinnedFreq,ilgopNREMbinnedSpec); title('Ilgop NREM');
figure; plot(ilgopWAKEbinnedFreq,ilgopWAKEbinnedSpec); title('Ilgop WAKE');

%% YULHANA (This one low key looks like hot garbage)
[yulhanaREMSub,~] = makeWinSpecs(ints.REMstate,yulhana,fs);
[yulhanaNREMSub,~] = makeWinSpecs(ints.NREMstate,yulhana,fs);
[yulhanaWAKESub,~] = makeWinSpecs(ints.WAKEstate,yulhana,fs);

[yulhanaREMbinnedSpec,yulhanaREMbinnedFreq] = makeSuperSpectrumFromWinSpecs(yulhanaREMSub,.25);
[yulhanaNREMbinnedSpec,yulhanaNREMbinnedFreq] = makeSuperSpectrumFromWinSpecs(yulhanaNREMSub,.25);
[yulhanaWAKEbinnedSpec,yulhanaWAKEbinnedFreq] = makeSuperSpectrumFromWinSpecs(yulhanaWAKESub,.25);

figure; plot(yulhanaREMbinnedFreq,yulhanaREMbinnedSpec); title('Yulhana REM');
figure; plot(yulhanaNREMbinnedFreq,yulhanaNREMbinnedSpec); title('Yulhana NREM');
figure; plot(yulhanaWAKEbinnedFreq,yulhanaWAKEbinnedSpec); title('Yulhana WAKE');

%% YULYUDUL (This one higher key looks like hot garbage)

[yulyudulREMSub,~] = makeWinSpecs(ints.REMstate,yulyudul,fs);
[yulyudulNREMSub,~] = makeWinSpecs(ints.NREMstate,yulyudul,fs);
[yulyudulWAKESub,~] = makeWinSpecs(ints.WAKEstate,yulyudul,fs);

[yulyudulREMbinnedSpec,yulyudulREMbinnedFreq] = makeSuperSpectrumFromWinSpecs(yulyudulREMSub,.25);
[yulyudulNREMbinnedSpec,yulyudulNREMbinnedFreq] = makeSuperSpectrumFromWinSpecs(yulyudulNREMSub,.25);
[yulyudulWAKEbinnedSpec,yulyudulWAKEbinnedFreq] = makeSuperSpectrumFromWinSpecs(yulyudulWAKESub,.25);

figure; plot(yulyudulREMbinnedFreq,yulyudulREMbinnedSpec); title('Yulyudul REM');
figure; plot(yulyudulNREMbinnedFreq,yulyudulNREMbinnedSpec); title('Yulyudul NREM');
figure; plot(yulyudulWAKEbinnedFreq,yulyudulWAKEbinnedSpec); title('Yulyudul WAKE');

disp('yayay!!')

%% Plotting
rex = [yusutREMbinnedFreq];
rwhy = [1 2 3];
rzee = [yusutREMbinnedSpec; ilgopREMbinnedSpec; hanaREMbinnedSpec];

figure;
remplot = waterfall(rex,rwhy,rzee);
title('REM Power')
xlim([0 40])
xlabel('Frequency (Hz)')
zlabel('Power')
remplot.EdgeColor = 'm';
remplot.LineWidth = 3;

nex = [yusutNREMbinnedFreq];
nwhy = [1 2 3];
nzee = [yusutNREMbinnedSpec; ilgopNREMbinnedSpec; hanaNREMbinnedSpec];

figure;
nremplot = waterfall(nex,nwhy,nzee);
title('NREM Power')
xlim([0 40])
xlabel('Frequency (Hz)')
zlabel('Power')
nremplot.EdgeColor = [0 .7 1];
nremplot.LineWidth = 3;

wex = [yusutWAKEbinnedFreq];
wwhy = [1 2 3];
wzee = [yusutWAKEbinnedSpec; ilgopWAKEbinnedSpec; hanaWAKEbinnedSpec];

figure;
wakeplot = waterfall(wex,wwhy,wzee);
title('WAKE Power')
xlim([0 40])
xlabel('Frequency (Hz)')
zlabel('Power')
wakeplot.EdgeColor = [1 .85 .4];
wakeplot.LineWidth = 3;


%% ALL
[hanaSpec,hanaFreq,~] = SimpleSpectro(hana,fs,40);
[yusutSpec,yusutFreq,~] = SimpleSpectro(yusut,fs,40);
[ilgopSpec,ilgopFreq,~] = SimpleSpectro(ilgop,fs,40);
%% THIS
smoothhana = movmedian(hanaSpec, 1000); 
smoothyusut = movmedian(yusutSpec, 1000); 
smoothilgop = movmedian(ilgopSpec, 1000);

dsamphana = downsample(smoothhana,1000);
dsampyusut = downsample(smoothyusut,1000);
dsampilgop = downsample(smoothilgop,1000);
dsampFreq = downsample(hanaFreq,1000);

aex = [dsampFreq];
awhy = [1 2 3];
azee = [dsampyusut; dsampilgop; dsamphana];

figure; 
wakeplot = waterfall(aex,awhy,azee);
title('ALL Power')
xlim([0 40])
xlabel('Frequency (Hz)')
zlabel('Power')
wakeplot.EdgeColor = [0 0 0];
wakeplot.LineWidth = 3;


%% 

function [sub,subsig] = makeWinSpecs(sleepwinds,signal,fs)
    for i = 1:size(sleepwinds,1)
        subsig = LFPSubsetBasedOnInterval(signal,fs,sleepwinds(i,1),sleepwinds(i,2));
        [sub{1,i}, sub{2,i}] = SimpleSpectro(subsig,fs,40);
    end
end


%%Okay, this is a little bit of a complicated function. You have to give it
%%a cell in the form of sub, so a 2xn cell s.t. element {1,i} and {2,i} are
%%the same length. Elements {1,n} represent the y-value of the power spectra, 
%%and the {2,n} represent the x-values of the spectra (so the frequency values in Hz)
%%This function combines all of them into two giant vectors (so x and y).
%%The sort function is used on the x-values to get a permutatrix, and it is
%%applied to the y vector. This produces a plottable and most likely
%%continuous curve. This 'function' is then binned, which is determined by
%%the binlength variable. Again, this is pretty complicated, but let's just
%%give it a shot, yeah? 
function [binnedSpec,binnedFreq] = makeSuperSpectrumFromWinSpecs(sub,binlength) 
    superSpecs = [];
    superFreqs = [];
    for i = 1:size(sub,2)
        superSpecs = [superSpecs, sub{1,i}];
        superFreqs = [superFreqs, sub{2,i}];
    end
    
    if ~(length(superSpecs) == length(superFreqs))
        error('How fucking old are you?')
    end
    
    [sortedFreqs,permutatrix] = sort(superFreqs);
    sortedSpecs = superSpecs(permutatrix);
    
    [binnedSpec, binnedFreq] = weirdBinMethod(sortedSpecs,sortedFreqs,binlength);
    
    
end


%%Okay, this is a binning function, but it's a little bit of a strange one.
%%It bins both the frequency and power axis. Each bin is actually not gonna
%%be the same amount of elements at all. The goal of this is to bin per
%%unit frequency. Luckily, the sortedFreqs are already expressed in the
%%form of Hz... So this will hopefully be okay...
function [binnedSpec, binnedFreq] = weirdBinMethod(sortedSpecs,sortedFreqs,binsize)
    binnedFreq = 0:binsize:ceil(max(sortedFreqs));
    binnedSpec = zeros(1,length(binnedFreq)); 
    
    for i = 1:length(binnedFreq)
        if (i == length(binnedFreq))
            binnedSpec(i) = median(sortedSpecs(sortedFreqs > binnedFreq(i)));
        else
            binnedSpec(i) = median(sortedSpecs(sortedFreqs > binnedFreq(i) & sortedFreqs < binnedFreq(i+1)));
        end
    end
    
    binnedFreq = binnedFreq + (binsize / 2);
end