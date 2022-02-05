% Pipeline of processing for EEG data from POP-R ERC project
% Experiment : POF-SYN (Parafoveal-on-Foveal Syntax effect)
% (c) Jeremy YEATON
% Date created : June 2020
% Updated : January 2022
%% Clear the workspace
clear all;close all;home
disp(' ')
disp('Pre-processing POF-SYN: EM and EEG automatic rejection of bad trials');

% Number of participants
path_to_data = 'Results\F_epoched';
file_struct = dir([path_to_data '/*.set']);
NumberOfBDF=dir([path_to_data '/*.set']);
S_vect = 1:size(NumberOfBDF,1);

disp(' ')
disp(['N participants: ', num2str(max(S_vect))]);
%% Loop over participants
trialAutoRej = zeros(length(S_vect),2);
for ind_file = 1:length(file_struct)
    clearvars -except S_vect  path_to_data ind_S ind_file file_struct trialAutoRej
    eeglab
    filename_tmp = file_struct(ind_file).name;
    
    % Read in data
    idx = isstrprop(filename_tmp,'digit');
    S_tmp = str2num(filename_tmp(idx)); %ind_file;
    
    EEG = pop_loadset('filename', [path_to_data '\' filename_tmp]);
    EEG = eeg_checkset( EEG );
    
    trialAutoRej(ind_file,1) = size(EEG.data,3);
    
    % Copy EEG to ID removed trials
    threshVal = 250;
    ThreshInf = -threshVal;
    ThreshSup = threshVal;
    EpochInf = -0.1; %
    EpochSup = 0.8;
    EEG = pop_eegthresh(EEG,1,1:64 ,ThreshInf,ThreshSup,EpochInf,EpochSup,2,0); % Si le dernier argument=0 -> marked sans suppr
    % Reject based on eyetrack
    EEG = pop_eegthresh(EEG,1,[70 71] ,[1 379] ,[1024 389] ,EpochInf,EpochSup,0,0);
    EEG = eeg_rejsuperpose( EEG, 1, 1, 1, 1, 1, 1, 1, 1);
    rej_epochs = (find(EEG.reject.rejglobal == 1));
    
    % Reject trials (mode: auto)
    EEG = pop_eegthresh(EEG,1,1:64 ,ThreshInf,ThreshSup,EpochInf,EpochSup,2,1); % Si =1 -> marked + suppri auto
    EEG = eeg_checkset( EEG );
    
    trialAutoRej(ind_file,2) = size(EEG.data,3);
    
    % 3_5_Sauvegarder les donnees
    path_to_save = 'Results\G_rejectTrials';
    EEG.setname = ['S' num2str(S_tmp) '_ICA_epochs_rejtrials'];
    EEG = pop_saveset( EEG,[path_to_save '/sub_' num2str(S_tmp) '_epoched_rejtrials.set']);
    EEG = eeg_checkset( EEG );
    disp(' ')
    disp(['\n Participant ',num2str(S_tmp),' done!\n']);

    eeglab redraw
end

colNames = {'Before' 'afterEEGrej'};
save('Results\F_epoched\trialAutoRej.mat','trialAutoRej','colNames')
disp(' ')
disp('Done with all participants!');
waitbar(1,'Done with all participants!');