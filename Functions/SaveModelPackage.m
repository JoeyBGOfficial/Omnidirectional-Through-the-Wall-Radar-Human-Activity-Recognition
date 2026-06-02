%% Save mDOF Model Package
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.

%% Function Body
function Model_Package_Path = SaveModelPackage(Net, Train_Info, Config, Class_Names, Validation_Metrics, Orientation_Results)

    if ~isfolder(Config.Output.Model_Folder)
        mkdir(Config.Output.Model_Folder);
    end

    Model_Package = struct();
    Model_Package.Net = Net;
    Model_Package.Train_Info = Train_Info;
    Model_Package.Config = Config;
    Model_Package.Class_Names = string(Class_Names(:));
    Model_Package.Validation_Metrics = Validation_Metrics;
    Model_Package.Orientation_Results = Orientation_Results;
    Model_Package.Created_By = "JoeyBG";
    Model_Package.Created_Time = string(datetime("now"));

    Model_Package_Path = fullfile(Config.Output.Model_Folder,char(Config.Output.Model_File_Name));
    save(Model_Package_Path,'Model_Package','-v7.3');
    fprintf('[JoeyBG] Model package saved to: %s\n', Model_Package_Path);

end
