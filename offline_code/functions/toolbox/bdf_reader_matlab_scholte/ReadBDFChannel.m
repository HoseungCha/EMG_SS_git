function currentChannel = readbdfchannel(filename,channel);
%
% function currentChannel = readbdfchannel(filename,channel);
% function currentChannel = readbdfchannel('mw_signaltest',2);
%

%
% (C) H.Steven Scholte 2002
%

% hier nog checkExtension

data = ImportBDFHeader(filename);
realname = [filename, '.bdf'];
sizeHeader = 256 + 256 * data.channels;
fin = fopen(realname,'r');
fseek(fin,0,'eof');
endOfFile = ftell(fin);
fclose(fin);

currentChannel = ChannelReaderBDF(realname,data.channels,data.nSamples,data.nTrials,channel,data.sampleRate,endOfFile,sizeHeader)';
currentChannel = currentChannel*data.sensor.gain(channel);