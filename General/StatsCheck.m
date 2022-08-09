function varargout = StatsCheck(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StatsCheck_OpeningFcn, ...
                   'gui_OutputFcn',  @StatsCheck_OutputFcn, ...
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

% --- Executes just before StatsCheck is made visible.
function StatsCheck_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StatsCheck (see VARARGIN)

% Choose default command line output for StatsCheck
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes StatsCheck wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = StatsCheck_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% Degrees of freedom
df = str2double(get(handles.edit1,'String'));
% t-statistic
t = str2double(get(handles.edit3,'String'));
% Caclulate significance 
p = p_value(t,df);
if p < 0.05
    SigTxt = 'Significant';
else
    SigTxt = 'Not significant';
end
set(handles.text2, 'String', [SigTxt ': t(' num2str(df) ') = ' num2str(t) ', p = ' num2str(p)]);
disp(get(handles.text2, 'String'));


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% Degrees of freedom #1
df1 = str2double(get(handles.edit1,'String'));
% Degrees of freedom #2
df2 = str2double(get(handles.edit2,'String'));
% F-statistic
F = str2double(get(handles.edit3,'String'));
% Caclulate significance 
p = 1 - fcdf(F,df1,df2);
if p < 0.05
    SigTxt = 'Significant';
else
    SigTxt = 'Not significant';
end
set(handles.text2, 'String', [SigTxt ': F(' num2str(df1) ',' num2str(df2) ') = ' num2str(F) ', p = ' num2str(p)]);
disp(get(handles.text2, 'String'));


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% Correlation coefficient
r = str2double(get(handles.edit3,'String'));
% Sample size
n = str2double(get(handles.edit1,'String'));
% Caclulate significance 
t = r2t(r,n);
p = p_value(t,n-2);
if p < 0.05
    SigTxt = 'Significant';
else
    SigTxt = 'Not significant';
end
set(handles.text2, 'String', [SigTxt ': r = ' num2str(r) ', p = ' num2str(p) ', n = ' num2str(n)]);
disp(get(handles.text2, 'String'));


function edit1_Callback(hObject, eventdata, handles)

function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit2_Callback(hObject, eventdata, handles)

function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit3_Callback(hObject, eventdata, handles)

function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
