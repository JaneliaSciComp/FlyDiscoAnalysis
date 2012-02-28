function FlyBowlPlotPerFrameStats(expdir,varargin)

[analysis_protocol,settingsdir,datalocparamsfilestr,visible,controldatadirstr,DEBUG,usedaterange] = ...
  myparse(varargin,...
  'analysis_protocol','current',...
  'settingsdir','/groups/branson/bransonlab/projects/olympiad/FlyBowlAnalysis/settings',...
  'datalocparamsfilestr','dataloc_params.txt',...
  'visible','off',...
  'controldatadirstr','current',...
  'debug',false,...
  'usedaterange',true);

dateformat = 'yyyymmddTHHMMSS';

%% data locations

datalocparamsfile = fullfile(settingsdir,analysis_protocol,datalocparamsfilestr);
dataloc_params = ReadParams(datalocparamsfile);

%% load experiment data

statsmatsavename = fullfile(expdir,dataloc_params.statsperframematfilestr);
load(statsmatsavename,'statsperfly','statsperexp');
histmatsavename = fullfile(expdir,dataloc_params.histperframematfilestr);
load(histmatsavename,'histperfly','histperexp');

%% create the plot directory if it does not exist
figdir = fullfile(expdir,dataloc_params.figdir);
if ~DEBUG && ~exist(figdir,'file'),
  [status,msg] = mkdir(figdir);
  if ~status,
    error('Could not create the figure directory %s:\n%s',figdir,msg);
  end
end

%% load stats params

statsperframefeaturesfile = fullfile(settingsdir,analysis_protocol,dataloc_params.statsperframefeaturesfilestr);
stats_perframefeatures = ReadStatsPerFrameFeatures(statsperframefeaturesfile);

%% load hist params

histperframefeaturesfile = fullfile(settingsdir,analysis_protocol,dataloc_params.histperframefeaturesfilestr);
hist_perframefeatures = ReadHistPerFrameFeatures(histperframefeaturesfile);
histperframebinsfile = fullfile(settingsdir,analysis_protocol,dataloc_params.histperframebinsfilestr);
load(histperframebinsfile,'bins');

%% read plotting parameters

histplotparamsfile = fullfile(settingsdir,analysis_protocol,dataloc_params.histplotparamsfilestr);
hist_plot_params = ReadParams(histplotparamsfile);
[tmp,expname] = fileparts(expdir);

%% get control data

if ~isempty(controldatadirstr),
  
  % try to parse date for this experiment
  metadata = parseExpDir(expdir);
  if ~isempty(metadata) && usedaterange,
    dv = datevec(metadata.date,dateformat);
    % get the previous month
    year = dv(1);
    month = dv(2);
    dvend = [year,month,1,0,0,0];    
    if month == 1,
      month = 12;
      year = year - 1;
    else
      month = month-1;
    end
    dvstart = [year,month,1,0,0,0];
    daterange = {datestr(dvstart,dateformat),datestr(dvend,dateformat)};
    controldatadir = fullfile(dataloc_params.pBDPGAL4Ustatsdir,sprintf('%sto%s_%s',daterange{:},controldatadirstr));
    if ~exist(controldatadir,'dir'),
      controldatadir = fullfile(dataloc_params.pBDPGAL4Ustatsdir,controldatadirstr);
    end
  else
    controldatadir = fullfile(dataloc_params.pBDPGAL4Ustatsdir,controldatadirstr);
  end
  controlstatsname = fullfile(controldatadir,dataloc_params.statsperframematfilestr);
  controlstats = load(controlstatsname);
  controlhistname = fullfile(controldatadir,dataloc_params.histperframematfilestr);
  controlhist = load(controlhistname);
  
  % make a soft-link to the control statistics directory
  if isunix,
    [~,link] = unix(sprintf('readlink %s',controldatadir));
    if ~isempty(link),
      if link(1) ~= '/',
        realcontroldatadir = fullfile(dataloc_params.pBDPGAL4Ustatsdir,strtrim(link));
      else
        realcontroldatadir = strtrim(link);
      end
    else
      realcontroldatadir = controldatadir;
    end
    cmd = sprintf('ln -s %s %s',realcontroldatadir,fullfile(figdir,'pBDPGAL4U_stats'));
    unix(cmd);
  end
  
else
  
  controlstats = [];
  controlhist = [];
  
end

%% plot means, stds

[tmp,basename] = fileparts(expdir);
stathandles = PlotPerFrameStats(stats_perframefeatures,statsperfly,statsperexp,controlstats,basename,'visible',visible);
drawnow;  
if ~DEBUG,
  savename = sprintf('stats.png');
  savename = fullfile(figdir,savename);
  if exist(savename,'file'),
    delete(savename);
  end
  save2png(savename,stathandles.hfig);
end

%% plot histograms

hist_fields = unique({hist_perframefeatures.field});
for i = 1:numel(hist_fields),
  
  field = hist_fields{i};

  if ~isempty(controlhist),
    if isfield(controlhist,'meanhistperexp'),
      handles_control = PlotPerExpHists(field,hist_perframefeatures,...
        controlhist.meanhistperexp,controlhist.histperexp,...
        bins.(field),hist_plot_params,expname,...
        'visible',visible,'linestyle',':','stdstyle','errorbar');
    else
      handles_control = PlotPerFrameHists(field,hist_perframefeatures,...
        controlhist.meanhistperfly,controlhist.histperfly,...
        bins.(field),hist_plot_params,expname,...
        'visible',visible,'linestyle',':','stdstyle','errorbar');
    end
    hax = handles_control.hax;
  else
    hax = [];
  end
  
  handles = PlotPerFrameHists(field,hist_perframefeatures,...
    histperexp,histperfly,...
    bins.(field),hist_plot_params,expname,...
    'visible',visible,...
    'hax',hax);
  
  if ~isempty(controlhist),
    % fix legend
    s = get(handles.hleg,'String');
    legend([handles_control.htype(1),handles.htype],[{'control'},s],'Parent',handles.hfig,'Interpreter','none');
  end
  
  drawnow;
  if ~DEBUG,
    savename = sprintf('hist_%s.png',hist_fields{i});
    savename = fullfile(figdir,savename);
    if exist(savename,'file'),
      delete(savename);
    end
    save2png(savename,handles.hfig);
  end
  
end

close all;

