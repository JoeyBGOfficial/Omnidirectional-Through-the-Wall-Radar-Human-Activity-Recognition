%% Reduce Micro-Doppler Optical Flow Feature
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function reduces the horizontal component of optical flow into a
% compact 128 x 128 mDOF feature map and a 128-step sequence matrix.

%% Function Body
function [Feature_Image, Feature_Sequence, Feature_Vector, Reduced_Flow_U] = ReducemDOFFeature(Flow_U, Frame_0, Frame_1, Config)

    Output_Size = Config.Feature.Output_Size;
    Reduced_Flow_U = imresize(single(Flow_U),[Output_Size Output_Size],'bilinear');

    Energy_Map = imresize((single(Frame_0)+single(Frame_1))/2,[Output_Size Output_Size],'bilinear');
    Energy_Map = mat2gray(Energy_Map);
    Energy_Map = Energy_Map.^Config.Feature.Energy_Weight_Power;

    Reduced_Flow_U = Reduced_Flow_U.*single(Energy_Map);
    Reduced_Flow_U = Reduced_Flow_U - median(Reduced_Flow_U(:),'omitnan');

    Low_Level = JoeyBG_Robust_Percentile(Reduced_Flow_U,Config.Feature.Robust_Percentile_Low);
    High_Level = JoeyBG_Robust_Percentile(Reduced_Flow_U,Config.Feature.Robust_Percentile_High);
    if High_Level > Low_Level
        Reduced_Flow_U = (Reduced_Flow_U - Low_Level)/(High_Level - Low_Level);
        Reduced_Flow_U(Reduced_Flow_U < 0) = 0;
        Reduced_Flow_U(Reduced_Flow_U > 1) = 1;
        Reduced_Flow_U = 2*Reduced_Flow_U - 1;
    else
        Reduced_Flow_U = zeros(Output_Size,Output_Size,'single');
    end

    Reduced_Flow_U = smoothdata(Reduced_Flow_U,1,'movmean',3);
    Reduced_Flow_U = smoothdata(Reduced_Flow_U,2,'movmean',3);
    Reduced_Flow_U(~isfinite(Reduced_Flow_U)) = 0;

    Feature_Image = reshape(single(Reduced_Flow_U),Output_Size,Output_Size,1);
    Feature_Sequence = single(Reduced_Flow_U);
    Feature_Vector = single(mean(Reduced_Flow_U,1,'omitnan'));

end
