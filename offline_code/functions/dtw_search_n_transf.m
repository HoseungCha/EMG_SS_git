%--------------------------------------------------------------------------
% x2 신호들에 대해, x1신호 DTW 거리가 작은 N_s 개의 신호를 뽑은 후 변환하는 코드
%
% [xt] = dtw_search_n_transf(ref_singal, signals to transfrom,
% number of singals to extract)
%--------------------------------------------------------------------------
% by Ho-Seung Cha, Ph.D Student
% Ph.D candidate @ Department of Biomedical Engineering, Hanyang University
% hoseungcha@gmail.com
%--------------------------------------------------------------------------
function [xt] = dtw_search_n_transf(x1, x2, N_s)
% parameters
window_width = 3;
max_slope_length = 2;
speedup_mode = 1;
DTW_opt.nDivision_4Resampling = 10;
DTW_opt.max_slope_length = 3;
DTW_opt.speedup_mode = 1;

[N_f, N]= size(x2); dist = zeros(N,1);
for i = 1 : N
    dist(i) = fastDTW(x1, x2(:,i),max_slope_length, ...
        speedup_mode, window_width );
end
% Sort
[~, sorted_idx] = sort(dist);
% xs= x2(:,sorted_idx(1:N_s));
xt = zeros(N_f,N_s);
for i = 1 : N_s
    xt(:,i)= transfromData_accRef_usingDTW(x2(:,sorted_idx(i)), x1, DTW_opt);
end
end