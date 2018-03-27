% DTW 의 fast version.
% slope mode 등의 파라메터를 디폴트로 잡아 처리에 걸리는 시간을 최소화한다.
% dimension: 1
% slope mode: normal (square jump)
% 
% speedup_mode: 1-> diamond, 2-> window, 3-> both
function [ dist ,table, match_pair] = fastDTW( data_ref, data_test, max_slope_length, speedup_mode, window_width)
    %array 길이 계산
    size_test = size(data_test,1);
    size_ref  = size(data_ref,1);
    
    
    table = ones(size_ref, size_test);                          % DP Table 생성
    table = table.*Inf;                                         % 초기화
    

    %DP Table 계산
    %table(1,1) = abs(data_ref(1,1)-data_test(1,1));
    table(1,1) = sqrt(sum((data_ref(1,:)-data_test(1,:)).^2,2));
    ratio = size_ref/size_test;
    for j=2:size_test
        %speed-up window
        
        if speedup_mode ==1
            tmp = j-size_test;   
            r_start = max(ceil(0.5*j+0.5), size_ref + 2*tmp);  %다이아몬드 형태인 경우의 수식
            r_end = min(2*j-1, 0.5*tmp+size_ref);
        elseif speedup_mode ==2
            r_start = max(round(ratio*j)-window_width,2);
            r_end = min(round(ratio*j)+window_width,size_ref);
        else       
            tmp = j-size_test;  
            r_start = max([round(ratio*j)-window_width,2,ceil(0.5*j+0.5), size_ref + 2*tmp]);
            r_end = min([round(ratio*j)+window_width,size_ref,2*j-1, 0.5*tmp+size_ref]);
        end

        for i=r_start:r_end
             %각각의 branch에 대해 거리값 계산하여 최소값 저장
            min_dist = table(i-1,j-1);

            for k = 2: max_slope_length
                if i-k>0 && j-1>0
                    dist1 = table(i-k,j-1);
                    if(dist1<min_dist)
                        min_dist =dist1;
                    end
                end
                if i-1>0 && j-k>0
                    dist2 = table(i-1,j-k);
                    if(dist2<min_dist)
                        min_dist =dist2;
                    end
                end
            end
            %table(i, j) = min_dist + abs(data_ref(i,1)-data_test(j,1)); %root;
            table(i, j) = min_dist + sqrt(sum((data_ref(i,:)-data_test(j,:)).^2,2));
        end
    end
    dist = table(size_ref, size_test);
    if dist~=Inf
        match_pair = dtwfast_backtracking(table,max_slope_length);
    else 
        match_pair = [];
    end
    
end

function [match_pair] = dtwfast_backtracking(table, max_slope_length)
    size_ref = size(table,1);
    size_test = size(table,2);

    i = size_ref;
    j = size_test;
    
    nMaxMatchPair = size_ref+size_test;
    
    match_pair = ones(nMaxMatchPair,2);
    match_pair = match_pair.*Inf;
    
    
    match_pair(1,:) =[i j]; % input starting position
    count = 2;
    while 1
        min_dist = table(i-1,j-1);
        min_r = i-1;
        min_t = j-1;
        %find matching point having minimum distance
        for k = 2:max_slope_length
           if i-k>0 && j-1>0 && table(i-k,j-1)< min_dist
                min_dist = table(i-k,j-1);
                min_r = i-k;
                min_t = j-1;
           end
           if i-1>0 && j-k>0 &&  table(i-1,j-k)< min_dist
                min_dist = table(i-1,j-k);
                min_r = i-1;
                min_t = j-k;
           end
        end
        
        %matching pair 저장
        match_pair(count,:) = [min_r min_t];
        count = count+1;
        
        %move to the next point
        i = min_r;
        j = min_t;
        
        %종료조건
        if(i==1 && j==1)
            break;
        end
    end
    
    match_pair(count:nMaxMatchPair,:) = [];
end