function set_experiment_parameters()
%SET_PARAMETERS
% Experiment Parameter Settings
global params;
global g_handles;


%% Experiment Parameters

% modes
params.use_real_dummy = 1; % 1 = realistic EMG sample signal, ...
% 0 = dummy signal with rectangular pulses
% params.lowpass_filtering=1;

% signal acquisition parameters
params.SamplingFrequency2Use = 1024; % 2048Hz���� 1024Hz�� DownSamplilng
params.DecimateFactor= 2048/params.SamplingFrequency2Use;
params.numEEG=17;
params.numAIB=0;
params.CompNum = 10; % Number of Components 4

% timer �Լ� ���� 
params.DelayTime = 0.25; % in sec, 0.25�ʸ��� �ڵ带 ������� �����͸� �ҷ���
params.BufferTime = 10; % in sec, EMG ������ buffer ũ�� ���� (GUI���� Plot)
params.DataAcquisitionTime = 0.25; % in sec

% pre-processing parameters
params.bandpass_filtering=0;
params.bandpass_filtering_after_epoch=1;
n =2;
Wn = [1 300];    % band-pass filtering frequencies
Fn = params.SamplingFrequency2Use/2;
ftype = 'bandpass';
[b, Vriable] = butter(n, Wn/Fn, ftype);
params.filter.b=b;
params.filter.Vriable=Vriable;
params.filter.zf=[];

% feature parameters
params.epoch_length_bef=0.5; % ���� ��ȭ���� ���� 0.5��
params.epoch_length=0.5; % ���� ��ȭ���� ���� 0.5��
% ������ feature name list
params.fList2extract={'RMS';'MAX_MIN';'TEAGER';...
    'ACTIVITY';'MOBILITY';'COMPLEXITY'};

% traning Ȥ�� teat�� �ܾ� ���� ���� ���� 
% (��:20�� ���, 4���� �ܾ ��������, 20�� �ݺ� ��= �� 80 trial
% 80 trial�� ������ ������ �迭��, �� ������ �̿��Ͽ� ������ �����)
params.numbering_image={'1','2','3','4'}; % 1���׸�: home, 2���׸�:Choose, 3���׸�: back, 4�� �׸�: saumsung pay
params.matched_word={'home','choose','back','samsung pay'};
trainning_repeatition=20;
params.training_sequence=[]; 
for ii=1:trainning_repeatition
    temp_sequence=randperm(length(params.matched_word))';
    params.training_sequence=[params.training_sequence;temp_sequence];
end
params.training_sequence4backup=params.training_sequence; % back-up

% resources\image ���� 4���� �׸��� �̸� �ҷ��� ��, GUI handle�� Plot�Ͽ� ������ ����
for ii=1:length(params.numbering_image)
    eval(sprintf('img.jpg_%s = imread(fullfile(pwd,''resources'',''image'',''%s.jpg''));',...
        params.numbering_image{ii},params.numbering_image{ii}));
    eval(sprintf('params.handle.img%s=imshow(img.jpg_%s,''Parent'',g_handles.Lip_shape_image_axis%s);',...
        params.numbering_image{ii},params.numbering_image{ii},params.numbering_image{ii}));
end

% GUI axis�� ��� ������ �ʰ� �Ͽ� GUI�� �ƹ� �׸��� ���� �ʰ� �ʱ�ȭ
for ii=1:length(params.numbering_image)
    eval(sprintf('set(params.handle.img%s,''Visible'',''off'');',...
        params.numbering_image{ii}));
end
end

