
function [concatenated_data]=get_matrix_from_celldata(trial_data)
%  load cell data and concatenating data as a matrix
%   get_matrix_from_celldata(save_path,Feature name)
% parameter
normalization=0;

% concatenating data as a matrix

[Nwords,Ntrials]=size(trial_data);
concatenated_data=[];
for i_Nwords=1:Nwords
    for i_Ntrials=1:10
        % rehsaping
        eval(sprintf('temp=trial_data{i_Nwords, i_Ntrials};'))
        
        data=reshape(temp',[1,size(temp,1)*size(temp,2)]);
        if(normalization)
            data=data/max(data);
        end
        concatenated_data=[concatenated_data;data];     
    end
end
end