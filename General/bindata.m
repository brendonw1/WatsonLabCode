function binned = bindata(x,samplesperbin);

x = x(:)';%regularize dimensionality
len = length(x);
numbins = ceil(len/samplesperbin);

sampstoadd = numbins*samplesperbin-len;
x2 = [x zeros(1,sampstoadd)];

binned = mean(reshape(x2,samplesperbin,numbins),1);
binned(end) = mean(x(samplesperbin*(numbins-1):end));