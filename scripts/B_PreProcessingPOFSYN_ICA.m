% Pipeline of processing for EEG data from POP-R ERC project
% Experiment : POF-SYN (Parafoveal-on-Foveal Syntax effect)
% (c) Jeremy YEATON
% Date created : June 2020
% Updated : January 2022
%% Clear the workspace
clear all;close all;clc;home
disp(' ')
disp('ICA on POF-SYN training data');

% 1_Number of participants
path_to_data = 'Results\A_trainingSet_preprocess';
file_struct = dir([path_to_data '/*.set']);
NumberOfset = dir([path_to_data '/*.set']);
S_vect = 1:size(NumberOfset,1);

disp(' ')
disp(['N participants: ', num2str(max(S_vect))]);
%% 3_Boucle pour chaque sujet
tic 
file_struct = file_struct([2,3,20],:);
parfor ind_file = 1:length(file_struct) 
    eeglab
    filename_tmp = file_struct(ind_file).name;
    
    % Read in data
    idx = isstrprop(filename_tmp,'digit'); 
    S_tmp = str2num(filename_tmp(idx)); %ind_file;
    
    EEG = pop_loadset('filename', [path_to_data '\' filename_tmp]);
    EEG = eeg_checkset( EEG );

    % Produce overweighted data for ICA
    EEG = pop_overweightevents(EEG,'R_saccade',[-0.02 0.01] ,0.5,1)
    % Run ICA
    EEG = pop_runica(EEG, 'extended',1,'interupt','on','chanind',1:68);
    EEG = eeg_checkset( EEG );
    
    EEG = pop_resample( EEG, 50);
    EEG = eeg_checkset( EEG );
    
    % 3_4_Sauvegarder les donnees
    path_to_save = 'Results\B_trainingSet_ICA\';
    EEG.setname = ['S' num2str(S_tmp) '_ICA'];
    parsave([path_to_save 'sub' num2str(S_tmp) '_ICAweighted.mat'], EEG);
    EEG = eeg_checkset( EEG );
    disp(' ')
    disp(['\n Participant ',num2str(S_tmp),' done\n']);

    eeglab redraw
 end
toc

% Convert .mat files to .set
path_to_data = 'Results\B_trainingSet_ICA\';
file_struct  = dir([path_to_data '/*.mat']);
    
for ind_file = 1:length(file_struct)
    filename_tmp = file_struct(ind_file).name;
    mat2set(path_to_data, filename_tmp)
end

disp(' ')
disp('Done with all participants!');
waitbar(1,'Done with all participants!');