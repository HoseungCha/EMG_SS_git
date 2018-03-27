%--------------------------------------------------------------------------
% CDP로 매칭된 결과를 plot 해 주는 함수
%
% cdp_coloring(x_test, y_test, match_pair, nMatchPair )
%--------------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Post-Doc @  Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
%--------------------------------------------------------------------------
function  cdp_coloring(x_test, y_test, match_pair, nMatchPair )
    prev_pos = [0 0];
    for i = 1:nMatchPair
        test_id = match_pair(i,2);
        pos = [x_test(test_id),y_test(test_id)];
        if(i>1)
            line([prev_pos(1) pos(1)], [prev_pos(2) pos(2) ],'linewidth',2,'color','green');
        end
        prev_pos = pos;
    end
end

