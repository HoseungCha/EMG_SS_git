function y=EMG_feature_extraction(data,feature_type)
% This function was developed by Hoseung Cha
% Nw= window (samples)
% Ns= overlap size (samples)
% feature_type = name of feature to use
% compute possible windows


% initialize

x=data;
if strcmp(feature_type,'RMS')
    y=rms(x);
end
if strcmp(feature_type,'MAV')
    y=meanabs(x);
end
if strcmp(feature_type,'MAX_MIN')
    y=max(x)-min(x);
end
if strcmp(feature_type,'TEAGER')
    x_teager=cal_freqweighted_energy(x,1,'teager');
    y=sum(x_teager)/length(x_teager);
end
if strcmp(feature_type,'envelope_diff')
    try
    x_envelope_diff=cal_freqweighted_energy(x',1,'envelope_diff');
    y=sum(x_envelope_diff)/length(x_envelope_diff);
    catch
        keyboard
    end
end
if strcmp(feature_type,'env_only')
    x_env_only=cal_freqweighted_energy(x,1,'env_only');
    y=sum(x_env_only)/length(x_env_only);
end
if strcmp(feature_type,'palmu')
    x_palmu=cal_freqweighted_energy(x,1,'palmu');
    y=sum(x_palmu)/length(x_palmu);
end
% if strcmp(feature_type,'TEAGER_ratio')
%     onset=round(length(x)/3);
%     x_teager=cal_freqweighted_energy(x,1,'teager');  
%     
%     y=sum(x_teager(1:onset-1))/sum(x_teager(onset:end));
% end
if strcmp(feature_type,'AR1')
    order=1;
    y = getarfeat(x,order);
end
if strcmp(feature_type,'WL')
    y = getwlfeat(x);
end
if strcmp(feature_type,'ZC')
    y = ZCR(x);
end
if strcmp(feature_type,'ACTIVITY')
    y=var(x,1);
end
if strcmp(feature_type,'MOBILITY')
    vx=var(x,1);
    vxdiff=var(diff(x),1);
    y=sqrt(vxdiff/vx);
end
if strcmp(feature_type,'COMPLEXITY')
    vx=var(diff(x),1);
    vxdiff=var(diff(diff(x)),1);
    diff_mobility=sqrt(vxdiff/vx);    
    
    vx=var(x,1);
    vxdiff=var(diff(x),1);
    mobility=sqrt(vxdiff/vx);
    
    y=diff_mobility/mobility;
    
end


end