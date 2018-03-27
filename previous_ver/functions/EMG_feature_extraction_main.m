% function EMG_feature_extraction_main(trial_data)

% data retireve
% global params
% global buffer
data=trial_data ;
[N_text, N_sequence]=size(data);
% fList2extract={'AR'};
% fList2extract={'RMS';'MAV';'MAX_MIN';'TEAGER';
%     'AR1';'WL';'ZC';...
%     'ACTIVITY';'MOBILITY';'COMPLEXITY'};
fList2extract={'RMS';'MAX_MIN';'TEAGER';...
    'ACTIVITY';'MOBILITY';'COMPLEXITY'};
% confirm feature is saved before saving it
% if isfield(data{1,1},feature_type )
%     error('the feature data had been aleady saved.')
% end

% set parameter
h = waitbar(0,'Please wait...');
for ii=1:length(fList2extract)
feature_type=fList2extract{ii,1};
Nch=size(data{1, 1}.data_queue,2);
for i=1:N_text
    for j=1:N_sequence
        for nch=1:Nch
            tempdata = data{i, j}.data_queue(:,nch);
            eval(sprintf('Feature{i, j}.%s(:,nch)=EMG_feature_extraction(tempdata,feature_type);'...
                ,feature_type));            

        end       
    end
    messages=sprintf('%dth of feature extraction is progressed in %d',ii,length(fList2extract));
    waitbar(i / N_text,h,messages)
end
end
close(h)
uisave('Feature')
% end
