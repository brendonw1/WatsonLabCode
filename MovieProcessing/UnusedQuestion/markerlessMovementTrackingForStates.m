function markerlessMovementTrackingForStates(filename)

diffmovie = DiffResampledMovie(filename,5);
threshdiffmovie = BinaryThresholdDiffMovie(diffmovie);

