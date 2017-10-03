function [UPDurs,DNDurs] = UPstates_UPDOWNDurations

plotting = 1;

[names,dirs]=GetDefaultDataset;

DNDurs = [];
UPDurs = [];

for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};
%     disp(['Starting ' basename])
    load(fullfile(basepath,[basename '_UPDOWNIntervals.mat']))

    DNDurs = cat(1,DNDurs,(End(DNInts,'s')-Start(DNInts,'s')));
    UPDurs = cat(1,UPDurs,(End(UPInts,'s')-Start(UPInts,'s')));
    
end

meanDOWN = mean(DNDurs);
stdDOWN = std(DNDurs);
medianDOWN = median(DNDurs);
geomeanDOWN = geomean(DNDurs);
geostdDOWN = geostd(DNDurs);

meanUP = mean(UPDurs);
stdUP = std(UPDurs);
medianUP = median(UPDurs);
geomeanUP = geomean(UPDurs);
geostdUP = geostd(UPDurs);

if plotting
   h = figure('position',[100 0 800 800],'name','DOWNUPDurs');
   subplot(2,2,1)
   hist(DNDurs,100)
   yl = ylim(gca);
   hold on 
   plot([meanDOWN meanDOWN],yl,'k')
   plot([medianDOWN medianDOWN],yl,'g')
   title({'DOWN state Durations - Linear';'Black = mean. Green = median'})
   
   subplot(2,2,2)
   semilogxhist(DNDurs,100)
   yl = ylim(gca);
   hold on 
   plot([geomeanDOWN geomeanDOWN],yl,'m')
   plot([medianDOWN medianDOWN],yl,'g')
   set(gca,'XScale','log')
   axis tight
   title({'DOWN state Durations - Log';'Magenta = geomean. Green = median'})
   legend

   
   subplot(2,2,3)
   hist(UPDurs,100)
   yl = ylim(gca);
   hold on 
   plot([meanUP meanUP],yl,'k')
   plot([medianUP medianUP],yl,'g')
   legend
   title({'UP state Durations - Linear';'Black = mean. Green = median'})
    
   subplot(2,2,4)
   semilogxhist(UPDurs,100)
   yl = ylim(gca);
   hold on 
   plot([geomeanUP geomeanUP],yl,'m')
   plot([medianUP medianUP],yl,'g')
   set(gca,'XScale','log')
   axis tight
   legend
   title({'UP state Durations - Log';'Magenta = geomean. Green = median'})
    
   MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/UPStates/Durations',h)
end