%data를 DTW 결과에 따라 transform하는 함수
%data_resampled는 원 데이터에서 resampling 된 데이터, 
%match_pair_ref_test는 ref, test 간의 DTW 결과,
%nDivision_4Resampling는 Resampling 시 사용된 division의 크기이다.
%
% designed & coded by Dr. Won-Du Chang
% last modified 2017.05.03
function [d_trans,pos_ref_exact_,pos_test_estimated_] = transfromData_accDTWresult(data_resampled_test, data_resampled_ref, match_pair_ref_test, nDivision_4Resampling)
    lenResampled = size(data_resampled_test,1);
    lenOriginal = (lenResampled -1)/nDivision_4Resampling +1;
    d_trans = zeros(lenOriginal,1);
    pos_test_estimated_ = zeros(lenOriginal,1);
    pos_ref_exact_ = zeros(lenOriginal,1);
    idx_start2search = 1;
    for i=1:lenOriginal
        pos_ref_exact = (i -1) *nDivision_4Resampling +1;
        [pos_test_estimated, idx_start2search] = findNearestPoint_InMatchPairRef(match_pair_ref_test,pos_ref_exact, data_resampled_ref,idx_start2search);
        d_trans(i) = data_resampled_test(pos_test_estimated);
        pos_test_estimated_(i) = pos_test_estimated;
        pos_ref_exact_(i) = pos_ref_exact;
    end
end

%match pair가 존재하는 ref 데이터 중 가장 가까운 데이터를 찾는다.
function [pos_test_estimated, idx_start2search] = findNearestPoint_InMatchPairRef(match_pair_ref_test,pos_ref_exact, data_resampled_ref, idx_start2search)
    idx_matchPair = -1;
    len_match_pair = size(match_pair_ref_test,1);
    for i=idx_start2search:len_match_pair
        cur = len_match_pair - i - 1;
        if pos_ref_exact== match_pair_ref_test(cur,1) %해당 지점이 skip 되지 않은 경우.
            idx_matchPair = cur;
            idx_start2search = i +1;
            break;
        elseif pos_ref_exact< match_pair_ref_test(cur,1)
            d_ref_before = data_resampled_ref(match_pair_ref_test(cur+1,1));
            d_ref_after = data_resampled_ref(match_pair_ref_test(cur,1));
            d_center= data_resampled_ref(pos_ref_exact);
            
            if abs(d_ref_before - d_center) < abs(d_ref_after - d_center) % 앞의 데이터가 더 가까우면,
                idx_matchPair = cur +1;
                idx_start2search = i;
                break;
            else                                                          % 그렇지 않다면, 뒤의 데이터를 사용
                idx_matchPair = cur;
                idx_start2search = i+1;
                break;
            end
        end
    end
    
    if idx_matchPair<0
        fprintf('findNearestPoint_InMatchPairRef: 예상치 못한 에러 발생\n');
    end
    
    pos_test_estimated = match_pair_ref_test(idx_matchPair,2);
end