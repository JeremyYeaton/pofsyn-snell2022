% Pipeline of processing for EEG data from POP-R ERC project
% Experiment : POF-SYN (Parafoveal-on-Foveal Syntax effect)
% (c) Jeremy YEATON
% Date created : June 2020
% Updated : January 2022
%% Clear the workspace
clear all;close all;home
disp(' ')
disp('Pre-processing POF-SYN data: Component removal a la Dimigen');

% Number of participants
path_to_data = 'C:\Users\LPC\Documents\OPOF_syn\Results\D_ICAweighted';
file_struct  = dir([path_to_data '/*.set']);
NumberOfset  = dir([path_to_data '/*.set']);

S_vect = 1:size(NumberOfset,1);
disp(' ')
disp(['N participants: ', num2str(max(S_vect))]);

% Keep track of components removed for each participant
compsRemoved = zeros(length(S_vect),2);
%% Loop over participants 
for ind_file = 1:length(file_struct)
    clearvars -except S_vect  path_to_data ind_file file_struct compsRemoved
    eeglab
    filename_tmp = file_struct(ind_file).name;
    
    % Read in data
    idx = isstrprop(filename_tmp,'digit');
    S_tmp = str2num(filename_tmp(idx)); %ind_file;
    
    EEG = pop_loadset('filename', [path_to_data '\' filename_tmp]);
    EEG = eeg_checkset( EEG );
    
    % Identify components for removal
    components_to_remove = [];
    [EEG vartable] = pop_eyetrackerica(EEG,'R_saccade','R_fixation',[10 0] ,1.1,2,0,4); % using default settings
    components_to_remove = find(EEG.reject.gcompreject);
    
    % Remove components
    EEG = pop_subcomp( EEG, components_to_remove, 0);
    n_comp_removed = length(components_to_remove);
    
    % Record removed components for reporting
    compsRemoved(ind_file,1:2) = [S_tmp n_comp_removed];
    disp(['Number of components removed: ' num2str(n_comp_removed)])
    
    % Save the data
    path_to_save = 'Results\E_ICAcompRemoved';
    EEG.setname = ['S' num2str(S_tmp) '_ICAcompRemoved'];
    EEG = pop_saveset( EEG,[path_to_save '/sub_' num2str(S_tmp) '_ICAcompRemoved.set']);
    EEG = eeg_checkset( EEG );
    disp(' ')
    disp(['\n Participant ',num2str(S_tmp),' done!\n']);
    eeglab redraw
    
end

% Save component removal information
save([path_to_save filesep 'componentsRemoved.mat'],'compsRemoved')

disp(' ')
disp('Done with all participants!');
waitbar(1,'Done with all participants!');