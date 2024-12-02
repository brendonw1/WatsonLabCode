function specs = SaveSpectrogramsFromEegStates(input);

StateInfo = input; 

specs = struct('spec', {}, 'freqs', {}, 'times', {});

for a = 1:length(StateInfo.fspec)
    specs(a).spec = StateInfo.fspec{a}.spec;
    specs(a).freqs = StateInfo.fspec{a}.fo;
    specs(a).times = StateInfo.fspec{a}.to;    
end

