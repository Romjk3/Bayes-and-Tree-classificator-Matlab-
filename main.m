function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 07-Jul-2017 16:33:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
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


% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

% Choose default command line output for main
handles.output = hObject;
handles.parameter = 'normal';
handles.classificator = 'bayes';
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in opentrainbutton.
function opentrainbutton_Callback(hObject, eventdata, handles)
% hObject    handle to opentrainbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName, PathName] = uigetfile('*.dat', 'MultiSelect', 'on');
DELIMITER = ',';
    
if iscell(FileName)
    for k = 1:length(FileName)
        if isfield(handles, 'numberFiles')
            numberdatafiles = handles.numberFiles + 1;
        else
            numberdatafiles = 1;
        end;
        FullName = [PathName FileName{k}];
        
        rawData = importdata(FullName, DELIMITER);
        
        if iscell(rawData)
            t = 1;
            while ~strcmp(rawData{t},'@data')
                t = t + 1;
            end;
        
            rawData = rawData(t+1:end,:);
            data(:) = strsplit(rawData{1},', ');
            for i = 2:size(rawData,1)
                data(i,:) = strsplit(rawData{i},', ');
            end;
        
            for i = 1:size(rawData,1)
                for j = 1:size(data,2)-1
                    handles.inputs{numberdatafiles}(i,j) = str2double(data{i,j});
                end;
            end;
        
            handles.outputs{numberdatafiles} = data(:,end);
            
            clear data;
            clear rawData;
        else
            handles.inputs{numberdatafiles}(:,:) = rawData.data(:,1:end-1);
            handles.outputs{numberdatafiles}(:) = rawData.data(:,end);
        end;
        handles.numberFiles = numberdatafiles;
        lst = get(handles.trainlistbox, 'String');
        lst{end + 1} = FileName{k};
        set(handles.trainlistbox,'String',lst)
        set(handles.trainlistbox,'Value', handles.numberFiles)
    end;
else
    if FileName~=0
        if isfield(handles, 'numberFiles')
            numberdata = handles.numberFiles + 1;
        else
            numberdata = 1;
        end;
        
        FullName = [PathName FileName];

        rawData = importdata(FullName, DELIMITER);
        
        if iscell(rawData)
            t = 1;
            while ~strcmp(rawData{t},'@data')
                t = t + 1;
            end;
        
            rawData = rawData(t+1:end,:);
            data(:) = strsplit(rawData{1},', ');
            for i = 2:size(rawData,1)
                data(i,:) = strsplit(rawData{i},', ');
            end;
        
            for i = 1:size(rawData,1)
                for j = 1:size(data,2)-1
                    handles.inputs{numberdata}(i,j) = str2double(data{i,j});
                end;
            end;
        
            handles.outputs{numberdata} = data(:,end);
            clear data;
            clear rawData;
        else
            handles.outputs{numberdata}(:) = rawData.data(:,end);
            
            handles.inputs{numberdata}(:,:) = rawData.data(:,1:end-1);
        end;
        
        handles.numberFiles = numberdata;
        
        lst = get(handles.trainlistbox, 'String');
        lst{end + 1} = FileName;
        set(handles.trainlistbox,'String',lst)
        set(handles.trainlistbox,'Value', handles.numberFiles)
    end;
end;
set(handles.modeltext,'String','');
set(handles.percenttext,'String','');

guidata(gcbo, handles);

% --- Executes on button press in trainbutton.
function trainbutton_Callback(hObject, eventdata, handles)
% hObject    handle to trainbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.modeltext,'String','');
try
if isequal(handles.classificator, 'tree')
    if isfield(handles, 'afc')
        for i=1:handles.numberFiles
            handles.Model{i} = fitctree(handles.inputs{i},handles.outputs{1,i}, 'AlgoritmForCategorical', handles.afc);
            Test_train{i} = num2cell(handles.Model{i}.predict(handles.inputs{i}(:,:)));
            get(handles.treeviewbutton,'Enable','on');
        end;
    else
        for i=1:handles.numberFiles
            handles.Model{i} = fitctree(handles.inputs{i},handles.outputs{1,i});
            Test_train{i} = num2cell(handles.Model{i}.predict(handles.inputs{i}(:,:)));
            set(handles.treeviewbutton,'Enable','on');
        end;
    end;
