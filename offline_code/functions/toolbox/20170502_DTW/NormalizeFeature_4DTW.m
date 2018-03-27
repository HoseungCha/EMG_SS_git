% NormalizeFeature_4DTW
%ref 를 기준으로 d를 normalize 한다. ref, d는 각각 1차원 배열이다.
% Designed & Coded by Dr. Won-Du Chang
% Last Modified at 2017.05.02
% 12cross@gmail.com
function [d_norm] = NormalizeFeature_4DTW(ref, d)
    factor = std(ref)/std(d);
    d_norm = d* factor;
%     d_norm = d_norm- mean(d_norm) + mean(ref);
    d_norm = d_norm- min(d_norm) + min(ref);
end
