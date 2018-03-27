%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
% 2017.09.20 main timer function 데이터를 실시간으로 받아 처리하는 코드.
%--------------------------------------------------------------------------
function online_code(  )
% tic;
global info;
global pd;
   
try
    %data input
    if info.prog_mode ==0
        if info.curr_pos+info.timer.SF-1 > size(info.bdf.data,2)
            myStop();
            return;
        end
        segment = info.bdf.data(:,info.curr_pos:info.curr_pos+info.timer.SF-1);
        segment = double(segment)';
        trg_segment = info.bdf.trg(info.curr_pos:info.curr_pos+info.timer.SF-1);
        info.curr_pos = info.curr_pos+ info.timer.SF;
    elseif info.prog_mode ==1
        if (info.use_biosmix ==1)
            try
                segment = biosemi_signal_recieve(info.total_ch);
            catch me
                if strfind(me.message,'biosemix')
                    errordlg('Please check you are using matlab 32bit version. and please Stop now');
                end
            end
        elseif (info.use_biosmix ==0)
            if pd.TCP_buffer.datasize<info.timer.SF % TCP 버퍼가 아직 안쌓였으면 return 시킴
                segment = pd.TCP_buffer.getLastN(pd.TCP_buffer.datasize);
            else
                segment = pd.TCP_buffer.getLastN(info.timer.SF);
            end
        end
    end
    
    % raw data 및 표정 인스트럭션 시점 저장
%     if ~exist('segment','var')
%         return;
%     end
    seg_size = size(segment,1);
    disp(seg_size);
    if seg_size == 0
%         myStop;
        return;
    end
    info.rawdata(info.raw_pos:info.raw_pos+seg_size-1,1:info.total_ch) = segment;
    if(info.FE_start_sign)        
        info.rawdata(info.raw_pos:info.raw_pos+seg_size-1,info.total_ch+1) = ones(seg_size,1);
    else
        info.rawdata(info.raw_pos:info.raw_pos+seg_size-1,info.total_ch+1) = zeros(seg_size,1);
    end
    info.raw_pos = info.raw_pos + seg_size;
    
    % channel configuration
    temp_chan = cell(1,6);
    temp_chan{1} = segment(:,1) - segment(:,2); %Right_Temporalis
    temp_chan{2} = segment(:,3) - segment(:,4);%Left_Temporalis
    temp_chan{3} = segment(:,5) - segment(:,6);%Right_Frontalis
    temp_chan{4} = segment(:,7) - segment(:,8);%Left_Corrugator
    temp_chan{5} = segment(:,9) - segment(:,10);%Left_Zygomaticus
    temp_chan{6} = segment(:,11) - segment(:,12);%Right_Zygomaticus
    segments = cell2mat(temp_chan);

    
    % filtering notch, BPF
    if isempty(info.f.nZn)
        [segments,info.f.nZn] = filter(info.f.nB,info.f.nA,...
           segments,[],1);
    else
        [segments,info.f.nZn] = filter(info.f.nB,info.f.nA,segments,info.f.nZn,1);
    end    
    if isempty(info.f.bZn)
        [segments,info.f.bZn] = filter(info.f.bB,info.f.bA,...
            segments,[],1);
    else
        [segments,info.f.bZn] = filter(info.f.bB,info.f.bA,segments,info.f.bZn,1);
    end
    pd.EMG.addArray(segments); % 그림 출력 데이터
    
    Process_EMG(); % EMG 신호 처리 및 분류
catch ex
    myStop;
    keyboard;
end
% toc;
end

function Process_EMG()    
    global pd;
    global info;
    
    if( pd.EMG.datasize<204) % 0.1초 기다림(윈도우 size)
        return;
    end
        
    % feat extracion
%     myStop;
    curr_win =pd.EMG.getLastN(204);
    temp_rms = sqrt(mean(curr_win.^2));
    pd.f.RMS.addArray(temp_rms);
    temp_CC = featCC(curr_win,4);
    pd.f.CC.addArray(temp_CC);
    temp_WL = sum(abs(diff(curr_win,2)));
    pd.f.WL.addArray(temp_WL);
    temp_SampEN = SamplEN(curr_win,2);
    pd.f.SampEN.addArray(temp_SampEN);
    
    if info.handles.radiobutton_train.Value % train code
        if(info.FE_start_sign)
%            myStop;
           pd.featset.addArray([temp_CC,temp_rms,temp_SampEN,temp_WL]);
