function plot_opponent_neighbors(subject, save_plots)
% plot_opponent_neighbors(subject, save_plots)
if nargin < 1
    subject = '20076R';
end
if nargin < 2
    save_plots = 0;
end
fontsize = 12;

cones = load_data(subject, 1);
tested_cones = array.find_non_empty_cells(cones);
ncones = length(tested_cones);

summary = zeros(ncones, 14);
intensities = unique(cones{tested_cones(1)}.stim_intensity);
for c = 1:ncones
    cone = cones{tested_cones(c)};
    % don't use S-cones
    if cone.type ~= 1
        hue_angles = compute_hue_angle(cone, -1, -1);
        summary(c, 1) = cone.type;
        summary(c, 2) = cone.nopponent_neighbors;
        summary(c, 6) = mean(cone.brightness_rating);
        summary(c, 10) = mean(cone.saturation_noNS);
        summary(c, 14) = mean(hue_angles);
        
        for intens = 2:4
            intensity = intensities(intens);
            summary(c, 1 + intens) = mean(cone.brightness_rating(...
                cone.stim_intensity_noNS == intensity));
            summary(c, 5 + intens) = mean(cone.saturation_noNS(...
                cone.stim_intensity_noNS == intensity));
            summary(c, 9 + intens) = mean(compute_hue_angle(cone, ...
                intensity, -1));                
        end
    end
end
summary = array.remove_zero_rows(summary);

l_cones = summary(:, 1) == 3;
m_cones = summary(:, 1) == 2;

% summary figure for all intensities: hue, saturation and brightness
fig0 = figure('Position', [20 20 300 750]);
metric = {'brightness', 'saturation', 'hue angle'};
c = 1;
for index = [6, 10, 14]
    subplot(3, 1, c);
    hold on;

    summary_L = summary(l_cones, :);
    summary_M = summary(m_cones, :);

    plot(summary_L(:, 2), summary_L(:, index), 'ro', ...
        'markerfacecolor', 'r')
    plot(summary_M(:, 2), summary_M(:, index), 'go', ...
        'markerfacecolor', 'g')
    
    if strcmp(metric{c}, 'saturation')        
        ylim([0 1]);
        set(gca, 'ytick', 0:0.25:1); 
    end

    if c < 3
        plots.nice_axes('', ['mean ' metric{c}], fontsize)
        % combine L and M cones in analysis
        nan_inds = isnan(summary(:, index));
        stats.corr_regress(summary(~nan_inds, 2), ...
            summary(~nan_inds, index),...
            1, ['n opponent neighbors vs ' metric{c}]);        
    else
        plots.nice_axes('# of non-like neighbors', ...
            ['mean ' metric{c}], fontsize)
        % keep L and M cones seperate for hue angles
        Lnan_inds = isnan(summary_L(:, index));
        stats.corr_regress(summary_L(~Lnan_inds, 2), ...
            summary_L(~Lnan_inds, index), 1, ...
            ['n opponent neighbors vs ' metric{c} ' L-cones']);
        Mnan_inds = isnan(summary_M(:, index));
        stats.corr_regress(summary_M(~Mnan_inds, 2), ...
            summary_M(~Mnan_inds, index), 1, ...
            ['n opponent neighbors vs ' metric{c} ' M-cones']);        
    end
    c = c + 1;
end

meanfig = figure();
hold on;

plot(summary(:, 2), summary(:, 10), 'ko', ...
    'markerfacecolor', [0.5 0.5 0.5], 'linewidth', 2)

ylim([0 1]);
set(gca, 'ytick', 0:0.2:1);

plots.nice_axes('# of non-like neighbors', ...
    ['mean ' metric{2}], 16)
% keep L and M cones seperate for hue angles
nan_inds = isnan(summary(:, 10));
stats.corr_regress(summary(~nan_inds, 2), ...
    summary(~nan_inds, 10), 1, ...
    ['n opponent neighbors vs ' metric{2} ' LM-cones']);


% now same as above for hue angle.
meanfig2 = figure();
hold on;

plot(summary(l_cones, 2), summary(l_cones, 14), 'ko', ...
    'markerfacecolor', 'r', 'linewidth', 2)
plot(summary(m_cones, 2), summary(m_cones, 14), 'ko', ...
    'markerfacecolor', 'g', 'linewidth', 2)

ylim([-180 180]);
set(gca, 'ytick', -150:50:150);

plots.nice_axes('# of non-like neighbors', ...
    ['mean ' metric{3}], 16)

% keep L and M cones seperate for hue angles
l_hue_summary = summary(l_cones, [2, 14]);
nan_inds = isnan(l_hue_summary(:, 2));
stats.corr_regress(l_hue_summary(~nan_inds, 1), ...
    l_hue_summary(~nan_inds, 2), 1, ...
    ['n opponent neighbors vs ' metric{3} ' L-cones']);

m_hue_summary = summary(m_cones, [2, 14]);
nan_inds = isnan(m_hue_summary(:, 2));
stats.corr_regress(m_hue_summary(~nan_inds, 1), ...
    m_hue_summary(~nan_inds, 2), 1, ...
    ['n opponent neighbors vs ' metric{3} ' M-cones']);
      

        
