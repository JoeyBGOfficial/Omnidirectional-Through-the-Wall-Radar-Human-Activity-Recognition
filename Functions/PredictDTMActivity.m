%% Predict Human Activity from a New DTM
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function performs one-shot DTM preprocessing, mDOF extraction, and
% activity recognition using a saved model package or an in-memory network.

%% Function Body
function Prediction_Result = PredictDTMActivity(Input_DTM_Path, Model_Package, Config)

    if ischar(Model_Package) || isstring(Model_Package)
        Model_Package = LoadModelPackage(char(Model_Package));
    end

    if isfield(Model_Package,'Net')
        Net = Model_Package.Net;
    else
        error('The model package does not contain Net.');
    end

    if isfield(Model_Package,'Class_Names')
        Class_Names = string(Model_Package.Class_Names(:));
    else
        error('The model package does not contain Class_Names.');
    end

    Feature_Record = ExtractmDOFFeature(Input_DTM_Path, Config);
    Score_Vector = predictSingleFeature(Net,Feature_Record,Config,Class_Names);
    [Sorted_Scores,Sorted_Index] = sort(Score_Vector,'descend');

    TopK = min(Config.Inference.TopK,numel(Class_Names));
    Prediction_Result = struct();
    Prediction_Result.Input_DTM_Path = string(Input_DTM_Path);
    Prediction_Result.Predicted_Label = Class_Names(Sorted_Index(1));
    Prediction_Result.Predicted_Score = Sorted_Scores(1);
    Prediction_Result.TopK_Labels = Class_Names(Sorted_Index(1:TopK));
    Prediction_Result.TopK_Scores = Sorted_Scores(1:TopK);
    Prediction_Result.Score_Vector = Score_Vector;
    Prediction_Result.Class_Names = Class_Names;
    Prediction_Result.Feature_Record = Feature_Record;

end

%% Local Functions
function Score_Vector = predictSingleFeature(Net, Feature_Record, Config, Class_Names)

    Image_Input = reshape(single(Feature_Record.Feature_Image), ...
        size(Feature_Record.Feature_Image,1),size(Feature_Record.Feature_Image,2),1,1);
    Sequence_Input = {single(Feature_Record.Feature_Sequence)};

    try
        Score_Vector = predict(Net,Image_Input,Sequence_Input);
    catch
        try
            Score_Vector = predict(Net,{Image_Input,Sequence_Input});
        catch
            if ~isfolder(Config.Output.Inference_Folder)
                mkdir(Config.Output.Inference_Folder);
            end
            Temporary_Feature_Path = fullfile(Config.Output.Inference_Folder,'Temporary_Inference_mDOF.mat');
            Feature_Image = Feature_Record.Feature_Image;
            Feature_Sequence = Feature_Record.Feature_Sequence;
            save(Temporary_Feature_Path,'Feature_Image','Feature_Sequence');
            Temporary_Table = table(string(Temporary_Feature_Path),'VariableNames',{'FeaturePath'});
            Prediction_Datastore = BuildmDOFDatastores(Temporary_Table,table(),Config,"prediction");
            Score_Vector = predict(Net,Prediction_Datastore,'MiniBatchSize',1);
        end
    end

    Score_Vector = double(gather(Score_Vector));
    Score_Vector = Score_Vector(:)';
    if numel(Score_Vector) ~= numel(Class_Names)
        Score_Vector = reshape(Score_Vector,1,[]);
    end

end
