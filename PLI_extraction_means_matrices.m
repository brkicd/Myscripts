%% Extraction of PLI values from the 2 groups
%% Make a big matrix out of 7x78 MST_degree par group from the group averages

group1dir = '/mnt/coraid0/vol12/201311-88/atlasBF/permutation_stats/theta/r'
group2dir = '/mnt/coraid0/vol12/201311-88/atlasBF/permutation_stats/theta/rf'

group1files = dir(group1dir);
group1files = group1files(3:end);
for i = 1:size(group1files,1),
    group1fnames(i,:) = [group1dir,'/',group1files(i).name];
end

group2files = dir(group2dir);
group2files = group2files(3:end);
for i = 1:size(group2files,1),
    group2fnames(i,:) = [group2dir,'/',group2files(i).name];
end


fnames = strvcat(group1fnames,group2fnames); % a list of filenames
nfiles = size(fnames,1);
for i=1:nfiles
    d = load(deblank(fnames(i,:)));
    PLI(i,:) = d.x_PLI_mean;  % you have to change this based on the variable you're exctracting
    %degreeCorr(i,:) = d.x_MST_R_mean;
end


%% now do the big average of the risk group -change the name of the variable every time

groupsize=nfiles/2;
PLI_risk=mean( PLI(1:groupsize,:));
% mean of the risk_free group
PLI_risk_free=mean(PLI(groupsize+1:nfiles,:));

%% create big matrices and save as an .txt file

%%%%%%%------------------------------------------- RISK -------------------------------%%%%%%%  
M_PLI_risk=PLI_risk' * PLI_risk ;

% now you need to avoid that rows==columns
for i=1:78
    for j=i:78
        if(i==j)
            M_PLI_risk(i,j)=0;  
        end
    end
end

save('M_PLI_risk');
% Save as a txt file 
dlmwrite('M_PLI_risk.txt', M_PLI_risk, 'delimiter','\t','newline','pc')

%%%%%% ------------------------------------- RISK FREE-------------------------------%%%% 

M_PLI_risk_free=PLI_risk_free' * PLI_risk_free ;



% now you need to avoid that rows==columns
for i=1:78
    for j=i:78
        if(i==j)
           M_PLI_risk_free(i,j)=0;  
        end
    end
end

save('M_PLI_risk_free');


save('M_PLI_risk_free');
% Save as a txt file 
dlmwrite('M_PLI_risk_free.txt', M_PLI_risk_free, 'delimiter','\t','newline','pc')

%% MIN- MAX - MEAN values 1x78
%risk group
min_risk=min(PLI_risk)
max_risk=max(PLI_risk)
mean_risk=mean(PLI_risk)
%risk free group
min_riskfree=min(PLI_risk_free)
max_riskfree=max(PLI_risk_free)
mean_riskfree=mean(PLI_risk_free)




