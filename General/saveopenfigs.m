% saveopenfigs

figs = findobj('type','fig');
for fidx = 1:length(figs)
    name = get(figs(fidx),'name');
    hgsave(figs(fidx),[name,'.fig']);
end