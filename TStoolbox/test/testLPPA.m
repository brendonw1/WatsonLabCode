hm = getenv('HOME');

%  parent_dir = '/media/DataExt3/Data'
%  parent_dir = '/media/sdc1/Data'
parent_dir = '/home/adrien/Data/LPPA'
cd(parent_dir);


%  	datasets = {};
%  	ratNb = '15';
%  	ds15 = List2Cell([ parent_dir filesep 'datasets_rat' ratNb '.list' ] );
%  	l15 = length(ds15);
%  	datasets = ds15;
%  	ratNb = '18';
%  	ds18 = List2Cell([ parent_dir filesep 'datasets_rat' ratNb 'ThetaRipples.list' ] );
%  	l18 = length(ds18);
%  	datasets = [datasets;ds18];
%  	ratNb = '19';
%  	ds19 = List2Cell([ parent_dir filesep 'datasets_rat' ratNb '.list' ] );
%  	l19 = length(ds19);
%  	datasets = [datasets;ds19];
%  	ratNb = '20';
%  	ds20 = List2Cell([ parent_dir filesep 'datasets_rat' ratNb 'ThetaRipples.list' ] );
%  	l20 = length(ds20);
%  	datasets = [datasets;ds20];

%  	ratNb = '12';
%  	ds12 = List2Cell([ parent_dir filesep 'datasets_rat' ratNb 'ThetaRipples.list' ] );
%  	l12 = length(ds12);
%  	datasets = [datasets;ds12];
%  

datasets = List2Cell([ parent_dir filesep 'datasets_general.list' ] );
%  datasets = List2Cell([ parent_dir filesep 'datasets_test.list' ] );
%  datasets = List2Cell([ parent_dir filesep 'datasets_general_ShiftDays.list' ] );

%  datasets = List2Cell([ parent_dir filesep 'datasets_rat20ThetaRipples.list' ] );
%  datasets = List2Cell([ parent_dir filesep 'datasets_rat19.list' ]);

% learning:
%  datasets= {'Rat15/150707';'Rat15/150713';'Rat18/181012';'Rat18/181020';'Rat19/190213';'Rat19/190228'};

%  datasets= {'Rat18/181014'};
%  datasets= {'Rat20/201226'};	

A = Analysis(parent_dir);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Data                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  A = run(A, 'makeSpikeData', datasets, 'SpikeData', 'DoDebug', 0);
%  A = run(A, 'behaviorResources', datasets, 'behavResources', 'DoDebug', 1,'Overwrite',1);
%  A = run(A, 'behavEpochs', datasets, 'behavEpochs', 'DoDebug', 0,'Overwrite',1);
%  A = run(A, 'SpkWidthDB', datasets, 'SpkWidthDB', 'DoDebug', 0,'Overwrite',1);
%  A = run(A, 'SpkWidthDB2', datasets, 'SpkWidthDB2', 'DoDebug', 1,'Overwrite',1);
%  A = run(A, 'SpkShape', datasets, 'SpkShape', 'DoDebug', 0,'Overwrite',1);
%  A = run(A, 'SpkPeak2ValleyDB', datasets, 'SpkPeak2ValleyDB', 'DoDebug', 0,'Overwrite',1);


%  A = run(A, 'CellTypeWidth', datasets, 'CellTypeWidth', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'MazeFiringRate', datasets, 'MazeFiringRate', 'DoDebug', 1, 'Overwrite',1);

%  A = run(A, 'DefineExpRules', datasets, 'DefineExpRules', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'DefCorrectError', datasets, 'DefCorrectError', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'CellsLayer', datasets, 'CellsLayer', 'DoDebug', 1, 'Overwrite',1);

