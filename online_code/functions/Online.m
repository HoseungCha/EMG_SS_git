%----------------------------------------------------------------------
% by Won-Du Chang, ph.D,
% Research Professor @  Department of Biomedical Engineering, Hanyang University
% contact: 12cross@gmail.com
%---------------------------------------------------------------------
function Process_mem(  )
%PROCESS 이 함수의 요약 설명 위치
%   timer에 의해서 주기적으로 동작한다
%   데이터를 하나 (세그먼트 단위) 가져와서 처리한다.


%global data_all;
%global pos;
global info;
%global option;
global dataqueue;
% global pd;
%global EM_online;
global raw_signal_reserve;
global trg;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 데이터 읽어오는 코드 - 시작

%add to original data
try
    seg_from_bio = biosemix([info.nTotalChannel, 0]);
catch me
    if strfind(me.message,'BIOSEMI device')
        
        fprintf(strrep([me.message 'Recalling the BIOSEMI device again.'], sprintf('\n'),'. '));
        
        clear biosemix;
        seg_from_bio = biosemix([params.numEEG 0]);
    else
        rethrow(me);
    end
end

segment = 10^6*double(single(seg_from_bio(2:end,:)') * 0.262 / 2^31);
trg_sig = seg_from_bio(1,:);
segLength_dynamic = size(segment,1);


dataqueue.addArray(segment);
trg.addArray(trg_sig);

if dataqueue.datasize<length(info.notchfilter.b)+length(info.notchfilter.a)
    return;
end

% notch filtering 적용 (60Hz)
if isempty(info.notchfilter.zf)
    tmp_d = dataqueue.getLastN(dataqueue.datasize);
    [notch_segment,info.notchfilter.zf]=filter(info.notchfilter.b,info.notchfilter.a,tmp_d,[],1);
else
    [notch_segment,info.notchfilter.zf]=filter(info.notchfilter.b,info.notchfilter.a,segment,info.notchfilter.zf,1);
end


% Raw Signal Reserve (데이터 백업용)
raw_signal_reserve.mat(raw_signal_reserve.n_data+1:raw_signal_reserve.n_data+segLength_dynamic, :) = [segment,trg_sig];
raw_signal_reserve.notch_mat(raw_signal_reserve.n_data+1:raw_signal_reserve.n_data+segLength_dynamic, :) = [notch_segment,trg_sig];
raw_signal_reserve.n_data = raw_signal_reserve.n_data + segLength_dynamic;

%resampling
segment_resmapled = notch_segment(option.resamplingRate4EOG:option.resamplingRate4EOG:info.ExpectedSegmentLength,:);
veog = segment_resmapled(:,info.ch_u) - segment_resmapled(:,info.ch_d);
heog = segment_resmapled(:,info.ch_r) - segment_resmapled(:,info.ch_l);
    
    
% 데이터 읽어오는 코드 - 끝
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Process_EOG (heog,veog);

end



function Process_EOG(heog,veog)
global pd;
global info;
global EM_online;
global tstack_triple;
persistent time_cur

% time setting for triple Blink
t = datevec(now);
temp_time=time_cur - t(6);
if ~isempty(temp_time)
    tstack_triple=tstack_triple+ ((-1)*temp_time); % 2번째 trial 시간을 계속 쌓음
end
time_cur = t(6);
if tstack_triple<0
    tstack_triple=0;
end
disp(tstack_triple);

pd.EOG.addArray([heog,veog]);
pd.EOG_ebRemoved.addArray([heog,veog]);
%     pd.EOG_2checkSaccade.addArray([heog,veog]);
%     pd.EOG_saccade.addArray([heog,veog]);



%Eyeblink Detection
len_veog = size(veog,1);
len_process_data = info.Fc4EOG; %최근 1초 데이터를 가져온다.
len_margin_4interpolation = 10; %이 길이만큼 eyeblink 가 존재하지 않는 경우, 이전의 eyeblink 가 끝났다고 가정함

for i=1:len_veog
    pd.queuelength_eb_check.addArray(0);
    EM_online.add(veog(i));
    if size(EM_online.cur_detected_range,1)>0  %새로 검출된 경우
        %        myStop();
        pd.EOG_ebRemoved.set(EM_online.cur_detected_range(1), EM_online.cur_detected_range(2), nan, 2);
        %pd.EOG_ebRemoved.set(EM_online.cur_detected_range(1), EM_online.cur_detected_range(2), nan);
    end
end

%Interpolation of Eyeblink Regions
len_dataQueue = pd.EOG_ebRemoved.datasize;
if len_dataQueue<len_process_data  %interpolation 등에 필요한 데이터가 충분하지 않은 경우, 더 이상 진행하지 않는다.
    return;
end
tmp_d = pd.EOG_ebRemoved.getLastN(len_process_data);
bNan = isnan(tmp_d(:,2));
%eyeblink 구간이 존재하며, 해당구간이 종료된 경우
if  sum(bNan)>0 && sum(bNan(len_process_data-len_margin_4interpolation+1:len_process_data))==0
    tmp_d(:,2) = InterpolateNans(tmp_d(:,2),1);
    pd.EOG_ebRemoved.set(len_dataQueue-len_process_data+1,len_dataQueue,tmp_d(:,2),2);
    
    %Tripple blink check
    %         myStop;
    pd.queuelength_eb_check.addArray(1);
    
    nEB_inAShortTime = sum(pd.queuelength_eb_check.data);
    %         disp(nEB_inAShortTime);
    %         disp(info.EMG.time_stack4tripple);
    
    if nEB_inAShortTime > 2 && tstack_triple>3
        %         triple blink 발생시 3초동안은 발생안하도록 설정
        %         if randi(20)==1 && info.EMG.time_stack4tripple>3
        myStop;
        tstack_triple=0;
        
        bTripleBlink = 1;
        fprintf('Tripple Blink\n');
    end
    
end
end

