%% Build Dual-Branch mDOF Recognition Network
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function builds a two-input recognition network. The image branch
% learns local mDOF textures, while the sequence branch learns temporal
% Doppler-bin dynamics. The fused feature is mapped to activity labels.

%% Function Body
function Layer_Graph = BuildDualBranchmDOFNetwork(Config, Number_of_Classes)

    Feature_Size = Config.Feature.Output_Size;
    Dropout_Rate = Config.Training.Dropout;

    Layer_Graph = layerGraph();

    Image_Branch = [
        imageInputLayer([Feature_Size Feature_Size 1], ...
            'Name','mDOF_Image_Input','Normalization','none')
        convolution2dLayer(5,16,'Padding','same','Name','Image_Conv_1')
        batchNormalizationLayer('Name','Image_BN_1')
        reluLayer('Name','Image_Relu_1')
        maxPooling2dLayer(2,'Stride',2,'Name','Image_Pool_1')
        convolution2dLayer(3,32,'Padding','same','Name','Image_Conv_2')
        batchNormalizationLayer('Name','Image_BN_2')
        reluLayer('Name','Image_Relu_2')
        maxPooling2dLayer(2,'Stride',2,'Name','Image_Pool_2')
        convolution2dLayer(3,64,'Padding','same','Name','Image_Conv_3')
        batchNormalizationLayer('Name','Image_BN_3')
        reluLayer('Name','Image_Relu_3')
        globalAveragePooling2dLayer('Name','Image_Global_Average')
        flattenLayer('Name','Image_Flatten')
        fullyConnectedLayer(128,'Name','Image_FC')
        reluLayer('Name','Image_FC_Relu')
        dropoutLayer(Dropout_Rate,'Name','Image_Dropout')];

    Sequence_Branch = [
        sequenceInputLayer(Feature_Size,'Name','mDOF_Sequence_Input','Normalization','none')
        bilstmLayer(128,'OutputMode','last','Name','Sequence_BiLSTM')
        dropoutLayer(Dropout_Rate,'Name','Sequence_Dropout_1')
        fullyConnectedLayer(128,'Name','Sequence_FC')
        reluLayer('Name','Sequence_FC_Relu')
        dropoutLayer(Dropout_Rate,'Name','Sequence_Dropout_2')];

    Fusion_Branch = [
        concatenationLayer(1,2,'Name','Feature_Fusion')
        fullyConnectedLayer(128,'Name','Fusion_FC_1')
        reluLayer('Name','Fusion_Relu_1')
        dropoutLayer(Dropout_Rate,'Name','Fusion_Dropout')
        fullyConnectedLayer(Number_of_Classes,'Name','Activity_FC')
        softmaxLayer('Name','Activity_Softmax')
        classificationLayer('Name','Activity_Classification')];

    Layer_Graph = addLayers(Layer_Graph,Image_Branch);
    Layer_Graph = addLayers(Layer_Graph,Sequence_Branch);
    Layer_Graph = addLayers(Layer_Graph,Fusion_Branch);

    Layer_Graph = connectLayers(Layer_Graph,'Image_Dropout','Feature_Fusion/in1');
    Layer_Graph = connectLayers(Layer_Graph,'Sequence_Dropout_2','Feature_Fusion/in2');

end
