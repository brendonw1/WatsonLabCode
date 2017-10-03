function plot_multiperfigure(data,xdim,ydim,titlestring,fignamestring,evalstring,varargin)

% figh = findall(0,'type','figure');
% figh = max(figh);
% if isempty(figh)
%     figh = 0;
% end

totplots = xdim*ydim;

w = whos('data');

switch w.class
    case 'double'
        datamode = 'matrix';
    case 'cell'
        datamode = 'cell';
    case 'tsdArray'
        datamode = 'tsdArray';
end

titlemode = 0;
if exist('titlestring','var')
    titlemode = 1;
end

fignamemode = 0;
if exist('fignamestring','var')
    fignamemode = 1;
end

evalmode = 0;
if exist('evalstring','var')
    evalmode = 1;
end

switch datamode
    case 'tsdArray'
        datadim = 1;
    otherwise
        datadim = 2;
end

for a = 1:size(data,datadim);
%     fignum = figh+ceil(a/totplots);
%     h = figure(fignum);
%     set(h,'position',[800 40 1100 925])
%     
%     if fignamemode
%         figname = [fignamestring,'#',num2str(fignum)];
%     else
%         figname = ['#',num2str(fignum)];
%     end
%     set(h,'name',figname);
    
    
    modtotplots=mod(a,totplots);
    if modtotplots==0
        modtotplots=totplots;
    end
    subplot(ydim,xdim,modtotplots)
   
    switch datamode
        case 'matrix'
            y = data(:,a)';
            x = 1:length(y);
        case 'cell'
            y = data{a};
            x = 1:length(y);
        case 'tsdArray'
            y = Data(data{a});
            x = TimePoints(data{a});
    end
    
    lineh = plot(x,y);%makes the eval command a bit easier to use
    xlim([x(1) x(end)])
    
    if titlemode
        if modtotplots == ceil(xdim/2);
            title(titlestring)
        end
    end
    if evalmode
        eval(evalstring);
    end
end