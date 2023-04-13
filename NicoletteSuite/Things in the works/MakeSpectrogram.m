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
    
    makeplots(spectrogram,'nofilter',freqrange);
end

function makeplots(spect,datitle,freqrange)
    figure;
    imagesc(spect)
    yticks((1:freqrange)* size(spect,1)/ freqrange);
    yticklabels(1:freqrange)
    title(datitle)
    clim([0 double(mean(spect,'all') + std(spect,0,'all'))])
    colormap('jet');
end

