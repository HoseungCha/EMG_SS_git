%-------------------------------------------------------------------------%
% 1. feat_extraction.m
% 2. classification_simple.m  %---current code---%
%-------------------------------------------------------------------------%
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%-------------------------------------------------------------------------%
clc; close all; clear;

%-----------------------Code anlaysis parmaters----------------------------
% name of raw DB
name_DB_raw = 'DB_raw';

% name of process DB to analyze in this code
name_DB_process = 'DB_processed';

% name of anlaysis DB in the process DB
name_DB_analy = 'feat_set_DB_raw_n_sub_2_n_seg_15_n_wininc_204_winsize_204';

% name of feature to be loaded
name_feat_file = 'feat_set_12910_RMS';

% decide indices of words to classify
% names_words2use = ["Silence";"Home";"Back";"Recents";"Volume";"Brightness";...
%     "Settings";"Wifi";"Bluetooth";"Vibrate";"Sound";"up";"down";"left";...
%     "right";"Alarms";"Timers";"Music";"Navigate";"Ok Google";"Hey Siri"];
names_words2use = ["Home";"Back";"Volume";...
    "Settings";"Wifi";"Vibrate";"Sound";"up";"down";"left";...
    "right";"Alarms";"Timers";"Navigate";"Ok Google"];
% names_words2use = ["Home";"Back";"up";"down";"left";...
%     "right"];
%-------------------------------------------------------------------------%

%-------------set paths in compliance with Cha's code structure-----------%
% path of research, which contains toolbox
path_research = fileparts(fileparts(fileparts(fullfile(cd))));

% path of code, which
path_code = fileparts(fullfile(cd));
path_DB = fullfile(path_code,'DB');
path_DB_raw = fullfile(path_DB,name_DB_raw);
path_DB_process = fullfile(path_DB,name_DB_process);
path_DB_analy = fullfile(path_DB_process,name_DB_analy);
%-------------------------------------------------------------------------%

%-------------------------add functions-----------------------------------%
% get toolbox
addpath(genpath(fullfile(path_research,'_toolbox')));
% add functions
addpath(genpath(fullfile(cd,'functions')));
%-------------------------------------------------------------------------%

%-----------------------------load DB-------------------------------------%
% load feature set, from this experiment
tmp = load(fullfile(path_DB_analy,name_feat_file));
tmp_name = fieldnames(tmp);
feat = getfield(tmp,tmp_name{1}); %#ok<GFLD>
%-------------------------------------------------------------------------%

%-----------------------experiment information----------------------------%
% DB infromation
[n_seg, n_feat, n_fe, n_trl, n_sub] = size(feat); % DB to be analyzed

% names of subjects
[name_subject,~] = read_names_of_file_in_folder(path_DB_raw);

% names of words
names_words = ["Silence";"Home";"Back";"Recents";"Volume";"Brightness";...
    "Settings";"Wifi";"Bluetooth";"Vibrate";"Sound";"up";"down";"left";...
    "right";"Alarms";"Timers";"Music";"Navigate";"Ok Google";"Hey Siri"];

% indices of words 2 classify
idx_word2classfy = find(contains(names_words,names_words2use)==1);
idx_word2classfy(3) = [];

n_word2classfy = length(idx_word2classfy);
names_word2classfy = names_words(idx_word2classfy);
disp(names_word2classfy);

%-------------------------------------------------------------------------%

%-------------------------------- paramters-------------------------------%
% type of train-less algorithm
id_DBtype = 'DB_own';

N_train = 5;

% load pair set
tmp = load('pairset_new.mat');
idx_pair_set = tmp.pairset_new;

% idices of subject and trials to be anlayzed
idx_sub = 1 : n_sub;
idx_trl = 1 : n_trl;
n_sub_compared = n_sub - 1;
%-------------------------------------------------------------------------%

