function ind = get_intensity_ind(intensity, summary)
    %
    %
    % USAGE
    % ind = get_intensity_ind(intensity, summary)
    %
    if ischar(intensity)
        if strcmpi(intensity, 'all')
            ind = 8;
        end            
    elseif intensity == -1
        ind = 8;
    else
        % all other cases
        ind = (find(summary.intensities == intensity) - 1) * 2;
        if isempty(ind)
            error(['intensity must be: ' num2str(summary.intensities')...
                ' -1 or ''all'''])
        end
    end
end