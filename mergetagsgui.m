function varargout = mergetagsgui(varargin)
% MERGETAGSGUI MATLAB code for mergetagsgui.fig
%      MERGETAGSGUI, by itself, creates a new MERGETAGSGUI or raises the existing
%      singleton*.
%
%      H = MERGETAGSGUI returns the handle to a new MERGETAGSGUI or the handle to
%      the existing singleton*.
%
%      MERGETAGSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MERGETAGSGUI.M with the given input arguments.
%
%      MERGETAGSGUI('Property','Value',...) creates a new MERGETAGSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mergetagsgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mergetagsgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mergetagsgui

% Last Modified by GUIDE v2.5 09-May-2019 10:45:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mergetagsgui_OpeningFcn, ...
                   'gui_OutputFcn',  @mergetagsgui_OutputFcn, ...
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


% --- Executes just before mergetagsgui is made visible.
function mergetagsgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mergetagsgui (see VARARGIN)

% Choose default command line output for mergetagsgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mergetagsgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mergetagsgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in selectindividualfiles.
function selectindividualfiles_Callback(hObject, eventdata, handles)
% hObject    handle to selectindividualfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.mat'}, 'Select results files','MultiSelect','on');
% Handle the situation where only one file is selected
if ~iscell(filename)
    f{1} = filename;
    filename = f;
end
if ~isempty(pathname)
    mergetags(pathname,filename)
end
for f=1:length(filename)
    if isfile(fullfile(pathname,strrep(filename{f},'results','log')))
        logfiles(f).folder = pathname;
        logfiles(f).name = strrep(filename{f},'results','log');
    end
end
if exist('logfiles','var')
    mergelogs(logfiles);
end

% --- Executes on button press in foldermerge.
function foldermerge_Callback(hObject, eventdata, handles)
% hObject    handle to foldermerge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Note - if there ARE subdirectories, it will only merge files in the
% subdirectories but not files in the main directory. The merged files from
% the subdirectories will be stored in the subdirectories.

[pathname] = uigetfile_n_dir(pwd, 'Select one or more directories');
ndirs = size(pathname,2);
for d=1:ndirs % If the user selects more than one directory, loop through each directory the user chose
    [P,F] = subdir(pathname{d}); % Look for subdirectories under the user-chosen directory
    if isempty(P) % If there are no subdirectories
        % Merge Results Files
        files = dir([pathname{d} '/*results.mat']);
        handles.filename = {};
        handles.pathname = {};
        for f=1:length(files)
            handles.filename{f} = files(f).name;
            handles.pathname{f} = files(f).folder;
        end
        if ~isempty(handles.filename)
            mergetags(handles.pathname{1},handles.filename)
        end
        
        % Merge the log files in the directory into a file with the same name as the first log.mat file, but labeled logmerged.mat
        logfiles = dir([pathname{d} '/*log.mat']);
        if ~isempty(logfiles)
            mergelogs(logfiles);
        end
    end
    for p=1:length(P) % If there are subdirectories
        % Merge Results Files
        Findex = find(contains(F{p},'results.mat'));
        files = F{p};
        handles.filename = {};
        handles.pathname = {};
        for f=1:length(Findex)
            handles.filename{f} = files{Findex(f)};
            handles.pathname{f} = P{p};
        end
        if ~isempty(handles.filename)
            mergetags(handles.pathname{1},handles.filename)
        end
        
        % Merge Log Files
        Findex = find(contains(F{p},'log.mat'));
        files = F{p};
        logfiles = struct;
        for f=1:length(Findex)
            logfiles(f).name = files{Findex(f)};
            logfiles(f).folder = P{p};
        end
        if isfield(logfile,'name')
            mergelogs(logfiles)
        end
    end
end
