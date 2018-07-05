% datapaths are organized by session #, background color and directory
% where the videos are stored. The latter is used by
% add_delivery_error_to_datfiles during delivery error analysis.

% NOTES
% =====
% Sessions 1-4 were not correctly updating the stimulus intensity.

% These were from before aom output was linearized:
% useable_sessions = [5, 6, 7, 8, 11, 12, 13];

% Blue background:
% 16 was at the end of the day and had low overall FoS.

% All following sessions were with linear aom.
% No longer using them, however, because of problems isolating S-cones (due
% to lack of correction in outer edge of pupil)
% useable_sessions = [14, 15, 17, 18, 19, 20, 21, 22]; 

% Session 23 and beyond: Iris on green channel was made smaller so that the
% beam was reduced to 6.4 mm at the pupil plane. In addition, ND filter 
% was increased to 2.1 in order to match the intensity at the pupil plane 
% with the same measurement on the old system.
% useable_sessions = [23, 24, 25, 26, 27, 28];

% Session 29 was with a ND of 2.1 after a full re-alignment of the system.
% Session 30 and beyond were with ND of 2.5.
% useable_sessions = [30, 31];

% Session 32 was with an ND of 2.7.
% useable_sessions = [32];

% Session 33, 34, 35. ND = 2.5. Int=0.2,0.4,0.8. Projector: variable.
% useable_sessions = [33, 34, 35];

% Sessions 36-39. ND=2.5. Int=0.2,0.4,0.8. Projector: ND 3.0, lum= 41.5.
% TCA moved around quite a lot in each session. Results are not usable.
%useable_sessions = 36:39;

% Sessions 40-46. ND=2.5. Int=0.2,0.4,0.8. Projector: ND=3.0, lum=35.
% Sessions 47-49. ND=2.5. Int=0.2,0.4,0.8. Projector: New aaxa HD projector
% ND=2.0, lum=30.
useable_sessions = [33:35, 40:62];

datapaths{1}.white.data_file = 'data_color_naming_27Mar2017x122435.mat';
datapaths{1}.white.video_dir = '3_27_2017_12_7_6';

datapaths{2}.white.data_file = 'data_color_naming_28Mar2017x115157.mat';
datapaths{2}.white.video_dir = '3_28_2017_11_31_2';
datapaths{3}.white.data_file = 'data_color_naming_28Mar2017x124038.mat';
datapaths{3}.white.video_dir = '3_28_2017_12_23_22';

datapaths{4}.white.data_file = 'data_color_naming_29Mar2017x144848.mat';
datapaths{4}.white.video_dir = '3_29_2017_14_27_5';

datapaths{5}.white.data_file = 'data_color_naming_30Mar2017x120827.mat';
datapaths{5}.white.video_dir = '3_30_2017_11_54_20';
datapaths{6}.white.data_file = 'data_color_naming_30Mar2017x123338.mat';
datapaths{6}.white.video_dir = '3_30_2017_12_16_17';
datapaths{7}.white.data_file = 'data_color_naming_30Mar2017x151419.mat';
datapaths{7}.white.video_dir = '3_30_2017_14_57_26';
datapaths{8}.white.data_file = 'data_color_naming_30Mar2017x154928.mat';
datapaths{8}.white.video_dir = '3_30_2017_15_31_52';

datapaths{9}.white.data_file = 'data_color_naming_04Apr2017x112709.mat';
datapaths{9}.white.video_dir = '';
datapaths{10}.white.data_file = 'data_color_naming_04Apr2017x115854.mat';
datapaths{10}.white.video_dir = '';

datapaths{11}.white.data_file = 'data_color_naming_05Apr2017x105554.mat';
datapaths{11}.white.video_dir = '4_5_2017_10_38_8';
datapaths{12}.white.data_file = 'data_color_naming_05Apr2017x112933.mat';
datapaths{12}.white.video_dir = '4_5_2017_11_14_38';
datapaths{13}.white.data_file = 'data_color_naming_05Apr2017x115606.mat';
datapaths{13}.white.video_dir = '4_5_2017_11_39_25';

