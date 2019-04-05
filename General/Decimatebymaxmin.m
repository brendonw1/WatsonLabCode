function varargout=Decimatebymaxmin(vect,factor)

flipindicator=0;
if length(size(vect))>2;
    error('input must be 2D or less')
elseif size(vect,1)<size(vect,2);%want size to be big x small (data stream by stream number)
    vect=vect';
    flipindicator=1;
end
numchans = size(vect,2);

factor=factor*2;
remain=rem(length(vect),factor);
if remain>0;%if number of points is not divisible by factor
    newvect=vect(1:end-remain,:);
    if remain>2;%if enough points to get a max and a min
        temp=vect(end-remain+1:end,:);
        temp(end+1:factor,:)=repmat(mean(temp,1),[factor-size(temp,1) 1]).*ones(factor-size(temp,1),size(temp,2));
        newvect(end+1:end+factor,:)=temp;
    end
else%if divisible by factor
    newvect=vect;
end
clear vect

newvect=reshape(newvect,[factor length(newvect)/factor  size(newvect,2)]);%set up for factor-fold decimation of data

[nvmax,maxpt]=max(newvect,[],1);
[nvmin,minpt]=min(newvect,[],1);

newvect=zeros(2*size(nvmax,2),numchans);
newvect(1:2:size(newvect,1)-1,:)=squeeze(nvmax);%odd numbered points are maxs
newvect(2:2:size(newvect,1),:)=squeeze(nvmin);%even points are local mins

if nargout>1;
    temp=((0:2:(size(newvect,1)-1))*(factor/2));
    timepoints=sort(cat(2,temp+round(factor/2/3),temp+round(factor/3)))';
end

if flipindicator==1;
    newvect=newvect';
    timepoints=timepoints';
end

varargout{1}=newvect;
if nargout>1;
    varargout{2}=timepoints;
end