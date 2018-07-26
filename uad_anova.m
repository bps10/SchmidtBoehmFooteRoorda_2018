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
    
    savename = fullfile('img', 'intensity', subject);
    files.check_for_dir(savename);
    % analyze blue-yellow dimension
    [~, anovatab, stat] = anova1(by_data, coneID);
    if save_plots        
        writetable(table(anovatab), fullfile(savename, 'anova_Ftest_BY.csv'));
    end    
    % posthoc comparisons
    yb_compare = multcompare(stat, 0.05);
    fig = plot_posthoc(ncones, yb_compare);
    if save_plots
        plots.save_fig(fullfile(savename, 'anova_multcomp_BY'), fig);
    end    
    
    % now analyze green-red dimension
    [~, anovatab, stat] = anova1(gr_data, coneID);  
    if save_plots        
        writetable(table(anovatab), fullfile(savename, 'anova_Ftest_RG.csv'));
    end    
    % posthoc tests    
    gr_compare = multcompare(stat, 0.05);
    fig = plot_posthoc(ncones, gr_compare);
    if save_plots
        plots.save_fig(fullfile(savename, 'anova_multcomp_RG'), fig);
    end    

    function fig = plot_posthoc(ncones, comparison_mat)
        
        comp_mat = zeros(ncones, ncones);
        for idx = 1:length(comparison_mat)
            x = comparison_mat(idx, 1);
            y = comparison_mat(idx, 2);

            p_val = comparison_mat(idx, 6);
            
            comp_mat(x, y) = p_val;
            comp_mat(y, x) = p_val;
        end
        
        % Fill in diagonal with p=1.
        for idx = 1:ncones
            comp_mat(idx, idx) = 1;
        end

        fig = figure;
        imagesc(log10(comp_mat), [-2.5 0]);
        colorbar();
        %colormap('gray')
        set(gca,'dataAspectRatio', [1 1 1])            
        
    end

end
