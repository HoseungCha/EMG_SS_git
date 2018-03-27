function varargout = online_gui(varargin)
% ONLINE_GUI MATLAB code for online_gui.fig
%      ONLINE_GUI, by itself, creates a new ONLINE_GUI or raises the existing
%      singleton*.
%
%      H = ONLINE_GUI returns the handle to a new ONLINE_GUI or the handle to
%      the existing singleton*.
%
%      ONLINE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ONLINE_GUI.M with the given input arguments.
%
%      ONLINE_GUI('Property','Value',...) creates a new ONLINE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before online_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to online_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help online_gui

% Last Modified by GUIDE v2.5 30-May-2016 16:41:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @online_gui_OpeningFcn, ...
    'gui_OutputFcn',  @online_gui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


% End initialization code - DO NOT EDIT

% --- Executes just before online_gui is made visible.
function online_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to online_gui (see VARARGIN)

% Choose default command line output for online_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using online_gui.
if strcmp(get(hObject,'Visible'),'off')
    axes(handles.current_signal1);
    plot([0 10], [0 0], 'color', 'black');    
    set(handles.current_signal1,'XTick',[]);
    set(handles.current_signal1,'YTick',[]);
    
    axes(handles.trg_signal);
    plot([0 10], [0 0], 'color', 'black');    
    set(handles.trg_signal,'XTick',[]);
    set(handles.trg_signal,'YTick',[]);

end

% UIWAIT makes online_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = online_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in initialize_button.
function initialize_button_Callback(hObject, eventdata, handles)
% hObject    handle to initialize_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Initialize 버튼
global params;
global buffer;
global File_Header;
global g_handles;

params = [];
buffer = [];
File_Header = [];

g_handles = handles;

params.DummyMode = 0; % 0 : biosemi, 1 : Dummy
[beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);

%% Dump if exist
try
    dummy = biosemix([1 0]); %실행될때마다 버퍼에서 데이터 가져오기, 일단 한번 실행하는 것.
catch me
    if strfind(me.message,'BIOSEMI device')
        params.DummyMode = 1; % 0 : biosemi, 1 : Dummy
        
        sound(beep, Fs); % sound beep
        set(handles.system_message, 'String', ...
            strrep([me.message 'The program will be run in dummy mode.'], sprintf('\n'),'. '));
        set(handles.console, 'String', 'Dummy Mode');
        clear biosemix;
    else
        rethrow(me);
    end
end

%% Basic Parameter Initialization

% Experiment Parameter Settings
set_experiment_parameters();

if (params.DummyMode == 0)
    sound(beep, Fs); % sound beep
    set(handles.system_message, 'String', ...
        'BIOSEMI has been detected. Initialization has been done successfully.');
    set(handles.console, 'String', 'Biosemi Mode');
elseif(params.DummyMode == 1)
    if (params.use_real_dummy == 1)
        % Get dummy sample data 
        load([pwd, '\resources\sample_signal\online_data_20160902.mat']);
        buffer.dummy_signal = data;
        clear data data_header;
    end
end

%% Preparing for signal acquisition

% downsampling setting for online data acquisition
params.DecimateFactor = 2048/params.SamplingFrequency2Use;
% decimation factor (sampling rate) ,1 = 2048, 2 = 1024, ...., 8 = 256 etc.
if(params.DecimateFactor==1)
    params.DownSample = 0;
    % 1 = downsample, 0 = none, Downsampleing according to Biosemi_Initialize
elseif(params.DecimateFactor>1)
    params.DownSample = 1;
end

% buffer setting for online data acquisition
params.BufferLength_Biosemi = params.SamplingFrequency2Use * params.DelayTime; %timer에서 한번받아오기 위한 버퍼인듯
params.QueueLength = params.SamplingFrequency2Use * params.BufferTime; %% 분석에 사용되는 데이터 버퍼
% params.ResultLength = params.SamplingFrequency2Use* params.ResultShowTime;
% buffers
if ~isempty(timerfind)
    stop(timerfind);
    delete(timerfind);
end
initial_buffer_initiation()

%% Initialize Biosemi

File_Header = file_initialize_Biosemi();

%% GUI Control
set(handles.start_button, 'Enable', 'on');
set(handles.stop_button, 'Enable', 'on');

