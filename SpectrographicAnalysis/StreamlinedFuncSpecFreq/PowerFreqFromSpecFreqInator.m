function [bands, epochs] = PowerFreqFromSpecFreqInator(specs, lightsOnTime)
    % Default value for lightsOnTime
    if ~exist('lightsOnTime', 'var') || isempty(lightsOnTime)
        lightsOnTime = 1; % seconds
    end

    %% Validate input structure
    if ~isstruct(specs)
        error('Input specs must be a struct array.');
    end

    requiredFields = {'spec', 'freqs', 'times'};
    for i = 1:length(specs)
        if ~all(isfield(specs(i), requiredFields))
            error('Each element of specs must contain fields: spec, freqs, and times.');
        end
    end

    %% Defining frequency bands
    bands.delta.startstopfreq = [0.5 4];
    bands.theta.startstopfreq = [5 10];
    bands.spindle.startstopfreq = [11 19];
    bands.lowbeta.startstopfreq = [20 30];
    bands.highbeta.startstopfreq = [30 40];
    bands.lowgamma.startstopfreq = [40 60];
    bands.midgamma.startstopfreq = [60 100];
    bands.highgamma.startstopfreq = [100 140];
    bands.ripple.startstopfreq = [140 180];
    bands.thetaratio.startstopfreq = [0 0];
    bandnames = fieldnames(bands);

    %% Setting up time intervals
    timestamps = specs(1).times;
    if isempty(timestamps)
        error('The field "times" in specs cannot be empty.');
    end
    
    epochs.BinInterval = [lightsOnTime length(timestamps)];
    BinIntervalLength = epochs.BinInterval(2) - epochs.BinInterval(1) + 1;
    if BinIntervalLength > length(timestamps)
        error('Calculated BinInterval exceeds the length of timestamps.');
    end
    epochs.BinIndices = epochs.BinInterval(1):epochs.BinInterval(2);

    % Define HourlyBinStarts and HourlyBinEnd
    HourlyBinStarts = (1:3600:23*3600+1)';
    HourlyBinEnd = (3600:3600:24*3600)';
    epochs.HourlyBinIntervals = [HourlyBinStarts HourlyBinEnd];

    % Calculate HourlyBinIndices manually and ensure within range
    for hidx = 1:24
        hourly_start = epochs.HourlyBinIntervals(hidx, 1);
        hourly_end = min(epochs.HourlyBinIntervals(hidx, 2), length(timestamps));
        epochs.HourlyBinIndices{hidx} = hourly_start:hourly_end;
    end

    %% Initialize powervectors field for each band
    for b = 1:length(bandnames)
        tbandname = bandnames{b};
        bands.(tbandname).powervectors.All = cell(length(specs), 1);
        bands.(tbandname).powervectors.HourlyBin = cell(length(specs), 24);
    end

    %% Extracting powers for each frequency band (indexed over channels)
    for b = 1:length(bandnames) % for every band
        tbandname = bandnames{b};
        tband = bands.(tbandname);

        % Find indices of relevant frequencies for this band
        tband.freqidxs = find(specs(1).freqs >= tband.startstopfreq(1) & specs(1).freqs < tband.startstopfreq(2));
        if isempty(tband.freqidxs) && ~strcmp(tbandname, 'thetaratio')
            warning(['No frequencies found in the range for band: ', tbandname]);
            continue;
        end
        
        for a = 1:length(specs) % for every channel
            if strcmp(tbandname, 'thetaratio')
                % Ensure required fields exist before accessing them
                if ~isfield(bands.delta, 'powervectors') || ~isfield(bands.spindle, 'powervectors') || ~isfield(bands.theta, 'powervectors')
                    warning('Delta, spindle, and theta power vectors must exist for thetaratio calculation.');
                    continue;
                end
                
                % Ensure that 'All' field exists in the power vectors for required bands
                if ~isfield(bands.delta.powervectors, 'All') || ~isfield(bands.spindle.powervectors, 'All') || ~isfield(bands.theta.powervectors, 'All')
                    warning('Delta, spindle, and theta power vectors must exist in bands.');
                    continue;
                end

                % Add debug information:
                delta_power = bands.delta.powervectors.All{a};
                spindle_power = bands.spindle.powervectors.All{a};
                theta_power = bands.theta.powervectors.All{a};

                % Debug output for sizes
                fprintf('Channel %d: delta_power size = %d, spindle_power size = %d, theta_power size = %d\n', a, length(delta_power), length(spindle_power), length(theta_power));

                % Check if sizes of delta, spindle, and theta power vectors are equal
                if isempty(delta_power) || isempty(spindle_power) || isempty(theta_power)
                    warning(['Truncated power vectors for channel ', num2str(a), ' to length 0']);
                    tbandpower = [];
                else
                    min_length = min([length(delta_power), length(spindle_power), length(theta_power)]);
                    delta_power = delta_power(1:min_length);
                    spindle_power = spindle_power(1:min_length);
                    theta_power = theta_power(1:min_length);

                    tbandpower = theta_power ./ (delta_power + spindle_power);
                end
                tband.powervectors.All{a} = tbandpower; % Save the thetaratio power vector
            else
                tband.subspectrograms{a} = specs(a).spec(:, tband.freqidxs);
                if isempty(tband.subspectrograms{a})
                    warning(['Subspectrogram for band "', tbandname, '" is empty for channel ', num2str(a)]);
                    tbandpower = [];
                else
                    tbandpower = mean(tband.subspectrograms{a}, 2);
                    tband.powervectors.All{a} = tbandpower;
                end
            end

            % Calculate mean power by hourly bin intervals
            for p = 1:24
                if isempty(epochs.HourlyBinIndices{p}) || (max(epochs.HourlyBinIndices{p}) > length(tbandpower))
                    warning(['Epoch or band power data out of range for hourly bin ', num2str(p), ' in band "', tbandname]);
                    continue;
                end
                tbandpowervector = mean(tbandpower(epochs.HourlyBinIndices{p}));
                tband.powervectors.HourlyBin{a, p} = tbandpowervector; 
            end

            % Generate histogram versions of each power vector
            pvnames = fieldnames(tband.powervectors);
            for c = 1:length(pvnames) % loop through all powervectors
                tpvname = pvnames{c};
                if ~isfield(tband.powervectors, tpvname) || isempty(tband.powervectors.(tpvname))
                    continue;
                end
                tpv = tband.powervectors.(tpvname){a};
                [bincounts, powerbins] = hist(tpv, 100);
                tband.powerhistograms.(tpvname){a}.powerbins = powerbins;
                tband.powerhistograms.(tpvname){a}.bincounts = bincounts;
            end
        end

        bands.(tbandname) = tband;
    end

    %% Save the results to a .mat file
    if ~exist('basepath', 'var') || isempty(basepath)
        basepath = pwd;
    end

    if ~exist('basename', 'var') || isempty(basename)
        basename = 'default';
    end

    save(fullfile(basepath, [basename '.SpectralBandPowersJH.mat']), 'bands');

    %% Plotting
    figs = [];
    % Power vs. Time
    for a = 1:length(specs)
        close all; % Ensure previous plots are closed
        ttitle = ['Channel ' num2str(a) ' Power Vs Time'];
        figs(end+1) = figure('Name', ttitle, 'Position', [100, 100, 1200, 800]);
        plotcounter = 0;
        for b = 1:length(bandnames)
            tbandname = bandnames{b};
            tband = bands.(tbandname);
            plotcounter = plotcounter + 1;
            subplot(4, 3, plotcounter);
            if ~isempty(tband.powervectors.All{a})
                plot(tband.powervectors.All{a});
                hold on;
                yl = get(gca, 'ylim');
                plot([lightsOnTime lightsOnTime], yl);
            else
                warning(['No power vector data to plot for band "', tbandname, '" on channel ', num2str(a)]);
            end
            title(tbandname);
            axis tight;
        end
        annotation('textbox', [0.5, 0.98, 0, 0], 'String', ttitle, 'FitBoxToText', 'on', 'HorizontalAlignment', 'center');
    end

    % Power vs. Time - Smoothed
    for a = 1:length(specs)  % for each channel
        ttitle = ['Channel ' num2str(a) ' Power Vs Time Smoothed 30s'];
        figs(end+1) = figure('Name', ttitle, 'Position', [100, 100, 1200, 800]);
        plotcounter = 0;
        for b = 1:length(bandnames) % for every band
            tbandname = bandnames{b};
            tband = bands.(tbandname);
            plotcounter = plotcounter + 1;
            subplot(4, 3, plotcounter);
            if ~isempty(tband.powervectors.All{a})
                plot(smooth(tband.powervectors.All{a}, 30));
                hold on;
                yl = get(gca, 'ylim');
                plot([lightsOnTime lightsOnTime], yl);
            else
                warning(['No power vector data to plot for band "', tbandname, '" on channel ', num2str(a)]);
            end
            title(tbandname);
            axis tight;
        end
        annotation('textbox', [0.5, 0.98, 0, 0], 'String', ttitle, 'FitBoxToText', 'on', 'HorizontalAlignment', 'center');
    end
end