%----------------------------------------------------------------------
% 두 데이터 사이의 local distance table을 구한다
% DPW의 계산량을 줄이기 위해 구현되었다.
%
% [table_local_dist] = cal_table_local_dist(data_ref, data_test)
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Post-Doc @  Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
%---------------------------------------------------------------------
function [table_local_dist] = cal_table_local_dist(data_ref, data_test, bFast,max_jump_Test, max_jump_Ref)
    if nargin<3
        bFast = 0;
    end
     %array 길이 계산
    size_test = size(data_test,1);
    size_ref  = size(data_ref,1);
    
    table_local_dist = ones(size_ref,size_test);
    table_local_dist = table_local_dist .* Inf;

    if size(data_ref,2)==1
    
        for j = 1: size_test
            tmp = j-size_test;
            %speed-up window
            if bFast ==0
                r_start = 1;
                r_end = size_ref;
            else
                tmp = j-size_test;
                r_start = max(ceil((1/(max_jump_Test+1))*(j-1))+1, size_ref + (max_jump_Ref+1)*tmp);
                r_end = min((max_jump_Ref+1)*j-1, ceil((1/(max_jump_Test+1))*tmp+size_ref));
            end

            for i = r_start: r_end
                table_local_dist(i,j) = abs(data_ref(i,:)-data_test(j,:));
            end
        end
 
    else
        for j = 1: size_test
            
            for i = 1: size_ref
                table_local_dist(i,j) = norm(data_ref(i,:)-data_test(j,:));
            end
            
        end
    end
        
    
end
