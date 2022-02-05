% Pipeline of processing for EEG data from POP-R ERC project
% Experiment : POF-SYN (Parafoveal-on-Foveal Syntax effect)
% (c) Jeremy YEATON
% Date created : June 2020
% Updated : January 2022
%% Clear the workspace
clear all;close all;home
load('all_data_the_end.mat','mask');
load('scripts/chan_labels.mat');
disp(' ')
disp('POF-SYN: Cluster-based permutation test');
%% Create a GND variable from set files 
chans2exclude = {'HEOGD_EXG2';'VEOGD_EXG3';'VEOGG_EXG4';'HEOGG_EXG5';'TIME';'R-GAZE-X';'R-GAZE-Y';'R-AREA'};
GND = sets2GND('gui', 'bsln', [-100 0], 'exclude_chans', chans2exclude,'exp_name','POF-syn'); 

%% Within-subject t-tests
load('scripts/chanlocs.mat');
load  Results\allTrials.GND -MAT
chan_hood = spatial_neighbors(chanlocs(1:64),40);

% Creating a difference wave between the 2 conditions
GND = bin_dif(GND, 1, 2, 'syn - nosyn');

tWin = [0 800]; 
[GND, prm_pval, data_t]  = clustGND(GND, 3, 'time_wind', tWin, 'chan_hood', chan_hood,...
    'alpha',0.05,'tail', 1, 'thresh_p', 0.05, 'n_perm', 2500);