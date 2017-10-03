function spkgroupnums = matchSpkGroupsToAnatGroups(par)
% find the original number of the shank, even if a shank was removed -
% using matches to anat group numbers.  Without this elec groups are just
% named in sequence regardless of skips of actual shanks.  Assumes 1:1
% matching of channels to groups

nanat = length(par.AnatGrps);
nspk = par.nElecGps;
spkgroupnums = zeros(nspk,1);
anatfirsts = zeros(nanat,1); %make a list of the first chan of each anat group

for a = 1:nspk
   spkchans = par.SpkGrps(a).Channels;
   for b = 1:nanat
       lia = ismember(par.AnatGrps(b).Channels,par.SpkGrps(a).Channels);
       if any(lia)
%            lia;
           spkgroupnums(a) = b;
           continue
       end
   end
end
1;
