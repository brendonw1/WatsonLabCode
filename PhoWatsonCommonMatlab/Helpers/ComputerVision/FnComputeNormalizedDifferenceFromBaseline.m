function [curr_change_from_baseline, curr_frame_hist] = FnComputeNormalizedDifferenceFromBaseline(static_reference_frame, curr_greyscale_frame)
%FnComputeNormalizedDifferenceFromBaseline Computes the normalized difference of a frame from baseline
%   static_reference_frame: this should be a greyscale frame that contains just the cage with no mouse, that will be used as a "Baseline" to see how the curr_greyscale_frame differs (hopefully reflecting mouse activity).

% Get histogram for the current frame:
curr_frame_hist = imhist(curr_greyscale_frame);

% Equalize the Histograms of the current frame and the static reference frame for valid comparisons.
curr_normalized_static_reference_frame = histeq(static_reference_frame, curr_frame_hist);

% Return the difference between the current frame and the normalized reference frame.
curr_change_from_baseline = abs(curr_greyscale_frame - curr_normalized_static_reference_frame);


end

