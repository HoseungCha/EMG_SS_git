function trial_control_main()

global params;
global buffer;
global g_handles;
global timer_id_data;
global tic_t;

status = buffer.Calib_or_Acquisition(1);
isLastSec = status > buffer.Calib_or_Acquisition(2);
isFirstSec = status > buffer.Calib_or_Acquisition(end) ...
    || buffer.Calib_or_Acquisition(end) == 2;

isFirstResultShowing = (status - buffer.Calib_or_Acquisition(end) == 2);
isLastResultShowing = (status == 2 && buffer.Calib_or_Acquisition(2) == 1);

isFirstAcq = (status == 0 && buffer.Calib_or_Acquisition(end) == 1);

if status == 1 % Calibration Mode
    if strcmp(buffer.timer_id_displaying.Running, 'on')
        stop(buffer.timer_id_displaying)
    end
    
    if isFirstSec && ~buffer.Recalibration_status
        tic_t = tic;
    
        if buffer.n_session == 1
        [ready_beep, Fs] = audioread([pwd, '\resources\sound\voice\beep_start_center.wav']);
        Snd('Play', ready_beep', Fs); WaitSecs(length(ready_beep)/Fs);
        end
        
        set(g_handles.system_message, 'String', 'Calibration Mode');
        set(g_handles.console, 'String', ['Session # : ' num2str(buffer.n_session)]);
        if params.DummyMode
           %%%
           number_examples_for_dummy_mode(num2str(buffer.dummy_idx(1)));
           buffer.dummy_idx = circshift(buffer.dummy_idx, -1);
           %%%
        end

    elseif isFirstSec && buffer.Recalibration_status
        set(g_handles.system_message, 'String', 'Re-do Calibration Mode');
        
        [beep, Fs] = audioread([pwd, '\resources\sound\voice\recalibration.wav']);
        Snd('Play', beep', Fs); WaitSecs(length(beep)/Fs);
    end
    
    session_calibration(isFirstSec, isLastSec);
    
elseif status == 0 % Data Acquisition Mode
    if strcmp(buffer.timer_id_displaying.Running, 'off')
        start(buffer.timer_id_displaying);
    end
    set(g_handles.system_message, 'String', 'Data Acquisition Mode');
    
    if isFirstAcq
        
        if buffer.n_session <= 26
            what_char = char(double('a'-1) + (buffer.n_session));
            [beep, Fs] = audioread([pwd, ['\resources\sound\voice\voice_' what_char '.wav']]);
            Snd('Play', beep', Fs); WaitSecs(length(beep)/Fs);
        elseif buffer.n_session > 26 && buffer.n_session < 30
            [beep, Fs] = audioread([pwd, ['\resources\sound\voice\voice_', ...
                num2str(buffer.n_session), '.wav']]);
            Snd('Play', beep', Fs); WaitSecs(length(beep)/Fs);
        end
        
        [beep, Fs] = audioread([pwd, '\resources\sound\voice\start.wav']);
        Snd('Play', beep', Fs); WaitSecs(length(beep)/Fs);
        Beeper(2000, 0.8, 0.1);
    end
    session_data_acquisition();
    
elseif status == 2 % Result Showing
    if isFirstResultShowing
                
        if strcmp(buffer.timer_id_displaying.Running, 'on')
            stop(buffer.timer_id_displaying)
        end
        
        set(g_handles.system_message, 'String', 'Result Showing Mode');
        
        % Sound Beep
%         [beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);
%         sound(beep, Fs); % sound beep

        session_retrieve_data();
        draw_touchscreen_trail();
        
        if mod(buffer.n_session, 7) == 0 && buffer.n_session < 28
            session_subject_rest(20);
        elseif buffer.n_session == 29
            [beep, Fs] = audioread([pwd, '\resources\sound\voice\set_end.wav']);
            Snd('Play', beep', Fs); WaitSecs(length(beep)/Fs);
            
            [beep, Fs] = audioread([pwd, '\resources\sound\voice\wait.wav']);
            Snd('Play', beep', Fs); WaitSecs(length(beep)/Fs);
            
            session_stop();
            set(g_handles.system_message, 'String', 'Set Done. You should save the data.');
            
        else
            session_subject_rest();
        end
    end
    
    % Check User's Feedback
    if isLastResultShowing

        buffer.n_session = buffer.n_session + 1;
        toc(tic_t);
%         stop(timer_id_data);
%         
%         FlushEvents('keyDown');
%         ListenChar(2);
%         str_input = GetChar;
%         disp(['User Input : ', str_input]);
%         
%         % Reject
%         if strcmp(str_input, 'X') || strcmp(str_input, 'x') 
%             str_show = 'The previous session was rejected.';
%             disp(str_show);
%             screen_init_psy(str_show);
%             WaitSecs(1.0);
%         else
%             
%         end
%         
%         start(timer_id_data);
    end

%     num_char = number_recognition();
%     string_to_keyboard_input(buffer.selected_key);
end

buffer.Calib_or_Acquisition = circshift(buffer.Calib_or_Acquisition', -1);
buffer.Calib_or_Acquisition = buffer.Calib_or_Acquisition';

end

