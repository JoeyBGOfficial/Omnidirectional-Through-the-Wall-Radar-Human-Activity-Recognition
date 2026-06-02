%% Visualization Style for JoeyBG mDOF Open Source Code
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.

%% Function Body
function Style = JoeyBG_Visualization_Style(Config)

    Base_Map = Config.Visualization.JoeyBG_Colormap;
    Base_Map_Flip = Config.Visualization.JoeyBG_Colormap_Flip;
    Query_Point = linspace(0,1,256);
    Source_Point = linspace(0,1,size(Base_Map,1));

    Style = struct();
    Style.Font_Name = Config.Visualization.Font_Name;
    Style.Font_Size_Basis = Config.Visualization.Font_Size_Basis;
    Style.Font_Size_Axis = Config.Visualization.Font_Size_Axis;
    Style.Font_Size_Title = Config.Visualization.Font_Size_Title;
    Style.Font_Weight_Basis = Config.Visualization.Font_Weight_Basis;
    Style.Font_Weight_Axis = Config.Visualization.Font_Weight_Axis;
    Style.Font_Weight_Title = Config.Visualization.Font_Weight_Title;
    Style.LineWidth = 1.5;
    Style.Curve_Colormap = interp1(Source_Point,Base_Map,Query_Point);
    Style.Image_Colormap = interp1(Source_Point,Base_Map_Flip,Query_Point);

end
