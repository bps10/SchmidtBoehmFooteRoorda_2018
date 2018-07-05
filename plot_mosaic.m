function plot_mosaic(subject, bkgd, intensity_exp, stim_intensity, save_plots,...
		     plot_unknown_cones)
%
% USAGE
% plot_mosaic(subject, bkgd, intensity_exp, stim_intensity, save_plots,
%	      plot_unknown_cones)
%  
% stim_intensity    0 or -1 will average across 0.4 and 0.8

if nargin < 1 
    subject = '20076R';
end
if nargin < 2
    bkgd = 'white';
end
if nargin < 3
    intensity_exp = 1;
end
if nargin < 4    
    stim_intensity = -1; % which level to plot
end
if nargin < 5
    save_plots = 0;
end
if nargin < 6
    plot_unknown_cones = 0;
end
if strcmpi(subject, '20092L')
    % force the plot to have unknown cones because none are classified
    plot_unknown_cones = 1;
end

if intensity_exp == 0
    % in this case, plot which ever intensity was used (only one);
    stim_intensity = -1;
end

% get data for the subject
dat = load_data(subject, intensity_exp);
tested_cones = array.find_non_empty_cells(dat);
ntested_cones = length(tested_cones);

% get cones for the subject
cone_locs = cone_mosaic.load_locs(subject);

% get targeted cone locations
targeted_cone = get_stim_cone_locs(subject);

ncones = length(cone_locs(:, 1));

% make the plot of the whole mosaic
cols = [0.3 0.3 0.9; 0.3 0.9 0.3; 0.9 0.3 0.3; 0.2 0.2 0.2];
f = figure('Position', [100, 100, 625, 625]);
hold on;
axis square;
axis off;
% gray background (not working)
%set(gca,'Color',[0.1 0.1 0.1]);

cone_type = cone_locs(:, 3);
cone_type(cone_type < 1) = 4;

cones = cone_locs(:, 1:2);
for i = 1:ncones
    cone = cones(i, :);
    plot(cone(1), cone(2), 'o', 'MarkerFaceColor', ...
        cols(cone_type(i), :), 'markersize', 7, 'markeredgecolor', 'none');
end
xlim([0 max(max(cones))]);
ylim([0 max(max(cones))]);

% pie chart parameters
img_scale_factor = 1;
rad = 1;
if strcmpi(subject, '20092L')
    outer_rad = 4.;
else
    outer_rad = 2.75;
end
label = {'', '', '', '', '', ''}; % turn off percentage labels
colmap = [0.1 0.1 0.1; 1 1 1; 1 0.0 0.0; 0.1 0.9 0.1; 0.0 0.0 1; ...
    0.8 0.8 0;];
x = -rad:0.01:rad;
y = sqrt(rad ^ 2 - x .^ 2);
x_circle = [x -x];
y_circle = [y -y];
ind = [1 2 5 1];

% add on the pie charts
plotted_cones = false(length(tested_cones), 1);
plotted_cones(tested_cones) = true;
for c = 1:ntested_cones
    % make sure cone was tested
    cID = tested_cones(c);
    cone = dat{cID};
    
    % format the data for the cone of interest      
    if intensity_exp        
        if stim_intensity <= 0
            % 0 or -1 will average across 0.4 and 0.8
            hues = cone.hues_noNS(cone.stim_intensity_noNS >= 0.3, :);    
            seen_trials = sum(cone.seen_trials(cone.stim_intensity >= 0.3));
        else
            hues = cone.hues_noNS(cone.stim_intensity_noNS == ...
                stim_intensity, :);
            seen_trials = sum(cone.seen_trials(cone.stim_intensity == ...
                stim_intensity));% / length(cone.trials);            
        end
        % histogram data
        cone_dat = histcounts(hues(:), 0.5:1:5.5);    
        cone_dat = [cone_dat(5) cone_dat(1:4)];

    else            
        cone_dat = hist(cone.(bkgd)(:), 1:5);    
        cone_dat = [cone_dat(5) cone_dat(1:4)];
        seen_trials = cone.FoS_white * lenght(cone.trials);
    end
    % get the cone class and location for the cone
    coneclass = cone.type;    
    cone_loc = targeted_cone(cone.ID, 1:2);

    % make sure not an S-cone or rod and that the FoS is over 50%
    if coneclass ~= 1 && coneclass ~=-1 && sum(seen_trials) >= 5
        if coneclass ~= 0 || plot_unknown_cones
            add_pie(cone_dat, img_scale_factor, outer_rad, x_circle, ...
                y_circle, label, ind, colmap, coneclass, cone_loc, 'k');
        else
            plotted_cones(cID) = false;
        end
    else
        plotted_cones(cID) = false;
    end
end
set(gcf, 'color', [0.55 0.55 0.55]);
set(gca, 'color', [0.55 0.55 0.55]);


disp([num2str(sum(plotted_cones)) ' L/M-cones plotted']);
minx = min(targeted_cone(plotted_cones, 1)) - 10;
maxx = max(targeted_cone(plotted_cones, 1)) + 10;
miny = min(targeted_cone(plotted_cones, 2)) - 10;
maxy = max(targeted_cone(plotted_cones, 2)) + 10;

% need to make sure will crop a square region
if maxx - minx < maxy - miny
    maxx = maxx + ((maxy - miny) - (maxx - minx));
else
    maxy = maxy + ((maxx - minx) - (maxy - miny));
end
xlim([minx maxx]);
ylim([miny maxy]);

add_scale_bar(subject, [maxx maxy])

% save figure
if save_plots
    if intensity_exp
        name = fullfile('img', 'intensity', subject, ...
            [subject '_' bkgd '_bkgd' num2str(stim_intensity) 'intensity.pdf']);
    else
        name = fullfile('img', 'mosaic', [subject '_' bkgd '_bkgd']);
    end
    plots.save_fig(name, f, 0, 'pdf');
end
