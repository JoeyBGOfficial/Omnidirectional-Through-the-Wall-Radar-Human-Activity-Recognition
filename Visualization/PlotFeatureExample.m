%% Plot mDOF Feature Example
% Former Author: JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-02;
% Language & Platform: MATLAB R2025b.

%% Function Body
function Figure_Handle = PlotFeatureExample(Sample_Row, Config)

    Style = JoeyBG_Visualization_Style(Config);

    if ismember('FeaturePath',Sample_Row.Properties.VariableNames) && isfile(Sample_Row.FeaturePath)
        Loaded_Data = load(Sample_Row.FeaturePath,'Feature_Image','Feature_Sequence','Feature_Vector');
        Feature_Image = Loaded_Data.Feature_Image;
        Feature_Sequence = Loaded_Data.Feature_Sequence;
        Feature_Vector = Loaded_Data.Feature_Vector;
        [DTM_Amplitude,~] = ReadAndPreprocessDTM(char(Sample_Row.FilePath),Config);
    else
        Feature_Record = ExtractmDOFFeature(char(Sample_Row.FilePath),Config);
        Feature_Image = Feature_Record.Feature_Image;
        Feature_Sequence = Feature_Record.Feature_Sequence;
        Feature_Vector = Feature_Record.Feature_Vector;
        DTM_Amplitude = Feature_Record.DTM_Amplitude;
    end

    Figure_Handle = figure('Name','mDOF Feature Example','Color','w', ...
        'Visible',Config.Visualization.Figure_Visible,'Position',[100 100 1100 760]);
    tiledlayout(2,2,'Padding','compact','TileSpacing','compact');

    nexttile;
    imagesc(flipud(DTM_Amplitude));
    axis image;
    set(gca,'YDir','normal');
    colormap(gca,Style.Image_Colormap);
    colorbar;
    xlabel('Time (s)','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Axis,'FontWeight',Style.Font_Weight_Axis);
    ylabel('Doppler (Hz)','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Axis,'FontWeight',Style.Font_Weight_Axis);
    title('Preprocessed DTM','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Title,'FontWeight',Style.Font_Weight_Title);
    applyAxisStyle(gca,Style,Config.Feature.Slow_Time_Length_of_DTM,Config.Feature.Max_Frequency_of_DTM);

    nexttile;
    imagesc(Feature_Image(:,:,1));
    axis image;
    set(gca,'YDir','normal');
    colormap(gca,Style.Image_Colormap);
    colorbar;
    xlabel('Slow-Time Index','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Axis,'FontWeight',Style.Font_Weight_Axis);
    ylabel('Doppler Index','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Axis,'FontWeight',Style.Font_Weight_Axis);
    title('Reduced Horizontal mDOF','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Title,'FontWeight',Style.Font_Weight_Title);
    set(gca,'FontName',Style.Font_Name,'FontSize',Style.Font_Size_Basis,'FontWeight',Style.Font_Weight_Basis);

    nexttile;
    imagesc(Feature_Sequence);
    axis tight;
    set(gca,'YDir','normal');
    colormap(gca,Style.Image_Colormap);
    colorbar;
    xlabel('Slow-Time Index','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Axis,'FontWeight',Style.Font_Weight_Axis);
    ylabel('Doppler Bin','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Axis,'FontWeight',Style.Font_Weight_Axis);
    title('mDOF Sequence Matrix','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Title,'FontWeight',Style.Font_Weight_Title);
    set(gca,'FontName',Style.Font_Name,'FontSize',Style.Font_Size_Basis,'FontWeight',Style.Font_Weight_Basis);

    nexttile;
    plot(Feature_Vector,'LineWidth',Style.LineWidth,'Color',Style.Curve_Colormap(32,:));
    grid on;
    xlabel('Normalized Time Index','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Axis,'FontWeight',Style.Font_Weight_Axis);
    ylabel('Mean mDOF Amp','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Axis,'FontWeight',Style.Font_Weight_Axis);
    title('Reduced mDOF Time Series','FontName',Style.Font_Name,'FontSize',Style.Font_Size_Title,'FontWeight',Style.Font_Weight_Title);
    set(gca,'FontName',Style.Font_Name,'FontSize',Style.Font_Size_Basis,'FontWeight',Style.Font_Weight_Basis);

    if Config.Visualization.Save_Figures
        ensureFolder(Config.Output.Result_Folder);
        exportgraphics(Figure_Handle,fullfile(Config.Output.Result_Folder,'Feature_Example.png'),'Resolution',300);
    end

end

%% Local Functions
function applyAxisStyle(Axis_Handle, Style, Slow_Time_Length, Max_Frequency)

    Image_Size = Axis_Handle.XLim(2);
    xticks(linspace(1,Image_Size,5));
    xticklabels({'0',num2str(Slow_Time_Length/4),num2str(Slow_Time_Length/2), ...
        num2str(3*Slow_Time_Length/4),num2str(Slow_Time_Length)});
    yticks(linspace(1,Image_Size,5));
    yticklabels({num2str(-Max_Frequency),num2str(-Max_Frequency/2),'0', ...
        num2str(Max_Frequency/2),num2str(Max_Frequency)});
    set(Axis_Handle,'FontName',Style.Font_Name,'FontSize',Style.Font_Size_Basis, ...
        'FontWeight',Style.Font_Weight_Basis);

end

function ensureFolder(Folder_Name)

    if ~isfolder(Folder_Name)
        mkdir(Folder_Name);
    end

end
