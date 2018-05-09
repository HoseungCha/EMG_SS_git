%--------------------------------------------------------------------------
% I keep this code as default code of feature extraction
%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%--------------------------------------------------------------------------
clc; clear all; close all;

%------------------------code analysis parameter--------------------------%
% decide the raw DB to analyse
name_DB_raw = 'DB_raw';
name_DB_process = 'DB_processed';

% decide number of segments in 3-sec long EMG data
period_wininc = 0.1; % s
period_winsize = 0.1;

% decide types of features to extract
% name_feat2use = {'RMS','WL','CC','SampEN','Min_Max','Teager','Hjorth'};
name_feat2use = {'RMS'};

% decide channel to be used
idx_ch_config = [11:17];
%-------------------VR configuriation
% 4 channels [1,2,9,10], [1,3,8,10], [2,3,8,9]
% 6 channels [1,2,3,8,9,10]

%-------------------Speech configuration
% idx_ch_config = [11:17];

%-------------------------------------------------------------------------%

%-------------set paths in compliance with Cha's code structure-----------%
% path_research = fileparts(fileparts(fileparts(fullfile(cd))));
path_code = fileparts(fullfile(cd));
path_DB = fullfile(path_code,'DB');
path_DB_raw = fullfile(path_DB,name_DB_raw);
path_DB_process = fullfile(path_DB,name_DB_process);
%-------------------------------------------------------------------------%

%-------------------------add functions-----------------------------------%
% addpath(genpath(fullfile(path_research,'_toolbox')));
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



% name of VR and Speech version
% name_ch_config = fieldnames(idx_ch_config);

% number of channel configuration
% n_ch_config = length(name_ch_config);

% struct 2 cell
% idx_ch_config = struct2cell(idx_ch_config);

%-----------------------set feature indices-------------------------------%
% feature list which was extracted in feat_extraction.m
name_feat_list = {'RMS','WL','CC','SampEN','Min_Max','Teager','Hjorth'};

% number of feature types
n_ftype = length(name_feat_list);

% idices of feature types to be used in this code
idx_ftype2use = find(contains(name_feat_list,name_feat2use)==1);

% value which should be multiplied by EMG channel
v_multply_of_feat = [1 1 1 4 1 1 3];

% number of feature types to be used in this code
n_ftype2use = length(idx_ftype2use==1);

% indices of EMG pair
idx_bp_pair = nchoosek(idx_ch_config,2);

% number of bipolar pairs of each channel configuration
n_bp = length(idx_bp_pair);

% number of features to be used
n_feat2use = sum(v_multply_of_feat(idx_ftype2use)*n_bp);

% %---------------set number and indices of features------------------------%
% tmp = cell(n_ftype2use,1);
% for i_feat_type = idx_ftype2use
%     tmp{i_feat_type} = i_feat_type*ones(v_multply_of_feat(i_feat_type)*...
%         n_bp,1);
% end
% idx_feat2use  = cell(n_ftype2use,1);
% for i_feat_type = 1 : n_ftype2use
%     idx_feat2use{i_feat_type} = find(idx_ftype2use(i_feat_type)==cat(1,tmp{:}));
% end
% %-------------------------------------------------------------------------%

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

period_FE_front = 0.5; % 0.5 s
period_FE_end = 1; % 1 s
n_seg = (period_FE_front+period_FE_end)/period_wininc; % choose 30 or 60
n_wininc = floor(period_wininc*fp.SF2use);
n_winsize = floor(period_winsize*fp.SF2use); % win
%-------------------------------------------------------------------------%

%----------------------set saving folder----------------------------------%
name_folder4saving = sprintf(...
    'feat_set_%s_n_sub_%d_n_seg_%d_n_wininc_%d_winsize_%d',...
    name_DB_raw,n_sub,n_seg,n_wininc,n_winsize);
path_save = make_path_n_retrun_the_path(fullfile(path_DB_process),...
    name_folder4saving);
%-------------------------------------------------------------------------%

% memory alloation
features = zeros(n_seg,n_feat2use,n_word,n_trl,n_sub);

