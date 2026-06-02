%% Build mDOF Datastores
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function builds MATLAB datastores for the two-input mDOF network.
% The first input is the mDOF feature image, and the second input is the
% Doppler-bin-by-time sequence matrix.

%% Function Body
function varargout = BuildmDOFDatastores(Training_Table, Validation_Table, Config, Mode)

    if nargin < 4 || isempty(Mode)
        Mode = "training";
    end

    if strcmpi(Mode,"prediction")
        varargout{1} = buildOneDatastore(Training_Table,false);
        return;
    end

    Training_Datastore = buildOneDatastore(Training_Table,true);
    if nargin >= 2 && ~isempty(Validation_Table) && height(Validation_Table) > 0
        Validation_Datastore = buildOneDatastore(Validation_Table,true);
    else
        Validation_Datastore = [];
    end

    varargout{1} = Training_Datastore;
    if nargout > 1
        varargout{2} = Validation_Datastore;
    end
    if nargout > 2
        varargout{3} = Config;
    end

end

%% Local Functions
function Current_Datastore = buildOneDatastore(Data_Table, Include_Label)

    if ~ismember('FeaturePath',Data_Table.Properties.VariableNames)
        error('The input table must contain FeaturePath. Run PreparemDOFFeatureCache first.');
    end

    Feature_Paths = cellstr(Data_Table.FeaturePath);
    Image_Datastore = fileDatastore(Feature_Paths,'ReadFcn',@readFeatureImage,'FileExtensions','.mat');
    Sequence_Datastore = fileDatastore(Feature_Paths,'ReadFcn',@readFeatureSequence,'FileExtensions','.mat');

    if Include_Label
        Label_Datastore = arrayDatastore(Data_Table.Label);
        Current_Datastore = combine(Image_Datastore,Sequence_Datastore,Label_Datastore);
    else
        Current_Datastore = combine(Image_Datastore,Sequence_Datastore);
    end

end

function Feature_Image = readFeatureImage(Feature_Path)

    Loaded_Data = load(Feature_Path,'Feature_Image');
    Feature_Image = single(Loaded_Data.Feature_Image);

end

function Feature_Sequence = readFeatureSequence(Feature_Path)

    Loaded_Data = load(Feature_Path,'Feature_Sequence');
    Feature_Sequence = single(Loaded_Data.Feature_Sequence);

end
