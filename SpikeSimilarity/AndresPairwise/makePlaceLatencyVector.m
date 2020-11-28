function out = makePlaceLatencyVector(PV)


out = [];
%out((length(PV))*(length(PV) - 1)/2, 1) = NaN;

for I = 1:(length(PV) - 1)
    if PV(I) == 0
        out = [out; zeros(length(PV) - I, 1)];
    else
        for i = (I + 1):length(PV)
            if PV(i) == 0
                out = [out; 0];
            else
                out = [out; PV(i) - PV(I)];
            end
        end
    end
end
out = out';