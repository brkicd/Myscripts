%%    PREPROCESSING- SENSOR LEVEL DATA %%
% - preprocessing
% visualization
% artefact rejection
% ALWAYS RUN ft_defaults before you start

% set your current directory

cd '/mnt/scratch28/Diandra/0155';

% specify location of the data file

rawfile= '/mnt/scratch28/Diandra/0155/170428/CA_supermario_tsss.fif';
subject='155';  %number or name of the subject
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


% Epoching based on a specific triggers


