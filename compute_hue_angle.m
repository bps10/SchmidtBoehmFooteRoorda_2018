function angle = compute_hue_angle(cone, stim_intensity, session)
    % Compute the angle of a hue report
    %
    % USAGE
    % angle = compute_hue_angle(cone, stim_intensity, session)
    %
    % INPUT
    % cone              a structure containing the processed data from a 
    %                   single cone. i.e. cones = load_data(subject, 1). 
    %                   cone = cones{1}.
    % stim_intensity    intensity of stimulus. Default value is all
    %                   intensity levels. A logical array of values that is
    %                   the same size as cone.uad_noNS may also be passed
    %                   to filter the output.
    % session           session to analyze. Default is all sessions.
    %
    % OUTPUT
    % angle             hue angles for all trials that were not pure white,
    %                   which has an undefined angle.
    %
    if nargin < 3 || isempty(session)
        session = -1;
    end
    if nargin < 2 || isempty(stim_intensity)
        stim_intensity = -1;
    end
    
    if session > 0
        sess_ind = cone.session_index_noNS == session;
    else
        if ~islogical(stim_intensity)            
            sess_ind = 1:length(cone.uad_noNS);
        end
    end
    
    if islogical(stim_intensity)        
        intensity_ind = stim_intensity;
        sess_ind = 1:length(stim_intensity);
    else
        if stim_intensity > 0
            intensity_ind = cone.stim_intensity_noNS(sess_ind) == stim_intensity;
        else
            if islogical(sess_ind)
                intensity_ind = 1:sum(sess_ind);
            else
                intensity_ind = sess_ind;
            end
        end
    end
    % remove unwanted trials based on session or stimulus intensity
    angle = cone.uad_noNS(sess_ind, :);
    angle = angle(intensity_ind, :);
    
    % find trials which were pure white (angle is undefined)
    sat = cone.saturation_noNS(sess_ind);
    nowhite = sat(intensity_ind) > 0;
    
    % use atan2 because atan does not preserve signs, i.e. (-1/-1) is
    % the same as (1/1) to atan. atan2 is used by cart2pol and
    % therefore these two functions produce the same output except that
    % x and y are flipped in the input to cart2pol.
    angle = rad2deg(atan2(angle(nowhite, 2), angle(nowhite, 1)));
end