fig1 = figure('Position', [20 20 300 800]);
count = 1;
for intensity = 2:length(intensities)
    subplot(3, 1, count);
    hold on;
    % saturation
    if intensity > 0
        index = intensity + 5;
    else
        index = 10;
    end
    l_saturation = summary(l_cones, [2 index]);
    m_saturation = summary(m_cones, [2 index]);
    thresh = 0;
    l_sort = l_saturation(:, 2) > thresh;
    m_sort = m_saturation(:, 2) > thresh;
    plot(l_saturation(l_sort, 1), l_saturation(l_sort, 2), 'ro', ...
        'markerfacecolor', 'r')
    plot(m_saturation(m_sort, 1), m_saturation(m_sort, 2), 'go', ...
        'markerfacecolor', 'g')
    if intensity == length(intensities)
    plots.nice_axes('# of opponent neighbors', ...
        'mean saturation', fontsize)
    else
    plots.nice_axes('', ...
        'mean saturation', fontsize)
    end
    if intensity == -1
        print_int = 'all';
    else
        print_int = num2str(intensities(intensity));
    end
    title(['intensity: ' print_int], 'fontweight', 'normal',...
        'fontsize', fontsize)

    ylim([0 1]);
    set(gca, 'ytick', 0:0.25:1);    
    
    nan_inds = isnan(summary(:, index));
    stats.corr_regress(summary(~nan_inds & summary(:, index) > thresh, 2), ...
        summary(~nan_inds & summary(:, index) > thresh, index), ...
        1, ['n opponent neighbors vs saturation:' print_int]);
    
    count = count + 1;
end

fig2 = figure('Position', [20 20 300 800]);
count = 1;
for intensity = 2:length(intensities)
    % brightness
    subplot(3, 1, count);
    hold on;
    
    if intensity > 0
        index = intensity + 1;
    else
        index = 6;
    end
    
    plot(summary(l_cones, 2), summary(l_cones, index), 'ro', ...
        'markerfacecolor', 'r')
    plot(summary(m_cones, 2), summary(m_cones, index), 'go', ...
        'markerfacecolor', 'g')
    if intensity == length(intensities)
        plots.nice_axes('# of opponent neighbors', ...
            'mean brightness', fontsize)
    else
        plots.nice_axes('', ...
            'mean brightness', fontsize)
    end
    if intensity == -1
        print_int = 'all';
    else
        print_int = num2str(intensities(intensity));
    end
    title(['intensity: ' print_int], 'fontweight', 'normal',...
        'fontsize', fontsize)
    nan_inds = isnan(summary(:, index));
    
    stats.corr_regress(summary(~nan_inds, 2), summary(~nan_inds, index),...
        1, ['n opponent neighbors vs brightness: ' print_int]);
    
    count = count + 1;
end


fig3 = figure('Position', [20 20 560 800]);
count = 1;
for intensity = 2:length(intensities)
    
    if intensity > 0
        index = intensity + 9;
    else
        index = 14;
    end
    % hue angle
    subplot(3, 2, count);
    hold on;
    plot(summary(l_cones, 2), summary(l_cones, index), 'ro', ...
        'markerfacecolor', 'r')
    % analyze L cones
    summary_L = summary(l_cones, :);
    nan_inds = isnan(summary_L(:, index));
    
    if intensity == -1
        print_int = 'all';
    else
        print_int = num2str(intensities(intensity));
    end
    
    stats.corr_regress(summary_L(~nan_inds, 2), summary_L(~nan_inds, index),...
        1, ['L-cones; n opponent neighbors vs hue angle: ' print_int]);
    ylim([-150 150])
    xlim([0 6])
    set(gca, 'xtick', 0:6, 'ytick', [-100 -50 0 50 100]);
    
    if intensity == length(intensities)
        plots.nice_axes('# of opponent neighbors', ...
            'mean hue angle', fontsize)
    else
        plots.nice_axes('', 'mean hue angle', fontsize)
    end
    count = count + 1;
    
    % analyze M cones
    subplot(3, 2, count );
    hold on;
    summary_M = summary(m_cones, :);
    nan_inds = isnan(summary_M(:, index));
    
    stats.corr_regress(summary_M(~nan_inds, 2), summary_M(~nan_inds, index),...
        1, ['M-cones; n opponent neighbors vs hue angle: ' print_int]);
    
    plot(summary(m_cones, 2), summary(m_cones, index), 'go', ...
        'markerfacecolor', 'g')
    ylim([-150 150])
    xlim([0 6])    
    set(gca, 'xtick', 0:6, 'ytick', [-100 -50 0 50 100]);
    
    if intensity == length(intensities)
        plots.nice_axes('# of opponent neighbors', '', fontsize)
    else
        plots.nice_axes('', '', fontsize)
    end
    if intensity == -1
        print_int = 'all';
    else
        print_int = num2str(intensities(intensity));
    end
    title(['intensity: ' print_int], 'fontweight', 'normal',...
        'fontsize', fontsize)
    count = count + 1;
end


if save_plots
    plots.save_fig(fullfile('img', 'intensity', subject, ...        
        'opponent_summary'), fig0);    
    plots.save_fig(fullfile('img', 'intensity', subject, ...        
        'opponent_vs_saturation'), fig1);
    plots.save_fig(fullfile('img', 'intensity', subject, ...
        'opponent_vs_brightness'), fig2);
    plots.save_fig(fullfile('img', 'intensity', subject, ...
        'opponent_vs_hue_angle'), fig3); 
    plots.save_fig(fullfile('img', 'intensity', subject, ...
        'opponent_vs_saturation_all_int'), meanfig);    
    plots.save_fig(fullfile('img', 'intensity', subject, ...
        'opponent_vs_hue_angle_all_int'), meanfig2);        
    
end