end;
if isequal(handles.classificator, 'bayes')
    for i=1:handles.numberFiles
        handles.Model{i} = fitcnb(handles.inputs{i},handles.outputs{1,i}, 'DistributionNames', handles.parameter);
        Test_train{i} = num2cell(handles.Model{i}.predict(handles.inputs{i}(:,:)));
    end;
end;


fullpercent_train = 0;

for k = 1:handles.numberFiles
    correct_train{k} = 0;

    if isnumeric(Test_train{k}{1,1})
        for i = 1:size(handles.outputs{k},2)
            if Test_train{k}{i,1} == handles.outputs{k}(1,i)
                correct_train{k} = correct_train{k} + 1;
            end;
        end;
        percent_train{k} = correct_train{k}/size(handles.outputs{k},2);
        str = get(handles.modeltext,'String');
        set(handles.modeltext,'String', [str ' ' num2str(percent_train{k})]);
    else
        for i = 1:size(handles.outputs{k},1)
            if strcmp(Test_train{k}{i,1}, handles.outputs{k}{i})
                correct_train{k} = correct_train{k} + 1;
            end;
        end;
        percent_train{k} = correct_train{k}/size(handles.outputs{k},1);
        str = get(handles.modeltext,'String');
        set(handles.modeltext,'String', [str ' ' num2str(percent_train{k})]);
    end;    
        fullpercent_train = fullpercent_train + percent_train{k};
end;
fullpercent_train = fullpercent_train/handles.numberFiles;

str = get(handles.modeltext,'String');
set(handles.modeltext,'String',[str int2str(handles.numberFiles) ' Model done! Train data: ' num2str(fullpercent_train)]);
guidata(gcbo, handles);
catch
    h = errordlg('Try another parameter for bayes','Error','modal');
    set(handles.modeltext,'String','');
end;

% --- Executes on button press in testbutton.
function testbutton_Callback(hObject, eventdata, handles)
% hObject    handle to testbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.percenttext,'String','');
if isequal(handles.classificator, 'tree')
    for i=1:handles.numberFiles_test
        Test{i} = num2cell(handles.Model{i}.predict(handles.inputs_test{i}(:,:)));
    end;
end;
if isequal(handles.classificator, 'bayes')
    for i=1:handles.numberFiles_test
        Test{i} = num2cell(handles.Model{i}.predict(handles.inputs_test{i}(:,:)));
    end;
end;

fullpercent = 0;
if handles.numberFiles == handles.numberFiles_test
    for k = 1:handles.numberFiles_test
        correct{k} = 0;

        if isnumeric(Test{k}{1,1})
            for i = 1:size(handles.outputs_test{k},2)
                if Test{k}{i,1} == handles.outputs_test{k}(1,i)
                    correct{k} = correct{k} + 1;
                end;
            end;
            percent{k} = correct{k}/size(handles.outputs_test{k},2);
            str = get(handles.percenttext,'String');
            set(handles.percenttext,'String', [str ' ' num2str(percent{k})]);
        else
            for i = 1:size(handles.outputs_test{k},1)
                if strcmp(Test{k}{i,1}, handles.outputs_test{k}{i})
                    correct{k} = correct{k} + 1;
                end;
            end;
            percent{k} = correct{k}/size(handles.outputs_test{k},1);
            str = get(handles.percenttext,'String');
            set(handles.percenttext,'String', [str ' ' num2str(percent{k})]);
        end;
        
        fullpercent = fullpercent + percent{k};
    end;
end;
fullpercent = fullpercent/handles.numberFiles_test;
str_1 = get(handles.percenttext,'String');
set(handles.percenttext,'String',[str_1 ' Full: ' num2str(fullpercent)]);



% --- Executes on selection change in trainlistbox.
function trainlistbox_Callback(hObject, eventdata, handles)
% hObject    handle to trainlistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns trainlistbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from trainlistbox


% --- Executes during object creation, after setting all properties.
function trainlistbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trainlistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in testlistbox.
function testlistbox_Callback(hObject, eventdata, handles)
% hObject    handle to testlistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns testlistbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from testlistbox


