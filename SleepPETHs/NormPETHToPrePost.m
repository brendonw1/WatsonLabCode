function [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs,normperiod,normmode)

if isfield(EpAligned,'align_norm')
    norm = EpAligned.align_norm;
elseif isfield(EpAligned,'norm')
    norm = EpAligned.norm;
end


if ~isempty(Epochs)
    onzero = find(EpAligned.t_align_on==0);
    offzero = find(EpAligned.t_align_off==0);
    normzero = find(EpAligned.t_norm == 0);
    normone = find(EpAligned.t_norm == 1);
    
    if ~exist('normperiod','var')
        normperiod = 'allin';%what part of the pre/post to use for normalization
    end
    switch normperiod
        case 'allin'
            onper = EpAligned.align_onset(onzero:end,:);
            offper = EpAligned.align_offset(1:offzero-1,:);
            normper = norm((normzero+1):(normone-1),:);
        case 'allout'
            onper = EpAligned.align_onset(1:onzero-1,:);
            offper = EpAligned.align_offset(offzero+1:end,:);
            normper = cat(1,norm(1:normzero-1,:),norm(normone+1:end,:));
        case 'tenpercent'%only applies to norm for now
            onper = EpAligned.align_onset(1:onzero-1,:);
            offper = EpAligned.align_offset(offzero+1:end,:);
            normnegten = find(EpAligned.t_norm == -0.1);
            normhundredten = find(EpAligned.t_norm == 1.1);
            normper = cat(1,norm(normnegten:normzero-1,:),norm(normone+1:normhundredten,:));
        case 'first10percentin'%only applies to norm for now
            onper = EpAligned.align_onset(1:onzero-1,:);
            offper = EpAligned.align_offset(offzero+1:end,:);
            norm10 = find(EpAligned.t_norm <= 0.1,1,'last');
            normper = norm(normzero:norm10,:);
    end

    if ~exist('normmode','var')
        normmode = 'zscore';
    end
    switch normmode
        case 'meandiv'
            m = repmat(nanmean(onper,1),size(EpAligned.align_onset,1),1);
            EpAligned.align_onset = EpAligned.align_onset ./m;

            m = repmat(nanmean(offper,1),size(EpAligned.align_offset,1),1);
            EpAligned.align_offset = EpAligned.align_offset ./m;

            m = repmat(nanmean(normper,1),size(norm,1),1);
            norm = norm ./m;
        case 'meansub'
            m = repmat(nanmean(onper,1),size(EpAligned.align_onset,1),1);
            EpAligned.align_onset = EpAligned.align_onset -m;

            m = repmat(nanmean(offper,1),size(EpAligned.align_offset,1),1);
            EpAligned.align_offset = EpAligned.align_offset -m;

            m = repmat(nanmean(normper,1),size(norm,1),1);
            norm = norm -m;
        case 'median'
            m = repmat(nanmedian(onper,1),size(EpAligned.align_onset,1),1);
            EpAligned.align_onset = EpAligned.align_onset ./m;

            m = repmat(nanmedian(offper,1),size(EpAligned.align_offset,1),1);
            EpAligned.align_offset = EpAligned.align_offset ./m;

            m = repmat(nanmedian(normper,1),size(norm,1),1);
            norm = norm ./m;
        case 'zscore'
            m = repmat(nanmean(onper,1),size(EpAligned.align_onset,1),1);
            s = repmat(nanstd(onper,1),size(EpAligned.align_onset,1),1);
            EpAligned.align_onset = (EpAligned.align_onset - m)./s;

            m = repmat(nanmean(offper,1),size(EpAligned.align_offset,1),1);
            s = repmat(nanstd(offper,1),size(EpAligned.align_offset,1),1);
            EpAligned.align_offset = (EpAligned.align_offset - m)./s;

            m = repmat(nanmean(normper,1),size(norm,1),1);
            s = repmat(nanstd(normper,1),size(norm,1),1);
            norm = (norm - m)./s;
        case 'bwnormalize'
            m = repmat(min(onper,[],1),size(EpAligned.align_onset,1),1);
            EpAligned.align_onset = EpAligned.align_onset - m;
            m = repmat(max(onper,[],1),size(EpAligned.align_onset,1),1);
            EpAligned.align_onset = EpAligned.align_onset ./ m;

            m = repmat(min(offper,[],1),size(EpAligned.align_offset,1),1);
            EpAligned.align_offset = EpAligned.align_offset - m;
            m = repmat(max(offper,[],1),size(EpAligned.align_offset,1),1);
            EpAligned.align_offset = EpAligned.align_offset ./ m;

            m = repmat(min(normper,[],1),size(norm,1),1);
            norm = norm - m;
            m = repmat(max(normper,[],1),size(norm,1),1);
            norm = norm ./ m;
    end
end

if isfield(EpAligned,'align_norm')
    EpAligned.align_norm = norm;
elseif isfield(EpAligned,'norm')
    EpAligned.norm = norm;
end
