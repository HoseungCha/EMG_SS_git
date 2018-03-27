function y=EMG_feature_extraction(data,Nw,Ns,feature_type)
% This function was developed by Hoseung Cha
% Nw= window (samples)
% Ns= overlap size (samples)
% feature_type = name of feature to use


% compute possible windows
N_windows=1;
while Nw*(N_windows)-Ns*(N_windows-1)<length(data)
    N_windows=N_windows+1;
end

% initialize
% http://arxiv.org/ftp/arxiv/papers/0912/0912.3973.pdf
y=zeros(N_windows-1,1);

for tf=1:N_windows-1;
    x=data((Nw-Ns)*(tf-1)+1:Nw*(tf)-Ns*(tf-1),1);

    if strcmp(feature_type,'RMS')  
        y(tf,1)=rms(x);
    end

    if strcmp(feature_type,'MAV')
        y(tf,1)=meanabs(x);
    end
    
    if strcmp(feature_type,'RMS_diff') % modified Mean Absolute Value 1
        if(tf==1)
            y(tf,1)=0;
        else            
            y(tf,1)=rms(x)-rms(data((Nw-Ns)*(tf-2)+1:Nw*(tf-1)-Ns*(tf-2),1));
        end
    end
%     
    
    if strcmp(feature_type(1:3),'SSI') % Simple Square Integral (energy of sEMG)
        temp=abs(x);
        y(tf,1)=sum(temp.^2);
    end    
    
%     if strcmp(feature_type(1:3),'SSI') % Simple Square Integral
%         y(tf,1)=meanabs(x);
%     end    
%     
%     if strcmp(feature_type(1:3),'SSI') % Simple Square Integral
%         y(tf,1)=meanabs(x);
%     end    
    
%     if strcmp(feature_type(1:3),'RMS')
%         features=get_time_domain_features...
%             (data,Nw,Ns,nRange2Average,nRange2Stacking,inputfeatures)
%     end
% 
%   
end
end