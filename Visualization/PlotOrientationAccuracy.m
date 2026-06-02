%% Plot Orientation Accuracy
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.

%% Function Body
function Figure_Handle = PlotOrientationAccuracy(Orientation_Results, Config, Output_Name)

    if nargin < 3 || isempty(Output_Name)
        Output_Name = 'Orientation_Accuracy.png';
    end

    Style = JoeyBG_Visualization_Style(Config);
    Orientation_Table = Orientation_Results.Orientation_Table;

    Figure_Handle = figure('Name','Omnidirectional Testing Accuracy','Color','w', ...
        'Visible',Config.Visualization.Figure_Visible,'Position',[160 160 980 520]);
    bar(Orientation_Table.Angle,Orientation_Table.Accuracy,0.70,'FaceColor',Style.Curve_Colormap(48,:));
    hold on;
    yline(Config.Evaluation.Target_Minimum_Orientation_Accuracy,'--', ...
        sprintf('Target %.0f%%',Config.Evaluation.Target_Minimum_Orientation_Accuracy), ...
        'LineWidth',1.5,'Color',[0.25 0.25 0.25]);
    hold off;
    grid on;
    ylim([0 100]);
    xticks(Orientation_Table.Angle);
    xlabel('Testing Orientation (deg)','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Axis,'FontWeight',Style.Font_Weight_Axis);
    ylabel('Accuracy (%)','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Axis,'FontWeight',Style.Font_Weight_Axis);
    title(sprintf('Cross-Orientation Testing Accuracy (Mean = %.2f%%, Min = %.2f%%)', ...
        Orientation_Results.Mean_Accuracy,Orientation_Results.Minimum_Accuracy), ...
        'FontName',Style.Font_Name,'FontSize',Style.Font_Size_Title,'FontWeight',Style.Font_Weight_Title);
    set(gca,'FontName',Style.Font_Name,'FontSize',Style.Font_Size_Basis,'FontWeight',Style.Font_Weight_Basis);

    if Config.Visualization.Save_Figures
        ensureFolder(Config.Output.Result_Folder);
        exportgraphics(Figure_Handle,fullfile(Config.Output.Result_Folder,Output_Name),'Resolution',300);
    end

end

%% Local Functions
function ensureFolder(Folder_Name)

    if ~isfolder(Folder_Name)
        mkdir(Folder_Name);
    end

end
