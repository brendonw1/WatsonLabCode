function FixResFetTimes(basename)
% adds times of previous file

Par = LoadPar([basename '.xml']);

varargout = getDatAndVideoSessionInfo(basename);
fs = varargout.metaInfo.fileBytes;
for a = 1:length(fs)
    filesamps(a) = fs{a}/Par.nChannels/2;%convert from bytes to samples in each file
end
fileends = cumsum(filesamps);
filestarts = [1 fileends(1:end-1)+1];

dr = dir('*.res.*');
for a = 1:length(dr);%for each shank/cluster group
    tn = dr(a).name;
    endp1 = regexp(tn,'.res.');
%     thisbasename = tn(1:endp1-1);
    shanknum = str2num(tn(endp1+5:end));
    disp(['Starting Res # ' num2str(shanknum)])
    
    res = load([tn]);%load res
    
    backslips = find(diff(res)<0);    %indices of res
%     figure;plot(diff(tr))
    if length(backslips) == length(fs)-1
        for b = 1:length(backslips)
            endtimetoadd = fileends(b);
            idxforstartofthisres = backslips(b)+1;
            if b == length(backslips)
                idxforstopofthisres = length(res);
            else
                idxforstopofthisres = backslips(b+1);
            end
            thisres = idxforstartofthisres:idxforstopofthisres;
            res(thisres) = res(thisres) + endtimetoadd;
        end
    elseif ~isempty(backslips)
        disp('did not execute')
%         for b = 1:length(backslips)
%             fileidx = find(filestarts>=backslips(b),1,'first');%get the file index
%             thesespks = backslips(b)+1:find(res<(filesamps(fileidx)+backslips(b)),1,'last');
%             res(thesespks) = res(thesespks)+fileends(fileidx-1);
%         end
    end
    SaveRes(tn,res)
    
    fetname = [tn(1:endp1-1) '.fet.' tn(endp1+5:end)];
    [Fet, nFeatures] = LoadFet(fetname);
    
    Fet(:,end) = res;
    SaveFet([fetname], Fet)
end