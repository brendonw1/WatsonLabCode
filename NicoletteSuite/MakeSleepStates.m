names = {'112','210','413','Beast','Cyclops','Moriarty','Professor X','Quiksilver','THRASH','Wolverine'};

ratinterps = {};
wakedat = zeros(10,24);
wakeintdat = zeros(10,24);
remdat = zeros(10,24);
remintdat = zeros(10,24);
nremdat = zeros(10,24);
nremintdat = zeros(10,24);
for i = 1:length(names)
    ratname = names{i};
    cd(['/analysis/Dayvihd/',ratname]);
    wakeints = table2array(readtable([cd '/' ratname ' Wake Windows.csv']));
    nremints = table2array(readtable([cd '/' ratname ' NREM Windows.csv']));
    remints = table2array(readtable([cd '/' ratname ' REM Windows.csv']));

    ints = struct('WAKEstate',wakeints,'NREMstate',nremints,'REMstate',remints);
    maxtime = max([max(wakeints) max(nremints) max(remints)]);

    hypno = makeHypno(wakeints,nremints,remints,maxtime);
    %figure;
    %imagesc(hypno);

    [wakebouts, interwake, proportionwake] = makeThree(wakeints);
    [rembouts, interrems, proportionrem] = makeThree(remints);
    [nrembouts, internrems, proportionnrem] = makeThree(nremints);

%     plotInterstate(wakebouts, interwake, proportionwake,'WAKE',ratname)
%     plotInterstate(rembouts, interrems, proportionrem,'REM',ratname)
%     plotInterstate(nrembouts, internrems, proportionnrem,'NREM',ratname)

    %plotInterstateCirc(wakeints, wakebouts, interwake, proportionwake,'WAKE',ratname)
    % commented out the line above bc I don't like how the plots look
    
    ratinterps{i,1} = spitInterpol(wakeints,wakebouts);
    ratinterps{i,2} = spitInterpol(shaveone(wakeints),interwake);
    ratinterps{i,3} = spitInterpol(nremints,nrembouts);
    ratinterps{i,4} = spitInterpol(shaveone(nremints),internrems);
    ratinterps{i,5} = spitInterpol(remints,rembouts);
    ratinterps{i,6} = spitInterpol(shaveone(remints),interrems);
    ratinterps{i,7} = names{i};
    
    [wakedat(i,:),junk] = binbyhour(nanfilter(ratinterps{i,1}));
    [wakeintdat(i,:),junk] = binbyhour(nanfilter(ratinterps{i,2}));
    [nremdat(i,:),junk] = binbyhour(nanfilter(ratinterps{i,3}));
    [nremintdat(i,:),junk] = binbyhour(nanfilter(ratinterps{i,4}));
    [remdat(i,:),junk] = binbyhour(nanfilter(ratinterps{i,5}));
    [remintdat(i,:),junk] = binbyhour(nanfilter(ratinterps{i,6}));
end

totalwakecirc = cellsum({ratinterps{:,1}});
totalinterwakecirc = cellsum({ratinterps{:,2}});
totalnremcirc = cellsum({ratinterps{:,3}});
totalinternremcirc = cellsum({ratinterps{:,4}});
totalremcirc = cellsum({ratinterps{:,5}});
totalinterremcirc = cellsum({ratinterps{:,6}});

figure;
subplot(1,3,1);
plot(totalwakecirc);
hold on
plot(totalinterwakecirc);
legend('Bout','Preceding Interval')
title('Wake')

subplot(1,3,2);
plot(totalnremcirc);
hold on
plot(totalinternremcirc);
legend('Bout','Preceding Interval')
title('NREM')

subplot(1,3,3);
plot(totalremcirc);
hold on
plot(totalinterremcirc);
legend('Bout','Preceding Interval')
title('REM')

[wakebin,larwakebin] = binbyhour(totalwakecirc);
[interwakebin,larinterwake] = binbyhour(totalinterwakecirc);
[nrembin,larnrembin] = binbyhour(totalnremcirc);
[internrembin,larinternrem] = binbyhour(totalinternremcirc);
[rembin,larrembin] = binbyhour(totalremcirc);
[interrembin,larinterrem] = binbyhour(totalinterremcirc);

% propwake = interwakebin ./ wakebin;
% propnrem = internrembin ./ nrembin;
% proprem  = interrembin  ./ rembin;

figure;
subplot(1,3,1);
bar(interwakebin,'FaceAlpha',.5);
hold on;
bar(wakebin,'FaceAlpha',.5);
legend('Nonwake Interval','Wakebouts')
title('Wake')

subplot(1,3,2);
bar(internrembin,'FaceAlpha',.5);
hold on;
bar(nrembin,'FaceAlpha',.5);
legend('NonNREM Interval','NREMbouts')
title('NREM')

subplot(1,3,3);
bar(interrembin,'FaceAlpha',.5);
hold on;
bar(rembin,'FaceAlpha',.5);
legend('NonREM Interval','REMbouts')
title('REM')


%%I'm gonna divy up the sleep states into hourly bins using the below block
for i = 3600:3600:maxtime
    if sum(remints(:,2) < i) < sum(remints(:,1) < i)
        edgeindex = sum(remints(:,2) < i);
        newwake2 = [remints(1:edgeindex,2); i-.1 ;remints((edgeindex+1):end,2)];
        newwake1 = [remints(1:(edgeindex+1),1); i+.1 ;remints((edgeindex+2):end,1)];
        remints = [newwake1 newwake2];
    end
end
remhourbins = {};
timevec = 0:3600:i;
timevec(end) = [];
for i = timevec
    remhourbins{end + 1} = remints(remints(:,1) > i & remints(:,2) < (i + 3600),:);
