function trial_stop()
%trial_STOP Summary of this function goes here
%   Detailed explanation goes here
global g_handles;

handles = g_handles;
[beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);

clear biosemix;
if ~isempty(timerfind)
    stop(timerfind);
    delete(timerfind);
end

set(handles.start_button, 'Enable', 'on');
set(handles.stop_button, 'Enable', 'off');
set(handles.initialize_button, 'Enable', 'on');

sound(beep, Fs); % sound beep
set(handles.system_message, 'String', 'Data acquisition has been stopped.');

end

