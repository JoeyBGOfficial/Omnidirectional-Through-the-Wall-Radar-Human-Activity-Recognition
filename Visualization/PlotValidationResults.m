%% Plot Validation Recognition Results
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.

%% Function Body
function Figure_Handle = PlotValidationResults(Validation_Metrics, Config, Output_Name)

    if nargin < 3 || isempty(Output_Name)
        Output_Name = 'Validation_Results.png';
    end

    Style = JoeyBG_Visualization_Style(Config);
    Figure_Handle = figure('Name','Validation Recognition Results','Color','w', ...
        'Visible',Config.Visualization.Figure_Visible,'Position',[120 120 1200 520]);
    tiledlayout(1,2,'Padding','compact','TileSpacing','compact');

    nexttile;
    Confusion_Chart = confusionchart(Validation_Metrics.True_Labels,Validation_Metrics.Predicted_Labels, ...
        'RowSummary','row-normalized','ColumnSummary','column-normalized');
    Confusion_Chart.Title = sprintf('Validation Confusion Matrix (Acc = %.2f%%)',Validation_Metrics.Accuracy);
    Confusion_Chart.FontName = Style.Font_Name;
    Confusion_Chart.FontSize = Style.Font_Size_Basis;

    nexttile;
    bar(Validation_Metrics.Class_Accuracy,'FaceColor','flat');
    colormap(gca,Style.Curve_Colormap);
    ylim([0 100]);
    grid on;
    xticks(1:numel(Validation_Metrics.Class_Names));
    xticklabels(Validation_Metrics.Class_Names);
    xtickangle(35);
    ylabel('Accuracy (%)','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Axis,'FontWeight',Style.Font_Weight_Axis);
    title('Per-Class Validation Accuracy','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Title,'FontWeight',Style.Font_Weight_Title);
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
