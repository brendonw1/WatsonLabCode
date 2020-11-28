function cdwithmakedir(p)

if ~exist(p,'dir')
    mkdir(p)
end

cd(p)
    