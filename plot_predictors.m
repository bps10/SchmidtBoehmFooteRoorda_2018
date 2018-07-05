function plot_predictors(subject, save_plots)
    if nargin < 1
        subject = '20076R';
    end
    if nargin < 2
       save_plots = 0; 
    end

    % get data for the subject29.
    cones = load_data(subject, 1);
    tested_cones = array.find_non_empty_cells(cones);
    ncones = length(tested_cones);

    % plot
    fig = figure('Position', [100 100 525 750]);
    hold on;

    hue_angles = zeros(ncones, 2);
    uad = zeros(ncones, 2);
    conetypes = zeros(ncones, 1);
    for c = 1:ncones
        cID = tested_cones(c);
        cone = cones{cID};
        % compute mean saturation
        saturation = mean(cone.saturation_noNS);
        
        % uad        
        uad(c, :) = mean(cone.uad_noNS, 1);
        
        % compute mean hue angle
        angle = mean(compute_hue_angle(cone));

        hue_angles(c, 1) = angle;
        hue_angles(c, 2) = saturation;
        conetypes(c) = cone.type;

    end
    lm_cones = conetypes > 1;
    hue_angles = hue_angles(lm_cones, :);
    conetypes = conetypes(lm_cones);
    uad = uad(lm_cones, :);
    
    l_cones = conetypes == 3;
    m_cones = conetypes == 2;
    
    boxplot(hue_angles(:, 1), conetypes);

    set(gca, 'xticklabel', {'M-cones', 'L-cones'}, 'linewidth', 2)
    
    plots.nice_axes('', 'hue angle')        
    
    % percent variance explained.
    % ------------------------ Hue angles, all cones
    Ncones = length(hue_angles(:, 1));
    
    variance = d(hue_angles(:, 1), mean(hue_angles(:, 1)));
    
    s_variance = sum(abs([hue_angles(l_cones, 1) - mean(hue_angles(l_cones, 1));...
        hue_angles(m_cones, 1) - mean(hue_angles(m_cones, 1))]) .^ 2) / Ncones;
    
    explained = (1 - s_variance / variance) * 100;
    
    disp('Hue angles:');
    util.pprint(length(hue_angles), 0, 'N cones:')
    util.pprint(explained, 2, '%% variance explained');
    disp(' ')
    
    % ------------------------ Hue angles, low saturation cones excluded
    saturation_thresh = hue_angles(:, 2) >= 0.1;
    
    l_cones_sat = l_cones & saturation_thresh;
    m_cones_sat = m_cones & saturation_thresh;
    
    Ncones = length(hue_angles(saturation_thresh));
    
    variance = d(hue_angles(saturation_thresh, 1), ...
        mean(hue_angles(saturation_thresh, 1)));
    
    s_variance = sum(abs([hue_angles(l_cones_sat, 1) - ...
        mean(hue_angles(l_cones_sat, 1));...
        hue_angles(m_cones_sat, 1) - ...
        mean(hue_angles(m_cones_sat, 1))]) .^ 2) / Ncones;
    
    explained = (1 - s_variance / variance) * 100;
    
    disp('Hue angles (low saturation excluded):');
    util.pprint(Ncones, 0, 'N cones:')
    util.pprint(explained, 2, '%% variance explained');
    disp(' ')    
    
    % ------------------------
    Ncones = length(hue_angles(:, 2));
    
    variance = d(hue_angles(:, 2), mean(hue_angles(:, 2)));
    
    s_variance = sum(abs([hue_angles(l_cones, 2) - mean(hue_angles(l_cones, 2));...
        hue_angles(m_cones, 2) - mean(hue_angles(m_cones, 2))]) .^ 2) / Ncones;
    
    explained = (1 - s_variance / variance) * 100;
    
    disp('Saturation:');
    util.pprint(length(hue_angles), 0, 'N cones:')
    util.pprint(explained, 2, '%% variance explained');
    disp(' ')
    
if save_plots
    save_name = fullfile('img', 'intensity', subject, 'box_whisker_cone_type');
    plots.save_fig(save_name, fig);
end
    
    function distance = d(x, y)
        
        distance = sum(abs(x - y) .^ 2) / length(x);
        
    
    
    