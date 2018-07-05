function plot_t_score_matrix(subject, save_plots)
if nargin < 1
    subject = '20076R';
end
if nargin < 2
    save_plots = 0;
end

% first compute the data without the arcsine transformation
cones = load_data(subject, 1, 0.35, false);
tested_cones = array.find_non_empty_cells(cones);
ncones = length(tested_cones);
xy_loc = get_stim_cone_locs(subject);


coneClasses = zeros(ncones, 2);
xy_locations = zeros(ncones, 2);

%first organize based on cone classes.
for c = 1:ncones
    cone = cones{tested_cones(c)};        
    coneClasses(c, :) = [cone.ID cone.type];
    
    xy_locations(c, :) = xy_loc(cone.ID, 1:2);
end

if strcmp(subject, '20092L')
    lm_cones = coneClasses(coneClasses(:, 2) == 0, :);
    sorted_cones = lm_cones(:, 1);
    xy_locations = xy_locations(coneClasses(:, 2) == 0, :);
    coneClasses = lm_cones(:, 2);
    
    
else    
    m_cones = coneClasses(coneClasses(:, 2) == 2, :);
    l_cones = coneClasses(coneClasses(:, 2) == 3, :);
    xy_locations = [xy_locations(coneClasses(:, 2) == 2, :);...
        xy_locations(coneClasses(:, 2) == 3, :)];
    
    sorted_cones = [m_cones(:, 1); l_cones(:, 1)];
    coneClasses = [m_cones(:, 2); l_cones(:, 2)];

end

% S-cones will be removed now
ncones = length(sorted_cones);
t_score_matrix = zeros(ncones, ncones, 2);
p_val_matrix = zeros(ncones, ncones, 2);
for c1 = 1:ncones
    cone1 = cones{sorted_cones(c1)};    
    
    for c2 = 1:ncones            
        
        cone2 = cones{sorted_cones(c2)};
        
        % compute the t-statistic
        [~, pval, ~, stat] = ttest2(cone1.uad_noNS, ...
            cone2.uad_noNS);
        tScore = stat.tstat;
        
        t_score_matrix(c1, c2, :) = abs(tScore);
        p_val_matrix(c1, c2, :) = pval;

    end    
end

% NaN values indicate that vectors were all 0s. Replace with P=1, T=0.
t_score_matrix(isnan(t_score_matrix)) = 0;
p_val_matrix(isnan(p_val_matrix)) = 1;

fig = figure();

imagesc(log10(p_val_matrix(:, :, 1)), [-2.5 0]);

colorbar();
axis square;
xlim([1 ncones + 1])
ylim([1 ncones + 1])
set(gca, 'XAxisLocation', 'top')
plots.nice_axes('cones', 'cones')

if save_plots
    plots.save_fig(fullfile('img', 'intensity', subject,...
        'cone-by-cone_p_val_matrix_by'), fig)
end

pause(0.2)


fig = figure();

imagesc(log10(p_val_matrix(:, :, 2)), [-2.5 0]);

colorbar();
axis square;
xlim([1 ncones + 1])
ylim([1 ncones + 1])
set(gca, 'XAxisLocation', 'top')
plots.nice_axes('cones', 'cones')

if save_plots
    plots.save_fig(fullfile('img', 'intensity', subject,...
        'cone-by-cone_p_val_matrix_rg'), fig)
end


figure('Position', [100 100 450 800]);
subplot(2, 1, 1)

inds = p_val_matrix(:, :, 1) < 0.005;
t_by = t_score_matrix(:, :, 1) .* inds;

imagesc(t_by, [0 8]);
colorbar();
axis square;

subplot(2, 1, 2)

inds = p_val_matrix(:, :, 2) < 0.005;
t_rg = t_score_matrix(:, :, 2) .* inds;

imagesc(t_rg, [0 8]);
colorbar();

axis square;

% Do Multi-dimensional scaling on the output of the p-val or t-stat matrix
% The only difference between the two matrices are the values of the
% arbitrary dimensions.
rng(654654); % for reproducability
MDS = mdscale(p_val_matrix(:, :, 2), 2);

kmean_group = kmeans(MDS, 2);

% Kmeans produces the same clusters but the # assigned to each cluster
% randomly changes each time.
if sum(kmean_group(1:10) == 1) > 5
    kmean_group(kmean_group == 2) = 3;
    kmean_group(kmean_group == 1) = 2;        
else
    kmean_group(kmean_group == 1) = 3;
end

% plot
fig = figure();
hold on;

colors = {'b', 'g', 'r'};

for c = 1:ncones
    if strcmp(subject, '20092L')
        colors = {'b', 'r', 'g'};
        plot(MDS(c, 1), MDS(c, 2), [colors{kmean_group(c)} 'o'], ...
            'markersize', 5.5, 'markerfacecolor', colors{kmean_group(c)}, ...
            'linewidth', 1.25);     
    else
        plot(MDS(c, 1), MDS(c, 2), [colors{kmean_group(c)} 'o'], ...
            'markersize', 5.5, 'markerfacecolor', colors{coneClasses(c)}, ...
            'linewidth', 1.25);         
    end
end    
plots.nice_axes('dimension 1', 'dimension 2')

analyze_prediction(kmean_group, coneClasses)

if save_plots
    plots.save_fig(fullfile('img', 'intensity', subject,...
        'mdscaling_results'), fig)
end


fig = figure;
axis equal;
axis off;
box off;
hold on;

    
for c = 1:ncones    
    if ~strcmp(subject, '20092L')    
        plot(xy_locations(c, 1), xy_locations(c, 2),...
            [colors{kmean_group(c)} 'o'], ...
                'markersize', 5.5, 'markerfacecolor', colors{coneClasses(c)}, ...
                'linewidth', 1.25)
    else
        plot(xy_locations(c, 1), xy_locations(c, 2),...
            [colors{kmean_group(c)} 'o'], ...
                'markersize', 5.5, 'markerfacecolor', [0.5 0.5 0.5], ...
                'linewidth', 1.25)
    end
        %[colors{kmean_group(c)} '.'], 'markersize', 12);        
end   

minxy = [min(xy_locations(:, 1)), min(xy_locations(:, 2))];

% scale bar.
add_scale_bar(subject, max(xy_locations, [], 1));

if save_plots
    plots.save_fig(fullfile('img', 'intensity', subject,...
        'predict_mosaic_t_score'), fig)
end



    function analyze_prediction(prediction, coneClasses)
        
        correct_ids = prediction == coneClasses;

        n_correct = sum(correct_ids);
        util.pprint(n_correct, 0, 'N-correct:')
        util.pprint(length(coneClasses), 0, 'Total:')

        l_cones = coneClasses == 3;
        m_cones = coneClasses == 2;

        correct_l_cones = sum(l_cones & correct_ids);
        total_l_cones = sum(l_cones);

        correct_m_cones = sum(m_cones & correct_ids);
        total_m_cones = sum(m_cones);

        disp([num2str(correct_l_cones) ' out of ' num2str(total_l_cones) ...
            ' L-cones correctly identified']);
        disp([num2str(correct_m_cones) ' out of ' num2str(total_m_cones) ...
            ' M-cones correctly identified']);   

        confuse_mat = [correct_l_cones, total_l_cones - correct_l_cones;...
            total_m_cones - correct_m_cones, correct_m_cones];

        stats.cohens_kappa(confuse_mat, 1);
        disp(' ')
    
