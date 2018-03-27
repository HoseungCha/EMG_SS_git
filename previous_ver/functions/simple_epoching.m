% get cell epoched data using trigger
function data_set=simple_epoching(data,srate,trg,before,after)
data_set=cell(size(trg));


for i=1:length(trg)
    if trg(i)+round(after*srate)<length(data) % Epoching 할 정도로 데이터 충분히 얻지 못하였을 경우 제외
        data_set{i,1}=data(trg(i)-round(before*srate):trg(i)+round(after*srate),:);
    end
end

end