% --- Executes during object creation, after setting all properties.
function testlistbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to testlistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in uptrainbutton.
function uptrainbutton_Callback(hObject, eventdata, handles)
% hObject    handle to uptrainbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lst = get(handles.trainlistbox, 'String');
value = get(handles.trainlistbox, 'Value');
if value > 1
    buf = lst{value};
    lst{value} = lst{value-1};
    lst{value-1} = buf;
    set(handles.trainlistbox,'String',lst)
    set(handles.trainlistbox, 'Value', value-1)
    buf_train_inputs = handles.inputs{value};
    handles.inputs{value} = handles.inputs{value-1};
    handles.inputs{value-1} = buf_train_inputs;
    buf_train_outputs = handles.outputs{value};
    handles.outputs{value} = handles.outputs{value-1};
    handles.outputs{value-1} = buf_train_outputs;
end;
guidata(gcbo, handles);

% --- Executes on button press in downtrainbutton.
function downtrainbutton_Callback(hObject, eventdata, handles)
% hObject    handle to downtrainbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lst = get(handles.trainlistbox, 'String');
value = get(handles.trainlistbox, 'Value');
if value < size(lst,1)
    buf = lst{value};
    lst{value} = lst{value+1};
    lst{value+1} = buf;
    set(handles.trainlistbox,'String',lst);
    set(handles.trainlistbox, 'Value', value+1);
    buf_train_inputs = handles.inputs{value};
    handles.inputs{value} = handles.inputs{value+1};
    handles.inputs{value+1} = buf_train_inputs;
    buf_train_outputs = handles.outputs{value};
    handles.outputs{value} = handles.outputs{value+1};
    handles.outputs{value+1} = buf_train_outputs;
end;
guidata(gcbo, handles);


% --- Executes on button press in uptestbutton.
function uptestbutton_Callback(hObject, eventdata, handles)
% hObject    handle to uptestbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lst = get(handles.testlistbox, 'String');
value = get(handles.testlistbox, 'Value');
if value > 1
    buf = lst{value};
    lst{value} = lst{value-1};
    lst{value-1} = buf;
    set(handles.testlistbox,'String',lst)
    set(handles.testlistbox, 'Value', value-1)
    buf_test_inputs = handles.inputs_test{value};
    handles.inputs_test{value} = handles.inputs_test{value-1};
    handles.inputs_test{value-1} = buf_test_inputs;
    buf_test_outputs = handles.outputs_test{value};
    handles.outputs_test{value} = handles.outputs_test{value-1};
    handles.outputs_test{value-1} = buf_test_outputs;
end;
guidata(gcbo, handles);

% --- Executes on button press in downtestbutton.
function downtestbutton_Callback(hObject, eventdata, handles)
% hObject    handle to downtestbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lst = get(handles.testlistbox, 'String');
value = get(handles.testlistbox, 'Value');
if value < size(lst,1)
    buf = lst{value};
    lst{value} = lst{value+1};
    lst{value+1} = buf;
    set(handles.testlistbox,'String',lst);
    set(handles.testlistbox, 'Value', value+1);
    buf_test_inputs = handles.inputs_test{value};
    handles.inputs_test{value} = handles.inputs_test{value+1};
    handles.inputs_test{value+1} = buf_test_inputs;
    buf_test_outputs = handles.outputs_test{value};
    handles.outputs_test{value} = handles.outputs_test{value+1};
    handles.outputs_test{value+1} = buf_test_outputs;
end;
guidata(gcbo, handles);

% --- Executes on button press in opentestbutton.
function opentestbutton_Callback(hObject, eventdata, handles)
% hObject    handle to opentestbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName, PathName] = uigetfile('*.dat', 'MultiSelect', 'on');
DELIMITER = ',';

numberdata = 1;
if isfield(handles, 'numberFiles_test')
    numberdata = handles.numberFiles_test + 1;
end;

if iscell(FileName)
   for k = 1:length(FileName)
        if isfield(handles, 'numberFiles_test')
            numberdatafiles = handles.numberFiles_test + 1;
        else
            numberdatafiles = 1;
        end;
        FullName = [PathName FileName{k}];
        
        rawData = importdata(FullName, DELIMITER);
        
        if iscell(rawData)
            t = 1;
            while ~strcmp(rawData{t},'@data')
                t = t + 1;
            end;
        
            rawData = rawData(t+1:end,:);
            data(:) = strsplit(rawData{1},', ');
            for i = 2:size(rawData,1)
                data(i,:) = strsplit(rawData{i},', ');
            end;
        
            for i = 1:size(rawData,1)
                for j = 1:size(data,2)-1
                    handles.inputs_test{numberdatafiles}(i,j) = str2double(data{i,j});
                end;
            end;
        
            handles.outputs_test{numberdatafiles} = data(:,end);
            
            clear data;
            clear rawData;
        else
            handles.inputs_test{numberdatafiles}(:,:) = rawData.data(:,1:end-1);
            handles.outputs_test{numberdatafiles}(:) = rawData.data(:,end);
        end;
        handles.numberFiles_test = numberdatafiles;
        lst = get(handles.testlistbox, 'String');
        lst{end + 1} = FileName{k};
        set(handles.testlistbox,'String',lst)
        set(handles.testlistbox,'Value', handles.numberFiles_test)
    end;
