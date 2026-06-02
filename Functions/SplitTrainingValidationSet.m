%% Split Training and Validation Set
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function splits the 0-degree training and validation set into an
% 8:2 class-balanced training/validation partition with a fixed random seed.

%% Function Body
function [Training_Table, Validation_Table] = SplitTrainingValidationSet(TrainingValidationTable, Config)

    rng(Config.Random_Seed,'twister');
    Class_Names = categories(TrainingValidationTable.Label);

    Training_Rows = [];
    Validation_Rows = [];

    for i = 1:numel(Class_Names)
        Current_Rows = find(TrainingValidationTable.Label == categorical(string(Class_Names{i}),Class_Names));
        Current_Rows = Current_Rows(:);
        Current_Rows = Current_Rows(randperm(numel(Current_Rows)));

        Number_of_Training = floor(Config.Training_Validation_Ratio*numel(Current_Rows));
        Training_Rows = [Training_Rows; Current_Rows(1:Number_of_Training)]; %#ok<AGROW>
        Validation_Rows = [Validation_Rows; Current_Rows(Number_of_Training+1:end)]; %#ok<AGROW>
    end

    Training_Table = sortrows(TrainingValidationTable(Training_Rows,:),{'ClassIndex','SampleIndex'});
    Validation_Table = sortrows(TrainingValidationTable(Validation_Rows,:),{'ClassIndex','SampleIndex'});

    Training_Table.Partition = repmat("Training",height(Training_Table),1);
    Validation_Table.Partition = repmat("Validation",height(Validation_Table),1);

end
