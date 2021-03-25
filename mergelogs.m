function mergelogs(logfiles)
mergedfile = fullfile(logfiles(1).folder,strrep(logfiles(1).name,'.mat','merged.mat'));
for logf=1:length(logfiles)
    logdata = load(fullfile(logfiles(logf).folder,logfiles(logf).name));
    newlog = logdata.log;
    if logf==1
        log = newlog;
    else
        log = [log,newlog];
    end
end
save(mergedfile,'log');