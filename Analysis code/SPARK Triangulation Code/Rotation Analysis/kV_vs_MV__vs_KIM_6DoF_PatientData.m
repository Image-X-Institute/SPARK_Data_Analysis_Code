
%%% Patient data (Phase II)
PAT = 5;
PAT_affix = 'PAT';
MarkerInfoFilePath = 'Triangulation\';

kVMarkerInfoFileName = [MarkerInfoFilePath PAT_affix num2str(PAT) '_kVMarkersInfo_test.txt']; %Using reference pose to match the
MVMarkerInfoFileName = [MarkerInfoFilePath PAT_affix num2str(PAT) '_MVMarkersInfo_test.txt']; %KIM rotation estimation.

frameAverage = 1;                                                                                          %kVRefPose changed

fid = fopen(kVMarkerInfoFileName, 'r');
kVData = ReadMarkerInfo(kVMarkerInfoFileName);
fclose(fid)

fid = fopen(MVMarkerInfoFileName, 'r');
MVData = ReadMarkerInfo(MVMarkerInfoFileName);
fclose(fid)

FxNum = kVData.Fx;
kVFrame = kVData.Frame;
kVSourceAngle = kVData.GantryAngle;
MVFrame = MVData.Frame;
MVGantryAngle = MVData.GantryAngle;
meanVecDiff = MVData.meanVecDiff;

uniqueFx = unique(FxNum);

