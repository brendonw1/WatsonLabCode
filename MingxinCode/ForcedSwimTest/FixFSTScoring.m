function FixFSTScoring(filename)
load(filename);
UsedChunks = RawChunkBehavVals(~isnan(RawChunkBehavVals));
UsedChunks = UsedChunks(1:180);
BehaviorChunkCounts(1) = sum(UsedChunks==0);
BehaviorChunkCounts(2) = sum(UsedChunks==1);
BehaviorChunkCounts(3) = sum(UsedChunks==2);
save(filename,'RawChunkBehavVals','secondsperchunk','UsedChunks','BehaviorChunkCounts');
end
