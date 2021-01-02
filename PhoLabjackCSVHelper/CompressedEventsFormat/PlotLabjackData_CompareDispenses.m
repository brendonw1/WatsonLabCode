function fighandles = PlotLabjackData_CompareDispenses(Data,binningtime)


% Loads the compressed.mat events and plots them

% %% setting paths for function 
% thisfuncpath = mfilename('fullpath');
% tpath1 = fileparts(thisfuncpath);
% tpath2 = fileparts(tpath1);
% addpath(genpath(fullfile(tpath2,'HelperFunctions')));
% addpath(genpath(fullfile(tpath2,'CompressedEventsFormat')));
% 
% %% Parsing inputs
% if ~exist('CompressedFilePath','var')
% 	[cfile,cpath] = uigetfile;
% 	CompressedFilePath = fullfile(cpath,cfile);
% end
% 
% %% Grab data
% % load('Output/compressed-out_file_1545.mat', 'OutputDeltasTimestamps')
% load(CompressedFilePath)
% %load('Output/compressed-newest.mat', 'OutputDeltasTimestamps')

if ~exist('binningtime','var')
    binningtime = 'daily';
end

DataList = {'Regular_Water','Sucrose_Water','Regular_Food','Fatty_Food'};
TypeList = {'BeamBreak','Dispense'};
DataLabels = fieldnames(Data(1).DeltaIdxs);

for a = 1:length(Data) % for each box
    tfn = fieldnames(Data(a).DeltaIdxs);
%     for b = 1:length(varNames)
%         us = strfind(varNames{b},'_');
%         varNames{b} = varNames{b}(1:us(2)-1);
%     end
    DataTimeTable = CompressedEvents2Timetable(Data(a).DeltaIdxs, Data(a).DeltaTimestamps,tfn);
    
   

    % binnedEventsTimetable = retime(labjackTimeTable,'hourly','sum','IncludedEdge','right');
    % [fig, axH] = PlotBinnedEventsTimetable(binnedEventsTimetable, 'Port Events: binned hourly');

    % binnedEventsTimetable = retime(labjackTimeTable,'daily','sum','IncludedEdge','right');
    binnedEventsTimetable = retime(DataTimeTable,binningtime,'sum');
    % [fig, axH] = PlotBinnedEventsTimetable(binnedEventsTimetable, 'Port Events: binned daily');
    dataonlyEventsTimetable = binnedEventsTimetable.Variables;

    %% Multi-Event Bar Plot Figure
    graphProperties.figname = ['BB' Data(a).BBName 'RegularVSSucroseFatty'];
    graphProperties.sgtitle = ['BB' Data(a).BBName ': Port Events: Binned Daily'];
    
    graphColors.regular = 'g';
    graphColors.sucrosefatty = [.7 .7 .7];
    maxBeamBreakCount = max(binnedEventsTimetable{:,1:4},[],'all');
    maxDispenseCount = max(binnedEventsTimetable{:,5:8},[],'all');
    globalMaxCount = max(maxBeamBreakCount,maxDispenseCount);
    graphProperties.yAxisMaxCount = globalMaxCount * 1.2;
    graphProperties.verticalLabelAlignment = 'bottom';
    graphProperties.regular.labels.shouldShow = false;
    graphProperties.sucrosefatty.labels.shouldShow = false;

    graphProperties.shouldShowEvents = true;

    graphProperties.legend.location = 'northwest';
    graphProperties.legend.orientation = 'vertical';

    dateTimes = binnedEventsTimetable.dateTime;
    dayIntoExperiment = 1:length(dateTimes);
    % xVariable = dateTimes;
    xVariable = dayIntoExperiment;

    %make figure
    fighandles(a) = figure('position',[560 100 1100 850],'name',graphProperties.figname);    
    clf
    
    %% Make axes
    % Water: Regular vs Sucrose
    axH(1) = subplot(2,1,1);
    matchidx = finddatamatchingname(tfn,'Regular_Wa','pense');%find column with desired data
    tdata = dataonlyEventsTimetable(:,matchidx);%grab data
    bar(xVariable, tdata,graphColors.regular);%barplot in blue
    if graphProperties.regular.labels.shouldShow%if showing single-bar data as text above bars
        text(1:length(tdata),tdata,num2str(tdata),'vert',graphProperties.verticalLabelAlignment,'horiz','center','color',graphColors.regular);
    end
    box off
    hold on;
    matchidx = finddatamatchingname(tfn,'Sucrose_Wa','pense');%find column with desired data    
    tdata = dataonlyEventsTimetable(:,matchidx);
    bar(xVariable, tdata,'facecolor',graphColors.sucrosefatty,'facealpha',0.4);
    ylabel('Water');
    % ylim([0,graphProperties.yAxisMaxCount]);
    if graphProperties.sucrosefatty.labels.shouldShow
        text(1:length(tdata),tdata,num2str(tdata),'vert',graphProperties.verticalLabelAlignment,'horiz','center','color',graphColors.dispense);
    end
    if graphProperties.shouldShowEvents
%        xline(15,'-',{'Lifted Water' 'Ports'});
%        xline(22,'-',{'Changed to' 'Sucrose Water'}); 
    end
    legend({'Regular','Sucrose'},'Location',graphProperties.legend.location,'Orientation',graphProperties.legend.orientation)

    %Food: Regular vs Fatty
    axH(2) = subplot(2,1,2);
    matchidx = finddatamatchingname(tfn,'Regular_Fo','pense');%find column with desired data
    tdata = dataonlyEventsTimetable(:,matchidx);%grab data
    bar(xVariable, tdata,graphColors.regular);%barplot in blue
    if graphProperties.regular.labels.shouldShow%if showing single-bar data as text above bars
        text(1:length(tdata),tdata,num2str(tdata),'vert',graphProperties.verticalLabelAlignment,'horiz','center','color',graphColors.regular);
    end
    box off
    hold on;
    matchidx = finddatamatchingname(tfn,'Fatty_Food','pense');%find column with desired data    
    tdata = dataonlyEventsTimetable(:,matchidx);
    bar(xVariable, tdata,'facecolor',graphColors.sucrosefatty,'facealpha',0.4);
    ylabel('Water');
    % ylim([0,graphProperties.yAxisMaxCount]);
    if graphProperties.sucrosefatty.labels.shouldShow
        text(1:length(tdata),tdata,num2str(tdata),'vert',graphProperties.verticalLabelAlignment,'horiz','center','color',graphColors.dispense);
    end
    if graphProperties.shouldShowEvents
%        xline(15,'-',{'Lifted Water' 'Ports'});
%        xline(22,'-',{'Changed to' 'Sucrose Water'}); 
    end
    legend({'Regular','Fatty'},'Location',graphProperties.legend.location,'Orientation',graphProperties.legend.orientation)


    sgtitle(graphProperties.sgtitle)
end
%% Annotations
% June 19, 2019: Day we added the elevated ports
% 6-26-2019: Added sugar water around noon. 
% More reasonable to cluster over night instead of from midnight to midnight.


function matchidx = finddatamatchingname(tfn,earlytext10,latetext5)
earlymatch = zeros(1,length(tfn));
latematch = zeros(1,length(tfn));
for b = 1:length(tfn)
    earlymatch(b) = strcmp(earlytext10,tfn{b}(1:10));
    latematch(b) = strcmp(latetext5,tfn{b}(end-4:end));
end
matchidx = find(earlymatch & latematch);
