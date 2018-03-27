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
params.SamplingFrequency2Use = 1024; % 2048Hz에서 1024Hz로 DownSamplilng
params.DecimateFactor= 2048/params.SamplingFrequency2Use;
params.numEEG=17;
params.numAIB=0;
params.CompNum = 10; % Number of Components 4

% timer 함수 설정 
params.DelayTime = 0.25; % in sec, 0.25초마다 코드를 실행시켜 데이터를 불러옴
params.BufferTime = 10; % in sec, EMG 데이터 buffer 크기 설정 (GUI에서 Plot)
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
params.epoch_length_bef=0.5; % 음성 발화시점 이전 0.5초
params.epoch_length=0.5; % 음성 발화시점 이후 0.5초
% 추출한 feature name list
params.fList2extract={'RMS';'MAX_MIN';'TEAGER';...
    'ACTIVITY';'MOBILITY';'COMPLEXITY'};

% traning 혹은 teat할 단어 순서 정보 설정 
% (예:20일 경우, 4가지 단어가 무작위로, 20번 반복 됨= 총 80 trial
% 80 trial이 무작위 순서로 배열됨, 이 정보를 이용하여 실험이 진행됨)
params.numbering_image={'1','2','3','4'}; % 1번그림: home, 2번그림:Choose, 3번그림: back, 4번 그림: saumsung pay
params.matched_word={'home','choose','back','samsung pay'};
trainning_repeatition=20;
params.training_sequence=[]; 
for ii=1:trainning_repeatition
    temp_sequence=randperm(length(params.matched_word))';
    params.training_sequence=[params.training_sequence;temp_sequence];
end
params.training_sequence4backup=params.training_sequence; % back-up

% resources\image 에서 4가지 그림을 미리 불러온 후, GUI handle에 Plot하여 변수로 저장
for ii=1:length(params.numbering_image)
    eval(sprintf('img.jpg_%s = imread(fullfile(pwd,''resources'',''image'',''%s.jpg''));',...
        params.numbering_image{ii},params.numbering_image{ii}));
    eval(sprintf('params.handle.img%s=imshow(img.jpg_%s,''Parent'',g_handles.Lip_shape_image_axis%s);',...
        params.numbering_image{ii},params.numbering_image{ii},params.numbering_image{ii}));
end

% GUI axis를 모두 보이지 않게 하여 GUI에 아무 그림이 뜨지 않게 초기화
for ii=1:length(params.numbering_image)
    eval(sprintf('set(params.handle.img%s,''Visible'',''off'');',...
        params.numbering_image{ii}));
end
end

