function cm = smoothMUA(S,binwidth,convwidth)


sampfreq = 10000; %samples per SECOND of the spiking data
binwidth = 1;% in ms
convwidth = 11;% in ms


mua = oneSeries(S);
muat = TimePoints(mua);
samplesperbin = binwidth*sampfreq/1000;%for bins of duration binwidth milliseconds

[muat,ind] = histc(muat,[0:samplesperbin:max(muat)]);%1ms binning

g = gaussian(1:100,50,50);
cm = conv(muat,g);

rectwidth = convwidth/binwidth;
cm = conv(muat,ones(1,rectwidth));
