function newstates = ReviewStateEditorStates(statetype)
% Allows user to hop to each incidence of a state one at a time in state
% editor, assuming state editor is the current figure.

FO = guidata(gcf);%get guidata
st = FO.States;
newstates = st;

ststarts = find(diff(st == statetype)==1)+1;
stends = find(diff(st == statetype)==-1)+1;
for a = 1:ststarts
    ss = ststarts(a);
    se = stends(a);
    set(FO.gotosecondbox, 'String',num2str(ss));
    goToSecond

    
%% Figure out how to reassign
    stbefore = st(ss-1);
    stafter = (se+1);
    stlength = (se-ss);
    
    r = statetype;%default
    if stbefore == 3 && stafter == 3
        r = 3;
    elseif stbefore == 5
        r = 5;
    end
%     r = 3;

%% Verify with user    
    prompt = ['This chunk will be re-assigned as ' num2str(r) '.  Enter alternate if desired: '];

    drawnow
    commandwindow

    result = input(prompt);
    if ~isempty(result);
        r = result;
    end
    newstates(ss:se) = r;
end



%%    
function goToSecond(obj,event)
% get xlims to generate range
% get the string to get what the mean should be
% make newx based on that
% if less than 0, or greater than max possible, keep the range and set the
%    one end at the boundary and the other
% set FO.sax


FO = guidata(gcf);%get guidata
xmax = diff(FO.lims);%max x possible
gotopoint = str2num(get(FO.gotosecondbox, 'String'));
oldrange = get(FO.sax{1}, 'XLim');
windowwidth = diff(oldrange);
% if (n2 <= xmax) & n2 > 0

newrange = [gotopoint - windowwidth/2, gotopoint + windowwidth/2];

if min(newrange) < 0
    newrange = [0 windowwidth-1];
end
if max(newrange) > FO.lims(2)
    newrange = [(FO.lims(2)-windowwidth+1), FO.lims(2)];
end

set(FO.sax{1}, 'XLim', newrange);  %action step: set axis1, if there are other axes, updateEEG will set any other axes to match it
axes(FO.sax{1});

set(FO.gotosecondbox, 'String', '');

UpdateText;
if gotopoint > FO.lims(1) & gotopoint <= FO.lims(2)
    updateEEG(gotopoint);
end
% else
%     set(FO.xlimbox, 'String', int2str(round(diff(oldx))));
%     return;
% end


%%
function UpdateText
FO = guidata(gcf);

action = FO.currAction;

switch action
    case 'Browse'
        set(FO.actionDisp, 'String', {'\fontsize{12}\bfCurrent Action:', ' ', '\fontsize{20}Browse'});
        set(gcf,'Pointer','hand');
    case 'Add'
        set(gcf,'Pointer','arrow');
        colors = FO.colors;
        s1 = FO.currentState;
        if s1 == 0
            s2 = 1;
        else
            s2 = s1;
        end
        h = ['\fontsize{42}\color[rgb]{', num2str(colors.states{s2}), '}',int2str(s1)];
        set(FO.actionDisp, 'String', {'\fontsize{12}\bfCurrent Action:', 'Add state:', h});
    case 'AddEvent'
        h = ['\fontsize{42}', int2str(FO.eventNum)];
        set(FO.actionDisp, 'String', {'\fontsize{12}\bfCurrent Action:', 'Add event:', h});
    case 'DeleteEvent'
        h = ['\fontsize{42}', int2str(FO.eventNum)];
        set(FO.actionDisp, 'String', {'\fontsize{12}\bfCurrent Action:', 'Delete event:', h});
    case 'Zoom'
        set(FO.actionDisp, 'String', {'\fontsize{12}\bfCurrent Action:', ' ', '\fontsize{20}Zooming', '\fontsize{20}about'});
        set(gcf,'Pointer','cross');
    case 'FreqResize'
        set(FO.actionDisp, 'String', {'\fontsize{12}\bfCurrent Action:', ' ', '\fontsize{20}Rescale Frequencies'});
        set(gcf,'Pointer','hand');
        
end

set(FO.lastClickDisp, 'String', {'Last Click at sec:', num2str(FO.clickPoint, 7), ['(of ', num2str(FO.lims(2), 7), ')']});
set(FO.eegWidthDisp, 'String', ['\bf\color{red}\fontsize{11}', num2str(FO.eegShow), ' sec']);
if isempty(FO.startLocation)
    set(FO.startLocDisp, 'Visible', 'off');
else
    set(FO.startLocDisp, 'String', {'First bound at sec:', num2str(FO.startLocDisp, 7)});
    set(FO.startLocDisp, 'Visible', 'on');
end

set(FO.xlimbox, 'String', int2str(round(diff(get(FO.sax{1}, 'XLim')))));
guidata(gcf, FO);


%%
function updateEEG(varargin)
FO = guidata(gcf);
if isempty(varargin)
    pos = mean(get(FO.sax{1}, 'XLim'));
else
    pos = varargin{1};
end
low = pos - FO.eegShow/2;
high = pos + FO.eegShow/2;
if low < FO.lims(1);
    high = high + (FO.lims(1) + low);
    low = FO.lims(1);
else
    if high > FO.lims(2)
        low = low + (FO.lims(2) - high);
        high = FO.lims(2);
    end
end

lowMargin = low - 60;
highMargin = high + 60;
for i = 1:FO.nCh
    set(FO.Eplot{i}, 'XData', FO.eegX(FO.eegX >= lowMargin & FO.eegX <= highMargin), 'YData', FO.eeg{i}(FO.eegX >= lowMargin & FO.eegX <= highMargin));
    l1 = [min(FO.eeg{i}(FO.eegX >= low & FO.eegX <= high)), max(FO.eeg{i}(FO.eegX >= low & FO.eegX <= high))];
    set(FO.eax{i}, 'YLim', l1);
    set(FO.eax{i}, 'XLim', [pos - FO.eegShow/2, pos + FO.eegShow/2]);
end

set(FO.max,'xticklabel',num2str(get(FO.max,'xtick')'));
set(FO.sax{end},'xticklabel',num2str(get(FO.sax{end},'xtick')'));
set(FO.eax{end},'xticklabel',num2str(get(FO.eax{end},'xtick')'));

lims1 = get(FO.sax{1}, 'XLim');
perc = (pos - lims1(1))/diff(lims1);
newL = (diff(FO.xplotLims)*perc) + FO.xplotLims(1);

for i = 1:length(FO.sMidline)
    set(FO.sMidline{i}, 'X', [newL, newL]);
end
set(FO.mMidline, 'X', [newL, newL]);


h = get(gcf, 'Children');
try
    h = [FO.lineParent; h(h ~= FO.lineParent)];
    set(gcf, 'Children', h);
catch
end

% for i = 1:FO.nCh
%     set(FO.Eplot{i}, 'XData', FO.eegX(FO.eegX >= low & FO.eegX <= high));
%     set(FO.Eplot{i}, 'YData', FO.eeg{i}(FO.eegX >= low & FO.eegX <= high));
%     l1 = [min(FO.eeg{i}(FO.eegX >= low & FO.eegX <= high)), max(FO.eeg{i}(FO.eegX >= low & FO.eegX <= high))];
%     set(FO.eax{i}, 'YLim', l1);
%     set(FO.eax{i}, 'XLim', [pos - FO.eegShow/2, pos + FO.eegShow/2]);
% end

guidata(gcf, FO);