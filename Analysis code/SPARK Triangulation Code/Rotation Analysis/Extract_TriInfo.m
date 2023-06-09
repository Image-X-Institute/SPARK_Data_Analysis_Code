% Read the information of where all 3 markers were present 
% produced by 'threeMVmarkers.m'.

PAT = 5;
PAT_affix = 'PAT';
TriangulationFolder = 'Triangulation Folder\';

MATfilePath = TriangulationFolder;
MATfilename = [MATfilePath PAT_affix num2str(PAT) '_test.mat'];

frameAverage = 1;

load(MATfilename);

nrDat = length(S); %Number of fractions in the data.

totNrCases = 0;
for n=1:nrDat
    if isempty(S(n).NrCases)
        S(n).NrCases = 0;
    end
    totNrCases = totNrCases + S(n).NrCases;
end    

ii = [S(:).NrCases] > 0;
idx = find(ii~=0);

nrDat = length(idx);

        Marker1 = zeros(totNrCases,12);
        Marker2 = zeros(totNrCases,10);
        Marker3 = zeros(totNrCases,10);
  
        outIndex = 1;       
        
for n=1:nrDat
    if (S(idx(n)).ThreeMarkerFrameNr ~= 0) % If the fraction contains 3 markers frame proceed
        nrFrames = S(idx(n)).NrCases;
        totalcase = sum(S(idx(n)).NrCases);
        current_folder = [TriangulationFolder PAT_affix num2str(PAT) '\' S(idx(n)).Fx]; 
       cd(current_folder); 
        
        %FxNum = S(idx(n)).Fx;
        FxNum = idx(n);
        
        %Get the data from Triangulation Results
        MVfile_name = ls('*TriangulatedPositions*.xls'); 
        if length(MVfile_name) > 1
            MVfile_name = MVfile_name(1,:);
        end
        fid = fopen(MVfile_name, 'r');
        Data = textscan(fid,'%f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\n' , 'headerlines', 1);                    
        fclose(fid); 
        frame = Data{1,:}; 
               
        for i = 1:nrFrames
           FrameIndex = find(frame == S(idx(n)).ThreeMarkerFrameNr(i))
           if (length(FrameIndex) > 3)
               disp('More than one arc is found');
               %return
           else    
           
           % Find marker number and extract required data in following
           % foramt for marker number i (where i=0~3)
           % [Fx, MVFrame#, GantryAngle Tri_X(i), Tri_Y(i), Tri_Z(i), 
           % kVFrame#, kVSourceAngle, KIM_X(i), KIM_Y(i), KIM_Z(i)]
           if (Data{1,42}(FrameIndex(1)) ~= Data{1,42}(FrameIndex(2))) && ...
                   (Data{1,42}(FrameIndex(2)) ~= Data{1,42}(FrameIndex(3))) && ...
                        (Data{1,42}(FrameIndex(3)) ~= Data{1,42}(FrameIndex(1)))
           for j = 1: 3
           if (Data{1,42}(FrameIndex(j)) == 1)
               %% Fx, MVFrame#, GA, Tri1_x,y,z, VecDiff1, kVFrame#, kVSA, KIM1_x,y,z
           Marker1(outIndex,:) = [FxNum Data{1,1}(FrameIndex(j)) Data{1,4}(FrameIndex(j)) Data{1,30}(FrameIndex(j)) Data{1,31}(FrameIndex(j)) Data{1,32}(FrameIndex(j)) Data{1,39}(FrameIndex(j))... 
                                Data{1,10}(FrameIndex(j)) Data{1,13}(FrameIndex(j)) Data{1,20}(FrameIndex(j)) Data{1,21}(FrameIndex(j)) Data{1,22}(FrameIndex(j))];
            
           elseif (Data{1,42}(FrameIndex(j)) == 2) 
               %% Fx, MVFrame#, Tri2_x,y,z, VecDiff2, kVFrame#, KIM2_x,y,z
           Marker2(outIndex,:) = [FxNum Data{1,1}(FrameIndex(j)) Data{1,33}(FrameIndex(j)) Data{1,34}(FrameIndex(j)) Data{1,35}(FrameIndex(j)) Data{1,40}(FrameIndex(j))... 
                         Data{1,10}(FrameIndex(j)) Data{1,23}(FrameIndex(j)) Data{1,24}(FrameIndex(j)) Data{1,25}(FrameIndex(j))];
               
           else (Data{1,42}(FrameIndex(j)) == 3) 
               %% Fx, MVFrame#, Tri3_x,y,z, VecDiff3, kVFrame#, KIM3_x,y,z
               Marker3(outIndex,:) = [FxNum Data{1,1}(FrameIndex(j)) Data{1,36}(FrameIndex(j)) Data{1,37}(FrameIndex(j)) Data{1,38}(FrameIndex(j)) Data{1,41}(FrameIndex(j))... 
                         Data{1,10}(FrameIndex(j)) Data{1,26}(FrameIndex(j)) Data{1,27}(FrameIndex(j)) Data{1,28}(FrameIndex(j))];
           end
           end
                      outIndex = outIndex+1;
           else
                      outIndex = outIndex;
           end
           end
          
        end
    end

end

MVMarkersInfo = [Marker1(:,1:6) Marker2(:,3:5) Marker3(:,3:5) Marker1(:,7) Marker2(:,6) Marker3(:,6) (Marker1(:,7)+Marker2(:,6)+Marker3(:,6))/3];
kVMarkersInfo = [Marker1(:,1) Marker1(:,8)/frameAverage Marker1(:,9:12) Marker2(:,8:10) Marker3(:,8:10)];
                %kV frame number / 3 to account for the average frame by a
                %factor of 3 used in KIMGTriPArt1_vc1.m
if 2<3                
fid = fopen([MATfilePath PAT_affix num2str(PAT) '_MVMarkersInfo_test.txt'],'w')
fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\n ','Fx', 'MVFrame', 'GantryAngle', 'Tri_X1', 'Tri_Y1', 'Tri_Z1', 'Tri_X2', 'Tri_Y2', 'Tri_Z2', 'Tri_X3', 'Tri_Y3', 'Tri_Z3', 'VecDiff1', 'VecDiff2', 'VecDiff3', 'meanVecDiff')
for i = 1:outIndex-1
fprintf(fid, '%s\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\n ',S(MVMarkersInfo(i)).Fx, MVMarkersInfo(i,2:end));
end

fid = fopen([MATfilePath PAT_affix num2str(PAT) '_kVMarkersInfo_test.txt'],'w')
fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\n ','Fx', 'kVFrame', 'kVSourceAngle', 'KIM_X1', 'KIM_Y1', 'KIM_Z1', 'KIM_X2', 'KIM_Y2', 'KIM_Z2', 'KIM_X3', 'KIM_Y3', 'KIM_Z3')
for i=1:outIndex-1
fprintf(fid, '%s\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\t %1.3f\n ',S(kVMarkersInfo(i)).Fx, kVMarkersInfo(i,2:end));
end
fclose('all')
end                