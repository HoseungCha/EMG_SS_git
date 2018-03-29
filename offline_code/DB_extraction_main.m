%----------------------------------------------------------------------
% EMG speech onset 부분 추출하여 합치는 코드
%----------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%---------------------------------------------------------------------

clear; close all; clc
addpath(genpath(fullfile(cd,'functions')));
DB_path = 'E:\OneDrive_Hanyang\연구\EMG_Silent_Search\코드';

%% 실험 정보
N_subject = 21;
N_trial = 15;
N_marker = 28;
p.SR = 2048; % biosemi sampling rate
p.len_win = 0.1; % window
p.SP_win = 0.1;
p.winsize = floor(p.SR*p.len_win);
p.wininc = floor(p.SR*p.SP_win);
% p.winsize = p.wininc;
p.time4word_recog = 2;
p.windows = p.time4word_recog/p.SP_win;

%% biploar 채널 조합
p.rc_matrix = [1,2;1,3;2,3]; %% 오른쪽 전극 조합
p.lc_matrix = [10,9;10,8;9,8]; %% 왼쪽 전극 조합

%% filter parameters
% Bandpassfilter Parameters
p.Fn = p.SR/2;
p.filter_order = 4;
p.BPF_cutoff_Freq = [20 450];
[p.bB,p.bA] = butter(p.filter_order, p.BPF_cutoff_Freq/p.Fn,'bandpass');

% Notchfilter Parameters
p.NOF_Freq = [59.5 60.5];
[p.nB, p.nA] = butter(p.filter_order, p.NOF_Freq/p.Fn, 'stop');

%% get EMG trigger of speech
trg = load(fullfile(cd,'EMG_trigger_ext_code','Trg_speech'));

%% 저장 폴더 설정
name_folder2save = 'DB_processed';
Path_Ances = make_path_n_retrun_the_path (fullfile(DB_path,'DB'),...
    name_folder2save);

%% read file path of data
[Sname,Spath] = read_names_of_file_in_folder(fullfile(DB_path,'DB','DB_raw'));

% DB memory allocatoin
feat_comb = cell(3,1);
feat_set = cell(N_subject,N_trial);
for i_comb = 1 : 3 % choose EMG channel 2 of 3
%% read bdf and conduct pre-processing of EMG, and get windows
for i_sub= 1 : N_subject
    sub_name = Sname{i_sub}(4:6); % the name of subejcts
    
    % prepare to read bdf file
    [b_fname,b_fpath] = read_names_of_file_in_folder(Spath{i_sub},'*bdf');
    
    for i_trl = 1 : N_trial
        p.trg = trg.Trg_speech{i_sub,i_trl};
        
        %% EMG BDF read
        fname = [Spath{i_sub},'\',num2str(i_trl),'.bdf'];
        OUT = pop_biosig(fname);
            
            %% EMG channel (only lower part, which is why lip
            % movements are not relevant with upper EMG)
            emg_raw.R1 = OUT.data(p.rc_matrix(i_comb,1),:);
            emg_raw.R2 = OUT.data(p.rc_matrix(i_comb,2),:);
            emg_raw.L1 = OUT.data(p.lc_matrix(i_comb,1),:);
            emg_raw.L2 = OUT.data(p.lc_matrix(i_comb,2),:);
            
            %% bipolar configuration
            emg_raw = double(cell2mat(struct2cell(emg_raw)))';
            idx_combi = nchoosek(1:size(emg_raw,2),2);
            N_comb = size(idx_combi,1);
            emg_comb = cell(1,N_comb);
            for i = 1 : N_comb
                emg_comb{i} = emg_raw(:,idx_combi(i,1))-emg_raw(:,idx_combi(i,2));
            end
            emg_comb = double(cell2mat(emg_comb));
            
            %% addition monopolar with bipolar
            emg_data = [emg_raw,emg_comb];
            clear emg_raw emg_comb;
            %% filtering
            emg_data = filter(p.bB,p.bA,emg_data); %% bandpassfilter
            emg_data = filter(p.nB,p.nA,emg_data); %%notchfilter
            
            %% window 추출
            [emg_win,trg_w] = getWindows(emg_data,p.winsize,p.wininc,[],[],p.trg(:,1));
            fname = sprintf('sub_%03d_trl_%03d',i_sub,i_trl);
            
            %% trg_w를 기준으로 2초 windows 추출(20
            feat_wins = cell(length(trg_w),1);
            for i = 1 : length(trg_w)
                temp_wins = emg_win(trg_w(i):trg_w(i)+p.windows-1,:);
                temp_feat = cell(p.windows,1);
                for j = 1 : p.windows
                    curr_win = temp_wins{j};
                    temp_rms = sqrt(mean(curr_win.^2));
                    temp_WL = sum(abs(diff(curr_win,2)));
                    temp_SampEN = SamplEN(curr_win,2);
                    temp_CC = featCC(curr_win,4);
                    temp_feat{j} = [temp_CC,temp_rms,temp_SampEN,temp_WL];
                end
                feat_wins{i} = cell2mat(temp_feat);
            end
            feat_set{i_sub,i_trl} = feat_wins;
%             fname_path = fullfile(Path_child_emg{1,i_comb},fname);
%             save(fname_path,'emg_win');
    end
        disp(fname);
end
    feat_comb{i_comb} = feat_set;
end
%% saving featset
path2save = 'E:\OneDrive_Hanyang\연구\EMG_Silent_Search\코드\DB\DB_processed';
folder_name = sprintf('len_win_%.4f_SP_win_%.4f',p.len_win,p.SP_win);
path = make_path_n_retrun_the_path (Path_Ances,folder_name);
save(fullfile(path,'feat_set.mat'),'feat_set','p');
