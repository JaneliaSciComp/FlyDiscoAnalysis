function [expdirs,expdir_reads,expdir_writes,experiments,rootreaddir,rootwritedir] = ...
  getExperimentDirs(varargin)

[protocol,daterange,linename,rig,plate,bowl,notstarted,subreadfiles,subwritefiles,...
  settingsdir,datalocparamsfilestr,rootdir] = ...
  myparse(varargin,'protocol','',...
  'daterange',cell(1,2),'linename','','rig','','plate','','bowl','','notstarted',false,...
  'subreadfiles',{},'subwritefiles',{},...
  'settingsdir','/groups/branson/bransonlab/projects/olympiad/FlyBowlAnalysis/settings',...
  'datalocparamsfilestr','dataloc_params.txt','rootdir','');

if isempty(rootdir),
  
  switch protocol,
    
    case 'RegistrationTest20110125',
      rootreaddir = '/groups/branson/bransonlab/tracking_data/olympiad/FlyBowl/RegistrationTest20110125';
      rootwritedir = rootreaddir;
      
    case 'scratched_polycarbonate_CtraxTest20101118',
      rootreaddir = '/groups/branson/bransonlab/tracking_data/olympiad/FlyBowl/polycarbonate_scratched';
      rootwritedir = '/groups/branson/home/bransonk/tracking/data/olympiad/FlyBowl/CtraxTest20101118';
      
    case 'CtraxTest20101118',
      rootreaddir = '/groups/sciserv/flyolympiad/Olympiad_Screen/fly_bowl/bowl_data/';
      rootwritedir = '/groups/branson/home/bransonk/tracking/data/olympiad/FlyBowl/CtraxTest20101118';
      
    case 'CtraxTest20110111',
      rootreaddir = '/groups/branson/bransonlab/tracking_data/olympiad/FlyBowl/CtraxTest20110111';
      rootwritedir = rootreaddir;
      
    case 'CtraxTest20110202',
      rootreaddir = '/groups/branson/bransonlab/tracking_data/olympiad/FlyBowl/CtraxTest20110202';
      rootwritedir = rootreaddir;
      
    otherwise
      
      params = ReadParams(fullfile(settingsdir,protocol,datalocparamsfilestr));
      
      rootreaddir = params.rootreaddir;
      rootwritedir = params.rootwritedir;
      
  end

else
  rootreaddir = rootdir;
  rootwritedir = rootdir;
end

% date range
mindatenum = -inf;
maxdatenum = inf;
if numel(daterange) >= 1 && ~isempty(daterange{1}),
  mindatenum = datenum(daterange{1},'yyyymmddTHHMMSS');
end
if numel(daterange) >= 2 && ~isempty(daterange{2}),
  maxdatenum = datenum(daterange{2},'yyyymmddTHHMMSS');
end


tmp = dir(rootreaddir);
expdir_reads = {tmp([tmp.isdir]).name};
tmp = dir(rootwritedir);
expdir_writes = {tmp([tmp.isdir]).name};
expdirs = union(expdir_reads,expdir_writes);

expdir_reads = cell(size(expdirs));
expdir_writes = cell(size(expdirs));

idx = false(size(expdirs));
experiments = struct;
for i = 1:numel(expdirs),
  
  % make sure the experiment exists in both read and write dirs
  expdir_reads{i} = fullfile(rootreaddir,expdirs{i});
  expdir_writes{i} = fullfile(rootwritedir,expdirs{i});
  if ~exist(expdir_reads{i},'file') || ~exist(expdir_writes{i},'file'),
    continue;
  end
  
  % parse the directory
  [parsedcurr,success] = parseExpDir(expdirs{i});
  if ~success,
    continue;
  else
    experiments = structarrayset(experiments,i,parsedcurr);
  end
  
  % check date range
  v = datenum(parsedcurr.date,'yyyymmddTHHMMSS');
  if v < mindatenum || v > maxdatenum,
    continue;
  end
  
  % check line name
  if ~isempty(linename),
    if isempty(regexp(parsedcurr.line,linename,'once')),
      continue;
    end
  end
  
  % check rig
  if ~isempty(rig),
    if isempty(regexp(parsedcurr.rig,rig,'once')),
      continue;
    end
  end
    
   % check plate
  if ~isempty(plate),
    if isempty(regexp(parsedcurr.plate,plate,'once')),
      continue;
    end
  end
    
   % check bowl
  if ~isempty(bowl),
    if isempty(regexp(parsedcurr.bowl,bowl,'once')),
      continue;
    end
  end
  
  % check notstarted
  if ~isempty(notstarted),
    if parsedcurr.notstarted ~= notstarted,
      continue;
    end
  end
  
  % check for subfiles
  doexist = true;
  for j = 1:numel(subreadfiles),
    %if ~exist(fullfile(expdir_reads{i},subreadfiles{j}),'file')
    if isempty(dir(fullfile(expdir_reads{i},subreadfiles{j}))),
      doexist = false;
      break;
    end
  end
  if ~doexist,
    continue;
  end
  for j = 1:numel(subwritefiles),
    %if ~exist(fullfile(expdir_writes{i},subwritefiles{j}),'file')
    if isempty(dir(fullfile(expdir_writes{i},subreadfiles{j}))),
      doexist = false;
      break;
    end
  end
  if ~doexist,
    continue;
  end
  
  idx(i) = true;
  
end

expdirs = expdirs(idx);
expdir_reads = expdir_reads(idx);
expdir_writes = expdir_writes(idx);
experiments = experiments(idx);