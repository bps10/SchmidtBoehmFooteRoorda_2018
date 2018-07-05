function main(subject, save_plots)
    % Run all analyses on hue, saturation, brightness scaling data
    %
    % USAGE
    % main_hue_and_brightness(subject, save_plots)
    %
    if nargin < 1
        subject = '20076R';
    end
    if nargin < 2
        save_plots = false;
    end

    % if saving write output to a text file for later.
    if save_plots
        bkgd = 'white';
        subjdir = fullfile('stats', 'intensity', subject);
        filename = fullfile(subjdir, [bkgd '_bkgd_analysis.txt']);
        if exist(filename, 'file') == 2
            delete(filename);
        end    
        files.check_for_dir(subjdir);
        
        diary(filename);

        disp([subject bkgd]);
        disp('======================='); 
        disp(' ');
        disp(datestr(now));
        disp('----------------------')
        disp(' ');
    end        
    
    disp('light delivery analysis');
    disp('++++++++++++++++++++++');    
    plot_light_delivery_analysis(subject, save_plots);
    disp(' ')
    
    disp('plot mosaic');
    disp('++++++++++++++++++++++');
    plot_mosaic(subject, 'white', 1, -1, save_plots);
    %plot_mosaic(subject, 'white', 1, 0.8, save_plots);
    disp(' ')
             
    disp('summary plots');
    disp('++++++++++++++++++++++');    
    plot_summary_analysis(subject, save_plots);
    disp(' ')
    
    disp('intensity correlations');
    disp('++++++++++++++++++++++');
    plot_intensity_corr(subject, save_plots);
    disp(' ');
    
    disp('uad plots');
    disp('++++++++++++++++++++++');
    plot_uad(subject, save_plots);
    disp(' ')    
    
    disp('t-test matrix and classification');
    disp('++++++++++++++++++++++');    
    plot_t_score_matrix(subject, save_plots);
    disp(' ')       

    if ~strcmp(subject, '20092L')
        % S20092L does not have a classified mosaic
        disp('percent variance explained');
        disp('++++++++++++++++++++++');
        plot_predictors(subject, save_plots);
        disp(' ') 

        disp('opponent neighborhood analysis')
        disp('++++++++++++++++++++++');
        plot_opponent_neighbors(subject, save_plots)
        disp(' ');

        disp('s-cone distance');
        disp('++++++++++++++++++++++');    
        plot_s_cone_dist(subject, save_plots);  
        disp(' ')    
    end        
    try
        disp('light capture analysis');
        disp('++++++++++++++++++++++');    
        plot_light_capture(subject, save_plots)
        disp(' ')
    catch ME
        disp(ME.message);
    end
    
    if save_plots
        diary OFF;
        close all;

        directory = fullfile('img', 'intensity', subject);
        save_name = [subject '_analysis_master.pdf'];
        files.make_combined_pdf(directory, save_name);
    
    end

