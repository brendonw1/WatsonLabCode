load(fullfile(getdropbox,'BW OUTPUT','SleepProject','StateRates','StateRates.mat'))

w = StateRates.EWSWakeRates;
s = StateRates.ESWSRates;
r = StateRates.EREMRates;
[h,p, chi2stat,df] = prop_test([sum(w>=2) sum(r>=2)] , [995;995])
[h,p, chi2stat,df] = prop_test([sum(w>=2) sum(s>=2)] , [995;995])
[h,p, chi2stat,df] = prop_test([sum(r>=2) sum(s>=2)] , [995;995])