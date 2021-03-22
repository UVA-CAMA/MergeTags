 function mergetags(pathname,filename,timetags,kqrs,kc)
 % timetags = set to 1 if you want to keep timestamps in the info structure, otherwise they will be removed to save space
 % kqrs = the user's selection as to whether or not they want to keep the qrs results
 % kc = the user's selection as to whether or not they want to keep the continuous results
if ~exist('timetags','var'),timetags=false;end

nfiles = size(filename,2);

result_tagcolumns_all = struct;
result_tags_all = struct;
result_tagtitle_all = struct;
info_all = struct;

for f=1:nfiles
    file = fullfile(pathname, filename{f});
    new_data = load(file,'result_tags','result_tagcolumns','result_tagtitle','result_name','info');
    if kqrs
        new_result_qrs = load(file,'result_qrs');
    end
    if kc
        new_result_data = load(file,'result_data');
        new_result_name = load(file,'result_name');
    end
    new_tags = new_data.result_tags;
    new_tagcolumns = new_data.result_tagcolumns;
    new_tagtitles = new_data.result_tagtitle;
    
    new_data.info.resultname = new_data.result_name;
    new_data.info.resultfile = file;
    % Remove timestamps to save space unless requested
    if ~timetags
        try
            new_data.info.times=[];
        end
        try
            new_data.info.originaltimes=[];
        end
        try
            new_data.info.local=[];
        end     
    end
    
    new_info = new_data.info;
    
    % Add file number to tags
    for a=1:length(new_tagcolumns)
        ncols = length(new_tagcolumns(a).tagname);
        new_tagcolumns(a).tagname{ncols+1,1} = 'FileNumber';
        new_tags(a).tagtable(:,ncols+1) = repmat(f,size(new_tags(a).tagtable,1),1);
    end
    
    % Add file number to continuous data
    if kc
        for a=1:length(new_result_data)
            new_result_data(a).FileNumber = f;
        end
    end
        
    % Merge tags
    if f==1
        result_tags_all = new_tags;
        result_tagcolumns_all = new_tagcolumns;
        result_tagtitle_all = new_tagtitles;
    else
        rows = size(result_tagtitle_all,1);
        if rows==0
        	result_tags_all = new_tags;
            result_tagcolumns_all = new_tagcolumns;
            result_tagtitle_all = new_tagtitles;
        else
            for row=1:rows
                alltitles{row,1} = horzcat(result_tagtitle_all{row,1},num2str(result_tagtitle_all{row,2}));
            end
            if size(new_tagtitles,1)>0 && size(new_tagtitles,2)<2 % Handle the situation where there is a struct inside a struct
                new_tagtitles = new_tagtitles{1};
            end
            for row=1:size(new_tagtitles,1)
                newtitles{row,1} = horzcat(new_tagtitles{row,1},num2str(new_tagtitles{row,2}));
            end
            [A,B] = ismember(newtitles,alltitles);
            for a=1:length(A)
                if A(a)==0
                    result_tagtitle_all(size(result_tagtitle_all,1)+1,:) = new_tagtitles(a,:);
                    result_tagcolumns_all(size(result_tagcolumns_all,2)+1).tagname = new_tagcolumns(a).tagname;
                    result_tags_all(size(result_tags_all,2)+1).tagtable = new_tags(a).tagtable;
                else
                    [oldheight,oldwidth] = size(result_tags_all(B(a)).tagtable);
                    [newheight,newwidth] = size(new_tags(a).tagtable);
                    if oldheight==0
                        result_tags_all(B(a)).tagtable = new_tags(a).tagtable;
                    elseif newheight==0
                        result_tags_all(B(a)).tagtable = result_tags_all(B(a)).tagtable;
                    elseif oldwidth == newwidth
                        result_tags_all(B(a)).tagtable = vertcat(result_tags_all(B(a)).tagtable,new_tags(a).tagtable);
                    else
                        disp(['Old result tag column length was ' num2str(oldwidth) ' and now it is ' num2str(newwidth) ' for ' new_tagtitles{a}]);
                    end
                end
            end   
            alltitles = {};
            newtitles = {};
        end
    end
    
    % Merge qrs
    if kqrs
        if f==1
            result_qrs_all.result_qrs = new_result_qrs;
            result_qrs_all.FileNumber = f;
        else
            result_qrs_all(f).result_qrs = new_result_qrs;
            result_qrs_all(f).FileNumber = f;
        end
    end
    
    % Merge Continuous Data
    
    info_all(f).info = new_info;
    message = ['Merged file ' num2str(f) ' of ' num2str(nfiles) ' in ' pathname];
    disp(message)
    msgbox(message,'Merge Tags','modal')
end

result_tags = result_tags_all;
result_tagcolumns = result_tagcolumns_all;
result_tagtitle = result_tagtitle_all;
info = info_all;
[~,name,ext] = fileparts(filename{f});

message = ['Saving as ' name 'merged' ext ' in ' pathname];
disp(message) 
msgbox(message,'Merge Tags','modal')

save(fullfile(pathname, [name 'merged']),'result_tags','result_tagcolumns','result_tagtitle','info')

message = ['Saved as ' name 'merged' ext ' in ' pathname '. Merge complete.'];
disp(message)
msgbox(message,'Merge Tags','modal')