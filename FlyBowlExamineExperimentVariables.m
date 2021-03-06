function [handles,data] = FlyBowlExamineExperimentVariables(varargin)

handles = struct;
data = [];
groupnames = SetDefaultGroupNames();

[analysis_protocol,settingsdir,datalocparamsfilestr,hfig,period,maxdatenum,...
  figpos,datenumnow,sage_params_path,sage_db,username,rootdatadir,dataset,...
  loadcacheddata,groupnames,leftovers] = ...
  myparse_nocheck(varargin,...
  'analysis_protocol','current',...
  'settingsdir','/groups/branson/bransonlab/projects/olympiad/FlyBowlAnalysis/settings',...
  'datalocparamsfilestr','dataloc_params.txt',...
  'hfig',1,...
  'period',7,...
  'maxdatenum',[],...
  'figpos',[],...
  'datenumnow',[],...
  'sage_params_path','',...
  'sage_db',[],...
  'username','',...
  'rootdatadir','/groups/sciserv/flyolympiad/Olympiad_Screen/fly_bowl/bowl_data',...
  'dataset','data',...
  'loadcacheddata','',...
  'groupnames',groupnames);

maxnundo = 5;
maxperiodsprev = 10;

didinputweek = ~isempty(maxdatenum) && ~isempty(datenumnow);
if ~didinputweek,
  datenumnow = now;
end

if isempty(maxdatenum),
  maxdatenum = datenumnow;
  daycurr = weekday(maxdatenum);
  daywant = 7;
  maxdatenum = floor(maxdatenum)+daywant-daycurr-7;

end
%format = 'yyyy-mm-ddTHH:MM:SS';
format = 'yyyymmddTHHMMSS';
mindatenum = maxdatenum - period;
mindatestr = datestr(mindatenum,format);
maxdatestr = datestr(maxdatenum,format);
daterange = {mindatestr,maxdatestr};
%maxdaysprev = datenumnow-mindatenum;
mindaysprev = datenumnow-maxdatenum;

% first day of week choices
mindatenum_choices = fliplr([mindatenum-period*maxperiodsprev:period:mindatenum-period,mindatenum:period:datenumnow]);
maxdatenum_choices = mindatenum_choices + period;
mindatestr_choices = datestr(mindatenum_choices,'yyyy-mm-dd');
maxdatestr_choices = datestr(maxdatenum_choices,'yyyy-mm-dd');

%% read parameters

datalocparamsfile = fullfile(settingsdir,analysis_protocol,datalocparamsfilestr);
dataloc_params = ReadParams(datalocparamsfile);
examineparamsfile = fullfile(settingsdir,analysis_protocol,dataloc_params.examineexperimentvariablesparamsfilestr);
examine_params = ReadParams(examineparamsfile);
examinefile = fullfile(settingsdir,analysis_protocol,dataloc_params.examineexperimentvariablesfilestr);
examinestats = ReadExamineExperimentVariables(examinefile);
registrationparamsfile = fullfile(settingsdir,analysis_protocol,dataloc_params.registrationparamsfilestr);
registration_params = ReadParams(registrationparamsfile);

if exist(examine_params.rcfile,'file'),
  rc = load(examine_params.rcfile);
else
  rc = struct('username','','savepath','');
end

%% get user name

havequestions = isempty(username) || ~didinputweek;

if havequestions,
  
  if ~isempty(username),
    rc.username = username;
  end

  if didinputweek,
    daterange_strings = {sprintf('%s to %s',mindatestr,maxdatestr)};
  else
    daterange_strings = cellstr(cat(2,mindatestr_choices,...
      repmat(' to ',[numel(maxdatenum_choices),1]),...
      maxdatestr_choices));
  end
  weekidx = find(maxdatenum_choices == maxdatenum,1);
  [success,newweekidx,newusername] = ExamineInitializeParams(daterange_strings,weekidx,rc.username);
  if ~success,
    return;
  end
  if ~isempty(newusername),
    rc.username = newusername;
  end
  if ~didinputweek,
    maxdatenum = maxdatenum_choices(newweekidx);
    mindatenum = mindatenum_choices(newweekidx);
    mindatestr = datestr(mindatenum,format);
    maxdatestr = datestr(maxdatenum,format);
    daterange = {mindatestr,maxdatestr};
    %maxdaysprev = datenumnow-mindatenum;
    mindaysprev = datenumnow-maxdatenum;
  end
  
end

if ~isfield(rc,'savepath'),
  rc.savepath = '';
end
if ~isfield(rc,'savedatapath'),
  rc.savedatapath = '';
end
savefilename = fullfile(rc.savepath,sprintf('DataCuration_FlyBowl_%s_%sto%s.tsv',...
  rc.username,datestr(mindatenum,'yyyymmdd'),datestr(maxdatenum,'yyyymmdd')));
savedatafilename = fullfile(rc.savedatapath,sprintf('ExperimentData_FlyBowl_%sto%s.mat',...
  datestr(mindatenum,'yyyymmdd'),datestr(maxdatenum,'yyyymmdd')));

needsave = false;

%% string metadata

flag_metadata_fns = {'flag_redo','flag_review'};
note_metadata_fns = {'notes_behavioral','notes_technical','notes_curation'};
string_metadata_fns = {'line_name','manual_pf','automated_pf','experiment_name','experiment_protocol',...
  'experimenter','exp_datetime','bowl','camera','computer','harddrive','apparatus_id','cross_date','effector',...
  'environmental_chamber','gender','genotype','handler_sorting','handler_starvation','plate','rearing_protocol',...
  'rig','top_plate','file_system_path','manual_behavior','cross_handler'};
%flag_options = {{'None',''},{'Rearing problem','Flies look sick',...
%  'See behavioral notes','See technical notes'}};

%% connect to SAGE for storing manualpf
% 
% if isempty(sage_db) && ~isempty(sage_params_path),
%   try
%     sage_db = ConnectToSage(sage_params_path);
%   catch ME,
%     getReport(ME);
%     warning('Could not connect to Sage');
%     sage_db = [];
%   end
% else
%   sage_db = [];
% end

%% get data
data_types = {'ufmf_diagnostics_summary_*',...
  'ctrax_diagnostics_*','registrationdata_*','sexclassifier_diagnostics_*',...
  'bias_diagnostics_*','temperature_diagnostics_*','bkgd_diagnostics_*',...
  'stats_perframe_x_mm_*','stats_perframe_y_mm_*'};
%data_types = examinestats;

didloaddata = false;
if isempty(loadcacheddata),
  b = questdlg('Load cached data from file?','Load data?','Yes','No','Cancel','No');
  if strcmpi(b,'no'),
    return;
  end
  if strcmpi(b,'yes'),
    [didloaddata,data,queries,pull_data_datetime,rc,savedatafilename] = ...
    LoadExamineData(savedatafilename,mindatenum,maxdatenum,rc,true);
  end    
