function data = ImportEDFHeader(filename,varargin)
%
% aux file for vsareadEDFHeader en construct generic data format
%

%
% (C) 2001, H.Steven Scholte
% version 1.0
%

constants;
genericFlag = 1;
for cArguments=1:max(size(varargin))
    if strcmp(varargin(cArguments),'generic') == 1
        genericFlag = 0;
    end        
end 

fid=fopen([filename '.bdf'],'r','b');
disp(['reading bdf header of ' filename]);

if fid == -1
    ferror(fid);
end    

version                 = fread(fid,8,'char')';               % version of data format
identify                = char(version(2:8));
if strcmp(identify,'BIOSEMI') ~= 1
    fclose(fid);
    error('this is not a biosemi bdf file');
end

data.nSamples           = 0;
data.nTrials            = 0;
data.negTrialSize       = 0;
data.sampleRate         = 0;
data.channels           = 0;
data.n_filters          = 0;
data.filters            = [];
data.filtersAux         = 0;
data.subjectId          = char(fread(fid,80,'char')');              % patient ID
data.rundescription     = char(fread(fid,80,'char')');              % recording information
data.dataDate           = char(fread(fid,8,'char')');               % date of recording
data.dataTime           = char(fread(fid,8,'char')');               % start of recording
numberOfBytesInHeader   = fread(fid,8,'char');                      % number of bytes in header record
manufacturer            = fread(fid,44,'char');                                               % reserved
if strcmp(char(manufacturer(1:5)'),'24BIT') ~= 1
    fclose(fid);
    error('this is not a biosemi bdf file');
end
data.nTrials            = str2num(char(fread(fid,8,'char')'));      % number of data records (would be number of trials in CTF)
data.epochTime          = str2num(char(fread(fid,8,'char')'));      % duration of data record (in seconds)
data.channels           = str2num(char(fread(fid,4,'char')'));      % number of samples per trial (in seconds)
data.dataSize           = 3;
data.type               = RAW;
data.dataFormat         = BDF;

% 1 is x -10 is achter 10 is voor
% 2 is y  - is links, + is rechts
% 3 is z - is beneden + is boven

for cChannels = 1:data.channels
    chanName = char(fread(fid,16,'char')');
    if genericFlag == 1
        if cChannels == 1
            data.sensor.chanName(cChannels) = {'P3'};
            data.sensor.headcoilMeasure(1,cChannels) = -5.6472;
            data.sensor.headcoilMeasure(2,cChannels) = 5.6472;
            data.sensor.headcoilMeasure(3,cChannels) = 6.0182;
        elseif cChannels == 2 
            data.sensor.chanName(cChannels) = {'PO7'};   
            data.sensor.headcoilMeasure(1,cChannels) = -8.0902;
            data.sensor.headcoilMeasure(2,cChannels) = 5.8779;
            data.sensor.headcoilMeasure(3,cChannels) = 0;
        elseif cChannels == 3
            data.sensor.chanName(cChannels) = {'PO3'};
            data.sensor.headcoilMeasure(1,cChannels) = -8.5355;
            data.sensor.headcoilMeasure(2,cChannels) = 3.5355;
            data.sensor.headcoilMeasure(3,cChannels) = 3.8268;
        elseif cChannels == 4 
            data.sensor.chanName(cChannels) = {'O1'};
            data.sensor.headcoilMeasure(1,cChannels) = -9.5106;
            data.sensor.headcoilMeasure(2,cChannels) = 3.0902;
            data.sensor.headcoilMeasure(3,cChannels) = 0;
        elseif cChannels == 5
            data.sensor.chanName(cChannels) = {'I1'};
            data.sensor.headcoilMeasure(1,cChannels) = -9.1528;
            data.sensor.headcoilMeasure(2,cChannels) = 2.4202;
            data.sensor.headcoilMeasure(3,cChannels) = -3.3202;
        elseif cChannels == 6
            data.sensor.chanName(cChannels) = {'OZ'};    
            data.sensor.headcoilMeasure(1,cChannels) = -10;
            data.sensor.headcoilMeasure(2,cChannels) = 0;
            data.sensor.headcoilMeasure(3,cChannels) = 0;
        elseif cChannels == 7
            data.sensor.chanName(cChannels) = {'IZ'};
            data.sensor.headcoilMeasure(1,cChannels) = -9.0631;
            data.sensor.headcoilMeasure(2,cChannels) = 0;
            data.sensor.headcoilMeasure(3,cChannels) = -3.4202;
        elseif cChannels == 8
            data.sensor.chanName(cChannels) = {'I2'};
            data.sensor.headcoilMeasure(1,cChannels) = -9.1528;
            data.sensor.headcoilMeasure(2,cChannels) = -2.4202;
            data.sensor.headcoilMeasure(3,cChannels) = -3.2202;
        elseif cChannels == 9
            data.sensor.chanName(cChannels) = {'O2'};
            data.sensor.headcoilMeasure(1,cChannels) = -9.5106;
            data.sensor.headcoilMeasure(2,cChannels) = -3.0902;
            data.sensor.headcoilMeasure(3,cChannels) = 0;            
        elseif cChannels == 10
            data.sensor.chanName(cChannels) = {'PO4'};
            data.sensor.headcoilMeasure(1,cChannels) = -8.5355;
            data.sensor.headcoilMeasure(2,cChannels) = -3.5355;
            data.sensor.headcoilMeasure(3,cChannels) = 3.8268;
        elseif cChannels == 11
            data.sensor.chanName(cChannels) = {'P4'};
            data.sensor.headcoilMeasure(1,cChannels) = -5.6472;
            data.sensor.headcoilMeasure(2,cChannels) = -5.6472;
            data.sensor.headcoilMeasure(3,cChannels) = 6.0182;
        elseif cChannels == 12
            data.sensor.chanName(cChannels) = {'PO8'};
            data.sensor.headcoilMeasure(1,cChannels) = -8.0902;
            data.sensor.headcoilMeasure(2,cChannels) = -5.8779;
            data.sensor.headcoilMeasure(3,cChannels) = 0;
        elseif cChannels == 13
            data.sensor.chanName(cChannels) = {'P1'};
            data.sensor.headcoilMeasure(1,cChannels) = -7.2803;
            data.sensor.headcoilMeasure(2,cChannels) = 3.0156;
            data.sensor.headcoilMeasure(3,cChannels) = 6.1566;
        elseif cChannels == 14
            data.sensor.chanName(cChannels) = {'PZ'};
            data.sensor.headcoilMeasure(1,cChannels) = -6.5606;
            data.sensor.headcoilMeasure(2,cChannels) = 0;
            data.sensor.headcoilMeasure(3,cChannels) = 7.5471;            
        elseif cChannels == 15
            data.sensor.chanName(cChannels) = {'P2'};        
            data.sensor.headcoilMeasure(1,cChannels) = -7.2803;
            data.sensor.headcoilMeasure(2,cChannels) = -3.0156;
            data.sensor.headcoilMeasure(3,cChannels) = 6.1566;            
        elseif cChannels == 16
            data.sensor.chanName(cChannels) = {'POZ'};
            data.sensor.headcoilMeasure(1,cChannels) = -9.2388;
            data.sensor.headcoilMeasure(2,cChannels) = 0;
            data.sensor.headcoilMeasure(3,cChannels) = 3.8268;            
        elseif cChannels == 17
            data.sensor.chanName(cChannels) = {'FP1'};
            data.sensor.headcoilMeasure(1,cChannels) = 9.5106;
            data.sensor.headcoilMeasure(2,cChannels) = 3.0902;
            data.sensor.headcoilMeasure(3,cChannels) = 0;            
        elseif cChannels == 18
            data.sensor.chanName(cChannels) = {'FZ'};
            data.sensor.headcoilMeasure(1,cChannels) = 6.5606;
            data.sensor.headcoilMeasure(2,cChannels) = 0;
            data.sensor.headcoilMeasure(3,cChannels) = 7.5471;            
        elseif cChannels == 19
            data.sensor.chanName(cChannels) = {'FCZ'};
            data.sensor.headcoilMeasure(1,cChannels) = 3.2557;
            data.sensor.headcoilMeasure(2,cChannels) = 0;
            data.sensor.headcoilMeasure(3,cChannels) = 9.4552;            
        elseif cChannels == 20
            data.sensor.chanName(cChannels) = {'FC1'};
            data.sensor.headcoilMeasure(1,cChannels) = 3.3197;
            data.sensor.headcoilMeasure(2,cChannels) = 3.3197;
            data.sensor.headcoilMeasure(3,cChannels) = 8.8295;
        elseif cChannels == 21
            data.sensor.chanName(cChannels) = {'F3'};
            data.sensor.headcoilMeasure(1,cChannels) = 5.6472;
            data.sensor.headcoilMeasure(2,cChannels) = 5.6472;
            data.sensor.headcoilMeasure(3,cChannels) = 6.0182;
        elseif cChannels == 22
            data.sensor.chanName(cChannels) = {'FC5'};
            data.sensor.headcoilMeasure(1,cChannels) = 3.4609;
            data.sensor.headcoilMeasure(2,cChannels) = 8.5661;
            data.sensor.headcoilMeasure(3,cChannels) = 3.8268;
        elseif cChannels == 23
            data.sensor.chanName(cChannels) = {'C3'};
            data.sensor.headcoilMeasure(1,cChannels) = 0;
            data.sensor.headcoilMeasure(2,cChannels) = 6.5606;
            data.sensor.headcoilMeasure(3,cChannels) = 7.5471;
        elseif cChannels == 24
            data.sensor.chanName(cChannels) = {'CP1'};
            data.sensor.headcoilMeasure(1,cChannels) = -3.3197;
            data.sensor.headcoilMeasure(2,cChannels) = 3.3197;
            data.sensor.headcoilMeasure(3,cChannels) = 8.8295;
        elseif cChannels == 25
            data.sensor.chanName(cChannels) = {'F7'};        
            data.sensor.headcoilMeasure(1,cChannels) = 5.8779;
            data.sensor.headcoilMeasure(2,cChannels) = 8.0902;
            data.sensor.headcoilMeasure(3,cChannels) = 0;
        elseif cChannels == 26
            data.sensor.chanName(cChannels) = {'T7'};
            data.sensor.headcoilMeasure(1,cChannels) = 0;
            data.sensor.headcoilMeasure(2,cChannels) = 10;
            data.sensor.headcoilMeasure(3,cChannels) = 0;
        elseif cChannels == 27
            data.sensor.chanName(cChannels) = {'C5'};
            data.sensor.headcoilMeasure(1,cChannels) = 0;
            data.sensor.headcoilMeasure(2,cChannels) = 9.2388;
            data.sensor.headcoilMeasure(3,cChannels) = 3.8268;
        elseif cChannels == 28
            data.sensor.chanName(cChannels) = {'CP5'};
            data.sensor.headcoilMeasure(1,cChannels) = -3.5355;
            data.sensor.headcoilMeasure(2,cChannels) = 8.5355;
            data.sensor.headcoilMeasure(3,cChannels) = 3.8268;
        elseif cChannels == 29
            data.sensor.chanName(cChannels) = {'TP7'};
            data.sensor.headcoilMeasure(1,cChannels) = -3.0902;
            data.sensor.headcoilMeasure(2,cChannels) = 9.5106;
            data.sensor.headcoilMeasure(3,cChannels) = 0;            
        elseif cChannels == 30
            data.sensor.chanName(cChannels) = {'P5'};
            data.sensor.headcoilMeasure(1,cChannels) = -6.5328;
            data.sensor.headcoilMeasure(2,cChannels) = 6.5328;
            data.sensor.headcoilMeasure(3,cChannels) = 3.8268; 
        elseif cChannels == 31
            data.sensor.chanName(cChannels) = {'P7'};
            data.sensor.headcoilMeasure(1,cChannels) = -5.8779;
            data.sensor.headcoilMeasure(2,cChannels) = 8.0902;
            data.sensor.headcoilMeasure(3,cChannels) = 0; 
        elseif cChannels == 32
            data.sensor.chanName(cChannels) = {'P9'};
            data.sensor.headcoilMeasure(1,cChannels) = -5.5234;
            data.sensor.headcoilMeasure(2,cChannels) = 7.6023;
            data.sensor.headcoilMeasure(3,cChannels) = -3.4202; 
        elseif cChannels == 33
            data.sensor.chanName(cChannels) = {'P10'};
            data.sensor.headcoilMeasure(1,cChannels) = -5.5234;
            data.sensor.headcoilMeasure(2,cChannels) = -7.6023;
            data.sensor.headcoilMeasure(3,cChannels) = -3.4202; 
        elseif cChannels == 34
            data.sensor.chanName(cChannels) = {'P8'};
            data.sensor.headcoilMeasure(1,cChannels) = -5.8779;
            data.sensor.headcoilMeasure(2,cChannels) = -8.0902;
            data.sensor.headcoilMeasure(3,cChannels) = 0;             
        elseif cChannels == 35
            data.sensor.chanName(cChannels) = {'TP8'};
            data.sensor.headcoilMeasure(1,cChannels) = -3.0902;
            data.sensor.headcoilMeasure(2,cChannels) = -9.5106;
            data.sensor.headcoilMeasure(3,cChannels) = 0;             
        elseif cChannels == 36
            data.sensor.chanName(cChannels) = {'P6'};
            data.sensor.headcoilMeasure(1,cChannels) = -6.5328;
            data.sensor.headcoilMeasure(2,cChannels) = -6.5328;
            data.sensor.headcoilMeasure(3,cChannels) = 3.8268;
        elseif cChannels == 37
            data.sensor.chanName(cChannels) = {'CP6'};
            data.sensor.headcoilMeasure(1,cChannels) = -3.5355;
            data.sensor.headcoilMeasure(2,cChannels) = -8.5355;
            data.sensor.headcoilMeasure(3,cChannels) = 3.8268;
        elseif cChannels == 38
            data.sensor.chanName(cChannels) = {'T8'};
            data.sensor.headcoilMeasure(1,cChannels) = 0;
            data.sensor.headcoilMeasure(2,cChannels) = -10;
            data.sensor.headcoilMeasure(3,cChannels) = 0;
        elseif cChannels == 39
            data.sensor.chanName(cChannels) = {'C6'};
            data.sensor.headcoilMeasure(1,cChannels) = 0;
            data.sensor.headcoilMeasure(2,cChannels) = -9.2388;
            data.sensor.headcoilMeasure(3,cChannels) = 3.8268; 
        elseif cChannels == 40
            data.sensor.chanName(cChannels) = {'C4'};
            data.sensor.headcoilMeasure(1,cChannels) = 0;
            data.sensor.headcoilMeasure(2,cChannels) = -6.5606;
            data.sensor.headcoilMeasure(3,cChannels) = 7.5471; 
        elseif cChannels == 41
            data.sensor.chanName(cChannels) = {'FC6'};
            data.sensor.headcoilMeasure(1,cChannels) = 3.4609;
            data.sensor.headcoilMeasure(2,cChannels) = -8.5661;
            data.sensor.headcoilMeasure(3,cChannels) = 3.8268; 
        elseif cChannels == 42
            data.sensor.chanName(cChannels) = {'F4'};
            data.sensor.headcoilMeasure(1,cChannels) = 5.6472;
            data.sensor.headcoilMeasure(2,cChannels) = -5.6472;
            data.sensor.headcoilMeasure(3,cChannels) = 6.0182; 
        elseif cChannels == 43
            data.sensor.chanName(cChannels) = {'F8'};
            data.sensor.headcoilMeasure(1,cChannels) = 5.8779;
            data.sensor.headcoilMeasure(2,cChannels) = -8.0902;
            data.sensor.headcoilMeasure(3,cChannels) = 0; 
        elseif cChannels == 44
            data.sensor.chanName(cChannels) = {'FP2'};
            data.sensor.headcoilMeasure(1,cChannels) = 9.5106;
            data.sensor.headcoilMeasure(2,cChannels) = -3.0902;
            data.sensor.headcoilMeasure(3,cChannels) = 0; 
        elseif cChannels == 45
            data.sensor.chanName(cChannels) = {'CP2'};
            data.sensor.headcoilMeasure(1,cChannels) = -3.3197;
            data.sensor.headcoilMeasure(2,cChannels) = -3.3197;
            data.sensor.headcoilMeasure(3,cChannels) = 8.8295; 
        elseif cChannels == 46
            data.sensor.chanName(cChannels) = {'CPZ'};
            data.sensor.headcoilMeasure(1,cChannels) = -3.2557;
            data.sensor.headcoilMeasure(2,cChannels) = 0;
            data.sensor.headcoilMeasure(3,cChannels) = 9.4552; 
        elseif cChannels == 47
            data.sensor.chanName(cChannels) = {'CZ'};                        
            data.sensor.headcoilMeasure(1,cChannels) = 0;
            data.sensor.headcoilMeasure(2,cChannels) = 0;
            data.sensor.headcoilMeasure(3,cChannels) = 10; 
        elseif cChannels == 48
            data.sensor.chanName(cChannels) = {'FC2'};
            data.sensor.headcoilMeasure(1,cChannels) = 3.3197;
            data.sensor.headcoilMeasure(2,cChannels) = -3.3197;
            data.sensor.headcoilMeasure(3,cChannels) = 8.8295; 
        elseif cChannels == 49
            data.sensor.chanName(cChannels) = {'EOG1'};
        elseif cChannels == 50
            data.sensor.chanName(cChannels) = {'EOG2'};
        elseif cChannels == 51
            data.sensor.chanName(cChannels) = {'Status'};        
        elseif cChannels == 52        
            data.sensor.chanName(cChannels) = {chanName(1:min(findstr(chanName,' ')))};
        end        
    else
        data.sensor.chanName(cChannels) = {removeSpaces(chanName)};
    end
    
    if strncmp(data.sensor.chanName{cChannels},'Sta',3) == 1;
        data.sensor.sensorType(cChannels)   =   STIM;
    elseif strncmp(data.sensor.chanName{cChannels},'EOG',3) == 1;
        data.sensor.sensorType(cChannels)   =   EOG;
    else strncmp(data.sensor.chanName{cChannels},'EEG',3) == 1;
        data.sensor.sensorType(cChannels)   =   EEG;
    end
end

for cChannels = 1:data.channels
    data.sensor.TransducerType{cChannels}   = char(fread(fid,80,'char')');
end    
for cChannels = 1:data.channels
    data.sensor.dimension{cChannels}        = char(fread(fid,8,'char')');    
end    
for cChannels = 1:data.channels
    data.sensor.physMinimum(cChannels)      = str2num(char(fread(fid,8,'char')'));    
end    
for cChannels = 1:data.channels    
    data.sensor.physMaximum(cChannels)      = str2num(char(fread(fid,8,'char')'));    
end 
for cChannels = 1:data.channels    
    data.sensor.digitalMinimum(cChannels)   = str2num(char(fread(fid,8,'char')'));
end
for cChannels = 1:data.channels    
    data.sensor.digitalMaximum(cChannels)   = str2num(char(fread(fid,8,'char')'));    
end
for cChannels = 1:data.channels    
    data.sensor.gain(cChannels)             = (data.sensor.physMaximum(cChannels)  - data.sensor.physMinimum(cChannels)) ./ (data.sensor.digitalMaximum(cChannels) -  data.sensor.digitalMinimum(cChannels));
end



for cChannels = 1:data.channels    
    data.sensor.preFiltering{cChannels}     = char(fread(fid,80,'char')');
end
for cChannels = 1:data.channels    
    data.sensor.numberOfSamples(cChannels)  = str2num(char(fread(fid,8,'char')'));
    data.sensor.sampleRate(cChannels)       = data.epochTime \ data.sensor.numberOfSamples(cChannels);
end

fread(fid,32*data.channels,'char');

if (data.channels+1)*256 ~= ftell(fid)
    error('something went wrong');
end

if length(unique(data.sensor.sampleRate)) == 1
    data.sampleRate = data.sensor.sampleRate(1);
end
if length(unique(data.sensor.numberOfSamples)) == 1
    data.nSamples = data.sensor.numberOfSamples(1);
end

% de header heeft nu de volgende omvang

sizeHeader = 256 + 256 * data.channels;
fseek(fid,0,'eof');
endOfFile=ftell(fid);

if data.nTrials == -1
    data.nTrials = (endOfFile - sizeHeader) / (data.nSamples * data.channels * data.dataSize);
elseif data.nTrials ~= (endOfFile - sizeHeader) / (data.nSamples * data.channels * data.dataSize)
    error('invalid file format');
end

fclose(fid);


function nameOut = removeSpaces(nameIn);
%
%
%

whites = findstr(nameIn,' ');
nTekens = max(size(nameIn));
nameOutCounter = 0;

for cTekens = 1:nTekens
    if(sum(find(whites == cTekens)) == 0)
        nameOutCounter = nameOutCounter;
        nameOut(nameOutCounter) = nameIn(cTekens);
    end
end