%  A = run(A, 'behavReport', datasets, 'behavReport', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'EEGSelection', datasets, 'EEGSelection', 'DoDebug', 1, 'Overwrite',1); 
%  A = run(A, 'SelectHcEEGRipples', datasets, 'SelectHcEEGRipples', 'DoDebug', 1, 'Overwrite',0);
%  A = run(A, 'LightTime', datasets, 'LightTime', 'DoDebug', 0, 'Overwrite',1);
%  A = run(A, 'LinearizeTrajectory', datasets, 'LinearizeTrajectory', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'SelectGoodCells', datasets, 'SelectGoodCells', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'HcPfcChannels', datasets, 'HcPfcChannels', 'DoDebug', 1, 'Overwrite',1);

%  A = run(A, 'CellsClassification', datasets, 'CellsClassification', 'DoDebug', 1, 'Overwrite',1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PETH / Rasters                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%  A = run(A, 'basicPETH', datasets, 'basicPETH', 'DoDebug', 0);
%  A = run(A, 'basicPETHOff', datasets, 'basicPETHOff', 'DoDebug', 1);
%  A = run(A, 'correctErrorPrevTrialPETH', datasets, 'correctErrorPrevTrialPETH', 'DoDebug', 1);
%  A = run(A, 'correctErrorPETH', datasets, 'correctErrorPETH', 'DoDebug', 0);
%  A = run(A, 'correctErrorPETHOff', datasets, 'correctErrorPETHOff', 'DoDebug', 1);
%  A = run(A, 'goLightDarkPETH', datasets, 'goLightDarkPETH', 'DoDebug', 0);
%  A = run(A, 'goLightDarkPETHOff', datasets, 'goLightDarkPETHOff', 'DoDebug', 0);
%  A = run(A, 'leftrightPETH', datasets, 'leftrightPETH', 'DoDebug', 0);
%  A = run(A, 'leftrightPETHOff', datasets, 'leftrightPETHOff', 'DoDebug', 0);
%  A = run(A, 'wholePETH', datasets, 'basicPETH', 'DoDebug', 1);
%  A = run(A, 'RipplesRaster', datasets, 'RippelsRaster', 'DoDebug', 0, 'Overwrite',1);
%  A = run(A, 'RipplesRewRaster', datasets, 'RippelsRewRaster', 'DoDebug', 0, 'Overwrite',1);
%  A = run(A, 'StartOutcomePETH', datasets, 'StartOutcomePETH', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'StartOutcomeRaster', datasets, 'StartOutcomeRaster', 'DoDebug', 1, 'Overwrite',1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scatter Plots                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%  A = run(A, 'scatterPlaceFields', datasets, 'scatterPlaceFields', 'DoDebug', 1);
%  A = run(A, 'scatterPlaceFieldsGo', datasets, 'scatterPlaceFieldsGo', 'DoDebug', 1);
%  A = run(A, 'scatterPlaceFieldsOff', datasets, 'scatterPlaceFieldsOff', 'DoDebug', 1);
%  A = run(A, 'scatterPlaceFieldsLeftRightGo', datasets, 'scatterPlaceFieldsGo', 'DoDebug', 1);
%  A = run(A, 'scatterPlaceFieldsByContingency', datasets, 'scatterPlaceFieldsByContingency', 'DoDebug', 1);
%  A = run(A, 'scatterPlaceFieldsByContingencyGo', datasets, 'scatterPlaceFieldsByContingencyGo', 'DoDebug', 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specgrams / Coherence            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%  A = run(A, 'SleepSpecgramGlobal', datasets, 'SleepSpecgramGlobal', 'DoDebug', 0,'Overwrite',1);
%  A = run(A, 'MazeSpecgramGlobal', datasets, 'MazeSpecgramGlobal', 'DoDebug', 0,'Overwrite',0);
%  A = run(A, 'coherence1', datasets, 'coherence1', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'mazeFineSpectrum', datasets, 'mazeFineSpectrum', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'SleepLargeSpectrum', datasets, 'SleepLarge', 'DoDebug', 1, 'Overwrite',1);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sleep                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  A = run(A, 'SleepStagesPCA', datasets, 'SleepStages', 'DoDebug', 0, 'Overwrite',1);
%  A = run(A, 'findDeltaEpochs', datasets, 'findDeltaEpochs', 'DoDebug', 0);

%  A = run(A, 'FindMUADownStates', datasets, 'FindMUADownStates', 'DoDebug', 0, 'Overwrite',1);

%  A = run(A, 'FindRecordRipples2', datasets, 'FindRecordRipples2', 'DoDebug', 1, 'Overwrite',1);
%  %  A = Analysis(parent_dir);
%  A = run(A, 'FindRecordRipplesSWS', datasets, 'FindRecordRipplesSWS', 'DoDebug', 0, 'Overwrite',0);

%  A = run(A, 'FineSWSSpindlesEpoch', datasets, 'FineSWSSpindlesEpoch', 'DoDebug', 0, 'Overwrite',1);
%  A = run(A, 'FindSpindlesPhase', datasets, 'FindSpindlesPhase', 'DoDebug', 0, 'Overwrite',1);
%  A = run(A, 'SpindlesPhaseModulation', datasets, 'SpindlesPhaseModulation', 'DoDebug', 0, 'Overwrite',1);
%  A = run(A, 'FindUpState', datasets, 'FindUpState', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'SlowOscillations_Ripples', datasets, 'SlowOscillations_Ripples', 'DoDebug', 0, 'Overwrite',1);
%  A = run(A, 'SlowOscillations_200HzRMS', datasets, 'SlowOscillations_200HzRMS', 'DoDebug', 1, 'Overwrite',1);

%  A = run(A, 'MeanLFP_UDS', datasets, 'MeanLFP_UDS', 'DoDebug', 0, 'Overwrite',1);

%  A = run(A, 'RipplesFrequency', datasets, 'RipplesFrequency', 'DoDebug', 0, 'Overwrite',1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reactivation                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%  A = run(A, 'ReactTimeCoursePCA', datasets, 'ReactTimeCoursePCA', 'DoDebug', 0, 'Overwrite',1);
%  A = run(A, 'EigenVal', datasets, 'EigenVal', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'ReactTimeCoursePCAErrorPermute', datasets, 'ReactTimeCoursePCAErrorPermute', 'DoDebug', 0, 'Overwrite',1);
%  A = run(A, 'ReactTimeCoursePCARandomPairs', datasets, 'ReactTimeCoursePCARandomPairs', 'DoDebug', 0, 'Overwrite',1);

%  A = run(A, 'ReactTimeCourseCohPCA', datasets, 'ReactTimeCourseCohPCA', 'DoDebug', 0, 'Overwrite',0);
%  A = run(A, 'ReactTimeCourseCohPCA_Trials', datasets, 'ReactTimeCourseCohPCA_Trials', 'DoDebug', 0, 'Overwrite',1);

%  A = run(A, 'ReactTimeCoursePCAFine', datasets, 'ReactTimeCoursePCAFine', 'DoDebug', 0, 'Overwrite',1);
%  A = run(A, 'ReactTimeCoursePCAFineErrorPermute', datasets, 'ReactTimeCoursePCAFineErrorPermute', 'DoDebug', 0, 'Overwrite',0);


%  A = run(A, 'ReactTimeCoursePCAnoTT', datasets, 'ReactTimeCoursePCAnoTT', 'DoDebug', 0, 'Overwrite',1);
%  A = run(A, 'ReactTimeCoursePCAnoTTErrorPermute', datasets, 'ReactTimeCoursePCAnoTTErrorPermute', 'DoDebug', 0, 'Overwrite',0);

A = run(A, 'ReactTimeCoursePCAnoTT_GoodCells', datasets, 'ReactTimeCoursePCAnoTT_GoodCells', 'DoDebug', 0, 'Overwrite',1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Theta-Ripples                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  A = run(A, 'HpcEEGThetaPhase', datasets, 'HpcEEGThetaPhase', 'DoDebug', 0, 'Overwrite',0);


%  A = run(A, 'FindRecordRipplesRew', datasets, 'FindRecordRipplesRew', 'DoDebug', 0, 'Overwrite',1);
%  A = run(A, 'FindRecordRipplesMaze', datasets, 'FindRecordRipplesMaze', 'DoDebug', 1, 'Overwrite',1);

%  A = run(A, 'PhasePref', datasets, 'PhasePref', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'ThetaModulation', datasets, 'ThetaModulation', 'DoDebug', 0, 'Overwrite',1);
%  A = run(A, 'ThetaPfcModulation', datasets, 'ThetaPfcModulation', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'RipplesModulation', datasets, 'RipplesModulation', 'DoDebug', 0, 'Overwrite',1);
%  A = run(A, 'RipplesModulationCtl2', datasets, 'RipplesModulationCtl2', 'DoDebug', 0, 'Overwrite',0);
%  A = run(A, 'RipplesModulation100msCtl2', datasets, 'RipplesModulation100msCtl2', 'DoDebug', 0, 'Overwrite',1);
%  A = run(A, 'RipplesModulationRew', datasets, 'RipplesModulationRew', 'DoDebug', 0, 'Overwrite',1);

%  A = run(A, 'ThetaPhaseBarPlot', datasets, 'ThetaPhaseBarPlot', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'PhasePrefRipples', datasets, 'PhasePrefRipples', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'CellsCorrRipples', datasets, 'coherence1', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'SPWCellsReact', datasets, 'SPWCellsReact', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'Theta_SPWlink', datasets, 'Theta_SPWlink', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'PCAcompare', datasets, 'PCAcompare', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'ArticleThetaRipples', datasets, 'ArticleThetaRipples', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'ArticleThetaRipples2', datasets, 'ArticleThetaRipples', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'RipplesSPindles', datasets, 'RipplesSPindles', 'DoDebug', 0, 'Overwrite',1);
%  A = run(A, 'RipplesDelta', datasets, 'RipplesDelta', 'DoDebug', 0, 'Overwrite',1);
%  A = run(A, 'RipplesLatence', datasets, 'RipplesLatence', 'DoDebug', 0, 'Overwrite',1);

%  A = run(A,'Ripples_200HzRMS', datasets, 'Ripples_200HzRMS', 'DoDebug', 1, 'Overwrite',1);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Expperimental stuff              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  A = run(A,'BrownFitPETH', datasets, 'BrownFitPETH', 'DoDebug', 1, 'Overwrite',1);

%  A = run(A,'LearningCurve', datasets, 'LearningCurve', 'DoDebug', 0, 'Overwrite',1);

%  A = run(A,'CompareEigenEntropy', datasets, 'CompareEigenEntropy', 'DoDebug', 1, 'Overwrite',1);

%  A = run(A,'DwStLatence', datasets, 'DwStLatence', 'DoDebug', 0, 'Overwrite',1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cells Connectivity               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%  A = run(A, 'CorrMaze', datasets, 'CorrMaze', 'DoDebug', 1, 'Overwrite',1);
%  A = run(A, 'NetworkConnection', datasets, 'NetworkConnection', 'DoDebug', 1, 'Overwrite',1);

%  A = run(A, 'testStuff', datasets, 'testStuff', 'DoDebug', 1, 'Overwrite',1);

%  A = run(A, 'SpkThetaCycle', datasets, 'SpkThetaCycle', 'DoDebug', 1, 'Overwrite',1);


%  
%  A = run(A, 'SpindlesPETH', datasets, 'SpindlesPETH', 'DoDebug', 0, 'Overwrite',1);
%  A = run(A, 'SpindlesRipplesPETH', datasets, 'SpindlesRipplesPETH', 'DoDebug', 0, 'Overwrite',1);




