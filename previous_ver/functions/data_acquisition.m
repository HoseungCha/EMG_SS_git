function data_acquisition()
%DATAPROCESSING Summary of this function goes here
    
    global g_handles;
    global buffer;
    
    
    %% Signal Processing
    % data acquisition
    try
    EMG = signal_acquisition_main();
    n_data = size(EMG, 1);
      
    %% trigger(epoching and feature extraction) saveing 
    buffer.recent_n_data(1) = n_data;
    buffer.recent_n_data = circshift(buffer.recent_n_data, -1);
    trigger_data_main();   
    
    %% Visualization
    draw_realtime_signal(g_handles.current_signal1);
    draw_realtime_trigger(g_handles.trg_signal);
    catch error
        error
        keyboard
    end
end