%% Initialize the Screen
% screen_init_psy();
% --- Executes on button press in start_button.
function start_button_Callback(hObject, eventdata, handles)
% hObject    handle to start_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pause(0.001);
global program_name;
global g_handles;
global timer_id_data;
global params;


g_handles = handles;
[beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);

% Timer 함수, 함수 data_acquisition.m을 delay time 간격으로 실행
timer_id_data= timer('TimerFcn','data_acquisition', ...
    'StartDelay', 0, 'Period', params.DelayTime, 'ExecutionMode', 'FixedRate');

choice = questdlg('Do you want to start data acquisition?', program_name, ...
    'Yes', 'No', 'Yes');

switch choice
    case 'Yes'
        start(timer_id_data); % timer 실행
        %         sound(beep, Fs); % sound beep        
        % GUI Control
        set(handles.start_button, 'Enable', 'off');
        set(handles.stop_button, 'Enable', 'on');
        set(handles.initialize_button, 'Enable', 'off');
    case 'No'
        return;
end


% --- Executes on button press in stop_button.
function stop_button_Callback(~, ~, ~)
% hObject    handle to stop_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global program_name;
pause(0.001);

choice = questdlg('Do you want to stop data acquisition?', program_name, ...
    'Yes', 'No', 'No');

switch choice
    case 'Yes'        
        trial_stop(); % timer 함수 Stop        
    case 'No'
        return;
end


% --------------------------------------------------------------------
function FileMenu_Callback(~, ~, ~)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function SaveMenuItem_Callback(~, ~, handles)
% hObject    handle to SaveMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global File_Header;


verbose_time = strjoin(strsplit((mat2str(fix(clock)))), '_');
verbose_time = strrep(verbose_time, '[', '');
verbose_time = strrep(verbose_time, ']', '');

[file, path] = uiputfile('*.mat', 'Save Current Experiment Results As', ...
    ['Online_EMG_', verbose_time]);
save_path = fullfile(path, file);

if ~isequal(file, 0)
    try
        File_Header = file_initialize_Biosemi();
        save(save_path, 'File_Header');
        set(handles.system_message, 'String', 'Data has been saved successfully.');
    catch me
        set(handles.system_message, 'String', me.message);
        
        %         errordlg(me.message, program_name);
    end
end

% --------------------------------------------------------------------
function EmergencySaveMenuItem_Callback(~, ~, handles)
% hObject    handle to EmergencySaveMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global File_Header;
global params;

verbose_time = strjoin(strsplit((mat2str(fix(clock))), ' '), '_');
verbose_time = strrep(verbose_time, '[', '');
verbose_time = strrep(verbose_time, ']', '');

save_path = [params.emergency_save_path, 'Online_EMG_', verbose_time, '.mat'];

try
    File_Header = file_initialize_Biosemi();
    save(save_path, 'File_Header');
    set(handles.system_message, 'String', 'Data has been saved successfully.');
catch me
    set(handles.system_message, 'String', me.message);
    
    %         errordlg(me.message, program_name);
end

% --------------------------------------------------------------------
function OpenParameterMenuItem_Callback(~, ~, handles)
% hObject    handle to OpenParameterMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uigetfile('*.mat', 'Open from a file');
save_path = fullfile(path, file);

if ~isequal(file, 0)
    try
        loaded_struct = load(save_path);
        file_retrieve_parameters(loaded_struct.File_Header,file);
        set(handles.system_message, 'String', ['Parameter Setting has been loaded successfully from ' file ' file.']);
        clear loaded_struct;
        
        % GUI Control
        set(handles.initialize_button, 'Enable', 'on');
        set(handles.start_button, 'Enable', 'on');
        set(handles.stop_button, 'Enable', 'off');
        
    catch me
        set(handles.system_message, 'String', me.message);
        
        %         errordlg(me.message, program_name);
    end
end

