function draw_Feature_set(handles)
%DRAW_ALPHABET_SET Summary of this function goes here
%   Detailed explanation goes here


global buffer;

prompt = {'Choose feature to plot','# of that feature','Will you save figure as jpg?(Yes or No)'};
dlg_title = 'Set features to use';
num_lines = 1;
def = {'RMS_27_4','1','Yes'};
fanswer = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(fanswer)
    return;
else
    
    if isfield(buffer, 'trial_data') && ~isempty(buffer.trial_data{1})
        set(handles.system_message, 'String', 'Visualizing the Data ... Wait.');
        
        %% Buffer Setting
        
        Data = buffer.trial_data;
        N_words = size(Data, 1);
        N_trials = size(Data, 2);
        
        Num_feature=str2num(fanswer{2,1});
        N_cols = ceil(N_words);
        
        %% Data Retrieve
        max_values=zeros(N_trials,1);
        min_values=zeros(N_trials,1);
        y_max=zeros(N_words,1);
        y_min=zeros(N_words,1);
        data_arrangements_for_plot=cell(N_trials,N_words);
        for j = 1:N_words
            for i=1:N_trials
                
                eval(sprintf('data_arrangements_for_plot{i,j} = Data{j, i }.Feature.%s(Num_feature,:);'...
                    ,fanswer{1,1}))
                titles_arrangements_for_plot{i,j}=Data{j,i}.name;
                max_values(i,1)=max(data_arrangements_for_plot{i,j});
                min_values(i,1)=min(data_arrangements_for_plot{i,j});
            end
            y_max(j,1)=max(max_values);
            y_min(j,1)=min(min_values);
        end
        if (0) % choose max and min of y of each pattern( words)
            y_range=[y_min-200,y_max];
        end
        if (1) % choose max and min of y of each pattern( words)
            y_range=[y_min,y_max];
        end        
        if (0)% choose max and min ofy of all pattern( words)
            y_range=[min(y_min),max(y_max)];
            y_range=repmat(y_range,N_words,1);
        end
        
        
        %% save figure
        %make another figure if the screen is insufficent on a screen
        % setup all axes
        if strcmp('Yes',fanswer{3,1})
            
            buf = 0.10/N_cols; % buffer between axes & between left edge of figure and axes
            awidth = (1-buf*(N_cols+1)-.08/N_cols)/N_cols; % width of all axes
            num_rows=(floor(0.5/awidth)-1);
            num2plot_on_s=ceil(N_trials/num_rows);
            for i=1:num2plot_on_s
                if (num_rows*i>N_trials)
                    fig=subplot_fullsize(N_cols,(N_trials-num_rows*(i-1)),...
                        data_arrangements_for_plot(num_rows*(i-1)+1:N_trials,:),y_range,titles_arrangements_for_plot);
                else
                    fig=subplot_fullsize(N_cols, num_rows,...
                        data_arrangements_for_plot(num_rows*(i-1)+1:num_rows*i,:),y_range,titles_arrangements_for_plot);
                end
                F = getframe(fig);
                CDATA{i} = F.cdata;
                close(fig)
            end
            
            
            %         fname=[fanswer{1,1},'_order_of_feature_',num2str(Num_feature),'.jpg'];
            %         imwrite(cat(1,CDATA{:}),fname)
            %         print( '-dpdf', 'test.pdf' );
            if(1)
                fname=[fanswer{1,1},'_compoent_',num2str(Num_feature),'.jpg'];

                [file, path] = uiputfile('*', 'Save Current Image As');
                imwrite(cat(1,CDATA{:}),fullfile(path,strcat(file,fname)))
            end
            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%A4 용지 출력용 코드
            if(0)
                NprintOnA4=3;
                NumCount2print=ceil(num2plot_on_s/NprintOnA4);
                
                for ii=1:NumCount2print
                    fname=[fanswer{1,1},'_compoent_',num2str(Num_feature),'_',num2str(ii),'.jpg'];
                    if ii*NprintOnA4>num2plot_on_s
                        imwrite(cat(1,CDATA{(ii-1)*NprintOnA4+1:end}),fname);
                    else
                        imwrite(cat(1,CDATA{(ii-1)*NprintOnA4+1:ii*NprintOnA4}),fname);
                    end
                end
            end
            
        end
        %% Visualization
        if ~strcmp('Yes',fanswer{3,1})
            scrollfigdemo(N_cols,N_trials,  data_arrangements_for_plot,y_range,titles_arrangements_for_plot);
        end
        % set(g_handles.alphabet_plot, 'Color', [1, 1, 1]);
        
        [beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);
        sound(beep, Fs);
        
        set(handles.system_message, 'String', 'EMG feature set visualization has been done.')
        
        
        
    else
        [beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);
        sound(beep, Fs);
        
        set(handles.system_message, 'String', 'There is no data to plot.')
    end
end
end

