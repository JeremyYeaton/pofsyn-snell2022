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
load('scripts/mask.mat');
path_to_data = 'Results\G_rejectTrials';
file_struct = dir([path_to_data '/*.set']);
file_struct = file_struct(mask);
NumberOfBDF=dir([path_to_data '/*.set']);
S_vect = 1:size(NumberOfBDF,1);

disp(' ')
disp(['N participants: ', num2str(max(S_vect))]);
%% Loop over participants: Bin epochs by condition
path_to_save = 'Results\H_binEpochs';
blf = [path_to_save filesep 'binNames.txt'];
for ind_file = 1:length(file_struct)
    clearvars -except S_vect  path_to_data ind_S ind_file file_struct blf path_to_save
    eeglab
    filename_tmp = file_struct(ind_file).name;
    
    % Read in data
    idx = isstrprop(filename_tmp,'digit');
    S_tmp = str2num(filename_tmp(idx));
    
    EEG = pop_loadset('filename', [path_to_data '\' filename_tmp]);
    EEG = eeg_checkset( EEG );
    
    EEG = pop_resample( EEG, 500);
    EEG = eeg_checkset( EEG );
    
    % Convert to string and add subject codename
    for i = 1:length(EEG.epoch)
        for b = 1:length(EEG.epoch(i).eventtype)
            EEG.epoch(i).eventtype{b} = num2str(EEG.epoch(i).eventtype{b});
        end
    end
    EEG.subject = ['S_' num2str(S_tmp)];
    
    EEG = bin_info2EEG(EEG, blf);
    EEG = eeg_checkset( EEG );
    
    % Trigger 211 (Condition 0/ syntactically compatible)
    EEG_211 = pop_selectevent(EEG, 'type',211,'deleteevents','off','deleteepochs','on','invertepochs','off');
    EEG_211.setname='BDF file epochs 211';
    EEG_211 = eeg_checkset(EEG_211);
    
    eegName211 = [path_to_save '/sub_' num2str(S_tmp) '_bin211.set'];
    EEG_211 = pop_saveset(EEG_211,eegName211);
    EEG_211 = eeg_checkset(EEG_211);
    
    % Trigger 311 (Condition 1/ syntactically incompatible)
    EEG_311 = pop_selectevent(EEG, 'type',311,'deleteevents','off','deleteepochs','on','invertepochs','off');
    EEG_311.setname='BDF file epochs 311';
    EEG_311 = eeg_checkset(EEG_311);
    
    eegName311 = [path_to_save '/sub_' num2str(S_tmp) '_bin311.set'];
    EEG_311 = pop_saveset(EEG_311,eegName311);
    EEG_311 = eeg_checkset(EEG_311);
    
    disp(' ')
    disp(['\n Participant ',num2str(S_tmp),' done!\n']);
    eeglab redraw
end

disp(' ')
disp('Done with all participants!');
waitbar(1,'Done with all participants!');
%% Aggregate data by condition
path_to_data = 'Results\H_binEpochs';
file_struct = dir([path_to_data '/*.set']);

NumberOfBDF = dir([path_to_data '/*.set']);
nParticipants = size(NumberOfBDF,1)/2;
S_vect = 1:nParticipants;
disp(' ')
disp(['N participants: ', num2str(nParticipants)]);

% Load files
load('scripts/EEG_times_900ms.mat');
load('scripts/chanlocs.mat');
load('Results/E_ICAcompRemoved/componentsRemoved.mat')
% load('all_data_the_end.mat');
load('scripts/chan_labels.mat');

% Group data by bin (211 & 311) in a single file each (channels*timepoints*subjects)
all_data.c21 = zeros(72,450,nParticipants);
all_data.c31 = zeros(72,450,nParticipants);
totalTrials = zeros(length(file_struct),1);
idx21 = 1;idx31 = 1;

for ind_file = 1:length(file_struct)
    filename_tmp = file_struct(ind_file).name;
    EEG = pop_loadset('filename', [path_to_data '\' filename_tmp]);
    EEG = eeg_checkset( EEG );
    if strcmp(filename_tmp(end-6:end-4), '211')
        nTrials = size(EEG.data,3);
        totalTrials(ind_file) = nTrials;
        all_data.c21(:,:,idx21) = mean(EEG.data(:,:,:),3);
        idx21 = idx21 + 1;
    elseif strcmp(filename_tmp(end-6:end-4), '311')
        nTrials = size(EEG.data,3);
        totalTrials(ind_file) = nTrials;
        all_data.c31(:,:,idx31) = mean(EEG.data(:,:,:),3);
        idx31 = idx31 + 1;
    end
end

% % % Get # trials & remove subs with less than 35 in either condition
% tt = totalTrials(:,1);
% 
% t0 = tt;%(1:2:end);
% t1(:,1) = t0(1:2:end);
% t1(:,2) = t0(2:2:end);
% mask0 = t1(:,1:2) > 35;
% mask = sum(mask0,2) == 2; 
% mask = mask & compsRemoved(:,2) < 5; % Subject 8 is bad

disp('Saving the data...')
% save all_data all_data mask t1
save all_data all_data
disp('Saved!')