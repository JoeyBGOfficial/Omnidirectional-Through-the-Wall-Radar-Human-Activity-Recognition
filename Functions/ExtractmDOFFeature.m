%% Extract Micro-Doppler Optical Flow Feature
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function implements the feature extraction stage of omnidirectional
% TWR HAR: DTM preprocessing, slow-time slicing, pyramid Lucas-Kanade flow
% estimation, and horizontal mDOF feature reduction.

%% Function Body
function Feature_Record = ExtractmDOFFeature(DTM_Path, Config)

    [DTM_Amplitude, DTM_Raw] = ReadAndPreprocessDTM(DTM_Path, Config);

    Flow_Size = Config.Feature.Flow_Estimation_Size;
    DTM_for_Flow = imresize(DTM_Amplitude,[Flow_Size Flow_Size],'bilinear');

    Slow_Time_Length = Config.Feature.Slow_Time_Length_of_DTM;
    Window_Length = Config.Feature.Sliding_Frame_Window;
    Window_Overlap = Config.Feature.Sliding_Frame_Overlap;
    Frame_Length = floor(Flow_Size*Window_Length/Slow_Time_Length);
    Frame_0_Start = 1;
    Frame_0_End = min(Flow_Size,Frame_0_Start+Frame_Length-1);
    Frame_1_Start = floor(Flow_Size*(Window_Length-Window_Overlap)/Slow_Time_Length) + 1;
    Frame_1_End = min(Flow_Size,Frame_1_Start+Frame_Length-1);

    Frame_0 = DTM_for_Flow(:,Frame_0_Start:Frame_0_End);
    Frame_1 = DTM_for_Flow(:,Frame_1_Start:Frame_1_End);
    Frame_0 = imresize(Frame_0,[Flow_Size Flow_Size],'bilinear');
    Frame_1 = imresize(Frame_1,[Flow_Size Flow_Size],'bilinear');

    [Flow_U, Flow_V] = EstimatePyramidLKFlow(Frame_0, Frame_1, Config);
    [Feature_Image, Feature_Sequence, Feature_Vector, Reduced_Flow_U] = ...
        ReducemDOFFeature(Flow_U, Frame_0, Frame_1, Config);

    Feature_Record = struct();
    Feature_Record.Source_Path = string(DTM_Path);
    Feature_Record.DTM_Raw = DTM_Raw;
    Feature_Record.DTM_Amplitude = DTM_Amplitude;
    Feature_Record.Frame_0 = single(Frame_0);
    Feature_Record.Frame_1 = single(Frame_1);
    Feature_Record.Flow_U = single(Flow_U);
    Feature_Record.Flow_V = single(Flow_V);
    Feature_Record.Reduced_Flow_U = single(Reduced_Flow_U);
    Feature_Record.Feature_Image = single(Feature_Image);
    Feature_Record.Feature_Sequence = single(Feature_Sequence);
    Feature_Record.Feature_Vector = single(Feature_Vector);

end
