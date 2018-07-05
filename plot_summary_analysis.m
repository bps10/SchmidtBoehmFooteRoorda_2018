function plot_summary_analysis(subject, save_plots)
if nargin < 1
    subject = '20076R';
end
if nargin < 2
   save_plots = 0; 
end

fontsize = 12;

% get data for the subject
cones = load_data(subject, 1);
tested_cones = array.find_non_empty_cells(cones);
ncones = length(tested_cones);

intensities = unique(cones{tested_cones(1)}.stim_intensity);
nintensities = length(intensities);

results = zeros(nintensities, 25);
for in = 1:nintensities
    intensity = intensities(in);
    hue_angles = zeros(ncones, 1);
    saturation = zeros(ncones, 1);
    brightness = zeros(ncones, 1);
    fos = zeros(ncones, 1);
    conetypes = zeros(ncones, 1);
    for c = 1:ncones
        cID = tested_cones(c);
        cone = cones{cID};
        
        % find the indexes of trials at given intensity
        intensity_inds_noNS = cone.stim_intensity_noNS == intensity;
        intensity_inds = cone.stim_intensity == intensity;
        
        % compute mean saturation
        sat = mean(cone.saturation_noNS(intensity_inds_noNS));
        
        % brightness      
        bright = mean(cone.brightness_rating(intensity_inds));

        % fos
        fos_int = sum(intensity_inds_noNS) ./ sum(intensity_inds);
        
        % compute mean hue angle
        angle = mean(compute_hue_angle(cone, intensity));

        hue_angles(c) = angle;
        saturation(c) = sat;
        brightness(c) = bright;
        fos(c) = fos_int;
        conetypes(c) = cone.type;

    end

 
    if strcmpi(subject, '20092L')
        s_index = conetypes == 1;
        sqrtN = sqrt(sum(~isnan(hue_angles(~s_index))));
        sqrtN_Scones = sqrt(sum(~isnan(hue_angles(s_index))));
        
        
        results(in, 1) = intensity;
        results(in, 2) = nanmean(hue_angles(~s_index)); 
        results(in, 3) = nanstd(hue_angles(~s_index)) ./ sqrtN;
        
        results(in, 8) = nanmean(saturation(~s_index));
        results(in, 9) = nanstd(saturation(~s_index)) ./ sqrtN;
        
        results(in, 14) = nanmean(brightness(~s_index));
        results(in, 15) = nanstd(brightness(~s_index)) ./ sqrtN; 
        results(in, 18) = nanmean(brightness(s_index));
        results(in, 19) = nanmean(brightness(s_index)) ./ sqrtN_Scones;
        
        results(in, 20) = nanmean(fos(~s_index));
        results(in, 21) = nanstd(fos(~s_index)) ./ sqrtN;
        results(in, 24) = nanmean(fos(s_index));
        results(in, 25) = nanstd(fos(s_index)) ./ sqrtN_Scones;
    else
        if in == 1
            % for blanks use average from all trials
            l_index = ones(length(conetypes), 1);
            m_index = ones(length(conetypes), 1);
            s_index = ones(length(conetypes), 1);
        else
            l_index = conetypes == 3;
            m_index = conetypes == 2;   
            s_index = conetypes == 1;
        end

        N_Lcones = sum(~isnan(hue_angles(l_index)));
        N_Mcones = sum(~isnan(hue_angles(m_index)));
        N_Scones = sum(~isnan(hue_angles(s_index)));

        % compute hue angles
        results(in, 1) = intensity;
        results(in, 2) = nanmean(hue_angles(l_index, 1));
        results(in, 3) = nanstd(hue_angles(l_index, 1)) ./ sqrt(N_Lcones);
        results(in, 4) = nanmean(hue_angles(m_index, 1));
        results(in, 5) = nanstd(hue_angles(m_index, 1)) ./ sqrt(N_Mcones);
        results(in, 6) = nanmean(hue_angles(s_index, 1));
        results(in, 7) = nanstd(hue_angles(s_index, 1)) ./ sqrt(N_Scones);
        
        % now compute saturation for L and M cones
        results(in, 8) = nanmean(saturation(l_index));
        results(in, 9) = nanstd(saturation(l_index)) ./ sqrt(N_Lcones);
        results(in, 10) = nanmean(saturation(m_index));
        results(in, 11) = nanstd(saturation(m_index)) ./ sqrt(N_Mcones);
        results(in, 12) = nanmean(saturation(s_index));
        results(in, 13) = nanstd(saturation(s_index)) ./ sqrt(N_Scones);
        
        % now compute brightness for L and M cones
        results(in, 14) = nanmean(brightness(l_index));
        results(in, 15) = nanstd(brightness(l_index)) ./ sqrt(N_Lcones);
        results(in, 16) = nanmean(brightness(m_index));
        results(in, 17) = nanstd(brightness(m_index)) ./ sqrt(N_Mcones);
        results(in, 18) = nanmean(brightness(s_index));
        results(in, 19) = nanstd(brightness(s_index)) ./ sqrt(N_Scones);
        
        % now compute fos for L and M cones
        results(in, 20) = nanmean(fos(l_index));
        results(in, 21) = nanstd(fos(l_index)) ./ sqrt(N_Lcones);
        results(in, 22) = nanmean(fos(m_index));
        results(in, 23) = nanstd(fos(m_index)) ./ sqrt(N_Mcones);  
        results(in, 24) = nanmean(fos(s_index));
        results(in, 25) = nanstd(fos(s_index)) ./ sqrt(N_Scones); 
        
    end
    
