%--------------------------------------------------------------------------
% by Ho-Seung Cha, Ph.D Student
% Ph.D candidate @ Department of Biomedical Engineering, Hanyang University
% hoseungcha@gmail.com
%--------------------------------------------------------------------------
function GUI_BEEP_sound()
global info;
    sound(info.beep, info.Beep_Fs); % sound beep
    pause(0.1);
end