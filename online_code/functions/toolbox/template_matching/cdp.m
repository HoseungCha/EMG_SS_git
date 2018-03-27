%----------------------------------------------------------------------
% CDP Implementation
%
% [dist, table, match_pair, nPair]=cdp(ref,test, slope_mode, max_slope_length, threshold, bVector, bDPW)
%
% slope_mode = 0: normal mode, 1 : square shape, 2: test-jump, 3: ref_jump
% please read following paper if you want to understand more
% Won-Du Chang, Jungpil Shin, "DPW Approach for Random Forgery Problem in Online Handwritten Signature Verification," Proc.NCM 2008, Gyeongju, Korea Republic, Sep. 2008.
% H. Kameya, S. Mori, R. Oka, "A segmentation-free biometric writer verification method based on continuous dynamic programming," Pattern Recognition Letters, 2006
%
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Post-Doc @  Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
%---------------------------------------------------------------------

function [dist, table, match_pair, nPair]=cdp(ref,test, slope_mode, max_slope_length, threshold, bVector, bDPW)
    if(nargin<6)
        bVector = 0;
    end
    if(nargin<7)
        bDPW = 0;
    end
    sc = dtw_slope_generation(slope_mode, max_slope_length);        % 슬로프 생성
    nTemplate = size(ref,2); %reference data set의 개수
    nTest= size(test,1); %test data row의 개수
    nWidth = size(test,1);  %DP table의 너비. 너무 넓어서 문제가 되는 경우 circle queue 로 전환하여야 한다.
    table = cell(1,nTemplate);
    match_pair = cell(nTemplate,nTest);  % backtracking data 
    nPair = zeros(nTemplate,nTest);  % backtracking data 
    table_local_dist = cell(1, nTemplate);
    
    bCDP = 1;
    
    %초기화
    for i=1:nTemplate
        nPoint = size(ref{i},1);
        table{i} = ones(nPoint,nWidth).*Inf;
%        if(slope_mode==1) % square mode 인 경우. 
%            table_local_dist{i} = norm(ref{i}(1,:) - test(1,:));
%        else
            table_local_dist{i} = cal_table_local_dist(ref{i},test,0);
%        end
    end
 
    

    %DPW 모드인 경우 vector값을 단계별로 계산해야 한다.
    if(bDPW ==1)    
        v_ref = cell(1,nTemplate);
        for i=1:nTemplate
            v_ref{i} = dpw_preprocessing( ref{i}, max_slope_length );
        end
        v_test = dpw_preprocessing( test, max_slope_length );
        
    end
    
    %DP 처리
    for j=1:nTest %모든 Test 데이터에 대해서... (나중 온라인으로 전환시 이 부분을 수정해야 함. Online은 하나씩 데이터가 들어오므로)
        for i=1:nTemplate
            %DP Table 계산
            if bDPW ==0
                tmp = dtw_internal_row(ref{i}, test(j,:),table{i},j, sc, table_local_dist{i}, bCDP,bVector, bDPW);
            else
                tmp = dtw_internal_row(ref{i}, test(j,:),table{i},j, sc, table_local_dist{i}, bCDP,bVector, bDPW, v_ref{i},v_test);
            end
            [table{i}] = tmp;
            dist = table{i}(size(ref{i},1),j);
            
            if dist<threshold
                [match_pair{i,j}, nPair(i,j)] = dtw_backtracking(table{i}, sc,j,bCDP); % backtracking and save track
            end
        end
    end
end



