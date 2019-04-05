function DOF = DOF(Q,pc)

n=size(Q,2).^2;
m = size(Q,1);

pc2 = pc*pc';
pc2 = pc2(:);

S = zeros(m,1);

for j=1:m
	b = Q(j,:);
	b = b'*b;
	b = b-diag(diag(b));
	xj = b(:).*pc2;
	S(j) = 1/(n-1)*sum((xj-mean(xj)).^2);
end

DOF = sum(S).^2/(sum(S.^2/(n-1)));

%  keyboard
