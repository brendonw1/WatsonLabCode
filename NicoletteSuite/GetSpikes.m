%%just run the script to load in the spikes and spit it out in the form of
%%allspikecells

if ~exist('rat','var')
    rat = 'Professor X';
end

if ~exist('allspikecells','var')
    cd(['Z:/Dayvihd/',rat,'/Spikes']) %This only has the spikes in it
    directory = dir('*.csv');
    allspikecells = {};
    for i = 1:length(directory)
        allspikecells{i} = readtable(directory(i).name);
    end

    for i=1:length(allspikecells)
        allspikecells{i} = table2array(allspikecells{i})';
    end
end