% Pipeline of processing for EEG data from POP-R ERC project
% Experiment : POF-SYN (Parafoveal-on-Foveal Syntax effect)
% (c) Jeremy YEATON
% Date created : June 2020
% Updated : January 2022
%% Clear the workspace
clear all;close all;home
disp(' ')
disp('Pre-processing POF-SYN: ID first fixation events & cut into epochs');

% Number of participants
path_to_data = 'Results\E_ICAcompRemoved';
file_struct  = dir([path_to_data '/*.set']);
NumberOfset  = dir([path_to_data '/*.set']);
S_vect = 1:size(NumberOfset,1);
disp(' ')
disp(['N participants: ', num2str(max(S_vect))]);

%% Loop over participants
newEventsTrialCount = zeros(length(file_struct),2);
% refMs = 1000/85;
for ind_file = 1:length(file_struct)
    clearvars -except S_vect  path_to_data ind_S fid ind_file file_struct newEventsTrialCount refMs
    eeglab;
    filename_tmp = file_struct(ind_file).name;
    
    % Read in the data
    idx = isstrprop(filename_tmp,'digit');
    S_tmp = str2num(filename_tmp(idx)); %ind_file;
    
    EEG = pop_loadset('filename', [path_to_data '\' filename_tmp]);
    EEG = eeg_checkset( EEG );
    
    % Record number of events at import
    newEventsTrialCount(ind_file,1) = sum(ismember({EEG.event.type},'21'));
    newEventsTrialCount(ind_file,2) = sum(ismember({EEG.event.type},'31'));
    
    % Initialise new event table and make it empty
    newEvent = EEG.event;
    newEvent(1:end) = [];
    fix = 0;
    count211 = 0; count311 = 0;
    limInf = 0;limSup = 0;xMax = 0;newTrial = 1;trialOnset = 0;

    % Add events for first fixations
    for Idx = 1:length(EEG.event)
        % Reset variables for new trial
        if strcmp(EEG.event(Idx).type, '21') || strcmp(EEG.event(Idx).type, '31')
            trialType = [EEG.event(Idx).type '1'];
            limInf = 0;limSup = 0;xMax = 0;newTrial = 2;
            trialOnset = EEG.event(Idx).latency;
            
        % Add fixation onset event at beginning of first fixation
        elseif strcmp(EEG.event(Idx).type, 'R_fixation')
            if EEG.event(Idx).fix_avgpos_x > xMax
                xMax = EEG.event(Idx).fix_avgpos_x;
            end
            if EEG.event(Idx).duration < 100
                fixDur = EEG.event(Idx).duration;
                for tIdx = Idx:length(EEG.event)
                    if strcmp(EEG.event(tIdx).type, 'R_fixation')
                        if EEG.event(tIdx).fix_avgpos_x > limSup || EEG.event(tIdx).fix_avgpos_x < limInf
                            break
                        else
                            fixDur = fixDur + EEG.event(tIdx).duration;
                        end
                    end
                end
                if fixDur < 100
                    newTrial = 0;
                end
            end
            timeDiff = EEG.event(Idx).latency - trialOnset;

            if newTrial == 2
                fix = fix + 1;
                % Add new 211 or 311 event (copy orig fix and change type)
                newEvent(end + 1) = EEG.event(Idx); 
                newEvent(end).type = trialType; 
                
                % Increment trial count
                if strcmp(trialType,'211')
                    count211 = count211 + 1;
                elseif strcmp(trialType,'311')
                    count311 = count311 + 1;
                end

                newTrial = 1; % so you only add one fixation
            end
        % If saccade endpoint > xMax, update xMax
        elseif strcmp(EEG.event(Idx).type, 'R_saccade')
            if EEG.event(Idx).sac_endpos_x > xMax
                xMax = EEG.event(Idx).sac_endpos_x;
            end
        end
        newEvent(end + 1) = EEG.event(Idx);
    end
    
    disp(['Number of fixation events added: ' num2str(fix)])
    % Use newEvent as EEG event table
    EEG.event = newEvent;
    
    % Define epochs
    EpochInf = -0.1;
    EpochSup = 0.8;
    EEG = pop_epoch( EEG, { '211' '311' }, [EpochInf  EpochSup], 'newname', 'BDF file epochs', 'epochinfo', 'yes');
    EEG = eeg_checkset( EEG );
    
    % Define baseline
    BaseMin = -100;
    BaseMax = 0;
    EEG = pop_rmbase( EEG, [BaseMin BaseMax]);
    EEG = eeg_checkset( EEG );
    
    % Record number of 211 and 311 events
    newEventsTrialCount(ind_file,3) = count211;
    newEventsTrialCount(ind_file,4) = count311;
    
    % Save data
    path_to_save = 'Results\F_epoched';
    EEG.setname = ['S' num2str(S_tmp) '_ICA_epoched'];
    EEG = pop_saveset( EEG,[path_to_save '\sub_' num2str(S_tmp) '_epoched.set']);
    EEG = eeg_checkset( EEG );
    disp(' ')
    disp(['\n Participant ',num2str(S_tmp),' done!\n']);
    eeglab redraw
end

colNames = {'21', '31', '211', '311'};
save('Results\F_epoched\newEventsTrialCount.mat','newEventsTrialCount','colNames');

disp(' ')
disp('Done with all participants!');
waitbar(1,'Done with all participants!');