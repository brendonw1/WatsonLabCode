%EDFConversionWrapper

basefolder = '/proraid/Human/Liulab/EDF';

d = dir('*.edf');
for a = 1:length(d);
    foldernames{a} = d(a).name(1:end-4);
    mkdir(foldernames{a})
    movefile(d(a).name,fullfile(basefolder,foldernames{a},d(a).name))
end

foldernames = [];
d = getdir(basefolder);
for a = 1:length(d);
    if d(a).isdir
        foldernames{end+1} = d(a).name;
    end
end

for a = 1:length(foldernames)
    basepath = fullfile(basefolder,foldernames{a});
    basename = foldernames{a};
    cd(basepath)
    disp(basename)
    xmlname = fullfile(basepath,[basename '.xml']);
    lfpname = fullfile(basepath,[basename '.lfp']);
    
%     if ~exist(lfpname,'file')
        EDFtoLFP(foldernames{a});
        ReferenceEEGFile(basepath,basename)
%         StateEditor(basename)
%     end
    
    if ~exist(xmlname,'file')
        copyfile(fullfile(basefolder,'LiuEDFDefaultXml.xml'),xmlname)
    end
end
