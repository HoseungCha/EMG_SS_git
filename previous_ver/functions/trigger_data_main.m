function trigger_data_main()
% RETRIEVE_TRIAL_DATA
% retrieves data from recent data acquisition (1s),
% and saves it in trial_data of the buffer

global buffer;
global params;
global g_handles;
global raw_signal_reserve;

%% show matin console
if buffer.n_trial==length(params.training_sequence)+1
    trial_stop();
end
set(g_handles.console, 'String', ['Trial # : ' num2str(buffer.n_trial),...
    'Vowels # : ',params.matched_word(params.training_sequence(1))]);
%%

EMG_channel_length=params.CompNum;

%% pre-allocate
buffer.trial_data{buffer.n_trial,1} = struct();

%% Data Retrieving
% Get the number of data point of this trial
n_data_sum = nansum(buffer.recent_n_data);

if n_data_sum >= params.QueueLength
    n_data_sum = params.QueueLength;
end


% try
if buffer.epoching_settingOn==1 % trigger ������ ���
    
    % Trigger �����ϵ� �ƴϵ� biosemi�� ���� �����ʹ� ��� �޴´�
    temp_data_queue = circshift(buffer.dataqueue.data, ...
        -buffer.dataqueue.index_start+1);
    end_idx = buffer.dataqueue.datasize;
    data_aquastion_by_biosmi = temp_data_queue(end_idx-n_data_sum+1:end_idx, :);
    
    % Trigger ������ ��� Trigger�� ���̴� ������ ��� �߰�
    buffer.trg_n_data_sum=n_data_sum+buffer.trg_n_data_sum;
    if -(n_data_sum+buffer.trg_n_data_sum)+(buffer.serched_trg_idx)+round(params.epoch_length*params.SamplingFrequency2Use)-1>0
        return;
        % 0.25�� ���� biosemi�� �ι� aquasition�� ����� ���� ��
        % (���� aquasition size+���� aqausition size) <  0.25�� ������ size
        % data_queue ������ ���� �ȵǴ� �� ���� �ϱ�!!!!!!!!!!!!!!!!
    else
        % biosemi�� �ι� aquasition���� 0.25�ʰ� ����� ��
        data_queue = circshift(buffer.dataqueue.data, ...
            -buffer.dataqueue.index_start+1);
        
        %% band-pass filtering
        if params.bandpass_filtering_after_epoch
            b=params.filter.b;
            Vriable=params.filter.Vriable;
            data_bandpass(:,1:EMG_channel_length)=simple_filter(data_queue(:,1:EMG_channel_length),b,Vriable);
        end
        
        
        end_idx = buffer.dataqueue.datasize;
        
        if (end_idx-(buffer.trg_n_data_sum)+(buffer.serched_trg_idx)+round(params.epoch_length*params.SamplingFrequency2Use)-1)>end_idx
            return;
            % Trigger ���������� buffer������ 1.5���� ������ ���̰� �ȵ� ��� �Լ��� return��
        end
        
        % Trigger �������� �����͸� �ڸ�
        data_epoched = data_bandpass(end_idx-(buffer.trg_n_data_sum)+(buffer.serched_trg_idx)...
            -round(params.epoch_length_bef*params.SamplingFrequency2Use)+1    ...
            :end_idx-(buffer.trg_n_data_sum)+(buffer.serched_trg_idx)+round(params.epoch_length*params.SamplingFrequency2Use)-1, :);
        
        %% Feature Extraction
        % component 10���η� feature extraction ����
        features=[];
        for ii=1:length(params.fList2extract)
            for ch=1:EMG_channel_length
                eval(sprintf('y=EMG_feature_extraction(data_epoched(:,ch),''%s'');',params.fList2extract{ii}));
                features=[features;y];
            end
        end
        
        %% Classification using SVM
        % feature model �ʿ�, class label�� '1'�� ����
        
        [estLabels, outputs] = predmsvm('online_svm_model',features');
        
        %         estLabels=randi(5);
        
        
        %% Trial Data Saving
        
        if buffer.epching_count==1
            % Saving Speech Onset Infromation onto Trial Data (rawdata ���� +
            % �ش� biosemi acquasition������ trigger ���� -> �������� ����ȯ
            buffer.trial_data{buffer.n_trial,1}.n_data4rawdata = raw_signal_reserve.n_data-buffer.trg_n_data_sum+buffer.serched_trg_idx;
            % ����ȭ input fist aquasition
            buffer.trial_data{buffer.n_trial,1}.trial = buffer.n_trial;
            buffer.trial_data{buffer.n_trial,1}.saved_time{buffer.epching_count,1} = fix(clock);
            buffer.trial_data{buffer.n_trial,1}.n_data{buffer.epching_count,1} = n_data_sum+buffer.trg_n_data_sum;
            buffer.trial_data{buffer.n_trial,1}.data_queue{buffer.epching_count,1} = data_epoched;
            buffer.trial_data{buffer.n_trial,1}.Nepoch=buffer.epching_count;
            % feature saving
            buffer.trial_data{buffer.n_trial,1}.feature{buffer.epching_count,1}=features;
            % classification results saving
            buffer.trial_data{buffer.n_trial,1}.classification.estLabels{buffer.epching_count,1}=estLabels;
            estLabels_first=estLabels;
            
            buffer.trial_data{buffer.n_trial,1}.classification.outputs{buffer.epching_count,1}=outputs;
            %                 if get(g_handles.radiobutton4train, 'Value')
            % training code
            buffer.trial_data{buffer.n_trial,1}.classification.trueLabels=...
                params.training_sequence(1);
            params.training_sequence = circshift(params.training_sequence, -1);
            %                 end
        else
            % ����ȭ after input  first aquasition
            n_trial=buffer.n_trial-1;
            buffer.trial_data{n_trial,1}.saved_time{buffer.epching_count,1} = fix(clock);
            buffer.trial_data{n_trial,1}.n_data{buffer.epching_count,1} = n_data_sum+buffer.trg_n_data_sum;
            buffer.trial_data{n_trial,1}.data_queue{buffer.epching_count,1} = data_epoched;
            buffer.trial_data{n_trial,1}.Nepoch=buffer.epching_count;
            % feature saving
            buffer.trial_data{n_trial,1}.feature{buffer.epching_count,1}=features;
            % classification results saving
            buffer.trial_data{n_trial,1}.classification.estLabels{buffer.epching_count,1}=estLabels;
            buffer.trial_data{n_trial,1}.classification.outputs{buffer.epching_count,1}=outputs;
        end
        % epoching count display
        disp(buffer.epching_count);
        %% image(lip-shape) presentation
        
        for ii=1:length(params.numbering_image)
            eval(sprintf('set(params.handle.img%s,''Visible'',''off'');',params.numbering_image{ii}));
        end
        if exist('estLabels_first','var')
            if get(g_handles.radiobutton4train, 'Value')
                eval(sprintf('set(params.handle.img%d,''Visible'',''on'');', params.training_sequence(1)));
            else
                eval(sprintf('set(params.handle.img%d,''Visible'',''on'');', estLabels_first));
                pause(0.001);
            end
        end
        
        %             params.matched_word={'HOME','SELECT','BACK','UNLOCK','SAMSUNG PAY'};
        %         if exist('estLabels_first','var')
        %             disp(params.matched_word(estLabels_first));
        %         end
        %% Reset Trial Buffer
        buffer.epoching_settingOn=0; % Epoching setting�� ����, ��� Ʈ���Ÿ� ��ġ���� �ʵ�����
        buffer.recent_n_data = zeros(fix(1/params.DelayTime)*params.DataAcquisitionTime, 1);
        if buffer.epching_count==1
            buffer.n_trial=buffer.n_trial+1;
        end
    end
else
    data_queue = circshift(buffer.dataqueue.data, ...
        -buffer.dataqueue.index_start+1);
    end_idx = buffer.dataqueue.datasize;
    data_aquastion_by_biosmi = data_queue(end_idx-n_data_sum+1:end_idx, :);
    % ��� ���� �����͸� ����(_n_data_sum�� �������ɴ� ���������� ������ Ȯ�� ����!!),
    % ��ݵ��� ������ ���� ������ ������ ���� ������ ���� ���� ����
    for ii=1:length(params.numbering_image)
        eval(sprintf('set(params.handle.img%s,''Visible'',''off'');',...
            params.numbering_image{ii}));
    end
    if get(g_handles.radiobutton4train, 'Value')
        eval(sprintf('set(params.handle.img%d,''Visible'',''on'');',...
            params.training_sequence(1)));
        for ii=1:length(params.numbering_image)
            eval(sprintf('set(params.handle.img%s,''Visible'',''off'');',...
                params.numbering_image{ii}));
        end
    else
        %             set(params.handle.img0,'Visible','on');
        for ii=1:length(params.numbering_image)
            eval(sprintf('set(params.handle.img%s,''Visible'',''off'');',...
                params.numbering_image{ii}));
        end
    end
end

if ~exist('data_aquastion_by_biosmi','var')
    keyboard
end


serched_trg_idx=find(data_aquastion_by_biosmi(:,EMG_channel_length+3)==64,1);  % trigger 64

if ~exist('serched_trg_idx','var')
    serched_trg_idx=[];
end

if ~(isempty(serched_trg_idx))  % trigger ����
    buffer.serched_trg_idx=serched_trg_idx;
    buffer.epoching_settingOn=1;
    buffer.epching_count=buffer.epching_count+1;
    buffer.trg_n_data_sum=n_data_sum; % Trigger �����Ͽ��� �� Trigger �����;� �ʱ�ȭ
    buffer.n_count_result_showing=-1;
else
    buffer.epching_count=0;
end
% catch ex
%     if strcmp(ex.message,'''data_queue''��(��) ���ǵ��� ���� �Լ� �Ǵ� �����Դϴ�.')
%         return;
%     end
%     keyboard
% end

end



