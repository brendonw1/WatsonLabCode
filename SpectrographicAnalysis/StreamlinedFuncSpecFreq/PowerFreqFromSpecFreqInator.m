function [bands, epochs] = PowerFreqFromSpecFreqInator(specs, lightsOnTime)
    if ~exist('lightsOnTime', 'var')
        lightsOnTime = 1; % seconds
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
    % Assuming 'specs' is a 1x2 struct array and you want to use the 'times' field from the first element
    timestamps = specs(1).times;

    epochs.BinInterval = [lightsOnTime length(timestamps)];

    % Define HourlyBinStarts and HourlyBinEnd
    HourlyBinStarts = (1:3600:23*3600+1)';
    HourlyBinEnd = (3600:3600:24*3600)';
    epochs.HourlyBinIntervals = [HourlyBinStarts HourlyBinEnd];

    % Calculate BinIndices within BinInterval
    bin_start_idx = epochs.BinInterval(1);
    bin_end_idx = epochs.BinInterval(2);
    epochs.BinIndices = bin_start_idx:bin_end_idx;

    % Calculate HourlyBinIndices manually
    for hidx = 1:24
        hourly_start = epochs.HourlyBinIntervals(hidx, 1);
        hourly_end = epochs.HourlyBinIntervals(hidx, 2);
        epochs.HourlyBinIndices{hidx} = hourly_start:hourly_end;
    end

    %% Extracting powers for each frequency band. (a is indexed over channels)
    for b = 1:length(bandnames) % for every band
        tbandname = bandnames{b};
        tband = getfield(bands, tbandname);

        % Find indices of relevant frequencies for this band
        tband.freqidxs = find(specs(1).freqs >= tband.startstopfreq(1) & specs(1).freqs < tband.startstopfreq(2));

        for a = 1:length(specs) % for every channel
            if strcmp(tbandname, 'thetaratio')
                tband.freqidxs = [];
                tband.subspectrograms{a} = [];

                % Add debug information:
                delta_power = bands.delta.powervectors.All{a};
                spindle_power = bands.spindle.powervectors.All{a};

                % Debug output for sizes
                fprintf('Channel %d: delta_power size = %d, spindle_power size = %d\n', a, length(delta_power), length(spindle_power));

                % Check if sizes of delta and spindle power vectors are equal
                if length(delta_power) == length(spindle_power)
                    tbandpower = bands.theta.powervectors.All{a} ./ (delta_power + spindle_power);
                else
                    % Handle mismatched sizes
                    % Option 1: Truncate to the shorter length
                    min_length = min(length(delta_power), length(spindle_power));
                    delta_power = delta_power(1:min_length);
                    spindle_power = spindle_power(1:min_length);
                    theta_power = bands.theta.powervectors.All{a}(1:min_length);
                    tbandpower = theta_power ./ (delta_power + spindle_power);
                    fprintf('Warning: Truncated delta and spindle power vectors for channel %d to length %d\n', a, min_length);
                end
            else
                tband.subspectrograms{a} = specs(a).spec(:, tband.freqidxs);
                tbandpower = mean(tband.subspectrograms{a}, 2);
                tband.powervectors.All{a, b} = tbandpower;
            end

            % Calculate mean power by hourly bin intervals
            for p = 1:24
                tbandpowervector = mean(tbandpower(epochs.HourlyBinIndices{p}));
                tband.powervectors.HourlyBin{a, p} = tbandpowervector; 
            end

            pvnames = fieldnames(tband.powervectors);
            for c = 1:length(pvnames) % loop through all powervectors to generate histogram versions of each
                tpvname = pvnames{c};
                tpv = getfield(tband.powervectors, tpvname);
                tpv = tpv{a};
                [bincounts, powerbins] = hist(tpv, 100);
                eval(['tband.powerhistograms.' tpvname '{a}.powerbins =  powerbins;']);
                eval(['tband.powerhistograms.' tpvname '{a}.bincounts =  bincounts;']);
            end
        end

        bands = setfield(bands, tbandname, tband);
    end

    % Save the results
    save(fullfile(basepath, [basename '.SpectralBandPowersJH.mat']), 'bands');
end