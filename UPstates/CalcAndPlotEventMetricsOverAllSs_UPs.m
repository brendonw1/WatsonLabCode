function h = CalcAndPlotEventMetricsOverAllSs_UPs(metricFcnName,inputStructName,inputFieldName,outputBaseName,iss,isse,issi,durs,SleepStartIdxs,SleepStopIdxs)

% CalcAndPlotEventMetricsOverAllSs
% inputStructName, inputFieldName, metricFcnName, outputBaseName, 
% durs, amps, freqs, SleepStartIdxs, SleepStopIdxs
times = mean([iss.intstarts iss.intends],2);

h = [];

eval([outputBaseName '.A = ' metricFcnName '(' inputStructName '.' inputFieldName ');'])
eval(['tA = ' outputBaseName '.A;']);
eval(['th = PlotEventSimilarities_UPs(tA,times,' inputStructName '.spkrates,durs,SleepStartIdxs,SleepStopIdxs);'])
h = cat(2,h,th);
disp('A Done')

eval([outputBaseName '.E = ' metricFcnName '(' inputStructName 'e.' inputFieldName ');'])
eval(['tE = ' outputBaseName '.E;']);
eval(['th = PlotEventSimilarities_UPs(tE,times,' inputStructName 'e.spkrates,durs,SleepStartIdxs,SleepStopIdxs);'])
h = cat(2,h,th);

eval([outputBaseName '.I = ' metricFcnName '(' inputStructName 'i.' inputFieldName ');'])
eval(['tI = ' outputBaseName '.I;']);
eval(['th = PlotEventSimilarities_UPs(tI,times,' inputStructName 'i.spkrates,durs,SleepStartIdxs,SleepStopIdxs);'])
h = cat(2,h,th);

% eval([outputBaseName '.ED = ' metricFcnName '(' inputStructName 'ed.' inputFieldName ');'])
% eval(['tED = ' outputBaseName '.ED;']);
% eval(['th = PlotEventSimilarities_UPs(tED,' inputStructName 'ed.spkrates,durs,SleepStartIdxs,SleepStopIdxs);'])
% h = cat(2,h,th);
% 
% eval([outputBaseName '.ID = ' metricFcnName '(' inputStructName 'id.' inputFieldName ');'])
% eval(['tID = ' outputBaseName '.ID;']);
% eval(['th = PlotEventSimilarities_UPs(tID,' inputStructName 'id.spkrates,durs,SleepStartIdxs,SleepStopIdxs);'])
% h = cat(2,h,th);

eval(['assignin(''caller'',outputBaseName,' outputBaseName ');'])