%----------------------------MAIN-----------------------------------------%
for i_sub = 1 : n_sub
    %subject name
    tmp_name_sub = name_sub{i_sub}(end-2:end);
    
    % read BDF
    [~,path_file] = read_names_of_file_in_folder(path_sub{i_sub},'*bdf');
    
    % for saving feature Set (processed DB)
    for i_trl = 1 : n_trl
        out = pop_biosig(path_file{i_trl});
        
        %-------load trigger and get sequnce of words in the expmt--------%
        %Trigger latency 및 FE 라벨
        tmp = cell2mat(permute(struct2cell(out.event),[1 3 2]))';
        tmp(:,1) = tmp(:,1)./128;
        % first get rid of speech onset trg
        idx_speech_trg = tmp(:,1)==0.5;
        idx_speech_onset = tmp(idx_speech_trg,:);
        tmp(idx_speech_trg,:) = [];
        
        lat_trg = tmp(2:2:n_word*2,2);
        
        Idx_trg_obtained = reshape(tmp(:,1),[2,n_word*2/2])';
        [~,idx_in_order] = sortrows(Idx_trg_obtained);
        
        tmp = sortrows([idx_in_order,(1:length(idx_in_order))'],1);
        idx_seq_FE = tmp(:,2);
        clear Idx_trg_obtained tmp
        
        %select trg of speech onset to use
        lat_trg_speech = zeros(n_word,1);
        for i_word = 1 : n_word
            if i_word == 1
                % during silent, use the trigger of instruction
                lat_trg_speech(i_word) = lat_trg(i_word);
            elseif i_word == n_word
                % during last word, campare only previous trigger of instruction
                idx_speech_onset_between_trg = ...
                    find((idx_speech_onset(:,2)>lat_trg(i_word))==1);
            else
                % during other words, compare triggers between instructions
                idx_speech_onset_between_trg = ...
                    find((idx_speech_onset(:,2)>lat_trg(i_word)).*...
                    (idx_speech_onset(:,2)<lat_trg(i_word+1))==1);
            end
            % get first trg of speech onsets
            try
                if lat_trg_speech(i_word) == 0
                    lat_trg_speech(i_word) = idx_speech_onset(...
                        idx_speech_onset_between_trg(1),2);
                end
                id_skip = 0;
            catch ex
                % save NaN data for data consistency
                % when trigger was not properly acquired
                if strcmp(ex.identifier,'MATLAB:badsubscript')
                    lat_trg_speech(i_word) = NaN;
                    id_skip = 1;
                    features(:,:,i_trl,:) = NaN(size(features(:,:,i_trl,:)));
                    break;
                end
            end
        end
        if id_skip == 1
            continue;
        end
        %-----------------------------------------------------------------%
        
        %get possible data from bipolar electrode configuration
        data_bip = cell(n_bp,1);
        for i_pair_ch = 1 : n_bp
            data_bip{i_pair_ch} = ...
                out.data(idx_bp_pair(i_pair_ch,1),:) - ...
                out.data(idx_bp_pair(i_pair_ch,2),:);
        end
        data_bip = double(cell2mat(data_bip))';
        
        clear out data_2_use;
        
        % filtering
        data_filtered = filter(fp.nb, fp.na, data_bip,[],1);
        data_filtered = filter(fp.bb, fp.ba, data_filtered, [],1);
        clear data_bip;
        
        %----------------------feat extracion of windows------------------%
        n_win = floor((length(data_filtered) - n_winsize)/n_wininc)+1;
        tmp_feat = zeros(n_win,n_feat2use );
        idx_trg_as_window = zeros(n_win,1);
        st = 1;
        en = n_winsize;
        for i_win = 1 : n_win
            % check trigger in signal window
            idx_trg_as_window(i_win) = en;
            
            % time domain features
            curr_win = data_filtered(st:en,:);
            
            % get features of EMG
            tmp = EMG_feat_extraction(curr_win,name_feat_list,name_feat2use);
            tmp_feat(i_win,:) = tmp;
            
            % moving windows
            st = st + n_wininc;
            en = en + n_wininc;
        end
        %         clear tmp_rms tmp_CC tmp_WL tmp_SampEN tmp_min_max tmp_teager ...
        %             tmp_Hjorth
        %------------------------------------------------------------------%
        
        % cutting trigger
        idx_trg_start = zeros(n_word,1);
        for i_emo_orer_in_this_exp = 1 : n_word
            idx_trg_start(i_emo_orer_in_this_exp,1) =...
                find(idx_trg_as_window >= lat_trg_speech(i_emo_orer_in_this_exp),1);
        end
        
        %---------------------construct features---------------------------%
        % Get Feature sets(preprocessed DB)
        % [n_seg,n_feat,n_fe,n_trl,n_sub,n_comb]
        for i_emo_orer_in_this_exp = 1 : n_word
            features(:,:,idx_seq_FE(i_emo_orer_in_this_exp),i_trl,i_sub) = ...
                tmp_feat(idx_trg_start(i_emo_orer_in_this_exp)...
                -floor((period_FE_front*fp.SF2use)/n_wininc):...
                idx_trg_start(i_emo_orer_in_this_exp)...
                +floor((period_FE_end*fp.SF2use)/n_wininc)-1 ,:);
        end
        %-----------------------------------------------------------------%
        
        %--------------------------plot and save--------------------------%
        figure(i_sub);
        set(gcf,'Position',[1 41 1920 962]);
        subplot(n_trl,1,i_trl);
        tmp = reshape(permute(features(:,:,...
            :,i_trl,i_sub),[1 3 2]),[n_seg*n_word,n_feat2use]);
        plot(tmp);
        set(gca,'YTickLabel',[])
        hold on;
        ylim([min(min(tmp)),max(max(tmp))]);
        xlim([0,length(tmp)]);
        tmp = get(gca,'YLim');
        stem(1:n_seg:n_seg*n_word,repmat(tmp(1),[n_word,1]),'r','LineWidth',1);
        stem(1:n_seg:n_seg*n_word,repmat(tmp(2),[n_word,1]),'r','LineWidth',1);
        drawnow;
        %-----------------------------------------------------------------%
    end
    % tight subplot
    tightfig;
    % plot the DB of subject
    savefig(gcf,fullfile(path_save,sprintf('subject-%s feat-%s',...
        tmp_name_sub(1:3),cat(2,name_feat2use{:}))));
    close
end

% 결과 저장
save(fullfile(path_save,sprintf('feat_set_%s_%s',...
    strrep(num2str(idx_ch_config),' ',''),...
    cat(2,name_feat2use{:}))),'features');


%--------------------------------functions--------------------------------%

function tmp_feat = EMG_feat_extraction(curr_win,name_feat_list,name_feat2use)

% determination of feature types to extract
id_feat2ext = contains(name_feat_list,name_feat2use);

% get number of channel of signal window
n_ch = size(curr_win,2);

if id_feat2ext(1)
    % RMS
    tmp_rms = sqrt(mean(curr_win.^2));
else
    tmp_rms = [];
end

if id_feat2ext(2)
    % WL
    tmp_WL = sum(abs(diff(curr_win,2)));
else
    tmp_WL = [];
end

if id_feat2ext(3)
    % CC
    tmp_CC = featCC(curr_win,4);
else
    tmp_CC = [];
end

if id_feat2ext(4)
    % SAMPLE ENTROPY
    tmp_SampEN = SamplEN(curr_win,2);
else
    tmp_SampEN = [];
end

if id_feat2ext(5)
    % MIN MAX
    tmp = minmax(curr_win');
    tmp_min_max = (tmp(:,2)-tmp(:,1))';
else
    tmp_min_max = [];
end

if id_feat2ext(6)
    % TEAGER
    tmp_teager = zeros(1,n_ch);
    for i = 1 : n_ch
        tmp = cal_freqweighted_energy(curr_win(:,i),1,'teager');
        tmp_teager(i) = sum(tmp)/length(tmp);
    end
else
    tmp_teager = [];
end

if id_feat2ext(7)
    % HJORTH PARAMETERS
    tmp_activity = var(curr_win);
    tmp_mobility = sqrt(var(diff(curr_win))./var(curr_win));
    tmp_complexity = sqrt(var(diff(diff(curr_win)))./var(diff(curr_win)));
    tmp_Hjorth = [tmp_activity,tmp_mobility,tmp_complexity];
else
    tmp_Hjorth = [];
end

% concatinating features
tmp_feat = [tmp_rms,tmp_WL,tmp_SampEN,tmp_CC,...
    tmp_min_max,tmp_teager,tmp_Hjorth];
end
