%% check trg more than two was superposed on avtivation of a tral
function [trg,ITI]=check_doubled_trigger(trg,threhosld_time)
diff_trg=diff(trg);
% use two std
% meann = mean(diff_trg);
% stdd = std(diff_trg);
% I = bsxfun(@lt, meann + 1*stdd, diff_trg) | bsxfun(@gt, meann - 1*stdd, diff_trg);

for i=1:length(diff_trg)
    % 사이 간격이 0.48초이하면 첫째 동기화 빼고 제거하기
    I(i,1)=diff_trg(i)<threhosld_time*2048;   
end
% get average time between trg
% avtrg=trg;
% avtrg(I)=[];
idx_trg2delete=find(I==1)+1;

trg(idx_trg2delete)=[];


ITI=mean(diff(trg))/2048; % samplingrate: 2048
% get idx to delete
% I(idx_trg2delete)=1;
% delete the trials.
end