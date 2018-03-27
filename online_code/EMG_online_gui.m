%--------------------------------------------------------------------------
% developed by Ho-Seung Cha, Ph.D Student,
% CONE Lab, Biomedical Engineering Dept. Hanyang University
% under supervison of Prof. Chang-Hwan Im
% All rights are reserved to the author and the laboratory
% contact: hoseungcha@gmail.com
% 2017.09.20 fEMG 표정인식 온라인 코드 GUI ver
%--------------------------------------------------------------------------
function varargout = EMG_online_gui(varargin)
% EMG_ONLINE_GUI MATLAB code for EMG_online_gui.fig
%      EMG_ONLINE_GUI, by itself, creates a new EMG_ONLINE_GUI or raises the existing
%      singleton*.
%
%      H = EMG_ONLINE_GUI returns the handle to a new EMG_ONLINE_GUI or the handle to
%      the existing singleton*.
%
%      EMG_ONLINE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMG_ONLINE_GUI.M with the given input arguments.
%
%      EMG_ONLINE_GUI('Property','Value',...) creates a new EMG_ONLINE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EMG_online_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EMG_online_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EMG_online_gui

% Last Modified by GUIDE v2.5 21-Sep-2017 16:44:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EMG_online_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @EMG_online_gui_OutputFcn, ...
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


% --- Executes just before EMG_online_gui is made visible.
function EMG_online_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EMG_online_gui (see VARARGIN)
global info;
global initalize_button;
% Choose default command line output for EMG_online_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


info.parentdir=(fileparts(fileparts(pwd))); % resource path
addpath(genpath(fullfile(cd,'functions'))); % 함수 경로 추가
GUI_mode_presentation(handles); % GUI presentation
info.prog_mode=1; % Defualt online mode
initalize_button = 0;
info.use_biosmix = 0; % identifier if we use biosemix for online analysis

% UIWAIT makes EMG_online_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EMG_online_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_insturction_Callback(hObject, eventdata, handles)
% hObject    handle to edit_insturction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_insturction as text
%        str2double(get(hObject,'String')) returns contents of edit_insturction as a double


% --- Executes during object creation, after setting all properties.
function edit_insturction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_insturction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_ize.
function pushbutton_initialize_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_initialize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
initialize(handles);



% --- Executes on button press in pushbutton_start.
function pushbutton_start_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global info;
global initalize_button
% intializing check
if initalize_button == 0
   errordlg('Initialize 버튼을 눌러주세요');
    return;
end
if handles.radiobutton_test.Value
% test session    
    if isempty(handles.edit_model_input.String)
        errordlg('Please input the name of the model');
        return;
    else
        info.model = load(fullfile(cd,'model',...
            [info.handles.edit_model_input.String,'.mat']));
    end
end

% TCPIP 연결
try
    fopen(info.tcpipClient);
     % 실시간 데이터 처리 타이머 실행
        start(info.timer.TCP);   
catch ex
    if ~isempty(strfind(ex.message,'Connection refused'))
        info.use_biosmix = 1;
        disp('Data aquasition is being obatained using Biosemix. Please use 32 bits matlab.')
    end
end
% 실시간 데이터 처리 타이머 실행
info.timer.online_code.UserData = tic;
info.timer.onPaint.UserData = tic;
info.timer.FE_train.UserData = tic;
info.timer.RestInst.UserData = tic;
% 표정 인스트럭션 GUI 시작

start(info.timer.FE_train); 
start(info.timer.RestInst);
start(info.timer.online_code);
start(info.timer.onPaint);




% --- Executes on button press in pushbutton_stop.
function pushbutton_stop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global initalize_button;
global info;
myStop();
clear biosemix;
% if info.use_biosmix == 0
%     fclose(info.tcpipClient);
%     delete(info.tcpipClient);
% end
initalize_button  = 0;
% closePreview(info.cam);
% info = rmfield(info, 'cam');



% --- Executes on button press in pushbutton_open.
function pushbutton_open_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global info;
global mat
% load bdf file DB 
[FileName,PathName,~] = uigetfile(['.','\*.bdf']);
if FileName==0
    return;
end
info.filepath = [PathName,FileName];
mat = load(info.filepath);
mat.File_Header.RawSignalReserve.mat(1:mat.File_Header.RawSignalReserve.n_data,:);
info.bdf = pop_biosig(info.filepath);

temp_trg = zeros(info.bdf.pnts,1);
for i = 1 : 8
    temp_trg(info.bdf.event(3*(i-1)+2).latency) = 128;
end
info.bdf.trg = temp_trg;
info.prog_mode = 0; % Online mode:1, file mode:0

% --- Executes on button press in pushbutton_open.
function radiobutton_train_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in pushbutton_open.
GUI_mode_presentation(handles)

function radiobutton_test_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUI_mode_presentation(handles)




function edit_model_input_Callback(hObject, eventdata, handles)
% hObject    handle to edit_model_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_model_input as text
%        str2double(get(hObject,'String')) returns contents of edit_model_input as a double


% --- Executes during object creation, after setting all properties.
function edit_model_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_model_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_classification_Callback(hObject, eventdata, handles)
% hObject    handle to edit_classification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_classification as text
%        str2double(get(hObject,'String')) returns contents of edit_classification as a double


% --- Executes during object creation, after setting all properties.
function edit_classification_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_classification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
% close all force
delete(hObject);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(hObject);


% --- Executes on button press in pushbutton_exit.
function pushbutton_exit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all force;
clear all;
