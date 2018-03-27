function segment = biosemi_signal_recieve(ch)
% biosemi online input
%% BIOSEMIX 이용 코드
try
    segment = biosemix([ch 0]);
catch me
    if strfind(me.message,'BIOSEMI device')
        clear biosemix;
        segment = biosemix([ch 0]);
    else
        rethrow(me);
    end
end
segment = single(segment(2:end,:)) * 0.262 / 2^31;
segment = 10^6.*double(segment');
% %% TCP
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %    Copyright (C) 2015 Biosemi(Gerben Snoek <info@biosemi.com>) <www.biosemi.com> 
% %
% %    This source code is free software; you can redistribute it
% %    and/or modify it in source code
% %
% %    This program is distributed in the hope that it will be useful,
% %    but WITHOUT ANY WARRANTY; without even the implied warranty of
% %    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %   This program is written to provide a matlab example that demonstrate
% %   a tcp-ip streaming connection between Actiview and matlab.
% %   This example is made with matlab R2014a
% %   To use this example you have to adjust the settings between the
% %   configure tabs to match your setup.
% %   LabviewTCPExample is able to stream all data over the network from actiview 
% %   to the computer running LabviewTCPExample in matlab. 
% %   LabviewTCPExample can only display one channel at the same time.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% %configure% the folowing 4 values should match with your setings in Actiview and your network settings 
% port = 8888;                %the port that is configured in Actiview , delault = 8888
% ipadress = 'localhost';     %the ip adress of the pc that is running Actiview
% Channels = 8;             %set to the same value as in Actiview "Channels sent by TCP"
% Samples = 16;               %set to the same value as in Actiview "TCP samples/channel"
% %!configure%
% 
% %variable%
% DispChannel = 1;            %configures the channel that is displayed on startup
% words = Channels*Samples;
% loop = 1000;
% %pre allocate data_struct 
% data_struct = zeros(Samples*loop, Channels);
% data_struct2 = zeros(Samples, Channels);
% %!variable
% 
% %open tcp connection%
% tcpipClient = tcpip(ipadress,port,'NetworkRole','Client');
% set(tcpipClient,'InputBufferSize',words*9); %input buffersize is 3 times the tcp block size %1 word = 3 bytes
% set(tcpipClient,'Timeout',5);
% try
%     fopen(tcpipClient);
% catch
%     disp('Actiview is unreachable please check if Actiview is running on the specified ip address and port number');
%     run = false;
% end
% %!open tcp connection%
% 
% %setup gui% 
% screensize = get(0,'ScreenSize');
% displ = figure('position',[(screensize(3)-700)/2 , ((screensize(4)-500)/2) , 700 , 500], 'name','Labview tcp example','NumberTitle','off','MenuBar','none','CloseRequestFcn',@stop);
% subplot('position',[0.1 0.3 0.8 0.6]);
% uicontrol('Style', 'pushbutton', 'String', 'Stop', 'Position', [530 50 100 30],'Callback', @stop);
% uicontrol('Style', 'text', 'String', 'Channel','Position', [300 75 80 20]);
% selectstring = sprintf('%d|',1:Channels);
% uicontrol('Style', 'popup', 'String',selectstring(1:end-1) , 'Position', [300 20 80 50],'Value',DispChannel ,  'Callback', @dropdown);  
% drawnow;
% %!setup gui%
% 
% for L = 0 : loop-1
%     %read tcp block
%     [rawData,count,msg] = fread(tcpipClient,[3 words],'uint8');
%     if count ~= 3*words
%         disp(msg);
%         disp('Is Actiview running with the same settings as this example?');
%         break
%     end
%     %reorder bytes from tcp stream into 32bit unsigned words%
%     normaldata = rawData(3,:)*(256^3) + rawData(2,:)*(256^2) + rawData(1,:)*256 + 0;
%     %!reorder bytes from tcp stream into 32bit unsigned words%
%     
%     %reorder the channels into a array [samples channels]%
%     j = 1+(L*Samples) : Samples+(L*Samples);
%     i = 0 : Channels : words-1;%words-1 because the vector starts at 0
%     for d = 1 : Channels;
%         data_struct(j,d) = typecast(uint32(normaldata(i+d)),'int32'); %puts the data directly into the display buffer at the correct place
%         data_struct2(1:Samples,d) = typecast(uint32(normaldata(i+d)),'int32'); %create a data struct where each channel has a seperate collum
%     end
%     %!reorder the channels into a array [samples channels]%
%     
%     user_application(data_struct2); %example call for additional usercode.
%     
%     %break when stop is pressed
%     if run == false
%         break
%     end
% end
% 
% %cleanup%
% close(displ);
% delete(displ);
% fclose(tcpipClient);
% delete(tcpipClient);
% %!cleanup%





end