function s = stdFromPdf(X,P)

%  s = stdFromPdf(X,pdf) computes the std of the distribution given by the pdf P
%  over the vector of data X
%  
%  example: 
%  X = [-5:5];
%  pdf = 1/sqrt(2*pi) * exp(-(X.^2)/2);
%  s = stdFromPdf(X,pdf)
%  
%  gives:
%  
%  s =
%  
%      1.0000
%  
% as expected for this normal distribution
% Adrien Peyrache 2007


a = size(X);
[n,ix] = max(a);



if ix > 2
	error('X must be a vector')
elseif ix==1
	if size(X,2)>1
		error('X must be a vector')
	end
	
	X = X';
	P = P';
end;

n = length(X);
P=P./(sum(P));

mu = X*P';
s = ((X-mu).*(X-mu))*P';

%  keyboard


