function A = truc(A)

[p,ds,e] = fileparts(current_dir(A));

for i=1:1

	try
		SpikeWidth(ds,i,current_dir(A));
	catch
		warning(['No ith TT on that day'];
	end

end