%-----------------------NN architecture parameters------------------------%
n_HiddenUnits = 100;
layers = [ ...
    sequenceInputLayer(n_feat)
    bilstmLayer(n_HiddenUnits,'OutputMode','last')
    fullyConnectedLayer(n_word2classfy)
    softmaxLayer
    classificationLayer];
n_maxEpochs = 100;
% n_miniBatchSize = 27;

options = trainingOptions('adam', ...
    'GradientThreshold',1, ...
    'MaxEpochs',n_maxEpochs, ...
    'SequenceLength','longest', ...
    'Shuffle','never', ...
    'Verbose',1);
%     'ExecutionEnvironment','gpu', ...

% , ...
%     'Plots','training-progress');
%-------------------------------------------------------------------------%


%---------------------- set folder for saving ----------------------------%
name_folder_saving = [name_feat_file,'_',id_DBtype,...
    '_',strrep(num2str(idx_word2classfy'),' ','')];

% set saving folder for windows
path_saving = make_path_n_retrun_the_path(path_DB_analy,name_folder_saving);
%-------------------------------------------------------------------------%

%----------------------memory allocation for results----------------------%

% memory allocatoin for accurucies
r.acc = zeros(n_trl,n_sub,N_train);

% memory allocatoin for output and target
r.output_n_target = cell(n_trl,n_sub,N_train);

% memory allocatoin for network
r.net= cell(n_trl,n_sub,N_train); 
%-------------------------------------------------------------------------%

%------------------------------------main---------------------------------%
% get accrucies and output/target (for confusion matrix) with respect to
% subject, trial, number of segment, FE,
for i_sub = 1 : n_sub
    for n_train = N_train
        for i_trl = 1 : n_trl
            % get indices of trial for training set
            idx_trl_tr = idx_pair_set{n_train}(i_trl,:);
            
            %display of subject and trial in progress
            fprintf('i_sub:%d i_trial:%d\n',i_sub,i_trl);
            
            % validate with number of transformed DB
            
            feat_trans = [];
            target_feat_trans = [];
            
            % feat for anlaysis
            feat_ref = reshape(permute(feat(:,:,:,idx_trl_tr,i_sub),...
                [1 4 3 2]),[n_seg*n_train*n_fe,n_feat]);
            target_feat_ref = repmat(1:n_fe,n_seg*n_train,1);
            target_feat_ref = target_feat_ref(:);
            
            % get input and targets for train DB
            input_train = cat(1,feat_ref,feat_trans);
            target_train = cat(1,target_feat_ref,target_feat_trans);
            
            % get input and targets for test DB
            input_test = reshape(permute(feat(:,:,...
                :,countmember(idx_trl,idx_trl_tr)==0,...
                i_sub),[1 4 3 2]),[n_seg*(n_trl-n_train)*n_fe,n_feat]);
            target_test = repmat(1:n_fe,n_seg*(n_trl-n_train),1);
            target_test = target_test(:);
            
            % get features of determined emotions that you want to classify
            idx_train_samples_2_classify = countmember(target_train,...
                idx_word2classfy)==1;
            input_train = input_train(idx_train_samples_2_classify,:);
            target_train = target_train(idx_train_samples_2_classify,:);
            
            idx_test_samples_2_classify = countmember(target_test,...
                idx_word2classfy)==1;
            input_test = input_test(idx_test_samples_2_classify,:);
            target_test = target_test(idx_test_samples_2_classify,:);
            
            %----------------------train----------------------------------%
            %             model.svm = fitcsvm(input_train,target_train);
            %             model.lda = fitcdiscr(input_train,target_train);
            tmp = (permute(reshape(input_train,...
                [n_seg,n_train,n_word2classfy,n_feat]),[4 1 2 3]));
            tmp = mat2cell(tmp(:,:,:),...
                n_feat,n_seg,ones(n_train*n_word2classfy,1));
            input_train = tmp(:);
            target_train = repmat(idx_word2classfy',[n_train,1]);
            target_train = categorical(target_train(:));
            net = trainNetwork(input_train,target_train,layers,options);
            %-------------------------------------------------------------%
            
            %--------------------test-------------------------------------%
            tmp = (permute(reshape(input_test,...
                [n_seg,(n_trl-n_train),n_word2classfy,n_feat]),[4 1 2 3]));
            tmp = mat2cell(tmp(:,:,:),...
                n_feat,n_seg,ones((n_trl-n_train)*n_word2classfy,1));
            input_test = tmp(:);
            target_test = repmat(idx_word2classfy',[(n_trl-n_train),1]);
            target_test = categorical(target_test(:));

            output_test = classify(net,input_test, ...
                'SequenceLength','longest');
            
            %--------------------save results-----------------------------%
            r.acc(i_trl,i_sub,n_train) = ...
                sum(output_test==target_test)/...
                (n_word2classfy*(n_trl-n_train))*100;
            fprintf('ACCURUCY: %0.2f\n',...
                r.acc(i_trl,i_sub,n_train));
            r.output_n_target{i_trl,i_sub,n_train} = ...
                [output_test,target_test];
            r.net{i_trl,i_sub,n_train} = net;
            %-------------------------------------------------------------%
        end
    end
end
%--------------------------------main end---------------------------------%

%------------------------results------------------------------------------%
save(fullfile(path_saving,sprintf('r.mat')),'r');
%-------------------------------------------------------------------------%

%--------------averge of accuracies with subjects and trials--------------%
acc_mean_sub_n_trl = permute(mean(mean(r.acc,1),2),[3 2 1]);


% plot of that acc
bar(acc_mean_sub_n_trl)
%--------------save fig
savefig(gcf,fullfile(path_saving,sprintf('acc_mean_sub_n_trl.fig')))
close;

acc_mean_sub_n_trl = permute(mean(r.acc(:,:,:),1),[3 2 1]);
%--------------save
save(fullfile(path_saving,sprintf('acc_mean_sub_n_trl.mat')),...
    'acc_mean_sub_n_trl');
%-------------------------------------------------------------------------%

%-----------------averge of accuracies with nd trials---------------------%
acc_mean_n_trl = permute(mean(mean(r.acc(:,:,:),1),2),[3 2 1]);

% plot of that acc
figure;
bar(acc_mean_n_trl)
%--------------save fig
savefig(gcf,fullfile(path_saving,sprintf('acc_mean_n_trl.fig')))
close;

%--------------save
save(fullfile(path_saving,sprintf('acc_mean_n_trl.mat')),...
    'acc_mean_n_trl');
%-------------------------------------------------------------------------%


%---------------------confusion matrix -----------------------------------%
for n_train = N_train
    tmp = r.output_n_target(:,:,n_train);
    tmp = cat(1,tmp{:});
    % categorical 2 double
    tmp = idx_word2classfy(tmp);
    
    output_tmp = full(ind2vec(tmp(:,1)'));
    target_tmp = full(ind2vec(tmp(:,2)'));
    
    tmp = countmember(1:max(idx_word2classfy),idx_word2classfy)==0;
    
    % get rid of classes which you do not use
    output_tmp(tmp,:) = [];
    target_tmp(tmp,:) = [];
    
    % compute confusion
    [~,mat_conf,idx_of_samps_with_ith_target,~] = ...
        confusion(target_tmp,output_tmp);
    
    % plot of that acc
    figure;
    plotConfMat(mat_conf, names_word2classfy)
    
    %--------------save fig
    savefig(gcf,fullfile(path_saving,sprintf('confusion_train-%d.fig',n_train)))
    close;
    
    %--------------save
    save(fullfile(path_saving,sprintf('confusion_train-%d.mat',n_train)),...
        'mat_conf','idx_of_samps_with_ith_target','names_word2classfy');
end
%-------------------------------------------------------------------------%
