%-------------------------------------------------------------------------%
% 1. feat_extraction.m
% 2. classficiation_using_DB.m  %---current code---%
%-------------------------------------------------------------------------%
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%-------------------------------------------------------------------------%
clc; close all; clear all;

%-----------------------Code anlaysis parmaters----------------------------
% name of raw DB
name_DB_raw = 'DB_raw';

% name of process DB to analyze in this code
name_DB_process = 'DB_processed';

% name of anlaysis DB in the process DB
name_DB_analy = 'feat_set_DB_raw_n_sub_2_n_wininc_204_winsize_204';

% name of feature to be loaded
name_feat_file = 'feat_set_speech';

% decide types of features to extract
str_features2use = {'RMS','Min_Max','Teager','Hjorth'};


% decide indices of words to classify
% names_words2use = ["Home";"Back";"Recents";"Volume";"Brightness";...
%     "Settings";"Wifi";"Bluetooth";"Vibrate";"Sound";"up";"down";"left";...
%     "right";"Alarms";"Timers";"Music";"Navigate";"Ok Google";"Hey Siri"];
names_words2use= ["Home";"Back";"up";"down";"left";"right"];

% decide number of tranfored feat from DB 
n_transforemd = 0;

% decide which attibute to be compared when applying train-less algoritm
% [n_seg:30, n_feat:28, n_fe:8, n_trl:20, n_sub:30]
% 'all' : [:,:,:,:,:], 'Only_Seg' : [i_seg,:,:,:,:], 'Seg_FE' : [i_seg,:,i_FE,:,:]
% id_att_compare = 'Only_Seg'; % 'all', 'Only_Seg', 'Seg_FE'
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
idx_feat = getfield(tmp,tmp_name{2}); %#ok<GFLD>
name_feat_list = getfield(tmp,tmp_name{3}); %#ok<GFLD>
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
n_word2classfy = length(idx_word2classfy);
names_word2classfy = names_words(idx_word2classfy);
%-------------------------------------------------------------------------%

%------------------------analysis paramters-------------------------------%
% type of train-less algorithm 
id_DBtype = 'DB_own'; 

N_train = 10;

% load pair set
tmp = load('pairset_new.mat');
idx_pair_set = tmp.pairset_new;

% idices of subject and trials to be anlayzed
idx_sub = 1 : n_sub;
idx_trl = 1 : n_trl;
n_sub_compared = n_sub - 1;


%-----------------------set feature indices-------------------------------%
% number of feature types
n_ftype = length(name_feat_list);

% value which should be multiplied by EMG channel
v_multply_of_feat = [1 1 1 4 1 1 3];

% idices of feature types to be used in this code
idx_ftype2use = find(contains(name_feat_list,str_features2use)==1);
 
idx_feat2use = cat(1,idx_feat{idx_ftype2use});
n_feat2use = length(idx_feat2use);
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%

%---------------------- set folder for saving ----------------------------%
name_folder_saving = [name_feat_file,'_',id_DBtype,...
    '_n_trans_',num2str(n_transforemd),'_',cat(2,names_word2classfy{:})];

% set saving folder for windows
path_saving = make_path_n_retrun_the_path(path_DB_analy,name_folder_saving);
%-------------------------------------------------------------------------%

%----------------------memory allocation for results----------------------%
  
% memory allocatoin for accurucies
r.acc = zeros(n_seg,n_trl,n_sub,N_train,n_transforemd+1);

% memory allocatoin for output and target
r.output_n_target = cell(n_seg,n_trl,n_sub,N_train,n_transforemd+1);  
%-------------------------------------------------------------------------%

