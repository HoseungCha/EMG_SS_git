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
function draw_dtwmatching_graph(ref, test, match_pair, nMatchPair, draw_option)
    if(nargin<5)
        draw_option = 1;
    end
   %size change
   [ref, test, size_ref, size_test] = fillNaN4sameLength(ref,test);
   size_big = size(ref,1);
   
   % basic setting for x axis
    x_ref = zeros(size_big,1);
    x_test = zeros(size_big,1);
    
    x_ref = x_ref+NaN;
    x_test= x_test+NaN;
 
    for i=1:size_ref
        x_ref(i) = i;
    end
    for i=1:size_test
        x_test(i) = i;
    end
    
    % basic seting for y axis
    y_ref = ones(size_big,1);
    y_test = zeros(size_big,1);
   
    
    
    %draw line
    if(bitand(draw_option,1)>0)
        %plotting A, B signals
       plot3(x_ref,y_ref, ref, x_test,y_test,test);   %plot
   
       %plotting connections
        for i=1:nMatchPair
            line([match_pair(i,1) match_pair(i,2)], [y_ref(1,1) y_test(1,1)], [ref(match_pair(i,1),1) test(match_pair(i,2),1)]);
        end
    end
    
    %coloring
    if(bitand(draw_option,2)>0)
       
        subplot(3,1,1);
        plot(x_ref,ref);   %plot
        subplot(3,1,3);
        plot(x_test,test);   %plot
        cdp_coloring(x_test, test, match_pair, nMatchPair );
    end
end