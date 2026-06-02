%% Read and Preprocess DTM Image
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function reads a DTM image and performs robust amplitude-domain
% preprocessing before micro-Doppler optical flow estimation.

%% Function Body
function [DTM_Amplitude, DTM_Raw] = ReadAndPreprocessDTM(DTM_Path, Config)

    if ~isfile(DTM_Path)
        error("DTM image does not exist: %s", DTM_Path);
    end

    DTM_Raw = imread(DTM_Path);
    DTM_Amplitude = ConvertJetRGBToAmplitude(DTM_Raw);
    DTM_Amplitude = mat2gray(DTM_Amplitude);

    Contrast_Level = JoeyBG_Robust_Percentile(DTM_Amplitude,99) - ...
        JoeyBG_Robust_Percentile(DTM_Amplitude,45);

    if strcmpi(Config.Dataset_Name,"RWSet") || strcmpi(Config.Dataset_Name,"Multi-View_RWSet")
        if Contrast_Level < 0.30
            Noise_Percentile = 82;
            Stretch_Low = 20;
            Stretch_High = 99.8;
            Smooth_Sigma = 0.70;
            Gamma_Value = 1.05;
        else
            Noise_Percentile = 42;
            Stretch_Low = 1;
            Stretch_High = 99.8;
            Smooth_Sigma = 0.45;
            Gamma_Value = 0.75;
        end
    else
        Noise_Percentile = 35;
        Stretch_Low = 1;
        Stretch_High = 99.5;
        Smooth_Sigma = 0.35;
        Gamma_Value = 0.90;
    end

    Noise_Level = JoeyBG_Robust_Percentile(DTM_Amplitude,Noise_Percentile);
    DTM_Enhanced = DTM_Amplitude - Noise_Level;
    DTM_Enhanced(DTM_Enhanced < 0) = 0;

    if any(DTM_Enhanced(:) > 0)
        DTM_Enhanced = medfilt2(DTM_Enhanced,[3 3],'symmetric');
        DTM_Enhanced = imgaussfilt(DTM_Enhanced,Smooth_Sigma);
        Active_Points = DTM_Enhanced(DTM_Enhanced > 0);
        Low_Level = JoeyBG_Robust_Percentile(Active_Points,Stretch_Low);
        High_Level = JoeyBG_Robust_Percentile(Active_Points,Stretch_High);
        if High_Level > Low_Level
            DTM_Enhanced = (DTM_Enhanced - Low_Level)/(High_Level - Low_Level);
        else
            DTM_Enhanced = mat2gray(DTM_Enhanced);
        end
    else
        DTM_Enhanced = mat2gray(DTM_Amplitude);
    end

    DTM_Enhanced(DTM_Enhanced < 0) = 0;
    DTM_Enhanced(DTM_Enhanced > 1) = 1;
    DTM_Amplitude = single(DTM_Enhanced.^Gamma_Value);

end
