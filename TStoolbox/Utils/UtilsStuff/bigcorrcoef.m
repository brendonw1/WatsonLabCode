function C = bigcorrcoef(X)

% Completly useless!!

maxL = 10000;
nbV = size(X,2);
n = size(X,1);
nbT = ceil(n/maxL);
C = zeros(nbV,nbV);

for i=1:nbV

%  	display(i)
	v1 = full(X(:,i));
	m1 = mean(v1);
	s1 = std(v1);
%  	keyboard
%  	display(s1)

	for j=i+1:nbV

		v2 = full(X(:,j));
		m2 = mean(v2);
		s2 = std(v2);
		val = 0;	
%  		keyboard
%  		display(s2)

		val = (v1-m1)'*(v2-m2)/((n-1)*s1*s2);
%  		keyboard

%  		for x=1:nbT
%  		
%  			if x<nbT
%  				val = val + (v1((x-1)*maxL+1:x*maxL)-m1)'*(v2((x-1)*maxL+1:x*maxL)-m2);
%  			else
%  				val = val + (v1((x-1)*maxL+1:end)-m1)'*(v2((x-1)*maxL+1:end)-m2);
%  			end
%  		
%  			val = val/(s1*s2);
%  %  			keyboard
%  		end

	C(i,j) = val;
	C(j,i) = val;	

	end

end

C(find(eye(size(C)))) = 1;
