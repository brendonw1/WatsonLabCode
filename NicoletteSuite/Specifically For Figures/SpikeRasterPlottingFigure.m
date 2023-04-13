
rat = 'Quiksilver';
DavidGetSpikes;
ints = makeints(rat); 
hypno = MakeHypno(ints);

if ~exist('raster', 'var')
    raster = dv_SpktToSpkmat(allspikecells, 1);
end

whatwelookinat = raster(13:14,:);
figure;
imagesc(whatwelookinat)
title('Whole Thing');

ZT06 = whatwelookinat(:,1:(3600*6));
ZT12 = whatwelookinat(:,(3600*6):(3600*12));
ZT18 = whatwelookinat(:,(3600*12):(3600*18));

figure;
imagesc(ZT06);
title('ZT 6');
figure;
imagesc(ZT12);
title('ZT12');
figure;
imagesc(ZT18);
title('ZT18');

figure; 
ZT06filt(1,:) = filter(gausswin(40),1,ZT06(1,:));
plot(ZT06filt(1,:)); 
hold on;
ZT06filt(2,:) = filter(gausswin(40),1,ZT06(2,:));
plot(ZT06filt(2,:));