%            disp(pd.featset.datasize);
           if pd.featset.length == pd.featset.datasize
               myStop;
               temp_FE_order = circshift(info.FE_order4GUI,1,2);
               i_trl = find(info.FE_order==temp_FE_order(1));
               info.FeatSet{i_trl} = pd.featset.data;
               
               pd.featset = circlequeue(60,info.Ch*3+info.Ch*4);%초기화
           end
        end
    end
    
    if info.handles.radiobutton_test.Value % test code
        % feat construction
%         test = [pd.f.CC.getLast,pd.f.RMS.getLast,pd.f.SampEN.getLast];
        test = [temp_CC,temp_rms,temp_SampEN,temp_WL];
        % classify
        pred_lda = predict(info.model.lda,test);
        pd.Predted.addArray(pred_lda);
        % majority voting
        if pd.Predted.datasize == pd.Predted.length
            temp_pd = pd.Predted.getLastN(pd.Predted.length);
            % 표정을 짓는 구간에서 결과 저장
            if(info.FE_start_sign)
               pd.test_result.addArray(pred_lda);
               pd.featset.addArray([temp_CC,temp_rms,temp_SampEN,temp_WL]);
               if pd.test_result.length == pd.test_result.datasize
                   % trl 순서파악
                   temp_FE_order = circshift(info.FE_order4GUI,1);
                   i_trl = find(info.FE_order==temp_FE_order(1));
                   % 결과 저장
                   info.test_result{i_trl} = pd.test_result.data;
                   pd.test_result = circlequeue(60,1);%초기화
                   % Feat 저장
                   info.FeatSet{i_trl} = pd.featset.data;
                   pd.featset = circlequeue(60,info.Ch*3+info.Ch*4);%초기화
                   if isempty(info.test_result{i_trl})
                       myStop;
                       a=1;
                   end
               end
               
            end
            % majority voting
            [~,fp] = max(countmember(1:info.N_FE,temp_pd));
            % presentation of classfied facial expression
            info.handles.edit_classification.String = ...
                sprintf('인식 표정(Classfied FacE: %s',info.FE_name{fp});
%             for i_FE=1:info.N_FE
%                 info.imt_h(i_FE).Visible='off';
%             end
%             info.imt_h(fp).Visible = 'on';
        end
    end

end

function f = featCC(curwin,order)
   cur_xlpc = real(lpc(curwin,order)');
   cur_xlpc = cur_xlpc(2:(order+1),:);
   Nsignals = size(curwin,2);
   cur_CC = zeros(order,Nsignals);
   for i_sig = 1 : Nsignals
      cur_CC(:,i_sig)=a2c(cur_xlpc(:,i_sig),order,order)';
   end
   f = reshape(cur_CC,[1,order*Nsignals]);
end

function c=a2c(a,p,cp)
%Function A2C: Computation of cepstral coeficients from AR coeficients.
%
%Usage: c=a2c(a,p,cp);
%   a   - vector of AR coefficients ( without a[0] = 1 )
%   p   - order of AR  model ( number of coefficients without a[0] )
%   c   - vector of cepstral coefficients (without c[0] )
%   cp  - order of cepstral model ( number of coefficients without c[0] )

%                              Made by PP
%                             CVUT FEL K331
%                           Last change 11-02-99

for n=1:cp
  sum=0;
  if n<p+1
    for k=1:n-1
      sum=sum+(n-k)*c(n-k)*a(k);
    end
    c(n)=-a(n)-sum/n;
  else
    for k=1:p
      sum=sum+(n-k)*c(n-k)*a(k);
    end
    c(n)=-sum/n;
  end
end
end

function f = SamplEN(curwin,dim)
    N_sig = size(curwin,2);
    f = zeros(1,N_sig);
    R = 0.2*std(curwin);
    for i_sig = 1 : N_sig
       f(i_sig) = sampleEntropy(curwin(:,i_sig), dim, R(i_sig),1); %%   SampEn = sampleEntropy(INPUT, M, R, TAU)
    end
end

function yp = majority_vote(xp)
% final decision using majoriy voting
% yp has final prediction X segments(times)
[N_Seg,N_trl,N_label] = size(xp);
yp = zeros(N_label*N_trl,1);
for n_seg = 1 : N_Seg
    maxv = zeros(N_label,N_trl); final_predict = zeros(N_label,N_trl);
    for i = 1 : N_label
        for j = 1 : N_trl
            [maxv(i,j),final_predict(i,j)] = max(countmember(1:8,...
                xp(1:n_seg,j,i)));
        end
    end
    yp(:,n_seg) = final_predict(:);
%     acc(n_seg,N_comp+1) = sum(repmat((1:label)',[N_trl,1])==final_predict)/(label*N_trial-label*n_pair)*100;
end
end