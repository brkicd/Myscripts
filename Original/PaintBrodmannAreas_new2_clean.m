function [cbh, patch_handles]=PaintBrodmannAreas_new2(labels, data, nr_ROIs_to_plot, nr_colors_to_plot, nr_views, colour_range, colourbar_threshold, mesh_type);
% function [cbh, patch_handles]=PaintBrodmannAreas_new2(labels, data, nr_ROIs_to_plot, nr_colors_to_plot, nr_views, colour_range, colourbar_threshold, mesh_type);
%
% Plots data on cortical surface mesh from SPM (for AAL atlas).
% The data en labels should be in the same order (i.e. data(i) corresponds to labels{i})
%

% make all the areas grey
%braincolor = [0 0 0]; % black
braincolor = [0.6 0.6 0.6];% grey

lighting_type = 'phong'; % very shiny - metalic like
%lighting_type = 'gouraud'; % a bit shiny
%lighting_type = 'flat';

%lcolor=[219,112,147]/255; % pink light
lcolor='w'; % white light
%brain_material([.55,.6,.4,10]);
brain_material = 'dull';
%brain_material = 'shiny';

patch_handles = [];

if nargin<5
    nr_views=6;
end
if nr_views~=6
    error('Can only plot 6 views')
end
if nargin<6 | isempty(colour_range)
    colour_range = [min(data), max(data)]; % set the colour_range based on the provided data
    if colour_range(1)== colour_range(2)
        colour_range(1) = -1*colour_range(1); colour_range = sort(colour_range);
        disp(sprintf('setting colour_range to [%5.2f %5.2f]',colour_range))
    end
elseif length(colour_range)~=2
    error('Please provide a maximum and a minimum value for the colour range')
end
if nargin<7
    colourbar_threshold=[]; % for thresholding of the images
end
if nargin<8
    mesh_type = 'spm_canonical';
end


if ~strmatch(mesh_type,'spm_canonical')
    error('Onyl use mesh for AAL atlas!')
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load the mesh and the labels for the lh mesh
switch mesh_type
    case 'spm_canonical'
        if exist('/mnt/data/home/hillebra/mfiles/Elekta/cortex_20484.surf.gii_labelled_lh.mat','file')
            tmp = load('/mnt/data/home/hillebra/mfiles/Elekta/cortex_20484.surf.gii_labelled_lh.mat');
        else, % for compiled files
            try
                tmp = load('/usr/local/bin/cortex_20484.surf.gii_labelled_lh.mat');
            catch
                % for demanding Danish girl
                tmp=load('N:\Data_Analysis\matlab_scripts\cortex_20484.surf.gii_labelled_lh.mat');
            end
        end
        % remove 2 lines below for Helen:
        test = gifti(tmp.lhmesh); % had to do this in order to get compiled version working
        clear test
        
        tmp.positions = tmp.lhmesh.vertices;
        tmp.polygons = tmp.lhmesh.faces;
end
positions=tmp.positions;
polygons=tmp.polygons;
approximate_meshlabels=char(tmp.approximate_meshlabels);
clear tmp


colormap_index3_lh=[];
% make all the areas grey
% colormap_index3_lh(1:size(positions,1),:) = 0.*ones(size(positions,1),3);
colormap_index3_lh(1:size(positions,1),:) = repmat(braincolor, size(positions,1),1);


map=colormap(jet(nr_colors_to_plot));
%map=colormap(winter(nr_colors_to_plot));
%map=colormap(bone(nr_colors_to_plot));
%map=colormap(autumn(nr_colors_to_plot));
%my_autumn = flipud(colormap(autumn(nr_colors_to_plot)));
%map=colormap(my_autumn);
%%map=flipud(map);
colormap(map);


% main figure, left hemisphere
fh1=figure;
patches=patch('faces', polygons, 'vertices', positions);
set(patches, 'CDataMapping', 'direct' );
set(patches, 'FaceColor', 'interp');
%set(patches, 'FaceColor', 'flat');
%set(patches, 'EdgeColor', 'flat');
set(patches, 'EdgeColor', 'none');
set(patches, 'FaceLighting',lighting_type);
view(270,0); % lateral view
axis equal