end

% plot
fig = figure('Position', [100 100 425 1125]);
hold on;


[~, ~, catch_trials] = dat_compute_FoS(subject);

false_alarm_rate = catch_trials(1) ./ catch_trials(2);
    
pInit.b = 1.5;
pInit.t = 0.5;    
pInit.g = false_alarm_rate;

% set the aggregate false alarm rate.
results(1, [20, 22, 24]) = false_alarm_rate;

params0 = [3.5, 0.01, 1.0];
if strcmpi(subject, '20092L')

    subplot(4, 1, 1)
    hold on;

    % L/M-cones
    errorbar(results(:, 1), results(:, 20), results(:, 21), 'ko', ...
        'linewidth', 2, 'markerfacecolor', 'k')
    data.intensity = results(:, 1);
    data.response = results(:, 20);
    psycho.fit_psychometric_func(data, pInit, 'k', 1, 0, 'weibull');    

    % S-cones
    errorbar(results(:, 1), results(:, 24), results(:, 25), 'bo', ...
        'linewidth', 2, 'markerfacecolor', 'b');
    data.intensity = results(:, 1);
    data.response = results(:, 24);    
    psycho.fit_psychometric_func(data, pInit, 'b', 1, 0, 'weibull'); 
    
    ylim([0 1])
    xlim([0 1.05]);
    set(gca, 'xtick', 0:0.2:1, 'ytick', 0:0.2:1);    
    plots.nice_axes('', 'frequency of seeing', fontsize);
    
    subplot(4, 1, 2)
    hold on;

    errorbar(results(:, 1), results(:, 14), results(:, 15), 'ko', ...
        'linewidth', 2, 'markerfacecolor', 'k')
    psycho.fit_stevens_law(intensities, results(:, 14), params0, 1);

    errorbar(results(:, 1), results(:, 18), results(:, 19), 'bo', ...
        'linewidth', 2, 'markerfacecolor', 'b')    
    [~, ~, ~, ~, h] = psycho.fit_stevens_law(intensities, results(:, 18),...
        params0, 1);
    h.Color = 'b';
    
    ylim([0 5])
    xlim([0 1.05]);
    set(gca, 'xtick', 0:0.2:1, 'ytick', 0:1:5);
    plots.nice_axes('', 'brightness rating', fontsize); 
    
    subplot(4, 1, 3)
    hold on;

    errorbar(results(2:end, 1), results(2:end, 8), results(2:end, 9), 'ko-', ...
        'linewidth', 2, 'markerfacecolor', 'k')

    ylim([0 1])
    xlim([0 1.05]);
    set(gca, 'xtick', 0:0.2:1, 'ytick', 0:0.2:1);
    plots.nice_axes('', 'saturation', fontsize); 
    
    subplot(4, 1, 4)

    errorbar(results(2:end, 1), results(2:end, 2), results(2:end, 3), 'ko-', ...
        'linewidth', 2, 'markerfacecolor', 'k')

    ylim([-150, 150])
    xlim([0 1.05]);
    set(gca, 'xtick', 0:0.2:1, 'ytick', -150:50:150);
    plots.nice_axes('flash intensity (a.u.)', 'hue angle', fontsize);
       
