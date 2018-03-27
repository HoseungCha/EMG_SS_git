%--------------------------------------------------------------------------
% GUI 변수 초기화 함수
%--------------------------------------------------------------------------
% by Ho-Seung Cha, Ph.D Student
% Ph.D candidate @ Department of Biomedical Engineering, Hanyang University
% hoseungcha@gmail.com
%--------------------------------------------------------------------------
function initialize(handles)
global info;
global pd;
global initalize_button;
initalize_button = 1;
% 
clc;
GUI_mode_presentation(handles)
%% timer 초기화
if ~isempty(timerfind)
    stop(timerfind);delete(timerfind);
end

% info.timer.Beep = timer('StartDelay', 5, 'TimerFcn','GUI_BEEP_sound',...
%     'Period', 6, 'ExecutionMode', 'fixedRate');
%% 기본정보
info.N_FE = 8; % 표정 갯수
info.FE_name = {'angry','contemptuous(right)','disgusted','fearfull','happy','neutral',...
    'sad','surprised'};
info.FE_order = randperm(info.N_FE);
info.FE_order4GUI = info.FE_order;
% BEEP sound
[info.beep, info.Beep_Fs] = audioread(fullfile(cd,'rsc','beep.wav'));
% handle
info.handles = handles;
% offline data
info.curr_pos=1;

%%  표정사진 및 인스트럭션 제시 코드
info.timer.FE_train = timer('StartDelay', 5, 'TimerFcn','GUI_FE_inst',...
    'Period', 8, 'ExecutionMode', 'fixedRate');
info.timer.RestInst = timer( 'TimerFcn','GUI_rest_inst',...
    'Period', 8, 'ExecutionMode', 'fixedRate');
info.FE_end_sign = 0;
info.FE_start_sign = 0;
info.FeatSet = cell(info.N_FE,1);
info.test_result = cell(info.N_FE,1);

%% circlequeue length setup
info.Ch = 6;
SF = 2048;
info.Fc = SF;
info.cq.time = 10;
info.cq.length = info.cq.time*SF; % buffer 10초
info.timer.SF = floor(info.Fc*0.1); % 0.05초마다 데이터를 얻음

%% RAWDATA (저장용) 초기화
info.total_ch = 12;
info.rawdata = zeros(info.Fc*10*60,info.total_ch+1); % 5분 데이터 양 끝채널: 표정trigger
info.raw_pos = 1;
%% filter 초기조건
filter_order = 4; Fn = SF/2;
Notch_freq = [58 62];
BPF_cutoff_Freq = [20 450];
[info.f.bB,info.f.bA] = butter(filter_order,BPF_cutoff_Freq/Fn,'bandpass');
[info.f.nB,info.f.nA] = butter(filter_order,Notch_freq/Fn,'stop');
info.f.bZn = []; info.f.nZn = [];
%% set circlequeue
pd.TCP_buffer = circlequeue(info.cq.length,info.total_ch); %10*64, 2채널+Trigger
pd.EMG = circlequeue(info.cq.length,info.Ch); %10*64, 2채널+Trigger
pd.trg = circlequeue(info.cq.length,1);
pd.f.RMS = circlequeue(info.cq.length,info.Ch);
pd.f.CC = circlequeue(info.cq.length,info.Ch*4);
pd.f.WL = circlequeue(info.cq.length,info.Ch);
pd.f.SampEN = circlequeue(info.cq.length,info.Ch);
pd.Predted = circlequeue(30,1);
pd.featset = circlequeue(30,info.Ch*3+info.Ch*4);
pd.test_result = circlequeue(30,1);%초기화

%% timer setup
period4timer = round(info.timer.SF/info.Fc,3);
% period4timer = 0.01;

% info.timer.online_code = timer('TimerFcn','online_code','StartDelay',...
%     period4timer, 'Period',period4timer, 'ExecutionMode', 'fixedRate');
info.timer.online_code = timer('TimerFcn','online_code',...
    'Period',0.1, 'ExecutionMode', 'fixedRate');
% info.timer.process_emg = timer('TimerFcn','Process_EMG',...
%     'Period', 0.1, 'ExecutionMode', 'fixedrate');
info.timer.onPaint = timer('TimerFcn','onPaint','StartDelay',...
    0.05, 'Period', 0.05, 'ExecutionMode', 'fixedRate');

%% image setup
info.im_h = gobjects(info.N_FE,1);
for i_FE=1:info.N_FE
    im_path = fullfile(cd,'img','train',[num2str(i_FE),'.jpg']);
    temp_img= imread(im_path);
    eval(sprintf('info.im_h(i_FE) = imshow(temp_img,''Parent'',handles.axes_img%d);',...
        i_FE));
end
for i_FE=1:info.N_FE
    info.im_h(i_FE).Visible='off';
end
info.im_h(6).Visible = 'on';

%% 웹캠 연결
% if ~isfield(info,'cam')
%     info.cam = webcam(1);
% end
% h1 = preview(info.cam);
% CData = h1.CData;
% closePreview(info.cam);
% info.hcam = image(zeros(size(CData)),'Parent', handles.axes_timg1); 
% info.currp = preview(info.cam,info.hcam);

%% TCP 연결
%configure% the folowing 4 values should match with your setings in Actiview and your network settings 
port = 8888;                %the port that is configured in Actiview , delault = 8888
ipadress = 'localhost';     %the ip adress of the pc that is info.TCP_running Actiview
info.tcp.Channels = 16;             %set to the same value as in Actiview "info.tcp.Channels sent by TCP"
info.tcp.Samples = 16;               %set to the same value as in Actiview "TCP info.tcp.Samples/channel"
%!configure%

%variable%
words = info.tcp.Channels*info.tcp.Samples;
% loop = 1000;
%open tcp connection%

info.tcpipClient = tcpip(ipadress,port,'NetworkRole','Client');
set(info.tcpipClient,'InputBufferSize',words*9); %input buffersize is 3 times the tcp block size %1 word = 3 bytes
set(info.tcpipClient,'Timeout',5);
% TCP 
period4TCP = round(info.tcp.Samples/info.Fc,3);
info.timer.TCP = timer('TimerFcn','TcpIpClientMatlabV1', 'Period',0.055, 'ExecutionMode', 'fixedRate');
end