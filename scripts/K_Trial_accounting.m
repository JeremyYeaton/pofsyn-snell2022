% Pipeline of processing for EEG data from POP-R ERC project
% Experiment : POF-SYN (Parafoveal-on-Foveal Syntax effect)
% (c) Jeremy YEATON
% Date created : June 2020
% Updated : January 2022
%% Load mask to ID participants who made the final cut
load('all_data_the_end.mat','mask');
nSubs = sum(mask);
totalTrials = nSubs * 128;

%% Load ICA rejection data
load('Results\E_ICAcompRemoved\componentsRemoved.mat')
data = compsRemoved(mask,:);

meanCompsRemoved = mean(data(:,2));

%% Load data from F
load('Results\F_epoched\newEventsTrialCount.mat')
% See how many trials were excluded for EEG & blink reasons
data = newEventsTrialCount(mask,:);

blinksBySuj = 128 - sum(data(:,1:2),2);
disp(['Blinks: max = ' num2str(max(blinksBySuj)) ', min = ' num2str(min(blinksBySuj)) ', mean = ' num2str(mean(blinksBySuj)) ' (SD = ' num2str(std(blinksBySuj))])

blinkTrials = totalTrials - sum(data(:,1:2),[1 2]);
blinkPercent = blinkTrials/totalTrials;
totalRej = blinkTrials;

skipBySuj = (128 - sum(data(:,3:4),2)) - blinksBySuj;
disp(['Skips: max = ' num2str(max(skipBySuj)) ', min = ' num2str(min(skipBySuj)) ', mean = ' num2str(mean(skipBySuj)) ' (SD = ' num2str(std(skipBySuj))])

skipTrials = (totalTrials - sum(data(:,3:4),[1 2])) - totalRej;
skipPercent = skipTrials/totalTrials;
totalRej = totalRej + skipTrials;
%% Load final trial counts
load('all_data_the_end.mat','mask', 't1')

finTrls = t1(mask,:);
finTrls(:,3) = finTrls(:,1) - finTrls(:,2);

disp(['Trls cond 1: max = ' num2str(max(finTrls(:,1))) ', min = ' num2str(min(finTrls(:,1))) ', mean = ' num2str(mean(finTrls(:,1))) ' (SD = ' num2str(std(finTrls(:,1)))])
disp(['Trls cond 2: max = ' num2str(max(finTrls(:,2))) ', min = ' num2str(min(finTrls(:,2))) ', mean = ' num2str(mean(finTrls(:,2))) ' (SD = ' num2str(std(finTrls(:,2)))])

finalSum = sum(t1(mask,:),[1 2]);
autoRejTrials = totalTrials - totalRej - finalSum;
autoRejPercent = autoRejTrials/(totalTrials/2);