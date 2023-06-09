function Triangulation_Part1
xx
% Triangulation_Part1 MV marker segmentation
% Run Triangulation_Part1
%
% This function creates two output files that are used in Triangulation_Part2.m
% 1. MVMarkerPositions.xls
% 2. AutoMVMarkerPositions.xls
%
% File 1 records the frames with manual user segmentation
% File 2 records the frames with automarker segmentation
%
% Where the auto segmetation (green crosses on MV image) seems incorrect -
% User can manually segment *** NOTE: All three markers need to be
% segmented.
%

clear
clc
close all


%----- INPUT ----%
CreateMVandkKVTimeStampsFromCSharp = 'YES'; %Create timetamps for kV and MV from Csharp code - saves time if already created.
DisplayImage = 'YES';
%----------------%

imThresh1 = 0.82; %For autoMV segmentation: choose values [0 1] where autosegmentation performance is poor.
imThresh2 = 0.8; %For MV image appearance: choose values [0 1] where higher values make the image appear darker
CSharpCodePath = '\getkvandmvtimestamps\getkvandmvtimestamps\bin\Release\';
pickA=50;
pickB=100;

%%% For patient folder%%%%%%%%%%%%
pat = 'PAT01';
fx  = 'Fx01';
OLdata = 1;
fxPath = strcat('Patient Images\', pat, '\', fx);
outputPath = strcat('Output\', pat, '\', fx);

StartNbr = 10;
SlicePerTri = 3;
extraImgsOffset = 0;
offset = extraImgsOffset;

% InputsResults')
mkdir(outputPath);
cd (outputPath)

% Adds VarianReader.jar to enable ClassMVFrameGrabber
pth = which('VarianReader.jar');
javaaddpath((pth));
global outputPath;
global MVFolder;

frameAverage = 1; % MVFrame average used for KIM fraction

list = ls(fxPath);

if (strcmp(strtrim(list(4,1:2)), 'CH') == 1)
    MVFolder = [fxPath '\CH0\'];
    kVFolder = [fxPath '\CH1\'];
else
    MVFolder = [fxPath '\KIM-MV\']; %'\CH0\'
    kVFolder = [fxPath '\KIM-KV\']; %'\CH1\'
end

% Field size (in mm)
kVFieldsize.X = 60;
kVFieldsize.Y = 60;

% Angle more than which there is no kV view. MV goes from 250 to 110 (clockwise). kV
% goes from 160 to 20 (clockwise)
nokVViewAngle1 = 20; %50; %20 for patient
nokVViewAngle2 = -130;

% 0. Adjust field size
linacData = getLinacData;
[xStartkV, xEndkV, yStartkV, yEndkV] = adjustFieldOfView(linacData, kVFieldsize, 'kV');
[xStartMV, xEndMV, yStartMV, yEndMV] = adjustFieldOfView(linacData, kVFieldsize, 'MV');

% 1. Obtain time Windows timestamps (using C#) for kV and MV images and
% output to text files
if strcmp(CreateMVandkKVTimeStampsFromCSharp, 'YES')
    dos([CSharpCodePath 'getkVAndMVTimestamps.exe' ' ' '"' fxPath '"' ' "' outputPath '"']);   
elseif strcmp(CreateMVandkKVTimeStampsFromCSharp, 'NO')
    disp('kV and MV timestamps being re-used from previous simulation')
end

% 2. Load the MV and kV data from the C# text files

[MVData kVCSharpData] = readCSharpData(outputPath);
%kVCSharpData.Timestamps = kVCSharpData.Timestamps(301:end);
%kVCSharpData.kVFrameNo = kVCSharpData.kVFrameNo(301:end)-kVCSharpData.kVFrameNo(300);

% 3. Read and load the KIM trajectory file
kVData = readKIMData(kVFolder,frameAverage, OLdata);

% 4. Combine the filename and timestamps from C# to kVData by matching the kVFrameNo
if 2>3
    if (length(kVData.kVFrameNo)-1)*frameAverage == kVData.kVFrameNo(end)
        if abs(length(kVCSharpData.kVFrameNo)- length(kVData.kVFrameNo)) > frameAverage
            droppedframes = abs(length(kVCSharpData.kVFrameNo)- kVData.kVFrameNo(end));
            fprintf('%d of kV frames are not recorded as KIM data \n', droppedframes)
            disp('Backwards Synchronise')
            for n=1:length(kVData.kVFrameNo)
                kVData.kVFrameNo(n) = kVData.kVFrameNo(n)+droppedframes;
            end
            %kVData.kVFrameNo = kVData.kVFrameNo'
        end
    end
end

numKIMData = size(kVData.kVFrameNo,1)*frameAverage;
numkVImgs  = size(kVCSharpData.kVFrameNo,1);

d_numDat = (numKIMData-numkVImgs);
%if numKIMData ~= numkVImgs
if 2>3
    %if d_numDat > 0
    %    disp('Missing kV images (more KIM data than images saved)')
    if abs(d_numDat) <= frameAverage
        disp('Number of KIM data matches with number of kV images')
        offset =0;
    elseif abs(d_numDat) > frameAverage
        disp('Number of kV images are different to KIM data points')
        GA1 = kVData.kVSourceAngle(pickA:pickB);
        [kVs2 GA2 TS2 FN2] = ReadDisplayHNDs2(kVFolder,0,pickA, pickB);
        intervalGA = (GA1(end)-GA1(1))/length(GA2);
        dd_GA = mean(GA1-GA2);
        offset = round(dd_GA/intervalGA)-1;
    end
end

if offset < 0
    kVCSharpData.kVFilename = kVCSharpData.kVFilename(abs(offset):end);
    kVCSharpData.kVFrameNo = kVCSharpData.kVFrameNo(abs(offset):end) - (abs(offset)-1);
    kVCSharpData.Timestamps = kVCSharpData.Timestamps(abs(offset):end);
    %     FrameNoIndex = FrameNoIndex(abs(offset):end);
end

j = 1;
 for n = 1:length(kVData.kVFrameNo)
    if (kVData.kVFrameNo(n)<=max(kVCSharpData.kVFrameNo))
      FrameNoIndex(n) = find(ismember(kVCSharpData.kVFilename, kVData.kVFilename(n,:),'rows'));
    end
 end


if offset >=0
    kVData.kVFilename = kVCSharpData.kVFilename(FrameNoIndex+offset,2);
    kVData.WindowsTimestamps = kVCSharpData.Timestamps(FrameNoIndex+offset);
    kVData.kVFrameNo = kVCSharpData.kVFrameNo(FrameNoIndex+offset);
    KIMFrame = kVData.kVFrameNo;
save(strcat(outputPath,'\',pat,fx,'.mat'),'KIMFrame');
elseif offset <0
    
    kVData.kVFilename = kVCSharpData.kVFilename(FrameNoIndex);
    kVData.WindowsTimestamps = kVCSharpData.Timestamps(FrameNoIndex);
end

% 5. Find the kV timestamps which match each MV timestamp the closest

for n = 1:size(MVData.WindowsTimestamps,1)
    timeDiff = abs(MVData.WindowsTimestamps(n) - kVData.WindowsTimestamps);
    % This is the list of indices for which the kV timestamps are closest to
    % each MV timestamp
    indexOfMatch = find(timeDiff == min(timeDiff));
    indexOfMatches(n) = indexOfMatch(round(length(indexOfMatch)/2));
    listOfTimeDiff(n) = min(timeDiff);
end
GoodSyncIndex = find(listOfTimeDiff < 0.1); %2 times of the sampling rate (10 Hz) %index of MV
indexOfMatches = indexOfMatches(GoodSyncIndex); %index of kV
%BadSyncIndex  = find(listOfTimeDiff >= 0.2)

figure
plot(MVData.WindowsTimestamps,'*')
hold on
plot(FrameNoIndex,kVData.WindowsTimestamps,'linewidth',2)
syncedkV = kVData.WindowsTimestamps(indexOfMatches);
plot(syncedkV,'linewidth',2)
aa = legend('MV Timestamps','kVTimestamps','Synced kV');
set(aa,'fontsize',12)
ylabel('Time Stamps (s)','fontsize',15)
xlabel('Frame Number','fontsize',15)

figure
plot(listOfTimeDiff,'*')
title('Time Differences in synchronised kV/MV','fontsize',15)
xlabel('Frame Number','fontsize',15)
ylabel('Time differences (s)','fontsize',15)

%%%indexOfMatches = indexOfMatches-4;
kVData = extractData(indexOfMatches, kVData);
MVData = extractData(GoodSyncIndex, MVData);
listOfTimeDiff = listOfTimeDiff(GoodSyncIndex);

figure
plot(listOfTimeDiff,'*')
title('Time Differences in synchronised kV/MV','fontsize',15)
xlabel('Frame Number','fontsize',15)
ylabel('Time differences (s)','fontsize',15)

% 6. Generate the MV gantry angles from the kV source angles

MVData.MVGantryAngle = kVData.kVSourceAngle + 90;

%%%
% figure(1); plot(MVData.MVGantryAngle)
% hold on
% plot(kVData.kVSourceAngle, 'r')
% hold off
%%%

% 7. Before segmenting the MV images, assign zero to the x and y coordinates
MVData.xp = zeros(length(MVData.MVFrameNo),1);
MVData.yp = zeros(length(MVData.MVFrameNo),1);
MVData.button = zeros(length(MVData.MVFrameNo),1);

% 8. Output all data as a check
printData([outputPath '\Part1Step8Check.xls'], MVData, kVData, listOfTimeDiff);

% 10. Output a messagebox for instructions for the user
h = msgbox({'(Enter) Check green crosses are on top of MV markers'; '(a) Correctly segmented markers - Go to next image';  '(s + Left-Click)  Incorrect segmentation - manually segment all three markers'; '(s + Right-Click) where auto-segmenation is wrong but cannot manually segment markers'});
set(h, 'Position', [700 30 250 80])

% 11. Output MVMarkerPositions.xls
filename = [outputPath '\MVMarkerPositions.xls']

if exist(filename, 'file') == 2
    % If the file exists, open the file in append mode and proceed to segmentation
    fid = fopen(filename, 'a');
else
    % If the file doesn't exist write header then proceed to segmentation
    fid = fopen(filename, 'w');
    writeMVMarkerPositionsXLSHeader(filename, fid)
end

%12. Output AutoSegmentation Restuls
filename2 = [outputPath '\AutoMVMarkerPositions.xls']

if exist(filename2, 'file') == 2
    % If the file exists, open the file in append mode and proceed to segmentation
    fid2 = fopen(filename2, 'a');
else
    % If the file doesn't exist write header then proceed to segmentation
    fid2 = fopen(filename2, 'w');
    writeAutoMVMarkerPositionsXLSHeader(filename2, fid2)
end

% 8. Commence MV segmentation
list = dir([MVFolder '\*hnd']);

%numMV= size(list,1);
numMV = length(MVData.MVFrameNo);
numkV = length(kVData.kVFrameNo);
isoCalib = zeros(ceil(length(GoodSyncIndex)/SlicePerTri), 3);

%% Find where different MV frames were synced to one kV frame (due to frame average)
[C, ia, idx] = unique(indexOfMatches,'stable');

for n = StartNbr:SlicePerTri:numMV-SlicePerTri
    
    if frameAverage > 1 %Change back to frameAverage > 1
        MVFrames = zeros(768,1024,SlicePerTri);
        MVFilenames = zeros(SlicePerTri,1);
        % 8.1 Load MV images
        if ~isempty(MVFolder)
            MVFramegrabber  = ClassFrameGrabber(MVFolder);
            if ~isempty(MVFramegrabber)
                for i=1:3%SlicePerTri
                    [MVFrames(:,:,i), MVGantry, MVTimestamp, MVFilename] = MVFramegrabber.getVarianNo(MVData.MVFrameNo(n)+i-2);
                    MVFilenames(i) = sscanf(MVFilename, 'Ch0_%*f_%u')';
                end
            end
        end
        
    elseif frameAverage == 1 
        
        % 8.1 Load MV images
        if ~isempty(MVFolder)
            MVFramegrabber  = ClassFrameGrabber(MVFolder);
            if ~isempty(MVFramegrabber)
                for i=1:3
                    [MVFrames(:,:,i), MVGantry, MVTimestamp, MVFilename] = MVFramegrabber.getVarianNo(MVData.MVFrameNo(n)+i-2);
                    MVFilenames(i) = sscanf(MVFilename, 'Ch0_%*f_%u');
                end
            end
        end
    end
    
    % Get average MV frame (Moving average)
    MVFrame = mean(MVFrames,3);
    MVFilename = median(MVFilenames);
    
    % 8.2 Find the kV Image with the closest angle to the current MV image
    angleDiff = MVData.MVGantryAngle(n) - kVData.kVSourceAngle;
    angleDiff = abs(angleDiff);
    indexOfClosestAngle = find(angleDiff == min(angleDiff),1);
    % Gantry goes from 250 to 110 during treatment. kVSource angle only
    % extends up to 20deg. For gantry angles 20<x<110, use the 180 deg
    % opposite image (and flip it)    
    if MVData.MVGantryAngle(n) > nokVViewAngle1
        oppositeGantryAngle = MVData.MVGantryAngle(n) - 180;
        angleDiff = oppositeGantryAngle - kVData.kVSourceAngle;
        angleDiff = abs(angleDiff);
        indexOfClosestAngle = find(angleDiff == min(angleDiff),1);
    end
    
    if 3<2
        if ~isempty(kVFolder)
            kVFramegrabber  = ClassFrameGrabber(kVFolder);
            if ~isempty(kVFramegrabber)
                [kVFrame, kVGantry, kVTimestamp, kVFilename] = kVFramegrabber.getVarianNo(kVData.kVFrameNo(indexOfClosestAngle));
                kVFilename = sscanf(kVFilename, 'Ch1_%*f_%u');
            end
        end
    else
        if ~isempty(kVFolder)
            kVFramegrabber  = ClassFrameGrabber(kVFolder);
            if ~isempty(kVFramegrabber)
                 [kVFrame, kVGantry, kVTimestamp, kVFilename] = kVFramegrabber.getVarianNo(kVData.kVFrameNo(n));%-extraImgsOffset);
                kVFilename = sscanf(kVFilename, 'Ch1_%*f_%u');
                [kVFrame2, kVGantry2, kVTimestamp2, kVFilename2] = kVFramegrabber.getVarianNo(kVData.kVFrameNo(indexOfClosestAngle));%-extraImgsOffset);
                kVFilename2 = sscanf(kVFilename2, 'Ch1_%*f_%u');
                
            end
        end
    end
    
    kVFrame = 1-kVFrame;
 
    if MVData.MVGantryAngle(n) > nokVViewAngle1
        disp('kV Frame2 flip in LR');
        kVFrame2 = fliplr(kVFrame2);
        xp11 = 2*linacData.XCenterPixel-kVData.xp1(indexOfClosestAngle); yp11 = kVData.yp1(indexOfClosestAngle);
        xp22 = 2*linacData.XCenterPixel-kVData.xp2(indexOfClosestAngle); yp22 = kVData.yp2(indexOfClosestAngle);
        xp33 = 2*linacData.XCenterPixel-kVData.xp3(indexOfClosestAngle); yp33 = kVData.yp3(indexOfClosestAngle);
    else
        xp11 = kVData.xp1(indexOfClosestAngle); yp11 = kVData.yp1(indexOfClosestAngle);
        xp22 = kVData.xp2(indexOfClosestAngle); yp22 = kVData.yp2(indexOfClosestAngle);
        xp33 = kVData.xp3(indexOfClosestAngle); yp33 = kVData.yp3(indexOfClosestAngle);
    end
    
    %Artificially adjust synchronisation - Only use this where there is
    %clear error in marker arrangement from MV and KV images
    
    %% Project the KIM position onto the MV image
    point1 = [kVData.x1(n) kVData.y1(n) kVData.z1(n)];
    point2 = [kVData.x2(n) kVData.y2(n) kVData.z2(n)];
    point3 = [kVData.x3(n) kVData.y3(n) kVData.z3(n)];
    proj = projectForMV(MVData.MVGantryAngle(n), point1, point2, point3);
    estMarker = [proj.yp1, proj.xp1;
        proj.yp2, proj.xp2;
        proj.yp3, proj.xp3]; 
    
    kVproj = projectForKIMwtkVOffset(kVData.kVSourceAngle(n), point1, point2, point3);
    xp1 = kVData.xp1(n); yp1 = kVData.yp1(n);
    xp2 = kVData.xp2(n); yp2 = kVData.yp2(n);
    xp3 = kVData.xp3(n); yp3 = kVData.yp3(n);
    pxp = [kVproj.xp1 - xStartkV + 1, kVproj.xp2 - xStartkV + 1, kVproj.xp3 - xStartkV + 1];
    pyp = [kVproj.yp1 - yStartkV + 1, kVproj.yp2 - yStartkV + 1, kVproj.yp3 - yStartkV + 1];
    
    zoomedMVFrame=MVFrame(yStartMV:yEndMV, xStartMV:xEndMV);
    
    
    %% Apply percentage intensity threshold (imThresh2)
    thresh = min(zoomedMVFrame(:))+((max(zoomedMVFrame(:))-min(zoomedMVFrame(:)))*imThresh2);
    zoomedMVFrame(find(zoomedMVFrame < thresh)) = thresh;
    
    %% MV auto-segmentation (O's code from NewCastle)
    estMarker = [estMarker(:,1)-yStartMV+1, estMarker(:,2)-xStartMV+1];
    autoPosition = MVforKim(zoomedMVFrame, 3, estMarker, 180, imThresh1); %3 is number of markers; 180 is SAD in cm
    
    % Adjust field of view for the kV images
    zoomedkVFrame=kVFrame(yStartkV:yEndkV, xStartkV:xEndkV);
    zoomedkVFrame2=kVFrame2(yStartkV:yEndkV, xStartkV:xEndkV);
    
    % If all markers are blocked by the leaves, skip to the next image
    meanPixVals  = findMeanPixelValues(xStartMV, yStartMV, zoomedMVFrame, proj, 11);
    disp([n meanPixVals])
    pixThreshold = min(zoomedMVFrame(:))*1; %1.025; % 25% pix value of the minimum
    lgc = (meanPixVals < pixThreshold);
    
    % Branch A: Number of markers blocked by MLC (skip image)
    if  sum(lgc) >= 1  %sum(lgc) >=3 % if sum(lgc) >= 1: At least one marker is blocked by MLC --> Find frame only when all three markers are present
        if strcmp(DisplayImage, 'YES')
            h3 = figure(9);
            colormap gray
            imagesc(zoomedMVFrame);
            grid on
            title({'MV', ['Frame/Filename/Gantry = ' num2str(MVData.MVFrameNo(n)) '/' num2str(MVData.MVFilename(n)) '/' num2str(MVData.MVGantryAngle(n)) ], [' SKIPPED']})
            colorbar
            set(h3, 'Position', [655 150 700 600])
            % Plot the projected positions
            hold on
            plot(proj.xp1 - xStartMV + 1, proj.yp1 - yStartMV + 1, 'b+', proj.xp2 - xStartMV + 1, proj.yp2 - yStartMV + 1, 'b+', proj.xp3 - xStartMV + 1, proj.yp3 - yStartMV + 1, 'b+', 'linewidth', 2)
            hold off
            legend('Projected 3D KIM position')
            
            h2 = figure(8);
            colormap gray
            imagesc(zoomedkVFrame)
            grid on
            
            % Plot the projected positions
            hold on
            plot(pxp, pyp, 'b+', 'linewidth', 2)
            plot(xp1 - xStartkV + 1, yp1 - yStartkV + 1, 'r+', xp2 - xStartkV + 1, yp2 - yStartkV + 1, 'r+', xp3 - xStartkV + 1, yp3 - yStartkV + 1, 'r+', 'linewidth', 2)
            hold off
            legend('Projected 3D KIM position', '2D KIM position')
            
            title({'Synced kV', ['Frame/Filename/kVSourceAngle = ' num2str(kVData.kVFrameNo(n)) '/' num2str(kVData.kVFilename(n)) '/' num2str(kVData.kVSourceAngle(n)) ]})
            colorbar
            set(h2, 'Position', [-15 150 700 600])
        end
        pause(0.01)
        continue
    end
    
    % Branch B: Number of markers are present in treatment field (segment)
    h2 = figure(8);
    colormap gray
    if strcmp(DisplayImage, 'YES')
        imagesc(zoomedkVFrame)
    end
    grid on
    
    % Plot the projected positions
    hold on
    plot(pxp, pyp, 'b+', 'linewidth', 2)
    plot(xp1 - xStartkV + 1, yp1 - yStartkV + 1, 'r+', xp2 - xStartkV + 1, yp2 - yStartkV + 1, 'r+', xp3 - xStartkV + 1, yp3 - yStartkV + 1, 'r+', 'linewidth', 2)
    hold off
    legend('Projected 3D KIM position', '2D KIM position')
    
    title({'Synced kV', ['Frame/Filename/kVSourceAngle = ' num2str(kVData.kVFrameNo(n)) '/' num2str(kVData.kVFilename(n)) '/' num2str(kVData.kVSourceAngle(n)) ]})
    colorbar
    set(h2, 'Position', [-15 150 700 600])
    
    if 2>3
        % Display markers on kV image at the same gantry angle as shown MV
        % Redundant: To verify synchronisation by comparing the marker orientation)
        h1 = figure(7);
        colormap gray
        imagesc(zoomedkVFrame2)
        grid on
        
        ppxp = [xp11 - xStartkV + 1, xp22 - xStartkV + 1, xp33 - xStartkV + 1];
        ppyp = [yp11 - yStartkV + 1, yp22 - yStartkV + 1, yp33 - yStartkV + 1];
        
        %% Create template
        minX = min(ppxp); maxX = max(ppxp); minY = min(ppyp); maxY = max(ppyp);
        
        hold on
        plot(ppxp, ppyp, 'r+')
        hold off
        title({'kV @ same GA', ['Frame/Filename/kVSourceAngle = ' num2str(kVData.kVFrameNo(indexOfClosestAngle)) '/' num2str(kVData.kVFilename(indexOfClosestAngle)) '/' num2str(kVData.kVSourceAngle(indexOfClosestAngle)) ]})
        colorbar
        set(h1, 'Position', [380 100 300 250])
    end
    
    h3 = figure(9);
    colormap gray
    if 2<3
        I2 = im2double(zoomedMVFrame);
        m = mean2(I2);
        contrast = 1./(1+(m./(I2+eps)).^10);
        if strcmp(DisplayImage, 'YES')
            
            imagesc(contrast)
        end
    end
    if strcmp(DisplayImage, 'YES')        
        imagesc(zoomedMVFrame)
    end
    grid on
    title({'MV', ['Frame/Filename/Gantry = ' num2str(MVData.MVFrameNo(n)) '/' num2str(MVData.MVFilename(n)) '/' num2str(MVData.MVGantryAngle(n))] })
    colorbar
    set(h3, 'Position', [635 150 700 600])
    MVppxp = [proj.xp1 - xStartMV + 1, proj.xp2 - xStartMV + 1, proj.xp3 - xStartMV + 1];
    MVppyp = [proj.yp1 - yStartMV + 1, proj.yp2 - yStartMV + 1, proj.yp3 - yStartMV + 1];
    
    % Plot the projected positions
    hold on
    %Redundant info - Display KIM position at 90deg later
    %plot(MVppxp, MVppyp, 'b.', 'linewidth', 2)
    %plot(xp11 - xStartMV + 1, yp11 - yStartMV + 1, 'r.', xp22 - xStartMV + 1, yp22 - yStartMV + 1, 'r.', xp33 - xStartMV + 1, yp33 - yStartMV + 1, 'r.')
    %plot(autoPosition(1,2)-xStartMV + 1,autoPosition(1,1)-yStartMV+1,'g+')
    %plot(autoPosition(2,2)-xStartMV + 1,autoPosition(2,1)-yStartMV+1,'g+')
    %plot(autoPosition(3,2)-xStartMV + 1,autoPosition(3,1)-yStartMV+1,'g+')
    %hold off
    %legend('Projected 3D KIM position', '2D KIM position at the same gantry angle (90degs later)', 'Automatic MV segmentation')
    
    % Plot the projected positions
    plot(MVppxp, MVppyp, 'b.', 'linewidth', 2)
    %plot(autoPosition(1,2)-xStartMV + 1,autoPosition(1,1)-yStartMV+1,'g+')
    %plot(autoPosition(2,2)-xStartMV + 1,autoPosition(2,1)-yStartMV+1,'g+')
    %plot(autoPosition(3,2)-xStartMV + 1,autoPosition(3,1)-yStartMV+1,'g+')
    plot(autoPosition(1,2),autoPosition(1,1),'g+')
    plot(autoPosition(2,2),autoPosition(2,1),'g+')
    plot(autoPosition(3,2),autoPosition(3,1),'g+')
    
    hold off
    legend('Projected 3D KIM position', 'Automatic MV segmentation')
    
    
    aaa = [xp1-xStartkV+1 xp2-xStartkV+1 xp3-xStartkV+1];
    bbb = [yp1-yStartkV+1 yp2-yStartkV+1 yp3-yStartkV+1];
    
    %*****************************************************************
    % Wait for the user to press the appropriate button
    if 1
        w=0;
        while (w==0) || (w==1)
        %    disp('Press onto the picture to segmentate the beacons')
            w = waitforbuttonpress;
            key=get(h3, 'CurrentCharacter')
            if key == 'a'
                break
            end
            h5 = msgbox('Click same number as present green symbols')
            set(h5, 'Position', [290 300 180 50])
            
            [MVxp MVyp MVbutton] = ginput(1);
            
            close(h5)
            MVbutton
            MVxp = MVxp + xStartMV - 1;
            MVyp = MVyp + yStartMV - 1;
            
            writeMVMarkerPositionsXLSSingleRow(fid, MVData, kVData, listOfTimeDiff, MVxp, MVyp, MVbutton, n)
        end
    end

for mm=1:3
    if (autoPosition(mm,2)~=0 && autoPosition(mm,1)~=0)
        aMVxp = autoPosition(mm,2) + xStartMV - 1;
        aMVyp = autoPosition(mm,1) + yStartMV - 1;
        MVbutton = 1;
        writeAutoMVMarkerPositionsXLSSingleRow(fid2, MVData, kVData, listOfTimeDiff, aMVxp, aMVyp, MVbutton, n)
    end
end
    
end


% Disp message box to show that the process has been completed
h = msgbox('MV Segmentation Complete')

fclose('all')
close all

end



function writeMVMarkerPositionsXLSSingleRow(fid, MVData, kVData, listOfTimeDiff, MVxp, MVyp, MVbutton, n)

% Define a single row of data
singleRow = [MVData.MVFrameNo(n) MVData.MVFilename(n) MVData.WindowsTimestamps(n), MVData.MVGantryAngle(n), MVxp, MVyp, MVbutton, ...
    kVData.kVFrameNo(n), kVData.kVFilename(n), kVData.WindowsTimestamps(n), kVData.kVSourceAngle(n), ...
    kVData.xp1(n), kVData.yp1(n), kVData.xp2(n), kVData.yp2(n), kVData.xp3(n), kVData.yp3(n), ...
    kVData.x1(n), kVData.y1(n), kVData.z1(n), kVData.x2(n), kVData.y2(n), kVData.z2(n), kVData.x3(n), kVData.y3(n), kVData.z3(n), ...
    listOfTimeDiff(n)'];

% Then write that single row using fprintf
fprintf(fid, '%f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\r', ...
    singleRow);

end

function writeAutoMVMarkerPositionsXLSSingleRow(fid, MVData, kVData, listOfTimeDiff, MVxp, MVyp, MVbutton, n)

% Define a single row of data
singleRow = [MVData.MVFrameNo(n) MVData.MVFilename(n) MVData.WindowsTimestamps(n), MVData.MVGantryAngle(n), MVxp, MVyp, MVbutton, ...
    kVData.kVFrameNo(n), kVData.kVFilename(n), kVData.WindowsTimestamps(n), kVData.kVSourceAngle(n), ...
    kVData.xp1(n), kVData.yp1(n), kVData.xp2(n), kVData.yp2(n), kVData.xp3(n), kVData.yp3(n), ...
    kVData.x1(n), kVData.y1(n), kVData.z1(n), kVData.x2(n), kVData.y2(n), kVData.z2(n), kVData.x3(n), kVData.y3(n), kVData.z3(n), ...
    listOfTimeDiff(n)'];

% Then write that single row using fprintf
fprintf(fid, '%f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\r', ...
    singleRow);

end

function writeMVMarkerPositionsXLSHeader(filename, fid)

fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\r', ...
    'MVFrameNo', 'MVFilename', 'MVWindowsTimestamps', 'MVGantryAngle', 'MVxp', 'MVyp', 'MVbutton', ...
    'kVFrameNo', 'kVFilename', 'kVWindowsTimestamps', 'kVSourceAngle', ...
    'xp1', 'yp1', 'xp2', 'yp2', 'xp3', 'yp3', ...
    'x1', 'y1', 'z1', 'x2', 'y2', 'z2', 'x3', 'y3', 'z3', ...
    'timeDiff');


end

function writeAutoMVMarkerPositionsXLSHeader(filename, fid)

fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\r', ...
    'MVFrameNo', 'MVFilename', 'MVWindowsTimestamps', 'MVGantryAngle', 'MVxp', 'MVyp', 'MVbutton', ...
    'kVFrameNo', 'kVFilename', 'kVWindowsTimestamps', 'kVSourceAngle', ...
    'xp1', 'yp1', 'xp2', 'yp2', 'xp3', 'yp3', ...
    'x1', 'y1', 'z1', 'x2', 'y2', 'z2', 'x3', 'y3', 'z3', ...
    'timeDiff');


end


function includeMultiMarkerPerFrame(bigArray, MVData, kVData)
% Incorporates bigArray into MVData and kVData
% Uses addToVector and repeatRowInVector

listOfkVDataFields = fieldnames(kVData);
listOfMVDataFields = fieldnames(MVData);

for k = 1:numel(listOfFields)
    
    xp = bigArray{n}(:,2)
    yp = bigArray{n}(:,3)
    button = bigArray{n}(:,4)
    numToAdd = length(xp) - 1;
    
    
    
    kVData.(listOfFields{k}) = repeatRowInVector(kVData.(listOfFields{k}), numToAdd, n)
    
    MVData.field1
    
end



MVData.xp = addToVector(MVData.xp, xp, n);
MVData.MVFrameNo = repeatRowInVector(MVData.MVFrameNo, numToAdd, n);

MVData.xp(1:10)
MVData.MVFrameNo(1:10)
length(MVData.xp)
length(MVData.MVFrameNo)


end

function vector = addToVector(vector, vectorAdd, n)
% Adds vectorAdd to vector at position n
numToAdd = length(vectorAdd)-1;

vector(n + numToAdd + 1 : end + numToAdd) =  vector(n + numToAdd:end);
vector(n:n + numToAdd) = vectorAdd;

end

function vector = repeatRowInVector(vector, numToAdd, n)
% Repeats row n in vector

vector(n + numToAdd + 1:end + numToAdd) =  vector(n + 1:end);
vector(n:n + numToAdd) = vector(n)*ones(numToAdd + 1, 1);

end


function [meanPixVals] = findMeanPixelValues(xStartMV, yStartMV, frame, proj, tempSideLength)
% Computes the average pixel value for an 11 by 11 template centred at (y,x)
tempSize = floor(tempSideLength/2);

proj.xp1 = proj.xp1 - xStartMV + 1;
proj.xp2 = proj.xp2 - xStartMV + 1;
proj.xp3 = proj.xp3 - xStartMV + 1;

proj.yp1 = proj.yp1 - yStartMV + 1;
proj.yp2 = proj.yp2 - yStartMV + 1;
proj.yp3 = proj.yp3 - yStartMV + 1;

subFrame1 = frame(proj.yp1-tempSize:proj.yp1+tempSize,proj.xp1-tempSize:proj.xp1+tempSize);
subFrame2 = frame(proj.yp2-tempSize:proj.yp2+tempSize,proj.xp2-tempSize:proj.xp2+tempSize);
subFrame3 = frame(proj.yp3-tempSize:proj.yp3+tempSize,proj.xp3-tempSize:proj.xp3+tempSize);

meanPix1 = mean(subFrame1(:));
meanPix2 = mean(subFrame2(:));
meanPix3 = mean(subFrame3(:));

meanPixVals = [meanPix1 meanPix2 meanPix3];

end


function adjustWindowAndReplot(MVData, proj, zoomedMVFrame, lowPercentile, highPercentile)
close figure(3)
h3 = figure(3);
colormap gray
imagesc(zoomedMVFrame)
grid on
title({'MV', ['Frame/Filename/Gantry = ' num2str(MVData.MVFrameNo(n)) '/' num2str(MVData.MVFilename(n)) '/' num2str(MVData.MVGantryAngle(n)) ]})
colorbar
set(h3, 'Position', [655 50 700 600])

p = prctile(zoomedMVFrame(:), [lowPercentile highPercentile]);
zoomedMVFrame = imadjust(zoomedMVFrame, [p(1) p(2)], [0 1]);
imagesc(zoomedMVFrame)
end

function [xStart, xEnd, yStart, yEnd] = adjustFieldOfView(linac, fieldsize, detectorType)

if detectorType == 'kV'
    pixelSizeAtIso = linac.kVPixelSizeAtIso;
    SDD = linac.kVSDD;
    
elseif detectorType == 'MV'
    pixelSizeAtIso = linac.MVPixelSizeAtIso;
    SDD = linac.MVSDD;
    
end

xStart = round(linac.XCenterPixel - fieldsize.X/2/pixelSizeAtIso*SDD);
xEnd = round(linac.XCenterPixel + fieldsize.X/2/pixelSizeAtIso*SDD);

yStart = round(linac.YCenterPixel - fieldsize.Y/2/pixelSizeAtIso*SDD);
yEnd = round(linac.YCenterPixel + fieldsize.Y/2/pixelSizeAtIso*SDD);



end

function linacData = getLinacData
linacData.kVPixelSizeAtIso = 0.388; % in mm
linacData.MVPixelSizeAtIso = 0.388; % in mm

linacData.MVSDD = 1.5; % in m
linacData.kVSDD = 1.5; % in m

linacData.XWidth = 1024;
linacData.YWidth = 774;

linacData.XCenterPixel = 512;
linacData.YCenterPixel = 387;

end


function KIMData = readKIMData(kVFolder, frameAverage, OLdata)
% Find the number of trajectory files
if OLdata ==1
    list = ls([kVFolder '\MarkerLocationsGA*.txt']); 
    noOfOLTrajFiles = size(list,1);
    
    for n = 1:noOfOLTrajFiles
        fid=fopen([kVFolder '\MarkerLocationsGA_CouchShift_' num2str(n-1) '.txt']); 
        rawKIMDataCurrent = textscan(fid, '%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f , %*f, %*f, %*f, %*f, %s %s', 'headerLines', 1); %, %*f, %*f, %*f, %*f, %s %q', 'headerLines', 1);
        eval(['rawKIMData' num2str(n) '=rawKIMDataCurrent']);
        fclose(fid);
    end
    
elseif OLdata ==0
    list = ls([kVFolder '\MarkerLocationsGA*.txt'])
    noOfOLTrajFiles = size(list,1);
    
    for n = 1:noOfOLTrajFiles
        fid=fopen([kVFolder '\MarkerLocationsGA_CouchShift_' num2str(n-1) '.txt']);
        rawKIMDataCurrent = textscan(fid, '%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f', 'headerLines', 1);
        eval(['rawKIMData' num2str(n) '=rawKIMDataCurrent']);
        fclose(fid);
    end
end



% Merge all trajectory files into one
%noOfColumns = 24;
noOfColumns = size(rawKIMDataCurrent,2)
for n = 1:noOfColumns
    for k = 1:noOfOLTrajFiles
        
        if (k==1)
            rawKIMData{n} = [eval(['rawKIMData' num2str(k) '{n}'])];
        else
            rawKIMData{n} = [rawKIMData{n}; eval(['rawKIMData' num2str(k) '{n}']) ];
        end
    end
    
end


KIMData.kVFrameNo = rawKIMData{1};
KIMData.timestamps = rawKIMData{2};
KIMData.timestamps = KIMData.timestamps - KIMData.timestamps(1);
KIMData.kVSourceAngle = rawKIMData{3};

KIMData.kVFilename = rawKIMData{end}
KIMData.kVFilename = char(KIMData.kVFilename)
for n = 1:length(KIMData.kVFilename)
    kVFilename(n,:) = sscanf(KIMData.kVFilename(n,:), '%*[^V]%*[^C] Ch1_%f_%f');
     %a(n) = cellstr(kVFilename);
end
KIMData.kVFilename = kVFilename

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
%array = [rawKIMData{14}(1) rawKIMData{16}(1) rawKIMData{18}(1)];
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
%array = [rawKIMData{6}(1) rawKIMData{9}(1) rawKIMData{12}(1)];
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

% K. Compute centroid 3D trajectories for KIM data
KIMData.xCent = (KIMData.x1 + KIMData.x2 + KIMData.x3)/3;
KIMData.yCent = (KIMData.y1 + KIMData.y2 + KIMData.y3)/3;
KIMData.zCent = (KIMData.z1 + KIMData.z2 + KIMData.z3)/3;
KIMData.rCent = sqrt(KIMData.xCent.^2 + KIMData.yCent.^2 + KIMData.zCent.^2);

KIMData.xCentOff = KIMData.xCent - KIMData.xCent(1);
KIMData.yCentOff = KIMData.yCent - KIMData.yCent(1);
KIMData.zCentOff = KIMData.zCent - KIMData.zCent(1);
KIMData.rCentOff = sqrt(KIMData.xCentOff.^2 + KIMData.yCentOff.^2 + KIMData.zCentOff.^2);

end

function [MVData kVCSharpData] = readCSharpData(outputPath)
% Load MV data

fid=fopen([outputPath '\MVTimestampsFromCSharp.txt']);
MVCSharpRawData = textscan(fid, '%f\t %s\t %f\t %f\t %f\t %f\t %f\r', 'headerLines', 1);
fclose(fid);

MVData.MVFrameNo = MVCSharpRawData{:,1}; %This is just an index from 1 to no of files
MVData.MVFilename = MVCSharpRawData{:,2}; %This has the frame number info
%temptime = MVCSharpRawData{:,3};

%Take the frame number info out from the filename
for n = 1:length(MVData.MVFilename)
    %MVFilename(n) = sscanf(MVData.MVFilename{n}, 'Ch0_%f');
    MVFilename(n,:) = sscanf(MVData.MVFilename{n}, 'Ch0_%f_%f');
end

%Sort data according to its frame number;
%sortedFrameNo = sort(temptime,'ascend');
%sortedFrameNo = sort(MVFilename,'ascend');
sortedFrameNo=sortrows(MVFilename);


% sortedFrameNo = sortedFrameNo(:,2);
% MVFilename = MVFilename(:,2);

for i=1:length(sortedFrameNo)
    %sortinds(i) = find(temptime == sortedFrameNo(i));
    %sortinds(i) = find(MVFilename == sortedFrameNo(i));
    sortinds(i) = find(ismember(MVFilename,sortedFrameNo(i,:),'rows'));
end

for n=1:length(sortedFrameNo)
    MVData.MVFilename(n) = MVCSharpRawData{1,2}(sortinds(n));
    MVData.WindowsTimestamps(n) = MVCSharpRawData{1,3}(sortinds(n));
    MVData.MVFrameNo(n) = MVCSharpRawData{1,1}(sortinds(n));
end

clear MVFilename
for n = 1:length(MVData.MVFilename)
    MVFilename(n,:) = sscanf(MVData.MVFilename{n}, 'Ch0_%f_%f');
end
MVFilename = MVFilename(:,2);

MVData.MVFilename = MVFilename;
MVData.WindowsTimestamps = MVData.WindowsTimestamps';

% Load kV data
fid=fopen([outputPath '\kVTimestampsFromCSharp.txt']);
kVCSharpRawData = textscan(fid, '%f\t %s\t %f\t %f\t %f\t %f\t %f\r', 'headerLines', 1);
fclose(fid);
kVCSharpData.kVFrameNo = kVCSharpRawData{:,1}; %This is just an index from 1 to no of files
kVCSharpData.kVFilename = kVCSharpRawData{:,2}; %This has the frame number info

%Take the frame number info out from the filename
for n = 1:length(kVCSharpData.kVFilename)
    kVFilename(n,:) = sscanf(kVCSharpData.kVFilename{n}, 'Ch1_%f_%f_%f');
end

%Sort data according to its frame number;
%sortedFrameNo = sort(kVFilename,'ascend');
sortedFrameNo=sortrows(kVFilename);
kVCSharpData.GantryAngle = sortedFrameNo(:,3);

% sortedFrameNo = sortedFrameNo(:,2);
% kVFilename = kVFilename(:,2);


for i=1:length(sortedFrameNo)
    %sortinds(i) = find(kVFilename == sortedFrameNo(i));
    sortinds(i) = find(ismember(kVFilename,sortedFrameNo(i,:),'rows'));
end

for n=1:length(sortedFrameNo)
    kVCSharpData.kVFilename(n) = kVCSharpRawData{1,2}(sortinds(n));
    kVCSharpData.Timestamps(n) = kVCSharpRawData{1,3}(sortinds(n));
    kVCSharpData.kVFrameNo(n) = kVCSharpRawData{1,1}(sortinds(n));
end

clear kVFilename
 for n = 1:length(kVCSharpData.kVFilename)
     kVFilename(n,:) = sscanf(kVCSharpData.kVFilename{n}, 'Ch1_%f_%f');
 end
%kVFilename = kVFilename(:,2);
 
kVCSharpData.kVFilename = kVFilename;
kVCSharpData.Timestamps = kVCSharpData.Timestamps';

end

function kVData = extractData(indexOfMatches, kVData)

listOfFields = fieldnames(kVData);

for n = 1:numel(listOfFields)
    kVData.(listOfFields{n}) = kVData.(listOfFields{n})(indexOfMatches) ;
    
end

end

function printData(filename, MVData, kVData, listOfTimeDiff)
% If the file exists, delete it, to prevent further appendings
if exist(filename, 'file') == 2
    delete(filename)
end

% Write the header first
fid = fopen(filename, 'w');
fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\r', ...
    'MVFrameNo', 'MVFilename', 'MVWindowsTimestamps', 'MVGantryAngle', 'MVxp', 'MVyp', 'MVbutton', ...
    'kVFrameNo', 'kVFilename', 'kVWindowsTimestamps', 'kVSourceAngle', ...
    'xp1', 'yp1', 'xp2', 'yp2', 'xp3', 'yp3', ...
    'x1', 'y1', 'z1', 'x2', 'y2', 'z2', 'x3', 'y3', 'z3', ...
    'timeDiff');



M = [MVData.MVFrameNo MVData.MVFilename MVData.WindowsTimestamps, MVData.MVGantryAngle, MVData.xp, MVData.yp, MVData.button, ...
    kVData.kVFrameNo, kVData.kVFilename, kVData.WindowsTimestamps, kVData.kVSourceAngle, ...
    kVData.xp1, kVData.yp1, kVData.xp2, kVData.yp2, kVData.xp3, kVData.yp3, ...
    kVData.x1, kVData.y1, kVData.z1, kVData.x2, kVData.y2, kVData.z2, kVData.x3, kVData.y3, kVData.z3, ...
    listOfTimeDiff'];

% Then write the data using dlmwrite
%dlmwrite(filename, M, 'delimiter', '\t', 'precision', 16, '-append')

% Then write the data using fprintf

fprintf(fid, '%f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\r', ...
    M');
fclose(fid);

end


function proj = projectForKIM(kVSourceAngleIEC, point1, point2, point3)
linac = getLinacData;


projPoint1 = project(kVSourceAngleIEC, point1);
projPoint2 = project(kVSourceAngleIEC, point2);
projPoint3 = project(kVSourceAngleIEC, point3);


proj.xp1 = round(projPoint1(1)*linac.kVSDD/linac.kVPixelSizeAtIso + linac.XCenterPixel);
proj.yp1 = round(linac.YCenterPixel - projPoint1(2)*linac.kVSDD/linac.kVPixelSizeAtIso);

proj.xp2 = round(projPoint2(1)*linac.kVSDD/linac.kVPixelSizeAtIso + linac.XCenterPixel);
proj.yp2 = round(linac.YCenterPixel - projPoint2(2)*linac.kVSDD/linac.kVPixelSizeAtIso);

proj.xp3 = round(projPoint3(1)*linac.kVSDD/linac.kVPixelSizeAtIso + linac.XCenterPixel);
proj.yp3 = round(linac.YCenterPixel - projPoint3(2)*linac.kVSDD/linac.kVPixelSizeAtIso);


    function [ProjectedPoint] = project(angle,point) % point = (x,y,z)
        % project.m
        % Transforms point from patient coordinates (x,y,z) to the coordinates of
        % an imager placed at the specified angle relative to vertical.
        % The tranformation consists of a rotation followed by a projection
        % *********************************************************************** %
        
        % Per Poulsen, June 2010
        
        % Variables that need only be assigned at the first call of this function
        persistent previousAngle RotationMatrix
        
        if isempty(previousAngle) || ~isequal(previousAngle,angle)
            previousAngle = angle;
            cosAngle = cosd(angle);
            sinAngle = sind(angle);
            RotationMatrix = [cosAngle 0 -sinAngle
                0     1     0
                sinAngle 0  cosAngle];
        end
        ProjectedPoint = RotationMatrix * point';
        scaleFactor =  1000/(1000-ProjectedPoint(3));  % SAD = 1000 mm
        ProjectedPoint(1:2) = scaleFactor*ProjectedPoint(1:2);
    end

end

function proj = projectForKIMwtkVOffset(kVSourceAngleIEC, point1, point2, point3)
linac = getLinacData;


projPoint1 = project(kVSourceAngleIEC, point1);
projPoint2 = project(kVSourceAngleIEC, point2);
projPoint3 = project(kVSourceAngleIEC, point3);

[kVOffset_x kVOffset_y] = ImagerOffsets(kVSourceAngleIEC);

proj.xp1 = round(projPoint1(1)*linac.kVSDD/linac.kVPixelSizeAtIso + linac.XCenterPixel + kVOffset_x);
proj.yp1 = round(linac.YCenterPixel - projPoint1(2)*linac.kVSDD/linac.kVPixelSizeAtIso + kVOffset_y);

proj.xp2 = round(projPoint2(1)*linac.kVSDD/linac.kVPixelSizeAtIso + linac.XCenterPixel + kVOffset_x);
proj.yp2 = round(linac.YCenterPixel - projPoint2(2)*linac.kVSDD/linac.kVPixelSizeAtIso + kVOffset_y);

proj.xp3 = round(projPoint3(1)*linac.kVSDD/linac.kVPixelSizeAtIso + linac.XCenterPixel + kVOffset_x);
proj.yp3 = round(linac.YCenterPixel - projPoint3(2)*linac.kVSDD/linac.kVPixelSizeAtIso + kVOffset_y);


    function [kVOffset_x kVOffset_y] = ImagerOffsets(GantryAngle)
%         x = [0 -2.82 89.72]; % Original Jin's (2014)
%         y = [3.49 -1.03 -4.78];
%         x = [1.185, 1.638, -9.118];
%         y = [3.489, -0.867, -9.269]
        x = [0 0 90];
        y = [-3 0 0];
        
        kVOffset_x = x(1) + x(2)*sind(180-(GantryAngle+90)+x(3));
        kVOffset_y = y(1) + y(2)*sind(180-(GantryAngle+90)+y(3));
        
    end

    function [ProjectedPoint] = project(angle,point) % point = (x,y,z)
        % project.m
        % Transforms point from patient coordinates (x,y,z) to the coordinates of
        % an imager placed at the specified angle relative to vertical.
        % The tranformation consists of a rotation followed by a projection
        % *********************************************************************** %
        
        % Per Poulsen, June 2010
        
        % Variables that need only be assigned at the first call of this function
        persistent previousAngle RotationMatrix
        
        if isempty(previousAngle) || ~isequal(previousAngle,angle)
            previousAngle = angle;
            cosAngle = cosd(angle);
            sinAngle = sind(angle);
            RotationMatrix = [cosAngle 0 -sinAngle
                0     1     0
                sinAngle 0  cosAngle];
        end
        ProjectedPoint = RotationMatrix * point';
        scaleFactor = 1;% 1000/(1000-ProjectedPoint(3));  % SAD = 1000 mm
        ProjectedPoint(1:2) = scaleFactor*ProjectedPoint(1:2);
    end

end %Newer - taking kV imager offsets

function proj = projectForMV(MVGantryAngle, point1, point2, point3)
linac = getLinacData;


projPoint1 = project(MVGantryAngle, point1);
projPoint2 = project(MVGantryAngle, point2);
projPoint3 = project(MVGantryAngle, point3);

[MVOffset_x MVOffset_y] = ImagerOffsets(MVGantryAngle);

proj.xp1 = round(projPoint1(1)*linac.MVSDD/linac.MVPixelSizeAtIso + linac.XCenterPixel + MVOffset_x);
proj.yp1 = round(linac.YCenterPixel - projPoint1(2)*linac.MVSDD/linac.MVPixelSizeAtIso + MVOffset_y);

proj.xp2 = round(projPoint2(1)*linac.MVSDD/linac.MVPixelSizeAtIso + linac.XCenterPixel + MVOffset_x);
proj.yp2 = round(linac.YCenterPixel - projPoint2(2)*linac.MVSDD/linac.MVPixelSizeAtIso + MVOffset_y);

proj.xp3 = round(projPoint3(1)*linac.MVSDD/linac.MVPixelSizeAtIso + linac.XCenterPixel + MVOffset_x);
proj.yp3 = round(linac.YCenterPixel - projPoint3(2)*linac.MVSDD/linac.MVPixelSizeAtIso + MVOffset_y);


    function [MVOffset_x MVOffset_y] = ImagerOffsets(GantryAngle)
        %x = [0 -2.82 89.72];    %kV offset
        %y = [3.49 -1.03 -4.78]; %kV offset
        
        if GantryAngle <= 180
            GantryAngle = 180 - GantryAngle;
        else
            GantryAngle = 540 - GantryAngle;
        end
        
        x = [0 0 0];
        y = [-3 0 90];
%         x = [-1.90658544 -1.42631161	0.710209323];   %MV offset
%         y = [7.821516977	0.897579659	89.10368905];   %MV offset
        
        MVOffset_x = x(1) + x(2)*sind(GantryAngle+x(3));
        MVOffset_y = y(1) + y(2)*sind(GantryAngle+y(3));
    end

    function [ProjectedPoint] = project(angle,point) % point = (x,y,z)
        % project.m
        % Transforms point from patient coordinates (x,y,z) to the coordinates of
        % an imager placed at the specified angle relative to vertical.
        % The tranformation consists of a rotation followed by a projection
        % *********************************************************************** %
        
        % Per Poulsen, June 2010
        
        % Variables that need only be assigned at the first call of this function
        persistent previousAngle RotationMatrix
        
        if isempty(previousAngle) || ~isequal(previousAngle,angle)
            previousAngle = angle;
            cosAngle = cosd(angle);
            sinAngle = sind(angle);
            RotationMatrix = [cosAngle 0 -sinAngle
                0     1     0
                sinAngle 0  cosAngle];
        end
        ProjectedPoint = RotationMatrix * point';
        scaleFactor = 1;% 1000/(1000-ProjectedPoint(3));  % SAD = 1000 mm
        ProjectedPoint(1:2) = scaleFactor*ProjectedPoint(1:2);
    end

end %Newer - taking kV imager offsets