datapaths{14}.white.data_file = 'data_color_naming_24Apr2017x114829.mat';
datapaths{14}.white.video_dir = '4_24_2017_11_33_2';
datapaths{15}.white.data_file = 'data_color_naming_24Apr2017x121412.mat';
datapaths{15}.white.video_dir = '4_24_2017_11_58_46';
datapaths{16}.blue.data_file = 'data_color_naming_24Apr2017x123812.mat';
datapaths{16}.blue.video_dir = '4_24_2017_12_21_48';

datapaths{17}.white.data_file = 'data_color_naming_25Apr2017x113655.mat';
datapaths{17}.white.video_dir = '4_25_2017_11_21_27';
datapaths{18}.white.data_file = 'data_color_naming_25Apr2017x120951.mat';
datapaths{18}.white.video_dir = '4_25_2017_11_48_23';
datapaths{19}.white.data_file = 'data_color_naming_25Apr2017x125038.mat';
datapaths{19}.white.video_dir = '4_25_2017_12_33_18';

datapaths{20}.white.data_file = 'data_color_naming_27Apr2017x114251.mat';
datapaths{20}.white.video_dir = '4_27_2017_11_29_49';
datapaths{21}.white.data_file = 'data_color_naming_27Apr2017x120757.mat';
datapaths{21}.white.video_dir = '4_27_2017_11_54_15';
datapaths{22}.white.data_file = 'data_color_naming_27Apr2017x124207.mat';
datapaths{22}.white.video_dir = '4_27_2017_12_29_0';

datapaths{23}.white.data_file = 'data_color_naming_03May2017x140656.mat';
datapaths{23}.white.video_dir = '5_3_2017_13_49_30';
datapaths{24}.white.data_file = 'data_color_naming_03May2017x143023.mat';
datapaths{24}.white.video_dir = '5_3_2017_14_17_3';
datapaths{25}.white.data_file = 'data_color_naming_03May2017x152308.mat';
datapaths{25}.white.video_dir = '5_3_2017_15_6_12';

datapaths{26}.white.data_file = 'data_color_naming_04May2017x120923.mat';
datapaths{26}.white.video_dir = '5_4_2017_11_55_26';
datapaths{27}.white.data_file = 'data_color_naming_04May2017x123053.mat';
datapaths{27}.white.video_dir = '5_4_2017_12_16_35';
datapaths{28}.white.data_file = 'data_color_naming_04May2017x125124.mat';
datapaths{28}.white.video_dir = '5_4_2017_12_36_46';

datapaths{29}.white.data_file = 'data_color_naming_12May2017x113751.mat';
datapaths{29}.white.video_dir = '5_12_2017_11_21_24';
datapaths{30}.white.data_file = 'data_color_naming_12May2017x121757.mat';
datapaths{30}.white.video_dir = '5_12_2017_11_58_54';
datapaths{31}.white.data_file = 'data_color_naming_12May2017x124811.mat';
datapaths{31}.white.video_dir = '5_12_2017_12_31_21';

datapaths{32}.white.data_file = 'data_color_naming_17May2017x144746.mat';
datapaths{32}.white.video_dir = '5_17_2017_14_35_27';

datapaths{33}.white.data_file = 'data_color_naming_31May2017x112854.mat';
datapaths{33}.white.video_dir = '5_31_2017_11_11_58';
datapaths{34}.white.data_file = 'data_color_naming_31May2017x115204.mat';
datapaths{34}.white.video_dir = '5_31_2017_11_39_41';
datapaths{35}.white.data_file = 'data_color_naming_31May2017x123047.mat';
datapaths{35}.white.video_dir = '5_31_2017_12_18_17';

datapaths{36}.white.data_file = 'data_color_naming_01Jun2017x111813.mat';
datapaths{36}.white.video_dir = '6_1_2017_11_2_34';
datapaths{37}.white.data_file = 'data_color_naming_01Jun2017x120212.mat';
datapaths{37}.white.video_dir = '6_1_2017_11_47_46';
datapaths{38}.white.data_file = 'data_color_naming_01Jun2017x123301.mat';
datapaths{38}.white.video_dir = '6_1_2017_12_18_57';
datapaths{39}.white.data_file = 'data_color_naming_01Jun2017x125807.mat';
datapaths{39}.white.video_dir = '6_1_2017_12_44_32';

