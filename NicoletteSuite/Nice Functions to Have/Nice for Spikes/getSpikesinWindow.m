%if you give it a single vector that represents spike times, you will get a
%subset of spiketimes within that window.
%splicing is a bit weird...  don't know if I can explain... One sec
%Okay, I'm back. If you say that splicing is 1, then it will do this:
%
% [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15] 
%
% If you ran this function with a low limit of 4 and a high limit of 11,
% then WITH splicing, it will return [4 5 6 7 8 9 10 11]
% if you ran this function WITHOUT splicing, on the other hand, then it'll
% return: [0 1 2 3 4 5 6 7]. This feature may not seem too useful, but I 
% promise you that it most certainly can be :))) 

function [newspikes] = getSpikesinWindow(lowlimit,highlimit,spikes,splice)
newspikes = spikes(spikes >= lowlimit & spikes <= highlimit);
checkmono(newspikes);
    if ~splice
        newspikes = newspikes - lowlimit;
    end
end

function checkmono(vector)
    temp = diff(vector);
    ismonotonic = isempty(temp(temp < 0));
    if ~ismonotonic
        disp('spikes got fucked. Maybe you have more than 1 spike train')
    end
end
