function KIMData = readKIMData_refpos(kVFolder, frameAverage, OLdata,PlannedCentPos)
% Find the number of trajectory files
if OLdata ==1
    list = ls([kVFolder '\MarkerLocationsGA*.txt']);
    noOfOLTrajFiles = size(list,1);
    
    for n = 1:noOfOLTrajFiles   
    fid=fopen([kVFolder '\MarkerLocationsGA_CouchShift_' num2str(n-1) '.txt']);
    rawKIMDataCurrent = textscan(fid, '%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f, %*f, %*f, %*f, %*f, %s', 'headerLines', 1);
    eval(['rawKIMData' num2str(n) '=rawKIMDataCurrent']);
    fclose(fid);
    end
    
elseif OLdata ==0
    list = ls([kVFolder '\MarkerLocationsGA*.txt']);
    noOfOLTrajFiles = size(list,1);
    
    for n = 1:noOfOLTrajFiles   
    fid=fopen([kVFolder '\MarkerLocationsGA_CouchShift_' num2str(n-1) '.txt']);
    rawKIMDataCurrent = textscan(fid, '%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f', 'headerLines', 1);
    eval(['rawKIMData' num2str(n) '=rawKIMDataCurrent']);
    fclose(fid);
    end
end



% Merge all trajectory files into one
noOfColumns = 24;
for n = 1:noOfColumns
    for k = 1:noOfOLTrajFiles
        
        if (k==1)
            rawKIMData{n} = [eval(['rawKIMData' num2str(k) '{n}'])];
        else
            rawKIMData{n} = [rawKIMData{n}; eval(['rawKIMData' num2str(k) '{n}']) ];
        end
    end
    
end

%Check if all field has the same number of data points
numCellData = cellfun('length',rawKIMData);
shortData = min(numCellData)

for i=1:noOfColumns
   rawKIMData{1,i} = rawKIMData{1,i}(1:shortData);
end    

KIMData.kVFrameNo = rawKIMData{1};
KIMData.timestamps = rawKIMData{2};
KIMData.timestamps = KIMData.timestamps - KIMData.timestamps(1);
KIMData.kVSourceAngle = rawKIMData{3};


if frameAverage == 1
    KIMData.kVFrameNo = KIMData.kVFrameNo + 1;
else
    KIMData.kVFrameNo = KIMData.kVFrameNo * frameAverage;
    KIMData.kVFrameNo(1) = 1;
end

% 2D
% 2D trajectories for KIM data
% Index the markers by y position where 1 is the most cranial and 3 the most caudal
% C# indexes from 0 to N-1 so a + 1 is added to each 2D trajectory for
% equivalent comparison to MATLAB
array = [mean(rawKIMData{14}) mean(rawKIMData{16}) mean(rawKIMData{18})];
sortedArray = sort(array, 'ascend');
indexes = [find(sortedArray(1) == array) find(sortedArray(2) == array) find(sortedArray(3) == array)];

for n = 1:3
    if indexes(n) == 1
        eval(['KIMData.xp' num2str(n) '= rawKIMData{13} + 1']);
        eval(['KIMData.yp' num2str(n) '= rawKIMData{14} + 1']);
    elseif indexes(n) == 2
        eval(['KIMData.xp' num2str(n) '= rawKIMData{15} + 1']);
        eval(['KIMData.yp' num2str(n) '= rawKIMData{16} + 1']);
    elseif indexes(n) == 3
        eval(['KIMData.xp' num2str(n) '= rawKIMData{17} + 1']);
        eval(['KIMData.yp' num2str(n) '= rawKIMData{18} + 1']);
    end
end

% 2D
% Compute centroids for the 2D coordinates
KIMData.xpCent = (KIMData.xp1 + KIMData.xp2 + KIMData.xp3) / 3 ;
KIMData.ypCent = (KIMData.yp1 + KIMData.yp2 + KIMData.yp3) / 3 ;

% K. 3D trajectories for KIM data
% Index the markers by SI position where 1 is the most cranial and 3 the most caudal
array = [mean(rawKIMData{6}) mean(rawKIMData{9}) mean(rawKIMData{12})];
sortedArray = sort(array, 'descend');
indexes = [find(sortedArray(1) == array) find(sortedArray(2) == array) find(sortedArray(3) == array)];

for n = 1:3
    if indexes(n) == 1
        eval(['KIMData.x' num2str(n) '= rawKIMData{5}']);
        eval(['KIMData.y' num2str(n) '= rawKIMData{6}']);
        eval(['KIMData.z' num2str(n) '= rawKIMData{4}']);
    elseif indexes(n) == 2
        eval(['KIMData.x' num2str(n) '= rawKIMData{8}']);
        eval(['KIMData.y' num2str(n) '= rawKIMData{9}']);
        eval(['KIMData.z' num2str(n) '= rawKIMData{7}']);
    elseif indexes(n) == 3
        eval(['KIMData.x' num2str(n) '= rawKIMData{11}']);
        eval(['KIMData.y' num2str(n) '= rawKIMData{12}']);
        eval(['KIMData.z' num2str(n) '= rawKIMData{10}']);
    end
end

KIMData.r1 = sqrt(KIMData.x1.^2 + KIMData.y1.^2 + KIMData.z1.^2);
KIMData.r2 = sqrt(KIMData.x2.^2 + KIMData.y2.^2 + KIMData.z2.^2);
KIMData.r3 = sqrt(KIMData.x3.^2 + KIMData.y3.^2 + KIMData.z3.^2);

% 
% K. Compute centroid 3D trajectories for KIM data
KIMData.xCent = (KIMData.x1 + KIMData.x2 + KIMData.x3)/3;
KIMData.yCent = (KIMData.y1 + KIMData.y2 + KIMData.y3)/3;
KIMData.zCent = (KIMData.z1 + KIMData.z2 + KIMData.z3)/3;
KIMData.rCent = sqrt(KIMData.xCent.^2 + KIMData.yCent.^2 + KIMData.zCent.^2);

PlannedCent = mean(PlannedCentPos,1);
PlannedCent_x = PlannedCent(1);
PlannedCent_y = PlannedCent(2);
PlannedCent_z = PlannedCent(3);

%KIMData.xCentOff = KIMData.xCent - KIMData.xCent(1);
%KIMData.yCentOff = KIMData.yCent - KIMData.yCent(1);
%KIMData.zCentOff = KIMData.zCent - KIMData.zCent(1);

KIMData.xCentOff = KIMData.xCent - PlannedCent_x;
KIMData.yCentOff = KIMData.yCent - PlannedCent_y;
KIMData.zCentOff = KIMData.zCent - PlannedCent_z;

KIMData.rCentOff = sqrt(KIMData.xCentOff.^2 + KIMData.yCentOff.^2 + KIMData.zCentOff.^2);

end
