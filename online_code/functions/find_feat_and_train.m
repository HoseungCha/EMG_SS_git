%--------------------------------------------------------------------------
% train LDA when train is finisehd
%----------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
%---------------------------------------------------------------------
function find_feat_and_train()
tic;
global info;
Featset = info.FeatSet;
Featset = Featset(info.FE_order);  % 표정 순서 정리
Featset = cell2mat(Featset);
Featset = mat2cell(Featset,repmat(60,1,8),[24,6,6,6]);
comp = cell(size(Featset));
for i = 1 : numel(Featset)
   comp{i} = zeros(size(Featset{i}));
end
DB = load(fullfile(cd,'online_code','rsc',...
    '17_09_18_172929_Features_extracted.mat'));
DB = rmfield(DB,'params');
FeatNames = fieldnames(DB);
h = waitbar(0, 'Registeration is being progressed...');
l_count =0;

for i_FeatName = 1 : 4
    
eval(sprintf('TEMP_FEAT = DB.%s;',FeatNames{i_FeatName}));
[N_Seg, N_Feat, N_FE, N_trial, N_sub] = size(TEMP_FEAT);
TEMP_FEAT = permute(TEMP_FEAT,[2,1,3,4,5]);%[N_Feat, N_Seg,  N_FE, N_trial,N_sub]
    for i_seg = 1 : N_Seg
        for i_FE = 1 : N_FE
            l_count = l_count +1;
            temp =  Featset{i_FE,i_FeatName}(i_seg,:)';
            temp_y = TEMP_FEAT(:,i_seg,i_FE,:,:);
            temp_y = reshape(temp_y,[N_Feat, N_trial*N_sub]);
            comp{i_FE,i_FeatName}(i_seg,:) = dtw_search_n_transf(temp, temp_y, 1)';
            waitbar(l_count/(4*N_Seg*N_FE))
        end
    end
end  
    close(h);
    F = [cell2mat(Featset);cell2mat(comp)];
    l = repmat(1:N_FE,N_Seg,1);
    l = [l(:);l(:)];
    lda = fitcdiscr(F,l);
    info.train_time = toc;
    info.handles.edit_insturction.String = ...
        sprintf('Registration time:%.2f sec',info.train_time);
    
    info = rmfield(info,'handles');    
    uisave({'lda','info'},fullfile(cd,'online_code','model',datestr(now,'yymmdd_')));
end





