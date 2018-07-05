function conetypes = get_cone_types(subject)
    f = fopen(fullfile('dat', subject, 'cone_types.csv'));
    conetypes = textscan(f, '%d %s', 'delimiter', ',');    
    scones = strcmpi(conetypes{2}, 's');
    mcones = strcmpi(conetypes{2}, 'm') * 2;
    lcones = strcmpi(conetypes{2}, 'l') * 3;
    rod = strcmpi(conetypes{2},'rod') * -1;
    conetypes = [conetypes{1}, rod + scones + mcones + lcones];
    fclose(f);
end