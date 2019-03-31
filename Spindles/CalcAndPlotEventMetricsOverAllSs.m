function h = CalcAndPlotEventMetricsOverAllSs(metricFcnName,inputStructName,inputFieldName,outputBaseName,iss,isse,issi,issed,issid,durs,amps,freqs,SleepStartIdxs,SleepStopIdxs)

% CalcAndPlotEventMetricsOverAllSs
% inputStructName, inputFieldName, metricFcnName, outputBaseName, 
% durs, amps, freqs, SleepStartIdxs, SleepStopIdxs

h = [];

eval([outputBaseName '.A = ' metricFcnName '(' inputStructName '.' inputFieldName ');'])
eval(['tA = ' outputBaseName '.A;']);
eval(['th = PlotEventSimilarities(tA,' inputStructName '.spkrates,durs,amps,freqs,SleepStartIdxs,SleepStopIdxs);'])
h = cat(2,h,th);

eval([outputBaseName '.E = ' metricFcnName '(' inputStructName 'e.' inputFieldName ');'])
eval(['tE = ' outputBaseName '.E;']);
eval(['th = PlotEventSimilarities(tE,' inputStructName 'e.spkrates,durs,amps,freqs,SleepStartIdxs,SleepStopIdxs);'])
h = cat(2,h,th);

eval([outputBaseName '.I = ' metricFcnName '(' inputStructName 'i.' inputFieldName ');'])
eval(['tI = ' outputBaseName '.I;']);
eval(['th = PlotEventSimilarities(tI,' inputStructName 'i.spkrates,durs,amps,freqs,SleepStartIdxs,SleepStopIdxs);'])
h = cat(2,h,th);

eval([outputBaseName '.ED = ' metricFcnName '(' inputStructName 'ed.' inputFieldName ');'])
eval(['tED = ' outputBaseName '.ED;']);
eval(['th = PlotEventSimilarities(tED,' inputStructName 'ed.spkrates,durs,amps,freqs,SleepStartIdxs,SleepStopIdxs);'])
h = cat(2,h,th);

eval([outputBaseName '.ID = ' metricFcnName '(' inputStructName 'id.' inputFieldName ');'])
eval(['tID = ' outputBaseName '.ID;']);
eval(['th = PlotEventSimilarities(tID,' inputStructName 'id.spkrates,durs,amps,freqs,SleepStartIdxs,SleepStopIdxs);'])
h = cat(2,h,th);

eval(['assignin(''caller'',outputBaseName,' outputBaseName ');'])