%--------------------------------------------------------------------------
% feat extracion code for silent search
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
clc; clear; close all;

%------------------------code analysis parameter--------------------------%
% decide the raw DB to analyse
name_DB_raw = 'DB_raw';
name_DB_process = 'DB_processed';

% decide number of segments in 3-sec long EMG data
period_winsize = 0.1;
period_wininc = 0.1; % s
period_word2clsy = 1.5; % 3-sec
% decide types of features to extract
str_features2use = {'RMS','WL','CC','SampEN','Min_Max','Teager','Hjorth'};
%-------------------------------------------------------------------------%

%-------------set paths in compliance with Cha's code structure-----------%
path_research = fileparts(fileparts(fileparts(fullfile(cd))));
path_code = fileparts(fullfile(cd));
path_DB = fullfile(path_code,'DB');
path_DB_raw = fullfile(path_DB,name_DB_raw);
path_DB_process = fullfile(path_DB,name_DB_process);
%-------------------------------------------------------------------------%

%-------------------------add functions-----------------------------------%
addpath(genpath(fullfile(path_research,'_toolbox')));
addpath(genpath(fullfile(cd,'functions')));
%-------------------------------------------------------------------------%

%------------------------experiment infromation---------------------------%
% trigger singals corresponding to each facial expression(emotion)
name_trg = ["Silence","1","1";"Home","1","2";"Back","1","3";...
    "Recents","1","4";"Volume","1","5";"Brightness","1","6";...
    "Settings","1","7";"Wifi","2","1";"Bluetooth","2","2";...
    "Vibrate","2","3";"Sound","2","4";"up","2","5";"down","2","6";...
    "left","2","7";"right","3","1";"Alarms","3","2";"Timers","3","3";...
    "Music","3","4";"Navigate","3","5";"Ok_Google","3","6";...
    "Hey_Siri","3","7"];

name_word = name_trg(:,1);
% idx_trg = cell2mat(name_trg(:,2:3));
clear name_trg;
n_word = length(name_word);% Number of words
n_trl = 20; % Number of Trials

% set channel types of VR and Speech version.
idx_ch_config.vr = [1,2,3,8,9,10];
idx_ch_config.speech = 11:17;

% name of VR and Speech version
name_ch_config = fieldnames(idx_ch_config);

% number of channel configuration
n_ch_config = length(name_ch_config);

% struct 2 cell
idx_ch_config = struct2cell(idx_ch_config);

%-----------------------set feature indices-------------------------------%
% feature list which was extracted in feat_extraction.m
name_feat_list = {'RMS','WL','CC','SampEN','Min_Max','Teager','Hjorth'};

% number of feature types
n_ftype = length(name_feat_list);

% value which should be multiplied by EMG channel
v_multply_of_feat = [1 1 1 4 1 1 3];

% idices of feature types to be used in this code
idx_ftype2use = find(contains(name_feat_list,str_features2use)==1);

% number of feature types to be used in this code
n_ftype2use = length(idx_ftype2use==1);

% indices of EMG pair
idx_bp_pair = cell(n_ch_config,1);

% number of bipolar pairs of each channel configuration
n_bp = cell(n_ch_config,1);

% indices of feature types which to be used
idx_feat2use = cell(n_ch_config,1);

% number of features to be used
n_feat2use = cell(n_ch_config,1);

% set number and indices of features of each channel configureation
for i_ch_config = 1 : n_ch_config
% indices of EMG pair
idx_bp_pair{i_ch_config} = nchoosek(1:length(idx_ch_config{i_ch_config}),2);

% number of bipolar pairs of each channel configuration
n_bp{i_ch_config} = length(idx_bp_pair{i_ch_config});

n_feat2use{i_ch_config} = sum(v_multply_of_feat(idx_ftype2use)*...
    n_bp{i_ch_config});

temp = cell(n_ftype,1);
for i_feat_type = 1 : n_ftype
    temp{i_feat_type} = i_feat_type*ones(v_multply_of_feat(i_feat_type)*...
        n_bp{i_ch_config},1);
