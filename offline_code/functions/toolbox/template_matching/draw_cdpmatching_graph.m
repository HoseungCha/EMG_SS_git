%----------------------------------------------------------------------
% draw_cdpmatching_graph(templates, test, match_pairs, nMatchPairs, table, threshold)
%
% Implementation of Drawing alignment between two data
% After using Dynamic Timew Warping 
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Post-Doc @  Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
%---------------------------------------------------------------------
function draw_cdpmatching_graph(templates, test, match_pairs, nMatchPairs, table, threshold,x_test)
   nTemplate = size(templates,2);
   for k = 1:nTemplate
       %size change
       [ref, test, size_ref, size_test] = fillNaN4sameLength(templates{k},test);
       size_big = size(test,1); %위쪽 function에서 ref와 test 의 사이즈가 균일하게 되므로 ref나 test 어떤 것을 취하든 관계없다

       % basic setting for x axis
        x_ref = zeros(size_big,1);


        x_ref = x_ref+NaN;
        for i=1:size_ref
            x_ref(i) = i;
        end

        if nargin<7
            x_test = zeros(size_big,1);
            x_test= x_test+NaN;
            for i=1:size_test
                x_test(i) = i;
            end
        end
            

%        subplot(nTemplate*2,11,[(k-1)*2*11+1 (k*2-1)*11+1]);
%        plot(x_ref,ref);   %plot
%        subplot(nTemplate*2,11,[(k-1)*2*11+2 (k-1)*2*11+11]);
 %       subplot(1,nTemplate,k);
        plot(x_test,test);   %plot
        
        %coloring
        for i=2:size_test-1
            %거리값이 local minimum 이면서 지정된 threshold보다 작은 경우
            if table{k}(size_ref,i) < threshold && table{k}(size_ref,i)<table{k}(size_ref,i-1) && table{k}(size_ref,i)< table{k}(size_ref,i+1)
                cdp_coloring(x_test, test, match_pairs{k,i}, nMatchPairs(k,i) );
            end
        end
        
 %     subplot(nTemplate*2,11,[(k-1)*2*11+2+11 k*2*11]);
 %     plot(table{k}(size_ref,:));
   end
end