%% Main Script for Omnidirectional TWR HAR Based on mDOF
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This script trains and evaluates an omnidirectional through-the-wall radar
% human activity recognition model based on micro-Doppler optical flow
% feature. The default dataset is Multi-View_RWSet. The model is trained
% only by the 0-degree training/validation set and is directly tested on
% 30~330-degree orientations.
%
% How to Run:
% Put this script in the root folder of the open-source project and run it
% directly. The generated features, trained model, and result figures are
% stored inside this project folder.

%% Initialization of Matlab Script
clear;
close all;
clc;
disp("---------- © Author: JoeyBG © ----------");

Project_Path = fileparts(mfilename('fullpath'));
addpath(fullfile(Project_Path,'Functions'));
addpath(fullfile(Project_Path,'Visualization'));

Config = JoeyBG_Default_Config(Project_Path);

% Change the following option to "SimHSet" when running the simulated set.
Config.Dataset_Name = "RWSet";
Config.Output.Model_File_Name = "JoeyBG_mDOF_" + Config.Dataset_Name + "_Model.mat";

% Suggested high-accuracy settings: Flow_Estimation_Size = 384 or 512.
% Suggested fast-debug settings: Flow_Estimation_Size = 96, MaxEpochs = 2.
Config.Feature.Flow_Estimation_Size = 256;
Config.Feature.Output_Size = 128;
Config.Training.MaxEpochs = 80;
Config.Training.MiniBatchSize = 32;
Config.Training.ShowTrainingProgress = true;
Config.Evaluation.Run_Full_Testing = true;

rng(Config.Random_Seed,'twister');

%% Build Dataset Index
disp('[JoeyBG] Building dataset index...');
Dataset_Index = BuildDatasetIndex(Config);
Class_Names = Dataset_Index.Class_Names;
Config.Class_Names = Class_Names;

[Training_Table, Validation_Table] = SplitTrainingValidationSet( ...
    Dataset_Index.TrainingValidationTable, Config);

fprintf('[JoeyBG] Training samples: %d.\n',height(Training_Table));
fprintf('[JoeyBG] Validation samples: %d.\n',height(Validation_Table));
fprintf('[JoeyBG] Testing samples: %d.\n',height(Dataset_Index.TestingTable));

%% Extract and Cache mDOF Features
disp('[JoeyBG] Preparing training mDOF feature cache...');
Training_Table = PreparemDOFFeatureCache(Training_Table,Config,Config.Feature.Force_Recompute_Features);

disp('[JoeyBG] Preparing validation mDOF feature cache...');
Validation_Table = PreparemDOFFeatureCache(Validation_Table,Config,Config.Feature.Force_Recompute_Features);

disp('[JoeyBG] Plotting a feature extraction example...');
PlotFeatureExample(Training_Table(1,:),Config);

%% Build Datastores and Train the Network
disp('[JoeyBG] Building mDOF datastores...');
[Training_Datastore, Validation_Datastore] = BuildmDOFDatastores(Training_Table,Validation_Table,Config);

disp('[JoeyBG] Starting dual-branch mDOF recognition network training...');
[Net, Train_Info, ~] = TrainmDOFNetwork(Training_Datastore,Validation_Datastore,Config,numel(Class_Names));
disp('[JoeyBG] Network training has been completed.');

%% Validation Evaluation
disp('[JoeyBG] Evaluating validation set...');
Validation_Metrics = ComputeClassificationMetrics(Net,Validation_Table,Config,Class_Names);
fprintf('[JoeyBG] Validation accuracy: %.2f%%.\n',Validation_Metrics.Accuracy);
fprintf('[JoeyBG] Validation macro-F1: %.2f%%.\n',Validation_Metrics.MacroF1);
PlotValidationResults(Validation_Metrics,Config,'Validation_Results.png');

%% Cross-Orientation Testing
Orientation_Results = [];
if Config.Evaluation.Run_Full_Testing
    disp('[JoeyBG] Evaluating cross-orientation testing set...');
    Orientation_Results = EvaluateByOrientation(Net,Dataset_Index.TestingTable,Config,Class_Names);
    PlotOrientationAccuracy(Orientation_Results,Config,'Orientation_Accuracy.png');

    disp('[JoeyBG] Cross-orientation testing summary:');
    disp(Orientation_Results.Orientation_Table);
    if Orientation_Results.Pass_Target
        fprintf('[JoeyBG] All testing orientations satisfy the %.2f%% target.\n', ...
            Config.Evaluation.Target_Minimum_Orientation_Accuracy);
    else
        fprintf('[JoeyBG] Minimum testing accuracy is %.2f%%. Please tune only by validation-set feedback.\n', ...
            Orientation_Results.Minimum_Accuracy);
    end
end

%% Save Runtime Results and Model Package
if ~isfolder(Config.Output.Result_Folder)
    mkdir(Config.Output.Result_Folder);
end
save(fullfile(Config.Output.Result_Folder,'Training_Runtime_Results.mat'), ...
    'Config','Dataset_Index','Training_Table','Validation_Table','Train_Info', ...
    'Validation_Metrics','Orientation_Results','-v7.3');

SaveModelPackage(Net,Train_Info,Config,Class_Names,Validation_Metrics,Orientation_Results);
disp('[JoeyBG] One-key training workflow has finished.');