[colormap_index3_lh] = local_colourin_ROIs(colormap_index3_lh, approximate_meshlabels, labels, data, nr_ROIs_to_plot, nr_colors_to_plot, nr_views, map, colour_range, braincolor, mesh_type);

% color the patches
set(patches, 'FaceVertexCData',colormap_index3_lh);


% change appearance
caxis(colour_range);
cbh=colorbar;
% AH, March 2013 -- repeat the colormap statement here in order to update the colorbar
colormap(map);

axis off;
set(cbh,'Visible','off');
%legh=legend(alllh, legend_labels_lh,'Location','BestOutside');
set(gcf,'Position', [0         165        1225         780]);

lh=camlight;
set(lh, 'Color', lcolor)
material(brain_material)


% Create a second view
patches2=patch('faces',polygons, 'vertices', positions);
set(patches2, 'CDataMapping', 'direct' );
set(patches2, 'FaceColor', 'interp');
%set(patches2, 'FaceColor', 'flat');
%set(patches2, 'EdgeColor', 'flat');
set(patches2, 'EdgeColor', 'none');
set(patches2, 'FaceVertexCData',colormap_index3_lh);
set(patches2, 'FaceLighting',lighting_type);
%set(patches2,'Vertices',[-1*positions(:,1), -1*positions(:,2)+190, positions(:,3)])
set(patches2,'Vertices',[-1*positions(:,1), -1*positions(:,2)-40, positions(:,3)-180])
material(brain_material)


% Create a 3rd view
patches3=patch('faces',polygons, 'vertices', positions);
set(patches3, 'CDataMapping', 'direct' );
set(patches3, 'FaceColor', 'interp');
%set(patches3, 'FaceColor', 'flat');
%set(patches3, 'EdgeColor', 'flat');
set(patches3, 'EdgeColor', 'none');
set(patches3, 'FaceVertexCData',colormap_index3_lh);
set(patches3, 'FaceLighting',lighting_type);
set(patches3,'Vertices',[-1*positions(:,3), -1*positions(:,1)-161, positions(:,2)-60])
material(brain_material)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the mesh and colours for the right hemisphere
% load the mesh and the labels for the mesh
switch mesh_type
    case 'spm_canonical'
        if exist('/mnt/data/home/hillebra/mfiles/Elekta/cortex_20484.surf.gii_labelled_rh.mat','file')
            tmp = load('/mnt/data/home/hillebra/mfiles/Elekta/cortex_20484.surf.gii_labelled_rh.mat');
        else,  % for compiled files
            try
                tmp = load('/usr/local/bin/cortex_20484.surf.gii_labelled_rh.mat');
            catch
                % for Ida
                tmp=load('N:\Data_Analysis\matlab_scripts\cortex_20484.surf.gii_labelled_rh.mat');
            end
        end
        % remove 2 lines below for Helen:
        test = gifti(tmp.rhmesh); % had to do this in order to get compiled version working
        clear test
        
        tmp.positions = tmp.rhmesh.vertices;
        tmp.polygons = tmp.rhmesh.faces;
end
positions_rh=tmp.positions;
polygons_rh=tmp.polygons;
approximate_meshlabels_rh=char(tmp.approximate_meshlabels);
clear tmp


colormap_index3_rh=[];
% make all the areas grey
%colormap_index3_rh(1:size(positions_rh,1),:) = 0.*ones(size(positions_rh,1),3);
colormap_index3_rh(1:size(positions_rh,1),:) = repmat(braincolor, size(positions_rh,1),1);

% find the colours for the patches
[colormap_index3_rh] = local_colourin_ROIs(colormap_index3_rh, approximate_meshlabels_rh, labels, data, nr_ROIs_to_plot, nr_colors_to_plot, nr_views, map, colour_range, braincolor, mesh_type);

