function plot_uad(subject, save_plots)
    %

    if nargin < 2
        save_plots = false;
    end
    if nargin < 1
        subject = '20076R';
    end
    
    % get the data
    cones = load_data(subject, 1);

    % get data across all cones
    summary = dat_summary(cones);

    intensities = summary.intensities;
    nintensities = summary.nintensities;
    
    % UAD diagrams
    fig = figure('position', [50 50 620 750]); 
    hold on;
    for in = 1:length(intensities)
        subplot(nintensities / 2, nintensities / 2, in)
        plots.format_uad_axes([], [], ['intensity:  ' ...
            num2str(intensities(in))]);
    end    
    mean_data = zeros(length(cones), nintensities - 1, 3);    
    for c = 1:length(cones)
        cone = cones{c};
        if ~isempty(cone)
            for b = 1:length(intensities)
                intensity = intensities(b);
                ind = cone.stim_intensity_noNS == intensity;

                by = cone.uad_noNS(ind, 1);
                gr = cone.uad_noNS(ind, 2);
                
                
                subplot(nintensities / 2, nintensities / 2, b);
                hold on;

                h = plots.errorbarxy(mean(by), mean(gr), ...
                    std(by) / sqrt(length(by)), std(gr) / sqrt(length(gr)),...
                    {'ko', 'b', 'b'});
                h.hMain.LineWidth = 1.25;
                h.hMain.MarkerFaceColor = 'w';
                h.hMain.MarkerSize = 4.5;
                %h.hErrorbar(1)
                
                if intensity > 0 && ~isempty(by)
                    mean_data(c, b - 1, 1) = cone.type;
                    mean_data(c, b - 1, 2:3) = [mean(by), mean(gr)];
                end
            end                       
            
        end
    end

    if save_plots
        plots.save_fig(fullfile('img', 'intensity', subject, ...
            'uad_intensity'), fig);
    end

    % lms plots
    fig = figure('position', [50 50 620 750]); 
    hold on;
    classes = {'unknown', 's-cone/rod', 'm-cone', 'l-cone'};
    for c_type = 1:4
        subplot(2, 2, c_type)
        plots.format_uad_axes([], [], classes(c_type), 12);        
    end   
    
    stats_data = zeros(length(cones), 6);
    summary = zeros(length(cones), 3);
    count = 1;
    colors = {'k', 'b', 'g', 'r'};    
    for c = 1:length(cones)
        cone = cones{c};
        if ~isempty(cone)             
            by = cone.uad_noNS(:, 1);
            gr = cone.uad_noNS(:, 2);
            
            [~, pBY, ~, tstats] = ttest(by);
            stats_data(count, 1) = pBY;
            stats_data(count, 2) = tstats.tstat;
            [~, pRG, ~, tstats] = ttest(gr);
            stats_data(count, 3) = pRG;
            stats_data(count, 4) = tstats.tstat;       
            
            [~, pS, ~, tstats] = ttest(abs(by) + abs(gr));
            stats_data(count, 5) = pS;
            stats_data(count, 6) = tstats.tstat;                              

            conetype = double(cone.type + 1);
            subplot(nintensities / 2, nintensities / 2, conetype);
            hold on;

            meanBY = mean(by);
            meanGR = mean(gr);
            h = plots.errorbarxy(meanBY, meanGR, ...
                std(by) / sqrt(length(by)), std(gr) / sqrt(length(gr)),...
                {'ko', 'k', 'k'});
            h.hMain.LineWidth = 1.;
            h.hMain.MarkerFaceColor = 'w';
            h.hMain.MarkerSize = 3.5;            
            
            if pBY < 0.01 || pRG < 0.01
                color = colors{cone.type + 1};
                plot(meanBY, meanGR, [color '.'], 'markersize', 10)
            end
            
            summary(count, 1) = cone.type;
            summary(count, 2) = meanBY;
            summary(count, 3) = meanGR;
            
            count = count + 1;
        end
    end

    summary = array.remove_zero_rows(summary);
    
    hist_by_fig = figure('position', [50 50 620 750]); 
    hold on;
    bins = -1:0.1:1;
    for c_type = 1:4
        subplot(2, 2, c_type)
        title(classes{c_type})
        
        histogram(summary(summary(:, 1) == c_type - 1, 2), bins, ...
            'facecolor', [0.5 0.5 0.5], 'linewidth', 1.5)
        
        plots.nice_axes('y-b rating', 'count')
    end     
    
    hist_rg_fig = figure('position', [50 50 620 750]); 
    hold on;
    bins = -1:0.1:1;
    for c_type = 1:4
        subplot(2, 2, c_type)
        title(classes{c_type})    
        
        histogram(summary(summary(:, 1) == c_type - 1, 3), bins, ...
            'facecolor', [0.5 0.5 0.5], 'linewidth', 1.5)
        
        plots.nice_axes('g-r rating', 'count')
    end       
    

    % d-prime analysis
    for in = 1:3
        d = squeeze(mean_data(:, in, :));
        d = array.remove_zero_rows(d);
        
        l_cones = d(d(:, 1) == 3, :);
        m_cones = d(d(:, 1) == 2, :);
        
        disp(['intensity=' num2str(intensities(in+1))]);
        disp('b-y');
        stats.d_prime(l_cones(:, 2), m_cones(:, 2));
        disp('r-g');
        stats.d_prime(l_cones(:, 3), m_cones(:, 3));        
    end
    
    % remove S-cones
    if strcmp(subject, '20092L')
        stats_data = stats_data(summary(:, 1) < 1, :);
    else
        stats_data = stats_data(summary(:, 1) > 1, :);
    end
    %stats_data = array.remove_zero_rows(stats_data);
    
    % find p-vales < 0.01
    n_sig_by = sum(stats_data(:, 1) < 0.01);
    disp(['by: ' num2str(n_sig_by) ' / ' num2str(length(stats_data(:, 1))) ...
        ' significantly different from 0 mean'])
    n_sig_rg = sum(stats_data(:, 3) < 0.01);
    disp(['rg: ' num2str(n_sig_rg) ' / ' num2str(length(stats_data(:, 3))) ...
        ' significantly different from 0 mean'])    

    n_sig = sum(stats_data(:, 1) < 0.01 | stats_data(:, 3) < 0.01);
    disp(['rg: ' num2str(n_sig) ' / ' num2str(length(stats_data(:, 3))) ...
        ' significantly different from 0 mean'])
    
    if save_plots
        plots.save_fig(fullfile('img', 'intensity', subject, ...
            'uad_intensity_LMS'), fig);
        
        plots.save_fig(fullfile('img', 'intensity', subject, ...
            'hist_rg_LMS'), hist_rg_fig);   
        plots.save_fig(fullfile('img', 'intensity', subject, ...
            'hist_by_LMS'), hist_by_fig);           
    end   
        

end
