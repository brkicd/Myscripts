 % new test version


function AAL_centroids_to_MEG_Aston(anatomicalfif);
%
% Converts the AAL centroids from MNI-space to subject-space 
%
%
% Arjan Hillebrand, 23 Sept 2015


if nargin < 1
    anatomicalfif=[];
end

% addpath /studies/201311-88/atlasBF/atlasbf_scripts/
% addpath /apps/spm8rev4667/toolbox/AAL/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%whi
%% Defaults
% needed for label_niftii
cfg.spmversion='spm8'
% this is the AAL atlas in MNI space
atlas_nii = fullfile('/mnt/coraid0/vol12/201311-88/atlasBF/atlasbf_scripts/ROI_MNI_V4.nii');
centroids_nii_out = strrep(atlas_nii, '/mnt/coraid0/vol12/201311-88/atlasBF/atlasbf_scripts/ROI_MNI_V4.nii', '/mnt/coraid0/vol12/201311-88/atlasBF/atlasbf_scripts/ROI_MNI_V4_centroids_MNI_2mm.nii');
%centroids_nii_out = (atlas_nii); (can use this to check the atlas normalisation)
line_in_jobsfile_that_needs_replacing = 47;
T1name = '/apps/spm8/templates/T1.nii';
default_jobfname = '/mnt/coraid0/vol12/201311-88/atlasBF/atlasbf_scripts/inv_norm_batch_job_V2b.m'; % make sure that the template file used in this file is accesible on the system



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get the name for the coregistered MRI
if isempty(anatomicalfif)
    [files,sts] = spm_select(1,'.*\.fif$','Please select co-registered mri for 1 subject',[],pwd,'.*',[]);
    cfg.nr_subjects = size(files,1);
    if cfg.nr_subjects ~= 1
        error('Expecting 1 subject!')
    end
    subject_nr = 1;
    cfg.subject{subject_nr}.anatomicalfif = deblank(files(subject_nr,:));
else
    cfg.nr_subjects = size(anatomicalfif,1);
    if cfg.nr_subjects ~= 1
        error('Expecting 1 subject!')
    end
    subject_nr = 1;
    cfg.subject{subject_nr}.anatomicalfif = deblank(anatomicalfif);
end



%% normalise the coregistered anatomical MRI and apply the transformation to the centroids nii
%
% First, create a jobfile that uses the centroids MRI we have just created
[junk, outfname] = fileparts(centroids_nii_out);
outpath = fileparts(cfg.subject{subject_nr}.anatomicalfif);
cfg.jobfname = fullfile(outpath, [outfname,'inv_norm_batch_job_niftii.m']); % make sure that the template file used in this file is accesible on the system

% read the default job
textstr = importdata(default_jobfname);

% replace the line that points to the file that needs to be transformed to subject space (i.e. the niftii with the centroid coordinates)
textstr{line_in_jobsfile_that_needs_replacing} = sprintf('matlabbatch{2}.spm.util.defs.fnames = {''%s,1''};',centroids_nii_out);

% save this as a new job file
fid=fopen(cfg.jobfname,'wt');
for linenr=1:size(textstr,1)
    fprintf(fid,'%s\n',char(textstr(linenr,:)));
end
fclose(fid);

% run the normalisation
label_niftii_Aston(cfg)

%return (only use this if checking the atlas normalisation without the
%centroids)

% check the result of the normalisation
files_to_check = strvcat(strrep(cfg.subject{subject_nr}.anatomicalfif,'.fif', '.nii'), centroids_nii_out);
spm_check_registration(files_to_check);
drawnow
fh = spm_figure('FindWin','Graphics');
outputfigfilename = strrep(deblank(cfg.subject{subject_nr}.anatomicalfif), '.fif', ['checked_normalisation', date,'.png']);
set(gcf,'pointer','watch')
export_fig(outputfigfilename,'-png')
set(gcf,'pointer','arrow')
spm_figure('Close',fh)

