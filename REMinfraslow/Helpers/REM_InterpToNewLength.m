function OutVector = REM_InterpToNewLength(InVector,DesiredLength)
%
% OutVector = REM_InterpToNewLength(InVector,DesiredLength)
%
% Upsamling function
%
% Bueno-Junior et al. (2023)

%%
x  = 1:length(InVector);
xq = linspace(1,length(InVector),DesiredLength);
OutVector = interp1(x,InVector,xq);

if size(InVector,1) > 1
    OutVector = OutVector';
end

end
