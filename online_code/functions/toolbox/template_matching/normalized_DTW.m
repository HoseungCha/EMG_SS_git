function [ cor ] = normalized_DTW( data_ref, data_test , max_slope_length, window_width )
    if nargin<3
        max_slope_length = 2;
    end
    if nargin<4
        window_width = 8;
    end
    size_ref = size(data_ref,1);
    size_test = size(data_test,1);
    v_ref = zeros(size_ref,1);
    v_test = zeros(size_test,1);
    for i=2:size_ref
        v_ref (i) = data_ref(i) - data_ref(i-1);
    end
    for i=2:size_test
        v_test (i) = data_test(i) - data_test(i-1);
    end
    
    [dist, table, match_pair] = fastDTW( v_ref, v_test, max_slope_length, window_width );
    
    if dist==Inf % 샘플 수의 차이로 (즉 허용된 점프횟수의 제한으로) 인해 distance 계산이 불가능한 경우
        cor = 0;
        return;
    end
    
   
    nNewPoint = size(match_pair,1);
    nColumn = size(data_ref,2);
    new_ref = zeros(nNewPoint,nColumn);
    new_test = new_ref;
    
    for i=1:nNewPoint
        new_ref(i,:) = data_ref(match_pair(i,1),:);
        new_test(i,:) = data_test(match_pair(i,2),:);
    end
    %cor = (corr(new_ref(:,1),new_test(:,1))+corr(new_ref(:,2),new_test(:,2)))/2;
    cor = corr(new_ref(:,1),new_test(:,1));
    
    subplot(2,1,1);
    hold on;
    plot(data_ref);
    plot(data_test);
    subplot(2,1,2);
    plot(new_ref);
    plot(new_test);
    hold off;
    
end


% function [ cor ] = corr_basedonDTW( data_ref, data_test , slope_mode, max_slope_length, bDPW )
%     if nargin<3
%         slope_mode = 0;  % normal (square jump) mode
%     end
%     if nargin<4
%         max_slope_length = 4;
%     end
%     if nargin<5
%         bDPW = 0;
%     end
%     
%     [dist, table, slope] = dtw(data_ref, data_test, slope_mode, max_slope_length, bDPW);
%     
%     if dist==Inf % 샘플 수의 차이로 (즉 허용된 점프횟수의 제한으로) 인해 distance 계산이 불가능한 경우
%         cor = 0;
%         return;
%     end
%     
%     [match_pair, nPair ] = dtw_backtracking(table, slope,[]);    %DTW Backtracking to find path
%     
%     nNewPoint = nPair;
%     nColumn = size(data_ref,2);
%     new_ref = zeros(nNewPoint,nColumn);
%     new_test = new_ref;
%     
%     for i=1:nNewPoint
%         new_ref(i,:) = data_ref(match_pair(i,1),:);
%         new_test(i,:) = data_test(match_pair(i,2),:);
%     end
%     %cor = (corr(new_ref(:,1),new_test(:,1))+corr(new_ref(:,2),new_test(:,2)))/2;
%     cor = corr(new_ref(:,1),new_test(:,1));
% end



