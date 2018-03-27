function [f_target,f_output,f_names]=arrange_data2Confusion_simple(Classification_results,new_celldata)

% load name list to classify
max_word_length=[];
[N_text,~]=size(new_celldata);
namelist2classify=cell(size(Classification_results,1),1);
word_length=length(new_celldata{1, 1}.name);
for i=1:N_text
    if word_length<length(new_celldata{i, 1}.name)
        max_word_length=length(new_celldata{i, 1}.name);
    end
end
if isempty(max_word_length)
    max_word_length=word_length;
end
for i=1:N_text
    if max_word_length>length(new_celldata{i, 1}.name)
        diff_word_length=max_word_length-length(new_celldata{i, 1}.name);
        namelist2classify{i}=...
            strcat(new_celldata{i, 1}.name,repmat('_',[1,diff_word_length]));
    else
        namelist2classify{i}=new_celldata{i, 1}.name;
    end
end

names=cell(N_text,1);
target=cell(N_text,1);
output=cell(N_text,1);
[N_text, K]=size(Classification_results);
% K=1
for target_word=1:N_text
    % Output setting
    for k=1:K
        %     for k=3:3
        temp=Classification_results(target_word, k).index_of_Classified_word ;
        reshaped_d=reshape(temp,[size(temp,1)*size(temp,2), 1]);
        
        output{target_word}=[output{target_word}; reshaped_d];
    end
    idx_zero=find(output{target_word}==0);
    
    % Target Setting
    target{target_word}=ones(length(output{target_word}),1)*target_word;
    % Name Setting
    names{target_word}=repmat(namelist2classify{target_word} ,...
        [length(output{target_word}),1]);
    if ~(isempty(idx_zero))
        %         output{target_word}(idx_zero)=NaN;
        try
            output{target_word}(idx_zero)=[];
            target{target_word}(idx_zero)=[];
            names{target_word}(idx_zero,:)=[];
        catch
            keyboard
        end
    end
end
f_target=[];
f_output=[];
f_names=[];

for i=1:N_text
    f_target=[f_target; target{i}];
    f_output=[f_output; output{i}];
    f_names=[f_names; names{i}];
end
end