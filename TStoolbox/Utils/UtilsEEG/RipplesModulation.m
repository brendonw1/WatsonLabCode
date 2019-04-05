function A = truc(A);

A = getResource(A,'MidRipS1SWS')
A = getResource(A,'MidRipS2SWS')
A = getResource(A,'SpikeData')
nbC = length(S);


t1_1 = Range(midRipS1SWS{1});
t1_2 = Range(midRipS2SWS{1});

t2_1 = Range(midRipS1SWS{2});
t2_2 = Range(midRipS2SWS{2});

nb1 = length(t1_1)+length(t1_2);
nb2 = length(t2_1)+length(t2_2);

if nb1>nb2

	t1 = t1_1;
	t2 = t1_2;

else

	t1 = t2_1;
	t2 = t2_2;

end

A = registerResource(A, 'RatioRip', 'numeric', {[], []}, ...
    'ratioRip', ...
    ['ratio of firing rate between ripples and control']);

A = registerResource(A, 'ProbaRip', 'numeric', {[], []}, ...
    'probaRip', ...
    ['probability of NULL hypothesis = {firing rate doens t change between ripples and control}']);

A = registerResource(A, 'RatioRipS1', 'numeric', {[], []}, ...
    'ratioRipS1', ...
    ['ratio of firing rate between ripples and control']);

A = registerResource(A, 'RatioRipS2', 'numeric', {[], []}, ...
    'ratioRipS2', ...
    ['ratio of firing rate between ripples and control']);

A = registerResource(A, 'ProbaRipS1', 'numeric', {[], []}, ...
    'probaRipS1', ...
    ['probability of NULL hypothesis = {firing rate doens t change between ripples and control}']);

A = registerResource(A, 'ProbaRipS2', 'numeric', {[], []}, ...
    'probaRipS2', ...
    ['probability of NULL hypothesis = {firing rate doens t change between ripples and control}']);


t = [t1;t2];

ripInt1 = intervalSet(t1-250,t1+250);
ripInt2 = intervalSet(t2-250,t2+250);
ripInt = intervalSet(t-250,t+250);

ripCtl1 = intervalSet(t1-10000,t1-500);
ripCtl2 = intervalSet(t2-10000,t2-500);
ripCtl = intervalSet(t-10000,t-500);

ratioRipS1 = zeros(nbC,1);
ratioRipS2 = zeros(nbC,1);
ratioRip = zeros(nbC,1);

probaRipS1 = zeros(nbC,1);
probaRipS2 = zeros(nbC,1);
probaRip = zeros(nbC,1);

percentMin = 0.1; %sfn abstract : 0.05

for i=1:nbC

	ripRate1 = Data(intervalRate2(S{i},ripInt1));
	ripRate2 = Data(intervalRate2(S{i},ripInt2));
	ripRate = Data(intervalRate2(S{i},ripInt));

	noRipRate1 = Data(intervalRate2(S{i},ripCtl1));
	noRipRate2 = Data(intervalRate2(S{i},ripCtl2));
	noRipRate = Data(intervalRate2(S{i},ripCtl));

	n1 = length(t1);
	n2 = length(t2);
	n = length(t);

	if (sum(ripRate1>0)>percentMin*n1) & (sum(noRipRate1>0)>percentMin*n1)

		mRip1 = mean(ripRate1);
		mCtl1 = mean(noRipRate1);
		if mCtl1==0, mCtl1=1;end
		ratioRipS1(i) = mRip1/mCtl1;
		
		[H,P] = ttest(ripRate1,noRipRate1);
		probaRipS1(i) = P;

	else
		
		ratioRipS1(i) = 0;
		probaRipS1(i) = 1;

	end

	if (sum(ripRate2>0)>percentMin*n2) & (sum(noRipRate2>0)>percentMin*n2)

		mRip2 = mean(ripRate2);
		mCtl2 = mean(noRipRate2);
		if mCtl2==0, mCtl2=1;end
		ratioRipS2(i) = mRip2/mCtl2;
		
		[H,P] = ttest(ripRate2,noRipRate2);
		probaRipS2(i) = P;

	else
		ratioRipS2(i) = 0;
		probaRipS2(i) = 1;

	end

	if (sum(ripRate>0)>percentMin*n) & (sum(noRipRate>0)>percentMin*n)

		mRip = mean(ripRate);
		mCtl = mean(noRipRate);
		if mCtl==0, mCtl=1;end
		ratioRip(i) = mRip/mCtl;
		
		[H,P] = ttest(ripRate,noRipRate);
		probaRip(i) = P;

	else
		ratioRip(i) = 0;
		probaRip(i) = 1;

	end

end

length(find(probaRipS1<0.05))
length(find(probaRipS2<0.05))

A = saveAllResources(A);


