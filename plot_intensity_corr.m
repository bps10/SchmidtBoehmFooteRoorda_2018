function plot_intensity_corr(subject, save_plots)
if nargin < 1
    subject = '20076R';
end
if nargin < 2
   save_plots = 0; 
end

fontsize = 10;

% get data for the subject
cones = load_data(subject, 1);
tested_cones = array.find_non_empty_cells(cones);
ncones = length(tested_cones);

intensities = unique(cones{tested_cones(1)}.stim_intensity);
nintensities = length(intensities);

hue_angle = nan(length(cones), 3);
hue_angle_all = nan(length(cones), 3);
saturation = nan(length(cones), 3);
saturation_var = nan(length(cones), 3);
for c = 1:ncones
    cID = tested_cones(c);
    cone = cones{cID};
    for in = 2:nintensities        
        intensity = intensities(in);         
        
        % find the indexes of trials at given intensity
        intensity_inds = cone.stim_intensity_noNS == intensity;
        
        % make sure the cone was seen at least 4 times
        if sum(intensity_inds) > 3
            % compute mean saturation
            sat = mean(cone.saturation_noNS(intensity_inds));
            sat_var = var(cone.saturation_noNS(intensity_inds));
            
            % compute mean hue angle        
            angle = mean(compute_hue_angle(cone, intensity));
            
            if sat >= 0.1
                hue_angle(cID, in - 1) = angle;
            end
            hue_angle_all(cID, in - 1) = angle;
            saturation(cID, in - 1) = sat;           
            saturation_var(cID, in - 1) = sat_var;           
        end
    end
end


if strcmpi(subject, '20053R')
    xylim = [-160 160];
    ticks = -150:75:150;
else
    xylim = [-150 150];    
    ticks = -150:75:150;
end

fig1 = figure('Position', [78 78 350 725]);
subplot(3, 1, 1);
hold on;
axis equal;

hue_angle_t = hue_angle(all(~isnan(hue_angle(:, 2:3)), 2), :);
hue_angle_all = hue_angle_all(all(~isnan(hue_angle_all(:, 2:3)), 2), :);

disp('Cones with saturation values < 0.1 were excluded from analysis')
disp('High and medium intensity:');
util.pprint(length(hue_angle_all), 0, 'N tested cones:')
util.pprint(length(hue_angle_t), 0, 'N analyzed cones:')
disp(' ')

xlim(xylim);
ylim(xylim);
plot(xylim, xylim, 'r-', 'linewidth', 1);
plot(hue_angle_t(:, 2), hue_angle_t(:, 3), 'ko', ...
    'markerfacecolor', [0.6 0.6 0.6]);
set(gca, 'xtick', ticks, 'ytick', ticks);

stats.corr_regress(hue_angle_t(:, 2), hue_angle_t(:, 3), 1, ...
    'med vs high int. hue angle');
plots.nice_axes('hue angle @ med. intensity', 'hue angle @ high intensity', fontsize)

subplot(3, 1, 2);
hold on;
axis equal;

hue_angle_t = hue_angle(all(~isnan(hue_angle(:, [1, 3])), 2), :);

xlim(xylim);
ylim(xylim);
plot(xylim, xylim, 'r-', 'linewidth', 1);
plot(hue_angle_t(:, 1), hue_angle_t(:, 3), 'ko', 'markerfacecolor', [0.6 0.6 0.6]);
set(gca, 'xtick', ticks, 'ytick', ticks);

stats.corr_regress(hue_angle_t(:, 1), hue_angle_t(:, 3), 1, ...
    'low vs high int. hue angle');
plots.nice_axes('hue angle @ low intensity', 'hue angle @ high intensity', fontsize)

subplot(3, 1, 3);
hold on;
axis equal;

hue_angle_t = hue_angle(all(~isnan(hue_angle(:, 1:2)), 2), :);

xlim(xylim);
ylim(xylim);
plot(xylim, xylim, 'r-', 'linewidth', 1);
plot(hue_angle_t(:, 1), hue_angle_t(:, 2), 'ko', 'markerfacecolor', [0.6 0.6 0.6]);
set(gca, 'xtick', ticks, 'ytick', ticks);

stats.corr_regress(hue_angle_t(:, 1), hue_angle_t(:, 2), 1, ...
    'low vs med int. hue angle');
plots.nice_axes('hue angle @ low intensity', 'hue angle @ med intensity', fontsize)


fig2 = figure('Position', [78 78 350 725]);
subplot(3, 1, 1);
hold on;
axis equal;

saturation_t = saturation(all(~isnan(saturation(:, 2:3)), 2), :);

