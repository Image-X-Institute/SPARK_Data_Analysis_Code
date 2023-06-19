clear all

%----------------------------------------------------------------------
%----------------------------------------------------------------------
% Inputs
% This is the patient ID to replace
patientID = ''

% This is the folder with the original log files
folder = 'C:\Users\data\linac_traj_logs\';

% TROG ID to replace with
TROGID = 'test123123'
%----------------------------------------------------------------------
%----------------------------------------------------------------------

%% Main program 

% Creating copied files. I do not want to overwrite original log files.

list = ls([folder '\*.bin']);

noOfTrajFiles = size(list,1);

for i = 1: noOfTrajFiles

look = strcat(folder, list(i,:))

outputfile = strcat('anon_', list(i,:))

output = strcat(folder, outputfile)

copyfile(look, output)

end


% Replacing all the matching patient IDs in the log file

list = ls([folder 'anon*.bin']);

noOfTrajFiles = size(list,1);

% New ID to be replaced with. I am setting the same size as the actual one. Otherwise there
% are issues with the bytes etc..

new = 1234567890

for i = 1: noOfTrajFiles
trajectoryFile = strcat(folder, list(i,:))
fid=fopen(trajectoryFile, 'r+'); 

f =fread(fid, 204);
a = ftell(fid)

b= fgetl(fid)
cursor = ftell(fid);
fseek(fid, cursor - 12, 'bof');
fprintf(fid, '%f', new);

fclose(fid);

end


% Removing patient ID from the log file name

list = ls([folder 'anon*.bin']);

noOfTrajFiles = size(list,1);

for i = 1: noOfTrajFiles
    
if(contains(list(i,:),patientID ))

totchr = strlength(list(i,:)) 

newChr = extractBetween(list(i,:),16,totchr)  

newname= strcat(TROGID, newChr)
newpath = strcat(folder,'\',newname)
oldpath = strcat(folder,'\',list(i,:))

movefile(oldpath, char(newpath))

end
end
