function getVectorsWrap(SessionPaths)

for whichSession=1:length(SessionPaths)
    subplot(3,5,whichSession)
    [rowsOut,proj,numHours,inj] = getVectors(SessionPaths{whichSession},false);
    plot([1:numHours],proj)
    xline(inj);
    ylim([0 1])
    sgtitle('Similarity to baseline FR vector')
end
