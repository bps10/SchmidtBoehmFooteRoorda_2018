function targeted_locs = get_stim_cone_locs(subject)
    if nargin < 1
        subject = '20076R';
    end
    
    targeted_locs = csvread(fullfile('dat', subject, 'cone_loc_index.csv'));
end