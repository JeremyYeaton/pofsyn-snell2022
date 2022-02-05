% Setup directory structure for analysis
mkdir('ET_mat');
mkdir('Results');
cd('Results');
dirNames = {'A_trainingSet_preprocess','B_trainingSet_ICA','C_analysisSet_preprocess',...
    'D_ICAweighted','E_ICAcompRemoved','F_epoched','G_rejectTrials','H_binEpochs'};

for i = 1:length(dirNames)
    mkdir(dirNames(i));
end
cd('..');
disp('Directories set up.');