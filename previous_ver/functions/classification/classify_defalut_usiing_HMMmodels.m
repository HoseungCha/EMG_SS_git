function classify_defalut_usiing_HMMmodels()
% load HMM models
[file, path] = uigetfile('*.mat', 'Open from a file');
save_path = fullfile(path, file);
load(save_path);


    %%  Classify target word by choosing HMM model which has the most high log likeligood value 
    % Compute the log-likelihood of a dataset using a (mixture of) Gaussians HMM
h = waitbar(0,'Please wait...');
idx_test=find(indices_for_test==1);
size_of_test=length(idx_test);
for nTarget_words=1:N_text
%     if nTarget_words==13
%         keyboard
%     end
    for i=1:size_of_test
         FeaturesVector_for_test=Features_for_input_HMM(:,:,idx_test(i),nTarget_words);
%     FeaturesVector_for_test=Features_for_input_HMM(:,:,indices_for_test,nTarget_words); %  단어"바람"의 Sessions1 데이터 들어옴

        for ii=1:N_text %  단어"바람"의 Sessions 1데이터가 이 5 개 HMM모델에 들어가 likelihood 계산 
            loglik(ii,1) = mhmm_logprob(FeaturesVector_for_test,...
            HMM2Text(ii,1).prior1, HMM2Text(ii,1).transmat1,...
            HMM2Text(ii,1).mu1, HMM2Text(ii,1).Sigma1,...
            HMM2Text(ii,1).mixmat1); 
        end

        [the_max, index_of_max] = max(loglik); % 5개의 likelihood값중 최대값이, 타켓단어의 likelihood값인지 판별(같으면 1)
        Classification_results(nTarget_words,i).max=the_max; 
        Classification_results(nTarget_words,i).index_of_word=nTarget_words;       
        Classification_results(nTarget_words,i).index_of_Classified_word=index_of_max;
        Classification_results(nTarget_words,i).loglik_obtained_by_each_HMM=loglik;
        Classification_results(nTarget_words,i).correction= index_of_max==nTarget_words;   
        % 설명
        % Classification_results(1, 1).loglik_obtained_by_each_HMM Session1의 단어 1을,단어
        % HMM 모델 1~5에 넣엏을 떄 나온 likelihood값 (:,iteration)
        % computation here %
    end
            waitbar(nTarget_words/N_text,h)  

end
%% get Accuracy of each word

[f_target,f_output]=arrange_data2Confusion(Classification_results,N_text);
C = confusionmat(f_target,f_output);
C = C./repmat(sum(C,2),1,size(C,2));
C = C*100;
% plotConfusion(f_target,f_output);
disp(diag(C));

% 결과 저장

verbose_time = strjoin(strsplit((mat2str(fix(clock)))), '_');
verbose_time = strrep(verbose_time, '[', '');
verbose_time = strrep(verbose_time, ']', '');

uisname=sprintf('%s_%s-based_HMM_%d_of_%d_CV_results_Q%d_M%d',...
    verbose_time,featurename,size_of_test,N_sequence,Q,M);
uisave({'C','Classification_results',...
    'HMM2Text','Q','M','N_text','N_sequence'},uisname)
% save(uisname,'C','Classification_results',...
%     'HMM2Text','Q','M','N_text','N_sequence'...
%     )
end