end
idx_feat2use{i_ch_config}  = cell(n_ftype2use,1);
for i_feat_type = 1 : n_ftype2use
    idx_feat2use{i_ch_config}{i_feat_type} = find(idx_ftype2use(i_feat_type)==cat(1,temp{:}));
end
end      
%-------------------------------------------------------------------------%

%----------------------------paramters------------------------------------%
% filter parameters
fp.SF2use = 2048;
fp.filter_order = 4; fp.Fn = fp.SF2use/2;
fp.freq_notch = [58 62];
fp.freq_BPF = [20 450];
[fp.nb,fp.na] = butter(fp.filter_order,fp.freq_notch/fp.Fn,'stop');
[fp.bb,fp.ba] = butter(fp.filter_order,fp.freq_BPF/fp.Fn,'bandpass');

% read file path of subjects
[name_sub,path_sub] = read_names_of_file_in_folder(path_DB_raw);
n_sub= length(name_sub);

% experiments or feat extractions parameters
n_ch = 4;
idx_pair_right = [1,2;1,3;2,3]; %% 오른쪽 전극 조합
idx_pair_left = [10,9;10,8;9,8]; %% 왼쪽 전극 조합

% n_seg = period_word2clsy/period_wininc; % choose 30 or 60
n_wininc = floor(period_wininc*fp.SF2use); 
n_winsize = floor(period_winsize*fp.SF2use); % win size

% subplot 그림 꽉 차게 출력 관련 
id_subplot_make_it_tight = true; subplot = @(m,n,p) subtightplot (m, n, p,...
    [0.01 0.05], [0.1 0.01], [0.1 0.01]);
if ~id_subplot_make_it_tight,  clear subplot;  end
%-------------------------------------------------------------------------%

%----------------------set saving folder----------------------------------%
name_folder4saving = sprintf(...
'feat_set_%s_n_sub_%d_n_wininc_%d_winsize_%d',...
    name_DB_raw,n_sub,n_wininc,n_winsize);
path_save = make_path_n_retrun_the_path(fullfile(path_DB_process),...
    name_folder4saving);
%-------------------------------------------------------------------------%


