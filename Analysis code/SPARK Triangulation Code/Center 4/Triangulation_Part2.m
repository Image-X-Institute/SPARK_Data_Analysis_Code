function KIMGTriPart2
%clear
%clc
close all
%%
%%%%%%%%%%%%%%%%%%%%%%%% Inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Pat      =   'PAT01'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Fraction =   'Fx01';  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pat      =   Pat; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fx =   Fraction;  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
global frameAverage;

% Inputs
 outputPath = strcat('Output\',Pat, '\', Fraction);
 fxPath =strcat('\',Pat, '\', Fraction);

frameAverage = 1;
% Isocenter offsets
% MV Isocal/TS3/30 Sep 2014
MVOffsetsX = [-1.90658544 -1.42631161	0.710209323];
MVOffsetsY = [7.821516977	0.897579659	89.10368905];

split = regexp(fxPath, '\', 'split');

% 1. Load all data from KIMGTriPart1.m 
% These include MV segmented positions and kV data

[header, Data] = combine_Auto_Man_Segmentation(outputPath);

% 2. Put all data into a structure
Data = structurize(Data, header);

% 2a. Apply MV calibration
Data = applyMVCalib(MVOffsetsX, MVOffsetsY, Data);

% 3. Print the Data again as a check
printData([outputPath '\Part2Step3Check.xls'], Data)

% 4. Extract the rows of Data which have correct segmented MV position
% i.e. rows corresponding to MVbutton = 1
Data = extractData(Data);

% 5. Print data as a check
printData([outputPath '\Part2Step5Check.xls'], Data)

% 6. Triangulate 
nRows = size(Data.MVFrameNo,1);

offMV = 0;
syncErr = 0;

    for n = (1+offMV):(nRows-syncErr)
    % Triangulate with kV marker 1
    [TriPos1, Data.dYp1(n)] = triangulateForKIM(Data.MVGantryAngle(n), Data.MVxpCalib(n), Data.MVypCalib(n), Data.kVSourceAngle(n+syncErr), Data.xp1(n+syncErr), Data.yp1(n+syncErr));
    TriPos1(1)
    Data.TriX1(n) = TriPos1(1);
    Data.TriY1(n) = TriPos1(2);
    Data.TriZ1(n) = TriPos1(3);
    Data.VecDiff1(n) = sqrt(    (Data.TriX1(n) - Data.x1(n+syncErr)).^2 + (Data.TriY1(n) - Data.y1(n+syncErr)).^2 + (Data.TriZ1(n) - Data.z1(n+syncErr)).^2     );

    % Triangulate with kV marker 2
    [TriPos2, Data.dYp2(n)] = triangulateForKIM(Data.MVGantryAngle(n), Data.MVxpCalib(n), Data.MVypCalib(n), Data.kVSourceAngle(n+syncErr), Data.xp2(n+syncErr), Data.yp2(n+syncErr));
    Data.TriX2(n) = TriPos2(1);
    Data.TriY2(n) = TriPos2(2);
    Data.TriZ2(n) = TriPos2(3);
    Data.VecDiff2(n) = sqrt(    (Data.TriX2(n) - Data.x2(n+syncErr)).^2 + (Data.TriY2(n) - Data.y2(n+syncErr)).^2 + (Data.TriZ2(n) - Data.z2(n+syncErr)).^2     );

    % Triangulate with kV marker 3
    [TriPos3, Data.dYp3(n)] = triangulateForKIM(Data.MVGantryAngle(n), Data.MVxpCalib(n), Data.MVypCalib(n), Data.kVSourceAngle(n+syncErr), Data.xp3(n+syncErr), Data.yp3(n+syncErr));
    Data.TriX3(n) = TriPos3(1);
    Data.TriY3(n) = TriPos3(2);
    Data.TriZ3(n) = TriPos3(3);
    Data.VecDiff3(n) = sqrt(    (Data.TriX3(n) - Data.x3(n)).^2 + (Data.TriY3(n) - Data.y3(n)).^2 + (Data.TriZ3(n) - Data.z3(n)).^2     );


    % Find the marker with the least vector difference
    % Note: Tried setting AP to + for Posterior. Ricky must have changed the
    % direction of the KIM AP output
    listOfVecDiff = [Data.VecDiff1(n) Data.VecDiff2(n) Data.VecDiff3(n)];

    Data.MarkerNo(n) = find(listOfVecDiff == min(listOfVecDiff));


    end


    for n = (1+offMV):(nRows-syncErr)
    % Triangulate with kV marker 1
    [TriPos1, Data.dYp1(n)] = triangulateForKIM(Data.MVGantryAngle(n), Data.MVxp(n), Data.MVyp(n), Data.kVSourceAngle(n+syncErr), Data.xp1(n+syncErr), Data.yp1(n+syncErr));
    TriPos1(1)
    Data.TriX11(n) = TriPos1(1);
    Data.TriY11(n) = TriPos1(2);
    Data.TriZ11(n) = TriPos1(3);
    Data.VecDiff11(n) = sqrt(    (Data.TriX11(n) - Data.x1(n+syncErr)).^2 + (Data.TriY11(n) - Data.y1(n+syncErr)).^2 + (Data.TriZ11(n) - Data.z1(n+syncErr)).^2     );

    % Triangulate with kV marker 2
    [TriPos2, Data.dYp2(n)] = triangulateForKIM(Data.MVGantryAngle(n), Data.MVxp(n), Data.MVyp(n), Data.kVSourceAngle(n+syncErr), Data.xp2(n+syncErr), Data.yp2(n+syncErr));
    Data.TriX22(n) = TriPos2(1);
    Data.TriY22(n) = TriPos2(2);
    Data.TriZ22(n) = TriPos2(3);
    Data.VecDiff22(n) = sqrt(    (Data.TriX22(n) - Data.x2(n+syncErr)).^2 + (Data.TriY22(n) - Data.y2(n+syncErr)).^2 + (Data.TriZ22(n) - Data.z2(n+syncErr)).^2     );

    % Triangulate with kV marker 3
    [TriPos3, Data.dYp3(n)] = triangulateForKIM(Data.MVGantryAngle(n), Data.MVxp(n), Data.MVyp(n), Data.kVSourceAngle(n+syncErr), Data.xp3(n+syncErr), Data.yp3(n+syncErr));
    Data.TriX33(n) = TriPos3(1);
    Data.TriY33(n) = TriPos3(2);
    Data.TriZ33(n) = TriPos3(3);
    Data.VecDiff33(n) = sqrt(    (Data.TriX33(n) - Data.x3(n+syncErr)).^2 + (Data.TriY33(n) - Data.y3(n+syncErr)).^2 + (Data.TriZ33(n) - Data.z3(n+syncErr)).^2     );


    % Find the marker with the least vector difference
    % Note: Tried setting AP to + for Posterior. Ricky must have changed the
    % direction of the KIM AP output
    listOfVecDiff1 = [Data.VecDiff11(n) Data.VecDiff22(n) Data.VecDiff33(n)];

    Data.MarkerNo1(n) = find(listOfVecDiff1 == min(listOfVecDiff1));

    end    


if syncErr ~= 0 
   Data.MVFrameNo = Data.MVFrameNo(1:(nRows-syncErr));
   Data.MVFilename = Data.MVFilename(1:(nRows-syncErr));
   Data.MVWindowsTimestamps = Data.MVWindowsTimestamps(1:(nRows-syncErr));
   Data.MVGantryAngle = Data.MVGantryAngle(1:(nRows-syncErr));
   Data.MVxp = Data.MVxp(1:(nRows-syncErr));
   Data.MVyp = Data.MVyp(1:(nRows-syncErr));
   Data.MVbutton = Data.MVbutton(1:(nRows-syncErr));
   Data.kVFrameNo = Data.kVFrameNo(1:(nRows-syncErr));
   Data.kVFilename = Data.kVFilename(1:(nRows-syncErr));
   Data.kVSourceAngle = Data.kVSourceAngle(1:(nRows-syncErr));
   Data.kVWindowsTimestamps = Data.kVWindowsTimestamps(1:(nRows-syncErr));
   Data.xp1 = Data.xp1(1:(nRows-syncErr));
   Data.yp1 = Data.yp1(1:(nRows-syncErr));
   Data.xp2 = Data.xp2(1:(nRows-syncErr));
   Data.yp2 = Data.yp2(1:(nRows-syncErr));
   Data.xp3 = Data.xp3(1:(nRows-syncErr));
   Data.yp3 = Data.yp3(1:(nRows-syncErr));
   Data.x1 = Data.x1(1:(nRows-syncErr));
   Data.y1 = Data.y1(1:(nRows-syncErr));
   Data.z1 = Data.z1(1:(nRows-syncErr));
   Data.x2 = Data.x2(1:(nRows-syncErr));
   Data.y2 = Data.y2(1:(nRows-syncErr));
   Data.z2 = Data.z2(1:(nRows-syncErr));
   Data.x3 = Data.x3(1:(nRows-syncErr));
   Data.y3 = Data.y3(1:(nRows-syncErr));
   Data.z3 = Data.z3(1:(nRows-syncErr));
   Data.timeDiff = Data.timeDiff(1:(nRows-syncErr));
   Data.MVxpCalib = Data.MVxpCalib(1:(nRows-syncErr));
   Data.MVypCalib = Data.MVypCalib(1:(nRows-syncErr));
end
% 7. Print final Data in Excel sheet
printFinalData([outputPath '\''TriangulatedPositions.xls'], Data)

% 8. Compute and print metrics for each marker
computeMetrics([outputPath '\''Metrics.xls'], Data);

% 9. Plot and save final Data
plotFinalData(outputPath, pat, fx, Data);

end

function Metrics = computeMetrics(filename, Data)
% Plot each plot per marker

% Extract the relevant rows for each marker
indexForMarker1 = find(Data.MarkerNo == 1);
indexForMarker2 = find(Data.MarkerNo == 2);
indexForMarker3 = find(Data.MarkerNo == 3);

listOfFields = fieldnames(Data);
noOfFields = numel(listOfFields);

for n = 1:noOfFields
    vector = Data.(listOfFields{n});
    
    DataMarker1.(listOfFields{n}) = vector(indexForMarker1);
    DataMarker2.(listOfFields{n}) = vector(indexForMarker2);
    DataMarker3.(listOfFields{n}) = vector(indexForMarker3);
    
end


% Compute metrics for each marker
% Marker1
if isempty(DataMarker1.kVWindowsTimestamps)
    disp('Marker1: No segmented data')
else
    Metrics.meanDiffMarker1LR =  mean(DataMarker1.x1 - DataMarker1.TriX1');
    Metrics.meanDiffMarker1SI =  mean(DataMarker1.y1 - DataMarker1.TriY1');
    Metrics.meanDiffMarker1AP =  mean(DataMarker1.z1 - DataMarker1.TriZ1');
    
    Metrics.stdDiffMarker1LR =  std(DataMarker1.x1 - DataMarker1.TriX1');
    Metrics.stdDiffMarker1SI =  std(DataMarker1.y1 - DataMarker1.TriY1');
    Metrics.stdDiffMarker1AP =  std(DataMarker1.z1 - DataMarker1.TriZ1');
        
    Metrics.prcDiffMarker1LR = tsprctile((DataMarker1.x1 - DataMarker1.TriX1'), [5 95])
    Metrics.prcDiffMarker1SI = tsprctile((DataMarker1.y1 - DataMarker1.TriY1'), [5 95])
    Metrics.prcDiffMarker1AP = tsprctile((DataMarker1.z1 - DataMarker1.TriZ1'), [5 95])
    
    Metrics.rmseMarker1LR = rmse(DataMarker1.x1, DataMarker1.TriX1');
    Metrics.rmseMarker1SI = rmse(DataMarker1.y1, DataMarker1.TriY1');
    Metrics.rmseMarker1AP = rmse(DataMarker1.z1, DataMarker1.TriZ1');
    
    Metrics.rmseMarker13D = sqrt( ( sum((DataMarker1.x1 - DataMarker1.TriX1').^2)    +   sum((DataMarker1.y1 - DataMarker1.TriY1').^2)  +   sum((DataMarker1.z1 - DataMarker1.TriZ1').^2)    )/length(DataMarker1.x1)   );
    Metrics.rmseMarker1Check = sqrt( Metrics.rmseMarker1LR^2 + Metrics.rmseMarker1SI^2 + Metrics.rmseMarker1AP^2   );
    
    Metrics.Marker1NPoints = length(DataMarker1.x1);
    
end

% Marker2
if isempty(DataMarker2.kVWindowsTimestamps)
    disp('Marker2: No segmented data')
else
    Metrics.meanDiffMarker2LR =  mean(DataMarker2.x2 - DataMarker2.TriX2');
    Metrics.meanDiffMarker2SI =  mean(DataMarker2.y2 - DataMarker2.TriY2');
    Metrics.meanDiffMarker2AP =  mean(DataMarker2.z2 - DataMarker2.TriZ2');
    
    Metrics.stdDiffMarker2LR =  std(DataMarker2.x2 - DataMarker2.TriX2');
    Metrics.stdDiffMarker2SI =  std(DataMarker2.y2 - DataMarker2.TriY2');
    Metrics.stdDiffMarker2AP =  std(DataMarker2.z2 - DataMarker2.TriZ2');
        
    Metrics.prcDiffMarker2LR = tsprctile((DataMarker2.x2 - DataMarker2.TriX2'), [5 95])
    Metrics.prcDiffMarker2SI = tsprctile((DataMarker2.y2 - DataMarker2.TriY2'), [5 95])
    Metrics.prcDiffMarker2AP = tsprctile((DataMarker2.z2 - DataMarker2.TriZ2'), [5 95])
    
    Metrics.rmseMarker2LR = rmse(DataMarker2.x2, DataMarker2.TriX2');
    Metrics.rmseMarker2SI = rmse(DataMarker2.y2, DataMarker2.TriY2');
    Metrics.rmseMarker2AP = rmse(DataMarker2.z2, DataMarker2.TriZ2');
    
    Metrics.rmseMarker23D = sqrt( ( sum((DataMarker2.x2 - DataMarker2.TriX2').^2)    +   sum((DataMarker2.y2 - DataMarker2.TriY2').^2)  +   sum((DataMarker2.z2 - DataMarker2.TriZ2').^2)    )/length(DataMarker2.x2)   );
    Metrics.rmseMarker2Check = sqrt( Metrics.rmseMarker2LR^2 + Metrics.rmseMarker2SI^2 + Metrics.rmseMarker2AP^2   );
    
    Metrics.Marker2NPoints = length(DataMarker2.x2);
    
end

% Marker3
if isempty(DataMarker3.kVWindowsTimestamps)
    disp('Marker3: No segmented data')
else
    Metrics.meanDiffMarker3LR =  mean(DataMarker3.x3 - DataMarker3.TriX3');
    Metrics.meanDiffMarker3SI =  mean(DataMarker3.y3 - DataMarker3.TriY3');
    Metrics.meanDiffMarker3AP =  mean(DataMarker3.z3 - DataMarker3.TriZ3');
    
    Metrics.stdDiffMarker3LR =  std(DataMarker3.x3 - DataMarker3.TriX3');
    Metrics.stdDiffMarker3SI =  std(DataMarker3.y3 - DataMarker3.TriY3');
    Metrics.stdDiffMarker3AP =  std(DataMarker3.z3 - DataMarker3.TriZ3');
        
    Metrics.prcDiffMarker3LR = tsprctile((DataMarker3.x3 - DataMarker3.TriX3'), [5 95])
    Metrics.prcDiffMarker3SI = tsprctile((DataMarker3.y3 - DataMarker3.TriY3'), [5 95])
    Metrics.prcDiffMarker3AP = tsprctile((DataMarker3.z3 - DataMarker3.TriZ3'), [5 95])
    
    Metrics.rmseMarker3LR = rmse(DataMarker3.x3, DataMarker3.TriX3');
    Metrics.rmseMarker3SI = rmse(DataMarker3.y3, DataMarker3.TriY3');
    Metrics.rmseMarker3AP = rmse(DataMarker3.z3, DataMarker3.TriZ3');
    
    Metrics.rmseMarker33D = sqrt( ( sum((DataMarker3.x3 - DataMarker3.TriX3').^2)    +   sum((DataMarker3.y3 - DataMarker3.TriY3').^2)  +   sum((DataMarker3.z3 - DataMarker3.TriZ3').^2)    )/length(DataMarker3.x3)   );
    Metrics.rmseMarker3Check = sqrt( Metrics.rmseMarker3LR^2 + Metrics.rmseMarker3SI^2 + Metrics.rmseMarker3AP^2   );
    
    Metrics.Marker3NPoints = length(DataMarker3.x3);
    
end

% Compute metrics for all markers
% Construct vectors to group all markers.
DataMarkerAll.x = [DataMarker1.x1; DataMarker2.x2; DataMarker3.x3];
DataMarkerAll.y = [DataMarker1.y1; DataMarker2.y2; DataMarker3.y3];
DataMarkerAll.z = [DataMarker1.z1; DataMarker2.z2; DataMarker3.z3];

DataMarkerAll.TriX = [DataMarker1.TriX1 DataMarker2.TriX2 DataMarker3.TriX3]';
DataMarkerAll.TriY = [DataMarker1.TriY1 DataMarker2.TriY2 DataMarker3.TriY3]';
DataMarkerAll.TriZ = [DataMarker1.TriZ1 DataMarker2.TriZ2 DataMarker3.TriZ3]';

Metrics.meanDiffMarkerAllLR =  mean(DataMarkerAll.x - DataMarkerAll.TriX);
Metrics.meanDiffMarkerAllSI =  mean(DataMarkerAll.y - DataMarkerAll.TriY);
Metrics.meanDiffMarkerAllAP =  mean(DataMarkerAll.z - DataMarkerAll.TriZ);

Metrics.stdDiffMarkerAllLR =  std(DataMarkerAll.x - DataMarkerAll.TriX);
Metrics.stdDiffMarkerAllSI =  std(DataMarkerAll.y - DataMarkerAll.TriY);
Metrics.stdDiffMarkerAllAP =  std(DataMarkerAll.z - DataMarkerAll.TriZ);

Metrics.prcDiffMarkerAllLR = tsprctile((DataMarkerAll.x - DataMarkerAll.TriX), [5 95])
Metrics.prcDiffMarkerAllSI = tsprctile((DataMarkerAll.y - DataMarkerAll.TriY), [5 95])
Metrics.prcDiffMarkerAllAP = tsprctile((DataMarkerAll.z - DataMarkerAll.TriZ), [5 95])

Metrics.rmseMarkerAllLR = rmse(DataMarkerAll.x, DataMarkerAll.TriX);
Metrics.rmseMarkerAllSI = rmse(DataMarkerAll.y, DataMarkerAll.TriY);
Metrics.rmseMarkerAllAP = rmse(DataMarkerAll.z, DataMarkerAll.TriZ);

Metrics.rmseMarkerAll3D = sqrt( ( sum((DataMarkerAll.x - DataMarkerAll.TriX).^2)    +   sum((DataMarkerAll.y - DataMarkerAll.TriY).^2)  +   sum((DataMarkerAll.z - DataMarkerAll.TriZ).^2)    )/length(DataMarkerAll.x)   );
Metrics.rmseMarkerAllCheck = sqrt( Metrics.rmseMarkerAllLR^2 + Metrics.rmseMarkerAllSI^2 + Metrics.rmseMarkerAllAP^2   );

Metrics.MarkerAllNPoints = length(DataMarkerAll.x);

% Write metrics to Triangulated Positions xls file
fid = fopen(filename, 'w')
fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\n', ' ', 'Mean Difference (mm)', ' ', ' ', 'Std Difference (mm)', ' ', ' ', 'Prc Difference (mm) [5%, 95%]', ' ', ' ', ' ', ' ', ' ', 'RMSE (mm)', ' ', ' ', ' ', ' ', 'NPoints')
fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\n', ' ', 'LR', 'SI', 'AP', 'LR', 'SI', 'AP', 'LR', ' ', 'SI', ' ', 'AP', '', 'LR', 'SI', 'AP', '3D', 'Check')
% Marker1
fprintf(fid, '%s\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\n', 'Marker1', ...
    [Metrics.meanDiffMarker1LR Metrics.meanDiffMarker1SI Metrics.meanDiffMarker1AP ...
    Metrics.stdDiffMarker1LR Metrics.stdDiffMarker1SI Metrics.stdDiffMarker1AP ...
    Metrics.prcDiffMarker1LR(1) Metrics.prcDiffMarker1LR(2) ...
    Metrics.prcDiffMarker1SI(1) Metrics.prcDiffMarker1SI(2) ...
    Metrics.prcDiffMarker1AP(1) Metrics.prcDiffMarker1AP(2) ... 
    Metrics.rmseMarker1LR Metrics.rmseMarker1SI Metrics.rmseMarker1AP Metrics.rmseMarker13D Metrics.rmseMarker1Check Metrics.Marker1NPoints])

% Marker2
fprintf(fid, '%s\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\n', 'Marker2', ...
    [Metrics.meanDiffMarker2LR Metrics.meanDiffMarker2SI Metrics.meanDiffMarker2AP ...
    Metrics.stdDiffMarker2LR Metrics.stdDiffMarker2SI Metrics.stdDiffMarker2AP ...
    Metrics.prcDiffMarker2LR(1) Metrics.prcDiffMarker2LR(2) ...
    Metrics.prcDiffMarker2SI(1) Metrics.prcDiffMarker2SI(2) ...
    Metrics.prcDiffMarker2AP(1) Metrics.prcDiffMarker2AP(2) ...
    Metrics.rmseMarker2LR Metrics.rmseMarker2SI Metrics.rmseMarker2AP Metrics.rmseMarker23D Metrics.rmseMarker2Check Metrics.Marker2NPoints])

% Marker3
fprintf(fid, '%s\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\n', 'Marker3', ...
    [Metrics.meanDiffMarker3LR Metrics.meanDiffMarker3SI Metrics.meanDiffMarker3AP ...
    Metrics.stdDiffMarker3LR Metrics.stdDiffMarker3SI Metrics.stdDiffMarker3AP ...
    Metrics.prcDiffMarker3LR(1) Metrics.prcDiffMarker3LR(2) ...
    Metrics.prcDiffMarker3SI(1) Metrics.prcDiffMarker3SI(2) ...
    Metrics.prcDiffMarker3AP(1) Metrics.prcDiffMarker3AP(2) ...
    Metrics.rmseMarker3LR Metrics.rmseMarker3SI Metrics.rmseMarker3AP Metrics.rmseMarker33D Metrics.rmseMarker3Check Metrics.Marker3NPoints])

% All markers
fprintf(fid, '%s\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\n', 'All', ...
    [Metrics.meanDiffMarkerAllLR Metrics.meanDiffMarkerAllSI Metrics.meanDiffMarkerAllAP ...
    Metrics.stdDiffMarkerAllLR Metrics.stdDiffMarkerAllSI Metrics.stdDiffMarkerAllAP ...
    Metrics.prcDiffMarkerAllLR(1) Metrics.prcDiffMarkerAllLR(2) ...
    Metrics.prcDiffMarkerAllSI(1) Metrics.prcDiffMarkerAllSI(2) ...
    Metrics.prcDiffMarkerAllAP(1) Metrics.prcDiffMarkerAllAP(2) ...
    Metrics.rmseMarkerAllLR Metrics.rmseMarkerAllSI Metrics.rmseMarkerAllAP Metrics.rmseMarkerAll3D Metrics.rmseMarkerAllCheck Metrics.MarkerAllNPoints])

fclose(fid)
end

function a = rmse(x,y)
a = sqrt(   sum((x-y).^2)   /   length(x) );
end

function [Header, Data] = readMVMarkerPositions(filename)
fid = fopen(filename); 
Header = textscan(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\n', 'headerlines', 0);
Data = textscan(fid, '%f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\r', 'headerlines', 1);
fclose(fid);


end

function output = structurize(Data, Header)
% Data is a cell array. Convert it into a structure.

for n = 1:size(Data,2)
    currentHeader = (Header{1,n});
    currentHeader = currentHeader{1};
    output.(currentHeader) = Data{1,n};
end



end

function plotFinalData(outputPath, pat, fx, Data)
% Plot each plot per marker

% Extract the relevant rows for each marker
indexForMarker1 = find(Data.MarkerNo == 1);
indexForMarker2 = find(Data.MarkerNo == 2);
indexForMarker3 = find(Data.MarkerNo == 3);

listOfFields = fieldnames(Data);
noOfFields = numel(listOfFields);

for n = 1:noOfFields
    vector = Data.(listOfFields{n});
    
    DataMarker1.(listOfFields{n}) = vector(indexForMarker1);
    DataMarker2.(listOfFields{n}) = vector(indexForMarker2);
    DataMarker3.(listOfFields{n}) = vector(indexForMarker3);
    
end


% Plot data for each marker
% Marker1
if isempty(DataMarker1.kVWindowsTimestamps)
    disp('Marker1: No segmented data')
else
    % Plot the data
    figure(1)
    hold on
    DataMarker1.kVWindowsTimestamps = DataMarker1.kVWindowsTimestamps - DataMarker1.kVWindowsTimestamps(1);
    DataMarker1.kVWindowsTimestamps = DataMarker1.kVFrameNo;
    plot(DataMarker1.kVWindowsTimestamps, DataMarker1.TriX1, 'kv', DataMarker1.kVWindowsTimestamps, DataMarker1.TriY1, 'kv', DataMarker1.kVWindowsTimestamps, DataMarker1.TriZ1, 'kv', 'linewidth', 2)
    plot(DataMarker1.kVWindowsTimestamps, DataMarker1.x1, 'b+', DataMarker1.kVWindowsTimestamps, DataMarker1.y1, 'g+', DataMarker1.kVWindowsTimestamps, DataMarker1.z1, 'r+', 'linewidth', 6)
    hold off
    xlabel('kV Frame No','fontsize',16)
    ylabel('Position (mm)', 'fontsize', 16')
    title('Marker1', 'fontsize', 16)
    legend('LR (TRI)', 'SI (TRI)', 'AP (TRI)', 'LR (KIM)', 'SI (KIM)', 'AP (KIM)', 'location', 'northeastoutside')
    set(gca,'fontsize',16)
end

% Marker2
if isempty(DataMarker2.kVWindowsTimestamps)
    disp('Marker2: No segmented data')
else
    figure(2)
    hold on
    DataMarker2.kVWindowsTimestamps = DataMarker2.kVWindowsTimestamps - DataMarker2.kVWindowsTimestamps(1);    
    DataMarker2.kVWindowsTimestamps = DataMarker2.kVFrameNo;
    plot(DataMarker2.kVWindowsTimestamps, DataMarker2.TriX2, 'kv', DataMarker2.kVWindowsTimestamps, DataMarker2.TriY2, 'kv', DataMarker2.kVWindowsTimestamps, DataMarker2.TriZ2, 'kv', 'linewidth', 2)
    plot(DataMarker2.kVWindowsTimestamps, DataMarker2.x2, 'b+', DataMarker2.kVWindowsTimestamps, DataMarker2.y2, 'g+', DataMarker2.kVWindowsTimestamps, DataMarker2.z2, 'r+', 'linewidth', 6)

   hold off
    xlabel('kV Frame No', 'fontsize', 16)
    ylabel('Position (mm)', 'fontsize', 16')
    title('Marker2', 'fontsize', 16)
    legend('LR (TRI)', 'SI (TRI)', 'AP (TRI)', 'LR (KIM)', 'SI (KIM)', 'AP (KIM)', 'location', 'northeastoutside')
    set(gca,'fontsize',16)
end


% Marker3
if isempty(DataMarker3.kVWindowsTimestamps)
    disp('Marker3: No segmented data')
else
    figure(3)
    hold on
  %  DataMarker3.kVWindowsTimestamps = DataMarker3.kVWindowsTimestamps - DataMarker3.kVWindowsTimestamps(1);
    DataMarker3.kVWindowsTimestamps = DataMarker3.kVFrameNo;
    plot(DataMarker3.kVWindowsTimestamps, DataMarker3.TriX3, 'kv', DataMarker3.kVWindowsTimestamps, DataMarker3.TriY3, 'kv', DataMarker3.kVWindowsTimestamps, DataMarker3.TriZ3, 'kv', 'linewidth', 2)
    plot(DataMarker3.kVWindowsTimestamps, DataMarker3.x3, 'b+', DataMarker3.kVWindowsTimestamps, DataMarker3.y3, 'g+', DataMarker3.kVWindowsTimestamps, DataMarker3.z3, 'r+', 'linewidth', 6)    
  %  plot(DataMarker3.MVGantryAngle, DataMarker3.TriX3, 'kv', DataMarker3.MVGantryAngle, DataMarker3.TriY3, 'kv', DataMarker3.MVGantryAngle, DataMarker3.TriZ3, 'kv', 'linewidth', 2)
  %  plot(DataMarker3.MVGantryAngle, DataMarker3.x3, 'b+', DataMarker3.MVGantryAngle, DataMarker3.y3, 'g+', DataMarker3.MVGantryAngle, DataMarker3.z3, 'r+', 'linewidth', 6)    
    hold off
  %  xlabel('Time (s)', 'fontsize', 16)
  %  xlabel('MV Gantry Angle (^\circ)', 'fontsize', 16)
    xlabel('kV Frame No','fontsize',16)
    ylabel('Position (mm)', 'fontsize', 16')
    title('Marker3', 'fontsize', 16)
    legend('LR (TRI)', 'SI (TRI)', 'AP (TRI)', 'LR (KIM)', 'SI (KIM)', 'AP (KIM)', 'location', 'northeastoutside')
    set(gca,'fontsize',16)
end

% Save all figures in png format

pngMarker1 = [outputPath '\' num2str(pat) num2str(fx) 'Marker1_GA'];
print(figure(1), '-dpng', pngMarker1)

pngMarker2 = [outputPath '\' num2str(pat) num2str(fx) 'Marker2_GA'];
print(figure(2), '-dpng', pngMarker2)

pngMarker3 = [outputPath '\' num2str(pat) num2str(fx) 'Marker3_GA'];
print(figure(3), '-dpng', pngMarker3)

end


function [targetpos, deltaYp2] = triangulateForKIM(angle1,xp1,yp1,angle2,xp2,yp2)
% xp and yp are in pixels
MVSDD = 1.8; % in meters
kVSDD = 1.8; % in meters

MVPixelSizeAtIso = 0.392; % in mm
kVPixelSizeAtIso = 0.388; % in mm

% Do the appropriate transformations for xp and yp
xp1 = (xp1 - 512)*MVPixelSizeAtIso/MVSDD;
yp1 = -(yp1 - 384)*MVPixelSizeAtIso/MVSDD;

xp2 = (xp2 - 512)*kVPixelSizeAtIso/kVSDD;
yp2 = -(yp2 - 384)*kVPixelSizeAtIso/kVSDD;

[targetpos, deltaYp2] = triangulate(angle1,xp1,yp1,angle2,xp2,yp2);


end

function [targetpos, deltaYp2] = triangulate(angle1,xp1,yp1,angle2,xp2,yp2)

% Input  = View angle and projected position for first and last image (1&2)
% Output = Target position in patient coordinates and y-motion deltaYp
% between image 1 and 2 projected onto image 2.
%******************************************************************
% The central axis of two imagers are assumed to be in the axial plane
% (as is the case for two coplanar images at different gantry angles).
% Therefore, triangulation does not need both yp1 and yp2 if the target
% is static (and if the imagers are perfect pinhole cameras without noise).
% This function uses yp2 (assumed to be the most recent acquisition) for
% the triangulation and then calculates the apparent y-motion from yp1 to
% yp2. This motion might be used to estimate the unresolved motion along the
% view axis of imager2 using a model that estimates the unresolved motion
% from the resolved motion.
% Changing the input yp1 does not change the output targetpos (but it
% changes output deltaYp2).
% See description of the calculations elsewhere (Per R Poulsen notes)


SAD = 1000;

% Determine the rotation matrix that links imager 0 and 1:

cosAngleDiff = cosd(angle2-angle1);
sinAngleDiff = sind(angle2-angle1);

rotMatrix = [cosAngleDiff 0 -sinAngleDiff
                  0       1       0   
             sinAngleDiff 0 cosAngleDiff];
              
% Determine the translation vector that links imager 1 and 2. The vector 
% specifies the focus of imager1 in the coordinate system of imager2

transVector = [-SAD*sinAngleDiff 0 SAD*(1-cosAngleDiff)];

% A point r1 in the coordinate system of imager1 has the following
% coordinates in the system of imager2: rotMatrix*(r1-transVector)

% Reconstruct:

%find the unresolved component zp2 in coordinate system 2:
rotrow1 = rotMatrix(1,:)';
rotrow3 = rotMatrix(3,:)';
y = [xp2 yp2 SAD]';

zp2 = SAD - SAD*dot(SAD*rotrow1-xp1*rotrow3,transVector)/dot(SAD*rotrow1-xp1*rotrow3,y);

% backproject/scale point from imager 2 coordinates to patient coordinates:
targetpos = backproject(angle2,[xp2 yp2 zp2]);

% Determine shift in yp2 from image1 to image2
zp1 = sind(angle1)*targetpos(1) + cosd(angle1)*targetpos(3);

% backproject/scale point from imager 1 coordinates to patient coordinates:
targetpos1 = backproject(angle1,[xp1, yp1, zp1]);

targetpos = (targetpos + targetpos1)/2;


deltaYp2 = yp2 - (SAD - zp1)/(SAD - zp2)*yp1;

end

function [BackProjectedPoint] = backproject(angle,ProjectedPoint) % point = (x,y,z)
% project.m
% Transforms point from imager coordinates (xp,yp,zp) to patient
% coordinates.
% an imager placed at the specified angle relative to vertical.
% The tranformation consists or a backprojection followed by a rotation
% *********************************************************************** %

% Per Poulsen, June 2010

% Variables that need only be assigned at the first call of this function
persistent previousAngle BackRotationMatrix

if isempty(previousAngle) || ~isequal(previousAngle,angle)  
    previousAngle = angle;
    cosAngle = cosd(angle);
    sinAngle = sind(angle);
    BackRotationMatrix = [cosAngle 0 sinAngle
                             0     1     0   
                         -sinAngle 0  cosAngle];
end
scaleFactor =  (1000-ProjectedPoint(3))/1000;  % SAD = 1000 mm
BackProjectedPoint = BackRotationMatrix*[ProjectedPoint(1)*scaleFactor ProjectedPoint(2)*scaleFactor ProjectedPoint(3)]';
    
end





function printData(filename, Data)
% If the file exists, delete it, to prevent further appendings
if exist(filename, 'file') == 2
    delete(filename)
end

% Write the header first
fid = fopen(filename, 'w');
fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\r', ...
    'MVFrameNo', 'MVFilename', 'MVWindowsTimestamps', 'MVGantryAngle', 'MVxp', 'MVyp', 'MVbutton', 'MVxpCalib', 'MVypCalib', ...
    'kVFrameNo', 'kVFilename', 'kVWindowsTimestamps', 'kVSourceAngle', ...
    'xp1', 'yp1', 'xp2', 'yp2', 'xp3', 'yp3', ...
    'x1', 'y1', 'z1', 'x2', 'y2', 'z2', 'x3', 'y3', 'z3', ... 
    'timeDiff');
fclose(fid);

% Then write the data
M = [Data.MVFrameNo Data.MVFilename Data.MVWindowsTimestamps, Data.MVGantryAngle, ...
    Data.MVxp, Data.MVyp, Data.MVbutton, Data.MVxpCalib, Data.MVypCalib, ...
    Data.kVFrameNo, Data.kVFilename, Data.kVWindowsTimestamps, Data.kVSourceAngle, ...
    Data.xp1, Data.yp1, Data.xp2, Data.yp2, Data.xp3, Data.yp3, ...
    Data.x1, Data.y1, Data.z1, Data.x2, Data.y2, Data.z2, Data.x3, Data.y3, Data.z3, ...
    Data.timeDiff];

dlmwrite(filename, M, 'delimiter', '\t', '-append')

end

function Data = extractData(Data)
indexToUse = find(Data.MVbutton == 1);

listOfFields = fieldnames(Data);
noOfFields = numel(listOfFields);

for n = 1:noOfFields
    vector = Data.(listOfFields{n});

    Data.(listOfFields{n}) = vector(indexToUse);
    
end
end


function Data = applyMVCalib(MVOffsetsX,MVOffsetsY, Data)

MVGantryVarian = MVIECToMVVarian(Data.MVGantryAngle);


MVxpOffset= (MVOffsetsX(1) + MVOffsetsX(2)*sind(MVGantryVarian + MVOffsetsX(3)));
MVypOffset = (MVOffsetsY(1) + MVOffsetsY(2)*sind(MVGantryVarian + MVOffsetsY(3)));

Data.MVxpCalib = Data.MVxp - MVxpOffset;
Data.MVypCalib = Data.MVyp - MVypOffset;

end

function MVGantryVarian = MVIECToMVVarian(MVGantryIEC)

%Converts from MV IEC to MV VARIAN coordinates (PA = 0, AP = 180,
%CCW direction is positive)

noOfImages = size(MVGantryIEC,1);

MVGantryVarian = zeros(noOfImages,1);

for n = 1:noOfImages;
    
    if MVGantryIEC(n) <= 180
        MVGantryVarian(n) = 180 - MVGantryIEC(n);
    else
        MVGantryVarian(n) = 540 - MVGantryIEC(n);
    end
    
end


end


function printFinalData(filename, Data)
% If the file exists, delete it, to prevent further appendings
if exist(filename, 'file') == 2
    delete(filename)
end

% Write the header first
fid = fopen(filename, 'w');
             
fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\r', ...
    'MVFrameNo', 'MVFilename', 'MVWindowsTimestamps', 'MVGantryAngle', 'MVxp', 'MVyp', 'MVbutton', 'MVxpCalib', 'MVypCalib', ...
    'kVFrameNo', 'kVFilename', 'kVWindowsTimestamps', 'kVSourceAngle', ...
    'xp1', 'yp1', 'xp2', 'yp2', 'xp3', 'yp3', ...
    'x1', 'y1', 'z1', 'x2', 'y2', 'z2', 'x3', 'y3', 'z3', ... 
    'timeDiff', ...
    'TriX1', 'TriY1', 'TriZ1', 'TriX2', 'TriY2', 'TriZ2', 'TriX3', 'TriY3', 'TriZ3',...
    'VecDiff1', 'VecDiff2', 'VecDiff3', 'MarkerNo');
fclose(fid);
%check if the lengths of arrays are the same
%if length(Data.MVFrameNo) ~= length(Data.TriX1)

% Then write the data
M = [Data.MVFrameNo Data.MVFilename Data.MVWindowsTimestamps, Data.MVGantryAngle, ...
    Data.MVxp, Data.MVyp, Data.MVbutton, Data.MVxpCalib, Data.MVypCalib, ...
    Data.kVFrameNo, Data.kVFilename, Data.kVWindowsTimestamps, Data.kVSourceAngle, ...
    Data.xp1, Data.yp1, Data.xp2, Data.yp2, Data.xp3, Data.yp3, ...
    Data.x1, Data.y1, Data.z1, Data.x2, Data.y2, Data.z2, Data.x3, Data.y3, Data.z3, ...
    Data.timeDiff, ...
    Data.TriX1', Data.TriY1', Data.TriZ1', Data.TriX2', Data.TriY2', Data.TriZ2', Data.TriX3', Data.TriY3', Data.TriZ3', ...
    Data.VecDiff1' Data.VecDiff2' Data.VecDiff3' Data.MarkerNo'];

dlmwrite(filename, M, 'delimiter', '\t', '-append')

end
function [header, AutoData2] = combine_Auto_Man_Segmentation(outputPath) 

% This function combines the results from using auto-segmentation
% algorithm and manual segmentation. 
% The rules for consolidating the results are:
% 1. If the same number of segmentation measurements is available in
% between auto- and manual-segmentation for the given frame, then replace
% auto-segmentation results with manual-segmentation;
% 2. Measurements are deleted in following instances:   
%   (i) auto- and manual-segmentation contain different number of
%   measurements; --> Hard to identify which segmentation measurements are
%   correct ones;
%   (ii) MVbutton==1 in manual-segmentation (left-clicked); In case
%   MVbutton==3 (right-clicked) then the corresponding measurements are deleted.
% It produces a plot showing the original auto- (blue) and
% manual-segmentation (black), as well as the combined (red) => where black
% symbols are available, the red should be overlaid on the black; where
% black symbols are not available, the red should be overlaid on the blue;
% where the numbers of black and blue symbols at given frame are different,the red should not be present; 
% even if the condition is met, red is not present if MVbutton was set to '3'. 
% Written by J Kim - 04/05/2017 

[header, AutoData] = readMVMarkerPositions([outputPath '\' 'AutoMVMarkerPositions.xls']);
[header, ManData] = readMVMarkerPositions([outputPath '\' 'MVMarkerPositions.xls']);
AutoFrames = AutoData{1,1};
ManFrames = ManData{1,1};

AutoMVButton = AutoData{1,7};
ManMVButton = ManData{1,7};

uAuto = unique(AutoFrames);
uMan = unique(ManFrames);
AutoData2 = AutoData;


for j=1:length(uMan)
    if find(ismember(uMan(j), uAuto) == 1)
        if length(find(AutoFrames == uMan(j))) == length(find(ManFrames == uMan(j)))
            AutoDataIndex = find(AutoFrames == uMan(j));
            ManDataIndex = find(ManFrames == uMan(j));
            for k=1:length(AutoDataIndex)
                if ManMVButton(ManDataIndex(k)) == 3
                    disp('delete measurement')
                    for i=1:length(AutoData)
                        AutoData2{i}(AutoDataIndex(k)) = NaN;
                    end
                elseif ManMVButton(ManDataIndex(k)) == 1
                    disp('replace measurement')
                    for i=1:length(AutoData)
                        AutoData2{i}(AutoDataIndex(k)) = ManData{i}(ManDataIndex(k));
                    end
                end
            end
        else %when different numbers of measurements are present in auto- and manual-segmentation for the frame
            AutoDataIndex = find(AutoFrames == uMan(j));
            ManDataIndex = find(ManFrames == uMan(j));
            numManDat = length(ManDataIndex);
            disp('delete measurement')
            for i=1:length(AutoData)
                for k=1:length(AutoDataIndex)
                    AutoData2{i}(AutoDataIndex(k)) = NaN;
                end
            end
        end
    end
end

for i = 1:length(AutoData2)
    AutoData2{i} = AutoData2{i}(~isnan(AutoData2{i}(:,1)),:) ;
end

figure (4); subplot(2,1,1); plot(AutoData{1},AutoData{5},'b*')
hold on; plot(ManData{1},ManData{5},'k*')
hold on; plot(AutoData2{1},AutoData2{5},'r+')
title('Xp from Combining Auto and Manual segmentation results')
legend('Auto-segmentation','Maunal segmentation','Combined Auto+Manual segmetation')
xlabel('Frame No')
ylabel('Pixel Number')

subplot(2,1,2); hold on; plot(AutoData{1},AutoData{6},'b*');box on;
hold on; plot(ManData{1},ManData{6},'k*')
hold on; plot(AutoData2{1},AutoData2{6},'r+')
title('Yp from Combining Auto and Manual segmentation results')
%legend('Auto-segmentation','Maunal segmentation','Combined Auto+Manual segmetation')
xlabel('Frame No')
ylabel('Pixel Number')
end

