function mergelogs(logfiles)
mergedfile = fullfile(logfiles(end).folder,strrep(logfiles(end).name,'.mat','merged.mat'));
for logf=1:length(logfiles)
    try
        logdata = load(fullfile(logfiles(logf).folder,logfiles(logf).name));
    catch
        continue
    end
    if ~isfield(logdata, 'log')
        continue
    end
    newlog = logdata.log;
    if logf==1
        log = newlog;
    else
        log = [log,newlog];
    end
end
save(mergedfile,'log');