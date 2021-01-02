% https://www.mathworks.com/matlabcentral/answers/157355-grouping-figures-separately-into-windows-and-tabs
% Answer by Jan

%% Notes:
% Running twice with new names adds new tabs.

% Desired Behavior: Typically, I think calling with the same name should replace the existing tab entry in the current figure.
% There should be an option to override it.

groupName = 'myGroup';
groupNumCols = 4;
groupNumRows = 2;


% Computed Variables:
groupNumTotalItems = groupNumCols * groupNumRows;

%% Main Code:
desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
myGroup = desktop.addGroup(groupName);
desktop.setGroupDocked(groupName, 0);
myDim   = java.awt.Dimension(groupNumCols, groupNumRows);   % 4 columns, 2 rows
% 1: Maximized, 2: Tiled, 3: Floating
desktop.setDocumentArrangement(groupName, 2, myDim)
figH    = gobjects(1, groupNumTotalItems);
bakWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
for iFig = 1:groupNumTotalItems
   figH(iFig) = figure('WindowStyle', 'docked', ...
		'Name', sprintf('Figure uWu %d', iFig), ...
		'NumberTitle', 'off');
   drawnow;
   pause(0.02);  % Magic, reduces rendering errors
   set(get(handle(figH(iFig)), 'javaframe'), 'GroupName', groupName); % Sets the group name
   % Plotting is done here.
   plot(1:10, rand(1, 10));
end
warning(bakWarn);