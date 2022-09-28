%% Welcome to David's Connectivity. I couldn't think of a zany name for this...
% So I guess it's David's Connectivity... Anyways, this is gonna be used to
% produce a single metric for connectivity of a single circuit. 

%How am I gonna do that you ask? Well... First thing's first... Let's load
%in a circuit csv.

filesloc = '/analysis/Dayvihd/Quiksilver/Connect Results/1hrbin';
cd(filesloc);
a = dir('*.csv');
names = {a.name};

conmat = {};
for i = 1:length(names)
    conmat{i} = readmatrix(names{i});
end

% Let's start with something pretty simple: Let's take the absolute value
% of the entire matrix and take the average.
convals = zeros(1,24);
for i = 1:length(conmat)
    convals(i) = mean(mean(abs(conmat{i})));
end

% Now let's plot all this out!
figure;
subplot(2,1,1)
bar(convals)
axis tight
title('Functional Connectivity Metric over time for Quiksilver')
xlabel('Hours')
ylabel('Connectivity Metric')
subplot(2,1,2)
plot(movmean(overallfr,60));
title('Firing Rate')
ylabel('Firing Rate')
xlabel('Seconds')
axis tight