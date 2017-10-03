function shanks = getShanksFromThisChannelAnatomy(channel,basename)

% get anatomy of this channel
cha = read_mixed_csv([basename '_ChannelAnatomy.csv'],',');
for a = 1:size(cha,1)
    tch = str2num(cha{a,1});
    if tch == channel
        anat = cha{a,2};
        break
    end
end


% get shanks wtih that same anatomy
shanks = [];
sga = read_mixed_csv([basename '_SpikeGroupAnatomy.csv'],',');
for a = 1:size(sga,1)
    tsga = sga{a,2};
    if strcmp(tsga,anat)
        shanks(end+1) = str2num(sga{a,1});
    end
end

% confine S to those clus from the shanks with the proper anatomy


