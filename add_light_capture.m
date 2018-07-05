function add_light_capture(subject)

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
params.proportion = 0.48;
params.intratrial_delivery_error = 0.15;

params = light_capture.compute_field_size(params);
params = light_capture.gen_stimulus(params);
params = light_capture.GeneratePSF(params);
params = light_capture.gen_retina_image(params);

% get targeted cone locations
targeted_cone_loc = get_stim_cone_locs(subject);

% cycle through cones and sessions and trials
analyzed_cones{length(cones)} = [];
parfor c = 1:ncones
    cID = targeted_cones(c);
    cone = cones{cID};    
    % save params
    cone.light_capture_params = params;
    for t = 1:length(cone.good_trials)
        trial = cone.good_trials(t);
        for session = 1:cone.nsession                
            % find the relavent data.
            session_index = cone.delivery_error_raw(:, 1) == session;
            delivery = cone.delivery_error_raw(session_index, :);
            trial_ind = delivery(:, 2) == trial;        
            trial_delivery = delivery(trial_ind, :);

            % don't include NaNs (blanks) or session that didn't 
            % include the trial.                
            if sum(trial_ind) > 1 && ~isempty(trial_delivery)
                mean_pos = mean(trial_delivery(:, 4:5), 1);

                % difference (in pix) of each from from the mean
                % location for given cone on the given trial
                trial_delta = zeros(size(trial_delivery(:, 4:5)));
                trial_delta(:, 1) = trial_delivery(:, 4) - mean_pos(1);
                trial_delta(:, 2) = trial_delivery(:, 5) - mean_pos(2);

                % update params with current cone/trial data
                coneparams = params;
                coneparams.delivery_locs = trial_delta;
                coneparams.center_cone_index = targeted_cone_loc(cone.ID, 4);

                % generate light capture model
                model_data = light_capture.model(coneparams);
                % light caught (%) in target cone and its nearest
                % neighbor
                target_cone_capture = mean(model_data.per_cone_int(:, 1));
                nn_cone_capture = mean(model_data.per_cone_int(:, 2));

                % append the light capture results and summary to the
                % data files.
                disp([cone.ID trial ...
                    mean(target_cone_capture .* model_data.per_trial_int)]);   

                % add each model to the cone structure and save in a
                % new structure (analyzed_data) that can be slurped in
                % by other analyses. 
                %
                % neighbor IDs are saved in params. 
                % Will want this information for doing Linear Systems 
                % Analysis (STA, STC, etc) & log likelihood. 

                % only save the relavant data.
                save_data = struct();
                % total amount of light captured by the whole mosaic 
                % during each frame of the stimulus
                save_data.total_capture = model_data.per_trial_int;
                % fraction of that absorbed light caught by each cone
                save_data.per_cone_int = model_data.per_cone_int;
                % cones of interest
                save_data.target_cone_capture = target_cone_capture;
                save_data.nn_cone_capture = nn_cone_capture;
                % add to structure of saving
                cone.light_capture{session}{trial} = save_data;
            end
        end
    end
    % save analyzed cone
    analyzed_cones{c} = cone;
end
% shut down the parallel pool
poolobj = gcp('nocreate');
delete(poolobj);

savename = fullfile('dat', subject, ...
    ['analyzed_cones_' num2str(params.defocus) 'D.mat']);
save(savename, 'analyzed_cones')

