function SecondsAfterLightCycleStart = TimeFromLightCycleStart(basepath,basename)
% Zeitgeber times of recording files
% Brendon Watson, 2016

%% settings
% lightson = 06:00:00;
lightsonhours = 6;
lightsonminutes = 0;
lightsonseconds = 0;


if ~exist('basepath','var')
 [~,basename,~] = fileparts(cd);
 basepath = cd;   
end
savepath = fullfile(basepath,[basename '_SecondsFromLightsOn.mat']);

if exist(fullfile(basepath,[basename '_BasicMetaData.mat'])) %if amplipex and old dating scheme
    bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
    if isfield(bmd,'masterpath')
        basepath = bmd.masterpath;
        basename = bmd.mastername;
        savepath = fullfile(bmd.basepath,[bmd.basename '_SecondsFromLightsOn.mat']);
    end
    clear bmd
    bunderscore = strfind(basename,'_');
    basedate = basename(bunderscore+1:end);
    bdateday = str2num(basedate(3:4));
    bdateyear = 2000+str2num(basedate(5:6));
    bdatemonth = str2num(basedate(1:2));
else %if intan
    bunderscore = strfind(basename,'_');
    basedate = basename(bunderscore+1:end);
    bdateday = str2num(basedate(5:6));
    bdateyear = 2000+str2num(basedate(1:2));
    bdatemonth = str2num(basedate(3:4));
end

lightsondatenum = datenum(bdateyear,bdatemonth,bdateday);

d = dir(fullfile(basepath,'*.meta'));
if ~isempty(d);%if from an amplipex
   fname1 = fullfile(basepath,[basename '-01.meta']);%explicitly look for -01
   seconds = getmetafilestarttime(fname1,lightsondatenum,lightsonhours,lightsonminutes,lightsonseconds);
   SecondsAfterLightCycleStart = seconds;
   SecondsAfterLightCycleStart_PerFile = nan(1,length(d));
   for a = 1:length(d);
       fname = fullfile(basepath,d(a).name);  
       seconds = getmetafilestarttime(fname,lightsondatenum,lightsonhours,lightsonminutes,lightsonseconds);
       SecondsAfterLightCycleStart_PerFile(a) = seconds;
   end
else %if from intan
    d = dir(fullfile(basepath,[basename(1:end-3) '*/']));%if I record over new year's eve I'll have to handle it :)
    for a = length(d):-1:1;
        if ~d(a).isdir
            d(a) = [];
        end
    end
    SecondsAfterLightCycleStart_PerFile = nan(1,length(d));
    for a = 1:length(d);
        seconds = getintanfilestarttime(d(a).name,lightsondatenum,lightsonhours,lightsonminutes,lightsonseconds);
        if a == 1 
           SecondsAfterLightCycleStart = seconds;
        end
        SecondsAfterLightCycleStart_PerFile(a) = seconds;
    end
end
    

save(savepath,'SecondsAfterLightCycleStart','SecondsAfterLightCycleStart_PerFile')
% SecondsAfterLightCycleStart_PerFile

function seconds = getmetafilestarttime(fname,lightsondatenum,lightsonhours,lightsonminutes,lightsonseconds)

try
    ttime = ReadMetaAspects(fname,'starttime');
    h = str2num(ttime(1:2));
    m = str2num(ttime(4:5));
    s = str2num(ttime(7:8));
    dashes = strfind(fname,'-');

    tdate = ReadMetaAspects(fname,'startdate');
    spaces = strfind(tdate,' ');
    datemonth = tdate(1:spaces(1)-1);
    dateday = tdate(spaces(1)+1:spaces(2)-1);
    if length(dateday) == 1;
        dateday = ['0' dateday];
    end
    dateyear = tdate(spaces(2)+1:end);
    dn = datenum([dateday '-' datemonth '-' dateyear],'dd-mmm-yyyy');

    hoursecs = (h-lightsonhours)*3600;
    minsecs = (m-lightsonminutes)*60;
    secs = s-lightsonseconds;
    daysecs = 24*3600*(dn-lightsondatenum);

    seconds = daysecs+hoursecs+minsecs+secs;
catch 
    disp(['reading time/date from ' fname ' did not work'])
    seconds = NaN;
end



function seconds = getintanfilestarttime(fname,lightsondatenum,lightsonhours,lightsonminutes,lightsonseconds)

underscores = strfind(fname,'_');
ttime = fname(underscores(2)+1:end);
h = str2num(ttime(1:2));
m = str2num(ttime(3:4));
s = str2num(ttime(5:6));

tdate = fname(underscores(1)+1:underscores(2)-1);
dateday = tdate(5:6);
dateyear = num2str(2000+str2num(tdate(1:2)));
datemonth = tdate(3:4);
dn = datenum([dateday '-' datemonth '-' dateyear],'dd-mmm-yyyy');

hoursecs = (h-lightsonhours)*3600;
minsecs = (m-lightsonminutes)*60;
secs = s-lightsonseconds;
daysecs = 24*3600*(dn-lightsondatenum);

seconds = daysecs+hoursecs+minsecs+secs;