xlim([0 1]);
ylim([0 1]);
plot([0 1], [0 1], 'r-', 'linewidth', 1);
plot(saturation_t(:, 2), saturation_t(:, 3), 'ko', 'markerfacecolor', [0.6 0.6 0.6]);

stats.corr_regress(saturation_t(:, 2), saturation_t(:, 3), 1, ...
    'med vs high int saturation');
plots.nice_axes('saturation @ med. intensity', 'saturation @ high intensity', fontsize)
set(gca, 'xtick', 0:0.25:1, 'ytick', 0:0.25:1);

subplot(3, 1, 2);
hold on;
axis equal;

saturation_t = saturation(all(~isnan(saturation(:, [1, 3])), 2), :);

xlim([0 1]);
ylim([0 1]);
plot([0 1], [0 1], 'r-', 'linewidth', 1);
plot(saturation_t(:, 1), saturation_t(:, 3), 'ko', 'markerfacecolor', [0.6 0.6 0.6]);

stats.corr_regress(saturation_t(:, 1), saturation_t(:, 3), 1, ...
    'low vs high int. saturation');
plots.nice_axes('saturation @ low intensity', 'saturation @ high intensity', fontsize)
set(gca, 'xtick', 0:0.25:1, 'ytick', 0:0.25:1);

subplot(3, 1, 3);
hold on;
axis equal;

saturation_t = saturation(all(~isnan(saturation(:, 1:2)), 2), :);

xlim([0 1]);
ylim([0 1]);
plot([0 1], [0 1], 'r-', 'linewidth', 1);
plot(saturation_t(:, 1), saturation_t(:, 2), 'ko', 'markerfacecolor', [0.6 0.6 0.6]);

stats.corr_regress(saturation_t(:, 1), saturation_t(:, 2), 1, ...
    'low vs med int. saturation');
plots.nice_axes('saturation @ low intensity', 'saturation @ med. intensity', fontsize)
set(gca, 'xtick', 0:0.25:1, 'ytick', 0:0.25:1);





fig3 = figure('Position', [78 78 350 725]);
subplot(3, 1, 1);
hold on;
axis equal;

saturation_t = saturation_var(all(~isnan(saturation_var(:, 2:3)), 2), :);

xlim([0 0.3]);
ylim([0 0.3]);
plot([0 1], [0 1], 'r-', 'linewidth', 1);
plot(saturation_t(:, 2), saturation_t(:, 3), 'ko', 'markerfacecolor', [0.6 0.6 0.6]);

stats.corr_regress(saturation_t(:, 2), saturation_t(:, 3), 1, ...
    'med vs high int saturation');
plots.nice_axes('saturation @ med. intensity', 'saturation @ high intensity', fontsize)
set(gca, 'xtick', 0:0.25:1, 'ytick', 0:0.25:1);

subplot(3, 1, 2);
hold on;
axis equal;

saturation_t = saturation_var(all(~isnan(saturation_var(:, [1, 3])), 2), :);

xlim([0 0.3]);
ylim([0 0.3]);
plot([0 1], [0 1], 'r-', 'linewidth', 1);
plot(saturation_t(:, 1), saturation_t(:, 3), 'ko', 'markerfacecolor', [0.6 0.6 0.6]);

stats.corr_regress(saturation_t(:, 1), saturation_t(:, 3), 1, ...
    'low vs high int. saturation');
plots.nice_axes('saturation @ low intensity', 'saturation @ high intensity', fontsize)
set(gca, 'xtick', 0:0.25:1, 'ytick', 0:0.25:1);

subplot(3, 1, 3);
hold on;
axis equal;

saturation_t = saturation_var(all(~isnan(saturation_var(:, 1:2)), 2), :);

xlim([0 0.3]);
ylim([0 0.3]);
plot([0 1], [0 1], 'r-', 'linewidth', 1);
plot(saturation_t(:, 1), saturation_t(:, 2), 'ko', 'markerfacecolor', [0.6 0.6 0.6]);

stats.corr_regress(saturation_t(:, 1), saturation_t(:, 2), 1, ...
    'low vs med int. saturation');
plots.nice_axes('saturation @ low intensity', 'saturation @ med. intensity', fontsize)
set(gca, 'xtick', 0:0.25:1, 'ytick', 0:0.25:1);

if save_plots
    save_name = fullfile('img', 'intensity', subject, 'intensity_corr_hue');
    plots.save_fig(save_name, fig1);    
    save_name = fullfile('img', 'intensity', subject, 'intensity_corr_sat');
    plots.save_fig(save_name, fig2);
end