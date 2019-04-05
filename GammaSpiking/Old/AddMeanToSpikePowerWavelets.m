function AddMeanToSpikePowerWavelets(basepath,basename)
% I think this is a helper for 
if ~exist('basepath','var')
    [~,basename] = fileparts(cd);
    basepath = cd;
end

fname = fullfile(basepath,[basename,'_WaveletForSpikePower.mat']);
names = MatVariableList(fname);

denom = 0;
for a = 1:length(names)
    if strcmp(names{a}(1:5),'ampCh');
        disp(names{a})
        load(fname,names{a})
        if ~exist('ChannelMean','var')
            eval(['ChannelMean = ' names{a} ';'])
        else
            eval(['ChannelMean = ChannelMean +' names{a} ';'])            
        end
        eval(['clear ' names{a}])
        denom = denom+1;
    end
end

ChannelMean = ChannelMean/denom;

save(fullfile(basepath,[basename,'_WaveletForSpikePower.mat']),'ChannelMean','-append')