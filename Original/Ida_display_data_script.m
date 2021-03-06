% just a loop to show each ROI in a new figure
for i=1:1:78
    

%% data that you want to plot; 1x78 vector, with data in the same order as the Gong atlas
data = NaN*ones(1,78);
data(i) = 1;

%% 
colourbar_threshold=[]; % can be used to adjust the colour range (experimental)
mesh_type = 'spm_canonical'; % assume that input contains 78 AAL ROIs
nr_views=6; % #views of the cortical surface in the figures
colour_range=[]; % for display: colour_range will be based on the data; alternatively, you can provide a maximum and minimum value


%% get AAL labels
[aalID, aalind,fullnames,everyID,allnames] = aal_get_numbers( 'Precentral_L' );
        tmplabels = char(allnames);
        cfg.allnames=tmplabels;
        
% Use only the most superfial areas
indices_in_same_order_as_in_Brainwave = select_ROIs_from_full_AAL(cfg);
labels = tmplabels(indices_in_same_order_as_in_Brainwave,:); %78 labels

%% plot
[colourbar_handle, patch_handles] = PaintBrodmannAreas_new2_clean(labels, data, length(data),length(data),nr_views, colour_range, colourbar_threshold, mesh_type);
set(gcf,'Tag','ShowBrainFigure');

display_label = deblank(labels(i,:));
display_label = strrep(display_label, '_', '\_');
title(sprintf('ROI %d: %s',i, display_label))
%%
end