else
  [didloaddata,data,queries,pull_data_datetime,rc,savedatafilename] = ...
    LoadExamineData(loadcacheddata,mindatenum,maxdatenum,rc,false);
end

if ~didloaddata,
  queries = leftovers;
  queries(end+1:end+2) = {'daterange',daterange};
  queries(end+1:end+2) = {'data_type',data_types};
  queries(end+1:end+2) = {'flag_aborted',0};
  queries(end+1:end+2) = {'automated_pf','P'};
  queries(end+1:end+2) = {'experiment_name','FlyBowl_*'};
  pull_data_datetime = now;
  data = SAGEGetBowlData(queries{:},'removemissingdata',true,'dataset',dataset);
  if isempty(data),
    uiwait(warndlg(sprintf('No data for date range %s to %s',daterange{:}),'No data found'));
    if didinputweek,
      fprintf('Trying previous week...\n');
      maxdatenum = maxdatenum - period;
      handles = FlyBowlExamineExperimentVariables(...
        'analysis_protocol',analysis_protocol,...
        'settingsdir',settingsdir,...
        'datalocparamsfilestr',datalocparamsfilestr,...
        'hfig',hfig,...
        'figpos',figpos,...
        'period',period,...
        'maxdatenum',maxdatenum,...
        'datenumnow',datenumnow,...
        'sage_params_path',sage_params_path,...
        'sage_db',sage_db,...
        'username',rc.username,...
        'rootdatadir',rootdatadir,...
        'dataset',dataset,...
        'loadcacheddata',loadcacheddata,...
        'groupnames',groupnames);
      return;
    else
      fprintf('Choose a different week.\n');
      handles = FlyBowlExamineExperimentVariables(...
        'analysis_protocol',analysis_protocol,...
        'settingsdir',settingsdir,...
        'datalocparamsfilestr',datalocparamsfilestr,...
        'hfig',hfig,...
        'figpos',figpos,...
        'period',period,...
        'maxdatenum',[],...
        'datenumnow',datenumnow,...
        'sage_params_path',sage_params_path,...
        'sage_db',sage_db,...
        'username',rc.username,...
        'rootdatadir',rootdatadir,...
        'dataset',dataset,...
        'loadcacheddata',loadcacheddata,...
        'groupnames',groupnames);
      return;
    end
  end
end
% sort by date
date = {data.exp_datetime};
[~,order] = sort(date);
data = data(order);
nexpdirs = numel(data);
expdir_bases = {data.experiment_name};
expdir_bases = cellfun(@(s) regexprep(s,'^FlyBowl_',''),expdir_bases,'UniformOutput',false);

%% for now, add on extra diagnostics here. we will store these later
need_file_system_path = ~isfield(data,'file_system_path');
need_notes_curation = ~isfield(data,'notes_curation');
for i = 1:nexpdirs,
  % add in mean_nsplit
  if isfield(data,'ctrax_diagnostics_sum_nsplit') && isfield(data,'ctrax_diagnostics_nlarge_split'),
    data(i).ctrax_diagnostics_mean_nsplit = ...
      data(i).ctrax_diagnostics_sum_nsplit / data(i).ctrax_diagnostics_nlarge_split;
  end
  % add in nframes_not_tracked
  if isfield(data,'ufmf_diagnostics_summary_nFrames') && isfield(data,'ctrax_diagnostics_nframes_analyzed'),
    data(i).ctrax_diagnostics_nframes_not_tracked = ...
      data(i).ufmf_diagnostics_summary_nFrames - data(i).ctrax_diagnostics_nframes_analyzed;
  end
  % add in mean, max, std, maxdiff, nreadings
%   data(i).temperature_mean = nanmean(data(i).temperature_stream);
%   data(i).temperature_max = max(data(i).temperature_stream);
%   data(i).temperature_maxdiff = data(i).temperature_max - min(data(i).temperature_stream);
%   data(i).temperature_nreadings = numel(data(i).temperature_stream);

  if isfield(data,'stats_perframe_x_mm'),
    data(i).mean_x_mm = data(i).stats_perframe_x_mm.meanmean_perexp.flyany_frameany;
  end
  if isfield(data,'stats_perframe_y_mm'),
    data(i).mean_y_mm = data(i).stats_perframe_y_mm.meanmean_perexp.flyany_frameany;
  end
  data(i).registrationdata_pxpermm = data(i).registrationdata_circleRadius / registration_params.circleRadius_mm;
  if need_file_system_path,
    data(i).file_system_path = fullfile(rootdatadir,expdir_bases{i});
  end
  if need_notes_curation,
    data(i).notes_curation = '';
  end
end
expdirs = {data.file_system_path};

%% groups of variables for searching

groupnames = intersect(groupnames,fieldnames(data));
groupvalues = cell(size(groupnames));
for i = 1:numel(groupnames),
  fn = groupnames{i};
  values = {data.(fn)};
  if all(cellfun(@ischar,values)),
    values = unique(values);
  else
    values = unique([values{:}]);
  end
  groupvalues{i} = values;
end

%% get experiment variables

nstats = numel(examinestats);
stat = nan(nexpdirs,nstats);

for i = 1:nstats,
  
  if ~isfield(data,examinestats{i}{1}),
    continue;
  end

  % special case: flags
  if ismember(examinestats{i}{1},flag_metadata_fns),
    % flags are now binary
    % make -3, 3
    v = double([data.(examinestats{i}{1})])*2*3-3;
    stat(:,i) = v;
%   if ismember(examinestats{i}{1},flag_metadata_fns),
%     
%     % which set of flags
%     v = zeros(1,nexpdirs);
%     for j = 1:numel(flag_options),
%       v(ismember({data.(examinestats{i}{1})},flag_options{j})) = j;
%     end
%     v = (v/numel(flag_options)*2-1)*3;
%     stat(:,i) = v;

  % special case: notes
  elseif ismember(examinestats{i}{1},note_metadata_fns),
    
    v = cellfun(@(s) ~isempty(s) && ~strcmpi(s,'None'),{data.(examinestats{i}{1})});
    v = double(v)*2*3-3; % make -3, 3
    stat(:,i) = v;


  % special case: strings
  elseif ismember(examinestats{i}{1},string_metadata_fns),
    [uniquevals,~,v] = unique({data.(examinestats{i}{1})});
    if numel(uniquevals) == 1,
      v(:) = 0;
    else
      v = v - 1;
      v = (v/max(v)*2-1)*3;
    end
    stat(:,i) = v;
    
  % numbers
  else
    
    datacurr = {data.(examinestats{i}{1})};
    for k = 2:numel(examinestats{i}),
      datacurr = cellfun(@(s) s.(examinestats{i}{k}),datacurr,'UniformOutput',false);
    end
    badidx = cellfun(@isempty,datacurr);
    for j = find(badidx),
      warning('No data for stat %s experiment %s',sprintf('%s,',examinestats{i}{:}),strtrim(data(j).experiment_name));
    end
    stat(~badidx,i) = cell2mat(datacurr);
    
  end
