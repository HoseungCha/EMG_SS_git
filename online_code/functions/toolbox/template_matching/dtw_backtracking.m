%----------------------------------------------------------------------
% [match_pair, nPair] = dtw_backtracking(table, slope, test_end_index, bCDP)
%
% Back-tracking for DTW
% test_end_index is for CDP, which denotes the position to starts backtracking
% when CDP is unused, test_end_index should be empty []
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Post-Doc @  Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
%---------------------------------------------------------------------
function [match_pair, nPair] = dtw_backtracking(table, slope, test_end_index, bCDP)
    if(nargin<4)
        bCDP = 0;
    end
    size_ref = size(table,1);
    size_test = size(table,2);
    size_sc = size(slope,2);
    i = size_ref;
    if(isempty(test_end_index)==1)
        j = size_test;
    else
        j = test_end_index;
    end
    
    match_pair = ones(size_ref+size_test,2);
    match_pair = match_pair.*Inf;
    
    
    match_pair(1,:) =[i j]; % input starting position
    count = 2;
    while 1
        min_dist = Inf; min_r = Inf; min_t = Inf;
        %find matching point having minimum distance
        for s = 1:size_sc
            size_branch = size(slope{s},2);
            r_tmp = slope{s}{size_branch}(1);
            t_tmp = slope{s}{size_branch}(2);
            
            if((i-r_tmp>0 &&j-t_tmp>0) && (s==1 || table(i-r_tmp,j-t_tmp)<min_dist))
                min_dist = table(i-r_tmp,j-t_tmp);
                min_r = i-r_tmp;
                min_t = j-t_tmp;
            end
        end
       
        %matching pair 저장
        match_pair(count,:) = [min_r min_t];
        count = count+1;
        
        %move to the next point
        i = min_r;
        j = min_t;
        
        %종료조건
        if((bCDP==0 &&i==1 && j==1) || (bCDP==1&&i==1))
            break;
        end
        if(count > size_test + size_ref+1)
            'Error: Code in a Loop does not seem to finished'
            break;
        end
    end
    nPair = count-1;
end