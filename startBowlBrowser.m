function browser = startBowlBrowser(data,varargin)
%startBowlBrowser Start OlyDat Browser for Bowl assay.
%   browser = startBowlBrowser(data) starts the OlyDat Browser for the bowl
%   assay with the specified input dataset. This input dataset should be
%   generated by the OlyDat.DataSelector.

%% parse parameters
[analysis_protocol,settingsdir,datalocparamsfilestr] = ...
  myparse(varargin,...
  'analysis_protocol','current',...
  'settingsdir','/groups/branson/bransonlab/projects/olympiad/FlyBowlAnalysis/settings',...
  'datalocparamsfilestr','dataloc_params.txt');

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
  bst = structappend(bst,OlyDat.BrowserStat(behaviorvariables{i},behaviorvariables{i},{},true,1,1),1);
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
edt          = OlyDat.BrowserStat('exp_datetime','exp_datetime');
ast          = [edt;bst];

%% Experiment Detail Quantities
est = [];
for i = 1:numel(experimentdetailvariables),
  fn = experimentdetailvariables{i};
  if ~isfield(data,fn),
    continue;
  end
  isscore = ~isempty(regexp(fn,'^seconds_','once')) || ...
    ~isempty(regexp(fn,'^hours_','once'));
  if isscore,
    % name, prettyname, validvalues, isscore, sequence, temperatureidx
    est = structappend(est,OlyDat.BrowserStat(experimentdetailvariables{i},experimentdetailvariables{i},{},true,1,1),1);
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
plots = {TornadoPlot;HistogramPlot;CorrelationPlot;MultiStatPlot};

%% DetailHandler
expdetailhandler = BowlExperimentDetailHandler;

browser = OlyDat.Browser(data,plots,bst,gst,ast,est,expdetailhandler);

end