end
  
%% get mean and standard deviation for z-scoring

if isempty(examine_params.examineexperimentvariablesstatsfile),
  mu = nanmean(stat,1);
  sig = nanstd(stat,1,1);  
else
  normstats = load(examine_params.examineexperimentvariablesstatsfile);
  mu = nan(1,nstats);
  sig = nan(1,nstats);
  for i = 1:nstats,

    pathcurr = examinestats{i};
    statcurr = normstats.mu;
    for j = 1:numel(pathcurr),
      statcurr = statcurr.(pathcurr{j});
    end
    mu(i) = statcurr;
    statcurr = normstats.sig;
    for j = 1:numel(pathcurr),
      statcurr = statcurr.(pathcurr{j});
    end
    sig(i) = statcurr;

  end
end

%% abbr names of stats

statnames = SetStatNames(examinestats);

%% z-score stats

z = sig;
z(z == 0) = 1;
normstat = bsxfun(@rdivide,bsxfun(@minus,stat,mu),z);

%% create figure

if ishandle(hfig),
  close(hfig);
end
figure(hfig);
clf(hfig,'reset');
if isempty(figpos),
  figpos = examine_params.figpos;
end
set(hfig,'Units','Pixels','Position',figpos,'MenuBar','none','ToolBar','figure');
hax = axes('Parent',hfig,'Units','Normalized','Position',examine_params.axespos);
% plot 0
plot(hax,[0,nstats+1],[0,0],'k-','HitTest','off');
hold(hax,'on');
colors = jet(nexpdirs)*.7;
drawnow;

%% plot diagnostics

if nexpdirs == 1,
  off = 0;
else
  off = (2*((1:nexpdirs)-(nexpdirs+1)/2)/(nexpdirs-1))*examine_params.offx;
end

h = nan(1,nexpdirs);
x = nan(nexpdirs,nstats);
for expdiri = 1:nexpdirs,
  x(expdiri,:) = (1:nstats)+off(expdiri);
  h(expdiri) = plot(hax,x(expdiri,:),normstat(expdiri,:),'o',...
    'color',colors(expdiri,:),'markerfacecolor',colors(expdiri,:),...
    'markersize',6,'HitTest','off');
end

xlim = [0,nstats+1];
miny = min(normstat(:));
maxy = max(normstat(:));
dy = maxy - miny;
if dy == 0,
  maxy = miny + .001;
end
ylim = [miny-.01*dy,maxy+.01*dy];
dx = diff(xlim)/figpos(3);
dy = diff(ylim)/figpos(4);
set(hax,'XLim',xlim,'YLim',ylim,'XTick',1:nstats,'XTickLabel',statnames,'XGrid','on');

ylabel(hax,'Stds from mean');

%% set manual_pf = p, f marker

%gray_p_color = [.7,.7,.7];
%gray_f_color = [.5,.5,.5];
badidx = cellfun(@isempty,{data.manual_pf});
for j = find(badidx),
  warning('No data for manual_pf, experiment %s',strtrim(data(j).experiment_name));
end
manual_pf = repmat('U',[1,nexpdirs]);
manual_pf(~badidx) = [data.manual_pf];
idx_manual_p = lower(manual_pf) == 'p';
idx_manual_f = lower(manual_pf) == 'f';
idx_visible = true(1,nexpdirs);
set(h(idx_manual_p),'Marker','+');
set(h(idx_manual_f),'Marker','x');

%% selected experiment

hselected = plot(0,0,'o','color','k','Visible','off','HitTest','off','MarkerSize',10,'MarkerFaceColor','k');
hselected1 = plot(0,0,'o','color','r','Visible','off','HitTest','off','MarkerSize',10,'MarkerFaceColor','r');
expdiri_selected = [];
stati_selected = [];


%% Examine menu

hmenu = struct;
hmenu.file = uimenu('Label','File','Parent',hfig);
hmenu.options = uimenu('Label','Options','Parent',hfig);
hmenu.set = uimenu('Label','Set','Parent',hfig);
hmenu.info = uimenu('Label','Info','Parent',hfig);
hmenu.plot_manual_p = uimenu(hmenu.options,'Label','Plot manual_pf = p',...
  'Checked','on','Callback',@plot_manual_p_Callback);
hmenu.plot_manual_f = uimenu(hmenu.options,'Label','Plot manual_pf = f',...
  'Checked','on','Callback',@plot_manual_f_Callback);
hmenu.set_rest_manual_p = uimenu(hmenu.set,'Label','Set manual_pf == u -> p',...
  'Callback',@set_rest_manual_p_Callback);
hmenu.set_rest_manual_f = uimenu(hmenu.set,'Label','Set manual_pf == u -> f',...
  'Callback',@set_rest_manual_f_Callback);
hmenu.undo = uimenu(hmenu.set,'Label','Undo',...
  'Callback',@undo_Callback,'Enable','off','Accelerator','z');
hmenu.save = uimenu(hmenu.file,'Label','Save Spreadsheet...',...
  'Callback',@save_Callback,'Accelerator','s');
hmenu.load = uimenu(hmenu.file,'Label','Load Spreadsheet...',...
  'Callback',@load_Callback,'Accelerator','l');
hmenu.save_data = uimenu(hmenu.file,'Label','Save Data...',...
  'Callback',@savedata_Callback);
hmenu.load_data = uimenu(hmenu.file,'Label','Load Data...',...
  'Callback',@loaddata_Callback);
hmenu.open = uimenu(hmenu.file,'Label','View Experiment',...
  'Callback',@open_Callback,'Enable','off','Accelerator','o');
hmenu.search = uimenu(hmenu.info,'Label','Search...',...
  'Callback',@search_Callback,'Accelerator','f');
hsearch = struct;

daterangeprint = {datestr(mindatenum,'yyyy-mm-dd'),datestr(maxdatenum,'yyyy-mm-dd')};
hmenu.daterange = uimenu(hmenu.info,'Label',...
  sprintf('Date range: %s - %s ...',daterangeprint{:}));
hmenu.username = uimenu(hmenu.info,'Label',...
  sprintf('User: %s',rc.username));
set(hfig,'CloseRequestFcn',@close_fig_Callback);

%% text box

set(hax,'Units','normalized');
axpos = get(hax,'Position');
textpos = [axpos(1),axpos(2)+axpos(4),axpos(3)/2,1-axpos(2)-axpos(4)-.01];
htext = annotation('textbox',textpos,'BackgroundColor','k','Color','g',...
  'String','Experiment info','Interpreter','none');

%% manual pf

