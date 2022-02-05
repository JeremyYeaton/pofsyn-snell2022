% Pipeline of processing for EEG data from POP-R ERC project
% Experiment : POF-SYN (Parafoveal-on-Foveal Syntax effect)
% (c) Jeremy YEATON
% Date created : June 2020
% Updated : January 2022
%% Clear the workspace
clear all;close all;home
disp(' ')
disp('Pre-processing POF-SYN data: Analysis set');

% 1_Nombre de sujet
path_to_data = 'BDF';
file_struct  = dir([path_to_data '/*.bdf']);
NumberOfBDF  = dir([path_to_data '/*.bdf']);
S_vect       = 1:size(NumberOfBDF,1);

disp(' ')
disp(['N participants: ', num2str(max(S_vect))]);
%% Loop over participants
tic
for ind_file = 1:length(NumberOfBDF)
    eeglab
    filename_tmp = file_struct(ind_file).name;
    idx = isstrprop(filename_tmp,'digit'); 
    S_tmp = str2num(filename_tmp(idx)); %ind_file;
    
    % Read in EEG data   
    data_file_name = [path_to_data filesep  filename_tmp];
    EEG = pop_biosig(data_file_name);
    EEG = eeg_checkset( EEG );
    
    % Veryify number of channels and sample rate
    if EEG.nbchan==72 && EEG.srate==1024 % 72= 64 electrodes + 8 externes (6 utilisees)
        disp(' ')
        disp(['Processing participant', num2str(S_tmp)]);
    else
        error('Error with the data dimensions!');
    end
    
    % Downsampling (1000Hz)
    EEG = pop_resample( EEG, 1000);
    EEG = eeg_checkset( EEG );
    
    % Get electrode positions
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
   
    % Filtering
    LowFilt = 0.1;
    HighFilt = 40;
    EEG = pop_eegfiltnew(EEG, LowFilt,HighFilt);
    EEG = eeg_checkset( EEG );
    
   % Select electrodes
    EEG = pop_reref( EEG, [65 70]);
    EEG = eeg_checkset( EEG );
    EEG = pop_select( EEG,'channel',1:68);
    EEG = eeg_checkset( EEG );

%     % Convert string events to numeric
%     for evtNum = 1:length(EEG.event)
%         if length(EEG.event(evtNum).type) == 2
%             try
%                 EEG.event(evtNum).type = str2num(EEG.event(evtNum).type);
%             catch
%                 EEG.event(evtNum).type = EEG.event(evtNum).type;
%             end
%         end
%     end
    
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
    
    % Load channel names
    load('scripts\name_list.mat')
    
    % Interpolate bad channels
    [eeg_interped, ~] = removeBadChannels(EEG, []);
    EEG.data(1:64,:) = eeg_interped;
    EEG = eeg_checkset( EEG );

    % Remove pauses
    maxPauseLen = 5000; % ms
    EEG  = pop_erplabDeleteTimeSegments( EEG , 'displayEEG',  0, 'endEventcodeBufferMS',  500, 'ignoreUseType', 'ignore',...
        'startEventcodeBufferMS', 500, 'timeThresholdMS',  maxPauseLen );
    EEG = eeg_checkset( EEG );
    
    % Save data
    path_to_save = 'Results\C_analysisSet_preprocess';
    EEG.setname = ['S' num2str(S_tmp) '_AS_prepro'];
    EEG = pop_saveset( EEG,[path_to_save '/sub_' num2str(S_tmp) '_analysisSet_preprocess.set']);
    EEG = eeg_checkset( EEG );
    disp(' ')
    disp(['\n Participant ',num2str(S_tmp),' done!\n']);

    eeglab redraw
    toc
end

disp(' ')
disp('Done with all participants!');
waitbar(1,'Done with all participants!');