function outputvar = assignout(ws,inputvarname)
% pulls a variable OUT of a workspace into your current one.
% INPUTS
% ws - string specifying the workspace to get variable out of, ie 'base'
%   or 'caller'
% inputvarname - string specifying the name of the value to grab from the 
%   specified workspace
%
% OUTPUT
% outputvar - variable extracted from specified workspace
%
% 2015 Brendon Watson

% assignstring = ['assignin(''caller'',''' outputvarname ''', ' inputvarname ')'];
assignstring = ['assignin(''caller'',''outputvar'', ' inputvarname ')'];

evalin(ws,assignstring)
