function video = ModeSubtractedMovie(vid)
% Takes a 4d color movie, finds the mode and subtracts that from each
% frame.  Outputs vid, a movie with the same size and duration but with the
% mode subtracted.

% %B&W >> SEEMS LIKE IT MUST THROW AWAY INFORMATION
% bwvid = squeeze(bwvid);
% modalimage = mode(bwvid,3);
% diffrommode = bwvid-repmat(modalimage,[1 1 size(bwvid,3)]);

%COLOR
modalimage = mode(vid,4);
video = vid-repmat(modalimage,[1 1 1 size(vid,4)]);
