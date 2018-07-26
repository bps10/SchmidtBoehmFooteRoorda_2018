function plot_svm_classify(save_plots)

    if nargin < 1
       save_plots = 0; 
    end
    subjects = {'20053R', '20076R', '20092L'};
    
 
    all_data_uad = [];
    all_conetypes = [];
    all_ncones = 0;
    for s = 1:2
        [uad_mean, conetypes, ncones, ~] = get_data(subjects{s});
        
        classifier = fitcsvm(uad_mean, conetypes);

        plot_classifier(classifier, uad_mean, conetypes, ncones, ...
            subjects{s}, save_plots);
    
        all_data_uad = [all_data_uad; uad_mean];
        all_conetypes = [all_conetypes; conetypes];
        all_ncones = all_ncones + ncones;
        
    end


    classifier = fitcsvm(all_data_uad, all_conetypes);
    plot_classifier(classifier, all_data_uad, all_conetypes, ...
        all_ncones, 'combined', save_plots);


    % Now analyze 20092L data
    [uad_mean, conetypes, ncones, xy_locations] = get_data('20092L');

    nonS = conetypes < 1;
    uad_mean = uad_mean(nonS, :);
    xy_locations = xy_locations(nonS, :);
    conetypes = conetypes(nonS) + 1;
    ncones = length(conetypes);

    plot_classifier(classifier, uad_mean, conetypes, ncones, '20092L', save_plots);

    prediction = predict(classifier, uad_mean);

    fig = figure;
    axis equal;
    axis off;
    box off;
    hold on;
    colors = {'b', 'g', 'r'};
    for c = 1:ncones    
        plot(xy_locations(c, 1), xy_locations(c, 2),...
            [colors{prediction(c)} '.'], 'markersize', 22);        
    end   

    minxy = [min(xy_locations(:, 1)), min(xy_locations(:, 2))];
    text(10 + minxy(1), minxy(2) + 8, '5 arcmin', 'fontsize', 18)
    plot(minxy(1) + [10:64], minxy(2) + ones(55, 1), 'k-', 'linewidth', 2.5)

    if save_plots
        plots.save_fig(fullfile('img', 'intensity', 'all',...
            '20092L_predict_mosaic'), fig)
    end



    function plot_classifier(classifier, uad_mean, conetypes, ncones, ...
            subject, save_plots)
        % plot
        fig = figure();
        hold on;
        fontsize = 12.5;  

        plots.format_uad_axes(1, 1, [], fontsize, 1.5);

        colors = {'k', 'g', 'r'};
        for c = 1:ncones    
            plot(uad_mean(c, 1), uad_mean(c, 2), ...
                [colors{conetypes(c)} '.'], 'markersize', 12);        
        end                       

        d = 0.01;
        [x1Grid, x2Grid] = meshgrid(-0.5:d:0.5, -0.5:d:0.5);
        xGrid = [x1Grid(:),x2Grid(:)];

        [~, scores] = predict(classifier,xGrid);   

        prediction = predict(classifier, uad_mean);       

        if ~strcmp(subject, '20092L')
            analyze_prediction(prediction, conetypes);
        else
            nLcones = sum(prediction == 3);
            nMcones = sum(prediction == 2);
            disp([num2str(nLcones) ' L-cones, ' num2str(nMcones) ' M-cones']);
        end

        contour(x1Grid, x2Grid, reshape(scores(:,2), size(x1Grid)), ...
            [0 0], 'k');

        if save_plots
            plots.save_fig(fullfile('img', 'intensity', 'all',...
                [subject '_classify']), fig)
        end

    
    function [uad_mean, conetypes, ncones, xy_locations] = get_data(subject)
        
        % get data for the subject
        cones = load_data(subject, 1);
        tested_cones = array.find_non_empty_cells(cones);
        ncones = length(tested_cones);
        xy_loc = get_stim_cone_locs(subject);

        uad_mean = zeros(ncones, 2);
        conetypes = zeros(ncones, 1);
        xy_locations = zeros(ncones, 2);
        for c = 1:ncones
            cID = tested_cones(c);
            cone = cones{cID};

            % compute mean hue angle
            uad = cone.uad_noNS;        

            uad_mean(c, :) = mean(uad, 1);
            %saturation(c, :) = mean(saturation);
            conetypes(c) = cone.type;

            xy_locations(c, :) = xy_loc(cone.ID, 1:2);
        end
        if strcmp(subject, '20076R') || strcmp(subject, '20053R')
            lm_cones = conetypes > 1;
            uad_mean = uad_mean(lm_cones, :);
            conetypes = conetypes(lm_cones);
            ncones = length(conetypes);
        end