%% Default Configuration for Omnidirectional TWR HAR Based on mDOF
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function defines the default configuration of the open-source
% omnidirectional through-the-wall radar human activity recognition method
% based on micro-Doppler optical flow feature.

%% Function Body
function Config = JoeyBG_Default_Config(Project_Path)

    if nargin < 1 || isempty(Project_Path)
        Project_Path = fileparts(fileparts(mfilename("fullpath")));
    end

    Config = struct();
    Config.Project_Path = char(Project_Path);
    Config.Dataset_Name = "RWSet";                                          % Options: "RWSet" or "SimHSet".
    Config.Random_Seed = 20260602;
    Config.Training_Validation_Ratio = 0.80;

    % Parameters for micro-Doppler optical flow feature extraction.
    Config.Feature.Slow_Time_Length_of_DTM = 4;                             % Slow-time length of one DTM (s).
    Config.Feature.Sliding_Frame_Window = 3;                                % Sliding window length (s).
    Config.Feature.Sliding_Frame_Overlap = 2;                               % Sliding window overlap (s).
    Config.Feature.Max_Frequency_of_DTM = 60;                               % Doppler frequency range is [-60, 60] Hz.
    Config.Feature.Flow_Estimation_Size = 256;                              % Increase to 384/512 for final high-accuracy training.
    Config.Feature.Output_Size = 128;                                       % Size of the reduced mDOF feature map.
    Config.Feature.Window_Size = 7;                                         % Local window size of pyramid Lucas-Kanade.
    Config.Feature.Iterations = 3;                                          % Iterations in each pyramid layer.
    Config.Feature.Pyramid_Layers = 3;                                      % Number of pyramid layers.
    Config.Feature.LK_Epsilon = 1e-3;                                       % Stabilizer of the LK normal equation.
    Config.Feature.Max_Update = 5;                                          % Pixel-level flow update clipping.
    Config.Feature.Flow_Smooth_Sigma = 0.60;                                % Gaussian smoothing strength for the flow field.
    Config.Feature.Robust_Percentile_Low = 1;                               % Low percentile for robust feature normalization.
    Config.Feature.Robust_Percentile_High = 99;                             % High percentile for robust feature normalization.
    Config.Feature.Energy_Weight_Power = 0.50;                              % Amplitude weight used to suppress weak-background flow.
    Config.Feature.Force_Recompute_Features = false;                        % Reuse cached mDOF features by default.

    % Parameters for dual-branch recognition network training.
    Config.Training.MiniBatchSize = 32;
    Config.Training.MaxEpochs = 80;
    Config.Training.InitialLearnRate = 1.0e-3;
    Config.Training.L2Regularization = 1.0e-4;
    Config.Training.Dropout = 0.40;
    Config.Training.LearnRateDropFactor = 0.50;
    Config.Training.LearnRateDropPeriod = 20;
    Config.Training.ValidationFrequency = 50;
    Config.Training.ValidationPatience = Inf;
    Config.Training.ExecutionEnvironment = "auto";
    Config.Training.OutputNetwork = "best-validation-loss";
    Config.Training.ShowTrainingProgress = true;

    % Parameters for testing and inference.
    Config.Evaluation.Run_Full_Testing = true;
    Config.Evaluation.Target_Minimum_Orientation_Accuracy = 80;
    Config.Inference.TopK = 3;

    % Visualization parameters.
    Config.Visualization.Font_Name = 'Palatino Linotype';
    Config.Visualization.Font_Size_Basis = 15;
    Config.Visualization.Font_Size_Axis = 16;
    Config.Visualization.Font_Size_Title = 18;
    Config.Visualization.Font_Weight_Basis = 'normal';
    Config.Visualization.Font_Weight_Axis = 'normal';
    Config.Visualization.Font_Weight_Title = 'bold';
    Config.Visualization.Figure_Visible = "on";
    Config.Visualization.Save_Figures = true;
    Config.Visualization.JoeyBG_Colormap = [0.6196 0.0039 0.2588;
                                            0.8353 0.2431 0.3098;
                                            0.9569 0.4275 0.2627;
                                            0.9922 0.6824 0.3804;
                                            0.9961 0.8784 0.5451;
                                            1.0000 1.0000 0.7490;
                                            0.9020 0.9608 0.5961;
                                            0.6706 0.8667 0.6431;
                                            0.4000 0.7608 0.6471;
                                            0.1961 0.5333 0.7412;
                                            0.3686 0.3098 0.6353];
    Config.Visualization.JoeyBG_Colormap_Flip = flip(Config.Visualization.JoeyBG_Colormap);

    % Runtime output folders. These folders are created automatically.
    Config.Output.Feature_Folder = fullfile(Config.Project_Path,'Generated_Features');
    Config.Output.Model_Folder = fullfile(Config.Project_Path,'Trained_Models');
    Config.Output.Result_Folder = fullfile(Config.Project_Path,'Training_Results');
    Config.Output.Inference_Folder = fullfile(Config.Project_Path,'Inference_Results');
    Config.Output.Model_File_Name = "JoeyBG_mDOF_" + Config.Dataset_Name + "_Model.mat";

end
