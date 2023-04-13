%% The now

rat = 'Cyclops'; ints = makeints(rat); hypno = MakeHypno(ints);

field = readmatrix('/analysis/Dayvihd/Cyclops/Field Potentials/Cyclops FP05.csv');
kono = field;%(2650000:2700000);


%%
figure;
plot(kono); axis tight

%%
%filtered = bandpass(kono,[.01 10],10000);
%[specz,dul,set] = spectrogram(kono,10,[],[1 10],10000);

%% Custom spectrogram code because it seems like the built in function is weird
binsamples = 30000; %amount of samples per bin
bins = ceil(length(kono) / binsamples); %total number of bins
fs = 1000; %samples per second
df = fs/binsamples; % Don't think super hard about this... It's the nature of ffts
%freq = -fs/2:df:fs/2;
freq = 0:df:fs/2; freq(1) = []; %take out the 0
heats = [];
smootheats = [];
smoothies = [];
lol = [];
freqrange = 100; %must be an integer
for i = 1:bins
    if i == 1
        sub = kono(1:binsamples);
    elseif i == bins
        sub = kono((binsamples*(i-1)):end);
        df = fs/length(sub);
        freq = 0:df:fs/2; freq(1) = [];
    else
        sub = kono((binsamples*(i-1)):(binsamples*i));
    end
    
    thisspec = abs(fft(sub));
    %plot(freq,thisspec(1:length(freq)))
    
    %plot(freq(freq < 12),thisspec(freq < 12));
    disone = thisspec(freq < freqrange); %a normal spectrum  with #nofilter
    distwo = movmean(disone,round(length(disone) / 10)); %a spectrum with mean filter (window = a tenth of the spectrum length...)
    disthree = filter(gausswin(round(length(distwo) / 30)),1,distwo);%now let's smooth distwo with a gaussian kernel that is a 30th of spec length!
    disfour = disthree.^2; %okay, now let's square this so that the curves are hopefully more exaggerated
        
    % if you wanna test out some nice curves, use this:
    % figure; smoothie = movmean(heats(:,1),???); smoothie = filter(gausswin(???),1,smoothie); plot(smoothie)
    try
        heats(:,i) = disone; 
        smootheats(:,i) = distwo;
        smoothies(:,i) = disthree;
        lol(:,i) = disfour;
    catch
        disp('This better had failed because its the last iteration')
        if ~(i == bins)
            error('Are you fucking kidding me, you dumb whore? What did you do?');
        end
    end
end

%%
makeplots(heats,'#nofilter',freqrange)
makeplots(smootheats,'meanfilter',freqrange)
makeplots(smoothies,'smoothed filter',freqrange)
makeplots(lol,'squared',freqrange)


function makeplots(spect,datitle,freqrange)
    figure;
    imagesc(spect)
    yticks((1:freqrange)* size(spect,1)/ freqrange);
    yticklabels(1:freqrange)
    title(datitle)
    clim([0 mean(spect,'all') + std(spect,0,'all')])
    colormap('jet');
end