else
    % --- FoS
    subplot(4, 1, 1)
    hold on;
    
    % L-cones        
    errorbar(results(:, 1), results(:, 20), results(:, 21), 'ro', ...
        'linewidth', 2, 'markerfacecolor', 'r')
    data.intensity = results(:, 1);
    data.response = results(:, 20);
    psycho.fit_psychometric_func(data, pInit, 'r', 1, 0, 'weibull');
    
    % M-cones
    errorbar(results(:, 1), results(:, 22), results(:, 23), 'go', ...
        'linewidth', 2, 'markerfacecolor', 'g');
    data.intensity = results(:, 1);
    data.response = results(:, 22);    
    psycho.fit_psychometric_func(data, pInit, 'g', 1, 0, 'weibull');
    
    % S-cones
    errorbar(results(:, 1), results(:, 24), results(:, 25), 'bo', ...
        'linewidth', 2, 'markerfacecolor', 'b');
    data.intensity = results(:, 1);
    data.response = results(:, 24);    
    psycho.fit_psychometric_func(data, pInit, 'b', 1, 0, 'weibull');    
    
    ylim([0 1])
    xlim([0 1.05]);
    set(gca, 'xtick', 0:0.2:1, 'ytick', 0:0.2:1);    
    plots.nice_axes('', 'frequency of seeing', fontsize);  
    
    % --- brightness
    subplot(4, 1, 2)
    hold on;

    % L-cones
    errorbar(results(:, 1), results(:, 14), results(:, 15), 'ro', ...
        'linewidth', 2, 'markerfacecolor', 'r')
    [fit, ~] = psycho.fit_stevens_law(intensities, results(:, 14), params0);   
    xvals = intensities(1):0.02:intensities(end);
    plot(xvals, psycho.stevens_law(xvals, fit), 'r-', 'linewidth', 2);
    
    % M-cones
    errorbar(results(:, 1), results(:, 16), results(:, 17), 'go', ...
        'linewidth', 2, 'markerfacecolor', 'g')
    [fit, ~] = psycho.fit_stevens_law(intensities, results(:, 16), params0);   
    xvals = intensities(1):0.02:intensities(end);
    plot(xvals, psycho.stevens_law(xvals, fit), 'g-', 'linewidth', 2);
    
    % S-cones
    errorbar(results(:, 1), results(:, 18), results(:, 19), 'bo', ...
        'linewidth', 2, 'markerfacecolor', 'b')
    [fit, ~] = psycho.fit_stevens_law(intensities, results(:, 18), params0);   
    xvals = intensities(1):0.02:intensities(end);
    plot(xvals, psycho.stevens_law(xvals, fit), 'b-', 'linewidth', 2);    
    
    ylim([0 5])
    xlim([0 1.05]);
    set(gca, 'xtick', 0:0.2:1, 'ytick', 0:1:5);
    plots.nice_axes('', 'brightness rating', fontsize);  
    
    % -- saturation
    subplot(4, 1, 3)
    hold on;

    errorbar(results(2:end, 1), results(2:end, 8), results(2:end, 9), 'ro-', ...
        'linewidth', 2, 'markerfacecolor', 'r')
    errorbar(results(2:end, 1), results(2:end, 10), results(2:end, 11), 'go-', ...
        'linewidth', 2, 'markerfacecolor', 'g')

    ylim([0 1])
    xlim([0 1.05]);
    set(gca, 'xtick', 0:0.2:1, 'ytick', 0:0.2:1);
    plots.nice_axes('', 'saturation', fontsize);  
    
    subplot(4, 1, 4)
    hold on;

    errorbar(results(2:end, 1), results(2:end, 2), results(2:end, 3), ...
        'ro-', 'linewidth', 2, 'markerfacecolor', 'r')
    errorbar(results(2:end, 1), results(2:end, 4), results(2:end, 5), 'go-', ...
        'linewidth', 2, 'markerfacecolor', 'g')

    ylim([-150, 150])
    xlim([0 1.05]);
    set(gca, 'xtick', 0:0.2:1, 'ytick', -150:50:150);
    plots.nice_axes('flash intensity (a.u.)', 'hue angle', fontsize);    
end

if save_plots
    save_name = fullfile('img', 'intensity', subject, 'intensity_summary');
    plots.save_fig(save_name, fig);    

end

