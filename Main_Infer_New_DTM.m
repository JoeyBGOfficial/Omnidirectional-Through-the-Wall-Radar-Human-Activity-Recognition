%% Main Script for New DTM Inference Based on mDOF
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This script performs one-key inference for a new Doppler-time map (DTM)
% using the trained omnidirectional TWR HAR mDOF model package.
%
% How to Run:
% First run Main_Train_Omnidirectional_TWR_HAR_mDOF.m to generate a model
% package. Then set Input_DTM_Path below and run this script.

%% Initialization of Matlab Script
clear;
close all;
clc;
disp('---------- © Author: JoeyBG © ----------');

Project_Path = fileparts(mfilename('fullpath'));
addpath(fullfile(Project_Path,'Functions'));
addpath(fullfile(Project_Path,'Visualization'));

Runtime_Config = JoeyBG_Default_Config(Project_Path);

% Set the input DTM image path here.
Input_DTM_Path = fullfile(Project_Path,'Multi-View_RWSet', ...
    'Multi-View_RW_Testing_Set','30','Walking','1.png');

% Set the trained model package path here.
Model_Package_Path = fullfile(Project_Path,'Trained_Models','JoeyBG_mDOF_RWSet_Model.mat');

%% Load Model Package and Restore Feature Parameters
Model_Package = LoadModelPackage(Model_Package_Path);
if isfield(Model_Package,'Config')
    Config = Model_Package.Config;
    Config.Project_Path = Project_Path;
    Config.Output = Runtime_Config.Output;
    Config.Visualization = Runtime_Config.Visualization;
    Config.Inference = Runtime_Config.Inference;
else
    Config = Runtime_Config;
end

%% mDOF Feature Extraction and Activity Recognition
Prediction_Result = PredictDTMActivity(Input_DTM_Path,Model_Package,Config);

fprintf('Input DTM: %s\n',Input_DTM_Path);
fprintf('Predicted activity: %s (confidence %.2f%%).\n', ...
    Prediction_Result.Predicted_Label,100*Prediction_Result.Predicted_Score);

disp('Top-K prediction results:');
for i = 1:numel(Prediction_Result.TopK_Labels)
    fprintf('    %s: %.2f%%\n',Prediction_Result.TopK_Labels(i),100*Prediction_Result.TopK_Scores(i));
end

PlotInferenceResult(Prediction_Result,Config,'Inference_Result.png');
disp('One-key inference workflow has finished.');
