function envelope = hilbertenvelope(signal)
% takes a vector input, hilbert transforms and uses abs(hilbert) to get the
% envelope

hs = hilbert(signal);
envelope = abs(hs);