set(htext,'Units','Pixels');
textpos_px = get(htext,'Position');
set(htext,'Units','normalized');
margin = 5;
w1 = 80;
w2 = 100;
w3 = 100;
h1 = 20;
h2 = 30;
c1 = ((figpos(4)-margin) + textpos_px(2))/2;
manualpf_textpos = [textpos_px(1)+textpos_px(3)+margin,c1-h1/2,w1,h1];
hmanualpf = struct;
hmanualpf.text = uicontrol(hfig,'Style','text','Units','Pixels',...
  'Position',manualpf_textpos,'String','Manual PF:',...
  'BackgroundColor',get(hfig,'Color'),'Visible','off');
manualpf_popuppos = [manualpf_textpos(1)+manualpf_textpos(3)+margin,...
  c1-h2/2,w2,h2];
hmanualpf.popup = uicontrol(hfig,'Style','popupmenu','Units','Pixels',...
  'Position',manualpf_popuppos,'String',{'Pass','Fail','Unknown'},...
  'Value',3,'Visible','off','Callback',@manualpf_popup_Callback);
manualpf_pushbuttonpos = [manualpf_popuppos(1)+manualpf_popuppos(3)+margin,...
  c1-h2/2,w3,h2];
hmanualpf.pushbutton = uicontrol(hfig,'Style','pushbutton','Units','Pixels',...
  'Position',manualpf_pushbuttonpos,'String','Add Note...',...
  'Callback',@manualpf_pushbutton_Callback,...
  'Visible','off');
manualpf_pushbutton_info_pos = [manualpf_pushbuttonpos(1)+manualpf_pushbuttonpos(3)+margin,...
  c1-h2/2,w3,h2];
hmanualpf.pushbutton_info = uicontrol(hfig,'Style','pushbutton','Units','Pixels',...
  'Position',manualpf_pushbutton_info_pos,'String','Add Info...',...
  'Callback',@manualpf_pushbutton_info_Callback,...
  'Visible','off');
set([hmanualpf.text,hmanualpf.popup,hmanualpf.pushbutton,hmanualpf.pushbutton_info],'Units','normalized');

hnotes = struct;
hinfo = struct;
info = false(nexpdirs,nstats);


%% date

set(hax,'Units','Pixels');
axpos_px = get(hax,'Position');
set(hax,'Units','normalized');
w1 = 20;
h1 = 20;
w2 = 150;
margin = 5;
nextpos = [axpos_px(1)+axpos_px(3)-w1,axpos_px(2)+axpos_px(4)+margin,w1,h1];
currpos = [nextpos(1)-margin-w2,nextpos(2),w2,h1];
prevpos = [currpos(1)-margin-w1,nextpos(2),w1,h1];
hdate = struct;
if mindaysprev <= 0,
  s = 'this week';
elseif mindaysprev < 7,
  s = 'last week';
else
  s = sprintf('%d weeks ago',ceil(mindaysprev/7));
end
hdate.curr = uicontrol(hfig,'Style','text','Units','Pixels',...
  'Position',currpos,'String',s);
hdate.next = uicontrol(hfig,'Style','pushbutton','Units','Pixels',...
  'Position',nextpos,'String','>','Callback',@nextdate_Callback);
hdate.prev = uicontrol(hfig,'Style','pushbutton','Units','Pixels',...
  'Position',prevpos,'String','<','Callback',@prevdate_Callback);
if mindaysprev < .0001,
  set(hdate.next,'Enable','off');
else
  set(hdate.prev,'Enable','on');
end
set([hdate.curr,hdate.prev,hdate.next],'Units','normalized');

%% rotate x-tick labels

hx = rotateticklabel(hax,90);
% make sure the ticks don't overlap the x-axis
ex = get(hx(1),'Extent');
y1 = ex(2)+ex(4);
offy = y1-ylim(1);
for i = 1:numel(hx),
  pos = get(hx(i),'Position');
  pos(2) = pos(2) - offy;
  set(hx(i),'Position',pos);
end
set(hx,'Interpreter','none');

%% set buttondownfcn

set(hax,'ButtonDownFcn',@ButtonDownFcn);

% hchil = findobj(hfig,'Units','Pixels');
% set(hchil,'Units','normalized');

%% set motion function

set(hfig,'WindowButtonMotionFcn',@MotionFcn,'BusyAction','queue');

%% undo list

undolist = [];

%% return values

handles = struct;
handles.hx = hx;
handles.hax = hax;
handles.hfig = hfig;
handles.h = h;
handles.hselected = hselected;
handles.hselected1 = hselected1;
handles.htext = htext;
handles.hdate = hdate;
% handles.hcmenu_manualpf = hcmenu_manualpf;
% handles.hcmenu = hcmenu;

%% set stat names

  function statnames = SetStatNames(examinestats)

    statnames = cell(1,nstats);
    for tmpi = 1:nstats,
      
      statnames{tmpi} = sprintf('%s_',examinestats{tmpi}{:});
      statnames{tmpi} = statnames{tmpi}(1:end-1);
      statnames{tmpi} = strrep(statnames{tmpi},'stats_perframe_','');
      statnames{tmpi} = strrep(statnames{tmpi},'meanmean_perexp_','');
      statnames{tmpi} = strrep(statnames{tmpi},'flyany_frame','');
      statnames{tmpi} = strrep(statnames{tmpi},'ufmf_diagnostics_summary','ufmf');
      statnames{tmpi} = strrep(statnames{tmpi},'ufmf_diagnostics_stream','ufmf');
      statnames{tmpi} = strrep(statnames{tmpi},'temperature_diagnostics','temp');
      statnames{tmpi} = strrep(statnames{tmpi},'bias_diagnostics','bias');
      statnames{tmpi} = strrep(statnames{tmpi},'bkgd_diagnostics','bkgd');
      statnames{tmpi} = strrep(statnames{tmpi},'ctrax_diagnostics','ctrax');
      statnames{tmpi} = strrep(statnames{tmpi},'registrationdata','reg');
      statnames{tmpi} = strrep(statnames{tmpi},'sexclassifier_diagnostics','sex');
      statnames{tmpi} = strrep(statnames{tmpi},'stats_perframe_','');
      statnames{tmpi} = strrep(statnames{tmpi},'flyany_frame','');
      statnames{tmpi} = strrep(statnames{tmpi},'_perexp','');
      
    end
    
  end

%% print function

  function s = printfun(expdiri,stati)
    
    s = cell(1,2);
    s{1} = expdir_bases{expdiri};
    % special case: flags
    if isempty(stati),
      s = s(1);
    else
      if ismember(examinestats{stati}{1},note_metadata_fns) || ...
          ismember(examinestats{stati}{1},string_metadata_fns),
        if iscell(data(expdiri).(examinestats{stati}{1})),
          s1 = sprintf('%s ',data(expdiri).(examinestats{stati}{1}){:});
        else
          s1 = data(expdiri).(examinestats{stati}{1});
        end
        s{2} = sprintf('%s = %s',statnames{stati},s1);
      else
        s{2} = sprintf('%s = %s = %s std',statnames{stati},...
          num2str(stat(expdiri,stati)),num2str(normstat(expdiri,stati)));
      end
    end
  end

