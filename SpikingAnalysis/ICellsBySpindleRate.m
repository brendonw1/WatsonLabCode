function [ISpFast,ISpSlow] = ICellsBySpindleRate(hzcutoff)
%

if ~exist('hzcutoff','var')
    hzcutoff = 1;
end
saveon = 0;

fname = '/mnt/brendon4/Dropbox/Data/ICellsBySpindleRate.mat';
allgood = 0;
if exist (fname,'file')
    load(fname);%loads ICellsBySpindleRate 
    if ICellsDvidedBySpindleRate.hzcutoff == hzcutoff
        v2struct(ICellsDvidedBySpindleRate)% unpacks ISpFast and ISpSlow
        allgood = 1;
    end        
else
    StateRates = SpikingAnalysis_GatherAllStateRates;
    ISpindle = StateRates.ISpindleRates;
    ISpFast = ISpindle>hzcutoff;
    ISpSlow = ISpindle<=hzcutoff;
end



if saveon
    ICellsDvidedBySpindleRate = v2struct(ISpFast,ISpSlow,hzcutoff);
    save(fname,'ICellsDvidedBySpindleRate')
end
