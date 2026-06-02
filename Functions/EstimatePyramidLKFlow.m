%% Estimate Pyramid Lucas-Kanade Optical Flow
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function estimates the dense optical flow between two DTM slices by
% using a coarse-to-fine Lucas-Kanade iteration.

%% Function Body
function [U, V] = EstimatePyramidLKFlow(Frame_0, Frame_1, Config)

    Frame_0 = single(mat2gray(Frame_0));
    Frame_1 = single(mat2gray(Frame_1));

    Pyramid_Layers = Config.Feature.Pyramid_Layers;
    Iterations = Config.Feature.Iterations;
    Window_Size = Config.Feature.Window_Size;
    LK_Epsilon = Config.Feature.LK_Epsilon;
    Max_Update = Config.Feature.Max_Update;

    Pyramid_0 = cell(Pyramid_Layers,1);
    Pyramid_1 = cell(Pyramid_Layers,1);
    Pyramid_0{1} = Frame_0;
    Pyramid_1{1} = Frame_1;
    for Layer_Index = 2:Pyramid_Layers
        Pyramid_0{Layer_Index} = imresize(Pyramid_0{Layer_Index-1},0.5,'bilinear');
        Pyramid_1{Layer_Index} = imresize(Pyramid_1{Layer_Index-1},0.5,'bilinear');
    end

    U = [];
    V = [];
    for Layer_Index = Pyramid_Layers:-1:1
        Current_0 = Pyramid_0{Layer_Index};
        Current_1 = Pyramid_1{Layer_Index};

        if isempty(U)
            U = zeros(size(Current_0),'single');
            V = zeros(size(Current_0),'single');
        else
            Target_Size = size(Current_0);
            U = 2*imresize(U,Target_Size,'bilinear');
            V = 2*imresize(V,Target_Size,'bilinear');
        end

        for Iteration_Index = 1:Iterations
            Warped_1 = warpImage(Current_1,U,V);
            [Ix,Iy] = gradient(Warped_1);
            It = Current_0 - Warped_1;

            Ix2 = boxFilter(Ix.^2,Window_Size);
            Iy2 = boxFilter(Iy.^2,Window_Size);
            Ixy = boxFilter(Ix.*Iy,Window_Size);
            Ixt = boxFilter(Ix.*It,Window_Size);
            Iyt = boxFilter(Iy.*It,Window_Size);

            Denominator = Ix2.*Iy2 - Ixy.^2 + LK_Epsilon;
            Delta_U = (Iy2.*Ixt - Ixy.*Iyt)./Denominator;
            Delta_V = (Ix2.*Iyt - Ixy.*Ixt)./Denominator;

            Delta_U = max(min(Delta_U,Max_Update),-Max_Update);
            Delta_V = max(min(Delta_V,Max_Update),-Max_Update);
            Delta_U(~isfinite(Delta_U)) = 0;
            Delta_V(~isfinite(Delta_V)) = 0;

            U = U + single(Delta_U);
            V = V + single(Delta_V);
        end

        if Config.Feature.Flow_Smooth_Sigma > 0
            U = imgaussfilt(U,Config.Feature.Flow_Smooth_Sigma);
            V = imgaussfilt(V,Config.Feature.Flow_Smooth_Sigma);
        end
    end

end

%% Local Functions
function Warped_Image = warpImage(Image, U, V)

    [X,Y] = meshgrid(1:size(Image,2),1:size(Image,1));
    Warped_Image = interp2(single(Image),single(X)+single(U),single(Y)+single(V),'linear',0);
    Warped_Image = single(Warped_Image);

end

function Filtered_Image = boxFilter(Image, Window_Size)

    Kernel = ones(Window_Size,Window_Size,'single')/(Window_Size*Window_Size);
    Filtered_Image = conv2(single(Image),Kernel,'same');

end
