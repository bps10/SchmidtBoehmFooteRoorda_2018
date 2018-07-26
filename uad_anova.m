function uad_anova(subject, save_plots)
    %

    if nargin < 2
        save_plots = false;
    end
    if nargin < 1
        subject = '20076R';
    end
    
    rng(21);
    
    % get the data
    cones = load_data(subject, 1);
    xy_loc = get_stim_cone_locs(subject);

    % first iterate over all cones and create an index for L and M cones.
    % S20092L does not have cone type information so we need to handle that
    % special case
    L_index = [];
    M_index = [];
    LM_ordered_index = [];
    for c = 1:length(cones)
        cone = cones{c};
        if ~isempty(cone)
            if strcmp(subject, '20092L')
                LM_ordered_index = [LM_ordered_index; cone.ID];
            else
                if cone.type == 2
                    M_index = [M_index; cone.ID];
                elseif cone.type == 3
                    L_index = [L_index; cone.ID];
                end
            end
        end
    end    
    if ~strcmp(subject, '20092L')
        LM_ordered_index = [M_index; L_index];
    end
    ncones = length(LM_ordered_index);

    xy_locations = zeros(ncones, 2);
    by_data = [];
    gr_data = [];
    coneID = [];
    coneType = [];
    conetypes_list = zeros(ncones, 1);
    mean_by_rg = zeros(ncones, 2);
    for c = 1:ncones
        cone = cones{LM_ordered_index(c)};
        if ~isempty(cone)
            if cone.type > 1 || strcmp(subject, '20092L')
                by = cone.uad_noNS(:, 1);
                gr = cone.uad_noNS(:, 2);
                
                mean_by_rg(c, :) = [mean(by), mean(gr)];

                by_data = [by_data; by];
                gr_data = [gr_data; gr];

                ID = ones(length(by), 1) .* c;
                coneID = [coneID; ID];
                coneType = [coneType; ones(length(by), 1) .* double(cone.type)];                
                
                conetypes_list(c) = cone.type;                
                
                xy_locations(c, :) = xy_loc(cone.ID, 1:2);

            end
        end
    end
    
    [~, ~, stat] = anova1(by_data, coneID);

    yb_compare = multcompare(stat, 0.05);
    plot_posthoc(ncones, yb_compare)
    
    [~, ~, stat] = anova1(gr_data, coneID);        
    gr_compare = multcompare(stat, 0.05);

    plot_posthoc(ncones, gr_compare)
    
    function plot_posthoc(ncones, comparison_mat)
        
        comp_mat = zeros(ncones, ncones);
        for idx = 1:length(comparison_mat)
            x = comparison_mat(idx, 1);
            y = comparison_mat(idx, 2);

            %multipleP = gr_compare(idx, 6) * yb_compare(idx, 6);
            %p = multipleP * (1 - log(multipleP));
            p_val = comparison_mat(idx, 6);
            
            comp_mat(x, y) = p_val;
            comp_mat(y, x) = p_val;
        end
        
        % Fill in diagonal with p=1.
        for idx = 1:ncones
            comp_mat(idx, idx) = 1;
        end

        figure;
        imagesc(log10(comp_mat), [-2.5 0]);
        colorbar();
        %colormap('gray')
        set(gca,'dataAspectRatio', [1 1 1])
        
    end

end
%     
%     
%     % stress, sstress, metricstress, metricsstress, sammon, strain
%     MDS = mdscale(comp_mat, 2, 'criterion', 'sstress', 'options', ...
%         statset('maxiter', 5000));
% 
%     %gmm = fitgmdist(MDS, 2);
%     %group = cluster(gmm, MDS) + 1;
%     
%     %model = fitcsvm(MDS, conetypes_list);
%     %[group, ~] = predict(model, MDS);
%     
%     group = kmeans(MDS, 2, 'options', ...
%         statset('maxiter', 5000));
%         
%     if sum(group(1:10) == 1) > 6
%         group = group + 1;
%     else
%         group(group == 1) = 3;
%     end
%     
%     fig = figure;
%     hold on;
%     colors = {'b', 'g', 'r'};
%     for cID = 1:ncones
%         if strcmp(subject, '20092L')
%             plot(MDS(cID, 1), MDS(cID, 2), [colors{group(cID)} 'o'], ...
%                 'markersize', 5.5, 'markerfacecolor', colors{group(cID)}, ...
%                 'linewidth', 1.25);     
%         else
%             
%             plot(MDS(cID, 1), MDS(cID, 2), [colors{group(cID)} 'o'], ...
%                 'markersize', 5.5, 'markerfacecolor', colors{conetypes_list(cID)}, ...
%                 'linewidth', 1.25);         
%         end
%     end    
%     
%     plots.nice_axes('dimension 1', 'dimension 2');
% 
%     if ~strcmp(subject, '20092L')
%         analyze_prediction(group, conetypes_list);
%     else
%         nLcones = sum(group == 3);
%         nMcones = sum(group == 2);
%         disp([num2str(nLcones) ' L-cones, ' num2str(nMcones) ' M-cones']);
%     end
%     
%     if save_plots
%         plots.save_fig(fullfile('img', 'intensity', subject,...
%             'mdscaling_results'), fig)
%     end
% 
%     % now plot the cone types on the mosaic
%     fig = figure;
%     axis equal;
%     axis off;
%     box off;
%     hold on;
% 
%     for c = 1:ncones    
%         if ~strcmp(subject, '20092L')    
%             plot(xy_locations(c, 1), xy_locations(c, 2),...
%                 [colors{group(c)} 'o'], ...
%                     'markersize', 5.5, 'markerfacecolor', colors{conetypes_list(c)}, ...
%                     'linewidth', 1.25)
%         else
%             plot(xy_locations(c, 1), xy_locations(c, 2),...
%                 [colors{group(c)} 'o'], ...
%                     'markersize', 5.5, 'markerfacecolor', [0.5 0.5 0.5], ...
%                     'linewidth', 1.25)
%         end
%             %[colors{kmean_group(c)} '.'], 'markersize', 12);        
%     end   
% 
%     minxy = [min(xy_locations(:, 1)), min(xy_locations(:, 2))];
% 
%     % scale bar.
%     add_scale_bar(subject, max(xy_locations, [], 1));
% 
%     if save_plots
%         plots.save_fig(fullfile('img', 'intensity', subject,...
%             'predict_mosaic_t_score'), fig)
%     end    