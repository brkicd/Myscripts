%export ascii file into matlab format
function read_Brainwave_summaries_power_PLI_MST()

% you can add things here, just use same syntax
properties=strvcat(' PLI',...
                   'total_power',...
                    'MST_degree',...
                    'MST_ecc',...
                    'MST_BC');
                    %'WPLI',...

% open the Brainwave matrix output - start by asking for the filename
[filename, pathname]=uigetfile('/studies/201311-88/atlasBF/DATA/*.*', 'Select the Matrix File');

filename=strcat(pathname, filename);

% read in the matrices
fid =fopen(filename, 'r');

while 1                                                                     %until we tell it to stop ....
    tline = fgetl(fid);
    if ~ischar(tline), break, end                                           %stop if we're already at the end of the file
    for i = 1: size(properties,1)                                           % iterate through the things we want to extract
        if strfind(tline, properties(i,:)),                                 %if the line has one of our properties of interest
            v = genvarname(deblank(tline(1:(strfind(tline, 'atlas')-1))));  %create a base name for the variables
            ind = strfind(tline, properties(i,:))+length(properties(i,:));  %find where the text ends on that line
            %epochnum= tline(strfind(tline, properties(i,:))-8);  
            epochnum=tline(strfind(tline, 'epoch')+5:strfind(tline, '.ascii')-1);%read from the file which epoch we're in
            tmp= str2num(tline (ind+1:end));                                %turn the rest of the line into numbers
            arr=tmp(2:end);                                                 %omit the first one which is the mean
            varname = ([v, '_', strtrim(properties(i,:)),'(',epochnum,',:)']);
            eval([varname, '=arr;']) ;                                            %put the matrix into our new variable
            
        end
        
    end
   
    
end
fclose(fid);                                                                   %always remember to close files else it eats memory

%create means and save them
for i = 1: size(properties,1)
    varname = genvarname([v, '_', properties(i,:)]);
    mnvarname=genvarname([v, '_', properties(i,:),'_mean']);
    eval([mnvarname,' = mean(',varname,', 1);']);                              %mean 1x78
    %eval(['save ',[v, '_', deblank(properties(i,:)),'_mean.mat'], ' ', mnvarname, ';']);  %save it
    
end

save x_PLI_MSTmean x_PLI_mean  x_total_power_mean x_MST_BC_mean x_MST_degree_mean x_MST_ecc_mean
 
end
%x_WPLI_mean
 