for i_ch_config = 1 : n_ch_config
% memory alloation
features = zeros(n_feat2use{i_ch_config},n_word,n_trl,n_sub);
for i_sub = 1 : n_sub
    %subject name
    tmp_name_sub = name_sub{i_sub}(end-2:end); 
    
    % read BDF
    [~,path_file] = read_names_of_file_in_folder(path_sub{i_sub},'*bdf');
   
    % for saving feature Set (processed DB)
    c_trl = 0;
    for i_trl = 1 : n_trl
        c_trl = c_trl + 1;
        out = pop_biosig(path_file{i_trl});
        
        %-------load trigger and get sequnce of words in the expmt--------%
        %Trigger latency 및 FE 라벨
        temp = cell2mat(permute(struct2cell(out.event),[1 3 2]))';
        temp(:,1) = temp(:,1)./128;
        
        % first get rid of speech onset trg
        idx_speech_trg = temp(:,1)==0.5;
        idx_speech_onset = temp(idx_speech_trg,:);
        temp(idx_speech_trg,:) = [];
        
        lat_trg = temp(1:2:n_word*2,2);
        
        Idx_trg_obtained = reshape(temp(:,1),[2,n_word*2/2])';
        [~,idx_in_order] = sortrows(Idx_trg_obtained);

        temp = sortrows([idx_in_order,(1:length(idx_in_order))'],1); 
        idx_seq_FE = temp(:,2); 
        clear Idx_trg_obtained temp
        
        %select trg of speech onset to use
        lat_trg_speech = zeros(n_word,1);
        for i = 1 : n_word
            lat_trg_speech(i) = idx_speech_onset(...
                find(idx_speech_onset(:,2)>lat_trg(i),1),2);
        end      
        %-----------------------------------------------------------------%
        
        % extract the data with channles position you get(VR, Speech)
        data_2_use = out.data(idx_ch_config{i_ch_config},:);
        
        %get possible data from bipolar electrode configuration     
        data_bip = cell(n_bp{i_ch_config},1);
        for i_pair_ch = 1 : n_bp{i_ch_config}
            data_bip{i_pair_ch} = ...
                data_2_use(idx_bp_pair{i_ch_config}(i_pair_ch,1),:) - ...
                data_2_use(idx_bp_pair{i_ch_config}(i_pair_ch,2),:);
        end
        data_bip = double(cell2mat(data_bip))';

        clear out data_2_use;
        
        % filtering
        data_filtered = filter(fp.nb, fp.na, data_bip,[],1);
        data_filtered = filter(fp.bb, fp.ba, data_filtered, [],1);
        clear data_bip;
        
        %----------------------get triggers of windows------------------%
        n_win = floor((length(data_filtered) - n_winsize)/n_wininc)+1;
        temp_feat = zeros(n_win,n_feat2use{i_ch_config} );
        idx_trg_as_window = zeros(n_win,1);
        emg_win = cell(n_win,1);
        st = 1;
        en = n_winsize;
        for i_win = 1 : n_win
            idx_trg_as_window(i_win) = en;
            
%             % time domain features 
            emg_win{i_win} = data_filtered(st:en,:);
            
            % moving windows
            st = st + n_wininc;
            en = en + n_wininc; 
        end
        %-----------------------------------------------------------------%
 
        % cutting trigger 
        idx_trg_start = zeros(n_word,1);
        for i_emo_orer_in_this_exp = 1 : n_word
            idx_trg_start(i_emo_orer_in_this_exp,1) =...
                find(idx_trg_as_window >= lat_trg_speech(i_emo_orer_in_this_exp),1);
        end        

       %---------------------construct features---------------------------%
       % Get Feature sets(preprocessed DB)
       % [n_feat,n_fe,n_trl,n_sub,n_comb]
        for i_emo_orer_in_this_exp = 1 : n_word
            % get EMG during period of word pronuciation
            tmp = emg_win(idx_trg_start(i_emo_orer_in_this_exp):...
                        idx_trg_start(i_emo_orer_in_this_exp)...
                        +floor((period_word2clsy*fp.SF2use)/n_wininc)-1 ,:);
            tmp = cell2mat(tmp);
            
            % get features of EMG
            temp_feat = EMG_feat_extraction(tmp);
                    
            % collect features
            features(:,idx_seq_FE(i_emo_orer_in_this_exp),c_trl,i_sub) = ...
                temp_feat';
        end 
        %-----------------------------------------------------------------%
    end  
end
%--------------------------plot and save--------------------------%
% tmp = features(:,:,1,1)

%-----------------------------------------------------------------%

% 결과 저장
idx_feat = idx_feat2use{i_ch_config};
save(fullfile(path_save,sprintf('feat_set_%s',...
    name_ch_config{i_ch_config})),'features','idx_feat','name_feat_list');
end


function temp_feat = EMG_feat_extraction(curr_win)
n_ch = size(curr_win,2);

% RMS
temp_rms = sqrt(mean(curr_win.^2));
% WL
temp_WL = sum(abs(diff(curr_win,2)));
% SAMPLE ENTROPY
temp_SampEN = SamplEN(curr_win,2);
% CC
temp_CC = featCC(curr_win,4);
% MIN MAX
tmp = minmax(curr_win');
temp_min_max = (tmp(:,2)-tmp(:,1))';
% TEAGER
temp_teager = zeros(1,n_ch);
for i = 1 : n_ch
    tmp = cal_freqweighted_energy(curr_win(:,i),1,'teager');
    temp_teager(i) = sum(tmp)/length(tmp);
end
% HJORTH PARAMETERS
temp_Hjorth = zeros(1,n_ch*3);
for i = 1 : n_ch
    temp_Hjorth(3*(i-1)+1:3*i) = HjorthParameters(curr_win(:,i));
end

% concatinating features
temp_feat = [temp_rms,temp_WL,temp_SampEN,temp_CC,...
    temp_min_max,temp_teager,temp_Hjorth];
end