function initial_buffer_initiation_for_externaldataset()
%INITIAL_BUFFER_INITIATION
% Experiment Buffer Settings

global buffer;

% buffer.X = 0; buffer.X_train = 0;
% buffer.Y = params.default_fixation_y; buffer.Y_train = 0;
% ExtendFactor = fix(1/params.DelayTime);
% buffer.Calib_or_Acquisition = [ones(1, ExtendFactor*params.CalibrationTime), zeros(1, ExtendFactor*params.DataAcquisitionTime), 2.* ones(1, ExtendFactor*params.ResultShowTime)];

% buffer.DM = online_downsample_init(params.DecimateFactor); % Online downsample buffer
% buffer.DM_BK = online_downsample_init(params.blink.DecimateRate); % Online downsample buffer for Blink Detector
% buffer.buffer_4medianfilter = circlequeue(params.medianfilter_size, params.CompNum);
% 
% buffer.dataqueue   = circlequeue(params.QueueLength, params.CompNum);
% buffer.dataqueue.data(:,:) = NaN;
% 
% buffer.raw_dataqueue   = circlequeue(params.QueueLength, params.CompNum);
% buffer.raw_dataqueue.data(:,:) = NaN;

% buffer.drift_removal_queue = circlequeue(params.DriftRemovalLength, params.CompNum);
% buffer.drift_removal_queue.data(:,:) = NaN;
% buffer.drift_pol_y = [0, 0];

% buffer.eye_position_queue = circlequeue(params.QueueLength, params.CompNum);
% buffer.eye_position_queue.data(:,:) = NaN;

% buffer.eye_position_queue_px = circlequeue(params.QueueLength, params.CompNum);
% buffer.eye_position_queue_px.data(:,:) = NaN;

% buffer.recent_n_data = zeros(ExtendFactor*params.DataAcquisitionTime, 1);
% buffer.recent_n_data_valid = zeros(ExtendFactor*params.DataAcquisitionTime, 1);

% buffer.screen_refresh_idx = 1:ExtendFactor*params.screen_refresh_frequency;
buffer.current_buffer_end_idx = 1;

% buffer.dummy_idx = (0:9)';
% buffer.selected_key = '';

buffer.n_trial = 1; 
% buffer.trial_data = cell(1, 1);
buffer.n_sequence=1;
buffer.calibration_end_idx = 1;
buffer.Recalibration_status = 0;

% buffer.timer_id_displaying = struct;

% raw_signal_reserve.mat = zeros(params.SamplingFrequency2Use * 3600, params.CompNum+1);
% raw_signal_reserve.n_data = 0;

end

