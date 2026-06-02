%% Compute Classification Metrics
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function computes accuracy, confusion matrix, precision, recall, and
% F1-score for the trained mDOF recognition model.

%% Function Body
function Metrics = ComputeClassificationMetrics(Net, Feature_Table, Config, Class_Names)

    if nargin < 4 || isempty(Class_Names)
        Class_Names = categories(Feature_Table.Label);
    end
    Class_Names = string(Class_Names(:));
    Number_of_Classes = numel(Class_Names);

    Prediction_Datastore = BuildmDOFDatastores(Feature_Table,table(),Config,"prediction");
    Score_Matrix = predict(Net,Prediction_Datastore,'MiniBatchSize',Config.Training.MiniBatchSize);
    Score_Matrix = normalizeScoreMatrix(Score_Matrix,height(Feature_Table),Number_of_Classes);

    [~,Predicted_Index] = max(Score_Matrix,[],2);
    Predicted_Labels = categorical(Class_Names(Predicted_Index),Class_Names);
    True_Labels = categorical(string(Feature_Table.ClassName),Class_Names);
    Category_Order = categorical(Class_Names,Class_Names);

    Confusion_Matrix = confusionmat(True_Labels,Predicted_Labels,'Order',Category_Order);
    Accuracy = 100*sum(diag(Confusion_Matrix))/max(1,sum(Confusion_Matrix(:)));

    Recall = diag(Confusion_Matrix)./max(1,sum(Confusion_Matrix,2));
    Precision = diag(Confusion_Matrix)./max(1,sum(Confusion_Matrix,1)');
    F1 = 2*(Precision.*Recall)./max(eps,Precision+Recall);
    Class_Accuracy = 100*Recall;

    Metrics = struct();
    Metrics.Accuracy = Accuracy;
    Metrics.MacroF1 = 100*mean(F1,'omitnan');
    Metrics.Confusion_Matrix = Confusion_Matrix;
    Metrics.Class_Names = Class_Names;
    Metrics.True_Labels = True_Labels;
    Metrics.Predicted_Labels = Predicted_Labels;
    Metrics.Score_Matrix = Score_Matrix;
    Metrics.Precision = 100*Precision;
    Metrics.Recall = 100*Recall;
    Metrics.F1 = 100*F1;
    Metrics.Class_Accuracy = Class_Accuracy;

end

%% Local Functions
function Score_Matrix = normalizeScoreMatrix(Score_Matrix, Number_of_Samples, Number_of_Classes)

    if iscell(Score_Matrix)
        Score_Matrix = Score_Matrix{1};
    end
    Score_Matrix = double(gather(Score_Matrix));

    if size(Score_Matrix,1) == Number_of_Classes && size(Score_Matrix,2) == Number_of_Samples
        Score_Matrix = Score_Matrix';
    end
    if size(Score_Matrix,2) ~= Number_of_Classes && size(Score_Matrix,1) == Number_of_Classes
        Score_Matrix = Score_Matrix';
    end
    if size(Score_Matrix,1) ~= Number_of_Samples
        Score_Matrix = reshape(Score_Matrix,Number_of_Samples,[]);
    end

end
