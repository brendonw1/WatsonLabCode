function [allidxs,origidxsofnondeleted] = AddDeletedIndices(deletedidxs,postdeletedidxs)
% Reconstructs an original vector from two parts, one of which was deleted
% from the original 
% (ie using postdeletedidxs = allidxs; postdeletedidxs(deletedidxs) = [];).

allidxs = postdeletedidxs(:);
for a = 1:length(deletedidxs)
    t = deletedidxs(a);

    %% Get chunk before the new insertion
    if t>1
        pre = allidxs(1):allidxs(t-1);
    else
        pre = [];
    end
    pre = pre';
    
    %% Get chunk after new insertion
    if t == allidxs(end)+1
        post = [];
    else
        post = allidxs(t):allidxs(end);
        post = post'+1;%scoot everything up, and flip
    end
    
    %% Construct new version with insertion inserted
    allidxs = cat(1,pre,t,post);
end

%% get original indices of what later became the non-deleted elements
origidxsofnondeleted = allidxs;
origidxsofnondeleted(deletedidxs) = [];