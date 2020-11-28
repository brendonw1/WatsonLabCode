% movefile(fullfile(basepath,[basename '_StateID2.mat']),fullfile(basepath,[basename '_StateIDA.mat']))
% try
%     delete(fullfile(basepath,[basename '_StateIDM.mat']))
% end
% try
%     delete(fullfile(basepath,[basename '_StateIDNoMin.mat']))
% end
% try
%     delete(fullfile(basepath,[basename '_StateIDWMin.mat']))
% end
% try
%     delete(fullfile(basepath,[basename '_StateID.mat']))
% end
% try
%     delete(fullfile(basepath,[basename '-states.mat']))
% end


try
    delete(fullfile(basepath,'*_WSWEpisodes*'))
end
try
    delete(fullfile(basepath,'*_SleepDivisions*'))
end
try
    delete(fullfile(basepath,'*_Intervals*'))
end
try
    delete(fullfile(basepath,'*_ACG*'))
end