%% button down function

  function ButtonDownFcn(varargin)
        
    try
      
      if ~isempty(stati_selected),
        set(hx(stati_selected),'Color','k','FontWeight','normal');
      end

      
      % get current point
      tmp = get(hax,'CurrentPoint');
      xclicked = tmp(1,1);
      yclicked = tmp(1,2);
      tmpidx = find(idx_visible);
      tmpn = numel(tmpidx);
      [d,closest] = min( ((reshape(x(idx_visible,:),[1,tmpn*nstats])-xclicked)/dx).^2+...
        ((reshape(normstat(idx_visible,:),[1,tmpn*nstats])-yclicked)/dy).^2 );
      d = sqrt(d);
      
      if d > examine_params.maxdistclick,
        set(hselected,'Visible','off');
        set(hselected1,'Visible','off');
        set(hmenu.open,'Enable','off');
        stati_selected = [];
        expdiri_selected = [];
        set(htext,'String','');
        set([hmanualpf.text,hmanualpf.popup,hmanualpf.pushbutton,hmanualpf.pushbutton_info],'Visible','off');
        return;
      end
      
      SelectionType = get(hfig,'SelectionType');
      set([hmanualpf.text,hmanualpf.popup,hmanualpf.pushbutton,hmanualpf.pushbutton_info],'Visible','on');

      [expdiri_selected,stati_selected] = ind2sub([tmpn,nstats],closest);
      expdiri_selected = tmpidx(expdiri_selected);

      UpdateSelected();
      
      if strcmp(SelectionType,'open'),
        
        open_Callback();

      end
      
    catch ME,

      fprintf('Error evaluating buttondownfcn, disabling:\n');
      set(hax,'ButtonDownFcn','');
      rethrow(ME);
    end
    
  end

%% update stat selected-based stuff

  function UpdateStatSelected()
    
    %set(hfig,'Interruptible','off');
    s = printfun(expdiri_selected,stati_selected);
    set(htext,'String',s); 
    set(hselected1,'XData',x(expdiri_selected,stati_selected),...
      'YData',normstat(expdiri_selected,stati_selected),'visible','on');
    set(hmenu.open,'Enable','on');
    set(hx,'Color','k','FontWeight','normal');
    set(hx(stati_selected),'Color','r','FontWeight','bold');
    %set(hfig,'Interruptible','on');

  end

%% update all info dependent on stat, experiment selected

  function UpdateSelected()
      
    UpdateStatSelected();
    
    set(hselected,'XData',x(expdiri_selected,:),'YData',normstat(expdiri_selected,:),'Visible','on');
    set(hmenu.open,'Enable','on');
    
    manual_pf_curr = data(expdiri_selected).manual_pf;
    s = get(hmanualpf.popup,'String');
    vcurr = find(strncmpi(manual_pf_curr,s,1),1);
    if isempty(vcurr),
      error('Unknown manual_pf %s',manual_pf_curr);
    end
    set(hmanualpf.popup,'Value',vcurr);
    
  end

%% manual_pf = p callback

  function plot_manual_p_Callback(hObject,event) %#ok<INUSD>
    
    v = get(hObject,'Checked');
    set(h(idx_manual_p),'Visible',v);
    if strcmpi(v,'on'),
      set(hObject,'Checked','off');
      idx_visible(idx_manual_p) = false;
      set(h(~idx_visible),'Visible','off');
    else
      set(hObject,'Checked','on');
      idx_visible(idx_manual_p) = true;
      set(h(idx_visible),'Visible','on');
    end
    
  end

%% manual_pf = f callback

  function plot_manual_f_Callback(hObject,event) %#ok<INUSD>
    
    v = get(hObject,'Checked');
    set(h(idx_manual_f),'Visible',v);
    if strcmpi(v,'on'),
      set(hObject,'Checked','off');
      idx_visible(idx_manual_f) = false;
      set(h(~idx_visible),'Visible','off');
    else
      set(hObject,'Checked','on');
      idx_visible(idx_manual_f) = true;
      set(h(idx_visible),'Visible','on');
    end
    
  end

%% go to next date range

  function nextdate_Callback(hObject,event)
    
    if needsave,
      answer = questdlg('Save manual_pf and notes?');
      switch lower(answer),
        case 'cancel',
          return;
        case 'yes',
          save_Callback(hObject,event);
      end
    end
    
    if exist('hsearch','var') && isfield(hsearch,'dialog') && ...
        ishandle(hsearch.dialog),...
        delete(hsearch.dialog);
    end
    
    maxdatenum = maxdatenum + period;
    handles = FlyBowlExamineExperimentVariables(...
      'analysis_protocol',analysis_protocol,...
      'settingsdir',settingsdir,...
      'datalocparamsfilestr',datalocparamsfilestr,...
      'hfig',hfig,...
      'period',period,...
      'maxdatenum',maxdatenum,...
      'figpos',get(hfig,'Position'),...
      'datenumnow',datenumnow,...
      'sage_params_path',sage_params_path,...
      'sage_db',sage_db,...
      'username',rc.username,...
      'rootdatadir',rootdatadir,...
      'dataset',dataset,...
      'loadcacheddata',loadcacheddata,...
      'groupnames',groupnames);

  end

%% go to previous date range

  function prevdate_Callback(hObject,event)
    
    if needsave,
      answer = questdlg('Save manual_pf and notes?');
      switch lower(answer),
        case 'cancel',
          return;
        case 'yes',
          save_Callback(hObject,event);
      end
    end
   
        
    if exist('hsearch','var') && isfield(hsearch,'dialog') && ...
        ishandle(hsearch.dialog),...
        delete(hsearch.dialog);
    end
    
    maxdatenum = maxdatenum - period;
    handles = FlyBowlExamineExperimentVariables(...
      'analysis_protocol',analysis_protocol,...
      'settingsdir',settingsdir,...
      'datalocparamsfilestr',datalocparamsfilestr,...
      'hfig',hfig,...
      'period',period,...
      'maxdatenum',maxdatenum,...
      'figpos',get(hfig,'Position'),...
      'datenumnow',datenumnow,...
      'sage_params_path',sage_params_path,...
      'sage_db',sage_db,...
      'username',rc.username,...
      'rootdatadir',rootdatadir,...
      'dataset',dataset,...
      'loadcacheddata',loadcacheddata,...
      'groupnames',groupnames);


  end