else
    if FileName~=0
            FullName = [PathName FileName];

            rawData = importdata(FullName, DELIMITER);
        
            if iscell(rawData)
                t = 1;
                while ~strcmp(rawData{t},'@data')
                    t = t + 1;
                end;
        
                rawData = rawData(t+1:end,:);
            
                data(:) = strsplit(rawData{1},', ');
                for i = 2:size(rawData,1)
                    data(i,:) = strsplit(rawData{i},', ');
                end;
        
                for i = 1:size(rawData,1)
                    for j = 1:size(data,2)-1
                        handles.inputs_test{numberdata}(i,j) = str2double(data{i,j});
                    end;
                end;
        
                handles.outputs_test{numberdata} = data(:,end);
        
            else
                handles.outputs_test{numberdata}(:) = num2cell(rawData.data(:,end));
            
                handles.inputs_test{numberdata}(:,:) = rawData.data(:,1:end-1);
            end;
            handles.numberFiles_test = numberdata;
                        
            lst = get(handles.testlistbox, 'String');
            lst{end + 1} = FileName;
            set(handles.testlistbox,'String',lst)
            set(handles.testlistbox,'Value', 1)
    end;
end;
guidata(gcbo, handles);


% --- Executes on button press in deletetrainbutton.
function deletetrainbutton_Callback(hObject, eventdata, handles)
% hObject    handle to deletetrainbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lst = get(handles.trainlistbox, 'String');
if size(lst,1) ~= 0 
    value = get(handles.trainlistbox, 'Value');
    lst(value) = [];
    handles.numberFiles = handles.numberFiles - 1;
    if handles.numberFiles ~= 0
        set(handles.trainlistbox, 'Value', handles.numberFiles);
    else
        set(handles.trainlistbox, 'Value', 1);
    end;
    set(handles.trainlistbox,'String',lst);
    handles.inputs(value) = [];
    handles.outputs(value) = [];
else
    set(handles.trainlistbox, 'Value', 1);
    set(handles.trainlistbox,'String','');
end;
guidata(gcbo, handles);

% --- Executes on button press in deletetestbutton.
function deletetestbutton_Callback(hObject, eventdata, handles)
% hObject    handle to deletetestbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lst = get(handles.testlistbox, 'String');
if size(lst,1) ~= 0 
    value = get(handles.testlistbox, 'Value');
    lst(value) = [];
    handles.numberFiles_test = handles.numberFiles_test - 1;
    if handles.numberFiles_test ~= 0
        set(handles.testlistbox, 'Value', handles.numberFiles_test);
    else
        set(handles.testlistbox, 'Value', 1);
    end;
    set(handles.testlistbox,'String',lst);
    handles.inputs_test(value) = [];
    handles.outputs_test(value) = [];
else
    set(handles.testlistbox, 'Value', 1);
    set(handles.testlistbox,'String','');
end;
guidata(gcbo, handles);


% --------------------------------------------------------------------
function menu_Callback(hObject, eventdata, handles)
% hObject    handle to menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function bayesitem_Callback(hObject, eventdata, handles)
% hObject    handle to bayesitem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h=open('dlg.fig');
handles_dlg = guihandles(h);
par = guidata(handles.figure1);
if isfield(par, 'parameter')
    if isequal(par.parameter,'normal')
        set(handles_dlg.normalradiobutton,'Value',1);
    end;
    if isequal(par.parameter,'mvmn')
        set(handles_dlg.mvmnradiobutton,'Value',1);
    end;
    if isequal(par.parameter,'kernel')
        set(handles_dlg.kernelradiobutton,'Value',1);
    end;
