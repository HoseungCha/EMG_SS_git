%------------------------------------------------------------------------------------
%define SC(slope constraint)
% DTW 에 필요한 slope를 생성한다.
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Post-Doc @  Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
%---------------------------------------------------------------------
function [cs] = dtw_slope_generation(slope_mode, max_slope_length)
    switch slope_mode
        case 0  %normal mode
            cs = cell(1,max_slope_length*2-1); %pre-allocating memory
            cs{1} = {[1 1]};
            for i=1:max_slope_length-1
                cs{1+ (i-1)*2+1} = {[i+1,1]};
                cs{1+ (i-1)*2+2} = {[1,i+1]};
            end
        case 1  %square mode
            cs = cell(1,max_slope_length*2-1);
            cs{1} = {[1 1]};
            for i=1:max_slope_length-1
                b_left = cell(1,i); %pre-allocating memory
                b_down = cell(1,i); %pre-allocating memory
                for j=1:i
                    b_left{j} = [j,0];
                    b_down{j} = [0,j];
                end
                b_left{i+1} = [i+1,1];
                b_down{i+1} = [1,i+1];
                cs{1+ (i-1)*2+1} = b_left;
                cs{1+ (i-1)*2+2} = b_down;
            end
        case 2 % Test jump
            cs = cell(1,max_slope_length+1); %pre-allocating memory
            for i=0:max_slope_length
                cs{i+1} = {[1,i]};
            end
        otherwise % Ref Jump
            cs = cell(1,max_slope_length+1); %pre-allocating memory
            for i=0:max_slope_length
                cs{i+1} = {[i,1]};
            end
    end
end