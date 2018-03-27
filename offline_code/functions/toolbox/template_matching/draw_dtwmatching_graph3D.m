%----------------------------------------------------------------------
% draw_dtwmatching_graph(ref, test, match_pair, nMatchPair, draw_option)
%
% Implementation of Drawing alignment between two data
% After using Dynamic Timew Warping 
% by Won-Du Chang, ph.D, 
% Post-Doc @  Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
% 
%draw_option (bit info) : 1st bit: draw line
%                         2nd bit: coloring
%
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Post-Doc @  Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
%---------------------------------------------------------------------
function draw_dtwmatching_graph3D(ref, test, match_pair, nMatchPair, draw_option)
    if(nargin<5)
        draw_option = 1;
    end
   %size change
   dim = size(ref,2);
   len_ref = size(ref,1);
   len_test = size(test,1);
   
   if dim~=2
       return;
   end
   
   min_x = min([ref(:,1); test(:,1)]);
   max_x = max([ref(:,1); test(:,1)]);
   min_y = min([ref(:,2); test(:,2)]);
   max_y = max([ref(:,2); test(:,2)]);
   
   
   ref_depth = zeros(len_ref,1);
   test_depth = ones(len_test,1)*100;
   
    
    %draw line
    if(bitand(draw_option,1)>0)
        %plotting A, B signals
       plot3(ref(:,1),ref(:,2), ref_depth);
       hold on;
       plot3(test(:,1),test(:,2),test_depth);   %plot
   
       %plotting connections
       x = zeros(nMatchPair,2);
       y = zeros(nMatchPair,2);
       z = zeros(nMatchPair,2);
        for i=1:nMatchPair
            id_ref = match_pair(i,1);
            id_test = match_pair(i,2);
            x(i,:) = [ref(id_ref,1) test(id_test ,1)];
            y(i,:) = [ref(id_ref,2) test(id_test ,2)];
            z(i,:) = [ref_depth(1,1) test_depth(1,1)];
            plot3(x(i,:),y(i,:),z(i,:),'r');
        end
        hold off;
    end
    

end