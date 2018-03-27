%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data_struct = TcpIpClientMatlabV1();

global info;
% global pd;
words = info.tcp.Channels*info.tcp.Samples;
loop = 7;
%pre allocate data_struct 
temp_data_struct = zeros(info.tcp.Samples*loop, info.tcp.Channels);
% data_struct2 = zeros(info.tcp.Samples, info.tcp.Channels);

[rawData,count,msg] = fread(info.tcpipClient,[3 words],'uint8');
if count ~= 3*words
    disp(msg);
    disp('Is Actiview info.TCP_running with the same settings as this example?');
    return;
end
%reorder bytes from tcp stream into 32bit unsigned words%
normaldata = rawData(3,:)*(256^3) + rawData(2,:)*(256^2) + rawData(1,:)*256 + 0;
%!reorder bytes from tcp stream into 32bit unsigned words%

for L = 0 : loop-1
%reorder the info.tcp.Channels into a array [info.tcp.Samples info.tcp.Channels]%
    j = 1+(L*info.tcp.Samples) : info.tcp.Samples+(L*info.tcp.Samples);
    i = 0 : info.tcp.Channels : words-1;%words-1 because the vector starts at 0
    for d = 1 : info.tcp.Channels;
        temp_data_struct(j,d) = typecast(uint32(normaldata(i+d)),'int32'); %puts the data directly into the display buffer at the correct place
    %     data_struct2(1:info.tcp.Samples,d) = typecast(uint32(normaldata(i+d)),'int32'); %create a data struct where each channel has a seperate collum
    end
end
data_struct = temp_data_struct(:,1:12);
% pd.TCP_buffer.addArray(data_struct(:,1:info.total_ch));
% disp(pd.TCP_buffer.datasize);
end
