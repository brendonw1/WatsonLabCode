%% Okay. We're gonna do a lot of burstiness things... First things first,
%We're gonna be reading in the csv files. They SHOULD be listed by default
%in this place called '/analysis/Dayvihd/Burstiness Data'
burstdir = '/analysis/Dayvihd/Burstiness Data';
allbursttab = readBurstCsvs(burstdir);

%% Now here we move onto the next step. Here's where it get's a little tricky...
% So the allbursttab variable that we made in the previous step is a cell
% of tables... This is because the csv that Nicolette formats burstiness
% data in is in the form of a csv with a lot of column headers... In this
% next step, you should change which variable you want to choose to analyze
% by changing the 'type' variable
type = 'SpikesInBurst'; % Things to choose from: Start,End,Duration,SpikesInBurst,ISIinBurst, and FreqInBurst
selectedbursts = selectCol(type, allbursttab);
times = selectCol('Start', allbursttab);
ends = selectCol('End', allbursttab);

%% Great. So now we have cell of tables called selectedbursts.
% Next we can work with the table to do whatever the hell it is that we
% want!

lmao = {};
holders = {};
figure;
hold on;
for i = 1:length(selectedbursts)
    [lmao{i} holders{i}] = MouseSum(selectedbursts{1,i},times{1,i});
    plot(lmao{i})
end

boxy = cell2mat(lmao)';
figure;
boxplot(boxy);


function writexlsx(holders,selectedbursts)
    guy = {'210','413','Bane','Beast','Cyclops','Moriarty','ProfessorX','Quiksilver','Wolverine'};
    for i = 1:length(guy)
        tabtab = array2table(holders{i});
        guynames = {};
        for j = 1:length(selectedbursts{1,i})
            guynames{j} = cell2mat(selectedbursts{1,i}{1,j}.Properties.VariableNames);
        end
        tabtab.Properties.VariableNames = guynames;
        writetable(tabtab,['fack.xlsx'],'Sheet',guy{i});
    end
end


function [singlemouseburst, holdercell] = MouseSum(selectedbursts,times)
    % Aight aight just a quick explanation. I wanna make this a wrapper for
    % the simplesum function below. It's going to be used for making a
    % single mouse's burst profile if you know what I mean...
    
    holdercell = zeros(24,length(selectedbursts)); %This is gonna hold the bins of all the mouse's units probably gonna mean it acrossed units though
    for i = 1:length(selectedbursts)
        holdercell(:,i) = SimpleSum(table2array(selectedbursts{1,i}),table2array(times{1,i}));
    end
    
    singlemouseburst = median(holdercell,2);
end


function [singlecolsums] = SimpleSum(selectedbursts,times)
    % I just gotta get this done. No time to explain
    singlecolsums = [];
    for hour = 1:24
        singlecolsums(hour,1) = sum(  selectedbursts(times > ((hour - 1)*3600) & times <= (hour*3600)  ));
    end
end

function [gousebursts] = OneMouseGauss(mousetabs,weight)
    % SO this is almost like a wrapper function. It requires a cell of
    % tables called mousetabs, where each table is a single column.
    % It stores the GaussBursts into a cell that has the gaussbursts of
    % each neuron for a single mouse. Hence the name, you know? Like Gauss
    % sounds like Mouse, so like it- nevermind let's continue. I'm so
    % fucking tired right now, holy shit. Why can't I keep my goddamn eyes
    % the hell open??? Jesus Christ, man...
    
    gousebursts = {};
    for i = 1:length(mousetabs)
        arrayver = table2array(mousetabs{i});
        gousebursts{i} = GaussBursts(arrayver,weight);
    end
end

%Okay, so this function is a little weird. It basically takes in all the
%timepoints and burst weights, and creates a curve where all the bursts are
%represented as a gaussian (based on the weight...)
function [curcurve] = GaussBursts(timepoints,weight)
    curcurvex = -.5:.01:86400.5; %It is .5 appended on both sides because of just how the algorithm works...
    curcurve = zeros(1,length(curcurvex));% curcurvex only has the timestamps! This has the actual values :)
    ex = [-.5:.01:.5];
    why = exp(-10*ex.^2);
    
    for i = 1:length(timepoints(~isnan(timepoints)))
        timeind = find(abs(curcurvex - round(timepoints(i),2)) < .005);
        curcurve((timeind-50):(timeind+50)) = curcurve((timeind-50):(timeind+50)) + why;
    end
    
    plot(curcurve(1:2000))
    
end

function [selectedbursts] = selectCol(type, allbursttab)
    selectedbursts = {};
    for i = 1:length(allbursttab)
        allnames = allbursttab{i}.Properties.VariableNames;
        selectnames = {allnames{endsWith(allnames,type)}};
        subselectbursts = {};
        for j = 1:length(selectnames)
            subselectbursts{j} = allbursttab{i}(:,[selectnames{j}]);
        end
        selectedbursts{i} = subselectbursts;
    end
end


function [allbursttab] = readBurstCsvs(burstdir)
    cd(burstdir);

    files = dir('*.csv');

    allbursttab = {};
    filenames = {files.name};
    for i = 1:length(filenames)
        allbursttab{i} = readtable(filenames{i});
    end
    
    
end