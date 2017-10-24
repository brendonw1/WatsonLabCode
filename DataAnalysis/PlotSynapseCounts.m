function PlotSynapseCounts(SynCounts)

eetot = (SynCounts.EECnxns+SynCounts.EELikeCnxns);
eitot = (SynCounts.EICnxns+SynCounts.EILikeCnxns);
ietot = (SynCounts.IECnxns+SynCounts.IELikeCnxns);
iitot = (SynCounts.IICnxns+SynCounts.IILikeCnxns);

treestruct = [0 1 2 2 3 3 5 5 6 6 4 4 11 11 12 12];
s = {[' Pairs - ' num2str(SynCounts.TotalPairsCompared)],...
    ['  Cnxns - ' num2str(SynCounts.Cnxns)],...
    ['   E - ' num2str(SynCounts.ECnxns)],...
    ['  I - ' num2str(SynCounts.ICnxns)],...
    [' EE - ' num2str(eetot)],...
    [' EI - ' num2str(eitot)],...
    [' EEd - ' num2str(SynCounts.EECnxns)],...
    [' EEp - ' num2str(SynCounts.EELikeCnxns)],...
    [' EId - ' num2str(SynCounts.EICnxns)],...
    [' EIp - ' num2str(SynCounts.EILikeCnxns)],...
    ['   IE - ' num2str(ietot)],...
    ['  II - ' num2str(iitot)],...
    ['  IEd - ' num2str(SynCounts.IECnxns)],...
    ['  IEp - ' num2str(SynCounts.IELikeCnxns)],...
    ['  IId - ' num2str(SynCounts.IICnxns)],...
    ['  IIp - ' num2str(SynCounts.IILikeCnxns)]};

figure
[x,y] = treeplot_bw(treestruct,'.k','k',s);


cnxnsPpairs = num2str(100* SynCounts.Cnxns / SynCounts.TotalPairsCompared,'%2.0f');
ePcnxns = num2str(100* SynCounts.ECnxns/SynCounts.Cnxns,'%2.0f');
iPcnxns = num2str(100* SynCounts.ICnxns/SynCounts.Cnxns,'%2.0f');

eePEcnxns = num2str(100* eetot/SynCounts.ECnxns,'%2.0f');
eePcnxns = num2str(100* eetot/SynCounts.Cnxns,'%2.0f');
eiPEcnxns = num2str(100* eitot/SynCounts.ECnxns,'%2.0f');
eiPcnxns = num2str(100* eitot/SynCounts.Cnxns,'%2.0f');
iePIcnxns = num2str(100* ietot/SynCounts.ICnxns,'%2.0f');
iePcnxns = num2str(100* ietot/SynCounts.Cnxns,'%2.0f');
iiPIcnxns = num2str(100* iitot/SynCounts.ICnxns,'%2.0f');
iiPcnxns = num2str(100* iitot/SynCounts.Cnxns,'%2.0f');

eedPEEcnxns = num2str(100* SynCounts.EECnxns/eetot,'%2.0f');
eedPcnxns = num2str(100* SynCounts.EECnxns/SynCounts.Cnxns,'%2.0f');
eepPEEcnxns = num2str(100* SynCounts.EELikeCnxns/eetot,'%2.0f');
eepPcnxns = num2str(100* SynCounts.EELikeCnxns/SynCounts.Cnxns,'%2.0f');
eidPEIcnxns = num2str(100* SynCounts.EICnxns/eitot,'%2.0f');
eidPcnxns = num2str(100* SynCounts.EICnxns/SynCounts.Cnxns,'%2.0f');
eipPEIcnxns = num2str(100* SynCounts.EILikeCnxns/eitot,'%2.0f');
eipPcnxns = num2str(100* SynCounts.EILikeCnxns/SynCounts.Cnxns,'%2.0f');
iedPIEcnxns = num2str(100* SynCounts.IECnxns/ietot,'%2.0f');
iedPcnxns = num2str(100* SynCounts.IECnxns/SynCounts.Cnxns,'%2.0f');
iepPIEcnxns = num2str(100* SynCounts.IELikeCnxns/ietot,'%2.0f');
iepPcnxns = num2str(100* SynCounts.IELikeCnxns/SynCounts.Cnxns,'%2.0f');
iidPIIcnxns = num2str(100* SynCounts.IICnxns/iitot,'%2.0f');
iidPcnxns = num2str(100* SynCounts.IICnxns/SynCounts.Cnxns,'%2.0f');
iipPIIcnxns = num2str(100* SynCounts.IILikeCnxns/iitot,'%2.0f');
iipPcnxns = num2str(100* SynCounts.IILikeCnxns/SynCounts.Cnxns,'%2.0f');


s2= {[' Pairs - ' num2str(SynCounts.TotalPairsCompared)],...
    ['  Cnxns - ' cnxnsPpairs '%'],...
    ['   E - ' ePcnxns '%'],...
    ['  I - ' iPcnxns '%'],...
    [' EE - ' eePEcnxns '%(' eePcnxns '%)'],...
    [' EI - ' eiPEcnxns '%(' eiPcnxns '%)'],...
    [' EEd - ' eedPEEcnxns '%(' eedPcnxns '%)'],...
    [' EEp - ' eepPEEcnxns '%(' eepPcnxns '%)'],...
    [' EId - ' eidPEIcnxns '%(' eidPcnxns '%)'],...
    [' EIp - ' eipPEIcnxns '%(' eipPcnxns '%)'],...
    ['   IE - ' iePIcnxns '%(' iePcnxns '%)'],...
    ['  II - ' iiPIcnxns '%(' iiPcnxns '%)'],...
    ['  IEd - ' iedPIEcnxns '%(' iedPcnxns '%)'],...
    ['  IEp - ' iepPIEcnxns '%(' iepPcnxns '%)'],...
    ['  IId - ' iidPIIcnxns '%(' iidPcnxns '%)'],...
    ['  IIp - ' iipPIIcnxns '%(' iidPcnxns '%)']};

figure
[x,y] = treeplot_bw(treestruct,'.k','k',s2);