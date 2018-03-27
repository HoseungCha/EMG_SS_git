% dist = templateMatching(data,template, mode)
% method_distanceMetrics = 1: Correlation
% method_distanceMetrics = 2: DTW
% method_distanceMetrics = 3: DPW
%                        = 4: Kurtosis
%                        = 5: Mean Squared Error
%
% mode_distance_template=1: min
%                       =2: average
%                       =3: average with normalized distance
function [dist] = templateMatching(data,template, method_distanceMetrics, mode_distance_template, max_slope_length)

%     global max_slope_length;
%     global speedup_mode;
        
    nRow        = size(data,1);
    nTemplate   = size(template,1);
    
    %DTW 계열인 경우 변수 설정
    if (method_distanceMetrics==2 || method_distanceMetrics==3) && nargin <= 4
        max_slope_length = 3;
        speedup_mode = 1;
    elseif (method_distanceMetrics==2 || method_distanceMetrics==3) && nargin == 5
        speedup_mode = 1;
    end
    
    %template 사용 방법이 averaging 이고 normalized distance를 사용할 경우
    nTemplate = size(template,1);
    if mode_distance_template==3   
        cnt = 0;
        nSizeDist = nTemplate*(nTemplate-1)/2;
        tmp_dist = zeros(nSizeDist,1);
        for i=1:nTemplate
            for j=i+1:nTemplate
                if method_distanceMetrics==1
                    [ a, b] = fillNaN4sameLength( template{i}, template{j} );
                    tmp_dist(cnt+1) = 1-corr(a ,b ,'rows','complete');
                    cnt = cnt+1;
                elseif method_distanceMetrics==2
                    tmp_dist(cnt+1) = fastDTW( template{i}, template{j}, max_slope_length, speedup_mode);
                    if tmp_dist(cnt+1)<Inf
                        cnt = cnt+1;
                    end
                elseif method_distanceMetrics==3
                    %[dist(j,i), table, slope] = dtw(n_template{i}, data(data_range,1) - data(data_range(1),1), slope_mode, max_slope_length, bDPW);
                    tmp_dist(cnt+1) = fastDPW( template{i}, template{j}, max_slope_length, speedup_mode);
                    if tmp_dist(cnt+1)<Inf
                        cnt = cnt+1;
                    end
                elseif method_distanceMetrics==4
                    tmp_dist(cnt+1) = abs(kurtosis(template{i})-kurtosis(template{j}));
                    cnt = cnt+1;
                elseif method_distanceMetrics==5
                    len1 = size(template{i},1);
                    len2 = size(template{j},1);
                    len_short = min(len1,len2);
                        
                    [ a, b] = fillNaN4sameLength( template{i}, template{j} );
                    tmp_dist(cnt+1) = sqrt(nansum((a-b).^2)/len_short);
                    cnt = cnt+1;
                else
                end
            end
        end
        tmp_dist(cnt+1:nSizeDist) = [];
        normalizing_factor = [mean(tmp_dist) std(tmp_dist)];
    end
    
    
    
    %distance 계산
    dist = zeros(nRow,nTemplate);
    for i=1:nTemplate
        template_length = size(template{i},1);
        for j=template_length:nRow
            data_range = j-template_length+1:1:j;
            if method_distanceMetrics==1
                dist_x = 1-corr(data(data_range,1), template{i}(:,1),'rows','complete');
                dist_y = 1-corr(data(data_range,2), template{i}(:,2),'rows','complete');
                dist(j,i) = dist_x + dist_y;
            elseif method_distanceMetrics==2
                [ dist(j,i), table, match_pair] = fastDTW( template{i}, data(data_range,:), max_slope_length, speedup_mode);
            elseif method_distanceMetrics==3
                %[dist(j,i), table, slope] = dtw(n_template{i}, data(data_range,1) - data(data_range(1),1), slope_mode, max_slope_length, bDPW);
                [ dist(j,i), table, match_pair] = fastDPW( template{i}, data(data_range,:), max_slope_length, speedup_mode);
            elseif method_distanceMetrics==4 %%%
                dist(j,i) = abs(kurtosis(data(data_range,1))-kurtosis(template{i}));
            elseif method_distanceMetrics==5
                dist_x = sqrt(sum((data(data_range,1)-template{i}(:,1)).^2));
                dist_y = sqrt(sum((data(data_range,2)-template{i}(:,2)).^2));
                dist(j,i) = dist_x + dist_y;
            else
            end
        end
    end
    
    if mode_distance_template==3   
        dist = dist./normalizing_factor(1);
    end
    
end