clearvars;
subject = '20053R/intensity';

pix_per_degree = 545;
cross_size_pix = 17;
xcorr_thresh = 0.55;
overwrite_raw = 0; % Caution. Only use this if you are sure.
overwrite_summary = 1;

[datapaths, useable_sessions] = load_datapaths('dat', subject);
datapaths = {datapaths{useable_sessions}};
% uncomment to re-run on select sessions
%datapaths = {datapaths{1:8}};

delivery.add_delivery_error(subject, datapaths, pix_per_degree, ...
    cross_size_pix, xcorr_thresh, overwrite_raw, overwrite_summary);

% --- plot summary --- %

% iterate through each data field in the datapaths.
for d = 1:length(datapaths)
    exp_d = load(fullfile('dat', subject, 'raw', datapaths{d}.white.data_file));
    exp_data = exp_d.exp_data;

    % print out name of data being analyzed.
    disp(datapaths{d}.white);
    
    % generate plots
    [fig1, fig2] = delivery.delivery_error_analysis(exp_data.delivery_error);

    % save figures
    imgdir = fullfile('dat', subject, 'delivery_analysis', ...
        datapaths{d}.white.video_dir);
    
    figure(fig1);
    axis equal;
    
    plots.save_fig(fullfile(imgdir, 'locations'), fig1, [], 'pdf');
    plots.save_fig(fullfile(imgdir, 'histogram'), fig2, [], 'pdf');

    close all
end