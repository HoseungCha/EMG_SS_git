function [ raw_signal] = signal_receive_Biosemi()
%SIGNAL_RECEIVE_BIOSEMI
% Receives online raw data signal from Biosemi device

global params;
global buffer;
global g_handles;

try
    raw_signal = biosemix([params.numEEG params.numAIB]);
catch me
    if strfind(me.message,'BIOSEMI device')
        %         [beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);
        %         sound(beep, Fs); % sound beep
        set(g_handles.system_message, 'String', ...
            strrep([me.message 'Recalling the BIOSEMI device again.'], sprintf('\n'),'. '));
        
        clear biosemix;
        raw_signal = biosemix([params.numEEG params.numAIB]);
    else
        rethrow(me);
    end
end

%% Translate [from bit to voltage value]

% Change the signal from bit to voltage value
% data type is transformed into single for faster downsampling
sig = single(raw_signal(2:end,:)) * 0.262 / 2^31;
trg = raw_signal(1,:);
trg=double(trg);

%% Downsampling
if(params.DownSample)
    [buffer.DM_sig, sig] = online_downsample_apply(buffer.DM_sig, [sig]);
    [buffer.DM_trg, trg] = online_downsample_apply(buffer.DM_trg, [trg]);
end
% sig=dsampled_sig(:,2:end);
% Data type recovery into double
raw_signal = 10^6.*double(sig);
n_data = size(raw_signal,1);

    
    %% EMG Component Calculation
    
    if n_data <= 0
        raw_signal = [0 0 0 0 0];
    else
        BP12 = raw_signal(:, 1) - raw_signal(:, 2);
        BP13 = raw_signal(:, 1) - raw_signal(:, 3);
        BP14 = raw_signal(:, 1) - raw_signal(:, 4);
        BP23 = raw_signal(:, 2) - raw_signal(:, 3);
        BP24 = raw_signal(:, 2) - raw_signal(:, 4);
        BP34 = raw_signal(:, 3) - raw_signal(:, 4);
        Uni1 = raw_signal(:, 1);
        Uni2 = raw_signal(:, 2);
        Uni3 = raw_signal(:, 3);
        Uni4 = raw_signal(:, 4);
        Ref1 = raw_signal(:, 5);
        Ref2 = raw_signal(:, 6);
        
        raw_signal = 10^6.*[Uni1 Uni2 Uni3 Uni4 BP12 BP13 BP14 BP23 BP24,...
            BP34 Ref1 Ref2]; % Conversion into [uV]
        raw_signal=[raw_signal trg];
        
    end
    
end

