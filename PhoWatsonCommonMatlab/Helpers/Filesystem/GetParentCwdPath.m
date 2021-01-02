function fullpath = GetParentCwdPath()
%GETPARENTCWDPATH Gets the path for the folder above the current working directory folder
	mydir  = pwd;
	idcs   = strfind(mydir,filesep);
	fullpath = mydir(1:idcs(end)-1);
end

