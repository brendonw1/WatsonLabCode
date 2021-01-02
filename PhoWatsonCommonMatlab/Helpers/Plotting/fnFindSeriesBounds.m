function [lim, lims_vec] = fnFindSeriesBounds(x_cells, y_cells, wants_series_local_vectors)
	% find_plot_axes_bounds: Returns x and y mins and maxes for all children dataseries plots on the axes
	% returns lim: [xmin xmax ymin ymax]
	% optionally returns lims_vec, a row containing [xmin_vec(i)
	% xmax_vec(i) ymin_vec(i) ymax_vec(i)] for each series if
	% wants_series_local_vectors == true.
	if ~exist('wants_series_local_vectors','var')
		wants_series_local_vectors = false;
	end
	
	% Per-series values:
	xmin_vec = cellfun(@min, x_cells);
	xmax_vec = cellfun(@max, x_cells);
	
	ymin_vec = cellfun(@min, y_cells);
	ymax_vec = cellfun(@max, y_cells);
	
	% Compute global values:
	xmin = min(xmin_vec);
	xmax = max(xmax_vec);
	
	ymin = min(ymin_vec);
	ymax = max(ymax_vec);
	
	lim = [xmin xmax ymin ymax];

	if wants_series_local_vectors
		numSeries = length(xmin_vec);
		lims_vec = zeros(numSeries,4);
		for i=1:numSeries
			lims_vec(i,:) = [xmin_vec(i) xmax_vec(i) ymin_vec(i) ymax_vec(i)];
		end
	else
		lims_vec = [];
	end
end
