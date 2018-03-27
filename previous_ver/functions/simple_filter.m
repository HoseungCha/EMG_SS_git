function filtered_data=simple_filter(rawdata,b,Vriable)
%% Band pass filter
filtered_data=zeros(size(rawdata,1),size(rawdata,2));
for ch=1:size(rawdata,2)
    X = rawdata(:,ch);
    Y = filtfilt(b, Vriable, X);
    filtered_data(:,ch) = Y;
end
end