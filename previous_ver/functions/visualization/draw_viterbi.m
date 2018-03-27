function draw_viterbi()
% choose specific features in time-domain
prompt = {'Input number of folds ((K-fold)'};
dlg_title = 'Set K-fold to use';
num_lines = 1;
def = {'1'};
fanswer = inputdlg(prompt,dlg_title,num_lines,def);
k=str2num(fanswer{1,1});

[file, path] = uigetfile('*.mat', 'Open from a file');
load_path = fullfile(path, file);
load(load_path);

for i_t=1:5
    h=figure(i_t);
    set(h,'Name',['단어 ',num2str(i_t),'분류','Q: ',num2str(Q),' ,M: ',num2str(M)]);

    for i=1:10 
        classfied_idx=Classification_results(i_t, k).index_of_Classified_word(i,1);
        for j=1:size(Classification_results(i_t, k).viterbi_pat{i, 1},1); 
            hs=subplot(10,5,(i-1)*5+j);
            stairs(Classification_results(i_t, k).viterbi_pat{i, 1}{j, 1} ); 
            if (j==classfied_idx)
                set(get(gca,'children'),'Color','r');
            end
            ylim([0 Q+1]);
            tname=sprintf('Log Likelihood value: %d',...
            Classification_results(i_t, k).loglik_obtained_by_each_HMM{1, 1}(j,1));
            title(tname)
        end 
    end
end
end

