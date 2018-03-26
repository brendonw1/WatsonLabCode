function MakeLFPs_OneSession(dirpath)
%assumes you are in or pointed to a subdirectory for a single session

goalLFPSampFreq = 1250;

% basic session name and and path
if ~exist('dirpath','var')
    dirpath = cd;
end

[~,basename] = fileparts(dirpath);

datname = fullfile(dirpath,[basename,'.dat']);
if ~exist(datname,'file')
    disp([basename ': no ' basename '.dat found, skipping recording'])
else
    eegname = fullfile(dirpath,[basename,'.lfp']);
    if ~exist(eegname,'file')
        xmlname = fullfile(dirpath,[basename,'.xml']);
        par = bz_getSessionInfo(xmlname);
        DatSampFreq = par.rates.wideband;
        numerator = 1;
        denominator = DatSampFreq/goalLFPSampFreq;
        ResampleBinary(datname,eegname,par.nChannels,numerator,denominator)
    end
end
    
    