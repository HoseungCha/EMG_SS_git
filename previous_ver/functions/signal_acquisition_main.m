function [EMG] = signal_acquisition_main()
%SIGNAL_PROCESSING_MAIN
global params;
global buffer;
global raw_signal_reserve;
global g_handles;

%% EMG Components Calculation
if (params.DummyMode)

    EMG_channel_length=params.CompNum;
        
    % Dummy Signal Generation
    if(params.use_real_dummy == 1)
        % Pseaudo-real Signal
        EMG = buffer.dummy_signal(1:params.BufferLength_Biosemi, :);
        buffer.dummy_signal = circshift(buffer.dummy_signal, -params.BufferLength_Biosemi);
    else
        % Rectangular Pulse Train Signal
        c=clock; c=c(6); % use clock for generating dummy signal
        ExtendFactor = 1/params.DelayTime;
        
        t=repmat(linspace(c, c+6, 5.*params.BufferLength_Biosemi)',1,EMG_channel_length+3);
        t=t(1:params.BufferLength_Biosemi,:);
        
        sigmoid = 1./(1+exp(1).^(-1.2*log2(ExtendFactor))) - 0.5;
        EMG = 15 * pulstran(t, c+0.5, 'rectpuls', ExtendFactor*1/1) .* (rand>0.5+sigmoid) ...
            + 0.5 .* randn(params.BufferLength_Biosemi,EMG_channel_length+3) ...
            + 10;          
    end    
%     EMG = 30 * EMG; % conversion into [uV]
    n_data = params.BufferLength_Biosemi;
else
    % Real Signal
    EMG = signal_receive_Biosemi();
    n_data = size(EMG, 1);
end

%% Data Registration to Raw Signal Reserve

raw_signal_reserve.mat(raw_signal_reserve.n_data+1:raw_signal_reserve.n_data+n_data, :) = [EMG];
raw_signal_reserve.n_data = raw_signal_reserve.n_data + n_data;

%% EMG bandpass filtering
% if(params.bandpass_filtering)
%     % filtering
%     b=params.filter.b;
%     Vriable=params.filter.Vriable;
%     if isempty(params.filter.zf)
%         [EMG(:,1:params.CompNum),params.filter.zf] = filter(b, Vriable,EMG(:,1:params.CompNum), [],1);
%     else
%         [EMG(:,1:params.CompNum),params.filter.zf] = filter(b, Vriable, EMG(:,1:params.CompNum),params.filter.zf,1);
%     end
% %     EMG=simple_filter(EMG,[1,300],2,params.SamplingFrequency2Use,'bandpass'); % band pass filter
% end

%% Data Registration to Buffer Queue
for i=1:n_data
    buffer.dataqueue.add(EMG(i,:));
end


end

