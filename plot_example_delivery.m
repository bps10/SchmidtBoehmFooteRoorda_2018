clearvars

contour_edges_delivery = [0.1 0.19 0.48];

contour_edges_lightspread = [0.034 0.1 0.38];

sumnorm = imread(['dat/20076R/img/7_6_2017/'...
    'sumnorm_20076R_V001_stabilized_06Jul2017x105407_350_376.tif']);

load('dat/20076R/intensity/raw/data_color_naming_06Jul2017x110843.mat');

% taken from experimental notes from July 6, 2017.
tca_x = -18;
tca_y = -1;

colors = {'m', 'r', 'g', 'b', 'y', 'c'};
alltrials = exp_data.delivery_error_raw(:, 1);
bad_deliveries = exp_data.delivery_error(...
    exp_data.delivery_error(:, 6) > 0.35, 1);
bad_indexes = ismember(alltrials, bad_deliveries);
delivery_data = exp_data.delivery_error_raw(~bad_indexes, :);
coneids = exp_data.coneids;
coneids(bad_deliveries) = 0;
alltrials = alltrials(~bad_indexes);

subject = '20076R';
% load data
cones = load_data(subject, true);
targeted_cones = array.find_non_empty_cells(cones);
ncones = length(targeted_cones);

params = light_capture.gen_default_params();
params.subject = subject(1:5); % crop off letter
params.scaling = 545; % pix/deg of AOSLO
params.defocus = 0.05; % Diopters
params.test_ecc = 1.5; % degrees
params.pupil_size = 6.5; % mm

params = light_capture.compute_field_size(params);
params = light_capture.gen_stimulus(params);
params = light_capture.GeneratePSF(params);
params = light_capture.gen_retina_image(params);
retinal_image = params.retina_image;
retinal_image = retinal_image ./ sum(retinal_image(:));


fig = figure('Position', [10 10 800 300]);

subplot(1, 3, 1);
axis square;
hold on;
imshow(sumnorm);

light_distribution = zeros(size(sumnorm, 1), size(sumnorm, 2),...
    exp_data.num_locations);
contour_encircled_deliveries = zeros(length(exp_data.num_locations), ...
    length(contour_edges_lightspread));
for coneID = 1:exp_data.num_locations
    conetrials = find(coneids == coneID);
    if ~isempty(conetrials)
        conetrials = ismember(alltrials, conetrials);
        cone = delivery_data(conetrials, :);

        xdat = cone(:, 3) - tca_x;
        ydat = cone(:, 4) - tca_y;
        scatter(xdat, ydat, 15, 'o', ...
            'markerfacecolor', colors{coneID}, 'markerfacealpha', 0.05, ...
            'markeredgecolor', 'none');
        hold on;
        
        bins = min([xdat; ydat])-1.5:1:max([xdat; ydat]) + 1.5;
        centers = bins(1:end-1) + 0.5;
        delivery_counts = histcounts2(xdat, ydat, bins, bins);
        delivery_counts = delivery_counts ./ max(delivery_counts(:));
        
        [yv, xv] = meshgrid(centers, centers);
        
        delivery_contour = contour(xv, yv, delivery_counts, contour_edges_delivery);
        
        frac_deliveries = delivery_counts(:, :) ./ sum(sum(...
            delivery_counts(:, :)));
       
        for contourID = 1:length(contour_edges_delivery)
            ind1 = find((delivery_contour(1, :) == ...
                contour_edges_delivery(contourID)) == 1);
            if contourID == length(contour_edges_delivery)
                ind2 = length(delivery_contour) + 1;
            else
                ind2 = find((delivery_contour(1, :) == ...
                    contour_edges_delivery(contourID + 1)) == 1); 
            end

            con = delivery_contour(:, ind1 + 1:ind2 - 1);        

            sum_contour = 0;
            for x_ind = 1:size(frac_deliveries, 1)
                for y_ind = 1:size(frac_deliveries, 2)
                    posx = centers(x_ind);
                    posy = centers(y_ind);
                    
                    if inpolygon(posx, posy , con(1,:), con(2, :))
                        sum_contour = sum_contour + frac_deliveries(x_ind, y_ind);
                    end
                end
            end
            contour_encircled_deliveries(coneID, contourID) = sum_contour;

        end        

        delta = floor(size(retinal_image, 1) / 2);
        for xx = 1:size(delivery_counts, 1)
            for yy = 1:size(delivery_counts, 2)
                pos = [centers(xx) centers(yy)];
                
                % add each pixel
                light_distribution(pos(1) - delta: pos(1) + delta,...
                    pos(2) - delta: pos(2) + delta, coneID) = ...
                    light_distribution(pos(1) - delta: pos(1) + delta,...
                    pos(2) - delta: pos(2) + delta, coneID) + (delivery_counts(xx, ...
                    yy) .* retinal_image);
            end
        end
    end    