wh = warndlg(sprintf('IMPORTANT!!\nCheck that the normalisation succeeded\nLoad the coregistered MRI and the two *.pts files in mriview.\nThe points should fall in the correct regions!!'));
waitfor(wh)

%% read the transformed MRI with the centroids
coregistered_centroids_fname = fullfile(outpath, ['w',outfname,'.nii']);
Vroi_ncentroids = spm_vol(coregistered_centroids_fname);

transmm = Vroi_ncentroids.mat; % from vox_ind to meg in mm
[Yroi, XYZmm] = spm_read_vols(Vroi_ncentroids); % volume


%% centroid voxels have an AAL value to indicate the label
[aalID, aalind,fullnames,everyID,allnames] = aal_get_numbers( 'Precentral_L' );
labels = char(allnames);
gridcentroidxyz=NaN*ones(3, size(labels,1));
for i=1:size(labels,1)
    
    % get the centroid for a particular AAL region
    [aalID] = aal_get_numbers( deblank(labels(i,:)) );
    
    cind=find(Yroi==aalID);
    if isempty(cind)
        error('can not find a centroid for this ROI')
    end
    
    selected_vox = XYZmm(:,cind)';
    % could have more than one voxel associated with the centroid, as you
    % go from 2mm resolution to (potentially) MRI with higher resolution
    % check that all selected voxels are within 2 mm cube from each other (i.e. there is only 1 centroid)
    if size(selected_vox,2)~=3
        error('do transpose')
    end
    for j=1:size(selected_vox,1)
        for k=1:size(selected_vox,1)
            dist = sqrt(dot(selected_vox(j,:)-selected_vox(k,:),selected_vox(j,:)-selected_vox(k,:)));
            if dist> (sqrt(16+(2*sqrt(8))^2))
                selected_vox
                dist
                j
                k
                error('more then one centroid for one AAL area?')
            end
        end
    end
    
    % get mean MEG coordinate for this centroid
    gridcentroidxyz(:,i) = mean(selected_vox,1)';
    
end
gridcentroidxyz = gridcentroidxyz';


%% reorder the centroids according to Gong and seperate from the deeper structures
% % only use 78 ROIs, in the same order as in Brainwave
indices_in_same_order_as_in_Brainwave = select_ROIs_from_full_AAL();
new_labels_Gong = labels(indices_in_same_order_as_in_Brainwave,:); %78 labels
deep_indices = setdiff([1:size(labels,1)], indices_in_same_order_as_in_Brainwave)';
deep_labels = labels(deep_indices,:);
% all_labels = labels([indices_in_same_order_as_in_Brainwave;deep_indices],:);

%% Write these voxels to two seperate pts files
for VE_fnr=1:2
    switch VE_fnr
        % Determine outputfile and pts to write
        case 1
            centroidsvoxels_file = strrep(coregistered_centroids_fname,'.nii','_Gong.pts');
            indices = indices_in_same_order_as_in_Brainwave;
            reordered_gridcentroidxyz = gridcentroidxyz(indices,:);
        case 2
            centroidsvoxels_file = strrep(coregistered_centroids_fname,'.nii','_DeepAAL.pts');
            indices = deep_indices;
            reordered_gridcentroidxyz = gridcentroidxyz(indices,:);
    end
    
    if exist(centroidsvoxels_file, 'file')
        wh=warndlg(sprintf('Overwriting existing file:\n%s',centroidsvoxels_file))
        waitfor(wh)
    else
        disp(sprintf('Writing centroids to file:\n%s',centroidsvoxels_file))
    end
    
    fid=fopen(centroidsvoxels_file,'wt');
    if fid==-1,
        error(sprintf('Failed to open new centroidsvoxels_file %s',centroidsvoxels_file));
    end;
    for i=1:length(indices),
        fprintf(fid,'%3.6f\t%3.6f\t%3.6f\n',reordered_gridcentroidxyz(i,1),reordered_gridcentroidxyz(i,2),reordered_gridcentroidxyz(i,3));
    end; % for i
    fclose(fid);
end


