%% Load mDOF Model Package
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.

%% Function Body
function Model_Package = LoadModelPackage(Model_Package_Path)

    if ~isfile(Model_Package_Path)
        error("Model package does not exist: %s", Model_Package_Path);
    end

    Loaded_Data = load(Model_Package_Path);
    if isfield(Loaded_Data,'Model_Package')
        Model_Package = Loaded_Data.Model_Package;
    else
        Model_Package = Loaded_Data;
    end

end
