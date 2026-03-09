classdef ClassFrameGrabber < handle
    % This class enables reading of .cps, .hnd and .hnc files.
    % It also supports .jpg, .png and .pgm files
    % The class is initialized with the path to folder containing
    % maximum one .cps file, or several of the other types.
    % Only one file type of should be present in a folder.
    % Gantry only supported for cps/hnc/hnd.
    
    properties
        folderpath;
        nextframe;
        numframes;
        filenames;
        cpsreader;
        avireader;
        filetype;
        cpsEOF = 0;
        timestamp = 0;
        
        preload     = false;
        gantryarray = [];
        timearray   = [];
        framearray  = [];
    end
    
    methods
        
        
        function [] = preLoad(obj, framecount)
            preload     = true;
            gantryarray = zeros(framecount,1);
            timearray   = zeros(framecount,1);
            framearray  = zeros(1024,768,framecount);
            
            for n=1:10
                
            end
            
        end
        
        
        
        %Constructor
        function obj = ClassFrameGrabber(folderpath)
            
            obj.folderpath = folderpath;
            obj.nextframe = 1;
            obj.filetype = -1;
            
            % IDENTIFY WHICH TYPE,
            dirCPS = dir(fullfile(folderpath,['*.','cps'])); % type = 1
            dirHND = dir(fullfile(folderpath,['*.','hnd'])); % type = 2
            dirHNC = dir(fullfile(folderpath,['*.','hnc'])); % type = 2
            dirJPG = dir(fullfile(folderpath,['*.','jpg'])); % type = 3
            dirPNG = dir(fullfile(folderpath,['*.','png'])); % type = 3
            dirPGM = dir(fullfile(folderpath,['*.','pgm'])); % type = 3
            dirAVI = dir(fullfile(folderpath,['*.','avi'])); % type = 4
            dirDCM = dir(fullfile(folderpath,['*.','dcm'])); % type = 5
            
            if(numel(dirCPS)==1)
                obj.filetype = 1;
            elseif( numel(dirHND)>0 || numel(dirHNC)>0)
                obj.filetype = 2;
            elseif( numel(dirJPG)>0 || numel(dirPNG)>0 || numel(dirPGM)>0)
                obj.filetype = 3;
            elseif( numel(dirAVI)>0)
                obj.filetype = 4;
            elseif( numel(dirDCM)>0)
                obj.filetype = 5;
            end
            
            
            
            % Find files in directory and initialize
            switch obj.filetype
                
                case 1 % CPS
                    obj.cpsreader = CPS_Reader(strcat(folderpath,'/',dirCPS.name),1);
                    
                case 2 % HND/HNC
                    dirInfo = dir(fullfile(folderpath,['*.','hnc']));
                    if(numel(dirInfo)==0)
                        dirInfo = dir(fullfile(folderpath,['*.','hnd']));
                    end
                    obj.cpsreader = CPS_Reader();
                    obj.filenames = {dirInfo.name}';
                    obj.numframes = numel(obj.filenames);
                    
                case 3 % JPG,PGM,PNG
                    dirInfo = dir(fullfile(folderpath,['*.','png']));
                    if(numel(dirInfo)==0)
                        dirInfo = dir(fullfile(folderpath,['*.','jpg']));
                    elseif (numel(dirInfo)==0)
                        dirInfo = dir(fullfile(folderpath,['*.','pgm']));
                    end
                    obj.filenames = {dirInfo.name}';
                    obj.numframes = numel(obj.filenames);
                case 4 % AVI
                    obj.avireader = mmreader([folderpath,'/',dirAVI.name]);
                    obj.numframes = obj.avireader.NumberOfFrames;
                case 5 % DICOM
                    obj.filenames = {dirDCM.name}';
                    obj.numframes = numel(obj.filenames);
                otherwise
                    obj.numframes = 0;
            end
            
        end
        
        
        
        function [frame,gantry,time] = getNextFrame(obj)
            frame  = [];
            gantry = 0;
            time   = 0;
            
            switch obj.filetype
                
                case 1 % GET CPS FRAME
                    if(~obj.cpsEOF)
                        frame = obj.cpsreader.getNextFrame();
                    else
                        return
                    end
                    
                    if(size(frame,1)==786432)
                        frame = reshape(frame,1024,768);
                        frame = im2double(frame)';
                        frame = frame/max(max(frame));
                        gantry = obj.cpsreader.getGantry();
                        time = obj.cpsreader.getTimeStamp();
                    else
                        obj.cpsEOF=1;
                    end
                    
                case 2 % GET HND HNC FRAME
                    if(obj.nextframe<=obj.numframes)
                        filepath = fullfile(obj.folderpath,obj.filenames{obj.nextframe});
                        frame  = obj.cpsreader.getHNC_HND(filepath);
                        gantry = obj.cpsreader.getGantry();
                        time = obj.cpsreader.getTimeStamp();
                        frame = reshape(frame,1024,768);
                        frame = im2double(frame)';
                        frame = frame/max(max(frame));
                        obj.nextframe = obj.nextframe+1;
                        
                        %Read accompanying textfile if it exist
                        filepath = [filepath(1:end-4) '.txt'];
                        
                        if(exist(filepath,'file'))
                            fid = fopen(filepath);
                            
                            tline = fgets(fid);
                            time = textscan(tline,'Adjustment: %f sec');
                            while  ischar(tline) && isempty(time{1})
                                time = textscan(tline,'Adjustment: %f sec');
                                tline = fgets(fid);
                            end
                            if ~isempty(time{1})
                                obj.timestamp = time{1};
                            end
                            fclose(fid);
                        end
                    end
                    
                case 3 % GET OTHER
                    if(obj.nextframe<=obj.numframes)
                        filepath = fullfile(obj.folderpath,obj.filenames{obj.nextframe});
                        frame = imread(filepath);
                        frame = im2double(frame);
                        obj.nextframe = obj.nextframe+1;
                        gantry = 0;
                        time = 0;
                    end
                    
                case 4 % AVI
                    if(obj.nextframe<=obj.numframes)
                        frame = read(obj.avireader,obj.nextframe);
                        frame = im2double(frame(:,:,2));
                        obj.nextframe = obj.nextframe+1;
                        gantry = 0;
                        time = 0;
                    end
                case 5 % GET DICOM
                    if(obj.nextframe<=obj.numframes)
                        filepath = fullfile(obj.folderpath,obj.filenames{obj.nextframe});
                        frame = dicomread(filepath);
                        frame = im2double(frame);
                        obj.nextframe = obj.nextframe+1;
                        gantry = 0;
                        time = 0;
                    end
                    
            end
            
            if(isempty(frame))
                clear obj.cpsreader;
            end
            
        end
        
        function [no] = getNumberOfFiles(obj)
            no = obj.numframes;
        end
        
        function [frame,gantry,timestamp,filename] = getVarianNo(obj,index)

            frame     = [];
            gantry    = [];
            filename  = [];
            timestamp = [];
            
            if(index>0 && index<=obj.numframes)
                
                if (obj.filetype==1 || obj.filetype==2)                                                            
                    filepath = fullfile(obj.folderpath,obj.filenames{index});
                    frame  = obj.cpsreader.getHNC_HND(filepath);
                    gantry = obj.cpsreader.getGantry();
                    timestamp = obj.cpsreader.getTimeStamp();
                    frame = reshape(frame,1024,768);
                    frame = im2double(frame)';
                    frame = frame/max(max(frame));
                    filename = obj.filenames{index};
                end
                
                if obj.filetype==4
                    frame = read(obj.avireader,index);
                    frame = im2double(frame(:,:,2));
                end
            end
        end
        
        function [timestamp] = getTimestamp(obj)
            timestamp = obj.timestamp;
        end
        
        % Currently only works for .hnc and .hnd
        function [header cw fullfan sid] = getInfo(obj)
            firstframe = 0;
            lastframe  = 0;
            header     = '';
            cw         = [];
            fullfan    = [];
            sid        = [];
            
            if obj.filetype==2 && obj.numframes>1
                null = obj.getVarianNo(1);
                firstframe = char(obj.cpsreader.getCreationTime());
                null = obj.getVarianNo(obj.numframes);
                lastframe = char(obj.cpsreader.getCreationTime());
                fullfan = (obj.cpsreader.getIDUPosLat<1);
                sid = round(obj.cpsreader.getSID)*10;
            end
            
            if obj.filetype==2 && obj.numframes>10
                check = round(obj.numframes/3);
                null = obj.getVarianNo(check);
                gantry1 = obj.cpsreader.getGantry();
                null = obj.getVarianNo(check*2);
                gantry2 = obj.cpsreader.getGantry();
                cw = (gantry2>gantry1);
            end
            
            
            strheader = char(obj.cpsreader.getHeader());
            strpath   = ['ImageDirectory         ' obj.folderpath];
            strcw     = ['CW                     ' num2str(cw)];
            strfan    = ['Fullfan                ' num2str(fullfan)];
            strfirst  = ['TimeStampFirstFrame    ' firstframe];
            strlast   = ['TimeStampLastFrame     ' lastframe];
            header    = sprintf( '%s\n%s\n%s\n%s\n%s\n%s',strpath,strcw,strfan,strfirst,strlast,strheader );
            
        end
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        function [out] = backdoor(obj)
            out = obj.cpsreader.getTimeStamp();
        end
        
    end
end

