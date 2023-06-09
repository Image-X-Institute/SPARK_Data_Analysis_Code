% This script goes through the triangulation results
% '*TriangulatedPositions.xlsx' and finds number of frames 
% that has all 3 markers in the MV images. The information is saved in 
% a structure (S), which is saved in a
% spreadsheet ('PAT#.xlsx') as well as ('PAT#.mat') file for further
% processing.

% Written by Jo Kim 15-Jan-2016.

outputPath = 'Trignaulation Folder\';
PAT = 5;
PAT_affix = 'PAT';

parent_dir = pwd; 

totalMarker = [];
oneMarker = []; 
twoMarker = []; 
threeMarker = []; 

S = repmat(struct('PAT',[], 'Fx',[], 'ThreeMarkerFrameNr',[], 'NrCases', []), 1, 10);

cd (outputPath) 
for p = 1:length(PAT)
    
    current_folder = [PAT_affix, num2str(PAT(p))]; 
    cd(current_folder); 
    All_fx = ls('Fx*');  
           
    for fx = 1:size(All_fx,1)
        cd(All_fx(fx,:));
        
        file_name = ls('*TriangulatedPositions*.xls'); 
        
        if(size(file_name,1) > 1)
            file_name = file_name(1,:);
        end
        
        if (size(file_name,1) > 0)          
                    fid = fopen(file_name, 'r'); 
                    %Data = textscan(fid,'%f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t' , 'headerlines', 1);                                        
                    Data = textscan(fid,'%f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\n' , 'headerlines', 1);                    
                    fclose(fid); 

                    
                    frame = Data{1,:};
                    MVfilename = Data{1,2};
        
                    if (all(diff(frame)>=0))
                      All_fx(fx,:)
                      disp('One arc is present in the data!')  
                      
                      [n, bin] = histc(frame, unique(frame));

                      ind = find(n==3);
                      out = 0:(size(ind,1)-1);
                      for i=1: (size(ind,1)) ; 
                          out(i) = sum(n(1:ind(i,1)));
                      end
                      threeMarkerFrame = [];%0:size(ind)-1;
                      for i=1: (size(ind,1));
                          threeMarkerFrame(i) = frame(out(i));
                      end
                     disp('Frame where all three markers were present')
                     threeMarkerFrame

                    else
                      All_fx(fx,:) 
                      disp('Two arcs are present in the data!')  
                      
                      cut = find((diff(frame)<0));
                      
                      if length(cut)==1
                      firstarc = frame(1:cut);
                      secondarc = frame(cut+1:end);
                      
                      [n1, bin1] = histc(firstarc, unique(firstarc));
                      [n2, bin2] = histc(secondarc, unique(secondarc));

                      %First arc
                      ind1 = find(n1==3);
                      threeMarkerFrame1 = [];%0:size(ind)-1;

                      if (ind1 ~= 0)
                      out1 = 0:(size(ind1,1)-1);
                      for i=1: (size(ind1,1)) ; 
                          out1(i) = sum(n1(1:ind1(i,1)));
                      end
                      for i=1: (size(ind1,1));
                          threeMarkerFrame1(i) = frame(out1(i));
                      end 
                      end
                      
                      %Second arc
                      ind2 = find(n2==3);
                      threeMarkerFrame2 = [];%0:size(ind)-1;
                      
                      if ind2 ~= 0
                      out2 = 0:(size(ind2,1)-1);
                      for i=1: (size(ind2,1)) ; 
                          out2(i) = sum(n2(1:ind2(i,1)));
                      end
                      
                      for i=1: (size(ind2,1));
                          threeMarkerFrame2(i) = frame(out2(i)+cut);
                      end 
                      end

                      disp('Frame where all three markers were present')

                      threeMarkerFrame = [threeMarkerFrame1 threeMarkerFrame2]                      
                      
                      else %%%%%%%%%%%Three arc data present
                      firstarc = frame(1:cut(1));
                      secondarc = frame(cut(1)+1:cut(2));
                      extraarc = frame(cut(2)+1:end);
                      
                      [n1, bin1] = histc(firstarc, unique(firstarc));
                      [n2, bin2] = histc(secondarc, unique(secondarc));
                      [n3, bin3] = histc(extraarc, unique(extraarc));

                      %First arc
                      ind1 = find(n1==3);
                      threeMarkerFrame1 = [];%0:size(ind)-1;

                      if (ind1 ~= 0)
                      out1 = 0:(size(ind1,1)-1);
                      for i=1: (size(ind1,1)) ; 
                          out1(i) = sum(n1(1:ind1(i,1)));
                      end
                      for i=1: (size(ind1,1));
                          threeMarkerFrame1(i) = frame(out1(i));
                      end 
                      end
                      
                      %Second arc
                      ind2 = find(n2==3);
                      threeMarkerFrame2 = [];%0:size(ind)-1;
                      
                      if ind2 ~= 0
                      out2 = 0:(size(ind2,1)-1);
                      for i=1: (size(ind2,1)) ; 
                          out2(i) = sum(n2(1:ind2(i,1)));
                      end
                      
                      for i=1: (size(ind2,1));
                          threeMarkerFrame2(i) = frame(out2(i)+cut(1));
                      end 
                      end
                      
                      %Third arc
                      ind3 = find(n3==3);
                      threeMarkerFrame3 = [];

                      if ind3 ~= 0
                      out3 = 0:(size(ind3,1)-1);
                      for i=1: (size(ind3,1)) ; 
                          out3(i) = sum(n3(1:ind3(i,1)));
                      end

                      for i=1: (size(ind3,1));
                          threeMarkerFrame3(i) = frame(out3(i)+cut(2));
                      end                                             
                      end
                      
                      disp('Frame where all three markers were present')
                      threeMarkerFrame = [threeMarkerFrame1 threeMarkerFrame2 threeMarkerFrame3]

                      end
                                      
                    end
                    
                   % oneMarker = [oneMarker length(find(n == 1))];
                   % twoMarker = [twoMarker length(find(n == 2))];
                   % threeMarker = [threeMarker length(find(n == 3))];
   
   S(fx).PAT0 = PAT;
   S(fx).Fx   = All_fx(fx,:);
   S(fx).ThreeMarkerFrameNr = threeMarkerFrame;
   S(fx).NrCases = length(threeMarkerFrame);
   
        end
        cd .. %for SPARK where Triangulation folder is within patient data
        %cd .. 
    end 
    
    cd ..

end

t = struct2table(S);
writetable(t, [outputPath current_folder '_test.xlsx'])

save([outputPath current_folder '_test.mat'], 'S')  % EDITED