end;
set(handles_dlg.okbutton,'Callback',{@okbutton_Callback,handles,handles_dlg});
set(handles_dlg.cancelbutton,'Callback',{@cancelbutton_Callback,handles_dlg});
% --------------------------------------------------------------------
function treeitem_Callback(hObject, eventdata, handles)
% hObject    handle to treeitem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h=open('tree.fig');
handles_tree = guihandles(h);
par = guidata(handles.figure1);
if isfield(par, 'afc')
    if isequal(par.afc,'Exact')
        set(handles_tree.exactradiobutton,'Value',1);
    end;
    if isequal(par.afc,'PullLeft')
        set(handles_tree.pullleftradiobutton,'Value',1);
    end;
    if isequal(par.afc,'PCA')
        set(handles_tree.pcaradiobutton,'Value',1);
    end;
    if isequal(par.afc,'OVAbyClass')
        set(handles_tree.ovabyclassradiobutton,'Value',1);
    end;        
end;
set(handles_tree.treeokbutton,'Callback',{@treeokbutton_Callback,handles,handles_tree});
set(handles_tree.treecancelbutton,'Callback',{@treecancelbutton_Callback,handles_tree});

function treeokbutton_Callback(hObject, eventdata, handles,handles_tree)

par=guidata(handles.figure1);
if get(handles_tree.exactradiobutton,'Value') 
    par.afc='Exact';
end;
if get(handles_tree.pullleftradiobutton,'Value')
    par.afc='PullLeft';
end
if get(handles_tree.pcaradiobutton,'Value')
    par.afc='PCA';
end
if get(handles_tree.ovabyclassradiobutton,'Value')
    par.afc='OVAbyClass';
end
guidata(handles.figure1,par)
% удаляем диалоговое окно method
delete(handles_tree.treefigure)

function treecancelbutton_Callback(hObject, eventdata, handles_tree)

delete(handles_tree.treefigure)



function okbutton_Callback(hObject, eventdata, handles,handles_dlg)

par=guidata(handles.figure1);
if get(handles_dlg.normalradiobutton,'Value') 
    par.parameter='normal';
end;
if get(handles_dlg.mvmnradiobutton,'Value')
    par.parameter='mvmn';
end
if get(handles_dlg.kernelradiobutton,'Value')
    par.parameter='kernel';
end
guidata(handles.figure1,par)
% удаляем диалоговое окно method
delete(handles_dlg.choosefigure)

function cancelbutton_Callback(hObject, eventdata, handles_dlg)

delete(handles_dlg.choosefigure)


% --------------------------------------------------------------------
function chooseclassificatoritem_Callback(hObject, eventdata, handles)
% hObject    handle to chooseclassificatoritem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h=open('classificator.fig');
handles_classificator = guihandles(h);
par = guidata(handles.figure1);
if isfield(par, 'classificator')
    if isequal(par.classificator,'bayes')
        set(handles_classificator.bayesradiobutton,'Value',1);
    end;
    if isequal(par.classificator,'tree')
        set(handles_classificator.treeradiobutton,'Value',1);
    end;
end;
set(handles_classificator.classificatorokbutton,'Callback',{@classificatorokbutton_Callback,handles,handles_classificator});
set(handles_classificator.classificatorcancelbutton,'Callback',{@classificatorcancelbutton_Callback,handles_classificator});

function classificatorokbutton_Callback(hObject, eventdata, handles,handles_classificator)

par=guidata(handles.figure1);
if get(handles_classificator.bayesradiobutton,'Value') 
    par.classificator='bayes';
end;
if get(handles_classificator.treeradiobutton,'Value')
    par.classificator='tree';
end
guidata(handles.figure1,par)
% удаляем диалоговое окно method
delete(handles_classificator.classificatorfigure)

function classificatorcancelbutton_Callback(hObject, eventdata, handles_classificator)

delete(handles_classificator.classificatorfigure)


% --- Executes on button press in treeviewbutton.
function treeviewbutton_Callback(hObject, eventdata, handles)
% hObject    handle to treeviewbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles, 'classificator')
    if isequal(handles.classificator, 'tree') && isfield(handles, 'Model')
        set(handles.treeviewbutton,'Enable','on');
        view(handles.Model{1},'Mode','graph')
    else
        set(handles.treeviewbutton,'Enable','off');
    end;
else
    set(handles.treeviewbutton,'Enable','off');
end;
