%% Welcome to CoNNECT Prep! I wanted to name it Preparation C like the hemorrhoid cream,
% But I deemed that a little inappropriate... Anyways, things to change are
% the two lines in the beginning "rat" and "saveloc". Make sure that the
% rat name is correctly spelled, and make sure that the saveloc exists!
% Next, be sure to edit the binsize in the next block of code (somewhere around 
% line 30-35 or so...) make sure that you do this in SECONDS! Anyways, good
% luck my friends and fellow scientists!

%% Loading in the spike trains and making allspikecells
rat = 'Quiksilver';
saveloc = ['/analysis/Dayvihd/' rat '/ConnectTxts/WholeRec'];

% Remember that below is for Nicolette style data where all spike trains
% are stored in their individual csv files. If using buzcode format, simply
% use allspikecells = spikes.times before running this script, and it'll
% run like a DREAM, my friend... A DREAM (Hopefully... Technically
% nightmares are dreams, yeah? So no promises)
if ~exist('allspikecells','var') 
    cd(['/analysis/Dayvihd/',rat,'/Spikes']) %This only has the spikes in it
    directory = dir('*.csv');
    allspikecells = {};
    for i = 1:length(directory)
        allspikecells{i} = readtable(directory(i).name);
    end
    for i=1:length(allspikecells)
        try
        allspikecells{i} = correctTable(table2array(allspikecells{i}));
        catch
        allspikecells{i} = table2array(allspikecells{i});
        end
    end
end

%% I am going to divy up the spike trains and save them one by one
binsize = 3600*24; %bin size in seconds
savebins(binsize, allspikecells,rat,saveloc)

function makeCCG(guy)
    ccg = CCG(guy,[],'binSize',.001,'duration',.1);
    cells = length(guy);
    for i=1:cells
        for j=1:cells
            subplot(cells,cells,(i-1)*cells+j)
            plot(ccg(:,i,j));xline(51);axis tight;
        end
    end
end

function [corrected] = correctTable(cellarray)
    corrected = zeros(length(cellarray),1);
    for i = 1:length(cellarray)
        corrected(i) = str2double(cellarray{i});
    end
end

function savebins(binsize,allspikecells,rat,saveloc)
    bins = round(findmax(allspikecells) / binsize);
    for i = 1:bins
        guy = ntimeframedivy((i-1)*binsize,i*binsize,allspikecells);
        %%makeCCG(guy);
        saveConnect(guy,i*binsize,rat,saveloc)
    end
end

%This guy takes in a spikes times format cell matrix and saves it in a
%connect compatible format
function saveConnect(spikecells,time,rat,saveloc)
    cd(saveloc)%['/analysis/Dayvihd/' rat '/ConnectCsvs'])
   
    conv = [];
    for i = 1:length(spikecells)
        disp(['loading unit',int2str(i)])
        conv = [conv; num2cell(spikecells{i})];
        conv(end + 1) = {';'};
        disp('done')
    end
    
    disp('writing txt file');
    writecell(conv,[rat,'_', num2str(time),'.txt'])
end

%This is pretty much only used to find the last spike in the recording.
%It's used for measuring the effective length of the recording.
function [maxmax] = findmax(allspikecells)
    maxmax = 0;
    for i = 1:length(allspikecells)
        if max(allspikecells{i}) > maxmax
            maxmax = max(allspikecells{i});
        end
    end
end

%Function divies up a spikecell called spikes into a cell called newspikes
%that only has firing times between lowlimit and highlimit. 
function [newspikes] = ntimeframedivy(lowlimit,highlimit,spikes)
    newspikes = {};
        for k = 1:length(spikes)
            newspikes{1,k} = spikes{1,k}(spikes{1,k} >= lowlimit & spikes{1,k}<= highlimit);
        end
    %newspikes = cell2mat(newspikes);
    for k = 1:length(newspikes)
        checkmono(newspikes{k});
        newspikes{k} = newspikes{k} - lowlimit;
    end
end

function checkmono(vector)
    temp = diff(vector);
    ismonotonic = isempty(temp(temp < 0));
    if ~ismonotonic
        disp('spikes got fucked. Maybe you have more than 1 spike train')
    end
end