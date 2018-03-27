function a=set_size_of_data_settrial_data(trial_data)
% data size
% global buffer

a=size(trial_data{1, 1}.data_queue,1);

for i=1:size(trial_data,1)
    for j=1:size(trial_data,2)
        
        if size(trial_data{i, j}.data_queue,1)<a
            a=size(trial_data{i, j}.data_queue,1);
%             b=[i,j];
%             disp(trial_data{3, 30}.saved_time );
        else 
            continue
        end
    end
end
end