%% Build Dataset Index for Omnidirectional TWR HAR
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function reads the local RWSet or SimHSet folder structure and builds
% table-form indexes for the 0-degree training/validation samples and the
% 30~330-degree omnidirectional testing samples.

%% Function Body
function Dataset_Index = BuildDatasetIndex(Config)

    [Dataset_Root, Training_Folder, Testing_Folder, Dataset_Full_Name] = getDatasetFolders(Config);

    if ~isfolder(Dataset_Root)
        error("Dataset folder does not exist: %s", Dataset_Root);
    end
    if ~isfolder(Training_Folder)
        error("Training and validation folder does not exist: %s", Training_Folder);
    end
    if ~isfolder(Testing_Folder)
        error("Testing folder does not exist: %s", Testing_Folder);
    end

    Class_Dirs = listVisibleDirectories(Training_Folder);
    Class_Names = string({Class_Dirs.name})';
    Number_of_Classes = numel(Class_Names);

    TrainingValidationTable = table();
    for Class_Index = 1:Number_of_Classes
        Current_Class = Class_Names(Class_Index);
        Current_Folder = fullfile(Training_Folder,Current_Class);
        Current_Files = sortImageFilesByNumericName(dir(fullfile(Current_Folder,'*.png')));
        Current_Table = buildSampleTable(Current_Files, Current_Folder, Current_Class, Class_Index, ...
            0, "TrainingValidation", Config.Dataset_Name, Class_Names);
        TrainingValidationTable = [TrainingValidationTable; Current_Table]; %#ok<AGROW>
    end

    Angle_Dirs = listVisibleDirectories(Testing_Folder);
    Angle_Numbers = str2double(string({Angle_Dirs.name}));
    [~,Angle_Order] = sort(Angle_Numbers);
    Angle_Dirs = Angle_Dirs(Angle_Order);

    TestingTable = table();
    for Angle_Index = 1:numel(Angle_Dirs)
        Current_Angle = str2double(Angle_Dirs(Angle_Index).name);
        Angle_Folder = fullfile(Testing_Folder,Angle_Dirs(Angle_Index).name);
        for Class_Index = 1:Number_of_Classes
            Current_Class = Class_Names(Class_Index);
            Current_Folder = fullfile(Angle_Folder,Current_Class);
            Current_Files = sortImageFilesByNumericName(dir(fullfile(Current_Folder,'*.png')));
            Current_Table = buildSampleTable(Current_Files, Current_Folder, Current_Class, Class_Index, ...
                Current_Angle, "Testing", Config.Dataset_Name, Class_Names);
            TestingTable = [TestingTable; Current_Table]; %#ok<AGROW>
        end
    end

    Dataset_Index = struct();
    Dataset_Index.Dataset_Root = Dataset_Root;
    Dataset_Index.Dataset_Full_Name = Dataset_Full_Name;
    Dataset_Index.Training_Folder = Training_Folder;
    Dataset_Index.Testing_Folder = Testing_Folder;
    Dataset_Index.Class_Names = Class_Names;
    Dataset_Index.TrainingValidationTable = TrainingValidationTable;
    Dataset_Index.TestingTable = TestingTable;

end

%% Local Functions
function [Dataset_Root, Training_Folder, Testing_Folder, Dataset_Full_Name] = getDatasetFolders(Config)

    if strcmpi(Config.Dataset_Name,"RWSet") || strcmpi(Config.Dataset_Name,"Multi-View_RWSet")
        Dataset_Full_Name = "Multi-View_RWSet";
        Training_Name = "Multi-View_RW_Training_and_Validation_Set";
        Testing_Name = "Multi-View_RW_Testing_Set";
    elseif strcmpi(Config.Dataset_Name,"SimHSet") || strcmpi(Config.Dataset_Name,"Multi-View_SimHSet")
        Dataset_Full_Name = "Multi-View_SimHSet";
        Training_Name = "Multi-View_SimH_Training_and_Validation_Set";
        Testing_Name = "Multi-View_SimH_Testing_Set";
    else
        error("Unsupported dataset name: %s", Config.Dataset_Name);
    end

    Dataset_Root = fullfile(Config.Project_Path,Dataset_Full_Name);
    Training_Folder = fullfile(Dataset_Root,Training_Name);
    Testing_Folder = fullfile(Dataset_Root,Testing_Name);

end

function Directory_List = listVisibleDirectories(Folder_Name)

    Directory_List = dir(Folder_Name);
    Directory_List = Directory_List([Directory_List.isdir]);
    Directory_List = Directory_List(~ismember({Directory_List.name},{'.','..'}));
    Directory_List = Directory_List(~startsWith(string({Directory_List.name}),'.'));
    [~,Order] = sort(lower(string({Directory_List.name})));
    Directory_List = Directory_List(Order);

end

function Sorted_Files = sortImageFilesByNumericName(File_List)

    if isempty(File_List)
        Sorted_Files = File_List;
        return;
    end

    Number_List = nan(numel(File_List),1);
    Name_List = strings(numel(File_List),1);
    for i = 1:numel(File_List)
        [~,Current_Name,~] = fileparts(File_List(i).name);
        Name_List(i) = string(Current_Name);
        Number_List(i) = str2double(Current_Name);
    end

    if all(~isnan(Number_List))
        [~,Order] = sort(Number_List);
    else
        [~,Order] = sort(Name_List);
    end
    Sorted_Files = File_List(Order);

end

function Sample_Table = buildSampleTable(File_List, Folder_Name, Class_Name, Class_Index, Angle, Subset_Name, Dataset_Name, Class_Names)

    Number_of_Files = numel(File_List);
    File_Path = strings(Number_of_Files,1);
    Sample_Index = zeros(Number_of_Files,1);
    Class_Name_Vector = repmat(string(Class_Name),Number_of_Files,1);
    Class_Index_Vector = repmat(Class_Index,Number_of_Files,1);
    Angle_Vector = repmat(Angle,Number_of_Files,1);
    Subset_Vector = repmat(string(Subset_Name),Number_of_Files,1);
    Dataset_Vector = repmat(string(Dataset_Name),Number_of_Files,1);

    for i = 1:Number_of_Files
        File_Path(i) = string(fullfile(Folder_Name,File_List(i).name));
        [~,Current_Name,~] = fileparts(File_List(i).name);
        Current_Index = str2double(Current_Name);
        if isnan(Current_Index)
            Current_Index = i;
        end
        Sample_Index(i) = Current_Index;
    end

    Label = categorical(Class_Name_Vector,Class_Names);
    Sample_Table = table(File_Path,Label,Class_Name_Vector,Class_Index_Vector,Sample_Index, ...
        Angle_Vector,Subset_Vector,Dataset_Vector, ...
        'VariableNames',{'FilePath','Label','ClassName','ClassIndex','SampleIndex','Angle','Subset','DatasetName'});

end
