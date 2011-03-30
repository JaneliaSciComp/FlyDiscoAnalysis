function trx = FlyBowlComputePerFrameFeatures(expdir,varargin)

[analysis_protocol,settingsdir,datalocparamsfilestr,forcecompute,perframefns] = ...
  myparse(varargin,...
  'analysis_protocol','current',...
  'settingsdir','/groups/branson/bransonlab/projects/olympiad/FlyBowlAnalysis/settings',...
  'datalocparamsfilestr','dataloc_params.txt',...
  'forcecompute',true,...
  'perframefns', {} ... % added CSC 20110321: optionally specify to-be-computed frames as parameter, reads from perframefnsfile (as before) otherwise
	);

%% load the trx

fprintf('Initializing trx...\n');

trx = Trx('analysis_protocol',analysis_protocol,'settingsdir',settingsdir,...
  'datalocparamsfilestr',datalocparamsfilestr);

fprintf('Loading trajectories for %s...\n',expdir);

trx.AddExpDir(expdir);

%% compute per-frame features

if isempty(perframefns) % added CSC 20110321: optionally specify to-be-computed frames as parameter, reads from perframefnsfile (as before) otherwise
perframefnsfile = fullfile(trx.settingsdir,trx.analysis_protocol,trx.dataloc_params.perframefnsfilestr);
perframefns = importdata(perframefnsfile);
end
nfns = numel(perframefns);

% clean this data to force computation
if forcecompute,
  for i = 1:nfns,
    fn = perframefns{i};
    trx.CleanPerFrameData(fn);
  end
end

% compute each
for i = 1:nfns,
  fn = perframefns{i};
  fprintf('Computing %s...\n',fn);
  trx.(fn); %#ok<VUNUS>
end
