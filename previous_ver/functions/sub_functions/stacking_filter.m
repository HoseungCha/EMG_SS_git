function Stacked_features_from_time=stacking_filter(features, nRange2Stacking,numberoffeatures)
%  features (features, timeframe)
Stacked_features_from_time=zeros((2*nRange2Stacking+1)*numberoffeatures,length(features)-(2*nRange2Stacking+1));
Stacked_features=[];
for tf=1:length(features)-nRange2Stacking;
    if tf<=nRange2Stacking || tf>= length(features)-nRange2Stacking
        
    else
        Stacked_features=[];
        for kk=tf-nRange2Stacking:tf+nRange2Stacking
        Stacked_features=...
            [Stacked_features;features(:,kk)];
        end
        Stacked_features_from_time(:,tf-nRange2Stacking)= Stacked_features;   
    end
    
end
end