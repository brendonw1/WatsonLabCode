function A = truc(A)

A = getResource(A,'SpkShape');
A = registerResource(A,'NpWidth','numeric',{[],1},'npWidth','hyperpolarisation length');

[p,ds,e] = fileparts(current_dir(A));


npWidth = [];

for i=1:length(spkShape)

	try
	
		%Positive peak width
		thresV = 0.2;
	
		spk = spkShape{i};
		wu = Data(spk);
		wu = wu-wu(1);
		tu = Range(spk);
		dt = median(diff(tu));

		[m,maxPos] = max(wu);
		waveTail = wu(maxPos+1:end);
		[d minPos] = min(waveTail);

		minPos = minPos+maxPos;

		if d < 0

			spk = tsd([tu;tu(end)+dt]*10,[wu;0]/d);
		
			tint = thresholdIntervals(spk,thresV);
			ix = find(End(tint,'ms')-tu(minPos)>0 & Start(tint,'ms')-tu(minPos)<0);
			tint = subset(tint,ix);

			lowIx = find(round(10000*Start(tint,'ms'))==round(10000*tu));
			highIx = find(round(10000*End(tint,'ms'))==round(10000*tu))-1;

			%   ...linear regression to find half crossing time
			t1 = tu(lowIx-1);
			t2 = tu(lowIx);
		;	y1 = wu(lowIx-1);
			y2 = wu(lowIx);
			tLow = (t2 - t1)/(y2 - y1)*(thresV - y1) + t1; 
		
			if highIx<length(tu)
	
				t1 = tu(highIx);
				t2 = tu(highIx+1);
				y1 = wu(highIx);
				y2 = wu(highIx+1);
				tHigh = (t2 - t1)/(y2 - y1)*(thresV - y1) + t1; 
			else
				tHigh = tu(end);
			end
	%  		display(c)
	%  		display(tHigh-tLow)
	
			npWidth = [npWidth;tHigh-tLow];
	
		else
			display(['no negative min']);
			npWidth = [npWidth;0];
		end
	
	catch
		warning(['error, peak put at 0 : ' lasterr]);
	end
end


A = saveAllResources(A);

