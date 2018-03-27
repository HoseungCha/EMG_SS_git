function GDF_Header = file_initialize_Biosemi()
%SIGNAL_INITIALIZE_BIOSEMI Summary of this function goes here
%   Detailed explanation goes here
global params;
global buffer;
global raw_signal_reserve;

% S = biosemix; % run biosemi

GDF_Header.N_CH = params.numEEG + params.numAIB;
GDF_Header.TYPE = 'MAT';
GDF_Header.DATE = clock;

GDF_Header.ChannelLabel = cell(GDF_Header.N_CH, 1);
GDF_Header.ChannelLabel{1} = 'Trigger';
for i = 1:params.numEEG
    GDF_Header.ChannelLabel{i} = sprintf('Ch%03i', i);
end
for i = 1:params.numAIB
    GDF_Header.ChannelLabel{1+params.numEEG+i} = sprintf('AIB%03i', i);
end

GDF_Header.ExperimentParameters = params;
GDF_Header.ExperimentBuffers = buffer;
GDF_Header.RawSignalReserve = raw_signal_reserve;
end