%----------------------------------------------------------------------
% [dist, table, slope] = dtw(data_ref, data_test, slope_mode, max_slope_length, bDPW)
%
% Implementation of Dynamic Timew Warping
% by Won-Du Chang, ph.D, 
% Post-Doc @  Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
% slope_mode = 0: normal mode, 1 : square shape, 2: test-jump, 3: ref_jump
% please read following paper if you want to understand more
% Won-Du Chang, Jungpil Shin, "DPW Approach for Random Forgery Problem in Online Handwritten Signature Verification," Proc.NCM 2008, Gyeongju, Korea Republic, Sep. 2008.
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Post-Doc @  Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
%---------------------------------------------------------------------

function [dist, table, slope] = dtw(data_ref, data_test, slope_mode, max_slope_length, bDPW)
    if nargin<5
        bDPW = 0;
    end
    bCDP = 0;   %CDP 는 적용 안함
    bDataVector = 0;    %CDP 가 아닌 경우 data 가 vector이든 아니든 상관이 없다.
    sc = dtw_slope_generation(slope_mode, max_slope_length);        % 슬로프 생성
    %Speed Up 을 위해 필요한 변수 계산
    if slope_mode==0 || slope_mode ==1
        max_jump_Test = max_slope_length-1;
        max_jump_Ref = max_slope_length-1;
    elseif slope_mode ==2
        max_jump_Test = max_slope_length-1;
        max_jump_Ref = Inf;
    elseif slope_mode ==3
        max_jump_Test = Inf;
        max_jump_Ref = max_slope_length-1;
    else
    end
    
    %array 길이 계산
    size_test = size(data_test,1);
    size_ref  = size(data_ref,1);
    
    
    table = ones(size_ref, size_test);                          % DP Table 생성
    table = table.*Inf;                                         % 초기화
    
   
    %DPW 모드인 경우 vector값을 단계별로 계산해야 한다.
    if(bDPW ==1)    
        v_ref = dpw_preprocessing( data_ref, max_slope_length );
        v_test = dpw_preprocessing( data_test, max_slope_length );
    end
    
     % 시간 단축을 위한 local distance 테이블 계산
     table_local_dist = cal_table_local_dist(data_ref,data_test);

    
            
    %DP Table 계산
    table(1,1) = table_local_dist(1, 1);
    for j=1:size_test
        if(bDPW ==1)
            [table] = dtw_internal_row(data_ref,data_test(j,:), table, j, sc, table_local_dist, bCDP, bDataVector, bDPW, v_ref,v_test,max_jump_Test, max_jump_Ref);
        else
            [table] = dtw_internal_row(data_ref,data_test(j,:), table, j, sc, table_local_dist, bCDP, bDataVector, bDPW,[],[],max_jump_Test, max_jump_Ref);
        end
    end
    
    slope = sc;
   
    dist = table(size_ref, size_test);
  
end
%------------------------------------------------------------------------------------










