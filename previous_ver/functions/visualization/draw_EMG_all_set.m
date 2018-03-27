function draw_EMG_all_set(handles)
%DRAW_ALPHABET_SET Summary of this function goes here
%   Detailed explanation goes here

% choose specific channel to plot
prompt = {'Choose channel to plot','Will you save figure as jpg?'};
dlg_title = 'Set channel to use';
num_lines = 1;
def = {'1','no'};
fanswer = inputdlg(prompt,dlg_title,num_lines,def);
ch=str2num(fanswer{1,1});



global buffer;

if isfield(buffer, 'trial_data') && ~isempty(buffer.trial_data{1,1}.data_queue)
    set(handles.system_message, 'String', 'Visualizing the Data ... Wait.');
    
    %% Buffer Setting
    
    Data = buffer.trial_data;
    [N_words, N_trials] = size(Data);
    N_cols = ceil(N_words);
    
    %% Data Retrieve
    max_values=zeros(N_trials,1);
    min_values=zeros(N_trials,1);
    y_max=zeros(N_words,1);
    y_min=zeros(N_words,1);
    
    for j = 1:N_words
        for i=1:N_trials
            if isempty(Data{j, i }.data_queue)
                data_arrangements_for_plot{i,j}=NaN;
                titles_arrangements_for_plot{i,j}=NaN;
            else
                data_arrangements_for_plot{i,j} = Data{j, i }.data_queue(:,ch);
                titles_arrangements_for_plot{i,j}=Data{j,i}.name;
            end
            
            max_values(i,1)=max(max(data_arrangements_for_plot{i,j}));
            min_values(i,1)=min(min(data_arrangements_for_plot{i,j}));
        end
        y_max(j,1)=max(max_values);
        y_min(j,1)=min(min_values);
    end
    if (0) % choose max and min of y of each pattern( words)
        y_range=[y_min-200,y_max];
    end
    if (0)% choose max and min ofy of all pattern( words)
        y_range=[min(y_min),max(y_max)];
        y_range=repmat(y_range,N_words,1);
    end
    if (1) % choose max and min of y of each pattern( words)
        y_range=[y_min,y_max];
    end
    
    %% save figure
    %make another figure if the screen is insufficent on a screen
    % setup all axes
    if strcmpi('Yes',fanswer{2,1})
        
        buf = 0.10/N_cols; % buffer between axes & between left edge of figure and axes
        awidth = (1-buf*(N_cols+1)-.08/N_cols)/N_cols; % width of all axes
        num_rows=(floor(0.45/awidth));
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
        
        fname=['channel_',num2str(ch),'.jpg'];
        imwrite(cat(1,CDATA{:}),fname)
        %         print( '-dpdf', 'test.pdf' );
        
    end
    %% Visualization
    
    if ~(strcmpi('Yes',fanswer{2,1}))
        [~,~,ax,axis_pos]=scrollfigdemo(N_words,N_trials, data_arrangements_for_plot,y_range,titles_arrangements_for_plot);
    end
    %     ax =reshape(ax,[N_trials,N_words]);
    %     axis_pos=reshape(axis_pos,[N_trials,N_words]);
    % filename='EMGdata.PNG';
    %  filename=get(pnl,'name')
    % printPanel(pnl,filename)
    % set(g_handles.alphabet_plot, 'Color', [1, 1, 1]);
    
    [beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);
    sound(beep, Fs);
    
    set(handles.system_message, 'String', 'EMG set visualization has been done.')
    
else
%     [beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);
%     sound(beep, Fs);
    
    set(handles.system_message, 'String', 'There is no data to plot.')
end

end
