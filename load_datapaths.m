function [datapaths, useable_sessions] = load_datapaths(base_dir, subject) 
    % load_datapaths(base_dir, subject)
    % 
    % loads datapaths structure
    run(fullfile(base_dir, subject, 'data_paths.m'));
end