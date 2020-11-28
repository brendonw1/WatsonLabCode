function ShankAnatomyList = ShankAnatomies(basepath,basename)
% uses xml: channels per spike group and _SpikeGroupAnatomy.csv to assign 
% anatomical locations to each channel

tx = read_mixed_csv(fullfile(basepath,[basename '_SpikeGroupAnatomy.csv']),',');
bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));

counter = 0;
for a = 1:size(tx,1)
    if prod(isstrprop(tx{a,1},'digit'))
        counter = counter+1;
        shanknum = str2num(tx{a,1});
        shankanat = tx{a,2};
       
        ShankAnatomyList(counter).ShankNumber = shanknum;
        ShankAnatomyList(counter).ShankAnatomy = shankanat;
    end
end
1;