datapaths{40}.white.data_file = 'data_color_naming_02Jun2017x100050.mat';
datapaths{40}.white.video_dir = '6_2_2017_9_46_0';
datapaths{41}.white.data_file = 'data_color_naming_02Jun2017x102444.mat';
datapaths{41}.white.video_dir = '6_2_2017_10_11_24';
datapaths{42}.white.data_file = 'data_color_naming_02Jun2017x105248.mat';
datapaths{42}.white.video_dir = '6_2_2017_10_39_29';
datapaths{43}.white.data_file = 'data_color_naming_02Jun2017x111821.mat';
datapaths{43}.white.video_dir = '6_2_2017_11_5_38';

datapaths{44}.white.data_file = 'data_color_naming_08Jun2017x135118.mat';
datapaths{44}.white.video_dir = '6_8_2017_13_37_6';
datapaths{45}.white.data_file = 'data_color_naming_08Jun2017x141835.mat';
datapaths{45}.white.video_dir = '6_8_2017_14_1_0';
datapaths{46}.white.data_file = 'data_color_naming_08Jun2017x145520.mat';
datapaths{46}.white.video_dir = '6_8_2017_14_42_23';

datapaths{47}.white.data_file = 'data_color_naming_15Jun2017x111008.mat';
datapaths{47}.white.video_dir = '6_15_2017_10_54_58';
datapaths{48}.white.data_file = 'data_color_naming_15Jun2017x113910.mat';
datapaths{48}.white.video_dir = '6_15_2017_11_26_29';
datapaths{49}.white.data_file = 'data_color_naming_15Jun2017x120103.mat';
datapaths{49}.white.video_dir = '6_15_2017_11_47_49';

datapaths{50}.white.data_file = 'data_color_naming_20Jun2017x105514.mat';
datapaths{50}.white.video_dir = '6_20_2017_10_38_21';
datapaths{51}.white.data_file = 'data_color_naming_20Jun2017x112031.mat';
datapaths{51}.white.video_dir = '6_20_2017_11_8_13';
datapaths{52}.white.data_file = 'data_color_naming_20Jun2017x113947.mat';
datapaths{52}.white.video_dir = '6_20_2017_11_27_0';
datapaths{53}.white.data_file = 'data_color_naming_20Jun2017x121743.mat';
datapaths{53}.white.video_dir = '6_20_2017_12_5_2';

datapaths{54}.white.data_file = 'data_color_naming_28Jun2017x114450.mat';
datapaths{54}.white.video_dir = '6_28_2017_11_33_15';
datapaths{55}.white.data_file = 'data_color_naming_28Jun2017x121051.mat';
datapaths{55}.white.video_dir = '6_28_2017_12_0_49';
datapaths{56}.white.data_file = 'data_color_naming_28Jun2017x123147.mat';
datapaths{56}.white.video_dir = '6_28_2017_12_21_19';

datapaths{57}.white.data_file = 'data_color_naming_30Jun2017x114841.mat';
datapaths{57}.white.video_dir = '6_30_2017_11_38_31';
datapaths{58}.white.data_file = 'data_color_naming_30Jun2017x121814.mat';
datapaths{58}.white.video_dir = '6_30_2017_12_5_12';
datapaths{59}.white.data_file = 'data_color_naming_30Jun2017x124349.mat';
datapaths{59}.white.video_dir = '6_30_2017_12_33_31';

datapaths{60}.white.data_file = 'data_color_naming_06Jul2017x110843.mat';
datapaths{60}.white.video_dir = '7_6_2017_10_57_2';
datapaths{61}.white.data_file = 'data_color_naming_06Jul2017x120855.mat';
datapaths{61}.white.video_dir = '7_6_2017_11_59_11';
datapaths{62}.white.data_file = 'data_color_naming_06Jul2017x125110.mat';
datapaths{62}.white.video_dir = '7_6_2017_12_37_24';
