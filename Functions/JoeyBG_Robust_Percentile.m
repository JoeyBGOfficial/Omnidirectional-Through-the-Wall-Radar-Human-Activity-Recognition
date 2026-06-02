%% Robust Percentile Without Extra Toolbox Dependency
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.

%% Function Body
function Value = JoeyBG_Robust_Percentile(Data, Percentile)

    Data = double(Data(:));
    Data = Data(isfinite(Data));
    if isempty(Data)
        Value = 0;
        return;
    end

    Data = sort(Data);
    Percentile = max(0,min(100,Percentile));
    Position = 1 + (numel(Data)-1)*Percentile/100;
    Lower_Index = floor(Position);
    Upper_Index = ceil(Position);

    if Lower_Index == Upper_Index
        Value = Data(Lower_Index);
    else
        Weight = Position - Lower_Index;
        Value = (1-Weight)*Data(Lower_Index) + Weight*Data(Upper_Index);
    end

end
