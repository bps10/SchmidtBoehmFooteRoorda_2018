function plot_bayes(subject, save_plots)
    if nargin < 1
        subject = '20076R';
    end
    if nargin < 2
       save_plots = 0; 
    end

    lm_ratio = cone_mosaic.get_lm_ratio(subject, 0);
    fracL = lm_ratio / (lm_ratio + 1);

    % get data for the subject
    cones = load_data(subject, 1);
    tested_cones = array.find_non_empty_cells(cones);
    ncones = length(tested_cones);

    intensities = unique(cones{tested_cones(1)}.stim_intensity);
    nintensities = length(intensities);

    % for histograms
    edges = -170:20:175;
    xticks =  -150:75:150;

    % plot
    fig = figure('Position', [100 100 525 750]);
    hold on;
    fontsize = 12.5;

    hue_angles = zeros(ncones, 2);
    conetypes = zeros(ncones, 1);
    for c = 1:ncones
        cID = tested_cones(c);
        cone = cones{cID};
        % compute mean saturation
        saturation = mean(cone.saturation_noNS);
        % compute mean hue angle
        angle = mean(compute_hue_angle(cone));

        hue_angles(c, 1) = angle;
        hue_angles(c, 2) = saturation;
        conetypes(c) = cone.type;

    end
    
    l_index = conetypes == 3;
    m_index = conetypes == 2;

    l_cone_angles = hue_angles(l_index, 1);
    m_cone_angles = hue_angles(m_index, 1);

    util.pprint(length(l_cone_angles), 0, 'N L-cones:    ');
    util.pprint(sum(l_cone_angles > 15), 0, 'N L-cone angles > 15:');

    util.pprint(length(m_cone_angles), 0, 'N M-cones:    ');
    util.pprint(sum(m_cone_angles < -15), 0, 'N M-cone angles < -15:');
    
    l_angle_count = histcounts(l_cone_angles, edges);  
    l_angle_density = l_angle_count ./ sum(l_angle_count);
    
    m_angle_count = histcounts(m_cone_angles, edges);
    m_angle_density = m_angle_count ./ sum(m_angle_count);
 
    p_AnglegivenL = l_angle_density;
    p_AnglegivenL(isnan(p_AnglegivenL)) = eps;

    p_AnglegivenM = m_angle_density;
    p_AnglegivenM(isnan(p_AnglegivenM)) = eps;        

    p_angles = p_AnglegivenL .* fracL + p_AnglegivenM .* (1 - fracL);
    p_angles(p_angles == 0) = eps;
    
    p_LgivenAngle = p_AnglegivenL .* fracL ./ p_angles;
    p_MgivenAngle = p_AnglegivenM .* (1 - fracL) ./ p_angles;
    
    binsize = edges(2)-edges(1);
    centers = edges(1) + binsize/2:binsize:edges(end) - binsize/2;
    
    subplot(2, 1, 1)
    % priors
    stairs(edges, [p_AnglegivenL 0], 'r-', 'linewidth', 2);
    hold on;
    stairs(edges, [p_AnglegivenM 0], 'g-.', 'linewidth', 2);
    
    ylim([0 0.45]);
    xlim([min(xticks) max(xticks)])
    plots.nice_axes('hue angle (\theta)', 'likelihood p(\theta|L[M])', ...
        fontsize);
    set(gca, 'xtick', xticks);
       
    subplot(2, 1, 2)
    % posterior
    stairs(edges, [p_LgivenAngle 0], 'r-', 'linewidth', 2);
    hold on;
    stairs(edges, [p_MgivenAngle 0], 'g-.', 'linewidth', 2);
    
    correct_l_cones = sum(l_angle_count(p_LgivenAngle > 0.5));
    total_l_cones = sum(l_angle_count);
    
    correct_m_cones = sum(m_angle_count(p_MgivenAngle > 0.5));
    total_m_cones = sum(m_angle_count);    
    
    disp([num2str(correct_l_cones) ' out of ' num2str(total_l_cones) ...
        ' L-cones correctly identified']);
    disp([num2str(correct_m_cones) ' out of ' num2str(total_m_cones) ...
        ' M-cones correctly identified']);    
    
    xlim([min(xticks) max(xticks)])
    plots.nice_axes('hue angle (\theta)', 'posterior p(L[M]|\theta)', fontsize);
    set(gca, 'xtick', xticks, 'ytick', 0:0.25:1);
    
    if save_plots
        savename = fullfile('img', 'intensity', subject, 'bayes');
        plots.save_fig(savename, fig, 1, 'pdf');
    end
    
