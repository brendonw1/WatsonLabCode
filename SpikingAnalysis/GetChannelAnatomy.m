function anat = GetChannelAnatomy(basename,channel)

tx = read_mixed_csv([basename '_ChannelAnatomy.csv'],',');

for a = 1:size(tx,1)
    tch = tx{a,1};
    if ~isempty(tch);
        tch = str2num(tch);
        if ~isempty(tch);
            if tch == channel
                anat = tx{a,2};
                continue
            end
        end
    end
end
