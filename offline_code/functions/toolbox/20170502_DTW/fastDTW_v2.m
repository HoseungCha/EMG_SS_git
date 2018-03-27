% DTW 의 fast version.
% division 추가
% channel 수가 2 이상일 때에 대해서는 아직 테스트해 보지 않았음. 2017.05.03
%
% slope mode 등의 파라메터를 디폴트로 잡아 처리에 걸리는 시간을 최소화한다.
% dimension: 1
% slope mode: normal (square jump)
% 
% speedup_mode: 1-> diamond, 2-> window, 3-> both
% designed & coded by Dr. Won-Du Chang
% last modified 2017.05.03
function [ dist ,table, match_pair] = fastDTW_v2( data_ref, data_test, max_slope_length, speedup_mode, window_width, bAllowDivision)
    
    %array 길이 계산
    size_test = size(data_test,1);
    size_ref  = size(data_ref,1);
    nChannel = size(data_test,2); %두 데이터의 채널수는 같다고 가정한다.
    
    %division을 위한 코드. 나누어질 데이터를 미리 계산해 둔다.
    %예를 들어, bDivData_ref{4,2} 는 ref 데이터의 3번째와 4번째 데이터 point 사이를 3등분했을때, 새로
    %생긴 두 개의 값을 가진다.
    if nargin<6
        bAllowDivision = 0;
    end
    if (bAllowDivision==1)
        dataDiv_ref    = cell(size_ref, max_slope_length-1);
        dataDiv_test   = cell(size_test, max_slope_length-1);
        for i=2:size_ref
            for j=1:max_slope_length-1
                dx = (data_ref(i,:) - data_ref(i-1,:))./(j+1);
                dataDiv_ref{i,j} = zeros(j,nChannel);
                for k=1:j
                    dataDiv_ref{i,j}(k,:) = data_ref(i-1,:) + dx * k;
                end
            end
            
            for j=1:max_slope_length-1
                dx = (data_test(i,:) - data_test(i-1,:))./(j+1);
                dataDiv_test{i,j} = zeros(j,nChannel);
                for k=1:j
                    dataDiv_test{i,j}(k,:) = data_test(i-1,:) + dx * k;
                end
            end
        end
    end
    %division을 위한 preCalculation코드 끝.
    
    
    
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
                if i-k>0 && j-1>0 %ref를 jump 하는 경우
                    dist1 = table(i-k,j-1);
                    
                    %division을 위한 코드
                    if (bAllowDivision==1)  %division을 하는 경우 division 된 거리까지 계산해 주어야 함.
                        for m=1:k-1  %여기서 k-1은 division을 안했을 때 skip 하게되는 point의 개수임. 즉 segement 는 k 등분된다.
                            d_tmp_test = dataDiv_test{j,k-1}(m,:);
                            dist_tmp = sqrt(sum((d_tmp_test-data_ref(i-k+m,:)).^2,2));
                            dist1 = dist1 + dist_tmp;
                            
                        end
                    end
                    %division을 위한 코드 끝
                    
                    if(dist1<min_dist)
                        min_dist =dist1;
                    end
                end
                if i-1>0 && j-k>0 %test 를 jump하는 경우
                    dist2 = table(i-1,j-k);
                    
                    %division을 위한 코드
                    if (bAllowDivision==1)  %division을 하는 경우 division 된 거리까지 계산해 주어야 함.
                        for m=1:k-1  %여기서 k-1은 division을 안했을 때 skip 하게되는 point의 개수임. 즉 segement 는 k 등분된다.
                            d_tmp_ref = dataDiv_ref{j,k-1}(m,:);
                            dist_tmp = sqrt(sum((d_tmp_ref-data_test(j-k+m,:)).^2,2));
                            dist1 = dist1 + dist_tmp;
                            
                        end
                    end
                    %division을 위한 코드 끝
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