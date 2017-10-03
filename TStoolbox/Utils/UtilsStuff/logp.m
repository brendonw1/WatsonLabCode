function b=logp(a)

% Perform the sum p*log(p) taking into accout the limit p.log(p)=0 when p vanishes.


for i=1:length(a)
	
	if a(i)==0
		b(i)=0;
	else
		b(i) = a(i)*log(a(i));
	end

end
