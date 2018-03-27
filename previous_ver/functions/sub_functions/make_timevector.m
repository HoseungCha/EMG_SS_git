%% make_timevector(Ω≈»£(1 demnsion),Fs(sampling freq))
function t = make_timevector(y,Fs)
T = 1/Fs;                     % Sample time
L = length(y);                     % Length of signal
t = (0:L-1)*T;                % Time vector
end