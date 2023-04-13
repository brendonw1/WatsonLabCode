if ~exist('rat','var')
    rat = '413';
end

DavidGetSpikes;

UIDs = 1:length(allspikecells);
pE = ones(1,length(UIDs));
pI = zeros(1,length(UIDs));

if strcmp(rat,'Quiksilver')
    pE(13) = 0;
    pI(13) = 1;
end


CellClass = struct('UID',UIDs,'pE',pE,'pI',pI);