%------------------------------------main---------------------------------%
% get accrucies and output/target (for confusion matrix) with respect to
% subject, trial, number of segment, FE,
for i_sub = 1 : n_sub
    for n_train = 1 : N_train
    for i_trl = 1 : n_trl
        % get indices of trial for training set
        idx_trl_tr = idx_pair_set{n_train}(i_trl,:);
        
        %display of subject and trial in progress
        fprintf('i_sub:%d i_trial:%d\n',i_sub,i_trl);

        if n_transforemd>=1
        % memory allocation similarily transformed feature set
        feat_t = cell(n_seg,n_fe);
        
        for i_seg = 1 : n_seg
            for i_FE = 1 : n_fe
                
                
                % memory allocation feature set from other experiment
                feat_t{i_seg,i_FE} = cell(1,n_ftype2use);
                
                % you should get access to DB of other experiment with each
                % features
                for i_feat2use = idx_ftype2use
                    
                %
                idx_feat_each = idx_feat_all{i_ch_config}==1;
                
                % number of feature of each type
                n_feat_each = length(find(idx_feat_each==1));
                
                % feat from this experiment
                feat_ref = feat(i_seg,idx_feat_each,i_FE,idx_trl_tr,i_sub)';
                    
                switch id_DBtype
                case 'DB_own'
                    %---------feat to be compared from this experiment----%
                    % [n_seg:30, n_feat:28, n_fe:8, n_trl:20, n_sub:30, n_emg_pair:3]

                    % compare ohter subject except its own subject
                    idx_sub_compared = countmember(idx_sub,i_sub)==0;
                    switch id_att_compare
                    case 'all'
                        feat_compare = feat(:,idx_feat_each,...
                            :,:,idx_sub_compared,i_emg_pair);

                    case 'Only_Seg'
                        feat_compare = feat(i_seg,idx_feat_each,...
                            :,:,idx_sub_compared);

                    case 'Seg_FE'
                        feat_compare = feat(i_seg,idx_feat_each,i_FE,:,...
                            idx_sub_compared);
                    end
                    
                    % permutation giving [n_feat, n_fe, n_trl, n_sub ,n_seg]
                    feat_compare = permute(feat_compare,[2 3 4 5 1]);
                    
                    %  size(2):FE, size(5):seg
                    feat_compare = reshape(feat_compare,...
                        [n_feat_each, size(feat_compare,2)*n_trl*...
                        n_sub_compared*size(feat_compare,5)]);
                    
                    % get similar features by determined number of
                    % transformed DB
                    feat_t{i_seg,i_FE}{i_feat2use} = ...
                        dtw_search_n_transf(feat_ref, feat_compare,...
                        n_transforemd)';
                    %-----------------------------------------------------%
                end
                end
            end
        end
        
        % arrange feat transformed and target
        % concatinating features with types
        feat_t = cellfun(@(x) cat(2,x{:}),feat_t,'UniformOutput',false);
        end
        % validate with number of transformed DB
        for n_t = 0: n_transforemd
            if n_t >= 1
            % get feature-transformed with number you want
            feat_trans = cellfun(@(x) x(1:n_t,:),feat_t,...
                'UniformOutput',false);
            
            % get size to have target
            size_temp = cell2mat(cellfun(@(x) size(x,1),...
                feat_trans(:,1),'UniformOutput',false));
            
            % feature transformed 
            feat_trans = cell2mat(feat_trans(:));
            
            % target for feature transformed 
            target_feat_trans = repmat(1:n_fe,sum(size_temp,1),1);
            target_feat_trans = target_feat_trans(:); 
            else
            feat_trans = [];    
            target_feat_trans = [];
            end
            
            % feat for anlaysis
            feat_ref = reshape(permute(feat(idx_feat2use,:,idx_trl_tr,i_sub),...
                [1 4 3 2]),[n_train*n_fe,n_feat2use]);
            target_feat_ref = repmat(1:n_fe,n_seg*n_train,1);
            target_feat_ref = target_feat_ref(:);
            
            % get input and targets for train DB
            input_train = cat(1,feat_ref,feat_trans);
            target_train = cat(1,target_feat_ref,target_feat_trans);

            % get input and targets for test DB
            input_test = reshape(permute(feat(:,idx_feat2use,...
                :,countmember(idx_trl,idx_trl_tr)==0,...
                i_sub),[1 4 3 2]),[n_seg*(n_trl-n_train)*n_fe,n_feat2use]);
            target_test = repmat(1:n_fe,n_seg*(n_trl-n_train),1);
            target_test = target_test(:);
            
            % get features of determined emotions that you want to classify
            idx_train_samples_2_classify = countmember(target_train,idx_word2classfy)==1;
            input_train = input_train(idx_train_samples_2_classify,:);
            target_train = target_train(idx_train_samples_2_classify,:);
            
            idx_test_samples_2_classify = countmember(target_test,idx_word2classfy)==1;
            input_test = input_test(idx_test_samples_2_classify,:);
            target_test = target_test(idx_test_samples_2_classify,:);
            
            % train
            model.lda = fitcdiscr(input_train,target_train);
            
            % test
            output_test = predict(model.lda,input_test);
            
            % reshape ouput_test as <seg, trl, FE>
            output_test = reshape(output_test,[n_seg,(n_trl-n_train),n_word2classfy]);
            output_mv_test = majority_vote(output_test,idx_word2classfy);
            
            % reshape target test for acc caculation
            target_test = repmat(idx_word2classfy,(n_trl-n_train),1);
            target_test = target_test(:);
            for i_seg = 1 : n_seg
                ouput_seg = output_mv_test(i_seg,:)';
                r.acc(i_seg,i_trl,i_sub,n_train,n_t+1) = ...
                    sum(target_test==ouput_seg)/(n_word2classfy*(n_trl-n_train))*100;
                r.output_n_target{i_seg,i_trl,i_sub,n_train,n_t+1} = ...
                    [ouput_seg,target_test];
            end
        end
    end
    end