% Create a 4rd view - the right hemisphere; top right
patches4=patch('faces',polygons_rh, 'vertices', positions_rh);
set(patches4, 'CDataMapping', 'direct');
set(patches4, 'FaceColor', 'interp');
%set(patches4, 'FaceColor', 'flat');
%set(patches4, 'EdgeColor', 'flat');
set(patches4, 'EdgeColor', 'none');
set(patches4, 'FaceVertexCData',colormap_index3_rh);
set(patches4, 'FaceLighting',lighting_type);
set(patches4,'Vertices',[-1*positions_rh(:,1), -1*positions_rh(:,2)-325, positions_rh(:,3)-2])
material(brain_material)


% Create a 5th view - the right hemisphere; bottom right
patches5=patch('faces',polygons_rh, 'vertices', positions_rh);
set(patches5, 'CDataMapping', 'direct');
set(patches5, 'FaceColor', 'interp');
%set(patches5, 'FaceColor', 'flat');
%set(patches5, 'EdgeColor', 'flat');
set(patches5, 'EdgeColor', 'none');
set(patches5, 'FaceVertexCData',colormap_index3_rh);
set(patches5, 'FaceLighting',lighting_type);
set(patches5,'Vertices',[positions_rh(:,1), positions_rh(:,2)-289, positions_rh(:,3)-181])
material(brain_material)


% Create a 6th view - the right hemisphere; right middle
patches6=patch('faces',polygons_rh, 'vertices', positions_rh);
set(patches6, 'CDataMapping', 'direct');
set(patches6, 'FaceColor', 'interp');
%set(patches6, 'FaceColor', 'flat');
%set(patches6, 'EdgeColor', 'flat');
set(patches6, 'EdgeColor', 'none');
set(patches6, 'FaceVertexCData',colormap_index3_rh);
set(patches6, 'FaceLighting',lighting_type);
set(patches6,'Vertices',[-1*positions_rh(:,3), -1*positions_rh(:,1)-164, positions_rh(:,2)-60])
material(brain_material)


patch_handles{1} = patches; patch_handles{2} = patches2; patch_handles{3} = patches3; patch_handles{4} = patches4; patch_handles{5} = patches5; patch_handles{6} = patches6;
set(cbh,'Visible','on', 'location', 'south');



if ~isempty(colourbar_threshold)
    colorindex1 = 1 + fix((colourbar_threshold(1)-colour_range(1))/(colour_range(2)-colour_range(1))*(nr_colors_to_plot-1));
    colorindex2 = 1 + fix((colourbar_threshold(2)-colour_range(1))/(colour_range(2)-colour_range(1))*(nr_colors_to_plot-1));
    map(colorindex1:colorindex2,:)=repmat([0 0 0],colorindex2-colorindex1+1,1);
    colormap(map)
end



% when exporting figures with print
%set(cbh,'Position', [0.2    0.3    0.3    0.01])
%when exporting figures with export_fig
set(cbh,'Position', [0.308  0.12 0.3    0.01])
%zoom(1.5)

% only this combination of commands prints a figure with black background
% and white fonts in the correct places
whitebg(gcf,'k')
set(gcf,'color','k')
colordef black
set(gcf,'InvertHardcopy','off')





function [colormap_index3] = local_colourin_ROIs(colormap_index3, approximate_meshlabels, labels, data, nr_ROIs_to_plot, nr_colors_to_plot, nr_views, map, colour_range, braincolor, mesh_type);
    
for j=1:nr_ROIs_to_plot
    searchlabel = deblank(char(labels(j,:)));
    colorindex = 1 + fix((data(j)-colour_range(1))/(colour_range(2)-colour_range(1))*(nr_colors_to_plot-1));
    if ~isnan(colorindex)
        surfacecolor = map(colorindex,:);
    else
        % color is invisible
        %surfacecolor = [0 0 0];
        surfacecolor = braincolor;
    end
    labelind = strmatch(searchlabel,approximate_meshlabels(:,1:length(searchlabel)), 'exact');
    if ~isempty(labelind), % color all relevant triangles
        for i=1:length(labelind)
            colormap_index3(labelind(i),:) = surfacecolor;
        end
    end
end


