%%   PREPROCESSING- SENSOR LEVEL DATA %%
% - preprocessing
% visualization
% artefact rejection
% ALWAYS RUN ft_defaults before you start

% set your current directory

cd '/mnt/scratch28/Diandra/0155';

% specify location of the data file

rawfile= '/mnt/scratch28/Diandra/0155/170428/CA_supermario_tsss.fif';
subject='155';           %number or name of the subject
% create log file
diary(sprintf('log %s.out',subject));
c = datestr(clock); %time and date
disp(sprintf('Running preprocessing script for subject %s',subject))
disp(c)
%% Epoching & Filtering
% Epoch the whole dataset into one continous dataset and apply
% the appropriate filters

cfg = [];
cfg.coilaccuracy = 2;
cfg.headerfile = rawfile; 
cfg.datafile = rawfile;
cfg.channel = 'MEG';
cfg.trialdef.triallength = Inf;
cfg.trialdef.ntrials = 1;
cfg = ft_definetrial(cfg);



cfg.continuous = 'yes';
cfg.bpfilter = 'yes';
cfg.bpfreq = [0.5 250];
cfg.channel = 'MEG';
cfg.dftfilter = 'yes';
cfg.dftfreq = [50];
alldata = ft_preprocessing(cfg);

% deal with the 50Hz line noise
cfg = [];
cfg.bsfilter = 'yes';
cfg.bsfreq = [49.5 50.5];
alldata = ft_preprocessing(cfg,alldata);

% deal with the 100Hz line noise
cfg = [];
cfg.bsfilter = 'yes';
cfg.bsfreq = [99.5 100.5];
alldata = ft_preprocessing(cfg,alldata);


%always do a quality check
%quality check
%ft quality check 
% cfg         = []
% cfg.dataset = rawfile;
% ft_qualitycheck(cfg)



%% Epoching based on a specific triggers

% Epoch your filtered data based on a specific trigger
cfg = [];
cfg.headerfile = rawfile; 
cfg.datafile = rawfile;
cfg.channel = 'MEG';
cfg.trialdef.eventtype  = 'Trigger';      % S2=[4,8]; SuperMario=[16,32]
cfg.trialdef.eventvalue = [4 8]; %16 32]; % read all conditions at once
cfg.trialdef.prestim    = 1.5;            % in seconds remember the longer the better
cfg.trialdef.poststim   = 1.5; 
%cfg.trialdef.prestim = 2.0;             % pre-stimulus interval
%cfg.trialdef.poststim = 2.0;            % post-stimulus interval
cfg = ft_definetrial(cfg);

data = ft_redefinetrial(cfg,alldata); %redefines the filtered data

% if you don't know your triggers you can define your data segments of
% interest

% This reads your events in case you don't know your triggers cfg.trialdef.eventvalue = [4 8 16 32]; 

hdr   = ft_read_header(rawfile);
event = ft_read_event(rawfile);

sample = [event.sample];
value  = [event.value];

figure
plot(sample/hdr.Fs, value, '.');
xlabel('time (s)')
rawfile

unique([event.value])

find(strcmp('Trigger', {event.type}))

triggers=[event(find(strcmp('Trigger', {event.type}))).value] %list of all the triggers in sequence
%% Detrend and demean each trial
cfg = [];
cfg.demean = 'yes';
cfg.detrend = 'yes';
data = ft_preprocessing(cfg,data);


save data


%% Reject Trials
% Display visual trial summary to reject deviant trials.
% You need to load the mag + grad separately due to different scales

cfg = []; 
cfg.method = 'summary'; 
cfg.keepchannel = 'yes'; 
cfg.channel = 'MEGMAG'; 
clean1 = ft_rejectvisual(cfg, data); 
% Now load this
cfg.channel = 'MEGGRAD';
clean2 = ft_rejectvisual(cfg, clean1);
data = clean2; clear clean1 clean2
close all

%% Display Data
% Displaying the (raw) preprocessed MEG data - data browser

diary off
cfg = [];
cfg.channel = 'MEGGRAD';
cfg.viewmode = 'vertical';   %or butterfly
ft_databrowser(cfg,data)
cfg.channel = 'MEGMAG';
ft_databrowser(cfg,data)

% Load the summary again so you can manually remove any deviant trials
cfg = []; 
cfg.method = 'summary'; 
cfg.keepchannel = 'yes'; 
cfg.channel = 'MEG'; 
data = ft_rejectvisual(cfg, data); 

data_clean_noICA = data
save data_clean_noICA data_clean_noICA
clear data_clean_noICA
close all

