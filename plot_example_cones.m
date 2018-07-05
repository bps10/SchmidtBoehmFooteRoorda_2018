clearvars;
subject = '20076R';
markersize = 5.5;
cones = load_data(subject, 1);

intensities = unique(cones{173}.stim_intensity);

coneIDs = [148, 149, 150, 151, 152];
colors = {'b', 'g', 'r'};
fig = figure('position', [10 10 1200, 300]);

subplot(1, 3, 3);
hold on;
plots.format_uad_axes(1, 1, '', 13, 1);

for c = 1:length(coneIDs)
    % select out cone of interest for plotting
    cone = cones{coneIDs(c)};
    
    uad_mean = zeros(3, 2);
    uad_sem = zeros(3, 2);
    for int = 2:4 % skip blank trials
        intensity = intensities(int);
        int_inds = cone.stim_intensity_noNS == intensity;
        uad = cone.uad_noNS(int_inds, :);
        
        uad_mean(int - 1, :) = mean(uad);
        uad_sem(int - 1, :) = std(uad) ./ sqrt(length(uad));
        
    end
    % plot UAD
    subplot(1, 3, 3);
    h = plots.errorbarxy(uad_mean(:, 1), uad_mean(:, 2), ...
            uad_sem(:, 1), uad_sem(:, 2), ...
            {[colors{cone.type} 'o-'], 'k', 'k'});    
        
    h.hMain.LineWidth = 1.5;
    h.hMain.MarkerFaceColor = 'w';        
    set(h.hMain, 'MarkerSize', markersize);
    
    brightness_mean = zeros(4, 1);
    brightness_sem = zeros(4, 1);
    fos_mean = zeros(4, 1);
    fos_sem = zeros(4, 1);
    for int = 1:4
        intensity = intensities(int);
        int_inds = cone.stim_intensity == intensity;
        bright = cone.brightness_rating(int_inds, :);
        
        Ntot = length(bright);
        
        brightness_mean(int) = mean(bright);
        brightness_sem(int) = std(bright) ./ sqrt(Ntot);
        
        fos_mean(int) = sum(bright > 0) / Ntot;
        fos_sem(int) = sqrt(fos_mean(int) * (1 - fos_mean(int))) ./ ...
            sqrt(Ntot);
        
    end
    % plot brightness
    subplot(1, 3, 1);
    hold on;
    errorbar(intensities, brightness_mean, brightness_sem, 'ko',...
        'markerfacecolor', colors{cone.type})
    
    params0 = [3.5, 0.01, 1.0];
    [fit, chi] = psycho.fit_stevens_law(intensities, brightness_mean, ...
        params0); 
    xvals = intensities(1):0.02:intensities(end);
    plot(xvals, psycho.stevens_law(xvals, fit), ...
        [colors{cone.type} '-'], 'linewidth', 1.25);    
    
    xlim([0 1])
    ylim([0 5])
    set(gca, 'xtick', 0:0.25:1, 'ytick', 0:1:5);
    plots.nice_axes('stimulus intensity', 'brightness rating');
    
    % plot FoS
    subplot(1, 3, 2);
    hold on;
    errorbar(intensities, fos_mean, fos_sem, 'ko', ...
        'markerfacecolor', colors{cone.type})
    
    results.intensity = intensities;
    results.response = fos_mean;
    [pBest, loglike, h] = psycho.fit_psychometric_func(results, ...
        [], colors{cone.type}, 1, 0, 'weibull');
    
    xlim([0 1])
    ylim([0 1])
    set(gca, 'xtick', 0:0.25:1, 'ytick', 0:0.25:1);
    h.LineWidth = 1.25;
    plots.nice_axes('stimulus intensity', 'frequency of seeing')    
end
savename = fullfile('img', 'intensity', subject, 'example_cones148_150');
plots.save_fig(savename, fig, 1, 'pdf');