%--------------------------------------------------------------------------
% by Ho-Seung Cha, Ph.D Student
% Ph.D candidate @ Department of Biomedical Engineering, Hanyang University
% hoseungcha@gmail.com
%--------------------------------------------------------------------------
function yp = majority_vote(xp)
% final decision using majoriy voting
% yp has final prediction X segments(times)
[N_Seg,N_trl,N_label] = size(xp);
yp = zeros(N_label*N_trl,1);
for n_seg = 1 : N_Seg
    maxv = zeros(N_label,N_trl); final_predict = zeros(N_label,N_trl);
    for i = 1 : N_label
        for j = 1 : N_trl
            [maxv(i,j),final_predict(i,j)] = max(countmember(1:N_label,...
                xp(1:n_seg,j,i)));
        end
    end
    yp(:,n_seg) = final_predict(:);
%     acc(n_seg,N_comp+1) = sum(repmat((1:label)',[N_trl,1])==final_predict)/(label*N_trial-label*n_pair)*100;
end
end