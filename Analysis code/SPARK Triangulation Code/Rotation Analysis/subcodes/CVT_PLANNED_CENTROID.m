function Refpose = CVT_PLANNED_CENTROID22(PATNUM, PHASE2)
%% Import Patientfilename
%% Initialize variables.

if PHASE2==1
PATIENTFILE_PATH = '\Patient Files\';
PATDIRECTORY = [PATIENTFILE_PATH '\PAT' num2str(PATNUM) '\'];

    if (size(ls([PATDIRECTORY '\*.txt']),1) ~=0)
        CENTROIDFILE = ls([PATDIRECTORY '\*.txt'])
    else 
        subdirs = ls([PATDIRECTORY]);
        disp('Patient has more than two centroid files')
        disp('Using one of them!!')

    end
else
    %%For SPARK data
    PATDIRECTORY = ['\Patient Files\' num2str(PATNUM) '\'];
    CENTROIDFILE = ls([PATDIRECTORY '*.txt'])
    
end



filename = [PATDIRECTORY CENTROIDFILE];
    
delimiter = ',';
formatSpec = '%s%s%s%s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[2,3,4]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(thousandsRegExp, ',', 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end

Data = raw(:, [2,3,4]);
rawCellColumns = raw(:, 1);

%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),Data); % Find non-numeric cells
Data(R) = {NaN}; % Replace non-numeric cells

%% Assign variables
MRN = Data{2,1};
Apex = [Data{3,1} Data{3,2} Data{3,3}];
Left = [Data{4,1} Data{4,2} Data{4,3}];
Right= [Data{5,1} Data{5,2} Data{5,3}];
SimCent = [Data{6,1} Data{6,2} Data{6,3}];

%% Convert to isocentre coord (where SimCent is at [0 0 0]) and convert to mm
Apex = (Apex - SimCent)*10;
Left = (Left - SimCent)*10;
Right = (Right - SimCent)*10;
IsoCent = (SimCent - SimCent)*10;

%%Flip Y and then Swap Y and Z coords.
Apex = [Apex(1) Apex(3) -Apex(2)];
Left = [Left(1) Left(3) -Left(2)];
Right = [Right(1) Right(3) -Right(2)];
IsoCent = [IsoCent(1) IsoCent(3) -IsoCent(2)];


%% Sort markers depending on the SI position 

array = [Apex(2) Left(2) Right(2)];
sortedArray = sort(array, 'descend');
indexes = [find(sortedArray(1) == array) find(sortedArray(2) == array) find(sortedArray(3) == array)];
 for n=1:3
    if indexes(n) == 1
         eval(['Marker.x' num2str(n) '= Apex(1)']);
         eval(['Marker.y' num2str(n) '= Apex(2)']);
         eval(['Marker.z' num2str(n) '= Apex(3)']);
    elseif indexes(n) == 2
         eval(['Marker.x' num2str(n) '= Left(1)']);
         eval(['Marker.y' num2str(n) '= Left(2)']);
         eval(['Marker.z' num2str(n) '= Left(3)']);
    else indexes(n) == 3
         eval(['Marker.x' num2str(n) '= Right(1)']);
         eval(['Marker.y' num2str(n) '= Right(2)']);
         eval(['Marker.z' num2str(n) '= Right(3)']);
    end        
 end

Marker1 = [Marker.x1 Marker.y1 Marker.z1];
Marker2 = [Marker.x2 Marker.y2 Marker.z2];
Marker3 = [Marker.x3 Marker.y3 Marker.z3];
Refpose = [Marker1; Marker2; Marker3];
ActualCentroid = [(Marker1(1)+Marker2(1)+Marker3(1))/3; (Marker1(2)+Marker2(2)+Marker3(2))/3; (Marker1(3)+Marker2(3)+Marker3(3))/3];

%% Clear temporary variables
clearvars filename delimiter formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me rawCellColumns R;
clearvars Apex array indexes Data IsoCent Left n Right SimCent sortedArray

end