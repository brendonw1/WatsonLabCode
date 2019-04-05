function SWSSpectra = GatherAlpostinSWSSpectra(ep1name)

if ~exist('ep1name','var')
    ep1name = 'flsws';
end

[names,dirs]=GetDefaultDataset;

SWSSpectra.basenames = {};
SWSSpectra.basepaths = {};
SWSSpectra.RatNames = {};
SWSSpectra.Anatomies = {};

% loop throug each dataset... then loop thru and store each 
counter = 0;%for accumulating stats, since I can't get states out before hand
for a = 1:length(dirs);
   %% Get basic info for record-keeping
    basename = names{a};
    basepath = dirs{a};

    cd (basepath)
    fname = fullfile(basepath,'Spectra',['SWSSpectra_' ep1name '.mat']);

    bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
    anat = GetChannelAnatomy(basename,bmd.goodeegchannel);
    slashes = strfind(basepath,'/');
    ratname = basepath(slashes(3)+1:slashes(4)-1);
    SWSSpectra.basenames{end+1} = basename;
    SWSSpectra.basepaths{end+1} = basepath;
    SWSSpectra.Anatomies{end+1} = anat;
    SWSSpectra.RatNames{end+1} = ratname;

    if exist(fname,'file')
        %% Load data for this session
        t = load(fname);
        eval(['t = t.SWSSpectra_' ep1name ';']);

        %FYI: construction command from Compare5minSWSSpectra;
        % SWS5MinSpectra = v2struct(wS,wf,intwS,sS,sf,intsS,rS,rf,intrS,f5sS,f5sf,intf5sS,l5sS,l5sf,intl5sS,standardFs);
        %% If this is first iteration, declare empty cells so can cat to them
        if a == 1;
            SWSSpectra.standardFs = t.standardFs;
            SWSSpectra.maxfreq = t.maxfreq;
            SWSSpectra.minfreq = t.minfreq;

            SWSSpectra.wspect = t.wspect;
            SWSSpectra.sspect = t.sspect;
            SWSSpectra.rspect = t.rspect;
            SWSSpectra.prespect = t.prespect;
            SWSSpectra.postspect = t.postspect;
%             eval(['SWS5MinSpectra.' ' = [];'])
        else
            SWSSpectra.wspect = cat(1,SWSSpectra.wspect,t.wspect);
            SWSSpectra.sspect = cat(1,SWSSpectra.sspect,t.sspect);
            SWSSpectra.rspect = cat(1,SWSSpectra.rspect,t.rspect);
            SWSSpectra.prespect = cat(1,SWSSpectra.prespect,t.prespect);
            SWSSpectra.postspect = cat(1,SWSSpectra.postspect,t.postspect);
        end
%         SWS.sleepspersess = 
        counter = counter+1;
        
    end
end



%
% savestr = ['UPSpindlTemplateData',date];
% 
% if ~exist('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/TemplateCorr','dir')
%     mkdir('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/TemplateCorr')
% end
% save(fullfile('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/TemplateCorr', savestr),'UPSpindlTemplateData')
