function BurstDecay = FitExponentialsToBurstDecays(ACGs,times,maxmaxtime)
% fits exponentials to decays from bursting in a series of ACGs.  ACGs are
% given as a matrix of timepoints x cells.  times are times associated with
% each dim1 point.  maxmaxtime is a time at which bursting is not allowed
% to be called burstin anylonger and so a fit is not made.
% Brendon Watson 2015

warning off

[BurstMaxTimes,BurstMaxIdxs] = MaxACGTimePoint(ACGs,times);%use 30ms ISIH
for b = 1:size(BurstMaxTimes,2)
    BurstDecay.ConstantVal(b) = nan;
    BurstDecay.ExponentVal(b) = nan;
    BurstDecay.ConstantCI(b,:) = nan(1,2);
    BurstDecay.ExponentCI(b,:) = nan(1,2);
    if BurstMaxIdxs(b) <= maxmaxtime
        decaytimes = times(BurstMaxIdxs(b):end);
        decaytimes = decaytimes' - BurstMaxTimes(b)+1;%reset first value to 1
        decayvals = ACGs(BurstMaxIdxs(b):end,b);
        try
            [BurstDecay.ConstantVal(b),BurstDecay.ExponentVal(b),BurstDecay.ConstantCI(b,:),BurstDecay.ExponentCI(b,:)] =...
                    fitexponential(decaytimes,decayvals);    
        end
    end
end
