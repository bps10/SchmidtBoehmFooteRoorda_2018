function plot_light_delivery_analysis(subject, save_plots)
    % distance to nearest S-cone as a function of saturation
    %
    %
    % USAGE
    % plot_s_cone_dist(subject, save_plots)
    %
    % INPUT
    % subject
    % save_plots    
    %
    % OUTPUT
    % plot of s-cone distance versus saturation
        
    if nargin < 2
        save_plots = false;
    end

    if nargin < 1
        subject = '20076R';
    end
    
    % get the data
    cones = load_data(subject, 1);

    % get data across all cones
    %summary = dat_summary(cones);
    
    delivery_errors = [];
    for c = 1:length(cones)
        cone = cones{c};
        if ~isempty(cone)
            delivery_errors = [delivery_errors; cone.delivery_error];
        end
    end
    
    fig = figure;
    histogram(delivery_errors(:, 5), 0:0.025:0.5);
    
    plots.nice_axes('delivery error (arcmin)', '# of trials', 20);
    
    Ntrials = sum(~isnan(delivery_errors(:, 5)));
    mean_error = nanmean(delivery_errors(:, 5));
    median_error = nanmedian(delivery_errors(:, 5));
    SEM_error = nanstd(delivery_errors(:, 5)) / sqrt(Ntrials);
    disp(' ')
    util.pprint(Ntrials, -1, 'N trials      ');
    util.pprint(mean_error, 3, 'mean error (arcmin)');
    util.pprint(median_error, 3, 'median error (arcmin)');
    util.pprint(SEM_error, 3, 'SEM error (arcmin)');    
    
    if save_plots
        plots.save_fig(fullfile('img', 'intensity', subject, ...
            'delivery_hist'), fig);
    end
end