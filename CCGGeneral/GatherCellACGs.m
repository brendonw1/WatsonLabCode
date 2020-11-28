function GatherCellACGs(basepath,basename)

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

f = load(fullfile(basepath,[basename '_funcsynapsesMoreStringent']));
mtx = f.funcsynapses.fullRawCCGMtx;

for a = 1:size(mtx,2)
   acgs(:,a) = mtx(:,a,a); 
end
BinMs = f.funcsynapses.BinMs;
TotalWidthMs = BinMs*(size(acgs,1));
HalfWidth = BinMs*(size(acgs,1)-1)/2;

ACGData = v2struct(acgs,BinMs,TotalWidthMs,HalfWidth);

save(fullfile(basepath,[basename, '_ACGData']),'ACGData');