%Read KIM Data from logs
KIMDatPath = ['KIMData\',PAT_affix,num2str(PAT)];

numDat = length(kVData.Fx); %Number of Three frames avail for PAT##

cd (KIMDatPath);
All_fx = ls('Fx*');
tmp_ICP = [];
tmp_KIM = [];
kVCoM = [];
MVCoM = [];
kV_sixDoF = [];%zeros(1,8);
MV_sixDoF = [];

FxID1 = [];
kVFrame1 = [];
kVSourceAngle1 = [];
MVFrame1 = [];
MVGantryAngle1 = [];
meanVecDiff1 = [];


for i = 1:size(All_fx,1)
    
    IniPose = CVT_PLANNED_CENTROID(PAT, 1);
    
    for j=1:length(uniqueFx)
         uFx = strtrim(uniqueFx{j});
        Fxx = strtrim(All_fx(i,:));
        if (strcmp(Fxx, uFx) == 1)
            cd (All_fx(i,:));
            localpath= pwd;
            subdir = ls('*');
            
            if exist(fullfile(localpath,'CH1'))
                kVFolder = ([localpath '\CH1\']);
            elseif exist(fullfile(localpath,'KV'))
                kVFolder = ([localpath '\KV\']);
            end
            KIMData = readKIMData_refPos(kVFolder,frameAverage,1, IniPose);
            
            listKVimages = ls([kVFolder '\*.hnd']);
            numImgs = size(listKVimages,1);
            
            if numImgs > size(KIMData.kVFrameNo,1)*2.3;
                frameAverage =3;
            else
                frameAverage =1;
            end
            
            KIMData = readKIMData_refPos(kVFolder,frameAverage,1,IniPose);
            
            numKIMDat = length(KIMData.kVFrameNo);
            
            %Calculate Rotations from KIM position data
            %NOTE - Change the reference pose (IniPose) as required.
            
            discontFrame = find(diff(KIMData.kVFrameNo)<0);
            if  ~isempty(discontFrame)
                KIMData.kVFrameNo(discontFrame+1:end) = KIMData.kVFrameNo(discontFrame)+KIMData.kVFrameNo(discontFrame+1:end);
            end
             KIMFrame = KIMData.kVFrameNo;
            
            Time = KIMData.timestamps;
            Time = Time - Time(1);
            Time = Time(2:end);
            GA = KIMData.kVSourceAngle+90;
            
            %% Calc rotations
            
            Pose = zeros(numel(KIMData.x1),6);
            
            for n=1:numel(KIMData.x1) %n=2:numDat+1
                SubsPose_M1 = [KIMData.x1(n), KIMData.y1(n), KIMData.z1(n)];
                SubsPose_M2 = [KIMData.x2(n), KIMData.y2(n), KIMData.z2(n)]; %% Waring: Changed M2 and M3
                SubsPose_M3 = [KIMData.x3(n), KIMData.y3(n), KIMData.z3(n)];
                
                SubsPose = [SubsPose_M1; SubsPose_M2; SubsPose_M3];
                
                Tc = horn3drot(IniPose, SubsPose);
                
                Pose(n,:)=cvtm4(Tc); %Pose(n-1,:) = cvtm4(Tc);
            end
            
            KIMData.rSI = Pose(:,1);
            KIMData.rLR = Pose(:,2);
            KIMData.rAP = Pose(:,3);
            KIMData.tLR = Pose(:,4);
            KIMData.tSI = Pose(:,5);
            KIMData.tAP = Pose(:,6);
            
            %Sort ICP Rotation estimates
            rawRotData = readICPData([kVFolder ],0,0);

            
            RotFrameNo = KIMFrame;
            
            %Find a transformation between first pose of this Fx and Fx1
            %(refpos)
            
            tmpInd = strcmp(strtrim(FxNum), uFx);
            ThreeMarkerFrameIndex = find(tmpInd == 1);
            
            for k = 1:length(ThreeMarkerFrameIndex)%-3
                if PAT==19 && i==21
                    RotDataInd = find(RotFrameNo == kVFrame(ThreeMarkerFrameIndex(k))-406)
                    disp('Offset applied')
                elseif PAT==21 && i==7
                    RotDataInd = find(RotFrameNo == kVFrame(ThreeMarkerFrameIndex(k))-479)
                    disp('Offset applied')
                elseif PAT==21 && i==13
                    RotDataInd = find(RotFrameNo == kVFrame(ThreeMarkerFrameIndex(k))-464)
                    disp('Offset applied')
                else
                    RotDataInd = find(RotFrameNo == kVFrame(ThreeMarkerFrameIndex(k)))
                end
                
                if isempty(RotDataInd)
                    RotDataInd = find(RotFrameNo == kVFrame(ThreeMarkerFrameIndex(k))+1);
                    if isempty(RotDataInd)
                        RotDataInd = find(RotFrameNo == kVFrame(ThreeMarkerFrameIndex(k))+2);
                    end
                end
                if size(RotDataInd,1) >1
                    RotDataInd = RotDataInd(1);
                end
                if RotDataInd <= size(rawRotData.tLR,1)
                    tLR = -rawRotData.tLR(RotDataInd); %Check the axes - current header is in the order of AP, RL, SI, rLR, rSI, rAP
                    tSI = -rawRotData.tSI(RotDataInd);
                    tAP = -rawRotData.tAP(RotDataInd);
                    rLR = rawRotData.rLR(RotDataInd);
                    rSI = rawRotData.rSI(RotDataInd);
                    rAP = rawRotData.rAP(RotDataInd);
                else
                    tLR = 0;
                    tSI = 0;
                    tAP = 0;
                    rLR = 0;
                    rSI = 0;
                    rAP = 0;
                end
                
                tmp1 = [j RotFrameNo(RotDataInd) rSI rLR rAP tLR tSI tAP];
                tmp_ICP  = vertcat(tmp_ICP,tmp1);
                   
                kVPoses = [kVData.X1(ThreeMarkerFrameIndex(k)) kVData.Y1(ThreeMarkerFrameIndex(k)) kVData.Z1(ThreeMarkerFrameIndex(k));
                    kVData.X2(ThreeMarkerFrameIndex(k)) kVData.Y2(ThreeMarkerFrameIndex(k)) kVData.Z2(ThreeMarkerFrameIndex(k));
                    kVData.X3(ThreeMarkerFrameIndex(k)) kVData.Y3(ThreeMarkerFrameIndex(k)) kVData.Z3(ThreeMarkerFrameIndex(k))];
                
                MVPoses = [MVData.X1(ThreeMarkerFrameIndex(k)) MVData.Y1(ThreeMarkerFrameIndex(k)) MVData.Z1(ThreeMarkerFrameIndex(k));
                    MVData.X2(ThreeMarkerFrameIndex(k)) MVData.Y2(ThreeMarkerFrameIndex(k)) MVData.Z2(ThreeMarkerFrameIndex(k));
                    MVData.X3(ThreeMarkerFrameIndex(k)) MVData.Y3(ThreeMarkerFrameIndex(k)) MVData.Z3(ThreeMarkerFrameIndex(k))];
                
                kVCoM = vertcat(kVCoM, mean(kVPoses,1));
                MVCoM = vertcat(MVCoM, mean(MVPoses,1));
                
                kV_Tc = horn3drot(IniPose, kVPoses);
                sixkV = cvtm4(kV_Tc)';
                kV_tmp1 = [j kVFrame(ThreeMarkerFrameIndex(k)) sixkV];
                kV_sixDoF = vertcat(kV_sixDoF, kV_tmp1);
                
                MV_Tc = horn3drot(IniPose, MVPoses);
                sixMV = cvtm4(MV_Tc)';
                MV_tmp1 = [j kVFrame(ThreeMarkerFrameIndex(k)) sixMV];
                MV_sixDoF = vertcat(MV_sixDoF, MV_tmp1);
                
                %FxID = vertcat(FxID, i-2);
                FxID1 = vertcat(FxID1, MVData.Fx(ThreeMarkerFrameIndex(k)));
                kVFrame1 = vertcat(kVFrame1, kVFrame(ThreeMarkerFrameIndex(k)));
                kVSourceAngle1 = vertcat(kVSourceAngle1, kVSourceAngle(ThreeMarkerFrameIndex(k)));
                MVFrame1 = vertcat(MVFrame1, MVFrame(ThreeMarkerFrameIndex(k)));
                MVGantryAngle1 = vertcat(MVGantryAngle1, MVGantryAngle(ThreeMarkerFrameIndex(k)));
                meanVecDiff1 = vertcat(meanVecDiff1, meanVecDiff(ThreeMarkerFrameIndex(k)));
            end
            
            
            %%%%Plot rotation traces%%%%
            %%a=PlotSixDoFTraces(KIMFrame, Pose, ICPData, MV_sixDoF, tmp_ICP, tmp_KIM)
            
            cd ..
        end
    end
end

%% Look for any '0' data (resulting from shorter ICP data - don't know what happened)
zeroIndex = find(tmp_ICP(:,3)==0);

if length(zeroIndex)~=0
    disp('zero data exist! eleminating...')
    tmp_ICP(zeroIndex,:)=[];
    kV_sixDoF(zeroIndex,:) = [];
    MV_sixDoF(zeroIndex,:) = [];
    FxID1(zeroIndex,:) = [];
    kVFrame1(zeroIndex,:) = [];
    kVSourceAngle1(zeroIndex,:) = [];
    MVFrame1(zeroIndex,:) = [];
    MVGantryAngle1(zeroIndex,:) = [];
    meanVecDiff1(zeroIndex,:) = [];
end

if PAT==30
    IndexC = strfind(FxID1, 'Fx2-Part1');   % This fraction markers must have manually clicked and swapped the order
    Index = find(not(cellfun('isempty',IndexC)));
    disp('Removing data for swapped markers')
    tmp_ICP(Index,:)=[];
    kV_sixDoF(Index,:) = [];
    MV_sixDoF(Index,:) = [];
    FxID1(Index,:) = [];
    kVFrame1(Index,:) = [];
    kVSourceAngle1(Index,:) = [];
    MVFrame1(Index,:) = [];
    MVGantryAngle1(Index,:) = [];
    meanVecDiff1(Index,:) = [];
end

numDat = numel(FxID1);

d_rAP = tmp_ICP(:,5)-MV_sixDoF(:,5);
d_rLR = tmp_ICP(:,4)-MV_sixDoF(:,4);
d_rSI = tmp_ICP(:,3)-MV_sixDoF(:,3);
d_tLR = tmp_ICP(:,6)-MV_sixDoF(:,6);
d_tSI = tmp_ICP(:,7)-MV_sixDoF(:,7);
d_tAP = tmp_ICP(:,8)-MV_sixDoF(:,8);

%save([MarkerInfoFilePath PAT '_diffsixDoF.mat'],'d_rLR','d_rSI','d_rAP','d_tLR','d_tSI','d_tAP');

[mean(d_rLR) mean(d_rSI) mean(d_rAP) mean(d_tLR) mean(d_tSI) mean(d_tAP)]
[std(d_rLR) std(d_rSI) std(d_rAP) std(d_tLR) std(d_tSI) std(d_tAP)]

if (2<3)
    subplot(2,1,1)
    plot((1:numDat),kV_sixDoF(1:end,5),(1:numDat),MV_sixDoF(1:end,5))
    title('rAP')
    legend('rAP_{kV}', 'rAP_{MV}')
    xlabel('Available Data Point (3Markers shown for Patient 1)')
    ylabel('rAP (^\circ)')
    subplot(2,1,2)
    plot((1:numDat),d_rAP)
    title('Differences in rAP (^\circ)')
    xlabel('Available Data Point (3Markers shown for Patient 1)')
    ylabel('\Delta rAP (^\circ): rAP_{kV} - rAP_{MV}')
    savefig([MarkerInfoFilePath num2str(PAT) 'rAP(kV vs MV)_3'])
    
    subplot(2,1,1)
    plot((1:numDat),kV_sixDoF(1:end,4),(1:numDat),MV_sixDoF(1:end,4))
    title('rLR')
    legend('rLR_{kV}', 'rLR_{MV}')
    xlabel('Available Data Point (3Markers shown for Patient 1)')
    ylabel('rLR (^\circ)')
    subplot(2,1,2)
    plot((1:numDat),d_rLR)
    title('Differences in rLR (^\circ)')
    xlabel('Available Data Point (3Markers shown for Patient 1)')
    ylabel('\Delta rLR (^\circ): rLR_{kV} - rLR_{MV}')
    savefig([MarkerInfoFilePath num2str(PAT) 'rLR(kV vs MV)_3'])
    
    subplot(2,1,1)
    plot((1:numDat),kV_sixDoF(1:end,3),(1:numDat),MV_sixDoF(1:end,3))
    title('rSI')
    legend('rSI_{kV}', 'rSI_{MV}')
    xlabel('Available Data Point (3Markers shown for Patient 1)')
    ylabel('rSI (^\circ)')
    subplot(2,1,2)
    plot((1:numDat),d_rSI)
    title('Differences in rSI (^\circ)')
    xlabel('Available Data Point (3Markers shown for Patient 1)')
    ylabel('\Delta rSI (^\circ): rSI_{kV} - rSI_{MV}')
    savefig([MarkerInfoFilePath num2str(PAT) 'rSI(kV vs MV)_3'])
    
    subplot(2,1,1)
    plot((1:numDat),kV_sixDoF(1:end,6),(1:numDat),MV_sixDoF(1:end,6))
    title('tLR')
    legend('tLR_{kV}', 'tLR_{MV}')
    xlabel('Available Data Point (3Markers shown for Patient 1)')
    ylabel('tLR (^\circ)')
    subplot(2,1,2)
    plot((1:numDat),d_tLR)
    title('Differences in tLR (^\circ)')
    xlabel('Available Data Point (3Markers shown for Patient 1)')
    ylabel('\Delta tLR (^\circ): tLR_{kV} - tLR_{MV}')
    savefig([MarkerInfoFilePath num2str(PAT) 'tLR(kV vs MV)_3'])
    
    subplot(2,1,1)
    plot((1:numDat),kV_sixDoF(1:end,8),(1:numDat),MV_sixDoF(1:end,8))
    title('tAP')
    legend('tAP_{kV}', 'tAP_{MV}')
    xlabel('Available Data Point (3Markers shown for Patient 1)')
    ylabel('tAP (^\circ)')
    subplot(2,1,2)
    plot((1:numDat),d_tAP)
    title('Differences in tAP (^\circ)')
    xlabel('Available Data Point (3Markers shown for Patient 1)')
    ylabel('\Delta tAP (^\circ): tAP_{kV} - tAP_{MV}')
    savefig([MarkerInfoFilePath num2str(PAT) 'tAP(kV vs MV)_3'])
    
    subplot(2,1,1)
    plot((1:numDat),kV_sixDoF(1:end,7),(1:numDat),MV_sixDoF(1:end,7))
    title('tSI')
    legend('tSI_{kV}', 'tSI_{MV}')
    xlabel('Available Data Point (3Markers shown for Patient 1)')
    ylabel('tSI (^\circ)')
    subplot(2,1,2)
    plot((1:numDat),d_tSI)
    title('Differences in tSI (^\circ)')
    xlabel('Available Data Point (3Markers shown for Patient 1)')
    ylabel('\Delta tSI (^\circ): tSI_{kV} - tSI_{MV}')
    savefig([MarkerInfoFilePath num2str(PAT) 'tSI(kV vs MV)_3'])
end


%FxID1 = cellfun(@str2num,FxID1);
FxID = cellfun(@(s) sscanf(s,'Fx%u'), FxID1);
Result = [kVFrame1 kVSourceAngle1 kV_sixDoF(:,3:8) MVFrame1 MVGantryAngle1 MV_sixDoF(:,3:8) meanVecDiff1];
%Result = [FxID kVFrame kVSourceAngle kV_sixDoF(:,3:8) MVFrame MVGantryAngle MV_sixDoF(:,3:8) meanVecDiff];
if 2<3
    fid = fopen([MarkerInfoFilePath PAT_affix num2str(PAT) '_KVMV_sixDoF_test.txt'],'w')
    fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\n ','FxID', 'kVFrame', 'kVSourceAngle', 'kV_rSI', 'kV_rLR', 'kV_rAP', 'kV_tLR', 'kV_tSI', 'kV_tAP', 'MVFrame', 'MVGantryAngle', 'MV_rSI', 'MV_rLR', 'MV_rAP', 'MV_tLR', 'MV_tSI', 'MV_tAP', 'meanVecDiff')
    for i=1:numDat
        fprintf(fid, '%s\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\n ',FxID1{i}, Result(i,:));
    end
    fclose('all')
    
    kVMV = Result;

    Result = [kVFrame1 kVSourceAngle1 tmp_ICP(:,3:8)];
    
    fid = fopen([MarkerInfoFilePath PAT_affix num2str(PAT) '_ICP_sixDoF_test.txt'],'w')
    fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\n ','FxID', 'kVFrame', 'kVSourceAngle', 'ICP_rSI', 'ICP_rLR', 'ICP_rAP', 'ICP_tLR', 'ICP_tSI', 'ICP_tAP')
    for i=1:numDat
        fprintf(fid, '%s\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\n ',FxID1{i}, Result(i,:));
    end
    fclose('all')
    
    
    KIM = Result;
    
    save([MarkerInfoFilePath PAT_affix num2str(PAT) '_6DoF.mat'], 'FxID', 'FxID1','kVMV','KIM','KIMData','rawRotData','d_rLR','d_rSI','d_rAP','d_tLR','d_tSI','d_tAP')
end