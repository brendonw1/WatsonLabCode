function [meanspectrogram,varargout] = StateTriggeredSpectrogram...
    (statenumber,beforesample,aftersample,channum,intervals,GoodSleepInterval,tssampfreq,basepath,basename)


meanspectrogram = [];
channelanatomy = read_mixed_csv([fullfile(basepath,basename) '_ChannelAnatomy.csv'],',');

% 
% intervalstarts = Start(intersect(intervals{statenumber},GoodSleepInterval))/tssampfreq;%episode start time in sec
% prestarts = intervalstarts - beforesample;%get pre-start time
% poststarts = intervalstarts + aftersample;% and post
% 
% % get rid of events that will run off the end of the useable period
% tooearly = prestarts < Start(GoodSleepInterval);
% toolate = poststarts > End(GoodSleepInterval);
% toobad = tooearly | toolate;
% prestarts(toobad) = [];
% poststarts(toobad) = [];
[prestarts,poststarts,intervalidxs] = getIntervalStartsWithinBounds(intervals{statenumber},beforesample,aftersample,GoodSleepInterval,tssampfreq);


% read spectrum from .eegstates.mat file
% t = load([fullfile(basepath,basename) '.eegstates.mat']);
% chans = t.StateInfo.Chs;

% if ismember(channum,chans);
%     fspec = t.StateInfo.fspec;
%     to = fspec{1}.to;
%     preinds = find(ismember(to,prestarts));
%     postinds = find(ismember(to,poststarts));
% 
% % for b = 1:length(fspec)
% %     channum = b;
% %         thischan =  chans(channum);
%     chanidx = find(chans==channum);
%     fo = fspec{chanidx}.fo;
%     for c = 1:size(preinds,1);
%        thischanspectra(:,:,c) = fspec{chanidx}.spec(preinds(c):postinds(c),:)';
%     end
%     meanperchannel(:,:,end+1) = mean(thischanspectra,3);
% else
%     clear t chans
    %load channel
    t = load(fullfile(basepath,[basename,'_BasicMetaData']));
    lfppath = findsessioneeglfpfile(basename,basepath);
    lfp = LoadLfp(lfppath,t.Par.nChannels,channum);    
    sampfreq = 10000/mode(diff(TimePoints(lfp)));
    lfp = double(Data(lfp));

    wlfp =  WhitenSignalIn(lfp,sampfreq*2000,1);
    [fspec, fo, to] = mtchglongIn(wlfp, 3072, sampfreq, 1*sampfreq, 0, [], [], [], [0 200]);

    preinds = find(ismember(to,prestarts));
    postinds = find(ismember(to,poststarts));
    
    for c = 1:size(preinds,1);%gather & average over timepoints
       thischanspectra(:,:,c) = fspec(preinds(c):postinds(c),:)';
    end
    meanspectrogram(:,:,end+1) = mean(thischanspectra,3);
% end

h = PlotSpectrogram(meanspectrogram(:,:,end),beforesample,fo,[0 100]);
title([basename,' Channel ',num2str(channum),': ',channelanatomy{channum,2}])
% end

% meanthischanspectra = mean(thischanspectra,3);

if nargout == 2
    varargout{1} = h;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subfunctions below


function [y, A] = WhitenSignalIn(x,varargin)

%artype =2; %Signal processing toolbox
artype =1; %arfit toolbox, (crushes sometimes with old version and single data type)

[window,CommonAR, ARmodel,ArOrder] = DefaultArgsIn(varargin,{[],1,[],1});
ArOrder = ArOrder+1;
Trans = 0;
if size(x,1)<size(x,2)
    x = x';
    Transf =1;
end
[nT nCh]  = size(x);
y = zeros(nT,nCh);
if isempty(window)
    seg = [1 nT];
    nwin=1;
