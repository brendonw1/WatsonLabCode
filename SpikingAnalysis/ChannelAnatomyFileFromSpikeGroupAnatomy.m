function ChannelAnatomyFileFromSpikeGroupAnatomy(basename)
% uses xml: channels per spike group and _SpikeGroupAnatomy.csv to assign 
% anatomical locations to each channel

tx = read_mixed_csv([basename '_SpikeGroupAnatomy.csv'],',');
Par = LoadPar([basename '.xml']);

totalchannels = Par.nChannels;

outputmtx = cell(totalchannels,2);
for a = 1:totalchannels
   outputmtx{a,1} = a;
end


% numgrps = length(Par.AnatGrps)-1;
numgrps = size(tx,1)-1;
for a = 1:numgrps
    try
        thisanat = tx{a+1,2};
        chs = Par.SpkGrps(a).Channels;
        for b = 1:length(chs)
           outputmtx{chs(b)+1,2} = thisanat;
        end
    end
end

cell2csv([basename '_ChannelAnatomy.csv'],outputmtx)