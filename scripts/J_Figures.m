% Pipeline of processing for EEG data from POP-R ERC project
% Experiment : POF-SYN (Parafoveal-on-Foveal Syntax effect)
% (c) Jeremy YEATON
% Date created : June 2020
% Updated : January 2022
%% Clear the workspace
clear all;close all;clc;home

% Load files
load('scripts/EEG_times.mat');
load('scripts/chanlocs.mat');
load('all_data.mat');
load('scripts/chan_labels.mat');

nSubs = size(all_data.c21,3);
disp(['Number of subs: ' num2str(nSubs)])

%% Snell et al. 2022 - Figure 3 (topos)
tBnds = 200:50:800;

cax = [-2.5 2.5];
figure('Renderer', 'painters', 'Position', [100 100 1000 500]);
nRow = 2; nCol = 6;
for t = 1:length(tBnds)-1
    subplot(nRow, nCol, t)
    tWin = find(EEG_times>= tBnds(t) & EEG_times < tBnds(t+1));
    cond21 = mean(all_data.c21(1:64,tWin,:),[2 3]);
    cond31 = mean(all_data.c31(1:64,tWin,:),[2 3]);
%     condDiff = cond31 - cond21;
    condDiff = cond21 - cond31;
    topoplot(-condDiff,chanlocs(1:64),'headrad','rim')
    caxis(cax)
    title([num2str(tBnds(t)) '-' num2str(tBnds(t+1)) ' ms'])
end
hold on
cb = colorbar;
x0 = cb.Position(1) + .065;
y0 = cb.Position(2) - .075;
width = .02;
height = cb.Position(4) + .15;
cb.Position = [x0 y0 width height];
title(cb,'\muV')
%% Snell et al. 2022 - FIgure 4 (FRP traces)
% Select electrodes
channels = {'F3','Fz','F4','CP3','Cz','CP4','Pz'};

% Define time window
tMin = -100;
tMax = 800;
time_window = find(EEG_times>= tMin & EEG_times <= tMax);

% Set range
yMin = -5;
yMax = 7;

lineWidth = 2;

figure('Renderer', 'painters', 'Position', [100 100 1000 750]);

% Set subplot locations in 3x3 grid
plotSpots = [1:6,8];

for chanIdx = 1:length(channels)
    subplot(3,3,plotSpots(chanIdx))
    % Get index of electrode
    chanName = channels{chanIdx};
    chan = find(strcmp(chan_labels, chanName));
    % Generate mean curve for electrode by condition
    condSame = mean(all_data.c21(chan,:,:),3);
    condDiff = mean(all_data.c31(chan,:,:),3);
    % Plot traces
    hold on
    FRP_21 = plot(EEG_times(time_window),condSame(time_window),'LineWidth',lineWidth);
    FRP_31 = plot(EEG_times(time_window),condDiff(time_window),'LineStyle','-.','LineWidth',lineWidth);
    hold off
    if chanIdx == 5
        legend([FRP_21, FRP_31], 'compatible', 'incompatible','Location','south');
    end
    set(gca, 'ydir', 'reverse', 'xaxislocation', 'origin', 'yaxislocation','origin','ylim',[yMin yMax]);
    xticks(-100:100:700)
    xticklabels({'-100', '0', '', '200', '', '400', '', '600', '700'});%, '800'});
    xlim([tMin tMax])
    yticks([-4 6])
    yticklabels({'-4 \muV','6 \muV'})
    title(chanName);
    set(gca, 'Layer', 'top')
    ax = gca;
    box on
    ax.BoxStyle = 'full';
end

% Map of electrode locations
EEG = pop_loadset('filename','sub_1_bin211.set','filepath','Results\\H_binEpochs\\');
EEG = eeg_checkset( EEG );
EEG = pop_select( EEG,'channel',channels);
EEG = eeg_checkset( EEG );
subplot(3,3,9)
topoplot([],EEG.chanlocs, 'style', 'blank',  'electrodes', 'labelpoint', 'chaninfo', EEG.chaninfo,'headrad',.45);
%% Snell et al. 2022 - Figure 5 (Raster)
load  Results\allTrials.GND -MAT
t_test = GND.t_tests(1);
mask = t_test.adj_pval < 0.05;
t_test.adj_pval(~mask) = 1;
figure('Renderer', 'painters', 'Position', [100 100 500 800]);
tIdxs = t_test.used_tpt_ids;
tvals = GND.grands_t(:,tIdxs,3);
tvals(~mask) = 0;

imagesc(tvals)
yticks(1:64);
yticklabels(chan_labels(1:64))
xticks(1:50:400)
xticklabels([0 100 200 300 400 500 600 700 800])
xlabel('Time (ms)')
ylabel('Electrode')
caxis([-5 5])
colormap(jet)
hcb = colorbar;
title(hcb,'t-val')