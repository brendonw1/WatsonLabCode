function A = MazeSpecgramGlobal(A)


cd(parent_dir(A));

A = getResource(A, 'MazeEpoch');
mazeEpoch = mazeEpoch{1};
A = getResource(A,'PfcTrace');


specfigdir = [ parent_dir(A) filesep 'specgrams' filesep 'maze'];

A = registerResource(A, 'MazeSpecgram', 'tsdArray', {6,1},...
    'mazeSpecgram', ...
    ['specgram  for each  EEG channel', ...
    'for the entire maze period'],'mfile');

A = registerResource(A, 'MazeSpecgramFreq', 'numeric',  {[],1}, ...
    'mazeSpecgramFreq', ...
    ['frequencies for the maze specgrams'],'mfile');

cd(current_dir(A));

mazeSpecgram = tsdArray(6,1);

for tr =1:6

    if (tr > 4) || (tr == pfcTrace)
	
	display(['channel ' num2str(tr)]);
	
	[p,dset,e] = fileparts(current_dir(A));
	eegfname = [dset 'eeg' num2str(tr) '.mat'];
	
	if exist([eegfname '.gz'])
		display(['unzipping file ' eegfname]);
		eval(['!gunzip ' eegfname '.gz']);
	end
	load(eegfname)
	eval(['EEG = EEG' num2str(tr), ';']);
	eval(['clear EEG' num2str(tr) ';']);    
	display(['zipping file ' eegfname]);
	eval(['!gzip ' eegfname]);

	EEG = Restrict(EEG, mazeEpoch);
	display 'a'

	st = StartTime(EEG);
	FsOrig = 1 / median(diff(Range(EEG, 's')));
	times = Range(EEG);
	dp = Data(EEG);
	clear EEG
	deeg = resample(dp, 600, 6250);
	clear dp
	display 'b'
	params.Fs = 200;
	params.fpass = [0 40];
	params.err = [2, 0.95];
	params.trialave = 0;
	movingwin = [2, 1];

	[S,t,f,Serr]=mtspecgramc(deeg,movingwin,params);
	display 'c'
	clear deeg
	mazeSpecgramFreq = f(:);

	
	
	
	%all this fuss is necessary to accommodate for EEG recordigns with possible
	%gaps in them
	t1 = 0:(1/FsOrig):((1/FsOrig)*(length(times)-1));
	[t2, ix] = Restrict(ts(t1), t-movingwin(1)/2);
	times = times(ix);
	figure(1), clf
	imagesc(times/10000, mazeSpecgramFreq, log10(abs(S')+eps));
	set(gcf, 'position', [54   532   917   380]);
	axis xy
	drawnow
	display 'd'
	saveas(gcf, [specfigdir filesep dset 'ch' num2str(tr) 'maze'], 'png');

	mazeSpecgram{tr} = tsd(times, S);
	clear S 
		
    end

end

cd(parent_dir(A));
A = saveAllResources(A);
