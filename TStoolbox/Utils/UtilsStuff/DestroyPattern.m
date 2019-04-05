function SO = DestroyPattern(S,binSize,varargin)

%  SO = DestroyPattern(ts,binSize,epoch) returns a ts object SO whose timestamps in the intervalSet epoch are shuffled in bins of size *binSize* 
%  INPUT:
%  S : a ts object or a tsdArray
%  binSize : size of the bins which will be shuffled
%  optionnal:
%  epoch : the intervalSet in which the shuffling has to take place.
%  
%  OUTPUT :
%  a ts object or a tsdArray 
%  
%  
%  Adrien Peyrache 2007


if length(varargin) == 1
	if isa(varargin{1},'intervalSet')
		epoch = varargin{1};
	else
		warning('argument must be an intervalSet, not taken into account')
	end
elseif length(varargin)>1
	warning('too many arguments!!')
else
	epoch = intervalSet(min(Start(S)),max(End(S)));

end


st = Start(epoch);
en = End(epoch);
reginter = regular_interval(st(1),en(end),binSize);


if isa(S,'tsdArray')

	SO = {};

	for i=1:length(S)
		SO = [SO;{destroy(S{i},binSize,reginter)}];
	end

	SO = tsdArray(SO);

else

	SO = destroy(S,binSize,epoch);

end

end

function SO = destroy(S,binSize,reginter)

	st0 = Start(reginter);
	en0 = End(reginter);
	
	permVect = randperm(length(st0));
	rg = Range(S);
	rgN = [];
	
	for i=1:length(st0)
		ix = find(rg>=st0(i) & rg<en0(i));
		rgN = [rgN;rg(ix)+st0(permVect(i))-st0(i)];
	end
	
	SO = ts(sort(rgN));

end
	