end

delta = 50;
xmean = mean(exp_data.delivery_error_raw(:, 3)) + 20;
ymean = mean(exp_data.delivery_error_raw(:, 4));
xlim([xmean - delta, xmean + delta])
ylim([ymean - delta, ymean + delta])

% add scale bar
% 540 pix/deg = 9 pix/arcmin
text(xmean + delta - 22, ymean + delta - 15, '2"', ...
    'fontsize', 15, 'color', 'w')
plot((1:18) + (xmean + delta - 27), ones(1, 18) + (ymean + delta - 8), ...
    'w-', 'linewidth', 5);

title('delivery locations', 'fontsize', 15, 'fontweight', 'normal')

disp(contour_encircled_deliveries);
%%
% 2.----- Add PSF * stimulus
subplot(1, 3, 2);
axis square
hold on;

% put retinal image in the center of zero array that is the same size as
% the image plots so that they pixel size is preserved.
retinal_image_0 = zeros(size(sumnorm));
halfsize = floor(size(retinal_image, 1) / 2);
center = floor(size(sumnorm, 1)) / 2;

retinal_image_0(center - halfsize:center + halfsize, ...
    center - halfsize:center + halfsize) = retinal_image;

imshow(retinal_image_0, [0 max(retinal_image(:))]);

% add same scale bar (no label).
plot((1:18) + (center + delta - 27), ones(1, 18) + center + delta - 8, ...
    'w-', 'linewidth', 5);

% set xy limits to be the same as above
xlim([center - delta, center + delta])
ylim([center - delta, center + delta])

title('PSF \otimes stimulus', 'fontsize', 15, 'fontweight', 'normal');

% 3.-------- Add total light distribution
subplot(1, 3, 3);
axis square
hold on;

% rotate to get in correct orientation with sumnorm
imshow(sumnorm); %flipud(rot90(light_distribution)))

contour_encircled_energies = zeros(length(exp_data.num_locations), ...
    length(contour_edges_lightspread));
for coneID = 1:exp_data.num_locations
    norm_light = light_distribution(:, :, coneID) ./ max(max(...
        light_distribution(:, :, coneID)));
    
    light_contour = contour(flipud(rot90(norm_light)), contour_edges_lightspread, ...
        'linewidth', 1, 'color', colors{coneID});
    
    frac_light = light_distribution(:, :, coneID) ./ sum(sum(...
        light_distribution(:, :, coneID)));
    
    
    for contourID = 1:length(contour_edges_lightspread)
        ind1 = find((light_contour(1, :) == contour_edges_lightspread(contourID)) == 1);
        if contourID == length(contour_edges_lightspread)
            ind2 = length(light_contour) + 1;
        else
            ind2 = find((light_contour(1, :) == contour_edges_lightspread(contourID + 1)) == 1); 
        end
        
        con = light_contour(:, ind1 + 1:ind2 - 1);        
        
        sum_contour = 0;
        for x_ind = 1:size(frac_light, 1)
            for y_ind = 1:size(frac_light, 2)
                if inpolygon(x_ind, y_ind , con(1,:), con(2, :))
                    sum_contour = sum_contour + frac_light(x_ind, y_ind);
                end
            end
        end
        contour_encircled_energies(coneID, contourID) = sum_contour;
        
    end
    
    
end
disp(contour_encircled_energies);

xlim([xmean - delta, xmean + delta])
ylim([ymean - delta, ymean + delta])

% add same scale bar (no label).
plot((1:18) + (xmean + delta - 27), ones(1, 18) + (ymean + delta - 8), ...
    'w-', 'linewidth', 5);

title('light distribution', 'fontsize', 15, 'fontweight', 'normal')


plots.save_fig(fullfile('img', 'light_delivery.pdf'), fig);
plots.save_fig(fullfile('img', 'light_delivery.svg'), fig);
