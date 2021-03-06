function browser = startBowlBrowser(data,varargin)
%startBowlBrowser Start OlyDat Browser for Bowl assay.
%   browser = startBowlBrowser(data) starts the OlyDat Browser for the bowl
%   assay with the specified input dataset. This input dataset should be
%   generated by the OlyDat.DataSelector.

%% parse parameters
[analysis_protocol,settingsdir,datalocparamsfilestr,compute_extra_diagnostics] = ...
  myparse(varargin,...
  'analysis_protocol','current',...
  'settingsdir','/groups/branson/bransonlab/projects/olympiad/FlyBowlAnalysis/settings',...
  'datalocparamsfilestr','dataloc_params.txt',...
  'compute_extra_diagnostics',false);

%% read in the data locations
datalocparamsfile = fullfile(settingsdir,analysis_protocol,datalocparamsfilestr);
dataloc_params = ReadParams(datalocparamsfile);

%% read parameters

%paramsfile = fullfile(settingsdir,analysis_protocol,dataloc_params.olydatbrowserbehaviorvariablesparamsfilestr);
%params = ReadParams(paramsfile);
behaviorfile = fullfile(settingsdir,analysis_protocol,dataloc_params.olydatbrowserbehaviorvariablesfilestr);
behaviorvariables = ReadOlyDatVariables(behaviorfile);
groupingfile = fullfile(settingsdir,analysis_protocol,dataloc_params.olydatbrowsergroupingvariablesfilestr);
groupingvariables = ReadOlyDatVariables(groupingfile);
experimentdetailfile = fullfile(settingsdir,analysis_protocol,dataloc_params.olydatbrowserexperimentdetailvariablesfilestr);
experimentdetailvariables = ReadOlyDatVariables(experimentdetailfile);


%% Behavioral and other quantities of interested listed in the behavioral stat pulldown

bst = [];
for i = 1:numel(behaviorvariables),
  if ~isfield(data,behaviorvariables{i}),
    continue;
  end
  % name, prettyname, validvalues, isscore, sequence, temperatureidx
  bst = structappend(bst,OlyDat.BrowserStat(behaviorvariables{i},behaviorvariables{i},{}),1);
end

%% Grouping quantities

gst = [];
for i = 1:numel(groupingvariables),
  fn = groupingvariables{i};
  if ~isfield(data,fn),
    continue;
  end
  tmp = {data.(fn)};
  if any(cellfun(@ischar,tmp)),
    validvalues = unique(tmp);
  else
    validvalues = unique([data.(fn)]);
  end
  % name, prettyname, validvalues, isscore, sequence, temperatureidx
  gst = structappend(gst,OlyDat.BrowserStat(groupingvariables{i},groupingvariables{i},validvalues),1);
end

%% Auxiliary quantities
edt          = OlyDat.BrowserStat('edt','exp_datenum');
ast          = [edt;bst];

%% Experiment Detail Quantities
est = [];
for i = 1:numel(experimentdetailvariables),
  fn = experimentdetailvariables{i};
  if ~isfield(data,fn),
    continue;
  end
  isnumber = ~isempty(regexp(fn,'^seconds_','once')) || ...
    ~isempty(regexp(fn,'^hours_','once'));
  if isnumber,
    % name, prettyname, validvalues, isscore, sequence, temperatureidx
    est = structappend(est,OlyDat.BrowserStat(experimentdetailvariables{i},experimentdetailvariables{i},{}),1);
  else
    tmp = {data.(fn)};
    if any(cellfun(@ischar,tmp)),
      validvalues = unique(tmp);
    else
      validvalues = unique([data.(fn)]);
    end
    % name, prettyname, validvalues, isscore, sequence, temperatureidx
    est = structappend(est,OlyDat.BrowserStat(experimentdetailvariables{i},experimentdetailvariables{i},validvalues),1);
  end
end

%% Plots
plots = {TornadoPlot_FlyBowl;HistogramPlot_FlyBowl;CorrelationPlot_FlyBowl;MultiStatPlot};

%% DetailHandler
expdetailhandler = BowlExperimentDetailHandler;
expdetailhandler.SetVideoDiagnosticsParams('analysis_protocol',analysis_protocol,'settingsdir',settingsdir,'datalocparamsfilestr',datalocparamsfilestr);
expdetailhandler.SetComputeExtraDiagnostics(compute_extra_diagnostics);
browser = OlyDat.Browser('FlyBowl',data(:),plots,bst,gst,ast,est,expdetailhandler);

end
