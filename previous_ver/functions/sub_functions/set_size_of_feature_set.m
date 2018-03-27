function a=set_size_of_feature_set(trial_data,featurename)
% input trial data, feature name
if isstruct(getfield(trial_data{1,1}.Feature,featurename))
    eval(sprintf('a=length(trial_data{1, 1}.Feature.%s.mapped_data);',featurename));
else
    eval(sprintf('a=size(trial_data{1, 1}.Feature.%s,2);',featurename));
end

for i=1:size(trial_data,1)
    for j=1:size(trial_data,2)
        if isstruct(getfield(trial_data{1,1}.Feature,featurename))
            eval(sprintf('b=length(trial_data{i, j}.Feature.%s.mapped_data);',featurename));
            
        else
            eval(sprintf('b=size(trial_data{i, j}.Feature.%s,2);',featurename));
        end
        %         if size(trial_data{i, j}.Feature.featurename,2)<a
        if b<a
            a=b;
            %             b=[i,j];
            %             disp(trial_data{3, 30}.saved_time );
        else
            continue
        end
    end
end
end