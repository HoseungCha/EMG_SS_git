function message = trial_go_prev(input_num)

global buffer;
global params;

if nargin < 1
    input_num = buffer.n_trial - 1;
    params.training_sequence = circshift(params.training_sequence, +1);
end

if input_num > 0
    if ischar(input_num)
        buffer.n_trial=str2double(input_num);
    else
        buffer.n_trial=input_num;
    end
    message = ['Moved to the designated trial. Current trial # : ', num2str(buffer.n_trial)];
%     params.training_sequence = circshift(params.training_sequence, +1);
elseif input_num <= 0
    message = ['This is the first trial. Current trial # : ', num2str(buffer.n_trial)];
end

% ExtendFactor = fix(1/params.DelayTime);
% buffer.Calib_or_Acquisition = [ones(1, ExtendFactor*params.CalibrationTime), zeros(1, ExtendFactor*params.DataAcquisitionTime), 2.* ones(1, ExtendFactor*params.ResultShowTime)];
%% show progress matin console
% set(g_handles.console, 'String', message);
end

