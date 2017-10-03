function [y, A] = WhitenSignal(x,varargin)
% Taken from Andres Grosmark's StateEditor... he took it from WhitenSignals
% by Anton Sirota.
% Uses an autoregressive model to filter the eeg trace to compensate for
% 1/f frequency strengths.  
% 
% INPUTS
% x = timeseries data (ie from eeg)
%
% OPTIONAL INPUTS
% window = chunk size (in samples) to divide input into for processsing. Default is none.
% CommonAR = Whether the same model is used for all channels.  Default is 1
% ARmodel = may input a pre-known AR model.  Default is none.
% ArOrder = order of model.  Default is 1.
%
% OUTPUTS 
% y = filtered data
% A = autoregressive model used
%
% Andres calls it as follows: WhitenSignalIn(rawEeg{i},eegFS*2000,1)
% Copied and some comments by Brendon Watson 2014

%artype =2; %Signal processing toolbox
artype =1; %arfit toolbox, (crashes sometimes with old version and single data type)

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
        A = ARmodel;%even if no model input to the function, after the first loop below there will be a model that will be perpetuated
        for i=1:nCh
            y(seg(j,1):seg(j,2),i) = Filter0In(A, x(seg(j,1):seg(j,2),i));
        end
    else
        if CommonAR % meaning common model for all channels and segments!!! ... this is default
            for i=1:nCh
                if  j==1 & i==1
                    switch artype
                        case 1
                            [w Atmp] = arfitIn(x(seg(j,1):seg(j,2),i),ArOrder,ArOrder);%default
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

end


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
end

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
end

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

end



% y = Filter0(b, x)
%
% filters x with a fir filter so it has zero phase, i.e. shifts the
% filtered signal to the right half of the length of b.
%
% for now it zero pads the original signal
% later it might also do reflecton boundary conditions.
%
% be careful about the order of b!
% for even filters it is not exact  (change of Anton)
% - tired that even filterss dont' work


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

end