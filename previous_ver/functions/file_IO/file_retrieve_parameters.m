function file_retrieve_parameters(File_Header,filename)
%SIGNAL_INITIALIZE_BIOSEMI Summary of this function goes here
%   Detailed explanation goes here
global params;
global buffer;
global raw_signal_reserve;

param_names = fieldnames(File_Header.ExperimentParameters);
buffer_names = fieldnames(File_Header.ExperimentBuffers);

n_params = length(param_names);
n_buffer = length(buffer_names);

%% Parameter Setting

disp(['Loading parameter settings from a file ...' char(10)]);

if n_params > 0
    for i = 1:n_params

            params.(param_names{i}) = File_Header.ExperimentParameters.(param_names{i});

    end
end
params.filename=filename;
disp(params);

%% Buffer Setting

disp(['Loading buffer settings from a file ...' char(10)]);

if n_buffer > 0
    for i = 1:n_buffer
try
            buffer.(buffer_names{i}) = File_Header.ExperimentBuffers.(buffer_names{i});
catch
    keyboard
end
    end
end

disp(buffer);

%% Load Session Data

% buffer.trial_data = File_Header.TrialData;
% buffer.n_trial = length(File_Header.TrialData) + 1;

%% Raw Signal
raw_signal_reserve = File_Header.RawSignalReserve;

end