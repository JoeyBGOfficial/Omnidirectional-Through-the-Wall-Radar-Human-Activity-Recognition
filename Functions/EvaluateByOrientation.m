%% Evaluate Recognition Accuracy by Orientation
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function evaluates the trained mDOF model on 30~330-degree testing
% views and returns accuracy metrics for every orientation.

%% Function Body
function Orientation_Results = EvaluateByOrientation(Net, Testing_Table, Config, Class_Names)

    Angle_List = unique(Testing_Table.Angle);
    Angle_List = sort(Angle_List(:));

    Accuracy_List = zeros(numel(Angle_List),1);
    MacroF1_List = zeros(numel(Angle_List),1);
    Sample_Number_List = zeros(numel(Angle_List),1);
    Metrics_By_Angle = cell(numel(Angle_List),1);

    for Angle_Index = 1:numel(Angle_List)
        Current_Angle = Angle_List(Angle_Index);
        Current_Table = Testing_Table(Testing_Table.Angle == Current_Angle,:);
        Current_Table = PreparemDOFFeatureCache(Current_Table,Config,Config.Feature.Force_Recompute_Features);
        Current_Metrics = ComputeClassificationMetrics(Net,Current_Table,Config,Class_Names);

        Accuracy_List(Angle_Index) = Current_Metrics.Accuracy;
        MacroF1_List(Angle_Index) = Current_Metrics.MacroF1;
        Sample_Number_List(Angle_Index) = height(Current_Table);
        Metrics_By_Angle{Angle_Index} = Current_Metrics;

        fprintf('[JoeyBG] Testing angle %03d deg: Accuracy = %.2f%%, Macro-F1 = %.2f%%.\n', ...
            Current_Angle,Current_Metrics.Accuracy,Current_Metrics.MacroF1);
    end

    Orientation_Table = table(Angle_List,Sample_Number_List,Accuracy_List,MacroF1_List, ...
        'VariableNames',{'Angle','SampleNumber','Accuracy','MacroF1'});

    Orientation_Results = struct();
    Orientation_Results.Orientation_Table = Orientation_Table;
    Orientation_Results.Metrics_By_Angle = Metrics_By_Angle;
    Orientation_Results.Minimum_Accuracy = min(Accuracy_List);
    Orientation_Results.Mean_Accuracy = mean(Accuracy_List);
    Orientation_Results.Target_Accuracy = Config.Evaluation.Target_Minimum_Orientation_Accuracy;
    Orientation_Results.Pass_Target = all(Accuracy_List >= Config.Evaluation.Target_Minimum_Orientation_Accuracy);

end
