%% Plot Inference Result for a New DTM
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.

%% Function Body
function Figure_Handle = PlotInferenceResult(Prediction_Result, Config, Output_Name)

    if nargin < 3 || isempty(Output_Name)
        Output_Name = 'Inference_Result.png';
    end

    Style = JoeyBG_Visualization_Style(Config);
    Feature_Record = Prediction_Result.Feature_Record;

    Figure_Handle = figure('Name','mDOF Inference Result','Color','w', ...
        'Visible',Config.Visualization.Figure_Visible,'Position',[180 180 1280 460]);
    tiledlayout(1,3,'Padding','compact','TileSpacing','compact');

    nexttile;
    imagesc(flipud(Feature_Record.DTM_Amplitude));
    axis image;
    set(gca,'YDir','normal');
    colormap(gca,Style.Image_Colormap);
    colorbar;
    xlabel('Time (s)','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Axis,'FontWeight',Style.Font_Weight_Axis);
    ylabel('Doppler (Hz)','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Axis,'FontWeight',Style.Font_Weight_Axis);
    title('Input DTM','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Title,'FontWeight',Style.Font_Weight_Title);
    set(gca,'FontName',Style.Font_Name,'FontSize',Style.Font_Size_Basis,'FontWeight',Style.Font_Weight_Basis);

    nexttile;
    imagesc(Feature_Record.Feature_Image(:,:,1));
    axis image;
    set(gca,'YDir','normal');
    colormap(gca,Style.Image_Colormap);
    colorbar;
    xlabel('Slow-Time Index','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Axis,'FontWeight',Style.Font_Weight_Axis);
    ylabel('Doppler Bin','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Axis,'FontWeight',Style.Font_Weight_Axis);
    title('mDOF Feature','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Title,'FontWeight',Style.Font_Weight_Title);
    set(gca,'FontName',Style.Font_Name,'FontSize',Style.Font_Size_Basis,'FontWeight',Style.Font_Weight_Basis);

    nexttile;
    barh(categorical(Prediction_Result.TopK_Labels),100*Prediction_Result.TopK_Scores, ...
        'FaceColor',Style.Curve_Colormap(48,:));
    xlim([0 100]);
    grid on;
    xlabel('Confidence (%)','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Axis,'FontWeight',Style.Font_Weight_Axis);
    title(sprintf('Prediction: %s',Prediction_Result.Predicted_Label), ...
        'FontName',Style.Font_Name,'FontSize',Style.Font_Size_Title,'FontWeight',Style.Font_Weight_Title);
    set(gca,'FontName',Style.Font_Name,'FontSize',Style.Font_Size_Basis,'FontWeight',Style.Font_Weight_Basis);

    if Config.Visualization.Save_Figures
        ensureFolder(Config.Output.Inference_Folder);
        exportgraphics(Figure_Handle,fullfile(Config.Output.Inference_Folder,Output_Name),'Resolution',300);
    end

end

%% Local Functions
function ensureFolder(Folder_Name)

    if ~isfolder(Folder_Name)
        mkdir(Folder_Name);
    end

end