%% set manual pf callback
  
  function manualpf_popup_Callback(hObject,event) %#ok<INUSD>
    
    if isempty(expdiri_selected),
      warning('No experiment selected');
      return;
    end

    addToUndoList();
    
    s = get(hObject,'String');
    vcurr = get(hObject,'Value');
    manual_pf_full = s{vcurr};
    manual_pf_new = manual_pf_full(1);
    data(expdiri_selected).manual_pf = manual_pf_new;
    %SetManualPF(data(expdiri_selected),sage_db);
    manual_pf(expdiri_selected) = manual_pf_new;

    switch lower(manual_pf_new),
      
      case 'p',
        
        % update indices
        idx_manual_p(expdiri_selected) = true;
        idx_manual_f(expdiri_selected) = false;

        % update marker
        set(h(expdiri_selected),'Marker','+');

        % update visible
        set(h(expdiri_selected),'Visible',get(hmenu.plot_manual_p,'Checked'));

      case 'f',

        % update indices
        idx_manual_p(expdiri_selected) = false;
        idx_manual_f(expdiri_selected) = true;

        % update marker
        set(h(expdiri_selected),'Marker','x');
        
        % update visible
        set(h(expdiri_selected),'Visible',get(hmenu.plot_manual_f,'Checked'));
        
      case 'u',
        
        % update indices
        idx_manual_p(expdiri_selected) = false;
        idx_manual_f(expdiri_selected) = false;
        
        % update marker
        set(h(expdiri_selected),'Marker','o');

        % update visible
        idx_visible(expdiri_selected) = true;
        set(h(expdiri_selected),'Visible','on');
        
      otherwise
        
        error('Unknown manual_pf value %s',manual_pf_new);
        
    end
    needsave = true;

    
  end

%% notes callbacks
 function manualpf_pushbutton_Callback(hObject,event) %#ok<INUSD>
    
   hnotes.dialog = dialog('Name','Add notes','WindowStyle','Normal','Resize','on');
   done_pos = [.29,.02,.2,.1];
   cancel_pos = [.51,.02,.2,.1];
   notes_pos = [.02,.14,.96,.84];

   if iscell(data(expdiri_selected).notes_curation),
     notes_curation_curr = data(expdiri_selected).notes_curation;
   else
     notes_curation_curr = regexp(data(expdiri_selected).notes_curation,'\\n','split');
   end

   hnotes.pushbutton_done = uicontrol(hnotes.dialog,'Style','pushbutton',...
     'Units','normalized','Position',done_pos,...
     'String','Done','Callback',@notes_done_Callback);
   hnotes.pushbutton_cancel = uicontrol(hnotes.dialog,'Style','pushbutton',...
     'Units','normalized','Position',cancel_pos,...
     'String','Cancel','Callback',@notes_cancel_Callback);
   hnotes.edit_notes = uicontrol(hnotes.dialog,'Style','edit',...
     'Units','normalized','Position',notes_pos,...
     'Min',0,'Max',25,...
     'String',notes_curation_curr,...
     'HorizontalAlignment','left',...
     'BackgroundColor','w');
   uiwait(hnotes.dialog);
   
 end

  function notes_done_Callback(hObject,event) %#ok<INUSD>
    
    addToUndoList();
    
    data(expdiri_selected).notes_curation = get(hnotes.edit_notes,'String');
    %SetNotes(data(expdiri_selected),sage_db);
    
    tmpi = find(strcmpi(examinestats,'notes_curation'),1);
    if ~isempty(tmpi),
      s = data(expdiri_selected).notes_curation;
      v = ~isempty(s) && ~strcmpi(s,'None');
      v = double(v)*2*3-3; % make -3, 3
      stat(expdiri_selected,tmpi) = v;
      normstat(expdiri_selected,tmpi) = ...
        (stat(expdiri_selected,tmpi) - mu(tmpi))/z(tmpi);
      set(h(expdiri_selected),'YData',normstat(expdiri_selected,:));
      set(hselected,'YData',normstat(expdiri_selected,:));
      set(hselected1,'YData',normstat(expdiri_selected,stati_selected));
    end
    needsave = true;
    
    close(hnotes.dialog);
    
  end

  function notes_cancel_Callback(hObject,event) %#ok<INUSD>
    
    close(hnotes.dialog);
    
  end

%% set rest callbacks

  function set_rest_manual_p_Callback(hObject,event) %#ok<INUSD>
    set_rest_manual_Callback('P');
  end

  function set_rest_manual_f_Callback(hObject,event) %#ok<INUSD>
    set_rest_manual_Callback('F');
  end

  function set_rest_manual_Callback(s)

    addToUndoList();
    
    b = questdlg(sprintf('Set all experiments plotted with manual_pf = U to %s?',s),...
      'Set manual_pf for rest?');
    if ~strcmpi(b,'Yes'),
      return;
    end
    
    idx = find(lower(manual_pf) == 'u');
    
    if isempty(idx),
      return;
    end
    
    needsave = true;
    
    for tmpi = idx,
      data(tmpi).manual_pf = s;
      %SetManualPF(data(tmpi),sage_db);
    end
    manual_pf(idx) = s;
    
    if lower(s) == 'p',

      % update indices
      idx_manual_p(idx) = true;
      idx_manual_f(idx) = false;
      
      % update marker
      set(h(idx),'Marker','+');
      
      % update visible
      set(h(idx),'Visible',get(hmenu.plot_manual_p,'Checked'));
      
    else

      % update indices
      idx_manual_p(idx) = false;
      idx_manual_f(idx) = true;
      
      % update marker
      set(h(idx),'Marker','x');
      
      % update visible
      set(h(idx),'Visible',get(hmenu.plot_manual_f,'Checked'));
      
    end
    
  end

%% save callback

  function save_Callback(hObject,event) %#ok<INUSD>
    
    while true
      [savefilename1,savepath1] = uiputfile(savefilename,'Save manual_pf tsv');
      if ~ischar(savefilename1),
        return;
      end
      savefilename = fullfile(savepath1,savefilename1);
      rc.savepath = savepath1;
      %[savepath2,savefilename2] = fileparts(savefilename);
      %savefilename2 = fullfile(savepath2,[savefilename2,'_diagnosticinfo.mat']);
      
      fid = fopen(savefilename,'w');
      if fid < 0,
        warndlg(sprintf('Could not open file %s for writing. Make sure it is not open in another program.',savefilename),'Could not save');
        continue;
      end
      break;
    end
    fprintf(fid,'#line_name\texperiment_name\tmanual_pf\tnotes_curation\tdiagnostic_fields\n');
    for tmpj = 1:nexpdirs,
      if iscell(data(tmpj).notes_curation),
        notes_curation_curr = sprintf('%s\\n',data(tmpj).notes_curation{:});
        notes_curation_curr = notes_curation_curr(1:end-2);
      else
        notes_curation_curr = data(tmpj).notes_curation;
      end
      if numel(notes_curation_curr) >= 2 && strcmp(notes_curation_curr(end-1:end),'\n'),
        notes_curation_curr = notes_curation_curr(1:end-2);
      end
      if numel(notes_curation_curr) >= 3 && strcmp(notes_curation_curr(end-2:end),'\n"'),
        notes_curation_curr = [notes_curation_curr(1:end-3),'"'];
      end
      fprintf(fid,'%s\t%s\t%s\t%s\t',...
        data(tmpj).line_name,...
        data(tmpj).experiment_name,...
        data(tmpj).manual_pf,...
        notes_curation_curr);
      % also print info
      idx = info(tmpj,:);
      if ~any(idx),
        tmps = '';
      else
        tmps = sprintf('%s,',statnames{idx});
        tmps = tmps(1:end-1);
      end
      fprintf(fid,'%s\n',tmps);
    end
    fclose(fid);
    %save(savefilename2,'info','data','examinestats');
    needsave = false;
    
  end

