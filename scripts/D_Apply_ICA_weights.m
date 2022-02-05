% Pipeline of processing for EEG data from POP-R ERC project
% Experiment : POF-SYN (Parafoveal-on-Foveal Syntax effect)
% (c) Jeremy YEATON
% Date created : June 2020
% Updated : January 2022
%% Clear the workspace
clear all;close all;home
disp(' ')
disp('Copy ICA weights from training set to analysis set');

% 1_Nombre de sujet
% Directory for trained data
path_to_ica_data = 'Results\B_trainingSet_ICA\';
% Directory for analysis data
path_to_data = 'Results\C_analysisSet_preprocess';
file_struct = dir([path_to_ica_data '/*.set']);
NumberOfset = dir([path_to_ica_data '/*.set']);
S_vect = 1:size(NumberOfset,1);

disp(' ')
disp(['N participants: ', num2str(max(S_vect))]);
%% Add trained ICA weights to filtered continuous data
for ind_file = 1:length(file_struct)
    clearvars -except S_vect  path_to_data path_to_ica_data ind_S fid ind_file file_struct
    eeglab
    
    filename_tmp = file_struct(ind_file).name;
    idx = isstrprop(filename_tmp,'digit');
    S_tmp = str2num(filename_tmp(idx)); %ind_file;
    
    % Read in EEG data with ICA weights
    EEG = pop_loadset('filename', [path_to_ica_data '\' filename_tmp]);
    EEG = eeg_checkset( EEG );
    
    % Copy ICA weights from training data
    TMP.icawinv = EEG.icawinv;
    TMP.icasphere = EEG.icasphere;
    TMP.icaweights = EEG.icaweights;
    TMP.icachansind = EEG.icachansind;
    clear EEG;
    
    % Apply ICA weights to analysis data
    EEG = pop_loadset('filename', [path_to_data '\sub_' num2str(S_tmp) '_analysisSet_preprocess.set']);
    EEG.icawinv = TMP.icawinv;
    EEG.icasphere = TMP.icasphere;
    EEG.icaweights = TMP.icaweights;
    EEG.icachansind = TMP.icachansind;
    clear TMP;
    
    % 3_5_Sauvegarder les donnees
    path_to_save = 'Results\D_ICAweighted';
    EEG.setname = ['S' num2str(S_tmp) '_ICA'];
    EEG = pop_saveset( EEG,[path_to_save '/sub_' num2str(S_tmp) '_ICAweighted.set']);
end

disp(' ')
disp('Done with all participants!');
waitbar(1,'Done with all participants!');