end
%--------------------------------main end---------------------------------%



%------------------------results------------------------------------------%
save(fullfile(path_saving,sprintf('r.mat')),'r');
%-------------------------------------------------------------------------%

%--------------averge of accuracies with subjects and trials--------------%
tmp = struct2cell(r);
tmp = tmp{1};
acc_mean_sub_trl = permute(mean(mean(tmp(:,:,:,:),2),3),[1 4 2 3]);
figure;
plot(acc_mean_sub_trl);
%--------------save
save(fullfile(path_saving,sprintf('acc_mean_sub_trl.mat')),...
    'acc_mean_sub_trl');

% plot of that acc
plot(acc_mean_sub_trl)
%--------------save fig
savefig(gcf,fullfile(path_saving,sprintf('acc_mean_sub_trl.fig')))
close;
%-------------------------------------------------------------------------%

%-----------------averge of accuracies with nd trials---------------------%
acc_mean_trl = mean(r.acc(15,:,:,:),2);


%--------------save
save(fullfile(path_saving,sprintf('acc_mean_trl.mat')),...
    'acc_mean_trl');

% plot of that acc
figure;
bar(tmp(:))
%--------------save fig
savefig(gcf,fullfile(path_saving,sprintf('acc_mean_trl.fig')))
close;
%-------------------------------------------------------------------------%


%---------------------confusion matrix -----------------------------------%
tmp = r.output_n_target(15,:,2,:);
tmp = cat(1,tmp{:});

output_tmp = full(ind2vec(tmp(:,1)'));
target_tmp = full(ind2vec(tmp(:,2)'));

tmp = countmember(1:max(idx_word2classfy),idx_word2classfy)==0;
output_tmp(tmp,:) = [];
target_tmp(tmp,:) = [];

[~,mat_conf,idx_of_samps_with_ith_target,~] = ...
    confusion(target_tmp,output_tmp);

% mat_n_samps = cellfun(@(x) size(x,2),idx_of_samps_with_ith_target);
% xxx = mat_n_samps(logical(eye(size(mat_n_samps))));

%--------------save
save(fullfile(path_saving,sprintf('confusion.mat')),...
    'mat_conf','idx_of_samps_with_ith_target','names_exp2classfy');

% plot of that acc
figure;
plotConfMat(mat_conf, names_word2classfy)
%--------------save fig
savefig(gcf,fullfile(path_saving,sprintf('confusion.fig')))
close;
%-------------------------------------------------------------------------%
