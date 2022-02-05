% Pipeline of processing for EEG data from POP-R ERC project
% Experiment : POF-SYN (Parafoveal-on-Foveal Syntax effect)
% (c) Jeremy YEATON
% Date created : June 2020
% Updated : January 2022
% cd('C:\Users\LPC\Documents\OPOF_syn')
%% 0_Clear the workspace
clear all;close all;home
disp(' ')
disp('PRE-PROCESSING: Training set');

% 1_Number of participants
path_to_data = 'BDF';
file_struct  = dir([path_to_data '/*.bdf']);
NumberOfBDF  = dir([path_to_data '/*.bdf']);
S_vect       = 1:size(NumberOfBDF,1);
disp(' ')
disp(['N participants: ', num2str(max(S_vect))]);
%% 1_Convert EDF to ASC
for ind_file = 1:length(file_struct)
    filename_tmp = file_struct(ind_file).name;
    parseeyelink(['EDF/' filename_tmp(1:end-4) '_trig.asc'],['ET_mat/' filename_tmp(1:end-4) '.mat'],'trigger:',1);
end
%% 2_Knit eyetrack & EEG data; filtering; rejection of bad segments
for ind_file = 1:length(file_struct)%[3,4,21]
    % Clear vars and launch eeglab
    clearvars -except S_vect  path_to_data ind_S fid ind_file file_struct
    eeglab
    
    filename_tmp = file_struct(ind_file).name;
    
    % Read in data
    idx = isstrprop(filename_tmp,'digit'); 
    S_tmp = str2num(filename_tmp(idx)); %ind_file;
    
    % Read eyetrack data
    parseeyelink(['EDF/' filename_tmp(1:end-4) '_trig.asc'],['ET_mat/' filename_tmp(1:end-4) '.mat'],'trigger:');
    
    % Read EEG data
    data_file_name = [path_to_data filesep  filename_tmp];
    EEG = pop_biosig(data_file_name);
    EEG = eeg_checkset( EEG );
    
    % Verify number of channels and sample rate
    if EEG.nbchan==72 && EEG.srate==1024 % 72= 64 electrodes + 8 externes (6 utilisees)
        disp(' ')
        disp(['Processing sub', num2str(S_tmp)]);
    else
        error('Error with the data dimensions!');
    end
    
    % Downsample to 500Hz
    EEG = pop_resample( EEG, 500);
    EEG = eeg_checkset( EEG );
    
    % Read electrode positions
    EEG = pop_chanedit(EEG, 'lookup','scripts\channel_location_LPC_add_ocular.ced');
    EEG = eeg_checkset( EEG );
    
    % Update trigger codes (0, 21, 22, 31, 32, 120)
    EV = [EEG.event.type]';
    for ii = 1:length(EV)
        val1 = EEG.event(ii).type;
        val2 = dec2bin(val1);
        val3 = val2(:,end-7:end);
        EEG.event(ii).type = bin2dec(val3);
    end
        
    % Filters for overweighted training data
    LowFilt = 2.5;
    HighFilt = 100;
    EEG = pop_eegfiltnew(EEG, LowFilt,HighFilt);
    EEG = eeg_checkset( EEG );
    
    % Select electrodes and re-reference
    EEG = pop_reref( EEG, [65 70]);
    EEG = eeg_checkset( EEG );
    EEG = pop_select( EEG,'channel',1:68);
    EEG = eeg_checkset( EEG );
    
    % Convert string events to numeric
    for evtNum = 1:length(EEG.event)
        if length(EEG.event(evtNum).type) == 2
            try
                EEG.event(evtNum).type = str2num(EEG.event(evtNum).type);
            catch
                EEG.event(evtNum).type = EEG.event(evtNum).type;
            end
        end
    end
    
    % Import and sync ET data    
    if strcmp(filename_tmp(1:end-4),'Sub_18')
        EEG = pop_importeyetracker(EEG,['ET_mat/' filename_tmp(1:end-4) '.mat'],[EEG.event(3).type EEG.event(end).type],1:4 ,{'TIME' 'R-GAZE-X' 'R-GAZE-Y' 'R-AREA'},1,1,0,0,4);
    else
        EEG = pop_importeyetracker(EEG,['ET_mat/' filename_tmp(1:end-4) '.mat'],[EEG.event(2).type EEG.event(end).type],1:4 ,{'TIME' 'R-GAZE-X' 'R-GAZE-Y' 'R-AREA'},1,1,0,0,4);
    end
    EEG = eeg_checkset( EEG );
    
    % Remove blink segments
    blinkPad = 50; % ms
    blinks = [];
    for Idx = 1:length(EEG.event)
        if strcmp(EEG.event(Idx).type, 'R_blink')
            blinks = [blinks ; [EEG.event(Idx).latency - blinkPad EEG.event(Idx).endtime + blinkPad]];
        end
    end
    EEG = eeg_eegrej( EEG, blinks );
    
    % Remove pauses
    maxPauseLen = 5000; % ms
    EEG  = pop_erplabDeleteTimeSegments( EEG , 'displayEEG',  0, 'endEventcodeBufferMS',  500, 'ignoreUseType', 'ignore',...
        'startEventcodeBufferMS', 500, 'timeThresholdMS',  maxPauseLen );
    EEG = eeg_checkset( EEG );
    
    % Load electrode names
    load('scripts\name_list.mat')
    
    % Interpolate bad channels
    [eeg_interped, ~] = removeBadChannels(EEG, []);
    EEG.data(1:64,:) = eeg_interped;
    EEG = eeg_checkset( EEG );
    
    % Save data
    path_to_save = 'Results\A_trainingSet_preprocess';
    EEG.setname = ['S' num2str(S_tmp) '_pre-ICA'];
    EEG = pop_saveset( EEG,[path_to_save '/sub_' num2str(S_tmp) '_trainingSet.set']);
    EEG = eeg_checkset( EEG );
    disp(' ')
    disp(['Participant ',num2str(S_tmp),' done!\n']);

    eeglab redraw
end
disp(' ')
disp('Done with all participants!');
waitbar(1,'Done with all participants!');