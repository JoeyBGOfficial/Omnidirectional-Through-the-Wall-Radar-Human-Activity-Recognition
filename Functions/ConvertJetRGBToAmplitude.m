%% Convert Jet-Color DTM Image to Normalized Amplitude
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function converts saved jet-color Doppler-time maps back into an
% approximate normalized amplitude domain by nearest-neighbor matching in
% the MATLAB jet colormap.

%% Function Body
function DTM_Amplitude = ConvertJetRGBToAmplitude(DTM_Image)

    if ismatrix(DTM_Image) || size(DTM_Image,3) == 1
        DTM_Amplitude = mat2gray(im2single(DTM_Image));
        return;
    end

    if ~isa(DTM_Image,'uint8')
        DTM_Image = im2uint8(DTM_Image);
    end

    Jet_Map = single(round(jet(256)*255));
    RGB_List = reshape(DTM_Image,[],3);
    [Unique_RGB_List,~,Unique_Index] = unique(RGB_List,'rows');
    Unique_RGB_List = single(Unique_RGB_List);

    Amplitude_Index = zeros(size(Unique_RGB_List,1),1,'single');
    Chunk_Size = 20000;
    for Unique_Start = 1:Chunk_Size:size(Unique_RGB_List,1)
        Unique_End = min(Unique_Start+Chunk_Size-1,size(Unique_RGB_List,1));
        Unique_RGB_Block = Unique_RGB_List(Unique_Start:Unique_End,:);
        Distance_Matrix = (Unique_RGB_Block(:,1) - Jet_Map(:,1)').^2 + ...
            (Unique_RGB_Block(:,2) - Jet_Map(:,2)').^2 + ...
            (Unique_RGB_Block(:,3) - Jet_Map(:,3)').^2;
        [~,Current_Index] = min(Distance_Matrix,[],2);
        Amplitude_Index(Unique_Start:Unique_End) = single(Current_Index);
    end

    DTM_Amplitude = reshape((double(Amplitude_Index(Unique_Index))-1)/255, ...
        size(DTM_Image,1),size(DTM_Image,2));
    DTM_Amplitude = single(DTM_Amplitude);

end
