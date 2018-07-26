function analyze_prediction(prediction, coneClasses)

    correct_ids = prediction == coneClasses;

    n_correct = sum(correct_ids);
    util.pprint(n_correct, 0, 'N-correct:')
    util.pprint(length(coneClasses), 0, 'Total:')

    l_cones = coneClasses == 3;
    m_cones = coneClasses == 2;

    correct_l_cones = sum(l_cones & correct_ids);
    total_l_cones = sum(l_cones);

    correct_m_cones = sum(m_cones & correct_ids);
    total_m_cones = sum(m_cones);

    disp([num2str(correct_l_cones) ' out of ' num2str(total_l_cones) ...
        ' L-cones correctly identified']);
    disp([num2str(correct_m_cones) ' out of ' num2str(total_m_cones) ...
        ' M-cones correctly identified']);   

    confuse_mat = [correct_l_cones, total_l_cones - correct_l_cones;...
        total_m_cones - correct_m_cones, correct_m_cones];

    stats.cohens_kappa(confuse_mat, 1);
    disp(' ')
