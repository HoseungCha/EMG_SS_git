function initial_buffer_initiation()
%INITIAL_BUFFER_INITIATION
%% Experiment Buffer Settings

global buffer;
global params;
global raw_signal_reserve;
global g_handles;

ExtendFactor = fix(1/params.DelayTime);

EMG_channel_length=params.CompNum;
%% online downsampling
buffer.DM_sig = online_downsample_init(params.DecimateFactor); % Online downsample buffer
buffer.DM_trg = online_downsample_init(params.DecimateFactor); % Online downsample buffer

%% circle queue
buffer.dataqueue   = circlequeue(params.QueueLength, EMG_channel_length+3); % 10 + 3(귓볼 2개, Trigger1개)
buffer.raw_dataqueue   = circlequeue(params.QueueLength, EMG_channel_length+3);
buffer.dataqueue.data(:,:) = NaN;
buffer.raw_dataqueue.data(:,:) = NaN;
raw_signal_reserve.mat = zeros(params.SamplingFrequency2Use * 1800, EMG_channel_length+3); % 1800초 데이터 preallocating
%% parameters
buffer.recent_n_data = zeros(ExtendFactor*params.DataAcquisitionTime, 1);
buffer.recent_n_data_valid = zeros(ExtendFactor*params.DataAcquisitionTime, 1);
buffer.n_trial=1; % trial 초기화
buffer.n_count_result_showing=0; % 0.25 *4 에한번씩 그림을 보여줌
buffer.epoching_settingOn=0;
buffer.epching_count=0;
% buffer.current_buffer_end_idx = 1;
% buffer.calibration_end_idx = 1;
% buffer.Recalibration_status = 0;
buffer.timer_id_displaying = struct;
raw_signal_reserve.n_data = 0;

end