else
    nwin = floor(nT/window)+1;
    seg = repmat([1 window],nwin,1)+repmat([0:nwin-1]'*window,1,2);
    if nwin*window>nT
        seg(end,2) =nT;
    end   
end

for j=1:nwin
    if ~isempty(ARmodel) 
        A = ARmodel;
        for i=1:nCh
            y(seg(j,1):seg(j,2),i) = Filter0In(A, x(seg(j,1):seg(j,2),i));
        end
    else
        if CommonAR % meaning common model for all channels and segments!!! 
            for i=1:nCh
                if  j==1 & i==1
                    switch artype
                        case 1
                            [w Atmp] = arfitIn(x(seg(j,1):seg(j,2),i),ArOrder,ArOrder);
                            A = [1 -Atmp];
                        case 2
                            A = arburg(x(seg(j,1):seg(j,2),i),ArOrder);
                    end
                    ARmodel = A;
                end
                y(seg(j,1):seg(j,2),i) = Filter0In(A, x(seg(j,1):seg(j,2),i));
            end
        else
            for i=1:nCh
                switch artype
                    case 1
                        [w Atmp] = arfitIn(x(seg(j,1):seg(j,2),i),ArOrder,ArOrder);
                        A =[1 -Atmp];
                    case 2
                        A = arburg(x(seg(j,1):seg(j,2),i),ArOrder);
                end
                y(seg(j,1):seg(j,2),i) = Filter0In(A, x(seg(j,1):seg(j,2),i));
            end
        end
    end
end

if Trans
    y =y';
end




function h = PlotSpectrogram(spec,beforesample,fo,freqrange)

freqstart = find(fo<freqrange(1),1,'last');
if isempty(freqstart);
    freqstart = 1;
end
freqstop = find(fo>freqrange(end),1,'first');
if isempty(freqstop);
    freqstop = length(fo);
end
spec = spec(freqstart:freqstop,:);

h = figure('Name','Spectrogram');
imagesc([0 size(spec,2)-1],[fo(freqstart) fo(freqstop)],log(spec));
set(gca,'YDir','Normal');
yl = ylim;
hold on;
plot([beforesample beforesample],[0 500],'k')
ylim(yl);

function varargout = DefaultArgsIn(Args, DefArgs)
% auxillary function to replace argument check in the beginning and def. args assigment
% sets the absent or empty values of the Args (cell array, usually varargin)
% to their default values from the cell array DefArgs. 
% Output should contain the actuall names of arguments that you use in the function

% e.g. : in function MyFunction(somearguments , varargin)
% calling [SampleRate, BinSize] = DefaultArgs(varargin, {20000, 20});
% will assign the defualt values to SampleRate and BinSize arguments if they
% are empty or absent in the varargin cell list 
% (not passed to a function or passed empty)
if isempty(Args)
    Args ={[]};
end

if iscell(Args{1}) & length(Args)==1
    Args = Args{1};
end

nDefArgs = length(DefArgs);
nInArgs = length(Args);
%out = cell(nDefArgs,1);
if (nargout~=nDefArgs)
    error('number of defaults is different from assigned');
    keyboard
end
for i=1:nDefArgs
    
    if (i>nInArgs | isempty(Args{i}))
        varargout(i) = {DefArgs{i}};
    else 
        varargout(i) = {Args{i}};
    end
end


function [w, A, C, sbc, fpe, th]=arfitIn(v, pmin, pmax, selector, no_const)
%ARFIT	Stepwise least squares estimation of multivariate AR model.
%
%  [w,A,C,SBC,FPE,th]=ARFIT(v,pmin,pmax) produces estimates of the
%  parameters of a multivariate AR model of order p,
%
%      v(k,:)' = w' + A1*v(k-1,:)' +...+ Ap*v(k-p,:)' + noise(C),
%
%  where p lies between pmin and pmax and is chosen as the optimizer
%  of Schwarz's Bayesian Criterion. The input matrix v must contain
%  the time series data, with columns of v representing variables
%  and rows of v representing observations.  ARFIT returns least
%  squares estimates of the intercept vector w, of the coefficient
%  matrices A1,...,Ap (as A=[A1 ... Ap]), and of the noise covariance
%  matrix C.
%
%  As order selection criteria, ARFIT computes approximations to
%  Schwarz's Bayesian Criterion and to the logarithm of Akaike's Final
%  Prediction Error. The order selection criteria for models of order
%  pmin:pmax are returned as the vectors SBC and FPE.
%
%  The matrix th contains information needed for the computation of
%  confidence intervals. ARMODE and ARCONF require th as input
%  arguments.
%       
%  If the optional argument SELECTOR is included in the function call,
%  as in ARFIT(v,pmin,pmax,SELECTOR), SELECTOR is used as the order
%  selection criterion in determining the optimum model order. The
%  three letter string SELECTOR must have one of the two values 'sbc'
%  or 'fpe'. (By default, Schwarz's criterion SBC is used.) If the
%  bounds pmin and pmax coincide, the order of the estimated model
%  is p=pmin=pmax. 
%
%  If the function call contains the optional argument 'zero' as the
%  fourth or fifth argument, a model of the form
%
%         v(k,:)' = A1*v(k-1,:)' +...+ Ap*v(k-p,:)' + noise(C) 
%
%  is fitted to the time series data. That is, the intercept vector w
%  is taken to be zero, which amounts to assuming that the AR(p)
%  process has zero mean.

%  Modified 14-Oct-00
%  Authors: Tapio Schneider
%           tapio@gps.caltech.edu
%
%           Arnold Neumaier
%           neum@cma.univie.ac.at

  % n: number of observations; m: dimension of state vectors
  [n,m]   = size(v);     

  if (pmin ~= round(pmin) | pmax ~= round(pmax))
    error('Order must be integer.');
  end
  if (pmax < pmin)
    error('PMAX must be greater than or equal to PMIN.')
  end

  % set defaults and check for optional arguments
  if (nargin == 3)              % no optional arguments => set default values
    mcor       = 1;               % fit intercept vector
    selector   = 'sbc';	          % use SBC as order selection criterion
  elseif (nargin == 4)          % one optional argument
    if strcmp(selector, 'zero')
      mcor     = 0;               % no intercept vector to be fitted
      selector = 'sbc';	          % default order selection 
    else
      mcor     = 1; 		  % fit intercept vector
    end
  elseif (nargin == 5)          % two optional arguments
    if strcmp(no_const, 'zero')
      mcor     = 0;               % no intercept vector to be fitted
    else
      error(['Bad argument. Usage: ', ...
	     '[w,A,C,SBC,FPE,th]=AR(v,pmin,pmax,SELECTOR,''zero'')'])
    end
  end

  ne  	= n-pmax;               % number of block equations of size m
  npmax	= m*pmax+mcor;          % maximum number of parameter vectors of length m

  if (ne <= npmax)
    error('Time series too short.')
  end

  % compute QR factorization for model of order pmax
  [R, scale]   = arqrIn(v, pmax, mcor);

  % compute approximate order selection criteria for models 
  % of order pmin:pmax
  [sbc, fpe]   = arordIn(R, m, mcor, ne, pmin, pmax);

  % get index iopt of order that minimizes the order selection 
  % criterion specified by the variable selector
  [val, iopt]  = min(eval(selector)); 

  % select order of model
  popt         = pmin + iopt-1; % estimated optimum order 
  np           = m*popt + mcor; % number of parameter vectors of length m

  % decompose R for the optimal model order popt according to 
  %
  %   | R11  R12 |
  % R=|          |
  %   | 0    R22 |
  %
  R11   = R(1:np, 1:np);
  R12   = R(1:np, npmax+1:npmax+m);    
  R22   = R(np+1:npmax+m, npmax+1:npmax+m);

  % get augmented parameter matrix Aaug=[w A] if mcor=1 and Aaug=A if mcor=0
  if (np > 0)   
    if (mcor == 1)
      % improve condition of R11 by re-scaling first column
      con 	= max(scale(2:npmax+m)) / scale(1); 
      R11(:,1)	= R11(:,1)*con; 
    end;
    Aaug = (R11\R12)';
    
    %  return coefficient matrix A and intercept vector w separately
    if (mcor == 1)
      % intercept vector w is first column of Aaug, rest of Aaug is 
      % coefficient matrix A
      w = Aaug(:,1)*con;        % undo condition-improving scaling
      A = Aaug(:,2:np);
    else
      % return an intercept vector of zeros 
      w = zeros(m,1);
      A = Aaug;
    end
  else
    % no parameters have been estimated 
    % => return only covariance matrix estimate and order selection 
    % criteria for ``zeroth order model''  
    w   = zeros(m,1);
    A   = [];
  end
  
  % return covariance matrix
  dof   = ne-np;                % number of block degrees of freedom
  C     = R22'*R22./dof;        % bias-corrected estimate of covariance matrix
  
  % for later computation of confidence intervals return in th: 
  % (i)  the inverse of U=R11'*R11, which appears in the asymptotic 
  %      covariance matrix of the least squares estimator
  % (ii) the number of degrees of freedom of the residual covariance matrix 
  invR11 = inv(R11);
  if (mcor == 1)
    % undo condition improving scaling
    invR11(1, :) = invR11(1, :) * con;
  end
  Uinv   = invR11*invR11';
  th     = [dof zeros(1,size(Uinv,2)-1); Uinv];
  

function [R, scale]=arqrIn(v, p, mcor)
%ARQR	QR factorization for least squares estimation of AR model.
%
%  [R, SCALE]=ARQR(v,p,mcor) computes the QR factorization needed in
%  the least squares estimation of parameters of an AR(p) model. If
%  the input flag mcor equals one, a vector of intercept terms is
%  being fitted. If mcor equals zero, the process v is assumed to have
%  mean zero. The output argument R is the upper triangular matrix
%  appearing in the QR factorization of the AR model, and SCALE is a
%  vector of scaling factors used to regularize the QR factorization.
%
%  ARQR is called by ARFIT. 
%
%  See also ARFIT.

%  Modified 29-Dec-99
%  Author: Tapio Schneider
%          tapio@gps.caltech.edu

  % n: number of time steps; m: dimension of state vectors
  [n,m] = size(v);     

  ne    = n-p;                  % number of block equations of size m
  np    = m*p+mcor;             % number of parameter vectors of size m

  % If the intercept vector w is to be fitted, least squares (LS)
  % estimation proceeds by solving the normal equations for the linear
  % regression model
  %
  %                  v(k,:)' = Aaug*u(k,:)' + noise(C)
  %
  % with Aaug=[w A] and `predictors' 
  %
  %              u(k,:) = [1 v(k-1,:) ...  v(k-p,:)]. 
  %
  % If the process mean is taken to be zero, the augmented coefficient
  % matrix is Aaug=A, and the regression model
  %
  %                u(k,:) = [v(k-1,:) ...  v(k-p,:)]
  %
  % is fitted. 
  % The number np is the dimension of the `predictors' u(k). 

  % Assemble the data matrix K (of which a QR factorization will be computed)
  K = zeros(ne,np+m);                 % initialize K
  if (mcor == 1)
    % first column of K consists of ones for estimation of intercept vector w
    K(:,1) = ones(ne,1);
  end
  
  % Assemble `predictors' u in K 
  for j=1:p
    K(:, mcor+m*(j-1)+1:mcor+m*j) = [v(p-j+1:n-j, :)];
  end
  % Add `observations' v (left hand side of regression model) to K
  K(:,np+1:np+m) = [v(p+1:n, :)];
  
  % Compute regularized QR factorization of K: The regularization
  % parameter delta is chosen according to Higham's (1996) Theorem
  % 10.7 on the stability of a Cholesky factorization. Replace the
  % regularization parameter delta below by a parameter that depends
  % on the observational error if the observational error dominates
  % the rounding error (cf. Neumaier, A. and T. Schneider, 2001:
  % "Estimation of parameters and eigenmodes of multivariate
  % autoregressive models", ACM Trans. Math. Softw., 27, 27--57.).
  q     = np + m;             % number of columns of K
  delta = (q^2 + q + 1)*eps;  % Higham's choice for a Cholesky factorization
  scale = sqrt(delta)*sqrt(sum(K.^2));   
  R     = triu(qr([K; diag(scale)]));


function [sbc, fpe, logdp, np] = arordIn(R, m, mcor, ne, pmin, pmax)
%ARORD	Evaluates criteria for selecting the order of an AR model.
%
%  [SBC,FPE]=ARORD(R,m,mcor,ne,pmin,pmax) returns approximate values
%  of the order selection criteria SBC and FPE for models of order
%  pmin:pmax. The input matrix R is the upper triangular factor in the
%  QR factorization of the AR model; m is the dimension of the state
%  vectors; the flag mcor indicates whether or not an intercept vector
%  is being fitted; and ne is the number of block equations of size m
%  used in the estimation. The returned values of the order selection
%  criteria are approximate in that in evaluating a selection
%  criterion for an AR model of order p < pmax, pmax-p initial values
%  of the given time series are ignored.
%
%  ARORD is called by ARFIT. 
%	
%  See also ARFIT, ARQR.

%  For testing purposes, ARORD also returns the vectors logdp and np,
%  containing the logarithms of the determinants of the (scaled)
%  covariance matrix estimates and the number of parameter vectors at
%  each order pmin:pmax.

%  Modified 17-Dec-99
%  Author: Tapio Schneider
%          tapio@gps.caltech.edu
  
  imax 	  = pmax-pmin+1;        % maximum index of output vectors
  
  % initialize output vectors
  sbc     = zeros(1, imax);     % Schwarz's Bayesian Criterion
  fpe     = zeros(1, imax);     % log of Akaike's Final Prediction Error
  logdp   = zeros(1, imax);     % determinant of (scaled) covariance matrix
  np      = zeros(1, imax);     % number of parameter vectors of length m
  np(imax)= m*pmax+mcor;

  % Get lower right triangle R22 of R: 
  %
  %   | R11  R12 |
  % R=|          |
  %   | 0    R22 |
  %
  R22     = R(np(imax)+1 : np(imax)+m, np(imax)+1 : np(imax)+m);

  % From R22, get inverse of residual cross-product matrix for model
  % of order pmax
  invR22  = inv(R22);
  Mp      = invR22*invR22';
  
  % For order selection, get determinant of residual cross-product matrix
  %       logdp = log det(residual cross-product matrix)
  logdp(imax) = 2.*log(abs(prod(diag(R22))));

  % Compute approximate order selection criteria for models of 
  % order pmin:pmax
  i = imax;
  for p = pmax:-1:pmin
    np(i)      = m*p + mcor;	% number of parameter vectors of length m
   if p < pmax
      % Downdate determinant of residual cross-product matrix
      % Rp: Part of R to be added to Cholesky factor of covariance matrix
      Rp       = R(np(i)+1:np(i)+m, np(imax)+1:np(imax)+m);

      % Get Mp, the downdated inverse of the residual cross-product
      % matrix, using the Woodbury formula
      L        = chol(eye(m) + Rp*Mp*Rp')';
      N        = L \ Rp*Mp;
      Mp       = Mp - N'*N;

      % Get downdated logarithm of determinant
      logdp(i) = logdp(i+1) + 2.* log(abs(prod(diag(L))));
   end

   % Schwarz's Bayesian Criterion
   sbc(i) = logdp(i)/m - log(ne) * (ne-np(i))/ne;

   % logarithm of Akaike's Final Prediction Error
   fpe(i) = logdp(i)/m - log(ne*(ne-np(i))/(ne+np(i)));

   % Modified Schwarz criterion (MSC):
   % msc(i) = logdp(i)/m - (log(ne) - 2.5) * (1 - 2.5*np(i)/(ne-np(i)));

   i      = i-1;                % go to next lower order
end
  
  

function y = Filter0In(b, x)

if size(x,1) == 1
	x = x(:);
end

% if mod(length(b),2)~=1
% 	error('filter order should be odd');
% end
if mod(length(b),2)~=1
    shift = length(b)/2;
else
    shift = (length(b)-1)/2;
end

[y0 z] = filter(b,1,single(x));

y = [y0(shift+1:end,:) ; z(1:shift,:)];


function [y, f, t, phi, FStats]=mtchglongIn(varargin);
%function [yo, fo, to, phi, FStats]=mtchglong(x,nFFT,Fs,WinLength,nOverlap,NW,Detrend,nTapers,FreqRange);
% Multitaper Time-Frequency Cross-Spectrum (cross spectrogram)
% for long files - splits data into blockes to save memory
% function A=mtcsg(x,nFFT,Fs,WinLength,nOverlap,NW,nTapers)
% x : input time series
% nFFT = number of points of FFT to calculate (default 1024)
% Fs = sampling frequency (default 2)
% WinLength = length of moving window (default is nFFT)
% nOverlap = overlap between successive windows (default is WinLength/2)
% NW = time bandwidth parameter (e.g. 3 or 4), default 3
% nTapers = number of data tapers kept, default 2*NW -1
%
% output yo is yo(f, t)
%
% If x is a multicolumn matrix, each column will be treated as a time
% series and you'll get a matrix of cross-spectra out yo(f, t, Ch1, Ch2)
% NB they are cross-spectra not coherences. If you want coherences use
% mtcohere

% Original code by Partha Mitra - modified by Ken Harris 
% and adopted for long files and phase by Anton Sirota
% Also containing elements from specgram.m

% default arguments and that
[x,nFFT,Fs,WinLength,nOverlap,NW,Detrend,nTapers,nChannels,nSamples,nFFTChunks,winstep,select,nFreqBins,f,t] = mtparamIn(varargin);

% allocate memory now to avoid nasty surprises later
y=complex(zeros(nFFTChunks,nFreqBins, nChannels, nChannels)); % output array
if nargout>3
    phi=complex(zeros(nFFTChunks,nFreqBins, nChannels, nChannels));
end
nFFTChunksall= nFFTChunks;
freemem = FreeMemoryIn;
BlockSize = 2^8;
nBlocks = ceil(nFFTChunksall/BlockSize);
%h = waitbar(0,'Wait..');
for Block=1:nBlocks
    %   waitbar(Block/nBlocks,h);
    minChunk = 1+(Block-1)*BlockSize;
    maxChunk = min(Block*BlockSize,nFFTChunksall);
    nFFTChunks = maxChunk - minChunk+1;
    iChunks = [minChunk:maxChunk];
    Periodogram = complex(zeros(nFreqBins, nTapers, nChannels, nFFTChunks)); % intermediate FFTs
    Temp1 = complex(zeros(nFreqBins, nTapers, nFFTChunks));
    Temp2 = complex(zeros(nFreqBins, nTapers, nFFTChunks));
    Temp3 = complex(zeros(nFreqBins, nTapers, nFFTChunks));
    eJ = complex(zeros(nFreqBins, nFFTChunks));
    tmpy =complex(zeros(nFreqBins,nFFTChunks, nChannels, nChannels));
    % calculate Slepian sequences.  Tapers is a matrix of size [WinLength, nTapers]
    [Tapers V]=dpss(WinLength,NW,nTapers, 'calc');
    % New super duper vectorized alogirthm
    % compute tapered periodogram with FFT 
    % This involves lots of wrangling with multidimensional arrays.
    
    TaperingArray = repmat(Tapers, [1 1 nChannels]);
    for j=1:nFFTChunks
        jcur = iChunks(j);
        Segment = x((jcur-1)*winstep+[1:WinLength], :);
        if (~isempty(Detrend))
            Segment = detrend(Segment, Detrend);
        end;
        SegmentsArray = permute(repmat(Segment, [1 1 nTapers]), [1 3 2]);
        TaperedSegments = TaperingArray .* SegmentsArray;
        
        fftOut = fft(TaperedSegments,nFFT);
        normfac = sqrt(2/nFFT); %to get back rms of original units
        Periodogram(:,:,:,j) = fftOut(select,:,:)*normfac; %fft(TaperedSegments,nFFT);
        % Periodogram: size  = nFreqBins, nTapers, nChannels, nFFTChunks
    end	
    if nargout>4
        U0 = repmat(sum(Tapers(:,1:2:end)),[nFreqBins,1,nChannels,   nFFTChunks]);
        Mu = sq(sum(Periodogram(:,1:2:end,:,:) .* conj(U0), 2) ./  sum(abs(U0).^2, 2));
        Num = abs(Mu).^2;
        Sp = sq(sum(abs(Periodogram).^2,2));
        chunkFS = (nTapers-1) * Num ./ (Sp ./ sq(sum(abs(U0).^2, 2))- Num );
        %	sum(abs(Periodogram - U0.*repmat(Mu,[1,nTapers,1,1])), 2);
        FStats(iChunks, :, :)  = permute(reshape(chunkFS, [nFreqBins, nChannels, nFFTChunks]),[ 3 1, 2]);
    end
    % Now make cross-products of them to fill cross-spectrum matrix
    for Ch1 = 1:nChannels
        for Ch2 = Ch1:nChannels % don't compute cross-spectra twice
            Temp1 = reshape(Periodogram(:,:,Ch1,:), [nFreqBins,nTapers,nFFTChunks]);
            Temp2 = reshape(Periodogram(:,:,Ch2,:), [nFreqBins,nTapers,nFFTChunks]);
            Temp2 = conj(Temp2);
            Temp3 = Temp1 .* Temp2;
            eJ=sum(Temp3, 2);
            tmpy(:,:, Ch1, Ch2)= eJ/nTapers;
            
            % for off-diagonal elements copy into bottom half of matrix
            if (Ch1 ~= Ch2)
                tmpy(:,:, Ch2, Ch1) = conj(eJ) / nTapers;
            end            
            
        end
    end
    
    for Ch1 = 1:nChannels
        for Ch2 = 1:nChannels % don't compute cross-spectra twice
            
            if (Ch1 == Ch2)
                % for diagonal elements (i.e. power spectra) leave unchanged
                y(iChunks,:,Ch1, Ch2) = permute(tmpy(:,:,Ch1, Ch2),[2 1 3 4]);
            else
                % for off-diagonal elements, scale
                
                y(iChunks,:,Ch1, Ch2) = permute((abs(tmpy(:,:,Ch1, Ch2).^2) ...
                    ./ (tmpy(:,:,Ch1,Ch1) .* tmpy(:,:,Ch2,Ch2))), [2 1 3 4]);
                if nargout>3
                    phi(iChunks,:,Ch1,Ch2) = permute(angle(tmpy(:,:,Ch1, Ch2) ...
                        ./ sqrt(tmpy(:,:,Ch1,Ch1) .* tmpy(:,:,Ch2,Ch2))), [2 1 3 4]); 
                end
            end
        end
    end
    
    
end
%close(h);
% we've now done the computation.  the rest of this code is stolen from
% specgram and just deals with the output stage

if nargout == 0
    % take abs, and use image to display results
    newplot;
    for Ch1=1:nChannels, for Ch2 = 1:nChannels
            subplot(nChannels, nChannels, Ch1 + (Ch2-1)*nChannels);
	    if Ch1==Ch2
		if length(t)==1
			imagesc([0 1/f(2)],f,20*log10(abs(y(:,:,Ch1,Ch2))+eps)');axis xy; colormap(jet);
		else
			imagesc(t,f,20*log10(abs(y(:,:,Ch1,Ch2))+eps)');axis xy; colormap(jet);
		end
	    else
	    	imagesc(t,f,(abs(y(:,:,Ch1,Ch2)))');axis xy; colormap(jet);
	    end
        end; end;
    xlabel('Time')
    ylabel('Frequency')
end


function [x,nFFT,Fs,WinLength,nOverlap,NW,Detrend,nTapers,nChannels,nSamples,nFFTChunks,winstep,select,nFreqBins,f,t,FreqRange] ...
    = mtparamIn(P)

nargs = length(P);

x = P{1};
if (nargs<2 | isempty(P{2})) nFFT = 1024; else nFFT = P{2}; end;
if (nargs<3 | isempty(P{3})) Fs = 1250; else Fs = P{3}; end;
if (nargs<4 | isempty(P{4})) WinLength = nFFT; else WinLength = P{4}; end;
if (nargs<5 | isempty(P{5})) nOverlap = WinLength/2; else nOverlap = P{5}; end;
if (nargs<6 | isempty(P{6})) NW = 3; else NW = P{6}; end;
if (nargs<7 | isempty(P{7})) Detrend = ''; else Detrend = P{7}; end;
if (nargs<8 | isempty(P{8})) nTapers = 2*NW -1; else nTapers = P{8}; end;
if (nargs<9 | isempty(P{9})) FreqRange = [0 Fs/2]; else FreqRange = P{9}; end
% Now do some compuatations that are common to all spectrogram functions
if size(x,1)<size(x,2)
    x = x';
end
nChannels = size(x, 2);
nSamples = size(x,1);

if length(nOverlap)==1
    winstep = WinLength - nOverlap;
    % calculate number of FFTChunks per channel
    %remChunk = rem(nSamples-Window)
    nFFTChunks = max(1,round(((nSamples-WinLength)/winstep))); %+1  - is it ? but then get some error in the chunking in mtcsd... let's figure it later
    t = winstep*(0:(nFFTChunks-1))'/Fs;
else
    winstep = 0;
    nOverlap = nOverlap(nOverlap>WinLength/2 & nOverlap<nSamples-WinLength/2);
    nFFTChunks = length(nOverlap);
    t = nOverlap(:)/Fs; 
end 
%here is how welch.m of matlab does it:
% LminusOverlap = L-noverlap;
% xStart = 1:LminusOverlap:k*LminusOverlap;
% xEnd   = xStart+L-1;
% welch is doing k = fix((M-noverlap)./(L-noverlap)); why?
% turn this into time, using the sample frequency


% set up f and t arrays
if isreal(x)%~any(any(imag(x)))    % x purely real
	if rem(nFFT,2),    % nfft odd
		select = [1:(nFFT+1)/2];
	else
		select = [1:nFFT/2+1];
	end
	nFreqBins = length(select);
else
	select = 1:nFFT;
end
f = (select - 1)'*Fs/nFFT;
nFreqRanges = size(FreqRange,1);
%if (FreqRange(end)<Fs/2)
    if nFreqRanges==1
        select = find(f>FreqRange(1) & f<FreqRange(end));
        f = f(select);
        nFreqBins = length(select);
    else
        select=[];
        for i=1:nFreqRanges
            select=cat(1,select,find(f>FreqRange(i,1) & f<FreqRange(i,2)));
        end
        f = f(select);
        nFreqBins = length(select);
    end
%end


% computes the available memory in bytes
function HowMuch = FreeMemoryIn
if isunix
	[junk mem] = unix('vmstat |tail -1|awk ''{print $4} {print $6}''');
	HowMuch = sum(mem);
else
	HowMuch = 200;
	%200Mb for windows machin
	
end