function [spectrogram] = MakeSpectrogram(signal,fs,freqrange,binlength)
    for i = 1:round(length(signal) / binlength)
        if i == round(length(signal) / binlength)
            subsig = LFPSubsetBasedOnInterval(signal,1,(i-1)*binlength,length(signal));
        else
            subsig = LFPSubsetBasedOnInterval(signal,1,(i-1)*binlength,i*binlength);
        end
        
        try            
            spectrogram(:,i) = SimpleSpectro(subsig,fs,freqrange); 
        catch
            if ~(i == round(length(signal) / binlength))
                error('Are you fucking kidding me, you dumb whore? What did you do?');
            end
        end
        
    end
    
    makeplots(spectrogram,'nofilter',freqrange,fs);
end

function makeplots(spect,datitle,freqrange,fs)
    if fs/2 < freqrange
        freqrange = fs/2;
    end
    
    figure;
    imagesc(spect)
    yticks((0:freqrange/10:freqrange)* size(spect,1)/ freqrange);
    yticklabels(0:freqrange/10:freqrange)
    title(datitle)
    clim([0 double(mean(spect,'all') + std(spect,0,'all'))])
    colormap('jet');
end

