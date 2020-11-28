function out = CellRateCountsBySWSEpisode(c,fn)

numep = c.numWSWEpisodes;

eval(['numcells = size(c.' fn ',1)/numep;'])

out = {};
for a = 1:numep
    eval(['out{a} = c.' fn '((((a-1)*numcells)+1):a*numcells);'])
end