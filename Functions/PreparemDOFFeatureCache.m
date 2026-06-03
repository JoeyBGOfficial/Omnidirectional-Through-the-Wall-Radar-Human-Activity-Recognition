%% Prepare mDOF Feature Cache
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function extracts and stores the mDOF feature files corresponding to
% a dataset index table. Existing feature files are reused by default.

%% Function Body
function Data_Table = PreparemDOFFeatureCache(Data_Table, Config, Force_Recompute)

    if nargin < 3 || isempty(Force_Recompute)
        Force_Recompute = Config.Feature.Force_Recompute_Features;
    end

    if height(Data_Table) == 0
        Data_Table.FeaturePath = strings(0,1);
        return;
    end

    if ~isfolder(Config.Output.Feature_Folder)
        mkdir(Config.Output.Feature_Folder);
    end

    Feature_Path_List = strings(height(Data_Table),1);
    for Sample_Index = 1:height(Data_Table)
        Feature_Path = buildFeaturePath(Data_Table(Sample_Index,:), Config);
        Feature_Path_List(Sample_Index) = string(Feature_Path);

        if Force_Recompute || ~isfile(Feature_Path)
            Feature_Folder = fileparts(Feature_Path);
            if ~isfolder(Feature_Folder)
                mkdir(Feature_Folder);
            end

            fprintf('Extracting mDOF feature %d/%d: %s\n', ...
                Sample_Index, height(Data_Table), char(Data_Table.FilePath(Sample_Index)));

            Feature_Record = ExtractmDOFFeature(char(Data_Table.FilePath(Sample_Index)), Config);
            Feature_Image = Feature_Record.Feature_Image;
            Feature_Sequence = Feature_Record.Feature_Sequence;
            Feature_Vector = Feature_Record.Feature_Vector;
            Reduced_Flow_U = Feature_Record.Reduced_Flow_U;
            Feature_Metadata = struct();
            Feature_Metadata.Source_Path = Data_Table.FilePath(Sample_Index);
            Feature_Metadata.ClassName = Data_Table.ClassName(Sample_Index);
            Feature_Metadata.ClassIndex = Data_Table.ClassIndex(Sample_Index);
            Feature_Metadata.Angle = Data_Table.Angle(Sample_Index);
            Feature_Metadata.DatasetName = Data_Table.DatasetName(Sample_Index);
            Feature_Metadata.Feature_Size = Config.Feature.Output_Size;
            Feature_Metadata.Flow_Estimation_Size = Config.Feature.Flow_Estimation_Size;
            save(Feature_Path,'Feature_Image','Feature_Sequence','Feature_Vector', ...
                'Reduced_Flow_U','Feature_Metadata','-v7.3');
        else
            if Sample_Index == 1 || mod(Sample_Index,100) == 0 || Sample_Index == height(Data_Table)
                fprintf('Reusing mDOF feature cache %d/%d.\n', Sample_Index, height(Data_Table));
            end
        end
    end

    Data_Table.FeaturePath = Feature_Path_List;

end

%% Local Functions
function Feature_Path = buildFeaturePath(Sample_Row, Config)

    Dataset_Name = char(Sample_Row.DatasetName);
    Subset_Name = char(Sample_Row.Subset);
    Class_Name = char(Sample_Row.ClassName);
    Sample_Index = Sample_Row.SampleIndex;
    Angle = Sample_Row.Angle;

    if strcmpi(Subset_Name,'Testing')
        Angle_Folder = sprintf('Angle_%03d',Angle);
    else
        Angle_Folder = 'Angle_000';
    end

    Feature_Name = sprintf('%04d_mDOF.mat',Sample_Index);
    Feature_Path = fullfile(Config.Output.Feature_Folder,Dataset_Name,Subset_Name, ...
        Angle_Folder,Class_Name,Feature_Name);

end