% --------------------------------------------------------------------
function CloseMenuItem_Callback(~, ~, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global program_name;

selection = questdlg(['Do you want to exit?'],...
    program_name,...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)

% Control Trial%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function TrialMenu_Callback(~, ~, ~)
% hObject    handle to TrialMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function NewSetMenuItem_Callback(~, ~, handles)
% hObject    handle to NewSetMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global program_name;
global buffer;

selection = questdlg(['Do you want to record a new set?'],...
    program_name,'Yes','No','No');
if strcmp(selection,'Yes')
    try
        new_sequence_initialize()
        set(handles.console, 'String', ['Trial # : ' num2str(buffer.n_trial),char(10), ...
            'Set # : ' num2str(buffer.n_sequence),char(10),...
            'Currently Saved Sets # :' num2str(size(buffer.trial_data ,2))]);
        set(handles.system_message, 'String', ...
            'Prepared for new set recording.');
        [beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);
        sound(beep, Fs);
    catch me
        set(handles.system_message, 'String', me.message);
    end
else
    return
end

% --------------------------------------------------------------------
function InitializeSequenceMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to InitializeSequenceMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global program_name
global buffer
selection = questdlg(['Do you want to get rid of current Set?' ...
    ], program_name,...
    'Yes','No','No');
if strcmp(selection,'Yes')
    %         new_sequence_initialize()
    trial_initialize(1);
    set(handles.system_message, 'String', ...
        'Prepared for new set recording.');
    set(handles.console, 'String', ['Trial # : ' num2str(buffer.n_trial),char(10), ...
        'Set # : ' num2str(buffer.n_sequence),char(10),...
        'Currently Saved Sets # :' num2str(size(buffer.trial_data ,2))]);
    
    [beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);
    sound(beep, Fs);
end


% --------------------------------------------------------------------
function InitializeSessionMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to InitializeSessionMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global program_name
global buffer
selection = questdlg(['Do you want to get rid of current session?, you might lose current sessions' ...
    ], program_name,...
    'Yes','No','No');
if strcmp(selection,'Yes')
    trial_initialize();
    set(handles.system_message, 'String', ...
        'Prepared for new session recording.');
    set(handles.console, 'String', ['Trial # : ' num2str(buffer.n_trial),char(10), ...
        'Set # : ' num2str(buffer.n_sequence),char(10),...
        'Currently Saved Sets # :' num2str(size(buffer.trial_data ,2))]);
    
    [beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);
    sound(beep, Fs);
end

% --------------------------------------------------------------------
function PrevMenuItem_Callback(~, ~, handles)
% hObject    handle to PrevMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global buffer;

message = trial_go_prev();
set(handles.system_message, 'String', message);
set(handles.console, 'String', ['Trial # : ' num2str(buffer.n_trial)]);

[beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);
sound(beep, Fs);

% --------------------------------------------------------------------
function TrialMoveMenuItem_Callback(~, ~, handles)
% hObject    handle to TrialMoveMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global buffer;

input_num = -1;
%     possible = [double('a'):double('z'), double('S'), double('B'), double('E')];

%     while (0 == sum(possible==input_num))

x = inputdlg('Enter the number of trial :',...
    'Move to specific trial', [1 50]);
if ~isempty(x)
    input_num = x{:};
else
    input_num = -1;
    %         break;
end
%     end

if input_num ~= -1
    %         if input_num >= double('a') && input_num <= double('z')
    %             input_num = input_num - double('a')+1;
    %         elseif input_num == double('S')
    %             input_num = 27;
    %         elseif input_num == double('B')
    %             input_num = 28;
    %         elseif input_num == double('E')
    %             input_num = 29;
    %         end
    message = trial_go_prev(input_num);
    set(handles.system_message, 'String', message);
    set(handles.console, 'String', ['Trial # : ' num2str(buffer.n_trial)]);
    
    [beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);
    sound(beep, Fs);
end




% --------------------------------------------------------------------
function See_current_saved_features_Callback(hObject, eventdata, handles)
% hObject    handle to See_current_saved_features (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global buffer
global params
% disp(fieldnames(buffer.trial_data{1, 1}.Feature));
buffer.trial_data{1, 1}.Feature

if ~isfield(buffer,'n_trial')
    buffer.n_trial=1;
end
disp(size(buffer.trial_data));
set(handles.console, 'String', [...
    'FileName : ', params.filename,char(10),...
    'Trial # : ' num2str(buffer.n_trial),char(10), ...
    'Set # : ' num2str(buffer.n_sequence),char(10),...
    'Currently Saved Sets # :' num2str(size(buffer.trial_data ,2))]);



% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});


