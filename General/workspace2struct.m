% workspace2struct
% (script)
% Takes all variables in the current workspace and saves them into a struct
% array.  Output is always called workspacestruct.
% Script so it can be in the same workspace as the caller
% Brendon Watson 2014

w = whos;

for a = 1:length(w)
    workspacestruct.(w(a).name) = eval(w(a).name);
end