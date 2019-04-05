%to this one should add:
% in processingHomeDir
% make xml which is just hipass (and pms)
% run code below
% make xml which has lopass and all other scripts active
% >> Maybe if probs with .xml, make them in standard names and have matlab cp them to the basename-01.xml sequentially


processingHomeDir = '/mnt/isis3/brendon/BWRat21_121313/BWRat21_121313_NewOriginalProc_pms/';
basename = 'BWRat21_121313';
refChan{1} = 1:48;
refChan{2} = 49:58;

cd(processingHomeDir)
d = dir(fullfile(processingHomeDir,[basename,'-*']));%looking for dirs with basename and "-"

for a = 1:length(d);
    thisdir = d(a).name;
%     cd(thisdir);
    filname = [thisdir,'.fil'];
    filpath = fullfile(processingHomeDir,thisdir,filname);
    par = LoadPar(filpath(1:end-4),'.xml');
    
    for b = 1:size(refChan,2);
        disp(['working on ' filname ': group ' num2str(b) ' of ' num2str(size(refChan,2))])
        [returnVar,msg] = ReRefFilFile(filpath,par.nChannels,refChan{b},refChan{b})%displayed on purpose
    end
end