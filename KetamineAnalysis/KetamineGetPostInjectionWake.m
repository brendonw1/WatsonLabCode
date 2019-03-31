function [postinjwake,noninjwake] = KetamineGetPostInjectionWake(basepath,basename)
% retrieves wake time just after injection, uses intervalSet format
% saves as an intervalset if not already on disk.
%
% Brendon Watson 2016

if ~exist('basepath','var')
    [~,basename] = fileparts(cd);
    basepath = cd;
end
if ~exist(basepath,'dir')
    basepath = fullfile(getdropbox,'Data','KetamineDataset',basename);
end

savefilepath = fullfile(basepath,[basename '_PostInjectionWakeInterval']);

% if exist(savefilepath,'file')
%     load(savefilepath)
% else

    %%
    load(fullfile(basepath,[basename '_BasicMetaData.mat']),'InjectionTimestamp')
    load(fullfile(basepath,[basename '_BasicMetaData.mat']),'BadIntervali')
    load(fullfile(basepath,[basename '-states.mat']),'states')

    %%
    stateInts = IDXtoINT(states);
    wake = stateInts{1};
    wakeis = intervalSet(wake(:,1),wake(:,2));
    inj = [InjectionTimestamp.InRecordingSeconds InjectionTimestamp.InRecordingSeconds+60*5];%injectin time in seconds and another 5min later

    [s,i] = InIntervalsBW(inj,wake);

    if s(1)
        ix = i(1);
        w_start = inj(1);
    %     i_end = max([inj(2) wake(ix,2)]);%either 5min or end of scored wake
    elseif s(2)
        ix = i(2);
        w_start = min([inj(2) wake(ix,2)]);%assming inj(2), which is 5min late is after teh actual wake start it was in the interval of
        w_start = max([w_start inj(1)]);%make sure this start time is not before injection by weird logic
    else
        %no match found
        return
    end

    w_end = wake(ix,2);%either 5min or end of scored wake

    % start shaping final outputs
    postinjwake = intervalSet(w_start,w_end);
    if ~isempty(BadIntervali)
        postinjwake = minus(postinjwake,BadIntervali);
    end
    
    postinjwake_IS = postinjwake;%interval set version
    postinjwake_se = StartEnd(postinjwake_IS);%startstop pair version
    postinjwake_vect = [];%list of seconds in the interval
    for a = 1:size(postinjwake_se,1)
        postinjwake_vect = cat(2,postinjwake_vect,postinjwake_se(1):postinjwake_se(2));
    end
    postinjwake_vect = round(postinjwake_vect);
    postinjwake = v2struct(postinjwake_IS,postinjwake_se,postinjwake_vect);

    noninjwake_IS = minus(wakeis,postinjwake_IS);
    if ~isempty(BadIntervali)
        noninjwake_IS = minus(noninjwake_IS,BadIntervali);
    end
    noninjwake_se = StartEnd(noninjwake_IS);
    noninjwake_vect = [];
    for a = 1:size(noninjwake_se,1)
        noninjwake_vect = cat(2,noninjwake_vect,noninjwake_se(1):noninjwake_se(2));
    end
    noninjwake_vect = round(noninjwake_vect);
    noninjwake = v2struct(noninjwake_IS,noninjwake_se,noninjwake_vect);
    
    save(savefilepath,'postinjwake','noninjwake')
% end


