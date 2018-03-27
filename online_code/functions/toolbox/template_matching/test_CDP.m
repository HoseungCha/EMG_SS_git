%----------------------------------------------------------------------
% exp_artifact()
% Artifact Detectionexperiment using CDP library
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Post-Doc @  Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
%---------------------------------------------------------------------
function test_CDP()
    %load template files
    template = load_txt_files_in_folder('D:/_Project/Data/Artifact_Test/Chang_no1_artifact/template');
    nTemplate = size(template,2);
    v_template = cell(1,nTemplate);
    for i=1:nTemplate
        template_length = size(template{i},1);
         v_template{i} = zeros(template_length,1);
        for j=2:template_length
            v_template{i}(j) = template{i}(j) - template{i}(j-1);
        end
    end
 
    %load test file
    test = load('D:/_Project/Data/Artifact_total_till_20130923/Wondu/highpass0.10_sampling32_median5.txt_01.txt');
    
    nTest = size(test,1);
    threshold = 600;
    x_test = test(:,1);
    test = test(:,2);
    v_test = zeros(nTest,1);    %V_Test
    for i=2:nTest
        v_test(i) = test(i) - test(i-1);
    end
    ac_test =  zeros(nTest,1);
    for i=3:nTest
        ac_test(i) = v_test(i) - v_test(i-1);
    end


    slope_mode = 1;
    bDPW = 0;  bVector = 1;
   %CDP
    [dist, table, match_pair, nPair] = cdp(v_template,v_test,slope_mode,5, threshold,bVector, bDPW);

    %draw data
    draw_cdpmatching_graph(template,test, match_pair, nPair,table, threshold, x_test);
    xlim([0 60]);
    ylim([-100 400]);
end


