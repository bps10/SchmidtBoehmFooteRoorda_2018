function cones = load_data(subject, brightness, delivery_thresh, ...
    arcsine_transform)
    % cones = load_data(subject)
    %
    if nargin < 1
        subject = '20076R';
    end
    if nargin < 2
        brightness = 0;
    end
    if nargin < 3
        % maximum permissible delivery error (arcmin).
        delivery_thresh = 0.35;
    end
    if nargin < 4
        arcsine_transform = false;
    end

    if ~brightness
        base_dir = 'dat';

        % load a structure with paths to the raw data
        datapaths = load_datapaths(base_dir, subject);

        % get session info
        f = fullfile('dat', subject, 'coneIDs.csv');
        info = csvread(f, 1);

        % get cone IDs and convert to numerical code.
        conetypes = get_cone_types(subject);

        names = {'red', 'green', 'blue', 'yellow', 'white'};

        cones{length(datapaths) * 10} = [];
        for d = 1:length(datapaths)    

            % load white and blue data for each trial
            whitepath = fullfile(base_dir, subject, 'raw', datapaths{d}.white);
            a = load(whitepath);
            white_dat = a.exp_data;

            bluepath = fullfile(base_dir, subject, 'raw', datapaths{d}.blue);
            b = load(bluepath);
            blue_dat = b.exp_data;

            ntrials = blue_dat.ntrials;

            session_info = info(info(:, 2) == d, :);
            for coneN = 1:blue_dat.num_locations
                cone = {};
                % select out individual cone's data
                cone.white = white_dat.answer(white_dat.coneids == coneN, :);
                cone.blue = blue_dat.answer(blue_dat.coneids == coneN, :);

                % remove rows with all zeros
                cone.white = cone.white(any(cone.white, 2), :);
                cone.blue = cone.blue(any(cone.blue, 2), :);

                % add the master ID
                masterID = session_info(session_info(:, 3) == coneN, 4);
                cone.ID = masterID;

                % add the cone type (s=1, m=2, l=3)        
                cone.type = conetypes(conetypes(:, 1) == cone.ID, 2);

                % compute the frequency of seeing
                cone.FoS_blue = size(cone.blue, 1) / ntrials;
                cone.FoS_white = size(cone.white, 1) / ntrials;

                % response data for cone in Uniform Appearance Diagram
                % arcsine_tranform
                [by, rg] = color_naming.data_uad(cone.white, names, ...
                    arcsine_transform);
                cone.white_uad = [by rg];

                [by, rg] = color_naming.data_uad(cone.blue, names, ...
                    arcsine_transform);
                cone.blue_uad = [by rg];

                % save the data for later
                % first check if the cone might already exist
                if length(cones) >= masterID
                    if ~isempty(cones{masterID})
                        % if the cone already exists append the data and compute
                        % repeatability
                        cones{masterID}.white = [cones{masterID}.white; cone.white];
                        cones{masterID}.blue = [cones{masterID}.blue; cone.blue];
                        cones{masterID}.nsession = cones{masterID}.nsession + 1;

                        cones{masterID}.FoS_blue = size(cones{masterID}.blue, 1) /...
                            (ntrials * cones{masterID}.nsession);
                        cones{masterID}.FoS_white = size(cones{masterID}.white, 1) / ...
                            (ntrials * cones{masterID}.nsession); 

                    else
                        cones{masterID} = cone;
                        cones{masterID}.nsession = 1;
                    end

                else
                    cones{masterID} = cone;
                    cones{masterID}.nsession = 1;
                end

            end
        end
    
    else                
        
        % base directory for raw intensity data
        base_dir = fullfile('dat', subject, 'intensity', 'raw');
        
        % base directory for session/cone info file
        info = csvread(fullfile('dat', subject, 'intensity', 'coneIDs.csv'), 1);
        
        % get cone types for the subject
        conetypes = get_cone_types(subject);

        % load the datapaths and useable sessions for the subject
        [datapaths, useable_sessions] = load_datapaths('dat', ...
            fullfile(subject, 'intensity'));

        try
            % get cone locations
            stim_cones = get_stim_cone_locs(subject);

            % get cones for the subject
            cone_locs = cone_mosaic.load_locs(subject);

            % get nearest S-cone
