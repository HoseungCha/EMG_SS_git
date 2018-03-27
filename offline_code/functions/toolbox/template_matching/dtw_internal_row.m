%----------------------------------------------------------------------
% [table_p] = dtw_internal_row(data_ref, data_test_row, table_p,test_index, sc, table_local_dist_p, bCDP, bDataVector, bDPW, v_ref_p,v_test_p)
%
% calculate DP table for a test data
% 하나의 test 데이터에 대해 table을 계산한다.
% ref: reference data set (1 pattern)
% test: test data (1 row)
% table_index: the index of table to calculate
% sc: slope constraint
%
% bDataVector: parameter로 넘어온 data가 미분된 값인지를 나타낸다. 미분된 값인 경우 CDP 의 starting
% point 간의 거리계산 방법에서 차이가 나게 된다.
% max_jump_Test, max_jump_Ref: diamond 형태로 path를 구속해서 속도를 빠르게 하기 위하여 필요하다.
% 각각 점프(skip)할 수 있는 최대 점의 개수를 의미한다. 즉 slope의 길이가 2인 경우 이 값은 1이 된다.
% max_jump_Test, max_jump_Ref 의 크기가 다른 경우에 대해서는 아직 코드가 검증되지 않았으므로, 당분간 이 두
% 값은 같은 크기로 해서 사용하도록 한다.
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Post-Doc @  Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
%---------------------------------------------------------------------
function [table_p] = dtw_internal_row(data_ref, data_test_row, table_p,test_index, sc, table_local_dist_p, bCDP, bDataVector, bDPW, v_ref_p,v_test_p,max_jump_Test, max_jump_Ref)
    if nargin<9
        bDPW = 0;
    end
    if nargin<10 || bCDP == 1
        bFast = 0;
    else
        bFast = 1;
    end
    %초기화
    size_ref  = size(data_ref,1);
    size_sc = size(sc,2);
    size_test = size(table_p,2);
    
    if(test_index ==1)
        table_p(1,test_index) = norm(data_ref(1,:)- data_test_row); %시작점 계산
    end
    
    j = test_index;
    
    %speed-up window
    if bFast ==0
        r_start = 1;
        r_end = size_ref;
    else
        tmp = j-size_test;
        r_start = max(ceil((1/(max_jump_Ref+1))*(j-1))+1, size_ref + (max_jump_Test+1)*tmp);
        r_end = min((max_jump_Test+1)*j-1, ceil((1/(max_jump_Ref+1))*tmp+size_ref));
    end
            
    for i=r_start:r_end
       if(i==1 && j==1)    %1,1 시작점은 미리 계산하고 여기서는 skip 한다
            continue;
       end

      
        %각각의 branch에 대해 거리값 계산하여 최소값 저장
        if bCDP==1 && i == 1   % CDP 이고 맨 아래점인 경우 시작점이 될 수 있도록 min dist를 지정하여 놓는다.
            if bDPW == 0
                if bDataVector==1   %미분된 값인 경우 시작점의 
                    min_dist = 0;
                else
                    min_dist = table_local_dist_p(i, j);
                end
            else
                min_dist = 0;   %DPW이고 CDP인 경우 시작점의 거리는 0으로 해 주어야 한다.
                %min_dist = norm(data_ref(1,:)- data_test_row); % DPW 의 경우 시작점은 벡터가 아닌 원 데이터여야 하므로, 새로 거리 계산
            end
        else                   % 일반적인 경우 min_dist 는 무한대
            min_dist = Inf;
        end
        
        for k = 1: size_sc
            dist = 0;
            size_branch = size(sc{k},2);
            
            %브랜치의 leaf를 기준으로 크기를 계산한다
            len_branch_ref = sc{k}{size_branch}(1);
            len_branch_test = sc{k}{size_branch}(2);
            
            %Leaf 노드의 경우. leaf 노드의 경우에는 DPW와 차이가 없다
            if(i- len_branch_ref<1 || j-len_branch_test<1 )    %branch가 테이블 밖으로 빠져나가는 경우
                dist = Inf;
            else
                dist = dist + table_p(i- len_branch_ref, j-len_branch_test);
            end
            
            % 중간 노드와  root의 경우 DPW 와 일반적인 경우를 나누어 처리한다.
            if bDPW ==0
                for m=1:size_branch-1   % 중간 노드의 경우. 
                    branchDist_from_root = sc{k}{m};
                    refID_branchPosition = i - branchDist_from_root(1);
                    testID_branchPosition = j - branchDist_from_root(2);
                
                    if(refID_branchPosition <1 || testID_branchPosition<1 )    %branch가 테이블 밖으로 빠져나가는 경우
                        dist = Inf;
                    else
                        dist = dist + table_local_dist_p(refID_branchPosition,  testID_branchPosition);  %미리 계산해 둔 local dist 를 사용한다                  
                    end
                end
                
                % root
                dist = dist+table_local_dist_p(i,j);
            else
                for m=0:size_branch-1   % 중간 노드의 경우. 
                    if m==0 % root 처리
                        branchDist_from_root = [0 0];
                    else
                        branchDist_from_root = sc{k}{m};
                    end
                    refID_branchPosition = i - branchDist_from_root(1);
                    testID_branchPosition = j - branchDist_from_root(2);
                    if(refID_branchPosition <1 || testID_branchPosition<1 )    %branch가 테이블 밖으로 빠져나가는 경우
                        dist = Inf;
                    else
                        data4dpw_ref = v_ref_p(len_branch_ref - branchDist_from_root(1),refID_branchPosition);    %해당 branch ITEM 에서 branchDist_from_leaf 만큼 이전의 데이터와의 차이를 취득
                        data4dpw_test = v_test_p(len_branch_test - branchDist_from_root(2),testID_branchPosition);    %해당 branch ITEM 에서 branchDist_from_leaf 만큼 이전의 데이터와의 차이를 취득            
                        dist = dist + norm(data4dpw_ref - data4dpw_test); 
                    end
                end
            end
            
            
               
            if(dist<min_dist)
                min_dist =dist;
            end
            table_p(i, j) = min_dist;
        end
    end
end
