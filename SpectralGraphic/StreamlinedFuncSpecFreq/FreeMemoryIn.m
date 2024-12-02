% computes the available memory in bytes
function HowMuch = FreeMemoryIn
if isunix
	[junk mem] = unix('vmstat |tail -1|awk ''{print $4} {print $6}''');
	HowMuch = sum(mem);
else
	HowMuch = 200;
	%200Mb for windows machin
	
end
end