function console_Callback(hObject, eventdata, handles)
% hObject    handle to console (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of console as text
%        str2double(get(hObject,'String')) returns contents of console as a double


% --- Executes during object creation, after setting all properties.
function console_CreateFcn(hObject, eventdata, handles)
% hObject    handle to console (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
clear biosemix;

global program_name;
program_name = 'Online EMG Speech Recognition GUI';

global params;
global buffer;
global File_Header;

% Add function path
addpath(genpath([pwd, '\functions']));

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function system_message_Callback(hObject, eventdata, handles)
% hObject    handle to system_message (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of system_message as text
%        str2double(get(hObject,'String')) returns contents of system_message as a double


% --- Executes during object creation, after setting all properties.
function system_message_CreateFcn(hObject, eventdata, handles)
% hObject    handle to system_message (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Lip_shape_presentation_Callback(hObject, eventdata, handles)
% hObject    handle to Lip_shape_presentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Lip_shape_presentation as text
%        str2double(get(hObject,'String')) returns contents of Lip_shape_presentation as a double


% --- Executes during object creation, after setting all properties.
function Lip_shape_presentation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Lip_shape_presentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Text2Speech_next_Callback(hObject, eventdata, handles)
% hObject    handle to Text2Speech_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Text2Speech_next as text
%        str2double(get(hObject,'String')) returns contents of Text2Speech_next as a double


% --- Executes during object creation, after setting all properties.
function Text2Speech_next_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Text2Speech_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Show_Classification_Results_Callback(hObject, eventdata, handles)
% hObject    handle to Show_Classification_Results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

show_online_results;
    



% --------------------------------------------------------------------
function EMG_Feature_Extraction_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_Feature_Extraction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% try
    EMG_feature_extraction_main();
    set(handles.system_message, 'String', 'the feature data has been successfully extracted')
    
% catch me
%     set(handles.system_message, 'String', me.message);
% end




% --------------------------------------------------------------------
function Open_External_Data_Callback(hObject, eventdata, handles)
% hObject    handle to Open_External_Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 set_experiment_parameters();
initial_buffer_initiation_for_externaldataset();
%  initial_buffer_initiation();
 [file, path] = uigetfile('*.mat', 'Open from a file');
save_path = fullfile(path, file);
global buffer
 load(save_path)
 if isfield(buffer,'trial_data')
     buffer=rmfield(buffer,'trial_data');
 end
 buffer.trial_data=trial_data;
 


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in togglebutton4testmode.
function togglebutton4testmode_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton4testmode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton4testmode


% --- Executes on button press in radiobutton4train.
function radiobutton4train_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4train (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4train



% --------------------------------------------------------------------
function Cross_Validation_using_SVM_Callback(hObject, eventdata, handles)
% hObject    handle to Cross_Validation_using_SVM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CV_and_Get_Classfier_from_offline_test_data;




% --------------------------------------------------------------------
function Train__Callback(hObject, eventdata, handles)
% hObject    handle to Train_ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Cross_Validation_for_searching_optimal_channels_Callback(hObject, eventdata, handles)
% hObject    handle to Cross_Validation_for_searching_optimal_channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
validation_of_rawdata_from_online;


% --- Executes on button press in Subejct_button.
function Subejct_button_Callback(hObject, eventdata, handles)
% hObject    handle to Subejct_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%  Subject 정보 설정 
global params;
prompt={'Subject''s Name (Initial of names)',...
    'Date of Birth (1999XXXX)',...
    'Sex (male or female)',...
    'Data_Categorization (raw_data, offline_data, online_data)',...
    'Note'};
name='Please fill in an information form ';
numlines=1;
defaultanswer={'',...
    '',...
    '',...
    '',...
    'If there is no to report, do not fill in here'};
answer=inputdlg(prompt,name,numlines,defaultanswer);

% subject info
params.subject_name = answer{1};
params.subject_dataOfbirth= answer{2};
params.subject_sex= answer{3};
params.data_catgorization=answer{4};
params.note=answer{5};
set(handles.Subejct_button, 'Enable', 'off');