%             s_cone_dist = mean(cone_mosaic.dist2cone_type(cone_locs, ...
%                 stim_cones(:, 1:2), 's', 3), 2);
            s_cone_dist = cone_mosaic.dist2cone_type(cone_locs, ...
                stim_cones(:, 1:2), 's', 1);
            
            [neighborIDs, ~] = knnsearch(cone_locs(:, 1:2), ...
                stim_cones(:, 1:2), 'k', 7);
            neighbor_types = cone_locs(neighborIDs(:, 2:7), 3);
            neighbor_types = reshape(neighbor_types, size(stim_cones, 1), 6);
            opponent_neighbors = neighbor_types ~= ...
                repmat(cone_locs(neighborIDs(:, 1), 3), 1, 6);
        catch
            % 
            s_cone_dist = [];
        end

        % find each cone and create a structure       
        cones{length(useable_sessions) * 5} = [];
        for session = useable_sessions
            % load the data from each session
            a = load(fullfile(base_dir, datapaths{session}.white.data_file));
            exp_data = a.exp_data;            
            ntrials = exp_data.ntrials;
                        
            % get session info
            session_info = info(info(:, 2) == session, :);
            
            for coneN = 1:exp_data.num_locations
                cone = {};
                % some meta data
                cone.names = exp_data.cnames;
                cone.pix_per_deg = 535;
            
                % select out individual cone's data
                cone_indexes = exp_data.coneids == coneN;                
                
                cone.trials = exp_data.trials(cone_indexes); 
                cone.session_index = ones(length(cone.trials), 1);
                
                cone.hue_scaling = exp_data.answer(cone_indexes, :);                
                cone.brightness_rating = exp_data.brightness_rating(...
                    cone_indexes)';                
                cone.stim_intensity = exp_data.intensities(cone_indexes); 
                
                % recode intensities into linear space
                cone.stim_intensity(cone.stim_intensity == 0.2) = 0.1228;
                cone.stim_intensity(cone.stim_intensity == 0.25) = 0.1934;
                cone.stim_intensity(cone.stim_intensity == 0.4) = 0.4633;
                cone.stim_intensity(cone.stim_intensity == 0.5) = 0.6535;
                cone.stim_intensity(cone.stim_intensity == 0.8) = 0.9773;
                
                
                % save delivery error for given cone.
                % organized by trial number. some are missing. 
                if isfield(exp_data, 'delivery_error') && delivery_thresh > 0
                    % find indices of trials for given cone
                    analyzed_trials = exp_data.delivery_error(:, 1);
                    ind = intersect(analyzed_trials, cone.trials);                
                    ind2 = ismember(analyzed_trials, cone.trials);
                    ind3 = ismember(cone.trials, ind);                    

                    % select out cone's delivery errors
                    cone.delivery_error = exp_data.delivery_error(ind2, 2:end);

                    % remove nan that not were caused by a blank trial.
                    bad_trials = isnan(cone.delivery_error(:, 2)) & ...
                        cone.stim_intensity(ind3) ~= 0;

                    % remove any trials with high delivery error. this
                    % index is now trials that were bad because
                    % delivery_error was not computed (nan, from above) or
                    % because the delivery error was greater than
                    % threshold.
                    bad_trials = bad_trials | cone.delivery_error(:, 5) >...
                        delivery_thresh;
                    cone.good_trials = ind(~bad_trials);
                    cone.good_index = ~bad_trials;
                
                    ind_raw = ismember(exp_data.delivery_error_raw(:, 1), ...
                        cone.good_trials);

                    cone.delivery_error = cone.delivery_error(...
                        cone.good_index, :);            
                    cone.delivery_error_raw = exp_data.delivery_error_raw(...
                        ind_raw, :);
                
                    % add session info for later analysis
                    cone.delivery_error_raw = [ones(sum(ind_raw), 1) ...
                        cone.delivery_error_raw];

                    % remove trials with large delivery errors.
                    if delivery_thresh > 0.0
                        cone.hue_scaling = cone.hue_scaling(cone.good_index, :);                
                        cone.brightness_rating = cone.brightness_rating(...
                            cone.good_index);                
                        cone.stim_intensity = cone.stim_intensity(cone.good_index); 
                        cone.session_index = ones(length(cone.stim_intensity), 1);                        
                    end
                else
                    cone.delivery_error_raw = NaN(length(cone.trials * ...
                        15), 5);
                    cone.delivery_error = NaN(length(cone.trials), 5);
                    cone.good_index = ones(length(cone.trials), 1);
                    cone.good_trials = (1:length(cone.trials))';
                    disp([datapaths{session}.white.data_file ...
                        ' does not have delivery error info']);
                end
                    
                % add the master ID
                masterID = session_info(session_info(:, 3) == coneN, 4);
                cone.ID = masterID;

                % add the cone type (s=1, m=2, l=3)  
                cone.type = conetypes(conetypes(:, 1) == cone.ID, 2);

                % compute the frequency of seeing
                %cone.FoS = size(cone.hue_scaling, 1) / ntrials;  

                % remove rows with all zeros       
                cone.seen_trials = cone.brightness_rating > 0;
                cone.trials_noNS = cone.trials(cone.seen_trials);
                cone.hues_noNS = cone.hue_scaling(cone.seen_trials, :);
                cone.session_index_noNS = ones(length(cone.trials_noNS), 1);                                
                
                if strcmp(cone.names{1}, 'red')
                    colornames = cone.names;
                else
                    colornames = {'red' 'green' 'blue' 'yellow' 'white'};
                end
                [by, gr] = color_naming.data_uad(cone.hues_noNS, ...
                    colornames, arcsine_transform);
                cone.uad_noNS = [by gr];
                
                % WRONG: sqrt((by .^ 2) + (gr .^ 2));
                
                cone.saturation_noNS = abs(by) + abs(gr);% sum(cone.hues_noNS < 5, 2) / ...
                    %size(cone.hues_noNS, 2);

                cone.stim_intensity_noNS = cone.stim_intensity(cone.seen_trials);
                cone.brightness_noNS = cone.brightness_rating(cone.seen_trials);
                
                if ~isempty(session_info) && any(conetypes(:, 2))
                        
                    % add cone type and distance to nearest S-cone
                    % l=3, m=2, s=1, lms=0, rod=-1
                    cone.type = conetypes(session_info(coneN, 4), 2);
                    
                    if ~isempty(s_cone_dist)
                        cone.s_cone_dist = s_cone_dist(session_info(...
                            coneN, 4));

                        % add number of nearest 6 neighbors that are opponent
                        cone.nopponent_neighbors = sum(opponent_neighbors(...
                            cone.ID, :));
                    end

                else
                    % case where there is no session info or conetypes are
                    % unknown (i.e. they are set to zero)
                    cone.type = 0;
                    cone.s_cone_dist = 0;
                end
                
                % save the data for later
                % first check if the cone might already exist
                if length(cones) >= masterID
                    if ~isempty(cones{masterID})
                        % update the session number based on previous count
                        cones{masterID}.nsession = cones{masterID}.nsession + 1;
                        
                        % update session index in delivery error raw
                        cone.delivery_error_raw(:, 1) = cones{masterID}.nsession;
                        
                        % update session index (all and noNS conditions)
                        cones{masterID}.session_index = ...
                            cones{masterID}.session_index * ...
                            cones{masterID}.nsession;
                        cones{masterID}.session_index_noNS = ...
                            cones{masterID}.session_index_noNS * ...
                            cones{masterID}.nsession;
                        
                        % if the cone already exists append the data
                        fields = {'hue_scaling', 'brightness_rating', ...
                            'stim_intensity', 'trials', 'seen_trials', ...
                            'trials_noNS', 'hues_noNS', 'uad_noNS', ...
                            'saturation_noNS', 'stim_intensity_noNS', ...
                            'brightness_noNS', 'delivery_error', ...
                            'good_trials', 'good_index', ...
                            'delivery_error_raw', 'session_index', ...
                            'session_index_noNS'};

                        % NOTE: need to compute repeatability here                        
                        for f = fields
                            if isfield(cone, f) && isfield(cones{masterID}, f)
                                field = char(f);
                                cones{masterID}.(field) = [...
                                    cones{masterID}.(field); cone.(field)];
                            end
                        end                                                                                                

                        cones{masterID}.FoS = size(...
                            cones{masterID}.hue_scaling, 1) / ...
                            (ntrials * cones{masterID}.nsession);                        

                    else
                        cones{masterID} = cone;
                        cones{masterID}.nsession = 1;
                    end

                else
                    cones{masterID} = cone;
                    cones{masterID}.nsession = 1;
                end                
            end     
        end
    end
end