%% save data callback

  function savedata_Callback(hObject,event) %#ok<INUSD>

    SaveExamineData;
 
  end

%% load data callback

  function loaddata_Callback(hObject,event) %#ok<INUSD>

    [didloaddata,newdata,newqueries,newpull_data_datetime,rc,savedatafilename] = ...
      LoadExamineData(savedatafilename,mindatenum,maxdatenum,rc,true)
 
  end


%% close callback

  function close_fig_Callback(hObject,event)
    
    if needsave,
      answer = questdlg('Save manual_pf and notes?');
      switch lower(answer),
        case 'cancel',
          return;
        case 'yes',
          save_Callback(hObject,event);
      end
    end
    
    try
      save(examine_params.rcfile,'-struct','rc');
    catch ME,
      warning('Error saving rc file:\n %s',getReport(ME));
    end
    
    if ishandle(hObject),
      delete(hObject);
    end
    
  end

%% add state to undo list

  function addToUndoList()

    if numel(undolist) >= maxnundo,
      undolist = undolist(end-maxnundo+1:end);
    end
    undolist = structappend(undolist,...
      struct('manual_pf',{[data.manual_pf]},...
      'notes_curation',{{data.notes_curation}},...
      'info',{info}));
    set(hmenu.undo,'Enable','on');
  end


%% reset state

  function setManualPFState(s)
  
    manual_pf = s.manual_pf;
    for tmpi = 1:nexpdirs,
      data(tmpi).manual_pf = s.manual_pf(tmpi);
      data(tmpi).notes_curation = s.notes_curation{tmpi};
    end
    idx_manual_p = lower(manual_pf) == 'p';
    idx_manual_f = lower(manual_pf) == 'f';
    idx_visible = true(1,nexpdirs);
    if strcmpi(get(hmenu.plot_manual_p,'Checked'),'off'),
      idx_visible(idx_manual_p) = false;
    end
    if strcmpi(get(hmenu.plot_manual_f,'Checked'),'off'),
      idx_visible(idx_manual_f) = false;
    end
    set(h,'Marker','o');
    set(h(idx_manual_p),'Marker','+');
    set(h(idx_manual_f),'Marker','x');
    set(h(idx_visible),'Visible','on');
    set(h(~idx_visible),'Visible','off');
    
    if ~isempty(expdiri_selected),
      manual_pf_curr = data(expdiri_selected).manual_pf;
      ss = get(hmanualpf.popup,'String');
      vcurr = find(strncmpi(manual_pf_curr,ss,1),1);
      if isempty(vcurr),
        error('Unknown manual_pf %s',manual_pf_curr);
      end
      set(hmanualpf.popup,'Value',vcurr);
    end
    info = s.info;
    
  end

%% undo callback

  function undo_Callback(hObject,event) %#ok<INUSD>
    
    if isempty(undolist), return; end
    setManualPFState(undolist(end));
    undolist = undolist(1:end-1);
    if isempty(undolist),
      set(hmenu.undo,'Enable','off');
    end
    
  end

%% info callback
 function manualpf_pushbutton_info_Callback(hObject,event) %#ok<INUSD>

   ncstats = 4;
   nrstats = ceil(nstats/ncstats);
   checkbox_h = 20;
   checkbox_w = 200;
   border = 10;
   donebutton_h = 20;
   donebutton_w = 60;
   dialog_h = nrstats*checkbox_h+border*3+donebutton_h;
   dialog_w = ncstats*checkbox_w+border*2;
   
   hinfo.dialog = dialog('Name','Add information','WindowStyle','Normal',...
     'Resize','on','Units','pixels','CloseRequestFcn',@info_done_Callback);
   SetFigureSize(hinfo.dialog,dialog_w,dialog_h);
   hinfo.checkboxes = nan(1,nstats);
   
   for tmpi = 1:nstats,
     [tmpr,tmpc] = ind2sub([nrstats,ncstats],tmpi);
     checkbox_pos = [border+(tmpc-1)*checkbox_w,dialog_h-(border+tmpr*checkbox_h),...
       checkbox_w,checkbox_h];
     hinfo.checkboxes(tmpi) = uicontrol(hinfo.dialog,'Style','checkbox',...
       'String',statnames{tmpi},'Position',checkbox_pos,...
       'Value',info(expdiri_selected,tmpi));
   end
   hinfo.donebutton = uicontrol(hinfo.dialog,'Style','pushbutton',...
     'String','Done','Position',...
     [dialog_w/2-donebutton_w/2,border,donebutton_w,donebutton_h],...
     'Callback',@info_done_Callback);
   uiwait(hinfo.dialog);
   
 end

  function info_done_Callback(hObject,event) %#ok<INUSD>
    
    for tmpi = 1:nstats,
      info(expdiri_selected,tmpi) = get(hinfo.checkboxes(tmpi),'Value') == 1;
    end
    needsave = true;
    delete(hinfo.dialog);
    
  end

%% mouse motion callback

  function MotionFcn(hObject,event) %#ok<INUSD>
    
    if isempty(expdiri_selected),
      return;
    end
    
    try
      tmp = get(hax,'CurrentPoint');
      xhover = tmp(1,1);
      if xhover < 0 || xhover > nstats+1,
        return;
      end
      stati_selected = min(nstats,max(1,round(xhover)));
      UpdateStatSelected();
    catch ME,
      fprintf('Error evaluating motionfcn, disabling:\n');
      set(hfig,'WindowButtonMotionFcn','');
      rethrow(ME);
    end
    
  end

%% open experiment callback

  function open_Callback(hObject,event)
    % open experiment
    if isempty(expdiri_selected),
      return;
    end
    if ispc,
      winopen(expdirs{expdiri_selected});
    else
      web(expdirs{expdiri_selected},'-browser');
    end
  end

