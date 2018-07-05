function summary = dat_summary(cones)
    % summary = dat_summary(cones)
    %
    brightness = [];
    hue_scaling = [];
    stim_intensity = [];    
    trials = [];
    
    seen_trials = [];
    trials_noNS = [];
    hue_scaling_noNS = [];
    uad_noNS = [];
    saturation_noNS = [];
    stim_intensity_noNS = [];
    brightness_noNS = [];
    nsession = [];
    type_noNS = [];
    
    ncones = 0;
    % make summary data across all cones in separate function.
    for c = 1:length(cones)
        cone = cones{c};
        if ~isempty(cone)
            brightness = [brightness; cone.brightness_rating];
            hue_scaling = [hue_scaling; cone.hue_scaling];
            stim_intensity = [stim_intensity; cone.stim_intensity];
            trials = [trials; cone.trials];    

            seen_trials = [seen_trials; cone.seen_trials];
            trials_noNS = [trials_noNS; cone.trials_noNS];
            hue_scaling_noNS = [hue_scaling_noNS; cone.hues_noNS];
            uad_noNS = [uad_noNS; cone.uad_noNS];
            saturation_noNS = [saturation_noNS; cone.saturation_noNS];                        
            stim_intensity_noNS = [stim_intensity_noNS; cone.stim_intensity_noNS];
            brightness_noNS = [brightness_noNS; cone.brightness_noNS];
            type_noNS = [type_noNS; int32(ones(length(cone.trials_noNS), 1)) .* cone.type];
            
            nsession = [nsession; cone.nsession];
                        
            ncones = ncones + 1;
        end        
    end    
    % intensity of physical stimulus
    summary.stim_intensity = stim_intensity;  
    summary.intensities = unique(stim_intensity);
    summary.nintensities = length(summary.intensities);
    
    summary.ncones = ncones;            
    
    % results w/ not seen
    summary.brightness = brightness;
    summary.hue_scaling = hue_scaling;          
    summary.trials = trials;
    
    % results w/ only seen
    summary.seen_trials = seen_trials;
    summary.trials_noNS = trials_noNS;
    summary.hue_scaling_noNS = hue_scaling_noNS;
    summary.uad_noNS = uad_noNS;
    summary.saturation_noNS = saturation_noNS;
    summary.stim_intensity_noNS = stim_intensity_noNS;
    summary.brightness_noNS = brightness_noNS;
    summary.type_noNS = type_noNS;
    summary.nsession = nsession;                      
    
    % --- compute s-cone distance data
    sat_dist_dat = zeros(ncones, 10);
    count = 1;
    for c = 1:length(cones)
        cone = cones{c};
        if ~isempty(cone)        
            if cone.type ~= 1 % skip cases where cone type  S
                cone_sat = cone.saturation_noNS;% & stim_intensities_noNS == 0.5);
                cone_int = cone.stim_intensity_noNS;
                d = 2;
                for int = 2:length(summary.intensities)
                    intensity = summary.intensities(int);
                    dat_int = cone_sat(cone_int == intensity);
                    sat_dist_dat(count, d) = mean(dat_int);
                    sat_dist_dat(count, d + 1) = std(dat_int) / sqrt(length(...
                        dat_int));
                    d = d + 2;
                end
                % now mean across all intensities and s-cone dist
                sat_dist_dat(count, 8) = mean(cone.saturation_noNS);
                sat_dist_dat(count, 9) = std(cone.saturation_noNS) / sqrt(...
                    length(cone.saturation_noNS));
                sat_dist_dat(count, 10) = cone.type;
                
                % skip cases where cone type S or is unknown 
                if isfield(cone, 's_cone_dist')
                    if cone.s_cone_dist > 0
                        sat_dist_dat(count, 1) = double(cone.s_cone_dist)...
                            .* (1 / cone.pix_per_deg * 60);
                    end
                end

                count = count + 1;                
            end
        end
    end
    sat_dist_dat = array.remove_zero_rows(sat_dist_dat);
    summary.sat_dist_dat = sat_dist_dat;

    % 
    dataint = zeros(length(cones), summary.nintensities + 1);
    dataint_noNS = zeros(length(cones), summary.nintensities + 1);
    for c = 1:length(cones)
        cone = cones{c};
        if ~isempty(cone)
            % keep track of cone types
            dataint(c, 1) = cone.type;
            dataint_noNS(c, 1) = cone.type;
            for b = 2:length(summary.intensities) + 1
                intensity = summary.intensities(b - 1);
                
                ind = cone.stim_intensity == intensity;
                dataint(c, b) = mean(cone.brightness_rating(ind));  
                
                ind = cone.stim_intensity_noNS == intensity;
                dataint_noNS(c, b) = mean(cone.brightness_noNS(ind));
            end
        end
    end
    dataint = array.remove_zero_rows(dataint);
    dataint_noNS = array.remove_zero_rows(dataint_noNS);
    
    summary.dataint = dataint;
    summary.dataint_noNS = dataint_noNS;

end