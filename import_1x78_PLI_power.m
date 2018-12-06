%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script allows to automatize import 1x78 par fq band
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dir= '/nfs/abc-wigry/studies/201311-88/atlasBF/fluency/';

freqBands= {'alpha'}          %{'alpha', 'beta'};
subjGroup= {'DD', 'TD'};
DDSubj= {'17','21','28','39','51','64','69','78','97','129'}  %{'13','28', '29', '39', '44', '78', '93', '126', '129', '143','162','171'};
TDSubj={'13','29','34','42','44','96','126','138','141','143','152','162','171'}   %{'10','17', '21', '34', '42', '51', '64', '69', '90', '97','138','152'};

nFreq= length(freqBands);
nGroup= length(subjGroup);
nSbDD= length(DDSubj);
nSbTD= length(TDSubj);

for f = 1:nFreq
    for g= 1:nGroup
        
        if strcmp(subjGroup{g}, 'DD')
            
            for s= 1:nSbDD
                pathname= [dir freqBands{f} '/' subjGroup{g} '/' ];
                filename= [DDSubj{s} '_PLI' freqBands{f} ];
                 read_Brainwave_summaries_PLI_Lw_Cw(filename, pathname);
            end
            
        else
            
            for s= 1:nSbTD
                pathname= [dir freqBands{f} '/' subjGroup{g} '/' ];
                filename= [TDSubj{s} '_PLI' freqBands{f}];
                 read_Brainwave_summaries_PLI_Lw_Cw(filename, pathname);
            end
            
        end
        
    end
    
    
end
