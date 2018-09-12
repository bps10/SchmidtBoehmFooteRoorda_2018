subject = '20076R';

filename = fullfile('img', subject, [subject '_pie.gif']);

% get data for the subject
dat = load_data(subject, 1);
tested_cones = array.find_non_empty_cells(dat);
ntested_cones = length(tested_cones);

if strcmp(subject, '20092L')
    add_unclassified = 1;
else
    add_unclassified = 0;
end

% pie chart parameters
img_scale_factor = 0.1;
rad = 0.4;
outer_rad = 1.15;

label = {'', '', '', '', '', ''}; % turn off percentage labels
colmap = [0.1 0.1 0.1; 1 1 1; 1 0.0 0.0; 0.1 0.9 0.1; 0.0 0.0 1; ...
    0.8 0.8 0;];
x = -rad:0.01:rad;
y = sqrt(rad ^ 2 - x .^ 2);
x_circle = [x -x];
y_circle = [y -y];
ind = [1 2 5 1];

% add on the pie charts
h = figure('position', [100, 100, 97, 97]);
xlim([-10 10])
ylim([-10 10])
set(gcf, 'color', [0.55 0.55 0.55]);
set(gca, 'color', [0.55 0.55 0.55]);
n = 1;
for c = 1:ntested_cones
    % make sure cone was tested
    cID = tested_cones(c);
    cone = dat{cID};
    
    % 0 or -1 will average across 0.4 and 0.8
    hues = cone.hues_noNS(cone.stim_intensity_noNS >= 0.3, :);    
    seen_trials = sum(cone.seen_trials(cone.stim_intensity >= 0.3));

    % get the cone class and location for the cone
    coneclass = cone.type;    
    cone_loc = [0, 0];
    % histogram data
    cone_dat = histcounts(hues(:), 0.5:1:5.5);    
    cone_dat = [cone_dat(5) cone_dat(1:4)];
    
    % make sure not an S-cone or rod and that the FoS is over 50%
    if coneclass ~= 1 && coneclass ~=-1 && sum(seen_trials) >= 5
        if coneclass ~= 0 || add_unclassified
            add_pie(cone_dat, img_scale_factor, outer_rad, x_circle, ...
                y_circle, label, ind, colmap, coneclass, cone_loc, 'k');
            drawnow;
            
            % Capture the plot as an image 
            frame = getframe(h); 
            im = frame2im(frame); 
            [imind,cm] = rgb2ind(im,256); 
            
            % Write to the GIF File 
            if n == 1 
                imwrite(imind, cm, filename, 'gif', 'Loopcount', inf); 
            else 
                imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append'); 
            end         
            n = n + 1;
        end
    end
end
