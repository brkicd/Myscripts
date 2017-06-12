% set your current directory
addpath '/apps/fieldtrip-20161031/'
ft_defaults;

addpath '/mnt/scratch28/Diandra/Fieldtrip/my_scripts/'
% specify location of the data file

rawfile= '/mnt/scratch28/Diandra/romano_luca/analysis/LR_super_mario_quat_tsss.fif';
subject='LR';           %number or name of the subject
% create log file
diary(sprintf('log %s.out',subject));
c = datestr(clock); %time and date
disp(sprintf('Running preprocessing script for subject %s',subject))
disp(c)
% first of all always do a  always do a quality check of your data

%ft quality check 
cfg         = []
cfg.dataset = rawfile;
ft_qualitycheck(cfg)


hdr   = ft_read_header(rawfile);
event = ft_read_event(rawfile);

% cfg = [];
% cfg.coilaccuracy = 2;
% cfg.headerfile = rawfile; 
% cfg.datafile = rawfile;
% cfg.channel = 'MEG';
% cfg.trialdef.triallength = Inf;
% cfg.trialdef.ntrials = 1;
% cfg = ft_definetrial(cfg);
%% Filtering
cfg = [];
cfg.coilaccuracy = 2;
cfg.headerfile = rawfile; 
cfg.datafile = rawfile;
cfg.continuous = 'yes';
cfg.bpfilter = 'yes';
cfg.bpfreq = [0.5 250];

data_raw = ft_preprocessing(cfg);


% cut your epochs 0-4 sec

cfg = [];
cfg.headerfile = rawfile; 
cfg.datafile = rawfile;
cfg.channel = 'MEG';
cfg.trialdef.prestim    = 0;               % in seconds remember the longer the better %1.5 (!)
cfg.trialdef.poststim   = 4; 
cfg.trialfun= 'DB_trialfun2';
cfg = ft_definetrial(cfg);
data = ft_redefinetrial(cfg,data_raw);

% hdr   = ft_read_header(rawfile);
% event = ft_read_event(rawfile);
% cfg = ft_definetrial(cfg);

% 
% data = ft_redefinetrial(cfg,data_raw);

% demean and detrend
% cfg = rmfield(cfg,'datafile');
% 
% cfg.demean = 'yes';
% cfg.detrend = 'yes';
% 
% data = ft_preprocessing(cfg,data);

clear data_raw

% avoid extra trails - where they are equal to 1 

voidtrials = find(data.trialinfo(:,1) == 1);
trials = [1:1:length(data.trialinfo)];
trials(voidtrials) = [];

cfg = [];
cfg.trials = trials;
data_all = ft_selectdata(cfg,data);     % you should get 180 trials

%define the I block 1-60 trials
cfg = []; 
cfg.trials = [1:1:60];
data1 = ft_selectdata(cfg,data_all);

% configure only the correct ones [trig>63==correct]
cfg = []; 
cfg.trials = find(data1.trialinfo(:,3)>63);

data1_correct = ft_selectdata(cfg,data1);


for i = 1:size(data1_correct.time,2)-1
%     data1_correct.time{1,i}(:) = data1_correct.time{1,i}(:) - 2;
    data1_correct.time{1,i}(3001:end) = [];
end


% Detrend and demean each trial
cfg = [];
cfg.demean = 'yes';
cfg.detrend = 'yes';
data1_correct = ft_preprocessing(cfg,data1_correct);

save data1_correct




cfg=[]
cfg.datafile=data_all
cfg=ft_databrowser(cfg)

%% Reject Trials
% Display visual trial summary to reject deviant trials.
% You need to load the mag + grad separately due to different scales

cfg = []; 
cfg.method = 'summary'; 
cfg.keepchannel = 'yes'; 
cfg.channel = 'MEGMAG'; 
cond1 = ft_rejectvisual(cfg, data1_correct); 

% Now load this
cfg.channel = 'MEGGRAD';
clean1_clean = ft_rejectvisual(cfg, cond1);
data = clean2; clear clean1 clean2
close all



for i = 1:size(data1_correct.time,2)-1
%     data1_correct.time{1,i}(:) = data1_correct.time{1,i}(:) - 2;
    data1_correct.time{1,i}(3001:end) = [];
end


% %%   select trials
% 
% cfg = [];
% % cfg.headerfile = data1_correct; 
% cfg.datafile        = data1_correct;
% %cfg.channel         = 'MEG';
% cfg.trl             = trl;
% cfg.trialdef.prestim    = 1;               % in seconds remember the longer the better %1.5 (!)
% cfg.trialdef.poststim   = 1; 
% cfg = ft_definetrial(cfg);
% 
% data1_correct = ft_redefinetrial(cfg,data1_correct);
% 
% 
% 
% % determine the number of samples before and after the trigger
% pretrig  = -round(cfg.trialdef.prestim  * hdr.Fs);
% posttrig =  round(cfg.trialdef.poststim * hdr.Fs);
% 
% % for each trial
% trl = [];
% 
% for j=1:length(data1_correct.trialinfo)
%     %if value(j) > 63 
%       %trg1 = value(j-2);
%       %trg2 = value(j-3);  
%     if data1_correct.trialinfo(j) == 4  || data1_correct.trialinfo(j) == 8  
% %      trlbegin = data1_correct.sampleinfo(j) + pretrig;       
% %         trlend   = data1_correct.sampleinfo(j) + posttrig;       
% %         offset   = pretrig;
% %         newtrl   = [trlbegin trlend offset ];
% %         trl      = [trl; newtrl]; 
%         if j == 1
%             newtrl   = [trlbegin trlend offset];
%         else
%             newtrl   = [newtrl; trlbegin trlend offset];
%         end
%         
%       end
% 
% 
% cfg=[]
% cfg.trial=trl



%%







