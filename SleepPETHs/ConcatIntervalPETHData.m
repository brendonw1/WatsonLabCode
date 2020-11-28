function [AllEpochs,AllEpAligned] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochs,AllEpAligned)
% function [AllEpochs,AllPETH,AllEpAligned] = ConcatIntervalPETHData(Epochs,PETH,EpAligned,AllEpochs,AllPETH,AllEpAligned)


%% Epochs
if prod(size(Epochs))
    AllEpochs = cat(1,AllEpochs,Epochs);

    %% PETH
    % if isempty(AllPETH)
    %     AllPETH = PETH;
    % else
    %     fn = fieldnames(PETH);
    %     ldiff = length(AllPETH.onset) - length(PETH.onset);
    %     if length(PETH.onset) > length(AllPETH.onset);
    %         AllPETH.onset = cat(1,nan(ldiff,1),AllPETH.onset);
    %     else
    %         
    %     PETH.onset
    %     
    %     for ix = 1:length(fn);
    %         if ~strcmp('t',fn(end))
    %             eval(['AllPETH.' fn{ix} '=cat(2,AllPETH.' fn{ix} ',PETH.' fn{ix} ');'])
    %         end
    %     end
    % end

    %% EpAligned
    if isempty(AllEpAligned)
        AllEpAligned = EpAligned;
    else
%         try
        if isfield(AllEpAligned,'align_norm')
            AllEpAligned.align_norm = cat(2,AllEpAligned.align_norm,EpAligned.align_norm);
        elseif isfield(AllEpAligned,'norm')
            AllEpAligned.norm = cat(2,AllEpAligned.norm,EpAligned.norm);
        end            
        [AllEpAligned.align_onset, AllEpAligned.t_align_on] = ...
            catdifflengths(AllEpAligned.align_onset,EpAligned.align_onset,AllEpAligned.t_align_on,EpAligned.t_align_on);
        [AllEpAligned.align_offset, AllEpAligned.t_align_off] = ...
            catdifflengths(AllEpAligned.align_offset,EpAligned.align_offset,AllEpAligned.t_align_off,EpAligned.t_align_off);
%         catch
%             1;
%         end
    end
end

function [a,t1] = catdifflengths(a,b,t1,t2)

if numel(t2)~=0
    % first handle padding beginning
    z1 = find(t1 == 0);
    z2 = find(t2 == 0);
    if z1>z2;
        t2 = cat(2,t1(1:z1-1),t2(z2:end));
        ld = z1-z2;
        b = cat(1,nan(ld,size(b,2)),b);
    elseif z1<z2;
        t1 = cat(2,t2(1:z2-1),t1(z1:end));
        ld = z2-z1;
        a = cat(1,nan(ld,size(a,2)),a);
    end

    % now handle padding the end
    z1 = find(t1 == 0);
    z2 = find(t2 == 0);
    ze1 = length(t1)-z1;
    ze2 = length(t2)-z2;
    if ze1 > ze2
        t2 = cat(2,t2(1:z2),t1(z1+1:end));
        ld = ze1-ze2;
        b = cat(1,b,nan(ld,size(b,2)));
    elseif ze1 < ze2
        t1 = cat(2,t1(1:z1),t2(z2+1:end));
        ld = ze2-ze1;
        a = cat(1,a,nan(ld,size(a,2)));
    end

    % finally concatenate the two to add b to a
    a = cat(2,a,b);
else
    1;
end
