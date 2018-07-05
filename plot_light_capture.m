function plot_light_capture(subject, save_plots)
%
if nargin < 1
    subject = '20076R';
end
if nargin < 2
    save_plots = 0;
end
defocus = '0.05D';


dataname = fullfile('dat', subject, ['analyzed_cones_' defocus '.mat']);
load(dataname);
cones = analyzed_cones;

light_cap = zeros(length(cones) * 33, 6);
count = 1;
for c = 1:length(cones)
    cone = cones{c};
    if ~isempty(cone)
        for session = 1:cone.nsession
            if isfield(cone, 'light_capture')
                cone_s = cone.light_capture{session};
                inds = cone.session_index_noNS == session;
                cone_uad = cone.uad_noNS(inds, :);
                cone_bright = cone.brightness_noNS(inds);
                cone_trials = cone.trials_noNS(inds);
                for trial = 1:length(cone_s)
                    if ~isempty(cone_s{trial})
                        % match up with color info                    
                        ind = cone_trials == trial;
                        if sum(ind) == 1 && ~isnan(...
                                cone_s{trial}.target_cone_capture)
                            c_uad = cone_uad(ind, :);
                            c_bright = cone_bright(ind);

                            total_capture = cone_s{trial}.target_cone_capture;
                            % target cone fraction of captured light;
                            light_cap(count, 1) = total_capture;   
                            % nearest neighbor fraction of captured light;
                            light_cap(count, 2) = cone_s{trial...
                                }.nn_cone_capture;
                            light_cap(count, 3) = mean(total_capture);
                            light_cap(count, 4) = c_bright;
                            light_cap(count, 5:6) = c_uad;                             
                            count = count + 1;
                        end
                    end
                end
            end
        end
    end
end
% clean up
light_cap = array.remove_zero_rows(light_cap);


f1 = figure; 
hold on;
plot(light_cap(:, 1), 'wo', 'markerfacecolor', 'k');
plot(light_cap(:, 2), 'r.')
%plot(light_cap(:, 3) - light_cap(:, 1), 'b+')
plots.nice_axes('trial #', '% light capture', 18);
%legend('targeted cone', 'nearest neighbor', 'all neighbors', 'fontsize', 15)

util.pprint(mean(light_cap(:, 1)), 4, 'mean target light capture:')
util.pprint(std(light_cap(:, 1)), 4, 'std target light capture:')

util.pprint(mean(light_cap(:, 2)), 4, 'mean NearestN light capture:')
util.pprint(std(light_cap(:, 2)), 4, 'std NearestN light capture:')

f2 = figure; 
hold on;
scatter(light_cap(:, 4), light_cap(:, 1), 'ko')
stats.corr_regress(light_cap(:, 4), light_cap(:, 1), 1, ...
    '% capture vs brightness');
plots.nice_axes('brightness', '% light capture',  20);


f3 = figure; 
hold on;
% compute saturation from UAD diagram
saturation = abs(light_cap(:, 5)) + abs(light_cap(:, 6));

scatter(saturation, light_cap(:, 1), 'ko');
stats.corr_regress(saturation, light_cap(:, 1), 1, ...
    '% capture vs saturation');
plots.nice_axes('saturation', '% light capture', 20);

if save_plots
    savedir = fullfile('img', 'intensity', subject);
    plots.save_fig(fullfile(savedir, 'light_capture_model_vs_trialN'), f1);
    plots.save_fig(fullfile(savedir, 'light_capture_model_vs_brightness'), f2);
    plots.save_fig(fullfile(savedir, 'light_capture_model_vs_saturation'), f3);
end

