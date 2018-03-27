%----------------------------------------------------------------------
% [ret] = highpass_simple (source,order, cut_off_freq)
% highpass filter를 좀 더 쉽게 사용하기 위한 함수
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Post-Doc @  Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
%---------------------------------------------------------------------
function [ret] = highpass_simple (source,order, cut_off_freq,sampling_rates)
    [a b] = butter(order,cut_off_freq/(sampling_rates/2),'high'); %sampling # = 2048.  cut-off freq is 1hz. order is 1
    %f = filter(a,b,source);
    ret = filtfilt(a,b,source);
end