%% load curation spreadsheet callback

  function load_Callback(hObject,event) %#ok<INUSD>

    numel_info = 5;
    numel_noinfo = numel_info-1;
    
    if needsave,
      res = questdlg('Load state from file? All changes will be lost.');
      if ~strcmpi(res,'yes'),
        return;
      end
    end
    addToUndoList();
    [loadfilename,loadpath] = uigetfile(savefilename,'Load data curation tsv');
    if ~ischar(loadfilename),
      return;
    end
    loadfilename = fullfile(loadpath,loadfilename);
    
    state = undolist(end);
    experiment_names = {data.experiment_name};
    
    [loadpath2,loadfilename2] = fileparts(loadfilename);
    loadfilename2 = fullfile(loadpath2,[loadfilename2,'_diagnosticinfo.mat']);
    if exist(loadfilename2,'file'),
      try
        tmpinfo = load(loadfilename2,'info','data','examinestats');
        tmpinfo.experiment_names = {tmpinfo.data.experiment_name};
        newstatnames = SetStatNames(tmpinfo.examinestats);
        if ~isempty(setdiff(statnames,newstatnames)) || ...
            ~isempty(setdiff(newstatnames,statnames)),
          error('examined stats different, not loading diagnostic info');
        end
        [isintersect,idxcurr] = ismember(tmpinfo.experiment_names,experiment_names);
        state.info(idxcurr(isintersect),:) = tmpinfo.info(isintersect,:);
       catch ME,
        warning('Could not load info from %s:\n%s',loadfilename2,getReport(ME));
      end
    end
    
    fid = fopen(loadfilename,'r');
    while true,
      
      ss = fgetl(fid);
      % end of file
      if ~ischar(ss), break; end
      
      % comments
      if isempty(ss) || ~isempty(regexp(ss,'^\s*$','once')) || ...
          ~isempty(regexp(ss,'^\s*#','once')),
        continue;
      end
      
      % split at tabs
      m = regexp(ss,'\t','split');
      if numel(m) < 3 || numel(m) > numel_info,
        warning('Skipping line %s: wrong number of fields',s);
        continue;
      end

      if numel(m) < numel_noinfo,
        m = [m,repmat({''},[1,numel_noinfo-numel(m)])];
      end

      for tmpi = 1:numel(m),
        if regexp(m{tmpi},'^".*"$','once'),
          m{tmpi} = m{tmpi}(2:end-1);
        end
      end
      
      isinfo = numel(m) == numel_info;
      experiment_name = m{2};
      manual_pf_curr = m{3};
      notes_curation_curr = m{4};
      
      notes_curation_curr = regexp(notes_curation_curr,'\\n','split');
      if isinfo,
        info_s = regexp(m{5},',','split');
        info_s = setdiff(info_s,{''});
        info_curr = ismember(statnames,info_s);
        unknown_stats = ~ismember(info_s,statnames);
        if any(unknown_stats),
          warning(['Unknown info stats: ',sprintf('%s ',info_s{unknown_stats})]);
        end
      end
      
      tmpi = find(strcmp(experiment_names,experiment_name),1);
      if isempty(tmpi),
        fprintf('experiment %s not currently examined, skipping\n',experiment_name);
        continue;
      end
      
      state.manual_pf(tmpi) = manual_pf_curr(1);
      state.notes_curation{tmpi} = notes_curation_curr;
      if isinfo,
        state.info(tmpi,:) = info_curr;
      end
    
    end
    fclose(fid);
    
    needsave = true;
    setManualPFState(state);
    
  end

%% search callback

  function search_Callback(hObject,event) %#ok<INUSD>
    
    if ~isfield(hsearch,'dialog') || ~ishandle(hsearch.dialog),
      line_height = 20;
      prompt_width = 50;
      answer_width = 200;
      button_width = 75;
      button_height = 30;
      gap_width = 5;
      gap_height = 10;
      nl = 3;
      dlg_height = (nl-1)*line_height + button_height + (nl+1)*gap_height;
      dlg_width = prompt_width + answer_width + 3*gap_width;
      hsearch.dialog = dialog('Name','Find experiments','WindowStyle','normal',...
        'Units','pixels');
      SetFigureSize(hsearch.dialog,dlg_width,dlg_height);
      hsearch.field_text = uicontrol(hsearch.dialog,'Style','text',...
        'Units','pixels',...
        'Position',[gap_width,dlg_height-(line_height+gap_height),prompt_width,line_height],...
        'String','Field: ',...
        'HorizontalAlignment','right');
      groupi = find(strcmp(groupnames,'line_name'),1);
      if isempty(groupi),
        groupi = 1;
      end
      hsearch.field_popupmenu = uicontrol(hsearch.dialog,'Style','popupmenu',...
        'Units','pixels',...
        'Position',[prompt_width+2*gap_width,dlg_height-(line_height+gap_height),answer_width,line_height],...
        'String',groupnames,...
        'Value',groupi,...
        'HorizontalAlignment','right',...
        'Callback',@search_field_Callback);
      hsearch.value_text = uicontrol(hsearch.dialog,'Style','text',...
        'Units','pixels',...
        'Position',[gap_width,dlg_height-2*(line_height+gap_height),prompt_width,line_height],...
        'String','Value: ',...
        'HorizontalAlignment','right');
      if iscell(groupvalues{groupi}),
        group_s = groupvalues{groupi};
      else
        group_s = num2str(groupvalues{groupi}(:));
      end
      hsearch.value_popupmenu = uicontrol(hsearch.dialog,'Style','popupmenu',...
        'Units','pixels',...
        'Position',[prompt_width+2*gap_width,dlg_height-2*(line_height+gap_height),answer_width,line_height],...
        'String',group_s,...
        'Value',1,...
        'HorizontalAlignment','right',...
        'Callback',@search_value_Callback);
      hsearch.findnext_pushbutton = uicontrol(hsearch.dialog,'Style','pushbutton',...
        'Units','pixels',...
        'Position',[dlg_width/2-button_width/2,dlg_height-(2*line_height+button_height+3*gap_height),button_width,button_height],...
        'String','Find next',...
        'HorizontalAlignment','center',...
        'Callback',@search_findnext_Callback);
      
    else
      figure(hsearch.dialog);
    end
    
    hsearch.resulti = 0;
    
  end

  function search_field_Callback(varargin)
    
    groupi = get(hsearch.field_popupmenu,'Value');
    if iscell(groupvalues{groupi}),
      group_s = groupvalues{groupi};
    else
      group_s = num2str(groupvalues{groupi}(:));
    end
    set(hsearch.value_popupmenu,'String',group_s,'Value',1);
    hsearch.resulti = 0;
    
  end

  function search_value_Callback(varargin)
    
    hsearch.resulti = 0;
    
  end

  function search_findnext_Callback(varargin)
    
    groupi = get(hsearch.field_popupmenu,'Value');
    groupname = groupnames{groupi};
    groupvaluei = get(hsearch.value_popupmenu,'Value');
    % need to do the search
    if hsearch.resulti == 0,
      if iscell(groupvalues{groupi}),
        hsearch.results = find(strcmp({data.(groupname)},groupvalues{groupi}{groupvaluei}));
      else
        hsearch.results = find([data.(groupname)] == groupvalues{groupi}(groupvaluei));
      end
    end
    
    hsearch.resulti = hsearch.resulti + 1;
    if hsearch.resulti > numel(hsearch.results),
      hsearch.resulti = 1;
    end
    
    expdiri_selected = hsearch.results(hsearch.resulti);    
    fprintf('Selecting experiment %s\n',data(expdiri_selected).experiment_name);
    
    UpdateSelected();
    
  end

end
