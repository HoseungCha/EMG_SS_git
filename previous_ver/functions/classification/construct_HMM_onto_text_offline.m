function construct_HMM_onto_text_offline()
% select features ans retrieve the features
global buffer
% choose specific features in time-domain
prompt = {'Name features to train HMM',...
    'Input number of states(Q)',...
    'Input number of mixtures of gaussian(M)',...
    'Input Number of sequences you want to tarin (ex: [2:5], or [2,3,4]'};
dlg_title = 'Set features to use';
num_lines = 1;
def = {'TD15_f2_9_0','10','5','[1:29]'};
fanswer = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(fanswer)
    return;
else
    featurename=fanswer{1,1};
    
    Q=str2num(fanswer{2,1});
    M=str2num(fanswer{3,1});
    
    size_feature=set_size_of_feature_set(featurename);
    N_sequence= size(buffer.trial_data,2);
    N_text=size(buffer.trial_data,1);
    % retirece features
    for i=1:N_text
        for j=1:N_sequence
            eval(sprintf('Features_for_input_HMM(:,:,j,i) = buffer.trial_data{i, j}.Feature.%s(:,1:size_feature);'...
                ,featurename));
        end
    end
    
    
    %% Construct HMM model corresponding to each word
    
    orderSequence = [1:N_sequence]';
    h = waitbar(0,'Please wait...');
    
    % Denote train sessions and test session
    indices_for_test = [1:N_sequence]';
    % train= [2:5];
    eval(sprintf('train=%s;',fanswer{4,1}));
    
    indices_for_test(train)=0;
    indices_for_test(nonzeros(indices_for_test))=1;
    indices_for_test=logical(indices_for_test);
    indices_for_train= ~indices_for_test;
    
    
    %% Train HMM
    % (Target_words,1,iter)
    for nTarget_words=1:N_text
        
        % 초기확률 / 전이확률 초기화 (cf:추후 논문 참고하여 초기화 방법바꿔야함)
        % Define parameters for HMM model
        [O,T,~,~] = size(Features_for_input_HMM ); % T:Number of vectors in a sequence % O: Number of coefficients in a vector
        cov_type = 'diag';
        prior0 = normalise(rand(Q,1)); % pi( 전이확률 A 중 초기화값) q1=si 일 때 Pr(Q(1) = i)
        transmat0 = mk_leftright_transmat(Q, diag(prior0)); % left-right model ?Q = num states, p = prob on (i,i), 1-p on (i,i+1)
        
        % 가우시안 혼합을 위한 파라미터 초기화 (mu,sigma, mixmat(가중치))
        % 채널 한꺼번에 포함
        FeaturesVector_for_train=Features_for_input_HMM(:,:,indices_for_train,nTarget_words);
        [mu0, Sigma0 ,weights0] = mixgauss_init(Q*M, FeaturesVector_for_train, cov_type,'kmeans'); % 가우시안 혼합 나눌때 clustering 'kmeans' 사용함 mu -> 평균 , signma -> 공분산, weight(pi)
        mu0 = reshape(mu0, [O Q M]); %% 이게 채널 1개당 만들어지는듯 (한국논문 채널끼리 independent)
        Sigma0 = reshape(Sigma0, [O O Q M]); %% 이게 채널 1개당 만들어지는듯
        A=Sigma0(:,:,1,1);
        mixmat0=reshape(weights0,[Q,M]);
        %             mixmat0 = mk_stochastic(rand(Q,M)); %% 이게 채널 1개당 만들어지는듯
        
        % HMM model training
        % Compute the ML parameters of an HMM with (mixtures of) Gaussians output using EM
        [HMM2Text(nTarget_words,1).LL, HMM2Text(nTarget_words,1).prior1,...
            HMM2Text(nTarget_words,1).transmat1,...
            HMM2Text(nTarget_words,1).mu1, HMM2Text(nTarget_words,1).Sigma1,...
            HMM2Text(nTarget_words,1).mixmat1] = ...
            mhmm_em(FeaturesVector_for_train, prior0, transmat0, mu0, Sigma0, mixmat0, 'cov_type', 'diag','max_iter', 17); %#ok<SAGROW>
        
        % computation here %
        waitbar(nTarget_words/N_text,h)
    end
    %% confirm HMM of each speech text is trained well
    l=1;
    record_HMM_not_converged=0;
    for i=1:N_text
        if(find(isinf(HMM2Text(i,1).LL),1))
            record_HMM_not_converged(l,:)=i;
            l=l+1;
        end
    end
    % 결과 저장
    
    verbose_time = strjoin(strsplit((mat2str(fix(clock)))), '_');
    verbose_time = strrep(verbose_time, '[', '');
    verbose_time = strrep(verbose_time, ']', '');
    sname=strcat(verbose_time,'_',featurename,'-based_HMMmodels');
    uisave({'Features_for_input_HMM','indices_for_test','HMM2Text','Q','M','N_text','N_sequence'...
        'record_HMM_not_converged','featurename','sname'},sname)
    close(h);
end
end
