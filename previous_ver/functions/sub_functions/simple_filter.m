function filtered_data=simple_filter(rawdata,freq_band,order,Fs,ftype)
%% Band pass filter
       X = rawdata;
       n = 1;
       Wn = freq_band;                                % filtering frequencies
       Fn = Fs/2;
%        ftype = 'bandpass';
       [b Vriable] = butter(n, Wn/Fn, ftype);
       Y = filtfilt(b, Vriable, X);
       filtered_data = Y; %#ok<AGROW>
end