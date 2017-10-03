function [lin_binbounds,log_binbounds] = GetBinBounds(distros,numbins)
% function [lin_bincenters,log_binlocations] = GetBinCenters(distros,numbins)
% Distros are a cell array of vectors, each vector represents a separate
% dataset to get centers of bins for.  Bin centers are gotten using simple
% linspace and logspace to generate linearly and logarithmically spaced
% sets of bins.  Outputs lin_bincenters and log_bincenters are each cell
% arrays, one vector in each corresponding to the same number of vectors
% given in the distros array.
%
% Brendon Watson 2015

if ~exist('numbins','var')
    flexiblenum = 1;
    numbins = 25;
else
    flexiblenum = 0;
end

switch class(distros)
    case 'double'
        numdistros = 1;
        distros = {distros};
end
numdistros = length(distros);
        
for a=1:numdistros;
    thisset = distros{a};
%     columncount = (a-1)*2+1;
    
    %% Linear
    if flexiblenum
        tnumbins = max(numbins,length(thisset)/2);
    else
        tnumbins = numbins;
    end
    
    lin_binbounds{a} = linspace(min(thisset),max(thisset),tnumbins);
    %% Log
    minbin = log10(min(thisset));
    if minbin == -Inf || ~isreal(minbin)
        minbin = log10(min(thisset(thisset>0)));
    end
    log_binbounds{a} = logspace(minbin,log10(max(thisset)),tnumbins);
end