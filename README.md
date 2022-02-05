# pofsyn-snell2022
Matlab code used for the EEG analyses presented in Snell et al. (2022) "Parallel word reading revealed by fixation-related brain potentials." [[full text]()] (ADD LINK)

# Requirements
This is all Matlab code and requires the following open-source toolboxes to run:
- [EEGLAB](https://sccn.ucsd.edu/eeglab/index.php)
- [EYE-EEG Toolbox](http://www2.hu-berlin.de/eyetracking-eeg/)
- [Mass-Univariate ERP Toolbox](https://openwetware.org/wiki/Mass_Univariate_ERP_Toolbox)

You will also need to make sure that you have Matlab configured for parallelization, as it is used to speed up the ICA training process.

If you have any questions about this code feel free to e-mail the second author at jyeaton@uci.edu. If you use this code in a future project, please cite the publication above as well as the required toolboxes.

If you'd like to replicate the findings from the paper, you should first download the data from [the OSF repository](https://osf.io/94q8t/). You should download the 'Raw data' directory as a .zip file. Once you unpack it, open MATLAB in that folder. You should also place the code here in a 'scripts' directory in the same location.

# Pipeline
The annotation needs some work, but all of the code is there. The scripts are to be run alphabetically:
- 00_Setup_directories.m: This just makes all the directories that are used in the pipeline. You'll need to make sure you're in the same directory as the data you downloaded above.
- A_PreProcessingPOFSYN_trainingSet.m: Preprocesses raw EEG data for ICA training
- B_PreProcessingPOFSYN_ICA.m: Runs ICA decomposition on overweighted training data
- C_PreProcessingPOFSYN_analysisSet.m: Preproceeses raw EEG data with different parameters for analysis
- D_Apply_ICA_weights.m: Applies ICA weights from training set to analysis set
- E_Remove_ICA_components.m: Removes eye-movement based ICA components from data 
- F_New_events_fixation.m: Creates new events by condition according to onset of fixation instead of boundary crossing
- G_Automatic_reject_bad_trials.m: Removes trials containing values that fall outside of acceptable thresholds
- H_Bins_211_311_fixation.m: Creates bins by condition for each participant
- I_Cluster_based_permutation_test.m: The code to run the cluster based permutation test presented in the paper
- J_Figures.m: The code to reproduce the Figures 3, 4, and 5 from the paper
- K_Trial_accounting.m: A transparency script to count how many trials were lost at the various stages of rejection

The respository also contains two functions to facilitate parallelization of the ICA training:
- parsave.m: Saves data structure from within parallel loop
- mat2set.m: Converts .mat file saved during parallel loop back to EEGLAB .set file

As well as some other files that are used in the processing or plotting:
- EEG_times.mat: Vector of times (in ms) for plotting FRP traces
- chan_labels.mat: Channel names for all 68 electrodes
- chanlocs.mat: Channel coordinates in EEGLAB structure
- channel_location_LPC_add_ocular.ced: Channel coordinates in text format
- mask.mat: Boolean vector for which of the 29 participants to include in the analysis (Sub 8 is excluded)
- name_list.mat: List of channel names for 64 electrodes used in plotting
