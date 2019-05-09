function mergetags(pathname,filename)

nfiles = size(filename,2);

result_tagcolumns_all = struct;
result_tags_all = struct;
result_tagtitle_all = struct;
info_all = struct;

for f=1:nfiles
    file = fullfile(pathname, filename{f});
    new_data = load(file,'result_tags','result_tagcolumns','result_tagtitle','info');
    new_tags = new_data.result_tags;
    new_tagcolumns = new_data.result_tagcolumns;
    new_tagtitles = new_data.result_tagtitle;
    new_info = new_data.info;
    
    % Add file number to tags
    for a=1:length(new_tagcolumns)
        ncols = length(new_tagcolumns(a).tagname);
        new_tagcolumns(a).tagname{ncols+1,1} = 'FileNumber';
        new_tags(a).tagtable(:,ncols+1) = repmat(f,size(new_tags(a).tagtable,1),1);
    end
        
    if f==1
        result_tags_all = new_tags;
        result_tagcolumns_all = new_tagcolumns;
        result_tagtitle_all = new_tagtitles;
    else
        rows = size(result_tagtitle_all,1);
        for row=1:rows
            alltitles{row,1} = horzcat(result_tagtitle_all{row,1},num2str(result_tagtitle_all{row,2}));
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
                result_tags_all(B(a)).tagtable = vertcat(result_tags_all(B(a)).tagtable,new_tags(a).tagtable);
            end
        end   
        alltitles = {};
        newtitles = {};
    end
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