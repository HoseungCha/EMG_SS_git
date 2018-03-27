function [P1,f]=simple_fft(rawdata,Fs)
% option_plot = 'plot' --> plot
        
T = 1/Fs;             % Sampling period
L = length(rawdata);             % Length of signal
t = (0:L-1)*T;        % Time vector

Y = fft(rawdata);

P2 = abs(Y/L);
P1 = P2(1:floor(L/2+1));
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;


end


