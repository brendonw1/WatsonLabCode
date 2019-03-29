function output = binning(data,nColumns,option)

% Sums or averages every n columns of data into a binned/re-binned output.
% Rows are binned separately if the input is a 2D or 3D matrix. Option can
% be either 'm' for mean or 's' for sum.
%
% LSBuenoJr _______________________________________________________________



%%
output = zeros(size(data,1),size(data,2)/nColumns,size(data,3));
switch option
    case 'm'
        for i = 1:size(data,3)
            output(:,:,i) = reshape(mean(reshape(data(:,:,i)',nColumns,...
                numel(data(:,:,i))/nColumns)),...
                size(data,2)/nColumns,size(data,1))'; 
        end
    case 's'
        for i = 1:size(data,3)
            output(:,:,i) = reshape(sum(reshape(data(:,:,i)',nColumns,...
                numel(data(:,:,i))/nColumns)),...
                size(data,2)/nColumns,size(data,1))';
        end
    otherwise
        error('Select mean (m) or sum (s) as the third argument');
end