%% Timelock analysis %%
% The function ft_timelockanalysis makes averages of all the trials 
%in a data structure.
cfg=[];
avg_data_noICA=ft_timelockanalysis(cfg, data_clean_noICA);


save avg_data_noICA
% plot the average- all sensors in 1 figure

cfg = [];
cfg.showlabels = 'yes'; 
cfg.fontsize = 6; 
cfg.layout = 'neuromag306mag.lay';
cfg.ylim = [-3e-13 3e-13];
ft_multiplotER(cfg, avg_data_noICA); 

% this might be used to plot different conditions at the same time
cfg = [];
cfg.showlabels = 'no'; 
cfg.fontsize = 6; 
cfg.layout = 'neuromag306mag.lay';
cfg.baseline = [-0.2 0.4]; 
cfg.xlim = [-0.2 1.0]; 
cfg.ylim = [-3e-13 3e-13]; 
ft_multiplotER(cfg, avg_data_noICA); %chamge here add (cfg, avg_data_cond2)

%To plot the topographic distribution of the 
%data averaged over the time interval
% single plot
cfg = [];
cfg.xlim = [-0.5 0.8];
cfg.colorbar = 'yes';
ft_topoplotER(cfg,avg_data_noICA);

% To plot a sequence of topographic distributions define the time intervals
% cfg.xlim

cfg = [];
cfg.xlim = [-0.2 : 0.1 : 1.0];  % Define 12 time intervals
cfg.zlim = ['maxmin']           % Set the 'color' limits. [-2e-13 2e-13];
clf;
ft_topoplotER(cfg,avg_data_noICA);

%% Inspect the ERF - this is an additional step 


load avg_data_noICA.mat
load data_clean_noICA.mat
load data_clean.mat

cfg = [];
cfg.vartrllength  = 2;  % the default is NOT to allow variable length trials
timelock_planar   = ft_timelockanalysis(cfg, data_clean);

figure
plot(timelock_planar.time, timelock_planar.avg);
grid on

cfg = [];
cfg.layout = 'neuromag306planar.lay';
figure
ft_multiplotER(cfg, timelock_planar);

%For a correct interpretation of the planar gradient topography,
%you should combine the two planar gradients at each location into a single (absolute) magnitude:

cfg = [];
timelock_cmb = ft_combineplanar(cfg, timelock_planar);

cfg = [];
cfg.layout = 'neuromag306cmb.lay';
ft_multiplotER(cfg, timelock_cmb);


%% ------------------ I C A ---------------------- %%

% 1. Dowmnsample your data
data_orig = data;             %save the original CLEAN data for later use 
cfg = []; 
cfg.resamplefs = 150;         %downsample frequency 
cfg.detrend = 'no'; 
disp('Downsampling data');
data = ft_resampledata(cfg, data_orig);

% Run ICA
disp('About to run ICA using the Runica method')
cfg            = [];
cfg.method     = 'fastica';
comp           = ft_componentanalysis(cfg, data);
save('comp.mat','comp','-v7.3')

% Display Components - change layout as needed
cfg = []; 
cfg.viewmode = 'component'; 
%cfg.layout = 'neuromag306all.lay';
cfg.layout = 'neuromag306mag.lay';
ft_databrowser(cfg, comp)
cfg.layout = 'neuromag306planar.lay';
ft_databrowser(cfg, comp)

%% Remove components from original data
% Decompose the original data as it was prior to downsampling 
diary on;
disp('Decomposing the original data as it was prior to downsampling...');
cfg           = [];
cfg.unmixing  = comp.unmixing;
cfg.topolabel = comp.topolabel;
comp_orig     = ft_componentanalysis(cfg, data_orig);

%% The original data can now be reconstructed, excluding specified components
% This asks the user to specify the components to be removed
disp('Enter components in the form [1 2 3]')
comp2remove = input('Which components would you like to remove?\n');
cfg           = [];
cfg.component = [comp2remove]; %these are the components to be removed
data_clean    = ft_rejectcomponent(cfg, comp_orig,data_orig);

%% Save the clean data
disp('Saving data_clean...');
save('data_clean','data_clean','-v7.3')
diary off

%% Display clean data
cfg = [];
cfg.channel = 'MEGGRAD';
cfg.viewmode =  'butterfly'; %'vertical';
ft_databrowser(cfg,data_clean)
cfg.channel = 'MEGMAG';
ft_databrowser(cfg,data_clean)

%%

% Next is sensor level time fq analysis --> trf_alien_example.m 
% supermario time frequency
