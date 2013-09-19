function CleanPerFrameData(obj,fns,ns)

if ~exist('ns','var'),
  ns = 1:obj.nexpdirs;
end
if ~exist('fns','var') || isempty(fns),
  fns = -1; % clean up all non-traj mats in per-frame dir  
  %fns = setdiff(Trx.PerFrameFieldNames(),Trx.TrajectoryFieldNames());
end
if ~iscell(fns),
  fns = {fns};
end
for n = ns,
  if any(cellfun(@(x)isequal(x,-1),fns))
    perframedir = fullfile(obj.expdirs{n},obj.dataloc_params.perframedir);
    perframefiles = dir(perframedir);
    perframefiles = perframefiles(~[perframefiles.isdir]);
    perframefiles = {perframefiles.name}';
    tfTmp = cellfun(@(x)~isempty(regexp(x,'\.mat$','once')),perframefiles);
    perframefiles = perframefiles(tfTmp);
    perframefiles = cellfun(@(x)x(1:end-4),perframefiles,'UniformOutput',false);
    fnsCurr = setdiff(perframefiles,Trx.TrajectoryFieldNames());
  else
    fnsCurr = fns;
  end
      
  for i = 1:numel(fnsCurr),
    fn = fnsCurr{i};

    filename = obj.GetPerFrameFile(fn,n);
    if exist(filename,'file') && ~obj.DEBUG,
      fprintf('Deleting per-frame data file %s\n',filename);
      delete(filename);
    end
    
    % clear from cache
    j = find(strcmp(fn,obj.fnscached{n}),1);
    if ~isempty(j),
      obj.datacached{n}(j) = [];
      obj.fnscached{n}(j) = [];
      obj.nfnscached(n) = obj.nfnscached(n)-1;
    end
    
  end
end