end

% interrems = [];
% for i = 1:(length(remints(:,1)) - 1)
%     interrems = [interrems; remints(i+1,1) - remints(i,2)];
% end
reminterhours = num2cell(zeros(1,length(remhourbins)));
for i = 1:length(remhourbins)
    for j = 1:(length(remhourbins{i}(:,1)) - 1)
        reminterhours{i} = [reminterhours{i}; remhourbins{i}(j+1,1) - remhourbins{i}(j,2)];
    end
end



% interwake = [];
% for i = 1:(length(wakeints(:,1)) - 1)
%     interwake = [interwake; wakeints(i+1,1) - wakeints(i,2)];
% end
% 
% rembouts = remints(:,2) - remints(:,1);

remhourbouts = num2cell(zeros(1,length(remhourbins)));
for i = 1:length(reminterhours)
    remhourbouts{i} = remhourbins{i}(:,2) - remhourbins{i}(:,1);
end

% proportionrem = interrems ./ rembouts(1:length(interrems));

% proportionremhours = num2cell(zeros(1,length(remhourbins)));
% for i = 1:length(remhourbouts)
%     proportionremhours{i} = reminterhours{i} ./ remhourbouts{i}(1:length(reminterhours{i}));
% end

% figure;
% bar(interrems);
% hold on;
% bar(rembouts);
% hold on;
% plot(proportionrem);
% hold off;
% legend('Post time interval','REM bouts','Proportion of InterREM / REM');

meaninterrems = remhourbouts;
for i = 1:length(meaninterrems)
    meaninterrems{i} = mean(reminterhours{i});
end
meanrembouts = remhourbouts;
for i = 1:length(meaninterrems)
    meanrembouts{i} = mean(remhourbouts{i});
end
meanproportion = cell2mat(meanrembouts) ./ cell2mat(meaninterrems);
 
% figure;
% bar(cell2mat(meaninterrems))
% hold on;
% bar(cell2mat(meanrembouts))
% hold on;
% limits = ylim;
% plot(meanproportion * limits(2))
% legend('Post time interval','REM bouts','Proportion of InterREM / REM');

REMBoutDat = struct('interrems',interrems,'rembouts',rembouts,'proportionrem',proportionrem,'remhourbouts',remhourbouts,'reminterhours',reminterhours)

function [hypno] = makeHypno(wakeints,nremints,remints,maxtime)
    hypno = zeros(1,round(maxtime));
    for i = 1:length(hypno)
        for j = 1:length(wakeints(:,1))
            if (i > wakeints(j,1) && i < wakeints(j,2))
                hypno(i) = 1;
            end
        end
        for j = 1:length(nremints(:,1))
            if (i > nremints(j,1) && i < nremints(j,2))
                hypno(i) = 2;
            end
        end
        for j = 1:length(remints(:,1))
            if (i > remints(j,1) && i < remints(j,2))
                hypno(i) = 3;
            end
        end    
    end
end

function [bouts, intertime, props] = makeThree(ints)
    intertime = [];
    for i = 1:(length(ints(:,1)) - 1)
        intertime = [intertime; ints(i+1,1) - ints(i,2)];
    end

    bouts = ints(:,2) - ints(:,1);
    props = intertime ./ bouts(1:length(intertime));
end

function plotInterstate(bouts, intertime, props, state, ratname)
    figure;
    bar(intertime);
    hold on;
    bar(bouts);
    hold on;
    plot(props);
    
    %plot(abs(hilbert(intertime)),'LineWidth',2)
    hold off;
    legend(['Post time interval'],[state,' bouts'],['Proportion of Inter',state,' / ',state]);
    title([ratname,' ',state,' Bouts to Non',state, ' Intervals'])
    savefig([ratname,state,'BoutstoNon',state, 'Intervals.fig'])
end

function plotInterstateCirc(windows,bouts,intertime,props,state,ratname)
    oneless = windows(:,1);
    oneless(end)=[];    
    
    figure;
    bar(windows(:,1),bouts,10);
    hold on;
    %plot(windows(:,1),abs(hilbert(bouts)),'LineWidth',2);
    bar(oneless,intertime,10);
    %plot(oneless,abs(hilbert(intertime)),'LineWidth',2);
    bar(oneless,props,10);
    %plot(oneless,abs(hilbert(props)),'LineWidth',2);
    %legend(['Post time interval'],'Hilbert',[state,' bouts'],'Hilbert',['Proportion of Inter',state,' / ',state],'Hilbert');
    title([ratname,' ',state,' Bouts to Non',state, ' Intervals'])
end

function [interpol] = spitInterpol(X,Y)
    interpolX = [1:1:86400]';
    X = X(:,1);
    interpol = interp1(X,Y,interpolX);
end

function [shaved] = shaveone(twocolumns)
    twocolumns(end,:)= [];
    shaved = twocolumns;
end

function [final] = cellsum(thecell)
    final = zeros(86400,1);
    for i = 1:length(thecell)
        final = final + nanfilter(thecell{i});
    end
end

function [filtered] = nanfilter(something)
    something(isnan(something)) = 0;
    filtered = something;
end

function [smaller,binned] = binbyhour(thing)
    binned = zeros(length(thing),1);
    smaller = zeros(24,1);
    for i = 1:24
        if i == 1
        binned(1:i*3600) = mean(thing(1:i*3600));
        else
        binned(((i-1)*3600):i*3600) = mean(thing(((i-1)*3600):i*3600));
        end
        smaller(i) = binned(i*3600);
    end
end