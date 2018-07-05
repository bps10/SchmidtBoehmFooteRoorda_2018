function plot_s_cone_dist(subject, save_plots)
    % distance to nearest S-cone as a function of saturation
    %
    %
    % USAGE
    % plot_s_cone_dist(subject, save_plots)
    %
    % INPUT
    % subject       str. subject ID.
    % save_plots    bool. decide to save plots
    % thresh        float. A saturation threshold; remove anything below 
    %               this value. Default = 0 (no threshold).
    % OUTPUT
    % plot of s-cone distance versus saturation
    %
        
    if nargin < 2
        save_plots = false;
    end
    if nargin < 1
        subject = '20076R';
    end
    if nargin < 3
        thresh = 0.0;
    end
    
    % get the data
    cones = load_data(subject, 1);
    tested_cones = array.find_non_empty_cells(cones);

    intensities = unique(cones{tested_cones(1)}.stim_intensity);
    intensities = [intensities(2:end); -1];
    nintensities = length(intensities);    
    
    % get data across all cones
    summary = dat_summary(cones);
    
    fig = figure('Position', [100 100 650 600]);
    fontsize = 16;
    titleint = {'0.2' '0.4' '0.8' 'mean'};
    for in = 1:nintensities
        intensity = intensities(in);
        
        % find which index corresponding to intensity specified in input args
        ind = get_intensity_ind(intensity, summary);

        if ~isempty(summary.sat_dist_dat)
            % remove any NaN trials (this is especially relevant to the lowest
            % intensity trials where FoS can be 0 for some L/M cones).
            nan_inds = isnan(summary.sat_dist_dat(:, ind));
            no_nan = summary.sat_dist_dat(~nan_inds, :);
            
            % threshold if desired
            no_nan = no_nan(no_nan(:, ind) > thresh, :);
            
            subplot(2, 2, in);
            hold on;
            scatter(no_nan(:, 1), no_nan(:, ind), ...
                'ko', 'markerfacecolor', [0.5 0.5 0.5], 'linewidth', 1.5)
            ylim([0 1]);
            set(gca, 'ytick', 0:0.25:1);
            
            stats.corr_regress(no_nan(:, 1), no_nan(:, ind), 1, ...
                'saturation vs. s-cone dist');
            plots.nice_axes('distance to S-cone (arcmin)', ...
                'mean saturation', fontsize);            
            title(['intensity: ' titleint{in} ' a.u.'], ...
                'fontweight', 'normal', 'fontsize', fontsize)
        end
    end

    meanfig = figure();
    
    intensity = intensities(end);

    % find which index corresponding to intensity specified in input args
    ind = get_intensity_ind(intensity, summary);

    % remove any NaN trials (this is especially relevant to the lowest
    % intensity trials where FoS can be 0 for some L/M cones).
    nan_inds = isnan(summary.sat_dist_dat(:, ind));
    no_nan = summary.sat_dist_dat(~nan_inds, :);

    % threshold if desired
    no_nan = no_nan(no_nan(:, ind) > thresh, :);

    hold on;
    scatter(no_nan(:, 1), no_nan(:, ind), ...
        'ko', 'markerfacecolor', [0.5 0.5 0.5], 'linewidth', 1.5)
    ylim([0 1]);
    xlim([0 4]);
    set(gca, 'ytick', 0:0.2:1);
    set(gca, 'xtick', 0:1:4);
    

    stats.corr_regress(no_nan(:, 1), no_nan(:, ind), 1, ...
        'saturation vs. s-cone dist');
    plots.nice_axes('distance to S-cone (arcmin)', ...
        'mean saturation', fontsize);            
            
    if save_plots
        plots.save_fig(fullfile('img', 'intensity', subject, ...
            's_distance'), fig);
        plots.save_fig(fullfile('img', 'intensity', subject, ...
            's_distance_all_int'), meanfig);
        
    end

end