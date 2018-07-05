function add_scale_bar(subject, maxXY)

    maxx = maxXY(1);
    maxy = maxXY(2);

    % ---- add scale bar ---- %
    if strcmpi(subject, '20053R') || strcmpi(subject, '20076R') || ...
            strcmpi(subject, '10001R')
        % 5 arcmin = 33.33 pix (1 deg = 400 pix)
        % i.e. 400 (pix/deg) / 60 (arcmin/deg) * 5
        scale = 400 / 60 * 5;
        plot([maxx - 10, maxx - (10 + scale)], ...
            ones(1, 2) * (maxy - 120), 'k-', 'LineWidth', 5);
    else
        % 5 arcmin; 1 deg = 545 pix
        % i.e. 545 (pix/deg) / 60 (arcmin/deg) * 5
        scale = 545 / 60 * 5;
        plot([maxx - 10, maxx - (10 + scale)], ...
            ones(1, 2) * (maxy - 120), 'k-', 'LineWidth', 5);    
    end
    text(maxx - 38, maxy - 115, '5 arcmin', 'Color', 'k', ...
        'FontSize', 25);