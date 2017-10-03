function cm = smoothMUA(S,binwidth,convwidth)
% Takes a spiketrain array (S), collapses it to a single mua, then smooths
% it using a gaussian of [conviwidth] milliseconds sigma, output resolution 
% is in bins of [binwidth] milliseconds width 

sampfreq = 10000; %samples per SECOND of the spiking data, based on TSToolbox
if ~exist('binwidth')
    binwidth = 1;% in ms
end

if ~exist('convwidth')
    convwidth = 11;% in ms
end

mua = oneSeries(S);
muat = TimePoints(mua);
samplesperbin = binwidth*sampfreq/1000;%for bins of duration binwidth milliseconds

[muat,ind] = histc(muat,[0:samplesperbin:max(muat)]);%1ms binning

% Gaussian smoothing... not clean at ends
g = gaussian(1:100,50,convwidth);
cm = conv(muat,g);

% Rectangular smoothing
% rectwidth = convwidth/binwidth;
% cm = conv(muat,ones(1,rectwidth));
