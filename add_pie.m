function add_pie(cone_dat, img_scale_factor, outer_rad, x_circle, y_circle, ...
    label, ind, colmap, coneclass, cone_loc, edgecolor)
    % plot_pie(conedata, img_scale_factor, outer_rad, x_circle, y_circle, ...
    % label, ind, colmap, coneclass, cone_loc)
    %
    % cone_dat = [masterID, xx, NS, W, R, G, B, Y];
    % ind = [start_ind, color label start ind, # of colors, color map ind]

    loc = cone_loc * img_scale_factor;

    % plot behavior responses
    plot_dat = cone_dat(ind(1):end);
    plot_dat(plot_dat == 0) = 0.00001;

    % renormalize incase of removing not seen category
    plot_dat = plot_dat / sum(plot_dat); 

    % pie plot
    h = pie(plot_dat, label(ind(2):end));
    h = movepieto(h, loc(1), loc(2), outer_rad);
    hp = findobj(h, 'Type', 'patch');

    for i = 1:ind(3) % 5 or 6 total
        set(hp(i), 'FaceColor', colmap(i + ind(4), :), 'EdgeColor', edgecolor,...
            'linewidth', 0.05);
    end

    % plot cone type
    x_loc = loc(1) + x_circle;
    y_loc = loc(2) + y_circle;

     
    if strcmp(coneclass, 'l') || coneclass == 3
        patch(x_loc, y_loc, [0.9 0.3 0.3], 'LineWidth', 0.05);

    elseif strcmp(coneclass, 'm') || coneclass == 2
        patch(x_loc, y_loc, [0.3 0.9 0.3], 'LineWidth', 0.05);

    elseif strcmp(coneclass, 's') || coneclass == 1
        patch(x_loc, y_loc, [0.1 0.1 1], 'LineWidth', 0.05);
        
    else
        patch(x_loc, y_loc, [0.4 0.4 0.4], 'LineWidth', 0.05);
        
    end

end

function piehandles = movepieto(piehandles, newx, newy, outer_rad)
    %assume pairs, patch first then text
    % http://www.mathworks.com/matlabcentral/newsreader/view_thread/236342
    for K = 1:2:length(piehandles)
        set(piehandles(K), 'Vertices', ...
              bsxfun(@plus, outer_rad * get(piehandles(K), 'Vertices'),...
              [newx newy]) );

        set(piehandles(K+1), 'Position', ...
            outer_rad * get(piehandles(K+1),'Position') + [newx, newy, 0]);
    end
end
