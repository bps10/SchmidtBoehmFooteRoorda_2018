function [FoS, intensities, catch_trials] = dat_compute_FoS(subject)
    % USAGE
    % FoS = dat_compute_FoS(subject)
    %
    % RETURNS
    % n x 12 matrix. Col 1 = cone type, col 2:4 = Pseen, col 5:8 = N
    % trials, col 9:12 = SE (sqrt(p*(1-p)/N)).
    if nargin < 1
        subject = '20076R';
    end
    
    % get the data
    cones = load_data(subject, 1);

    % get data across all cones
    summary = dat_summary(cones);

    FoS = zeros(summary.ncones, 13);
    count = 1;
    catch_trials = [0 0];
    for c = 1:length(cones)
        cone = cones{c};
        if ~isempty(cone)
            intensities = unique(cone.stim_intensity);
            FoS(count, 1) = cone.type;
            for in = 1:length(intensities)
                intensity = intensities(in);
                inds = cone.stim_intensity == intensity;
                seen = cone.brightness_rating(inds) > 0;
                pseen = sum(seen) / length(seen);  
                Ntrials = length(seen);
                FoS(count, in + 1) = pseen;
                FoS(count, in + 5) = Ntrials;
                FoS(count, in + 9) = sqrt(pseen .* (1 - pseen) ./ Ntrials);
                FoS(count, 13) = cone.ID;
                if in == 1
                    catch_trials = catch_trials + [sum(seen) length(seen)];
                end
                    
            end
            count = count + 1;
        end    
    end
end