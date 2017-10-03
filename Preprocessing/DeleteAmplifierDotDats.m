function DeleteAmplifierDotDats(basepath)

if ~exist('basepath','var')
    basepath = cd;
elseif isempty(basepath)
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);

if ~exist(fullfile(basepath,[basename '.dat']),'file')
    return
end
d = dir(fullfile(basepath,[basename '.dat']));
datbytes = d(1).bytes;
if datbytes == 0;
    disp([basename '.dat is zero bytes'])
    return
end

ampbytes = 0;
d = dir(fullfile(basepath));
for didx = 1:length(d)
    if d(didx).isdir
        ad = dir(fullfile(basepath,d(didx).name,'amplifier.dat'));
        if ~isempty(ad)
            ampbytes = ampbytes + ad(1).bytes; 
        end
    end
end

if datbytes == ampbytes
    rmstr = ['! rm -r ' fullfile(basepath,'*','amplifier.dat')];
    eval(rmstr);
end